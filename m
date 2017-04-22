Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 12C3D6B03A7
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 23:30:52 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id p33so26522299qte.6
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 20:30:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k126si11566173qkc.96.2017.04.21.20.30.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 20:30:51 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 06/15] mm/migrate: migrate_vma() unmap page from vma while collecting pages
Date: Fri, 21 Apr 2017 23:30:28 -0400
Message-Id: <20170422033037.3028-7-jglisse@redhat.com>
In-Reply-To: <20170422033037.3028-1-jglisse@redhat.com>
References: <20170422033037.3028-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

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
 mm/migrate.c | 114 ++++++++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 98 insertions(+), 16 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 452f894..4ac2a7a 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2118,7 +2118,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 {
 	struct migrate_vma *migrate = walk->private;
 	struct mm_struct *mm = walk->vma->vm_mm;
-	unsigned long addr = start;
+	unsigned long addr = start, unmapped = 0;
 	spinlock_t *ptl;
 	pte_t *ptep;
 
@@ -2128,9 +2128,12 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 	}
 
 	ptep = pte_offset_map_lock(mm, pmdp, addr, &ptl);
+	arch_enter_lazy_mmu_mode();
+
 	for (; addr < end; addr += PAGE_SIZE, ptep++) {
 		unsigned long mpfn, pfn;
 		struct page *page;
+		swp_entry_t entry;
 		pte_t pte;
 
 		pte = *ptep;
@@ -2162,11 +2165,44 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
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
 
@@ -2191,7 +2227,13 @@ static void migrate_vma_collect(struct migrate_vma *migrate)
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
@@ -2247,12 +2289,16 @@ static void migrate_vma_prepare(struct migrate_vma *migrate)
 
 	for (i = 0; i < npages; i++) {
 		struct page *page = migrate_pfn_to_page(migrate->src[i]);
+		bool remap = true;
 
 		if (!page)
 			continue;
 
-		lock_page(page);
-		migrate->src[i] |= MIGRATE_PFN_LOCKED;
+		if (!(migrate->src[i] & MIGRATE_PFN_LOCKED)) {
+			remap = false;
+			lock_page(page);
+			migrate->src[i] |= MIGRATE_PFN_LOCKED;
+		}
 
 		if (!PageLRU(page) && allow_drain) {
 			/* Drain CPU's pagevec */
@@ -2261,21 +2307,50 @@ static void migrate_vma_prepare(struct migrate_vma *migrate)
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
@@ -2302,12 +2377,19 @@ static void migrate_vma_unmap(struct migrate_vma *migrate)
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
