Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 67ACE6B03A0
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 06:28:37 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r70so64274974pfb.7
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 03:28:37 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m29si8775702pfj.277.2017.06.13.03.28.36
        for <linux-mm@kvack.org>;
        Tue, 13 Jun 2017 03:28:36 -0700 (PDT)
From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH v2 3/3] mm: migrate: Stabilise page count when migrating transparent hugepages
Date: Tue, 13 Jun 2017 11:28:42 +0100
Message-Id: <1497349722-6731-4-git-send-email-will.deacon@arm.com>
In-Reply-To: <1497349722-6731-1-git-send-email-will.deacon@arm.com>
References: <1497349722-6731-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: mark.rutland@arm.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, Punit.Agrawal@arm.com, mgorman@suse.de, steve.capper@arm.com, vbabka@suse.cz, Will Deacon <will.deacon@arm.com>

When migrating a transparent hugepage, migrate_misplaced_transhuge_page
guards itself against a concurrent fastgup of the page by checking that
the page count is equal to 2 before and after installing the new pmd.

If the page count changes, then the pmd is reverted back to the original
entry, however there is a small window where the new (possibly writable)
pmd is installed and the underlying page could be written by userspace.
Restoring the old pmd could therefore result in loss of data.

This patch fixes the problem by freezing the page count whilst updating
the page tables, which protects against a concurrent fastgup without the
need to restore the old pmd in the failure case (since the page count can
no longer change under our feet).

Cc: Mel Gorman <mgorman@suse.de>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Will Deacon <will.deacon@arm.com>
---
 mm/migrate.c | 15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 89a0a1707f4c..8b21f1b1ec6e 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1913,7 +1913,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	int page_lru = page_is_file_cache(page);
 	unsigned long mmun_start = address & HPAGE_PMD_MASK;
 	unsigned long mmun_end = mmun_start + HPAGE_PMD_SIZE;
-	pmd_t orig_entry;
 
 	/*
 	 * Rate-limit the amount of data that is being migrated to a node.
@@ -1956,8 +1955,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	/* Recheck the target PMD */
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 	ptl = pmd_lock(mm, pmd);
-	if (unlikely(!pmd_same(*pmd, entry) || page_count(page) != 2)) {
-fail_putback:
+	if (unlikely(!pmd_same(*pmd, entry) || !page_ref_freeze(page, 2))) {
 		spin_unlock(ptl);
 		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 
@@ -1979,7 +1977,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 		goto out_unlock;
 	}
 
-	orig_entry = *pmd;
 	entry = mk_huge_pmd(new_page, vma->vm_page_prot);
 	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 
@@ -1996,15 +1993,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
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
-
+	page_ref_unfreeze(page, 2);
 	mlock_migrate_page(new_page, page);
 	page_remove_rmap(page, true);
 	set_page_owner_migrate_reason(new_page, MR_NUMA_MISPLACED);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
