Date: Fri, 4 Mar 2005 16:53:58 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: no page_cache_get in do_wp_page?
In-Reply-To: <Pine.LNX.4.58.0503031104500.9773@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.61.0503041631580.4758@goblin.wat.veritas.com>
References: <Pine.LNX.4.58.0503031104500.9773@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Thu, 3 Mar 2005, Christoph Lameter wrote:

> We do a page_cache_get in do_wp_page but we check the pte for changes later.

I remember it well(ish) - end of July 2001, 2.4.8-pre - my change.

> So why do a page_cache_get at all? Do the copy and maybe copy garbage and
> if the pte was changed forget about it. This avoids having to keep state
> for the page copied from.
> 
> Nick and I discussed this a few weeks ago and there were no further comments.

Sorry, I seem to have missed that discussion.

> Andrew thought that this need to be discussed in more detail.
> 
> So maybe there is a situation in which the pte
> can go away and then be restored to exactly the
> same value it had before?
> 
> The first action that would need to happen is that the swapper(?)
> clears the pte (and puts the page on the free lists?).
> 
> Then the same page with the same pte flags would have to be mapped to
> the same virtual address again but something significant about the page
> must have changed.

Exactly.  But for it to be a problem, there needs to be more.

You have to imagine the page is reused for some other purpose after
it's freed from here, gets unrelated data written into it, do_wp_page's
copy_user_highpage picks up some or all of that unrelated data, then
it's freed again and chosen for the very same pte slot as before,
all while the original do_wp_pager has dropped the page_table_lock.

Not your most likely race, and I'd find it hard to write an exploit ;)

But possible - or it was back then.  I have the ghost of a memory that
shortly afterwards some unrelated mod by bcrl independently fixed the
hole; but I can't see it now, perhaps that was in the -ac tree only.

> mmap and related stuff is all not possible because mmap_sem semaphore
> is held but the page_table_lock is dropped for for the allocation and
> the copy.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

Nacked-by: Hugh Dickins <hugh@veritas.com> !
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
