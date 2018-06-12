Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A05BC6B0271
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 10:39:35 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t5-v6so7804024pgt.18
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 07:39:35 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id d191-v6si257904pga.192.2018.06.12.07.39.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 07:39:30 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 15/17] x86/mm: Implement sync_direct_mapping()
Date: Tue, 12 Jun 2018 17:39:13 +0300
Message-Id: <20180612143915.68065-16-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For MKTME we use per-KeyID direct mappings. This allows kernel to have
access to encrypted memory.

sync_direct_mapping() sync per-KeyID direct mappings with a canonical
one -- KeyID-0.

The function tracks changes in the canonical mapping:
 - creating or removing chunks of the translation tree;
 - changes in mapping flags (i.e. protection bits);
 - splitting huge page mapping into a page table;
 - replacing page table with a huge page mapping;

The function need to be called on every change to the direct mapping:
hotplug, hotremove, changes in permissions bits, etc.

The function is nop until MKTME is enabled.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/mktme.h |   6 +
 arch/x86/mm/init_64.c        |   6 +
 arch/x86/mm/mktme.c          | 444 +++++++++++++++++++++++++++++++++++
 3 files changed, 456 insertions(+)

diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
index 3bf481fe3f56..efc0d4bb3b35 100644
--- a/arch/x86/include/asm/mktme.h
+++ b/arch/x86/include/asm/mktme.h
@@ -41,11 +41,17 @@ int page_keyid(const struct page *page);
 void mktme_disable(void);
 
 void setup_direct_mapping_size(void);
+int sync_direct_mapping(void);
 
 #else
 #define mktme_keyid_mask	((phys_addr_t)0)
 #define mktme_nr_keyids		0
 #define mktme_keyid_shift	0
+
+static inline int sync_direct_mapping(void)
+{
+	return 0;
+}
 #endif
 
 #endif
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 17383f9677fa..032b9a1ba8e1 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -731,6 +731,8 @@ kernel_physical_mapping_init(unsigned long paddr_start,
 		pgd_changed = true;
 	}
 
+	sync_direct_mapping();
+
 	if (pgd_changed)
 		sync_global_pgds(vaddr_start, vaddr_end - 1);
 
@@ -1142,10 +1144,13 @@ void __ref vmemmap_free(unsigned long start, unsigned long end,
 static void __meminit
 kernel_physical_mapping_remove(unsigned long start, unsigned long end)
 {
+	int ret;
 	start = (unsigned long)__va(start);
 	end = (unsigned long)__va(end);
 
 	remove_pagetable(start, end, true, NULL);
+	ret = sync_direct_mapping();
+	WARN_ON(ret);
 }
 
 int __ref arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
@@ -1290,6 +1295,7 @@ void mark_rodata_ro(void)
 			(unsigned long) __va(__pa_symbol(rodata_end)),
 			(unsigned long) __va(__pa_symbol(_sdata)));
 
