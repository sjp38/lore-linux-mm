Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id A283D6B026E
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 10:39:38 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id l20so290182960qta.3
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 07:39:38 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t14si17525531qkt.296.2016.12.08.07.39.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 07:39:37 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM v14 11/16] mm/hmm/migrate: support un-addressable ZONE_DEVICE page in migration
Date: Thu,  8 Dec 2016 11:39:39 -0500
Message-Id: <1481215184-18551-12-git-send-email-jglisse@redhat.com>
In-Reply-To: <1481215184-18551-1-git-send-email-jglisse@redhat.com>
References: <1481215184-18551-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

Allow to unmap and restore special swap entry of un-addressable
ZONE_DEVICE memory.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 mm/migrate.c | 11 ++++++++++-
 mm/rmap.c    | 47 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 57 insertions(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 66ce6b4..6b6b457 100644
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
diff --git a/mm/rmap.c b/mm/rmap.c
index 1ef3640..719c334 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -61,6 +61,7 @@
 #include <linux/hugetlb.h>
 #include <linux/backing-dev.h>
 #include <linux/page_idle.h>
+#include <linux/memremap.h>
 
 #include <asm/tlbflush.h>
 
@@ -1455,6 +1456,52 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
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
