Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7CE1F6B00A6
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 16:16:22 -0400 (EDT)
Received: from int-mx03.intmail.prod.int.phx2.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id n7PKGQmk028362
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 16:16:26 -0400
Date: Tue, 25 Aug 2009 17:22:17 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 13/12] ksm: fix munlock during exit_mmap deadlock
Message-ID: <20090825152217.GQ14722@random.random>
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
 <Pine.LNX.4.64.0908031317190.16754@sister.anvils>
 <20090825145832.GP14722@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090825145832.GP14722@random.random>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Izik Eidus <ieidus@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

We can't stop page faults from happening during exit_mmap or munlock
fails. The fundamental issue is the absolute lack of serialization
after mm_users reaches 0. mmap_sem should be hot in the cache as we
just released it a few nanoseconds before in exit_mm, we just need to
take it one last time after mm_users is 0 to allow drivers to
serialize safely against it so that taking mmap_sem and checking
mm_users > 0 is enough for ksm to serialize against exit_mmap while
still noticing when oom killer or something else wants to release all
memory of the mm. When ksm notices it bails out and it allows memory
to be released.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/kernel/fork.c b/kernel/fork.c
index 9a16c21..f5af0d3 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -515,7 +515,18 @@ void mmput(struct mm_struct *mm)
 
 	if (atomic_dec_and_test(&mm->mm_users)) {
 		exit_aio(mm);
+
+		/*
+		 * Allow drivers tracking mm without pinning mm_users
+		 * (so that mm_users is allowed to reach 0 while they
+		 * do their tracking) to serialize against exit_mmap
+		 * by taking mmap_sem and checking mm_users is still >
+		 * 0 before working on the mm they're tracking.
+		 */
+		down_read(&mm->mmap_sem);
+		up_read(&mm->mmap_sem);
 		exit_mmap(mm);
+
 		set_mm_exe_file(mm, NULL);
 		if (!list_empty(&mm->mmlist)) {
 			spin_lock(&mmlist_lock);
diff --git a/mm/memory.c b/mm/memory.c
index 4a2c60d..025431e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2603,7 +2603,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (!pte_none(*page_table) || ksm_test_exit(mm))
+	if (!pte_none(*page_table))
 		goto release;
 
 	inc_mm_counter(mm, anon_rss);
@@ -2753,7 +2753,7 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * handle that later.
 	 */
 	/* Only go through if we didn't race with anybody else... */
-	if (likely(pte_same(*page_table, orig_pte) && !ksm_test_exit(mm))) {
+	if (likely(pte_same(*page_table, orig_pte))) {
 		flush_icache_page(vma, page);
 		entry = mk_pte(page, vma->vm_page_prot);
 		if (flags & FAULT_FLAG_WRITE)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
