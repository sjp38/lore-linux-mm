Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 72FFC6B03C1
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 20:06:25 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id i19so26501255qte.5
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 17:06:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v36si1918261qtb.161.2017.08.16.17.06.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 17:06:24 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM-v25 17/19] mm/migrate: allow migrate_vma() to alloc new page on empty entry v4
Date: Wed, 16 Aug 2017 20:05:46 -0400
Message-Id: <20170817000548.32038-18-jglisse@redhat.com>
In-Reply-To: <20170817000548.32038-1-jglisse@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

This allow caller of migrate_vma() to allocate new page for empty CPU
page table entry (pte_none or back by zero page). This is only for
anonymous memory and it won't allow new page to be instanced if the
userfaultfd is armed.

This is useful to device driver that want to migrate a range of virtual
address and would rather allocate new memory than having to fault later
on.

Changed since v3:
  - support zero pfn entry
  - improve commit message
Changed sinve v2:
  - differentiate between empty CPU page table entry and non empty
  - improve code comments explaining how this works
Changed since v1:
  - 5 level page table fix

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/migrate.h |   9 +++
 mm/migrate.c            | 205 +++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 205 insertions(+), 9 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 8dc8f0a3f1af..d4e6d12a0b40 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -218,6 +218,15 @@ static inline unsigned long migrate_pfn(unsigned long pfn)
  * driver should avoid setting MIGRATE_PFN_ERROR unless it is really in an
  * unrecoverable state.
  *
+ * For empty entry inside CPU page table (pte_none() or pmd_none() is true) we
+ * do set MIGRATE_PFN_MIGRATE flag inside the corresponding source array thus
+ * allowing device driver to allocate device memory for those unback virtual
+ * address. For this the device driver simply have to allocate device memory
+ * and properly set the destination entry like for regular migration. Note that
+ * this can still fails and thus inside the device driver must check if the
+ * migration was successful for those entry inside the finalize_and_map()
+ * callback just like for regular migration.
+ *
  * THE alloc_and_copy() CALLBACK MUST NOT CHANGE ANY OF THE SRC ARRAY ENTRIES
  * OR BAD THINGS WILL HAPPEN !
  *
diff --git a/mm/migrate.c b/mm/migrate.c
index 6c8a9826da32..5500e3738354 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -37,6 +37,7 @@
 #include <linux/hugetlb_cgroup.h>
 #include <linux/gfp.h>
 #include <linux/memremap.h>
+#include <linux/userfaultfd_k.h>
 #include <linux/balloon_compaction.h>
 #include <linux/mmu_notifier.h>
 #include <linux/page_idle.h>
