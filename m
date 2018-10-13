Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 55A676B0296
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 20:24:33 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id l75-v6so13270994qke.23
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 17:24:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a21-v6si955864qtp.98.2018.10.12.17.24.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 17:24:32 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/3] mm: thp: fix MADV_DONTNEED vs migrate_misplaced_transhuge_page race condition
Date: Fri, 12 Oct 2018 20:24:28 -0400
Message-Id: <20181013002430.698-2-aarcange@redhat.com>
In-Reply-To: <20181013002430.698-1-aarcange@redhat.com>
References: <20181013002430.698-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Aaron Tomlin <atomlin@redhat.com>, Mel Gorman <mgorman@suse.de>, Jerome Glisse <jglisse@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>

This is a corollary of ced108037c2aa542b3ed8b7afd1576064ad1362a,
58ceeb6bec86d9140f9d91d71a710e963523d063,
5b7abeae3af8c08c577e599dd0578b9e3ee6687b.

When the above three fixes where posted Dave asked
https://lkml.kernel.org/r/929b3844-aec2-0111-fef7-8002f9d4e2b9@intel.com
but apparently this was missed.

The pmdp_clear_flush* in migrate_misplaced_transhuge_page was
introduced in commit a54a407fbf7735fd8f7841375574f5d9b0375f93.

The important part of such commit is only the part where the page lock
is not released until the first do_huge_pmd_numa_page() finished
disarming the pagenuma/protnone.

The addition of pmdp_clear_flush() wasn't beneficial to such commit
and there's no commentary about such an addition either.

I guess the pmdp_clear_flush() in such commit was added just in case for
safety, but it ended up introducing the MADV_DONTNEED race condition
found by Aaron.

At that point in time nobody thought of such kind of MADV_DONTNEED
race conditions yet (they were fixed later) so the code may have
looked more robust by adding the pmdp_clear_flush().

This specific race condition won't destabilize the kernel, but it can
confuse userland because after MADV_DONTNEED the memory won't be
zeroed out.

This also optimizes the code and removes a superflous TLB flush.

Reported-by: Aaron Tomlin <atomlin@redhat.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/migrate.c | 26 +++++++++++++++++++-------
 1 file changed, 19 insertions(+), 7 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index d6a2e89b086a..180e3d0ed16d 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2082,15 +2082,27 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 
 	/*
-	 * Clear the old entry under pagetable lock and establish the new PTE.
-	 * Any parallel GUP will either observe the old page blocking on the
-	 * page lock, block on the page table lock or observe the new page.
-	 * The SetPageUptodate on the new page and page_add_new_anon_rmap
-	 * guarantee the copy is visible before the pagetable update.
+	 * Overwrite the old entry under pagetable lock and establish
+	 * the new PTE. Any parallel GUP will either observe the old
+	 * page blocking on the page lock, block on the page table
+	 * lock or observe the new page. The SetPageUptodate on the
+	 * new page and page_add_new_anon_rmap guarantee the copy is
+	 * visible before the pagetable update.
 	 */
 	flush_cache_range(vma, mmun_start, mmun_end);
 	page_add_anon_rmap(new_page, vma, mmun_start, true);
-	pmdp_huge_clear_flush_notify(vma, mmun_start, pmd);
+	/*
+	 * At this point the pmd is numa/protnone (i.e. non present)
+	 * and the TLB has already been flushed globally. So no TLB
+	 * can be currently caching this non present pmd mapping.
+	 * There's no need of clearing the pmd before doing
+	 * set_pmd_at(), nor to flush the TLB after
+	 * set_pmd_at(). Clearing the pmd here would introduce a race
+	 * condition against MADV_DONTNEED, beacuse MADV_DONTNEED only
+	 * holds the mmap_sem for reading. If the pmd is set to NULL
+	 * at any given time, MADV_DONTNEED won't wait on the pmd lock
+	 * and it'll skip clearing this pmd.
+	 */
 	set_pmd_at(mm, mmun_start, pmd, entry);
 	update_mmu_cache_pmd(vma, address, &entry);
 
@@ -2104,7 +2116,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	 * No need to double call mmu_notifier->invalidate_range() callback as
 	 * the above pmdp_huge_clear_flush_notify() did already call it.
 	 */
-	mmu_notifier_invalidate_range_only_end(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 
 	/* Take an "isolate" reference and put new page on the LRU. */
 	get_page(new_page);
