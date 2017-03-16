Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id CB1786B0394
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:04:07 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id u4so22227299qtc.4
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 08:04:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g32si4099813qtg.89.2017.03.16.08.04.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 08:04:06 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 14/16] mm/migrate: allow migrate_vma() to alloc new page on empty entry
Date: Thu, 16 Mar 2017 12:05:33 -0400
Message-Id: <1489680335-6594-15-git-send-email-jglisse@redhat.com>
In-Reply-To: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

This allow caller of migrate_vma() to allocate new page for empty CPU
page table entry. It only support anoymous memory and it won't allow
new page to be instance if userfaultfd is armed.

This is usefull to device driver that want to migrate a range of virtual
address and would rather allocate new memory than having to fault later
on.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/migrate.h |   6 +-
 mm/migrate.c            | 156 +++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 138 insertions(+), 24 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index c43669b..01f4945 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -157,7 +157,11 @@ static inline unsigned long migrate_pfn_size(unsigned long mpfn)
  * allocator for destination memory.
  *
  * Note that in alloc_and_copy device driver can decide not to migrate some of
- * the entry by simply setting corresponding dst entry 0.
+ * the entry by simply setting corresponding dst entry 0. Driver can also try
+ * to allocate memory for empty source entry by setting valid dst entry. If
+ * CPU page table is not populated while alloc_and_copy() callback is taking
+ * place then CPU page table will be updated to point to the newly allocated
+ * memory.
  *
  * Destination page must locked and MIGRATE_PFN_LOCKED set in the corresponding
  * entry of dstarray. It is expected that page allocated will have an elevated
diff --git a/mm/migrate.c b/mm/migrate.c
index 9950245..b03158c 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -42,6 +42,7 @@
 #include <linux/page_owner.h>
 #include <linux/sched/mm.h>
 #include <linux/memremap.h>
+#include <linux/userfaultfd_k.h>
 
 #include <asm/tlbflush.h>
 
@@ -2103,29 +2104,17 @@ static int migrate_vma_collect_hole(unsigned long start,
 				    struct mm_walk *walk)
 {
 	struct migrate_vma *migrate = walk->private;
-	unsigned long addr, next;
+	unsigned long addr;
 
-	for (addr = start & PAGE_MASK; addr < end; addr = next) {
-		unsigned long npages, i;
+	for (addr = start & PAGE_MASK; addr < end; addr += PAGE_SIZE) {
 		int ret;
 
-		next = pmd_addr_end(addr, end);
-		npages = (next - addr) >> PAGE_SHIFT;
-		if (npages == (PMD_SIZE >> PAGE_SHIFT)) {
-			migrate->dst[migrate->npages] = 0;
-			migrate->src[migrate->npages++] = MIGRATE_PFN_HUGE;
-			ret = migrate_vma_array_full(migrate);
-			if (ret)
-				return ret;
-		} else {
-			for (i = 0; i < npages; ++i) {
-				migrate->dst[migrate->npages] = 0;
-				migrate->src[migrate->npages++] = 0;
-				ret = migrate_vma_array_full(migrate);
-				if (ret)
-					return ret;
-			}
-		}
+		migrate->cpages++;
+		migrate->dst[migrate->npages] = 0;
+		migrate->src[migrate->npages++] = 0;
+		ret = migrate_vma_array_full(migrate);
+		if (ret)
+			return ret;
 	}
 
 	return 0;
@@ -2162,6 +2151,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 		pfn = pte_pfn(pte);
 
 		if (pte_none(pte)) {
+			migrate->cpages++;
 			flags = pfn = 0;
 			goto next;
 		}
@@ -2480,6 +2470,114 @@ static void migrate_vma_unmap(struct migrate_vma *migrate)
 	}
 }
 