+	sync_direct_mapping();
 	debug_checkwx();
 
 	/*
diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index 3e5322bf035e..6dd7d0c090e8 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -1,6 +1,8 @@
 #include <linux/mm.h>
 #include <linux/highmem.h>
 #include <asm/mktme.h>
+#include <asm/pgalloc.h>
+#include <asm/tlbflush.h>
 
 phys_addr_t mktme_keyid_mask;
 int mktme_nr_keyids;
@@ -90,6 +92,440 @@ struct page_ext_operations page_mktme_ops = {
 	.need = need_page_mktme,
 };
 
+static int sync_direct_mapping_pte(unsigned long keyid,
+		pmd_t *dst_pmd, pmd_t *src_pmd,
+		unsigned long addr, unsigned long end)
+{
+	pte_t *src_pte, *dst_pte;
+	pte_t *new_pte = NULL;
+	bool remove_pte;
+
+	/*
+	 * We want to unmap and free the page table if the source is empty and
+	 * the range covers whole page table.
+	 */
+	remove_pte = !src_pmd && PAGE_ALIGNED(addr) && PAGE_ALIGNED(end);
+
+	/*
+	 * PMD page got split into page table.
+	 * Clear PMD mapping. Page table will be established instead.
+	 */
+	if (pmd_large(*dst_pmd)) {
+		spin_lock(&init_mm.page_table_lock);
+		pmd_clear(dst_pmd);
+		spin_unlock(&init_mm.page_table_lock);
+	}
+
+	/* Allocate a new page table if needed. */
+	if (pmd_none(*dst_pmd)) {
+		new_pte = (void *)__get_free_page(GFP_KERNEL | __GFP_ZERO);
+		if (!new_pte)
+			return -ENOMEM;
+		dst_pte = new_pte + pte_index(addr + keyid * direct_mapping_size);
+	} else {
+		dst_pte = pte_offset_map(dst_pmd, addr + keyid * direct_mapping_size);
+	}
+	src_pte = src_pmd ? pte_offset_map(src_pmd, addr) : NULL;
+
+	spin_lock(&init_mm.page_table_lock);
+
+	do {
+		pteval_t val;
+
+		if (!src_pte || pte_none(*src_pte)) {
+			set_pte(dst_pte, __pte(0));
+			goto next;
+		}
+
+		if (!pte_none(*dst_pte)) {
+			/*
+			 * Sanity check: PFNs must match between source
+			 * and destination even if the rest doesn't.
+			 */
+			BUG_ON(pte_pfn(*dst_pte) != pte_pfn(*src_pte));
+		}
+
+		/* Copy entry, but set KeyID. */
+		val = pte_val(*src_pte) | keyid << mktme_keyid_shift;
+		set_pte(dst_pte, __pte(val));
+next:
+		addr += PAGE_SIZE;
+		dst_pte++;
+		if (src_pte)
+			src_pte++;
+	} while (addr != end);
+
+	if (new_pte)
+		pmd_populate_kernel(&init_mm, dst_pmd, new_pte);
+
+	if (remove_pte) {
+		__free_page(pmd_page(*dst_pmd));
+		pmd_clear(dst_pmd);
+	}
+
+	spin_unlock(&init_mm.page_table_lock);
+
+	return 0;
+}
+
+static int sync_direct_mapping_pmd(unsigned long keyid,
+		pud_t *dst_pud, pud_t *src_pud,
+		unsigned long addr, unsigned long end)
+{
+	pmd_t *src_pmd, *dst_pmd;
+	pmd_t *new_pmd = NULL;
+	bool remove_pmd = false;
+	unsigned long next;
+	int ret;
+
+	/*
+	 * We want to unmap and free the page table if the source is empty and
+	 * the range covers whole page table.
+	 */
+	remove_pmd = !src_pud && IS_ALIGNED(addr, PUD_SIZE) && IS_ALIGNED(end, PUD_SIZE);
+
+	/*
+	 * PUD page got split into page table.
+	 * Clear PUD mapping. Page table will be established instead.
+	 */
+	if (pud_large(*dst_pud)) {
+		spin_lock(&init_mm.page_table_lock);
+		pud_clear(dst_pud);
+		spin_unlock(&init_mm.page_table_lock);
+	}
+
+	/* Allocate a new page table if needed. */
+	if (pud_none(*dst_pud)) {
+		new_pmd = (void *)__get_free_page(GFP_KERNEL | __GFP_ZERO);
+		if (!new_pmd)
+			return -ENOMEM;
+		dst_pmd = new_pmd + pmd_index(addr + keyid * direct_mapping_size);
+	} else {
+		dst_pmd = pmd_offset(dst_pud, addr + keyid * direct_mapping_size);
+	}
+	src_pmd = src_pud ? pmd_offset(src_pud, addr) : NULL;
+
+	do {
+		pmd_t *__src_pmd = src_pmd;
+
+		next = pmd_addr_end(addr, end);
+		if (!__src_pmd || pmd_none(*__src_pmd)) {
+			if (pmd_none(*dst_pmd))
+				goto next;
+			if (pmd_large(*dst_pmd)) {
+				spin_lock(&init_mm.page_table_lock);
+				set_pmd(dst_pmd, __pmd(0));
+				spin_unlock(&init_mm.page_table_lock);
+				goto next;
+			}
+			__src_pmd = NULL;
+		}
+
+		if (__src_pmd && pmd_large(*__src_pmd)) {
+			pmdval_t val;
+
+			if (pmd_large(*dst_pmd)) {
+				/*
+				 * Sanity check: PFNs must match between source
+				 * and destination even if the rest doesn't.
+				 */
+				BUG_ON(pmd_pfn(*dst_pmd) != pmd_pfn(*__src_pmd));
+			} else if (!pmd_none(*dst_pmd)) {
+				/*
+				 * Page table is replaced with a PMD page.
+				 * Free and unmap the page table.
+				 */
+				__free_page(pmd_page(*dst_pmd));
+				spin_lock(&init_mm.page_table_lock);
+				pmd_clear(dst_pmd);
+				spin_unlock(&init_mm.page_table_lock);
+			}
+
+			/* Copy entry, but set KeyID. */
+			val = pmd_val(*__src_pmd) | keyid << mktme_keyid_shift;
+			spin_lock(&init_mm.page_table_lock);
+			set_pmd(dst_pmd, __pmd(val));
+			spin_unlock(&init_mm.page_table_lock);
+			goto next;
+		}
+
+		ret = sync_direct_mapping_pte(keyid, dst_pmd, __src_pmd,
+				addr, next);
+next:
+		addr = next;
+		dst_pmd++;
+		if (src_pmd)
+			src_pmd++;
+	} while (addr != end && !ret);
+
+	if (new_pmd) {
+		spin_lock(&init_mm.page_table_lock);
+		pud_populate(&init_mm, dst_pud, new_pmd);
+		spin_unlock(&init_mm.page_table_lock);
+	}
+
+	if (remove_pmd) {
+		spin_lock(&init_mm.page_table_lock);
+		__free_page(pud_page(*dst_pud));
+		pud_clear(dst_pud);
+		spin_unlock(&init_mm.page_table_lock);
+	}
+
+	return ret;
+}
+
+static int sync_direct_mapping_pud(unsigned long keyid,
+		p4d_t *dst_p4d, p4d_t *src_p4d,
+		unsigned long addr, unsigned long end)
+{
+	pud_t *src_pud, *dst_pud;
+	pud_t *new_pud = NULL;
+	bool remove_pud = false;
+	unsigned long next;
+	int ret;
+
+	/*
+	 * We want to unmap and free the page table if the source is empty and
+	 * the range covers whole page table.
+	 */
+	remove_pud = !src_p4d && IS_ALIGNED(addr, P4D_SIZE) && IS_ALIGNED(end, P4D_SIZE);
+
+	/*
+	 * P4D page got split into page table.
+	 * Clear P4D mapping. Page table will be established instead.
+	 */
+	if (p4d_large(*dst_p4d)) {
+		spin_lock(&init_mm.page_table_lock);
+		p4d_clear(dst_p4d);
+		spin_unlock(&init_mm.page_table_lock);
+	}
+
+	/* Allocate a new page table if needed. */
+	if (p4d_none(*dst_p4d)) {
+		new_pud = (void *)__get_free_page(GFP_KERNEL | __GFP_ZERO);
+		if (!new_pud)
+			return -ENOMEM;
+		dst_pud = new_pud + pud_index(addr + keyid * direct_mapping_size);
+	} else {
+		dst_pud = pud_offset(dst_p4d, addr + keyid * direct_mapping_size);
+	}
+	src_pud = src_p4d ? pud_offset(src_p4d, addr) : NULL;
+
+	do {
+		pud_t *__src_pud = src_pud;
+
+		next = pud_addr_end(addr, end);
+		if (!__src_pud || pud_none(*__src_pud)) {
+			if (pud_none(*dst_pud))
+				goto next;
+			if (pud_large(*dst_pud)) {
+				spin_lock(&init_mm.page_table_lock);
+				set_pud(dst_pud, __pud(0));
+				spin_unlock(&init_mm.page_table_lock);
+				goto next;
+			}
+			__src_pud = NULL;
+		}
+
+		if (__src_pud && pud_large(*__src_pud)) {
+			pudval_t val;
+
+			if (pud_large(*dst_pud)) {
+				/*
+				 * Sanity check: PFNs must match between source
+				 * and destination even if the rest doesn't.
+				 */
+				BUG_ON(pud_pfn(*dst_pud) != pud_pfn(*__src_pud));
+			} else if (!pud_none(*dst_pud)) {
+				/*
+				 * Page table is replaced with a pud page.
+				 * Free and unmap the page table.
+				 */
+				__free_page(pud_page(*dst_pud));
+				spin_lock(&init_mm.page_table_lock);
+				pud_clear(dst_pud);
+				spin_unlock(&init_mm.page_table_lock);
+			}
+
+			/* Copy entry, but set KeyID. */
+			val = pud_val(*__src_pud) | keyid << mktme_keyid_shift;
+			spin_lock(&init_mm.page_table_lock);
+			set_pud(dst_pud, __pud(val));
+			spin_unlock(&init_mm.page_table_lock);
+			goto next;
+		}
+
+		ret = sync_direct_mapping_pmd(keyid, dst_pud, __src_pud,
+				addr, next);
+next:
+		addr = next;
+		dst_pud++;
+		if (src_pud)
+			src_pud++;
+	} while (addr != end && !ret);
+
+	if (new_pud) {
+		spin_lock(&init_mm.page_table_lock);
+		p4d_populate(&init_mm, dst_p4d, new_pud);
+		spin_unlock(&init_mm.page_table_lock);
+	}
+
+	if (remove_pud) {
+		spin_lock(&init_mm.page_table_lock);
+		__free_page(p4d_page(*dst_p4d));
+		p4d_clear(dst_p4d);
+		spin_unlock(&init_mm.page_table_lock);
+	}
+
+	return ret;
+}
+
+static int sync_direct_mapping_p4d(unsigned long keyid,
+		pgd_t *dst_pgd, pgd_t *src_pgd,
+		unsigned long addr, unsigned long end)
+{
+	p4d_t *src_p4d, *dst_p4d;
+	p4d_t *new_p4d_1 = NULL, *new_p4d_2 = NULL;
+	bool remove_p4d = false;
+	unsigned long next;
+	int ret;
+
+	/*
+	 * We want to unmap and free the page table if the source is empty and
+	 * the range covers whole page table.
+	 */
+	remove_p4d = !src_pgd && IS_ALIGNED(addr, PGDIR_SIZE) && IS_ALIGNED(end, PGDIR_SIZE);
+
+	/* Allocate a new page table if needed. */
+	if (pgd_none(*dst_pgd)) {
+		new_p4d_1 = (void *)__get_free_page(GFP_KERNEL | __GFP_ZERO);
+		if (!new_p4d_1)
+			return -ENOMEM;
+		dst_p4d = new_p4d_1 + p4d_index(addr + keyid * direct_mapping_size);
+	} else {
+		dst_p4d = p4d_offset(dst_pgd, addr + keyid * direct_mapping_size);
+	}
+	src_p4d = src_pgd ? p4d_offset(src_pgd, addr) : NULL;
+
+	do {
+		p4d_t *__src_p4d = src_p4d;
+
+		next = p4d_addr_end(addr, end);
+		if (!__src_p4d || p4d_none(*__src_p4d)) {
+			if (p4d_none(*dst_p4d))
+				goto next;
+			__src_p4d = NULL;
+		}
+
+		ret = sync_direct_mapping_pud(keyid, dst_p4d, __src_p4d,
+				addr, next);
+next:
+		addr = next;
+		dst_p4d++;
+
+		/*
+		 * Direct mappings are 1TiB-aligned. With 5-level paging it
+		 * means that on PGD level there can be misalignment between
+		 * source and distiantion.
+		 *
+		 * Allocate the new page table if dst_p4d crosses page table
+		 * boundary.
+		 */
+		if (!((unsigned long)dst_p4d & ~PAGE_MASK) && addr != end) {
+			if (pgd_none(dst_pgd[1])) {
+				new_p4d_2 = (void *)__get_free_page(GFP_KERNEL | __GFP_ZERO);
+				if (!new_p4d_2)
+					ret = -ENOMEM;
+				dst_p4d = new_p4d_2;
+			} else {
+				dst_p4d = p4d_offset(dst_pgd + 1, 0);
+			}
+		}
+		if (src_p4d)
+			src_p4d++;
+	} while (addr != end && !ret);
+
+	if (new_p4d_1 || new_p4d_2) {
+		spin_lock(&init_mm.page_table_lock);
+		if (new_p4d_1)
+			pgd_populate(&init_mm, dst_pgd, new_p4d_1);
+		if (new_p4d_2)
+			pgd_populate(&init_mm, dst_pgd + 1, new_p4d_2);
+		spin_unlock(&init_mm.page_table_lock);
+	}
+
+	if (remove_p4d) {
+		spin_lock(&init_mm.page_table_lock);
+		__free_page(pgd_page(*dst_pgd));
+		pgd_clear(dst_pgd);
+		spin_unlock(&init_mm.page_table_lock);
+	}
+
+	return ret;
+}
+
+static int sync_direct_mapping_keyid(unsigned long keyid)
+{
+	pgd_t *src_pgd, *dst_pgd;
+	unsigned long addr, end, next;
+	int ret;
+
+	addr = PAGE_OFFSET;
+	end = PAGE_OFFSET + direct_mapping_size;
+
+	dst_pgd = pgd_offset_k(addr + keyid * direct_mapping_size);
+	src_pgd = pgd_offset_k(addr);
+
+	do {
+		pgd_t *__src_pgd = src_pgd;
+
+		next = pgd_addr_end(addr, end);
+		if (pgd_none(*__src_pgd)) {
+			if (pgd_none(*dst_pgd))
+				continue;
+			__src_pgd = NULL;
+		}
+
+		ret = sync_direct_mapping_p4d(keyid, dst_pgd, __src_pgd,
+				addr, next);
+	} while (dst_pgd++, src_pgd++, addr = next, addr != end && !ret);
+
+	return ret;
+}
+
+/*
+ * For MKTME we maintain per-KeyID direct mappings. This allows kernel to have
+ * access to encrypted memory.
+ *
+ * sync_direct_mapping() sync per-KeyID direct mappings with a canonical
+ * one -- KeyID-0.
+ *
+ * The function tracks changes in the canonical mapping:
+ *  - creating or removing chunks of the translation tree;
+ *  - changes in mapping flags (i.e. protection bits);
+ *  - splitting huge page mapping into a page table;
+ *  - replacing page table with a huge page mapping;
+ *
+ * The function need to be called on every change to the direct mapping:
+ * hotplug, hotremove, changes in permissions bits, etc.
+ *
+ * The function is nop until MKTME is enabled.
+ */
+int sync_direct_mapping(void)
+{
+	int i, ret = 0;
+
+	if (mktme_status != MKTME_ENABLED)
+		return 0;
+
+	for (i = 1; !ret && i <= mktme_nr_keyids; i++)
+		ret = sync_direct_mapping_keyid(i);
+
+	__flush_tlb_all();
+
+	return ret;
+}
+
 void __init setup_direct_mapping_size(void)
 {
 	unsigned long available_va;
@@ -134,6 +570,14 @@ static int __init mktme_init(void)
 	if (direct_mapping_size == -1UL)
 		setup_direct_mapping_size();
 
+	if (mktme_status == MKTME_ENUMERATED)
+		mktme_status = MKTME_ENABLED;
+
+	if (sync_direct_mapping()) {
+		pr_err("x86/mktme: sync_direct_mapping() failed. Disable MKTME\n");
+		mktme_disable();
+	}
+
 	return 0;
 }
 arch_initcall(mktme_init)
-- 
2.17.1
