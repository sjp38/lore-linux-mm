Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id AFF44831CC
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:04:19 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id n141so42278872qke.1
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 08:04:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t30si4105026qtt.48.2017.03.16.08.04.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 08:04:05 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 13/16] mm/hmm/migrate: support un-addressable ZONE_DEVICE page in migration
Date: Thu, 16 Mar 2017 12:05:32 -0400
Message-Id: <1489680335-6594-14-git-send-email-jglisse@redhat.com>
In-Reply-To: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Allow to unmap and restore special swap entry of un-addressable
ZONE_DEVICE memory.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/migrate.h |   2 +
 mm/migrate.c            | 141 +++++++++++++++++++++++++++++++++++++-----------
 mm/page_vma_mapped.c    |  10 ++++
 mm/rmap.c               |  25 +++++++++
 4 files changed, 147 insertions(+), 31 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 6c610ee..c43669b 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -130,6 +130,8 @@ static inline int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 #define MIGRATE_PFN_HUGE	(1UL << (BITS_PER_LONG_LONG - 3))
 #define MIGRATE_PFN_LOCKED	(1UL << (BITS_PER_LONG_LONG - 4))
 #define MIGRATE_PFN_WRITE	(1UL << (BITS_PER_LONG_LONG - 5))
+#define MIGRATE_PFN_DEVICE	(1UL << (BITS_PER_LONG_LONG - 6))
+#define MIGRATE_PFN_ERROR	(1UL << (BITS_PER_LONG_LONG - 7))
 #define MIGRATE_PFN_MASK	((1UL << (BITS_PER_LONG_LONG - PAGE_SHIFT)) - 1)
 
 static inline struct page *migrate_pfn_to_page(unsigned long mpfn)
diff --git a/mm/migrate.c b/mm/migrate.c
index 5a14b4ec..9950245 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -41,6 +41,7 @@
 #include <linux/page_idle.h>
 #include <linux/page_owner.h>
 #include <linux/sched/mm.h>
+#include <linux/memremap.h>
 
 #include <asm/tlbflush.h>
 
@@ -230,7 +231,15 @@ static int remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 			pte = arch_make_huge_pte(pte, vma, new, 0);
 		}
 #endif