@@ -2152,6 +2153,22 @@ static int migrate_vma_collect_hole(unsigned long start,
 	unsigned long addr;
 
 	for (addr = start & PAGE_MASK; addr < end; addr += PAGE_SIZE) {
+		migrate->src[migrate->npages++] = MIGRATE_PFN_MIGRATE;
+		migrate->dst[migrate->npages] = 0;
+		migrate->cpages++;
+	}
+
+	return 0;
+}
+
+static int migrate_vma_collect_skip(unsigned long start,
+				    unsigned long end,
+				    struct mm_walk *walk)
+{
+	struct migrate_vma *migrate = walk->private;
+	unsigned long addr;
+
+	for (addr = start & PAGE_MASK; addr < end; addr += PAGE_SIZE) {
 		migrate->dst[migrate->npages] = 0;
 		migrate->src[migrate->npages++] = 0;
 	}
@@ -2189,7 +2206,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 			spin_unlock(ptl);
 			split_huge_pmd(vma, pmdp, addr);
 			if (pmd_trans_unstable(pmdp))
-				return migrate_vma_collect_hole(start, end,
+				return migrate_vma_collect_skip(start, end,
 								walk);
 		} else {
 			int ret;
@@ -2197,19 +2214,22 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 			get_page(page);
 			spin_unlock(ptl);
 			if (unlikely(!trylock_page(page)))
-				return migrate_vma_collect_hole(start, end,
+				return migrate_vma_collect_skip(start, end,
 								walk);
 			ret = split_huge_page(page);
 			unlock_page(page);
 			put_page(page);
-			if (ret || pmd_none(*pmdp))
+			if (ret)
+				return migrate_vma_collect_skip(start, end,
+								walk);
+			if (pmd_none(*pmdp))
 				return migrate_vma_collect_hole(start, end,
 								walk);
 		}
 	}
 
 	if (unlikely(pmd_bad(*pmdp)))
-		return migrate_vma_collect_hole(start, end, walk);
+		return migrate_vma_collect_skip(start, end, walk);
 
 	ptep = pte_offset_map_lock(mm, pmdp, addr, &ptl);
 	arch_enter_lazy_mmu_mode();
@@ -2224,7 +2244,9 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 		pfn = pte_pfn(pte);
 
 		if (pte_none(pte)) {
-			mpfn = pfn = 0;
+			mpfn = MIGRATE_PFN_MIGRATE;
+			migrate->cpages++;
+			pfn = 0;
 			goto next;
 		}
 
@@ -2246,6 +2268,12 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 			if (is_write_device_private_entry(entry))
 				mpfn |= MIGRATE_PFN_WRITE;
 		} else {
+			if (is_zero_pfn(pfn)) {
+				mpfn = MIGRATE_PFN_MIGRATE;
+				migrate->cpages++;
+				pfn = 0;
+				goto next;
+			}
 			page = vm_normal_page(migrate->vma, addr, pte);
 			mpfn = migrate_pfn(pfn) | MIGRATE_PFN_MIGRATE;
 			mpfn |= pte_write(pte) ? MIGRATE_PFN_WRITE : 0;
@@ -2565,6 +2593,135 @@ static void migrate_vma_unmap(struct migrate_vma *migrate)
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
+	bool flush = false;
+	spinlock_t *ptl;
+	pte_t entry;
+	pgd_t *pgdp;
+	p4d_t *p4dp;
+	pud_t *pudp;
+	pmd_t *pmdp;
+	pte_t *ptep;
+
+	/* Only allow populating anonymous memory */
+	if (!vma_is_anonymous(vma))
+		goto abort;
+
+	pgdp = pgd_offset(mm, addr);
+	p4dp = p4d_alloc(mm, pgdp, addr);
+	if (!p4dp)
+		goto abort;
+	pudp = pud_alloc(mm, p4dp, addr);
+	if (!pudp)
+		goto abort;
+	pmdp = pmd_alloc(mm, pudp, addr);
+	if (!pmdp)
+		goto abort;
+
+	if (pmd_trans_huge(*pmdp) || pmd_devmap(*pmdp))
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
+	 * preceding stores to the page contents become visible before
+	 * the set_pte_at() write.
+	 */
+	__SetPageUptodate(page);
+
+	if (is_zone_device_page(page) && is_device_private_page(page)) {
+		swp_entry_t swp_entry;
+
+		swp_entry = make_device_private_entry(page, vma->vm_flags & VM_WRITE);
+		entry = swp_entry_to_pte(swp_entry);
+	} else {
+		entry = mk_pte(page, vma->vm_page_prot);
+		if (vma->vm_flags & VM_WRITE)
+			entry = pte_mkwrite(pte_mkdirty(entry));
+	}
+
+	ptep = pte_offset_map_lock(mm, pmdp, addr, &ptl);
+
+	if (pte_present(*ptep)) {
+		unsigned long pfn = pte_pfn(*ptep);
+
+		if (!is_zero_pfn(pfn)) {
+			pte_unmap_unlock(ptep, ptl);
+			mem_cgroup_cancel_charge(page, memcg, false);
+			goto abort;
+		}
+		flush = true;
+	} else if (!pte_none(*ptep)) {
+		pte_unmap_unlock(ptep, ptl);
+		mem_cgroup_cancel_charge(page, memcg, false);
+		goto abort;
+	}
+
+	/*
+	 * Check for usefaultfd but do not deliver the fault. Instead,
+	 * just back off.
+	 */
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
+	get_page(page);
+
+	if (flush) {
+		flush_cache_page(vma, addr, pte_pfn(*ptep));
+		ptep_clear_flush_notify(vma, addr, ptep);
+		set_pte_at_notify(mm, addr, ptep, entry);
+		update_mmu_cache(vma, addr, ptep);
+	} else {
+		/* No need to invalidate - it was non-present before */
+		set_pte_at(mm, addr, ptep, entry);
+		update_mmu_cache(vma, addr, ptep);
+	}
+
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
@@ -2577,7 +2734,10 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
 {
 	const unsigned long npages = migrate->npages;
 	const unsigned long start = migrate->start;
-	unsigned long addr, i;
+	struct vm_area_struct *vma = migrate->vma;
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned long addr, i, mmu_start;
+	bool notified = false;
 
 	for (i = 0, addr = start; i < npages; addr += PAGE_SIZE, i++) {
 		struct page *newpage = migrate_pfn_to_page(migrate->dst[i]);
@@ -2585,10 +2745,27 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
 		struct address_space *mapping;
 		int r;
 
-		if (!page || !newpage)
+		if (!newpage) {
+			migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
 			continue;
-		if (!(migrate->src[i] & MIGRATE_PFN_MIGRATE))
+		}
+
+		if (!page) {
+			if (!(migrate->src[i] & MIGRATE_PFN_MIGRATE)) {
+				continue;
+			}
+			if (!notified) {
+				mmu_start = addr;
+				notified = true;
+				mmu_notifier_invalidate_range_start(mm,
+								mmu_start,
+								migrate->end);
+			}
+			migrate_vma_insert_page(migrate, addr, newpage,
+						&migrate->src[i],
+						&migrate->dst[i]);
 			continue;
+		}
 
 		mapping = page_mapping(page);
 
@@ -2616,6 +2793,10 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
 		if (r != MIGRATEPAGE_SUCCESS)
 			migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
 	}
+
+	if (notified)
+		mmu_notifier_invalidate_range_end(mm, mmu_start,
+						  migrate->end);
 }
 
 /*
@@ -2638,8 +2819,14 @@ static void migrate_vma_finalize(struct migrate_vma *migrate)
 		struct page *newpage = migrate_pfn_to_page(migrate->dst[i]);
 		struct page *page = migrate_pfn_to_page(migrate->src[i]);
 
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
2.13.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
