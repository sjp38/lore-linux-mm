Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6D51C6B03B5
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 20:06:22 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o124so25135030qke.9
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 17:06:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y3si1818129qkc.225.2017.08.16.17.06.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 17:06:21 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM-v25 15/19] mm/migrate: migrate_vma() unmap page from vma while collecting pages
Date: Wed, 16 Aug 2017 20:05:44 -0400
Message-Id: <20170817000548.32038-16-jglisse@redhat.com>
In-Reply-To: <20170817000548.32038-1-jglisse@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

Common case for migration of virtual address range is page are map
only once inside the vma in which migration is taking place. Because
we already walk the CPU page table for that range we can directly do
the unmap there and setup special migration swap entry.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Evgeny Baskakov <ebaskakov@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
---
 mm/migrate.c | 141 +++++++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 112 insertions(+), 29 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 60e2f8369cd7..57d1fa7a8e62 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2160,7 +2160,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 	struct migrate_vma *migrate = walk->private;
 	struct vm_area_struct *vma = walk->vma;
 	struct mm_struct *mm = vma->vm_mm;
-	unsigned long addr = start;
+	unsigned long addr = start, unmapped = 0;
 	spinlock_t *ptl;
 	pte_t *ptep;
 
@@ -2205,9 +2205,12 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 		return migrate_vma_collect_hole(start, end, walk);
 
 	ptep = pte_offset_map_lock(mm, pmdp, addr, &ptl);
+	arch_enter_lazy_mmu_mode();
+
 	for (; addr < end; addr += PAGE_SIZE, ptep++) {
 		unsigned long mpfn, pfn;
 		struct page *page;
+		swp_entry_t entry;
 		pte_t pte;
 
 		pte = *ptep;
@@ -2239,11 +2242,44 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 		mpfn = migrate_pfn(pfn) | MIGRATE_PFN_MIGRATE;
 		mpfn |= pte_write(pte) ? MIGRATE_PFN_WRITE : 0;
 
+		/*
+		 * Optimize for the common case where page is only mapped once
+		 * in one process. If we can lock the page, then we can safely
+		 * set up a special migration page table entry now.
+		 */
+		if (trylock_page(page)) {
+			pte_t swp_pte;
+
+			mpfn |= MIGRATE_PFN_LOCKED;
+			ptep_get_and_clear(mm, addr, ptep);
+
+			/* Setup special migration page table entry */
+			entry = make_migration_entry(page, pte_write(pte));
+			swp_pte = swp_entry_to_pte(entry);
+			if (pte_soft_dirty(pte))
+				swp_pte = pte_swp_mksoft_dirty(swp_pte);
+			set_pte_at(mm, addr, ptep, swp_pte);
+
+			/*
+			 * This is like regular unmap: we remove the rmap and
+			 * drop page refcount. Page won't be freed, as we took
+			 * a reference just above.
+			 */
+			page_remove_rmap(page, false);
+			put_page(page);
+			unmapped++;
+		}
+
 next:
 		migrate->src[migrate->npages++] = mpfn;
 	}
+	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(ptep - 1, ptl);
 
+	/* Only flush the TLB if we actually modified any entries */
+	if (unmapped)
+		flush_tlb_range(walk->vma, start, end);
+
 	return 0;
 }
 
@@ -2268,7 +2304,13 @@ static void migrate_vma_collect(struct migrate_vma *migrate)
 	mm_walk.mm = migrate->vma->vm_mm;
 	mm_walk.private = migrate;
 
+	mmu_notifier_invalidate_range_start(mm_walk.mm,
+					    migrate->start,
+					    migrate->end);
 	walk_page_range(migrate->start, migrate->end, &mm_walk);
+	mmu_notifier_invalidate_range_end(mm_walk.mm,
+					  migrate->start,
+					  migrate->end);
 
 	migrate->end = migrate->start + (migrate->npages << PAGE_SHIFT);
 }
