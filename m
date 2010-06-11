Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5D5556B01AC
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 15:08:14 -0400 (EDT)
Date: Fri, 11 Jun 2010 12:07:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/6] vmscan: Write out ranges of pages contiguous to the
 inode where possible
Message-Id: <20100611120730.26a29366.akpm@linux-foundation.org>
In-Reply-To: <20100611124936.GB8798@csn.ul.ie>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
	<1275987745-21708-6-git-send-email-mel@csn.ul.ie>
	<20100610231045.7fcd6f9d.akpm@linux-foundation.org>
	<20100611124936.GB8798@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 11 Jun 2010 13:49:36 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> > It takes a large number of high-level
> > VFS locks.  Locks which cannot be taken from deep within page reclaim
> > without causing various deadlocks.
> > 
> 
> Can you explain this a bit more please? I can see the inode_lock is very
> important in this path for example but am not seeing how page reclaim taking
> it would cause a deadlock.

iput_final() takes a lot more locks than inode_lock.  It can get down
into truncate_inode_pages() and can run journal commits and does
lock_page() and presumably takes i_mutex somewhere.  We'd need to check
all the fs-specific ->clear_inode, ->delete_inode, maybe others.  It
can do a synchronous write_inode_now() in generic_detach_inode().  We
seem to run about half the kernel code under iput_final() :(

I don't recall specifically what deadlock was hitting, and being eight
years ago it's not necessarily still there.

> > I did solve that problem before reverting it all but I forget how.  By
> > holding a page lock to pin the address_space rather than igrab(),
> > perhaps. 
> 
> But this is what I did. That function has a list of locked pages. When I
> call igrab(), the page is locked so the address_space should be pinned. I
> unlock the page after I call igrab.

Right, so you end up with an inode/address_space which has no locked
pages and on which you hold a refcount.  When that refcount gets
dropped with iput(), the code can run iput_final().

<grovels around for a while>

OK, 2.5.48's mm/page-writeback.c has:

/*
 * A library function, which implements the vm_writeback a_op.  It's fairly
 * lame at this time.  The idea is: the VM wants to liberate this page,
 * so we pass the page to the address_space and give the fs the opportunity
 * to write out lots of pages around this one.  It allows extent-based
 * filesytems to do intelligent things.  It lets delayed-allocate filesystems
 * perform better file layout.  It lets the address_space opportunistically
 * write back disk-contiguous pages which are in other zones.
 *
 * FIXME: the VM wants to start I/O against *this* page.  Because its zone
 * is under pressure.  But this function may start writeout against a
 * totally different set of pages.  Unlikely to be a huge problem, but if it
 * is, we could just writepage the page if it is still (PageDirty &&
 * !PageWriteback) (See below).
 *
 * Another option is to just reposition page->mapping->dirty_pages so we
 * *know* that the page will be written.  That will work fine, but seems
 * unpleasant.  (If the page is not for-sure on ->dirty_pages we're dead).
 * Plus it assumes that the address_space is performing writeback in
 * ->dirty_pages order.
 *
 * So.  The proper fix is to leave the page locked-and-dirty and to pass
 * it all the way down.
 */
int generic_vm_writeback(struct page *page, struct writeback_control *wbc)
{
	struct inode *inode = page->mapping->host;

	/*
	 * We don't own this inode, and we don't want the address_space
	 * vanishing while writeback is walking its pages.
	 */
	inode = igrab(inode);
	unlock_page(page);

	if (inode) {
		do_writepages(inode->i_mapping, wbc);

		/*
		 * This iput() will internally call ext2_discard_prealloc(),
		 * which is rather bogus.  But there is no other way of
		 * dropping our ref to the inode.  However, there's no harm
		 * in dropping the prealloc, because there probably isn't any.
		 * Just a waste of cycles.
		 */
		iput(inode);
#if 0
		if (!PageWriteback(page) && PageDirty(page)) {
			lock_page(page);
			if (!PageWriteback(page)&&test_clear_page_dirty(page)) {
				int ret;

				ret = page->mapping->a_ops->writepage(page);
				if (ret == -EAGAIN)
					__set_page_dirty_nobuffers(page);
			} else {
				unlock_page(page);
			}
		}
#endif
	}
	return 0;
}

and that still uses igrab :(

I'm pretty sure I did fix this at some stage in some tree, don't recall
where or how, but I think the fix involved not using igrab/iput, but
instead ensuring that the code retained at least one locked page until
it had finished touching the address_space.

> > Go take a look - it was somewhere between 2.5.1 and 2.5.10 if
> > I vaguely recall correctly.
> > 
> > Or don't take a look - we shouldn't need to do any of this anyway.
> > 
> 
> I'll take a closer look if there is real interest in having the VM use
> writepages() but it sounds like it's a waste of time.

Well.  The main problem is that we're doing too much IO off the LRU of
course.

But a secondary problem is that the pages which are coming off the LRU
may not be well-ordered wrt their on-disk layout.  Seeky writes to a
database will do this, as may seeky writes from /usr/bin/ld, etc.  And
seeky metadata writes to /dev/sda1!  So writing in LRU-based ordering
can generate crappy IO patterns.

Doing a pgoff_t-based writearound around the target page was an attempt
to straighten all that out.  And in some circumstances it really should
provide large reductions in seek traffic, and would still be a good
area of investigation.  But if we continue to submit IO in the order in
which pages fall off the tail of the LRU, I don't think there's much to
be gained in the area of improved IO patterns.  There might be CPU
consumption benefits, doing less merging work in the block layer.

> I'll focus on
> 
> a) identifying how many dirty pages the VM is really writing back with
>    tracepoints
> b) not using writepage from direct reclaim because it overflows the
>    stack

OK.

This stuff takes a lot of time.  You see a blob of 1000 dirty pages
fall off the tail of the LRU and then need to work out how the heck
they got there and what could be done to prevent that, and to improve
the clean-to-dirty ratio of those pages.

Obviously another appropach would be just to bisect the thing - write a
little patch to backport /proc/vmstat:nr_vmscan_write into old kernels,
pick a simple workload which causes "excessive" increments in
nr_vmscan_write then go for it.  Bit of a PITA.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
