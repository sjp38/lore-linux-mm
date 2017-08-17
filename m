Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 00A906B03BD
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 20:06:24 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id d15so26405112qta.11
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 17:06:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p15si1994708qtb.61.2017.08.16.17.06.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 17:06:22 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM-v25 16/19] mm/migrate: support un-addressable ZONE_DEVICE page in migration v3
Date: Wed, 16 Aug 2017 20:05:45 -0400
Message-Id: <20170817000548.32038-17-jglisse@redhat.com>
In-Reply-To: <20170817000548.32038-1-jglisse@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

Allow to unmap and restore special swap entry of un-addressable
ZONE_DEVICE memory.

Changed since v2:
  - un-conditionaly allow device private memory to be migrated (it can
    not be pin to pointless to check reference count).
Changed since v1:
  - s/device unaddressable/device private/

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/migrate.h |  10 +++-
 mm/migrate.c            | 149 +++++++++++++++++++++++++++++++++++++++---------
 mm/page_vma_mapped.c    |  10 ++++
 mm/rmap.c               |  25 ++++++++
 4 files changed, 164 insertions(+), 30 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 8f73cebfc3f5..8dc8f0a3f1af 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -159,12 +159,18 @@ static inline int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 
 #ifdef CONFIG_MIGRATION
 
+/*
+ * Watch out for PAE architecture, which has an unsigned long, and might not
+ * have enough bits to store all physical address and flags. So far we have
+ * enough room for all our flags.
+ */
 #define MIGRATE_PFN_VALID	(1UL << 0)
 #define MIGRATE_PFN_MIGRATE	(1UL << 1)
 #define MIGRATE_PFN_LOCKED	(1UL << 2)
 #define MIGRATE_PFN_WRITE	(1UL << 3)
-#define MIGRATE_PFN_ERROR	(1UL << 4)
-#define MIGRATE_PFN_SHIFT	5
+#define MIGRATE_PFN_DEVICE	(1UL << 4)
+#define MIGRATE_PFN_ERROR	(1UL << 5)
+#define MIGRATE_PFN_SHIFT	6
 
 static inline struct page *migrate_pfn_to_page(unsigned long mpfn)
 {
diff --git a/mm/migrate.c b/mm/migrate.c
index 57d1fa7a8e62..6c8a9826da32 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -36,6 +36,7 @@
 #include <linux/hugetlb.h>
 #include <linux/hugetlb_cgroup.h>
 #include <linux/gfp.h>
+#include <linux/memremap.h>
 #include <linux/balloon_compaction.h>
 #include <linux/mmu_notifier.h>
 #include <linux/page_idle.h>
@@ -236,7 +237,13 @@ static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 		if (is_write_migration_entry(entry))
 			pte = maybe_mkwrite(pte, vma);
 
-		flush_dcache_page(new);
+		if (unlikely(is_zone_device_page(new)) &&
+		    is_device_private_page(new)) {
+			entry = make_device_private_entry(new, pte_write(pte));
+			pte = swp_entry_to_pte(entry);
+		} else
+			flush_dcache_page(new);
+
 #ifdef CONFIG_HUGETLB_PAGE
 		if (PageHuge(new)) {
 			pte = pte_mkhuge(pte);
@@ -2216,17 +2223,40 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 		pte = *ptep;
 		pfn = pte_pfn(pte);
 
-		if (!pte_present(pte)) {
+		if (pte_none(pte)) {
 			mpfn = pfn = 0;
 			goto next;
 		}
 
+		if (!pte_present(pte)) {
+			mpfn = pfn = 0;
+
+			/*
+			 * Only care about unaddressable device page special
+			 * page table entry. Other special swap entries are not
+			 * migratable, and we ignore regular swapped page.
+			 */
+			entry = pte_to_swp_entry(pte);
+			if (!is_device_private_entry(entry))
+				goto next;
+
+			page = device_private_entry_to_page(entry);
+			mpfn = migrate_pfn(page_to_pfn(page))|
+				MIGRATE_PFN_DEVICE | MIGRATE_PFN_MIGRATE;
+			if (is_write_device_private_entry(entry))
+				mpfn |= MIGRATE_PFN_WRITE;
+		} else {
+			page = vm_normal_page(migrate->vma, addr, pte);
+			mpfn = migrate_pfn(pfn) | MIGRATE_PFN_MIGRATE;
+			mpfn |= pte_write(pte) ? MIGRATE_PFN_WRITE : 0;
+		}
+
 		/* FIXME support THP */
-		page = vm_normal_page(migrate->vma, addr, pte);
 		if (!page || !page->mapping || PageTransCompound(page)) {
 			mpfn = pfn = 0;
 			goto next;
 		}
+		pfn = page_to_pfn(page);
 
 		/*
 		 * By getting a reference on the page we pin it and that blocks
@@ -2239,8 +2269,6 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 		 */
 		get_page(page);
 		migrate->cpages++;
-		mpfn = migrate_pfn(pfn) | MIGRATE_PFN_MIGRATE;
-		mpfn |= pte_write(pte) ? MIGRATE_PFN_WRITE : 0;
 
 		/*
 		 * Optimize for the common case where page is only mapped once
@@ -2267,10 +2295,13 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 			 */
 			page_remove_rmap(page, false);
 			put_page(page);
-			unmapped++;
+
+			if (pte_present(pte))
+				unmapped++;
 		}
 
 next:
+		migrate->dst[migrate->npages] = 0;
 		migrate->src[migrate->npages++] = mpfn;
 	}
 	arch_leave_lazy_mmu_mode();
@@ -2340,6 +2371,28 @@ static bool migrate_vma_check_page(struct page *page)
 	if (PageCompound(page))
 		return false;
 
+	/* Page from ZONE_DEVICE have one extra reference */
+	if (is_zone_device_page(page)) {
+		/*
+		 * Private page can never be pin as they have no valid pte and
+		 * GUP will fail for those. Yet if there is a pending migration
+		 * a thread might try to wait on the pte migration entry and
+		 * will bump the page reference count. Sadly there is no way to
+		 * differentiate a regular pin from migration wait. Hence to
+		 * avoid 2 racing thread trying to migrate back to CPU to enter
+		 * infinite loop (one stoping migration because the other is
+		 * waiting on pte migration entry). We always return true here.
+		 *
+		 * FIXME proper solution is to rework migration_entry_wait() so
+		 * it does not need to take a reference on page.
+		 */
+		if (is_device_private_page(page))
+			return true;
+
+		/* Other ZONE_DEVICE memory type are not supported */
+		return false;
+	}
+
 	if ((page_count(page) - extra) > page_mapcount(page))
 		return false;
 
@@ -2390,24 +2443,30 @@ static void migrate_vma_prepare(struct migrate_vma *migrate)
 			migrate->src[i] |= MIGRATE_PFN_LOCKED;
 		}
 
