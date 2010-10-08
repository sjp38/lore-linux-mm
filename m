Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3B7BC6B006A
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 00:40:11 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id o984e8wE023819
	for <linux-mm@kvack.org>; Thu, 7 Oct 2010 21:40:09 -0700
Received: from pxi5 (pxi5.prod.google.com [10.243.27.5])
	by wpaz13.hot.corp.google.com with ESMTP id o984e277011763
	for <linux-mm@kvack.org>; Thu, 7 Oct 2010 21:40:06 -0700
Received: by pxi5 with SMTP id 5so295350pxi.40
        for <linux-mm@kvack.org>; Thu, 07 Oct 2010 21:40:02 -0700 (PDT)
Date: Thu, 7 Oct 2010 21:39:56 -0700
From: Michel Lespinasse <walken@google.com>
Subject: Re: [PATCH 2/3] Retry page fault when blocking on disk transfer.
Message-ID: <20101008043956.GA25662@google.com>
References: <1286265215-9025-1-git-send-email-walken@google.com>
 <1286265215-9025-3-git-send-email-walken@google.com>
 <4CAB628D.3030205@redhat.com>
 <AANLkTimdACZ9Xm01DM2+E64+T5XfLffrkFBhf7CJ286p@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTimdACZ9Xm01DM2+E64+T5XfLffrkFBhf7CJ286p@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm@kvack.org, Ying Han <yinghan@google.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 05, 2010 at 03:44:22PM -0700, Michel Lespinasse wrote:
> On Tue, Oct 5, 2010 at 10:38 AM, Rik van Riel <riel@redhat.com> wrote:
> > Looks like it should be relatively easy to do something
> > similar in do_swap_page also.
> 
> Good idea. We don't make use of swap too much, which is probably why
> we didn't have that in our kernel, but it seems like a good idea just
> for uniformity. I'll add this in a follow-on patch.

So here's the patch. Sorry for the delay - it did not take long to write,
but I couldn't test it before today.

Please have a look - I'd like to add this to the series I sent earlier.

----------------------------------- 8< ---------------------------------

Retry page fault when blocking on swap in

This change is the cousin of 'Retry page fault when blocking
on disk transfer'. The idea here is to reduce mmap_sem hold times
that are caused by disk transfers when swapping in pages. We drop
mmap_sem while waiting for the page lock, and return the VM_FAULT_RETRY
flag. do_page_fault will then re-acquire mmap_sem and retry the
page fault. It is expected that upon retry the page will now be cached,
and thus the retry will complete with a low mmap_sem hold time.

Signed-off-by: Michel Lespinasse <walken@google.com>

diff --git a/mm/memory.c b/mm/memory.c
index b068c68..0ec70b4 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2613,6 +2613,21 @@ int vmtruncate_range(struct inode *inode, loff_t offset, loff_t end)
 	return 0;
 }
 
+static inline int lock_page_or_retry(struct page *page, struct mm_struct *mm,
+				     unsigned int flags)
+{
+	if (trylock_page(page))
+		return 1;
+	if (!(flags & FAULT_FLAG_ALLOW_RETRY)) {
+		__lock_page(page);
+		return 1;
+	}
+
+	up_read(&mm->mmap_sem);
+	wait_on_page_locked(page);
+	return 0;
+}
+
 /*
  * We enter with non-exclusive mmap_sem (to exclude vma changes,
  * but allow concurrent faults), and pte mapped but not yet locked.
@@ -2626,6 +2641,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct page *page, *swapcache = NULL;
 	swp_entry_t entry;
 	pte_t pte;
+	int locked;
 	struct mem_cgroup *ptr = NULL;
 	int exclusive = 0;
 	int ret = 0;
@@ -2676,8 +2692,12 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto out_release;
 	}
 
-	lock_page(page);
+	locked = lock_page_or_retry(page, mm, flags);
 	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
+	if (!locked) {
+		ret |= VM_FAULT_RETRY;
+		goto out_release;
+	}
 
 	/*
 	 * Make sure try_to_free_swap or reuse_swap_page or swapoff did not


-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
