Message-ID: <3AB77311.77EB7D60@uow.edu.au>
Date: Wed, 21 Mar 2001 02:11:13 +1100
From: Andrew Morton <andrewm@uow.edu.au>
MIME-Version: 1.0
Subject: Re: 3rd version of R/W mmap_sem patch available
References: <Pine.LNX.4.33.0103192254130.1320-100000@duckman.distro.conectiva> <Pine.LNX.4.31.0103191839510.1003-100000@penguin.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> There is a 2.4.3-pre5 in the test-directory on ftp.kernel.org.
> 

I stared long and hard at expand_stack().  Its first access
to vma->vm_start appears to be safe wrt other threads which 
can alter this, but perhaps the page_table_lock should be
acquired earlier here?



We now have:

	free_pgd_slow();
	pmd_free_slow();
	pte_free_slow();

Could we please have consistent naming back?



in do_wp_page():

        spin_unlock(&mm->page_table_lock);
        new_page = alloc_page(GFP_HIGHUSER);
        if (!new_page)
                return -1;
        spin_lock(&mm->page_table_lock);

Should retake the spinlock before returning.



General comment: an expensive part of a pagefault
is zeroing the new page.  It'd be nice if we could
drop the page_table_lock while doing the clear_user_page()
and, if possible, copy_user_page() functions.  Very nice.




read_zero_pagealigned()->zap_page_range()

	The handling of mm->rss is racy.  But I think
	it always has been?




This comment in mprotect.c:
+       /* XXX: maybe this could be down_read ??? - Rik */

I don't think so.  The decisions about where in the 
vma tree to place the new vma would be unprotected and racy.



Apart from that - I looked at it (x86-only) very closely and
it seems solid.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
