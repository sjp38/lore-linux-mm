Date: Sat, 11 Dec 2004 09:23:20 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: page fault scalability patch V12 [0/7]: Overview and performance
    tests
In-Reply-To: <20041210165745.38c1930e.akpm@osdl.org>
Message-ID: <Pine.LNX.4.44.0412110914280.1535-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: clameter@sgi.com, torvalds@osdl.org, benh@kernel.crashing.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 10 Dec 2004, Andrew Morton wrote:
> Hugh Dickins <hugh@veritas.com> wrote:
> > 
> > My inclination would be simply to remove the mark_page_accessed
> > from do_anonymous_page; but I have no numbers to back that hunch.
> 
> With the current implementation of page_referenced() the
> software-referenced bit doesn't matter anyway, as long as the pte's
> referenced bit got set.  So as long as the thing is on the active list, we
> can simply remove the mark_page_accessed() call.

Yes, you're right.  So we don't need numbers, can just delete that line.

> Except one day the VM might get smarter about pages which are both
> software-referenced and pte-referenced.

And on that day, we'd be making other changes, which might well
involve restoring the mark_page_accessed to do_anonymous_page
and adding it in the similar places which currently lack it.

But for now...

--- 2.6.10-rc3/mm/memory.c	2004-12-05 12:56:12.000000000 +0000
+++ linux/mm/memory.c	2004-12-11 09:18:39.000000000 +0000
@@ -1464,7 +1464,6 @@ do_anonymous_page(struct mm_struct *mm, 
 							 vma->vm_page_prot)),
 				      vma);
 		lru_cache_add_active(page);
-		mark_page_accessed(page);
 		page_add_anon_rmap(page, vma, addr);
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
