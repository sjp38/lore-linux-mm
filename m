Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8A5926B030A
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 08:29:04 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 14-v6so545386pfk.22
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 05:29:04 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 89-v6si11401786plc.383.2018.10.26.05.29.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Oct 2018 05:29:02 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 2/3] x86/ldt: Unmap PTEs for the slot before freeing LDT pages
Date: Fri, 26 Oct 2018 15:28:55 +0300
Message-Id: <20181026122856.66224-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20181026122856.66224-1-kirill.shutemov@linux.intel.com>
References: <20181026122856.66224-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org
Cc: boris.ostrovsky@oracle.com, jgross@suse.com, bhe@redhat.com, willy@infradead.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

modify_ldt(2) leaves old LDT mapped after we switch over to the new one.
Memory for the old LDT gets freed and the pages can be re-used.

Leaving the mapping in place can have security implications. The mapping
is present in userspace copy of page tables and Meltdown-like attack can
read these freed and possibly reused pages.

It's relatively simple to fix: just unmap the old LDT and flush TLB
before freeing LDT memory.

We can now avoid flushing TLB on map_ldt_struct() as the slot is
unmapped and flushed by unmap_ldt_struct() (or never mapped in
the first place). The overhead of the change should be negligible.
It shouldn't be a particularly hot path anyway.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Fixes: f55f0501cbf6 ("x86/pti: Put the LDT in its own PGD if PTI is on")
---
 arch/x86/kernel/ldt.c | 51 ++++++++++++++++++++++++++++++++-----------
 1 file changed, 38 insertions(+), 13 deletions(-)

diff --git a/arch/x86/kernel/ldt.c b/arch/x86/kernel/ldt.c
index ab18e0884dc6..e32f3427438a 100644
--- a/arch/x86/kernel/ldt.c
+++ b/arch/x86/kernel/ldt.c
@@ -199,14 +199,6 @@ static void sanity_check_ldt_mapping(struct mm_struct *mm)
 /*
  * If PTI is enabled, this maps the LDT into the kernelmode and
  * usermode tables for the given mm.
- *
- * There is no corresponding unmap function.  Even if the LDT is freed, we
- * leave the PTEs around until the slot is reused or the mm is destroyed.
- * This is harmless: the LDT is always in ordinary memory, and no one will
- * access the freed slot.
- *
- * If we wanted to unmap freed LDTs, we'd also need to do a flush to make
- * it useful, and the flush would slow down modify_ldt().
  */
 static int
 map_ldt_struct(struct mm_struct *mm, struct ldt_struct *ldt, int slot)
@@ -215,7 +207,7 @@ map_ldt_struct(struct mm_struct *mm, struct ldt_struct *ldt, int slot)
 	bool is_vmalloc;
 	spinlock_t *ptl;
 	pgd_t *pgd;
-	int i;
+	int i, nr_pages;
 
 	if (!static_cpu_has(X86_FEATURE_PTI))
 		return 0;
@@ -238,7 +230,8 @@ map_ldt_struct(struct mm_struct *mm, struct ldt_struct *ldt, int slot)
 
 	is_vmalloc = is_vmalloc_addr(ldt->entries);
 
-	for (i = 0; i * PAGE_SIZE < ldt->nr_entries * LDT_ENTRY_SIZE; i++) {
+	nr_pages = DIV_ROUND_UP(ldt->nr_entries * LDT_ENTRY_SIZE, PAGE_SIZE);
+	for (i = 0; i < nr_pages; i++) {
 		unsigned long offset = i << PAGE_SHIFT;
 		const void *src = (char *)ldt->entries + offset;
 		unsigned long pfn;
@@ -272,13 +265,39 @@ map_ldt_struct(struct mm_struct *mm, struct ldt_struct *ldt, int slot)
 	/* Propagate LDT mapping to the user page-table */
 	map_ldt_struct_to_user(mm);
 
-	va = (unsigned long)ldt_slot_va(slot);
-	flush_tlb_mm_range(mm, va, va + LDT_SLOT_STRIDE, PAGE_SHIFT, false);
-
 	ldt->slot = slot;
 	return 0;
 }
 
+static void
+unmap_ldt_struct(struct mm_struct *mm, struct ldt_struct *ldt)
+{
+	unsigned long va;
+	int i, nr_pages;
+
+	if (!ldt)
+		return;
+
+	/* LDT map/unmap is only required for PTI */
+	if (!static_cpu_has(X86_FEATURE_PTI))
+		return;
+
+	nr_pages = DIV_ROUND_UP(ldt->nr_entries * LDT_ENTRY_SIZE, PAGE_SIZE);
+	for (i = 0; i < nr_pages; i++) {
+		unsigned long offset = i << PAGE_SHIFT;
+		pte_t *ptep;
+		spinlock_t *ptl;
+
+		va = (unsigned long)ldt_slot_va(ldt->slot) + offset;
+		ptep = get_locked_pte(mm, va, &ptl);
+		pte_clear(mm, va, ptep);
+		pte_unmap_unlock(ptep, ptl);
+	}
+
+	va = (unsigned long)ldt_slot_va(ldt->slot);
+	flush_tlb_mm_range(mm, va, va + nr_pages * PAGE_SIZE, 0, false);
+}
+
 #else /* !CONFIG_PAGE_TABLE_ISOLATION */
 
 static int
@@ -286,6 +305,11 @@ map_ldt_struct(struct mm_struct *mm, struct ldt_struct *ldt, int slot)
 {
 	return 0;
 }
+
+static void
+unmap_ldt_struct(struct mm_struct *mm, struct ldt_struct *ldt)
+{
+}
 #endif /* CONFIG_PAGE_TABLE_ISOLATION */
 
 static void free_ldt_pgtables(struct mm_struct *mm)
@@ -524,6 +548,7 @@ static int write_ldt(void __user *ptr, unsigned long bytecount, int oldmode)
 	}
 
 	install_ldt(mm, new_ldt);
+	unmap_ldt_struct(mm, old_ldt);
 	free_ldt_struct(old_ldt);
 	error = 0;
 
-- 
2.19.1
