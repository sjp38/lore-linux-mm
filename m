Date: Tue, 23 May 2006 15:55:05 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: tracking dirty pages patches
In-Reply-To: <20060522132905.6e1a711c.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0605231454440.3700@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0605222022100.11067@blonde.wat.veritas.com>
 <20060522132905.6e1a711c.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrea Arcangeli <andrea@suse.de>, a.p.zijlstra@chello.nl, torvalds@osdl.org, dhowells@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 May 2006, Andrew Morton wrote:
> Hugh Dickins <hugh@veritas.com> wrote:
> > 
> > set_page_dirty has always (awkwardly) been liable to be called from
> > very low in the hierarchy; whereas you're assuming clear_page_dirty
> > is called from much higher up.  And in most cases there's no problem
> > (please cross-check to confirm that); but try_to_free_buffers in fs/
> > buffer.c calls it while holding mapping->private_lock - page_wrprotect
> > called from test_clear_page_dirty then violates the order.
> > 
> > If we're lucky and that is indeed the only violation, maybe Andrew
> > can recommend a change to try_to_free_buffers to avoid it: I have
> > no appreciation of the issues at that end myself.
> 
> I had troubles with that as well - tree_lock is a very "inner" lock.  So I
> moved test_clear_page_dirty()'s call to page_wrprotect() to be outside
> tree_lock.

Ah.  I've only been looking at versions after that good change.

> But I don't think you were referring to that

Correct.

>  - I am unable to evaluate your expression "the order".

Sorry.  The order shown in rmap.c goes:

 * mm->mmap_sem
 *   page->flags PG_locked (lock_page)
 *     mapping->i_mmap_lock
 *       anon_vma->lock
 *         mm->page_table_lock or pte_lock
 *           zone->lru_lock (in mark_page_accessed, isolate_lru_page)
 *           swap_lock (in swap_duplicate, swap_info_get)
 *             mmlist_lock (in mmput, drain_mmlist and others)
 *             mapping->private_lock (in __set_page_dirty_buffers)
 *             inode_lock (in set_page_dirty's __mark_inode_dirty)
 *               sb_lock (within inode_lock in fs/fs-writeback.c)
 *               mapping->tree_lock (widely used, in set_page_dirty,
 *                         in arch-dependent flush_dcache_mmap_lock,
 *                         within inode_lock in __sync_single_inode)

> The running of page_wrprotect_file() inside private_lock is a worry, yes. 
> We can move the clear_page_dirty() call in try_to_free_buffers() to be
> outside private_lock.

That would be great (for Peter) if you know it to be safe.

> But I don't know which particular ranking violation you've identified.

page_wrprotect and callees take i_mmap_lock and pte_lock,
neither of which should be taken while private_lock is held.

> > ...
> >
> > (Why does follow_page set_page_dirty at all?  I _think_ it's in case
> > the get_user_pages caller forgets to set_page_dirty when releasing.
> > But that's not how we usually write kernel code, to hide mistakes most
> > of the time,
> 
> Yes, that would be bad.

It would, but you've shown I was wrong in thinking that.

> > and your mods may change the balance there.  Andrew will
> > remember better whether that set_page_dirty has stronger justification.)
> 
> It was added by the below, which nobody was terribly happy with at the
> time.  (Took me 5-10 minutes to hunt this down.  Insert rote comment about
> comments).

Thanks so much for hunting it down, I should have done so myself.

I can well understand s390 looping on its always 0 pte_dirty test,
but very much agree with Nick: the real question then becomes,
what was the point of ever testing for pte_dirty there?
and why don't we just remove the whole
		if ((flags & FOLL_WRITE) &&
		    !pte_dirty(pte) && !PageDirty(page))
			set_page_dirty(page);
from follow_page?

That pte_dirty test first came in 2.4.4-final from
 - Andrea Arkangeli: raw-io fixes
I've just spent some frustrating hours thinking I'd be able to
explain why it was necessary in the old 2.4 context, but actually
I can't.  Vague memory of modifications vanishing under pressure
because of race when pte_dirty was not set; yet the page count is
raised without dropping page_table_lock, and mark_dirty_kiobuf was
introduced in the same patch, to set dirty before releasing.  I've
CC'ed Andrea, but it's a little (a lot!) unfair to expect him to
explain it now.

I do believe that dirty check now should be redundant.  But I
said "should be" not "is" because I still haven't fixed drivers/scsi
sg.c and st.c to use set_page_dirty_lock in place of SetPageDirty.

Last time I was preparing that patch, I got distracted by the over-
whelming feeling that it should be easier to do at interrupt time
(as sg.c needs), but failed to find a satisfying way.  I'd better
revisit that before trying to cut set_page_dirty from follow_page.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