-		flush_dcache_page(new);
+
+		if (unlikely(is_zone_device_page(new)) &&
+		    !is_addressable_page(new)) {
+			entry = make_device_entry(new, pte_write(pte));
+			pte = swp_entry_to_pte(entry);
+			if (pte_swp_soft_dirty(*pvmw.pte))
+				pte = pte_mksoft_dirty(pte);
+		} else
+			flush_dcache_page(new);
 		set_pte_at(vma->vm_mm, pvmw.address, pvmw.pte, pte);
 
 		if (PageHuge(new)) {
@@ -302,6 +311,8 @@ void __migration_entry_wait(struct mm_struct *mm, pte_t *ptep,
 	 */
 	if (!get_page_unless_zero(page))
 		goto out;
+	if (is_zone_device_page(page))
+		get_zone_device_page(page);
 	pte_unmap_unlock(ptep, ptl);
 	wait_on_page_locked(page);
 	put_page(page);
@@ -2101,12 +2112,14 @@ static int migrate_vma_collect_hole(unsigned long start,
 		next = pmd_addr_end(addr, end);
 		npages = (next - addr) >> PAGE_SHIFT;
 		if (npages == (PMD_SIZE >> PAGE_SHIFT)) {
+			migrate->dst[migrate->npages] = 0;
 			migrate->src[migrate->npages++] = MIGRATE_PFN_HUGE;
 			ret = migrate_vma_array_full(migrate);
 			if (ret)
 				return ret;
 		} else {
 			for (i = 0; i < npages; ++i) {
+				migrate->dst[migrate->npages] = 0;
 				migrate->src[migrate->npages++] = 0;
 				ret = migrate_vma_array_full(migrate);
 				if (ret)
@@ -2148,17 +2161,44 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 		pte = *ptep;
 		pfn = pte_pfn(pte);
 
-		if (!pte_present(pte)) {
+		if (pte_none(pte)) {
 			flags = pfn = 0;
 			goto next;
 		}
 
+		if (!pte_present(pte)) {
+			flags = pfn = 0;
+
+			/*
+			 * Only care about unaddressable device page special
+			 * page table entry. Other special swap entry are not
+			 * migratable and we ignore regular swapped page.
+			 */
+			entry = pte_to_swp_entry(pte);
+			if (!is_device_entry(entry))
+				goto next;
+
+			page = device_entry_to_page(entry);
+			if (!dev_page_allow_migrate(page))
+				goto next;
+
+			flags = MIGRATE_PFN_VALID |
+				MIGRATE_PFN_DEVICE |
+				MIGRATE_PFN_MIGRATE;
+			if (is_write_device_entry(entry))
+				flags |= MIGRATE_PFN_WRITE;
+		} else {
+			page = vm_normal_page(migrate->vma, addr, pte);
+			flags = MIGRATE_PFN_VALID | MIGRATE_PFN_MIGRATE;
+			flags |= pte_write(pte) ? MIGRATE_PFN_WRITE : 0;
+		}
+
 		/* FIXME support THP */
-		page = vm_normal_page(migrate->vma, addr, pte);
 		if (!page || !page->mapping || PageTransCompound(page)) {
 			flags = pfn = 0;
 			goto next;
 		}
+		pfn = page_to_pfn(page);
 
 		/*
 		 * By getting a reference on the page we pin it and that blocks
@@ -2171,8 +2211,6 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 		 */
 		get_page(page);
 		migrate->cpages++;
-		flags = MIGRATE_PFN_VALID | MIGRATE_PFN_MIGRATE;
-		flags |= pte_write(pte) ? MIGRATE_PFN_WRITE : 0;
 
 		/*
 		 * Optimize for the common case where page is only mapped once
@@ -2203,6 +2241,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 		}
 
 next:
+		migrate->dst[migrate->npages] = 0;
 		migrate->src[migrate->npages++] = pfn | flags;
 		ret = migrate_vma_array_full(migrate);
 		if (ret) {
@@ -2277,6 +2316,13 @@ static bool migrate_vma_check_page(struct page *page)
 	if (PageCompound(page))
 		return false;
 
+	/* Page from ZONE_DEVICE have one extra reference */
+	if (is_zone_device_page(page)) {
+		if (!dev_page_allow_migrate(page))
+			return false;
+		extra++;
+	}
+
 	if ((page_count(page) - extra) > page_mapcount(page))
 		return false;
 
@@ -2316,28 +2362,31 @@ static void migrate_vma_prepare(struct migrate_vma *migrate)
 			migrate->src[i] |= MIGRATE_PFN_LOCKED;
 		}
 
-		if (!PageLRU(page) && allow_drain) {
-			/* Drain CPU's pagevec */
-			lru_add_drain_all();
-			allow_drain = false;
-		}
+		/* ZONE_DEVICE page are not on LRU */
+		if (!is_zone_device_page(page)) {
+			if (!PageLRU(page) && allow_drain) {
+				/* Drain CPU's pagevec */
+				lru_add_drain_all();
+				allow_drain = false;
+			}
 
-		if (isolate_lru_page(page)) {
-			if (remap) {
-				migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
-				migrate->cpages--;
-				restore++;
-			} else {
-				migrate->src[i] = 0;
-				unlock_page(page);
-				migrate->cpages--;
-				put_page(page);
+			if (isolate_lru_page(page)) {
+				if (remap) {
+					migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
+					migrate->cpages--;
+					restore++;
+				} else {
+					migrate->src[i] = 0;
+					unlock_page(page);
+					migrate->cpages--;
+					put_page(page);
+				}
+				continue;
 			}
-			continue;
-		}
 
-		/* Drop the reference we took in collect */
-		put_page(page);
+			/* Drop the reference we took in collect */
+			put_page(page);
+		}
 
 		if (!migrate_vma_check_page(page)) {
 			if (remap) {
@@ -2345,14 +2394,19 @@ static void migrate_vma_prepare(struct migrate_vma *migrate)
 				migrate->cpages--;
 				restore++;
 
-				get_page(page);
-				putback_lru_page(page);
+				if (!is_zone_device_page(page)) {
+					get_page(page);
+					putback_lru_page(page);
+				}
 			} else {
 				migrate->src[i] = 0;
 				unlock_page(page);
 				migrate->cpages--;
 
-				putback_lru_page(page);
+				if (!is_zone_device_page(page))
+					putback_lru_page(page);
+				else
+					put_page(page);
 			}
 		}
 	}
@@ -2391,7 +2445,7 @@ static void migrate_vma_unmap(struct migrate_vma *migrate)
 	const unsigned long npages = migrate->npages;
 	const unsigned long start = migrate->start;
 
-	for (i = 0; i < npages && migrate->cpages; addr += size, i++) {
+	for (addr = start, i = 0; i < npages; addr += size, i++) {
 		struct page *page = migrate_pfn_to_page(migrate->src[i]);
 		size = migrate_pfn_size(migrate->src[i]);
 
@@ -2419,7 +2473,10 @@ static void migrate_vma_unmap(struct migrate_vma *migrate)
 		unlock_page(page);
 		restore--;
 
-		putback_lru_page(page);
+		if (is_zone_device_page(page))
+			put_page(page);
+		else
+			putback_lru_page(page);
 	}
 }
 
@@ -2451,6 +2508,22 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
 
 		mapping = page_mapping(page);
 
+		if (is_zone_device_page(newpage)) {
+			if (!dev_page_allow_migrate(newpage)) {
+				migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
+				continue;
+			}
+
+			/*
+			 * For now only support private anonymous when migrating
+			 * to un-addressable device memory.
+			 */
+			if (mapping && !is_addressable_page(newpage)) {
+				migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
+				continue;
+			}
+		}
+
 		r = migrate_page(mapping, newpage, page, MIGRATE_SYNC, false);
 		if (r != MIGRATEPAGE_SUCCESS)
 			migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
@@ -2492,11 +2565,17 @@ static void migrate_vma_finalize(struct migrate_vma *migrate)
 		unlock_page(page);
 		migrate->cpages--;
 
-		putback_lru_page(page);
+		if (is_zone_device_page(page))
+			put_page(page);
+		else
+			putback_lru_page(page);
 
 		if (newpage != page) {
 			unlock_page(newpage);
-			putback_lru_page(newpage);
+			if (is_zone_device_page(newpage))
+				put_page(newpage);
+			else
+				putback_lru_page(newpage);
 		}
 	}
 }
diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
index c4c9def..5730d23 100644
--- a/mm/page_vma_mapped.c
+++ b/mm/page_vma_mapped.c
@@ -48,6 +48,7 @@ static bool check_pte(struct page_vma_mapped_walk *pvmw)
 		if (!is_swap_pte(*pvmw->pte))
 			return false;
 		entry = pte_to_swp_entry(*pvmw->pte);
+
 		if (!is_migration_entry(entry))
 			return false;
 		if (migration_entry_to_page(entry) - pvmw->page >=
@@ -60,6 +61,15 @@ static bool check_pte(struct page_vma_mapped_walk *pvmw)
 		WARN_ON_ONCE(1);
 #endif
 	} else {
+		if (is_swap_pte(*pvmw->pte)) {
+			swp_entry_t entry;
+
+			entry = pte_to_swp_entry(*pvmw->pte);
+			if (is_device_entry(entry) &&
+			    device_entry_to_page(entry) == pvmw->page)
+				return true;
+		}
+
 		if (!pte_present(*pvmw->pte))
 			return false;
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 49ed681..59c34d5 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -63,6 +63,7 @@
 #include <linux/hugetlb.h>
 #include <linux/backing-dev.h>
 #include <linux/page_idle.h>
+#include <linux/memremap.h>
 
 #include <asm/tlbflush.h>
 
@@ -1315,6 +1316,10 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
 		return SWAP_AGAIN;
 
+	if (IS_ENABLED(CONFIG_MIGRATION) && (flags & TTU_MIGRATION) &&
+	    is_zone_device_page(page) && !dev_page_allow_migrate(page))
+		return SWAP_AGAIN;
+
 	if (flags & TTU_SPLIT_HUGE_PMD) {
 		split_huge_pmd_address(vma, address,
 				flags & TTU_MIGRATION, page);
@@ -1350,6 +1355,26 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		subpage = page - page_to_pfn(page) + pte_pfn(*pvmw.pte);
 		address = pvmw.address;
 
+		if (IS_ENABLED(CONFIG_MIGRATION) &&
+		    (flags & TTU_MIGRATION) &&
+		    is_zone_device_page(page)) {
+			swp_entry_t entry;
+			pte_t swp_pte;
+
+			pteval = ptep_get_and_clear(mm, address, pvmw.pte);
+
+			/*
+			 * Store the pfn of the page in a special migration
+			 * pte. do_swap_page() will wait until the migration
+			 * pte is removed and then restart fault handling.
+			 */
+			entry = make_migration_entry(page, 0);
+			swp_pte = swp_entry_to_pte(entry);
+			if (pte_soft_dirty(pteval))
+				swp_pte = pte_swp_mksoft_dirty(swp_pte);
+			set_pte_at(mm, address, pvmw.pte, swp_pte);
+			goto discard;
+		}
 
 		if (!(flags & TTU_IGNORE_ACCESS)) {
 			if (ptep_clear_flush_young_notify(vma, address,
-- 
2.4.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
