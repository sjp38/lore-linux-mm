Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id F01406B0273
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 10:46:13 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id x2so21597827itf.6
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 07:46:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c62si3058309iod.40.2017.01.06.07.46.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 07:46:13 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM v15 14/16] mm/hmm/migrate: optimize page map once in vma being migrated
Date: Fri,  6 Jan 2017 11:46:41 -0500
Message-Id: <1483721203-1678-15-git-send-email-jglisse@redhat.com>
In-Reply-To: <1483721203-1678-1-git-send-email-jglisse@redhat.com>
References: <1483721203-1678-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

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
 mm/migrate.c | 180 +++++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 170 insertions(+), 10 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 365b615..a256f68 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2116,6 +2116,7 @@ static int hmm_collect_walk_pmd(pmd_t *pmdp,
 	struct hmm_migrate *migrate = walk->private;
 	struct mm_struct *mm = walk->vma->vm_mm;
 	unsigned long addr = start;
+	unsigned long unmaped = 0;
 	hmm_pfn_t *src_pfns;
 	spinlock_t *ptl;
 	pte_t *ptep;
@@ -2130,6 +2131,7 @@ static int hmm_collect_walk_pmd(pmd_t *pmdp,
 
 	src_pfns = &migrate->src_pfns[(addr - migrate->start) >> PAGE_SHIFT];
 	ptep = pte_offset_map_lock(mm, pmdp, addr, &ptl);
+	arch_enter_lazy_mmu_mode();
 
 	for (; addr < end; addr += PAGE_SIZE, src_pfns++, ptep++) {
 		unsigned long pfn;
@@ -2194,9 +2196,44 @@ static int hmm_collect_walk_pmd(pmd_t *pmdp,
 		 * can't be drop from it).
 		 */
 		get_page(page);
+
+		/*
+		 * Optimize for common case where page is only map once in one
+		 * process. If we can lock the page then we can safely setup
+		 * special migration page table entry now.
+		 */
+		if (!trylock_page(page)) {
+			set_pte_at(mm, addr, ptep, pte);
+		} else {
+			pte_t swp_pte;
+
+			*src_pfns |= HMM_PFN_LOCKED;
+			ptep_get_and_clear(mm, addr, ptep);
+
+			/* Setup special migration page table entry */
+			entry = make_migration_entry(page, write);
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
 	}
+	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(ptep - 1, ptl);
 
+	/* Only flush the TLB if we actually modified any entries */
+	if (unmaped)
+		flush_tlb_range(walk->vma, start, end);
+
 	return 0;
 }
 
@@ -2279,18 +2316,26 @@ static inline bool hmm_migrate_page_check(struct page *page)
 static void hmm_migrate_lock_and_isolate(struct hmm_migrate *migrate)
 {
 	unsigned long addr = migrate->start, i = 0;
+ 	struct mm_struct *mm = migrate->vma->vm_mm;
+ 	struct vm_area_struct *vma = migrate->vma;
+	hmm_pfn_t *src_pfns = migrate->src_pfns;
+	unsigned long restore = 0;
 	bool allow_drain = true;
 
 	lru_add_drain();
 
 	for (; (addr<migrate->end) && migrate->npages; addr+=PAGE_SIZE, i++) {
-		struct page *page = hmm_pfn_to_page(migrate->src_pfns[i]);
+		struct page *page = hmm_pfn_to_page(src_pfns[i]);
+		bool need_restore = true;
 
 		if (!page)
 			continue;
 
-		lock_page(page);
-		migrate->src_pfns[i] |= HMM_PFN_LOCKED;
+		if (!(src_pfns[i] & HMM_PFN_LOCKED)) {
+			lock_page(page);
+			need_restore = false;
+			src_pfns[i] |= HMM_PFN_LOCKED;
+		}
 
 		/* ZONE_DEVICE page are not on LRU */
 		if (!is_zone_device_page(page)) {
@@ -2301,20 +2346,135 @@ static void hmm_migrate_lock_and_isolate(struct hmm_migrate *migrate)
 			}
 
 			if (isolate_lru_page(page)) {
-				migrate->src_pfns[i] = 0;
-				migrate->npages--;
-				unlock_page(page);
-				put_page(page);
+				if (need_restore) {
+					src_pfns[i] &= ~HMM_PFN_MIGRATE;
+					restore++;
+				} else {
+					migrate->npages--;
+					unlock_page(page);
+					src_pfns[i] = 0;
+					put_page(page);
+				}
 			} else
 				/* Drop the reference we took in collect */
 				put_page(page);
 		}
 
 		if (!hmm_migrate_page_check(page)) {
-			migrate->src_pfns[i] = 0;
-			migrate->npages--;
+			if (need_restore) {
+				src_pfns[i] &= ~HMM_PFN_MIGRATE;
+				restore++;
+			} else {
+				migrate->npages--;
+				unlock_page(page);
+				src_pfns[i] = 0;
+				put_page(page);
+			}
+		}
+	}
+
+	if (!restore)
+		return;
+
+	for (addr = migrate->start, i = 0; (addr < migrate->end) && restore;) {
+		struct page *page = hmm_pfn_to_page(src_pfns[i]);
+		unsigned long next, restart;
+		spinlock_t *ptl;
+		pgd_t *pgdp;
+		pud_t *pudp;
+		pmd_t *pmdp;
+		pte_t *ptep;
+
+		if (!page || !(src_pfns[i] & HMM_PFN_MIGRATE)) {
+			addr += PAGE_SIZE;
+			i++;
+			continue;
+		}
+
+		restart = addr;
+
+		/*
+		 * Some one might have zap the mapping. Truncate should be only
+		 * case for which this might happen while holding mmap_sem.
+		 */
+		pgdp = pgd_offset(mm, addr);
+		next = pgd_addr_end(addr, migrate->end);
+		if (!pgdp || pgd_none_or_clear_bad(pgdp))
+			goto unlock_release;
+		pudp = pud_offset(pgdp, addr);
+		next = pud_addr_end(addr, migrate->end);
+		if (!pudp || pud_none(*pudp))
+			goto unlock_release;
+		pmdp = pmd_offset(pudp, addr);
+		next = pmd_addr_end(addr, migrate->end);
+		if (!pmdp || pmd_none(*pmdp) || pmd_trans_huge(*pmdp))
+			goto unlock_release;
+
+		ptep = pte_offset_map_lock(mm, pmdp, addr, &ptl);
+		for (; addr < next; addr += PAGE_SIZE, i++, ptep++) {
+			swp_entry_t entry;
+			bool write;
+			pte_t pte;
+
+			page = hmm_pfn_to_page(src_pfns[i]);
+			if (!page || (src_pfns[i] & HMM_PFN_MIGRATE))
+				continue;
+
+			write = src_pfns[i] & HMM_PFN_WRITE;
+			write &= (vma->vm_flags & VM_WRITE);
+
+			/* Here it means pte must be a valid migration entry */
+			pte = ptep_get_and_clear(mm, addr, ptep);
+			if (pte_none(pte) || pte_present(pte)) {
+				/* SOMETHING BAD IS GOING ON ! */
+				set_pte_at(mm, addr, ptep, pte);
+				continue;
+			}
+			entry = pte_to_swp_entry(pte);
+			if (!is_migration_entry(entry)) {
+				/* SOMETHING BAD IS GOING ON ! */
+				set_pte_at(mm, addr, ptep, pte);
+				continue;
+			}
+
+			if (is_zone_device_page(page) &&
+			    !is_addressable_page(page)) {
+				entry = make_device_entry(page, write);
+				pte = swp_entry_to_pte(entry);
+			} else {
+				pte = mk_pte(page, vma->vm_page_prot);
+				pte = pte_mkold(pte);
+				if (write)
+					pte = pte_mkwrite(pte);
+			}
+			if (pte_swp_soft_dirty(*ptep))
+				pte = pte_mksoft_dirty(pte);
+
+			get_page(page);
+			set_pte_at(mm, addr, ptep, pte);
+			if (PageAnon(page))
+				page_add_anon_rmap(page, vma, addr, false);
+			else
+				page_add_file_rmap(page, false);
+		}
+		pte_unmap_unlock(ptep - 1, ptl);
+
+unlock_release:
+		addr = restart;
+		i = (addr - migrate->start) >> PAGE_SHIFT;
+		for (; addr < next && restore; addr += PAGE_SHIFT, i++) {
+			page = hmm_pfn_to_page(src_pfns[i]);
+			if (!page || (src_pfns[i] & HMM_PFN_MIGRATE))
+				continue;
+
+			src_pfns[i] = 0;
 			unlock_page(page);
-			put_page(page);
+			restore--;
+
+			if (is_zone_device_page(page))
+				put_page(page);
+			else
+				putback_lru_page(page);
 		}
 	}
 }
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
