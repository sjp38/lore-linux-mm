Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 954186B026F
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 16:51:02 -0500 (EST)
Received: by mail-yw0-f200.google.com with SMTP id l19so283184604ywc.5
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 13:51:02 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b1si1698840ywb.163.2017.01.27.13.51.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jan 2017 13:51:01 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM v17 12/14] mm/hmm/migrate: support un-addressable ZONE_DEVICE page in migration
Date: Fri, 27 Jan 2017 17:52:19 -0500
Message-Id: <1485557541-7806-13-git-send-email-jglisse@redhat.com>
In-Reply-To: <1485557541-7806-1-git-send-email-jglisse@redhat.com>
References: <1485557541-7806-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

Allow to unmap and restore special swap entry of un-addressable
ZONE_DEVICE memory.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/migrate.h |   2 +
 mm/migrate.c            | 134 +++++++++++++++++++++++++++++++++++++-----------
 mm/rmap.c               |  47 +++++++++++++++++
 3 files changed, 153 insertions(+), 30 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index cd56e41..2d7904a 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -129,6 +129,8 @@ static inline int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 #define MIGRATE_PFN_LOCKED	(1UL << (BITS_PER_LONG_LONG - 4))
 #define MIGRATE_PFN_WRITE	(1UL << (BITS_PER_LONG_LONG - 5))
 #define MIGRATE_PFN_ZERO	(1UL << (BITS_PER_LONG_LONG - 6))
+#define MIGRATE_PFN_DEVICE	(1UL << (BITS_PER_LONG_LONG - 7))
+#define MIGRATE_PFN_ERROR	(1UL << (BITS_PER_LONG_LONG - 8))
 #define MIGRATE_PFN_MASK	((1UL << (BITS_PER_LONG_LONG - PAGE_SHIFT)) - 1)
 
 static inline struct page *migrate_pfn_to_page(unsigned long mpfn)
diff --git a/mm/migrate.c b/mm/migrate.c
index d78c0e7..bc14b8e 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -40,6 +40,7 @@
 #include <linux/mmu_notifier.h>
 #include <linux/page_idle.h>
 #include <linux/page_owner.h>
+#include <linux/memremap.h>
 
 #include <asm/tlbflush.h>
 
@@ -248,7 +249,15 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 		pte = arch_make_huge_pte(pte, vma, new, 0);
 	}
 #endif
-	flush_dcache_page(new);
+
+	if (unlikely(is_zone_device_page(new)) && !is_addressable_page(new)) {
+		entry = make_device_entry(new, pte_write(pte));
+		pte = swp_entry_to_pte(entry);
+		if (pte_swp_soft_dirty(*ptep))
+			pte = pte_mksoft_dirty(pte);
+	} else
+		flush_dcache_page(new);
+
 	set_pte_at(mm, addr, ptep, pte);
 
 	if (PageHuge(new)) {
@@ -2165,17 +2174,44 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
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
+			 * Only care about un-addressable device page special
+			 * page table entry. Other special swap entry are not
+			 * migratable and we ignore regular swaped page.
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
 		 * By getting a reference on the page we pin it and blocks any
@@ -2187,8 +2223,6 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 		 */
 		get_page(page);
 		migrate->cpages++;
-		flags = MIGRATE_PFN_VALID | MIGRATE_PFN_MIGRATE;
-		flags |= pte_write(pte) ? MIGRATE_PFN_WRITE : 0;
 
 		/*
 		 * Optimize for common case where page is only map once in one
@@ -2290,6 +2324,13 @@ static bool migrate_vma_check_page(struct page *page)
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
 
@@ -2327,28 +2368,31 @@ static void migrate_vma_prepare(struct migrate_vma *migrate)
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
@@ -2356,14 +2400,19 @@ static void migrate_vma_prepare(struct migrate_vma *migrate)
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
@@ -2428,7 +2477,10 @@ static void migrate_vma_unmap(struct migrate_vma *migrate)
 		unlock_page(page);
 		restore--;
 
-		putback_lru_page(page);
+		if (is_zone_device_page(page))
+			put_page(page);
+		else
+			putback_lru_page(page);
 	}
 }
 
@@ -2459,6 +2511,22 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
 
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
@@ -2497,11 +2565,17 @@ static void migrate_vma_finalize(struct migrate_vma *migrate)
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
diff --git a/mm/rmap.c b/mm/rmap.c
index 91619fd..c7b0b54 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -61,6 +61,7 @@
 #include <linux/hugetlb.h>
 #include <linux/backing-dev.h>
 #include <linux/page_idle.h>
+#include <linux/memremap.h>
 
 #include <asm/tlbflush.h>
 
@@ -1454,6 +1455,52 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			goto out;
 	}
 
+	if ((flags & TTU_MIGRATION) && is_zone_device_page(page)) {
+		swp_entry_t entry;
+		pte_t swp_pte;
+		pmd_t *pmdp;
+
+		if (!dev_page_allow_migrate(page))
+			goto out;
+
+		pmdp = mm_find_pmd(mm, address);
+		if (!pmdp)
+			goto out;
+
+		pte = pte_offset_map_lock(mm, pmdp, address, &ptl);
+		if (!pte)
+			goto out;
+
+		pteval = ptep_get_and_clear(mm, address, pte);
+		if (pte_present(pteval) || pte_none(pteval)) {
+			set_pte_at(mm, address, pte, pteval);
+			goto out_unmap;
+		}
+
+		entry = pte_to_swp_entry(pteval);
+		if (!is_device_entry(entry)) {
+			set_pte_at(mm, address, pte, pteval);
+			goto out_unmap;
+		}
+
+		if (device_entry_to_page(entry) != page) {
+			set_pte_at(mm, address, pte, pteval);
+			goto out_unmap;
+		}
+
+		/*
+		 * Store the pfn of the page in a special migration
+		 * pte. do_swap_page() will wait until the migration
+		 * pte is removed and then restart fault handling.
+		 */
+		entry = make_migration_entry(page, 0);
+		swp_pte = swp_entry_to_pte(entry);
+		if (pte_soft_dirty(*pte))
+			swp_pte = pte_swp_mksoft_dirty(swp_pte);
+		set_pte_at(mm, address, pte, swp_pte);
+		goto discard;
+	}
+
 	pte = page_check_address(page, mm, address, &ptl,
 				 PageTransCompound(page));
 	if (!pte)
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
