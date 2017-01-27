Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1BDFC6B026A
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 16:50:57 -0500 (EST)
Received: by mail-yw0-f200.google.com with SMTP id l19so283182545ywc.5
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 13:50:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y185si1695060ywc.278.2017.01.27.13.50.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jan 2017 13:50:56 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM v17 07/14] mm/migrate: migrate_vma() unmap page from vma while collecting pages
Date: Fri, 27 Jan 2017 17:52:14 -0500
Message-Id: <1485557541-7806-8-git-send-email-jglisse@redhat.com>
In-Reply-To: <1485557541-7806-1-git-send-email-jglisse@redhat.com>
References: <1485557541-7806-1-git-send-email-jglisse@redhat.com>
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
 mm/migrate.c | 108 ++++++++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 93 insertions(+), 15 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 150fc4d..d78c0e7 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2142,9 +2142,10 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 {
 	struct migrate_vma *migrate = walk->private;
 	struct mm_struct *mm = walk->vma->vm_mm;
-	unsigned long addr = start;
+	unsigned long addr = start, unmaped = 0;
 	spinlock_t *ptl;
 	pte_t *ptep;
+	int ret = 0;
 
 	if (pmd_none(*pmdp) || pmd_trans_unstable(pmdp)) {
 		/* FIXME support THP */
@@ -2152,9 +2153,12 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
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
 
@@ -2186,17 +2190,50 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 		flags = MIGRATE_PFN_VALID | MIGRATE_PFN_MIGRATE;
 		flags |= pte_write(pte) ? MIGRATE_PFN_WRITE : 0;
 
+		/*
+		 * Optimize for common case where page is only map once in one
+		 * process. If we can lock the page then we can safely setup
+		 * special migration page table entry now.
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
+			 * This is like regulat unmap we remove the rmap and
+			 * drop page refcount. Page won't be free as we took
+			 * a reference just above.
+			 */
+			page_remove_rmap(page, false);
+			put_page(page);
+			unmaped++;
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
+	if (unmaped)
+		flush_tlb_range(walk->vma, start, end);
+
+	return ret;
 }
 
 /*
@@ -2220,7 +2257,13 @@ static void migrate_vma_collect(struct migrate_vma *migrate)
 	mm_walk.mm = migrate->vma->vm_mm;
 	mm_walk.private = migrate;
 
+	mmu_notifier_invalidate_range_start(mm_walk.mm,
+					    migrate->start,
+					    migrate->end);
 	walk_page_range(migrate->start, migrate->end, &mm_walk);
+	mmu_notifier_invalidate_range_end(mm_walk.mm,
+					  migrate->start,
+					  migrate->end);
 }
 
 /*
@@ -2264,20 +2307,25 @@ static bool migrate_vma_check_page(struct page *page)
  */
 static void migrate_vma_prepare(struct migrate_vma *migrate)
 {
-	unsigned long addr = migrate->start, i = 0, size;
+	unsigned long addr = migrate->start, i = 0, size, restore = 0;
 	bool allow_drain = true;
 
 	lru_add_drain();
 
 	for (; i < migrate->npages && migrate->cpages; i++, addr += size) {
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
@@ -2286,10 +2334,16 @@ static void migrate_vma_prepare(struct migrate_vma *migrate)
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
 
@@ -2297,13 +2351,37 @@ static void migrate_vma_prepare(struct migrate_vma *migrate)
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
+	for (i = 0; i < migrate->npages && restore; i++, addr += size) {
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
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
