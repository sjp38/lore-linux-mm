Date: Tue, 20 Mar 2001 08:08:36 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: 3rd version of R/W mmap_sem patch available
In-Reply-To: <3AB77311.77EB7D60@uow.edu.au>
Message-ID: <Pine.LNX.4.31.0103200801480.1503-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <andrewm@uow.edu.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 21 Mar 2001, Andrew Morton wrote:
>
> I stared long and hard at expand_stack().  Its first access
> to vma->vm_start appears to be safe wrt other threads which
> can alter this, but perhaps the page_table_lock should be
> acquired earlier here?

Hmm.. Probably.

> We now have:
>
> 	free_pgd_slow();
> 	pmd_free_slow();
> 	pte_free_slow();
>
> Could we please have consistent naming back?

Yes, I want to rename free_pgd_slow() to match the others.

> in do_wp_page():
>
>         spin_unlock(&mm->page_table_lock);
>         new_page = alloc_page(GFP_HIGHUSER);
>         if (!new_page)
>                 return -1;
>         spin_lock(&mm->page_table_lock);
>
> Should retake the spinlock before returning.

Thanks, done.

> General comment: an expensive part of a pagefault
> is zeroing the new page.  It'd be nice if we could
> drop the page_table_lock while doing the clear_user_page()
> and, if possible, copy_user_page() functions.  Very nice.

I don't think it's worth it. We should have basically zero contention on
this lock now, and adding complexity to try to release it sounds like a
bad idea when the only way to make contention on it is (a) kswapd (only
when paging stuff out) and (b) multiple threads (only when taking
concurrent page faults).

So I don't really see the point of bothering.

> read_zero_pagealigned()->zap_page_range()
>
> 	The handling of mm->rss is racy.  But I think
> 	it always has been?

It always has been. Right now I think we hold the page_table_lock over
most of them, that the old patch to fix this might end up being just that
one place. Somebody interested in checking?

> This comment in mprotect.c:
> +       /* XXX: maybe this could be down_read ??? - Rik */
>
> I don't think so.  The decisions about where in the
> vma tree to place the new vma would be unprotected and racy.

I think we could potentially find it useful in places to have a

	down_write_start();

	down_write_commit();

in a few places, where "down_write_start()" only guarantees exclusion of
other writers (and write-startes), while down_write_commit() waits for all
the readers to go away.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