@@ -2316,32 +2358,37 @@ static bool migrate_vma_check_page(struct page *page)
 static void migrate_vma_prepare(struct migrate_vma *migrate)
 {
 	const unsigned long npages = migrate->npages;
+	const unsigned long start = migrate->start;
+	unsigned long addr, i, restore = 0;
 	bool allow_drain = true;
-	unsigned long i;
 
 	lru_add_drain();
 
 	for (i = 0; (i < npages) && migrate->cpages; i++) {
 		struct page *page = migrate_pfn_to_page(migrate->src[i]);
+		bool remap = true;
 
 		if (!page)
 			continue;
 
-		/*
-		 * Because we are migrating several pages there can be
-		 * a deadlock between 2 concurrent migration where each
-		 * are waiting on each other page lock.
-		 *
-		 * Make migrate_vma() a best effort thing and backoff
-		 * for any page we can not lock right away.
-		 */
-		if (!trylock_page(page)) {
-			migrate->src[i] = 0;
-			migrate->cpages--;
-			put_page(page);
-			continue;
+		if (!(migrate->src[i] & MIGRATE_PFN_LOCKED)) {
+			/*
+			 * Because we are migrating several pages there can be
+			 * a deadlock between 2 concurrent migration where each
+			 * are waiting on each other page lock.
+			 *
+			 * Make migrate_vma() a best effort thing and backoff
+			 * for any page we can not lock right away.
+			 */
+			if (!trylock_page(page)) {
+				migrate->src[i] = 0;
+				migrate->cpages--;
+				put_page(page);
+				continue;
+			}
+			remap = false;
+			migrate->src[i] |= MIGRATE_PFN_LOCKED;
 		}
-		migrate->src[i] |= MIGRATE_PFN_LOCKED;
 
 		if (!PageLRU(page) && allow_drain) {
 			/* Drain CPU's pagevec */
@@ -2350,21 +2397,50 @@ static void migrate_vma_prepare(struct migrate_vma *migrate)
 		}
 
 		if (isolate_lru_page(page)) {
-			migrate->src[i] = 0;
-			unlock_page(page);
-			migrate->cpages--;
-			put_page(page);
+			if (remap) {
+				migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
+				migrate->cpages--;
+				restore++;
+			} else {
+				migrate->src[i] = 0;
+				unlock_page(page);
+				migrate->cpages--;
+				put_page(page);
+			}
 			continue;
 		}
 
 		if (!migrate_vma_check_page(page)) {
-			migrate->src[i] = 0;
-			unlock_page(page);
-			migrate->cpages--;
+			if (remap) {
+				migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
+				migrate->cpages--;
+				restore++;
 
-			putback_lru_page(page);
+				get_page(page);
+				putback_lru_page(page);
+			} else {
+				migrate->src[i] = 0;
+				unlock_page(page);
+				migrate->cpages--;
+
+				putback_lru_page(page);
+			}
 		}
 	}
+
+	for (i = 0, addr = start; i < npages && restore; i++, addr += PAGE_SIZE) {
+		struct page *page = migrate_pfn_to_page(migrate->src[i]);
+
+		if (!page || (migrate->src[i] & MIGRATE_PFN_MIGRATE))
+			continue;
+
+		remove_migration_pte(page, migrate->vma, addr, page);
+
+		migrate->src[i] = 0;
+		unlock_page(page);
+		put_page(page);
+		restore--;
+	}
 }
 
 /*
@@ -2391,12 +2467,19 @@ static void migrate_vma_unmap(struct migrate_vma *migrate)
 		if (!page || !(migrate->src[i] & MIGRATE_PFN_MIGRATE))
 			continue;
 
-		try_to_unmap(page, flags);
-		if (page_mapped(page) || !migrate_vma_check_page(page)) {
-			migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
-			migrate->cpages--;
-			restore++;
+		if (page_mapped(page)) {
+			try_to_unmap(page, flags);
+			if (page_mapped(page))
+				goto restore;
 		}
+
+		if (migrate_vma_check_page(page))
+			continue;
+
+restore:
+		migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
+		migrate->cpages--;
+		restore++;
 	}
 
 	for (addr = start, i = 0; i < npages && restore; addr += PAGE_SIZE, i++) {
-- 
2.13.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
