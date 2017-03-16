Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 34792831CC
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:04:15 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id j127so42160036qke.2
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 08:04:15 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l4si4101565qkb.60.2017.03.16.08.03.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 08:04:00 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 08/16] mm/migrate: migrate_vma() unmap page from vma while collecting pages
Date: Thu, 16 Mar 2017 12:05:27 -0400
Message-Id: <1489680335-6594-9-git-send-email-jglisse@redhat.com>
In-Reply-To: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

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
 mm/migrate.c | 111 ++++++++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 95 insertions(+), 16 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index e37d796..5a14b4ec 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2125,9 +2125,10 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 {
 	struct migrate_vma *migrate = walk->private;
 	struct mm_struct *mm = walk->vma->vm_mm;
-	unsigned long addr = start;
+	unsigned long addr = start, unmapped = 0;
 	spinlock_t *ptl;
 	pte_t *ptep;
+	int ret = 0;
 
 	if (pmd_none(*pmdp) || pmd_trans_unstable(pmdp)) {
 		/* FIXME support THP */
@@ -2135,9 +2136,12 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 	}
 
 	ptep = pte_offset_map_lock(mm, pmdp, addr, &ptl);
+	arch_enter_lazy_mmu_mode();
+
 	for (; addr < end; addr += PAGE_SIZE, ptep++) {
 		unsigned long flags, pfn;
 		struct page *page;
+		swp_entry_t entry;
 		pte_t pte;
 		int ret;
 
@@ -2170,17 +2174,50 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 		flags = MIGRATE_PFN_VALID | MIGRATE_PFN_MIGRATE;
 		flags |= pte_write(pte) ? MIGRATE_PFN_WRITE : 0;
 
+		/*
+		 * Optimize for the common case where page is only mapped once
+		 * in one process. If we can lock the page, then we can safely
+		 * set up a special migration page table entry now.
+		 */
+		if (trylock_page(page)) {
+			pte_t swp_pte;
+
+			flags |= MIGRATE_PFN_LOCKED;
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
 		migrate->src[migrate->npages++] = pfn | flags;
 		ret = migrate_vma_array_full(migrate);
 		if (ret) {
-			pte_unmap_unlock(ptep, ptl);
-			return ret;
+			ptep++;
+			break;
 		}
 	}
+	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(ptep - 1, ptl);
 
-	return 0;
+	/* Only flush the TLB if we actually modified any entries */
+	if (unmapped)
+		flush_tlb_range(walk->vma, start, end);
+
+	return ret;
 }
 
 /*
@@ -2204,7 +2241,13 @@ static void migrate_vma_collect(struct migrate_vma *migrate)
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
@@ -2251,21 +2294,27 @@ static bool migrate_vma_check_page(struct page *page)
  */
 static void migrate_vma_prepare(struct migrate_vma *migrate)
 {
-	unsigned long addr = migrate->start, i, size;
+	unsigned long addr = migrate->start, i, size, restore = 0;
 	const unsigned long npages = migrate->npages;
+	const unsigned long start = migrate->start;
 	bool allow_drain = true;
 
 	lru_add_drain();
 
-	for (i = 0; i < npages && migrate->cpages; i++, addr += size) {
+	for (addr = start, i = 0; i < npages; i++, addr += size) {
 		struct page *page = migrate_pfn_to_page(migrate->src[i]);
+		bool remap = true;
+
 		size = migrate_pfn_size(migrate->src[i]);
 
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
@@ -2274,10 +2323,16 @@ static void migrate_vma_prepare(struct migrate_vma *migrate)
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
 
@@ -2285,13 +2340,37 @@ static void migrate_vma_prepare(struct migrate_vma *migrate)
 		put_page(page);
 
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
+	for (i = 0, addr = start; i < npages && restore; i++, addr += size) {
+		struct page *page = migrate_pfn_to_page(migrate->src[i]);
+		size = migrate_pfn_size(migrate->src[i]);
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
-- 
2.4.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