-		if (!PageLRU(page) && allow_drain) {
-			/* Drain CPU's pagevec */
-			lru_add_drain_all();
-			allow_drain = false;
-		}
+		/* ZONE_DEVICE pages are not on LRU */
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
+
+			/* Drop the reference we took in collect */
+			put_page(page);
 		}
 
 		if (!migrate_vma_check_page(page)) {
@@ -2416,14 +2475,19 @@ static void migrate_vma_prepare(struct migrate_vma *migrate)
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
@@ -2494,7 +2558,10 @@ static void migrate_vma_unmap(struct migrate_vma *migrate)
 		unlock_page(page);
 		restore--;
 
-		putback_lru_page(page);
+		if (is_zone_device_page(page))
+			put_page(page);
+		else
+			putback_lru_page(page);
 	}
 }
 
@@ -2525,6 +2592,26 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
 
 		mapping = page_mapping(page);
 
+		if (is_zone_device_page(newpage)) {
+			if (is_device_private_page(newpage)) {
+				/*
+				 * For now only support private anonymous when
+				 * migrating to un-addressable device memory.
+				 */
+				if (mapping) {
+					migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
+					continue;
+				}
+			} else {
+				/*
+				 * Other types of ZONE_DEVICE page are not
+				 * supported.
+				 */
+				migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
+				continue;
+			}
+		}
+
 		r = migrate_page(mapping, newpage, page, MIGRATE_SYNC_NO_COPY);
 		if (r != MIGRATEPAGE_SUCCESS)
 			migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
@@ -2565,11 +2652,17 @@ static void migrate_vma_finalize(struct migrate_vma *migrate)
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
index 3bd3008db4cb..6a03946469a9 100644
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
+			if (is_device_private_entry(entry) &&
+			    device_private_entry_to_page(entry) == pvmw->page)
+				return true;
+		}
+
 		if (!pte_present(*pvmw->pte))
 			return false;
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 2c55e7b8f8f4..60e47a96cdbd 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -63,6 +63,7 @@
 #include <linux/hugetlb.h>
 #include <linux/backing-dev.h>
 #include <linux/page_idle.h>
+#include <linux/memremap.h>
 
 #include <asm/tlbflush.h>
 
@@ -1330,6 +1331,10 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
 		return true;
 
+	if (IS_ENABLED(CONFIG_MIGRATION) && (flags & TTU_MIGRATION) &&
+	    is_zone_device_page(page) && !is_device_private_page(page))
+		return true;
+
 	if (flags & TTU_SPLIT_HUGE_PMD) {
 		split_huge_pmd_address(vma, address,
 				flags & TTU_SPLIT_FREEZE, page);
@@ -1378,6 +1383,26 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
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
2.13.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
