Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4F1F56B0005
	for <linux-mm@kvack.org>; Tue,  3 May 2016 08:34:05 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id b189so35273004vkh.3
        for <linux-mm@kvack.org>; Tue, 03 May 2016 05:34:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y84si1747790qhc.45.2016.05.03.05.34.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 May 2016 05:34:04 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH] mm/numa/thp: fix assumptions of migrate_misplaced_transhuge_page()
Date: Tue,  3 May 2016 14:33:51 +0200
Message-Id: <1462278831-1959-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Fix assumptions in migrate_misplaced_transhuge_page() which is only
call by do_huge_pmd_numa_page() itself only call by __handle_mm_fault()
for pmd with PROT_NONE. This means that if the pmd stays the same
then there can be no concurrent get_user_pages / get_user_pages_fast
(GUP/GUP_fast). More over because migrate_misplaced_transhuge_page()
abort if page is mapped more than once then there can be no GUP from
a different process. Finaly, holding the pmd lock assure us that no
other part of the kernel can take an extra reference on the page.

In the end this means that the failure code path should never be
taken unless something is horribly wrong, so convert it to BUG_ON().

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/migrate.c | 38 +++++++++++++++++++++++---------------
 1 file changed, 23 insertions(+), 15 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index f9dfb18..07148be 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1760,7 +1760,13 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	int page_lru = page_is_file_cache(page);
 	unsigned long mmun_start = address & HPAGE_PMD_MASK;
 	unsigned long mmun_end = mmun_start + HPAGE_PMD_SIZE;
-	pmd_t orig_entry;
+
+	/*
+	 * What we do here is only valid if pmd_protnone(entry) is true and thp
+	 * page is map in only once, which numamigrate_isolate_page() checks.
+	 */
+	if (!pmd_protnone(entry))
+		goto out_unlock;
 
 	/*
 	 * Rate-limit the amount of data that is being migrated to a node.
@@ -1803,7 +1809,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_same(*pmd, entry) || page_count(page) != 2)) {
-fail_putback:
 		spin_unlock(ptl);
 		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 
@@ -1825,17 +1830,21 @@ fail_putback:
 		goto out_unlock;
 	}
 
-	orig_entry = *pmd;
+	/*
+	 * We are holding the lock so no one can set a new pmd and original pmd
+	 * is PROT_NONE thus no one can get_user_pages or get_user_pages_fast
+	 * (GUP or GUP_fast) from this point on we can not fail.
+	 */
 	entry = mk_pmd(new_page, vma->vm_page_prot);
 	entry = pmd_mkhuge(entry);
 	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 
 	/*
 	 * Clear the old entry under pagetable lock and establish the new PTE.
-	 * Any parallel GUP will either observe the old page blocking on the
-	 * page lock, block on the page table lock or observe the new page.
-	 * The SetPageUptodate on the new page and page_add_new_anon_rmap
-	 * guarantee the copy is visible before the pagetable update.
+	 * Any parallel GUP can only observe the new page as old page only had
+	 * one mapping with PROT_NONE (GUP/GUP_fast fails if pmd_protnone() is
+	 * true). However a concurrent GUP might see the new page as soon as
+	 * we set the pmd to the new entry.
 	 */
 	flush_cache_range(vma, mmun_start, mmun_end);
 	page_add_anon_rmap(new_page, vma, mmun_start, true);
@@ -1843,14 +1852,13 @@ fail_putback:
 	set_pmd_at(mm, mmun_start, pmd, entry);
 	update_mmu_cache_pmd(vma, address, &entry);
 
-	if (page_count(page) != 2) {
-		set_pmd_at(mm, mmun_start, pmd, orig_entry);
-		flush_pmd_tlb_range(vma, mmun_start, mmun_end);
-		mmu_notifier_invalidate_range(mm, mmun_start, mmun_end);
-		update_mmu_cache_pmd(vma, address, &entry);
-		page_remove_rmap(new_page, true);
-		goto fail_putback;
-	}
+	/* As said above no one can get reference on the old page nor through
+	 * get_user_pages or get_user_pages_fast (GUP/GUP_fast) or through
+	 * any other means. To get reference on huge page you need to hold
+	 * pmd_lock and we are already holding that lock here and the page
+	 * is only mapped once.
+	 */
+	BUG_ON(page_count(page) != 2);
 
 	mlock_migrate_page(new_page, page);
 	page_remove_rmap(page, true);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
