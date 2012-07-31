Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 35F876B004D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 23:26:54 -0400 (EDT)
Received: by ggm4 with SMTP id 4so6633811ggm.14
        for <linux-mm@kvack.org>; Mon, 30 Jul 2012 20:26:53 -0700 (PDT)
Date: Mon, 30 Jul 2012 20:26:10 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: change nr_ptes BUG_ON to WARN_ON
Message-ID: <alpine.LSU.2.00.1207302017040.6310@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Meelis Roos <mroos@linux.ee>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

>From time to time an isolated BUG_ON(mm->nr_ptes) gets reported,
indicating that not all the page tables allocated could be found
and freed when exit_mmap() tore down the user address space.

There's usually nothing we can say about it, beyond that it's
probably a sign of some bad memory or memory corruption; though
it might still indicate a bug in vma or page table management
(and did recently reveal a race in THP, fixed a few months ago).

But one overdue change we can make is from BUG_ON to WARN_ON.

It's fairly likely that the system will crash shortly afterwards
in some other way (for example, the BUG_ON(page_mapped(page)) in
__delete_from_page_cache(), once an inode mapped into the lost
page tables gets evicted); but might tell us more before that.

Change the BUG_ON(page_mapped) to WARN_ON too?  Later perhaps:
I'm less eager, since that one has several times led to fixes.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/mmap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- v3.5/mm/mmap.c	2012-07-21 13:58:29.000000000 -0700
+++ linux/mm/mmap.c	2012-07-30 19:38:41.977203670 -0700
@@ -2310,7 +2310,7 @@ void exit_mmap(struct mm_struct *mm)
 	}
 	vm_unacct_memory(nr_accounted);
 
-	BUG_ON(mm->nr_ptes > (FIRST_USER_ADDRESS+PMD_SIZE-1)>>PMD_SHIFT);
+	WARN_ON(mm->nr_ptes > (FIRST_USER_ADDRESS+PMD_SIZE-1)>>PMD_SHIFT);
 }
 
 /* Insert vm structure into process list sorted by address

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
