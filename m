Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id DCB386B0372
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 14:13:07 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id j130so43487719qkj.3
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 11:13:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t5si18868022qtt.80.2017.04.24.11.13.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 11:13:06 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 11/15] mm/migrate: support un-addressable ZONE_DEVICE page in migration v2
Date: Mon, 24 Apr 2017 14:12:39 -0400
Message-Id: <20170424181243.20320-12-jglisse@redhat.com>
In-Reply-To: <20170424181243.20320-1-jglisse@redhat.com>
References: <20170424181243.20320-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

Allow to unmap and restore special swap entry of un-addressable
ZONE_DEVICE memory.

Changed since v1:
  - s/device unaddressable/device private/

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/migrate.h |  10 +++-
 mm/migrate.c            | 136 ++++++++++++++++++++++++++++++++++++++----------
 mm/page_vma_mapped.c    |  10 ++++
 mm/rmap.c               |  25 +++++++++
 4 files changed, 152 insertions(+), 29 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 576b3f5..7dd875a 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -130,12 +130,18 @@ static inline int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 
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
index 4ac2a7a..6df2e03 100644
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
@@ -233,7 +234,15 @@ static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 			pte = arch_make_huge_pte(pte, vma, new, 0);
 		}
 #endif
-		flush_dcache_page(new);
+
+		if (unlikely(is_zone_device_page(new)) &&
+		    is_device_private_page(new)) {
+			entry = make_device_private_entry(new, pte_write(pte));
+			pte = swp_entry_to_pte(entry);
+			if (pte_swp_soft_dirty(*pvmw.pte))
+				pte = pte_mksoft_dirty(pte);
+		} else
+			flush_dcache_page(new);
 		set_pte_at(vma->vm_mm, pvmw.address, pvmw.pte, pte);
 
 		if (PageHuge(new)) {
@@ -305,6 +314,8 @@ void __migration_entry_wait(struct mm_struct *mm, pte_t *ptep,
 	 */
 	if (!get_page_unless_zero(page))
 		goto out;
+	if (is_zone_device_page(page))
+		get_zone_device_page(page);
 	pte_unmap_unlock(ptep, ptl);
 	wait_on_page_locked(page);
 	put_page(page);
@@ -2139,17 +2150,40 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
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
@@ -2162,8 +2196,6 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 		 */
 		get_page(page);
 		migrate->cpages++;
-		mpfn = migrate_pfn(pfn) | MIGRATE_PFN_MIGRATE;
-		mpfn |= pte_write(pte) ? MIGRATE_PFN_WRITE : 0;
 
 		/*
 		 * Optimize for the common case where page is only mapped once
@@ -2194,6 +2226,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 		}
 
 next:
+		migrate->dst[migrate->npages] = 0;
 		migrate->src[migrate->npages++] = mpfn;
 	}
 	arch_leave_lazy_mmu_mode();
@@ -2263,6 +2296,15 @@ static bool migrate_vma_check_page(struct page *page)
 	if (PageCompound(page))
 		return false;
 
+	/* Page from ZONE_DEVICE have one extra reference */
+	if (is_zone_device_page(page)) {
+		if (is_device_private_page(page)) {
+			extra++;
+		} else
+			/* Other ZONE_DEVICE memory type are not supported */
+			return false;
+	}
+
 	if ((page_count(page) - extra) > page_mapcount(page))
 		return false;
 
@@ -2300,24 +2342,30 @@ static void migrate_vma_prepare(struct migrate_vma *migrate)
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
@@ -2326,14 +2374,19 @@ static void migrate_vma_prepare(struct migrate_vma *migrate)
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
@@ -2404,7 +2457,10 @@ static void migrate_vma_unmap(struct migrate_vma *migrate)
 		unlock_page(page);
 		restore--;
 
-		putback_lru_page(page);
+		if (is_zone_device_page(page))
+			put_page(page);
+		else
+			putback_lru_page(page);
 	}
 }
 
@@ -2435,6 +2491,26 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
 
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
@@ -2475,11 +2551,17 @@ static void migrate_vma_finalize(struct migrate_vma *migrate)
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
index de9c40d..f95765c 100644
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
index d405f0e..515cea6 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -63,6 +63,7 @@
 #include <linux/hugetlb.h>
 #include <linux/backing-dev.h>
 #include <linux/page_idle.h>
+#include <linux/memremap.h>
 
 #include <asm/tlbflush.h>
 
@@ -1308,6 +1309,10 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
 		return true;
 
+	if (IS_ENABLED(CONFIG_MIGRATION) && (flags & TTU_MIGRATION) &&
+	    is_zone_device_page(page) && !is_device_private_page(page))
+		return true;
+
 	if (flags & TTU_SPLIT_HUGE_PMD) {
 		split_huge_pmd_address(vma, address,
 				flags & TTU_MIGRATION, page);
@@ -1343,6 +1348,26 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