+static void migrate_vma_insert_page(struct migrate_vma *migrate,
+				    unsigned long addr,
+				    struct page *page,
+				    unsigned long *src,
+				    unsigned long *dst)
+{
+	struct vm_area_struct *vma = migrate->vma;
+	struct mm_struct *mm = vma->vm_mm;
+	struct mem_cgroup *memcg;
+	spinlock_t *ptl;
+	pgd_t *pgdp;
+	pud_t *pudp;
+	pmd_t *pmdp;
+	pte_t *ptep;
+	pte_t entry;
+
+	if ((*dst & MIGRATE_PFN_HUGE) || (*src & MIGRATE_PFN_HUGE))
+		goto abort;
+
+	/* Only allow to populate anonymous memory */
+	if (!vma_is_anonymous(vma))
+		goto abort;
+
+	pgdp = pgd_offset(mm, addr);
+	pudp = pud_alloc(mm, pgdp, addr);
+	if (!pudp)
+		goto abort;
+	pmdp = pmd_alloc(mm, pudp, addr);
+	if (!pmdp)
+		goto abort;
+
+	if (pmd_trans_unstable(pmdp) || pmd_devmap(*pmdp))
+		goto abort;
+
+	/*
+	 * Use pte_alloc() instead of pte_alloc_map().  We can't run
+	 * pte_offset_map() on pmds where a huge pmd might be created
+	 * from a different thread.
+	 *
+	 * pte_alloc_map() is safe to use under down_write(mmap_sem) or when
+	 * parallel threads are excluded by other means.
+	 *
+	 * Here we only have down_read(mmap_sem).
+	 */
+	if (pte_alloc(mm, pmdp, addr))
+		goto abort;
+
+	/* See the comment in pte_alloc_one_map() */
+	if (unlikely(pmd_trans_unstable(pmdp)))
+		goto abort;
+
+	if (unlikely(anon_vma_prepare(vma)))
+		goto abort;
+	if (mem_cgroup_try_charge(page, vma->vm_mm, GFP_KERNEL, &memcg, false))
+		goto abort;
+
+	/*
+	 * The memory barrier inside __SetPageUptodate makes sure that
+	 * preceeding stores to the page contents become visible before
+	 * the set_pte_at() write.
+	 */
+	__SetPageUptodate(page);
+
+	if (is_zone_device_page(page) && !is_addressable_page(page)) {
+		swp_entry_t swp_entry;
+
+		swp_entry = make_device_entry(page, vma->vm_flags & VM_WRITE);
+		entry = swp_entry_to_pte(swp_entry);
+	} else {
+		entry = mk_pte(page, vma->vm_page_prot);
+		if (vma->vm_flags & VM_WRITE)
+			entry = pte_mkwrite(pte_mkdirty(entry));
+	}
+
+	ptep = pte_offset_map_lock(mm, pmdp, addr, &ptl);
+	if (!pte_none(*ptep)) {
+		pte_unmap_unlock(ptep, ptl);
+		mem_cgroup_cancel_charge(page, memcg, false);
+		goto abort;
+	}
+
+	/* Check for usefaultfd but do not deliver fault just back of */
+	if (userfaultfd_missing(vma)) {
+		pte_unmap_unlock(ptep, ptl);
+		mem_cgroup_cancel_charge(page, memcg, false);
+		goto abort;
+	}
+
+	inc_mm_counter(mm, MM_ANONPAGES);
+	page_add_new_anon_rmap(page, vma, addr, false);
+	mem_cgroup_commit_charge(page, memcg, false, false);
+	if (!is_zone_device_page(page))
+		lru_cache_add_active_or_unevictable(page, vma);
+	set_pte_at(mm, addr, ptep, entry);
+
+	/* Take a reference on the page */
+	get_page(page);
+
+	/* No need to invalidate - it was non-present before */
+	update_mmu_cache(vma, addr, ptep);
+	pte_unmap_unlock(ptep, ptl);
+	*src = MIGRATE_PFN_MIGRATE;
+	return;
+
+abort:
+	*src &= ~MIGRATE_PFN_MIGRATE;
+}
+
 /*
  * migrate_vma_pages() - migrate meta-data from src page to dst page
  * @migrate: migrate struct containing all migration information
@@ -2501,10 +2599,16 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
 
 		size = migrate_pfn_size(migrate->src[i]);
 
-		if (!page || !newpage)
+		if (!newpage) {
+			migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
 			continue;
-		if (!(migrate->src[i] & MIGRATE_PFN_MIGRATE))
+		} else if (!(migrate->src[i] & MIGRATE_PFN_MIGRATE)) {
+			if (!page)
+				migrate_vma_insert_page(migrate, addr, newpage,
+							&migrate->src[i],
+							&migrate->dst[i]);
 			continue;
+		}
 
 		mapping = page_mapping(page);
 
@@ -2551,8 +2655,14 @@ static void migrate_vma_finalize(struct migrate_vma *migrate)
 		struct page *page = migrate_pfn_to_page(migrate->src[i]);
 		size = migrate_pfn_size(migrate->src[i]);
 
-		if (!page)
+		if (!page) {
+			if (newpage) {
+				unlock_page(newpage);
+				put_page(newpage);
+			}
 			continue;
+		}
+
 		if (!(migrate->src[i] & MIGRATE_PFN_MIGRATE) || !newpage) {
 			if (newpage) {
 				unlock_page(newpage);
-- 
2.4.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
