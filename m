Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 70E156B01AC
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 16:44:33 -0400 (EDT)
Date: Fri, 11 Jun 2010 21:44:11 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 5/6] vmscan: Write out ranges of pages contiguous to
	the inode where possible
Message-ID: <20100611204411.GD9946@csn.ul.ie>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie> <1275987745-21708-6-git-send-email-mel@csn.ul.ie> <20100610231045.7fcd6f9d.akpm@linux-foundation.org> <20100611124936.GB8798@csn.ul.ie> <20100611120730.26a29366.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100611120730.26a29366.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 11, 2010 at 12:07:30PM -0700, Andrew Morton wrote:
> On Fri, 11 Jun 2010 13:49:36 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > > It takes a large number of high-level
> > > VFS locks.  Locks which cannot be taken from deep within page reclaim
> > > without causing various deadlocks.
> > > 
> > 
> > Can you explain this a bit more please? I can see the inode_lock is very
> > important in this path for example but am not seeing how page reclaim taking
> > it would cause a deadlock.
> 
> iput_final() takes a lot more locks than inode_lock.  It can get down
> into truncate_inode_pages() and can run journal commits and does
> lock_page() and presumably takes i_mutex somewhere. 

i_mutex was something I failed to consider. I can see how that could
conceivably get deadlocked on if it was held when page reclaim was
entered and then direct reclaim later. I don't know if this actually
happens, but it's possible I guess.

> We'd need to check
> all the fs-specific ->clear_inode, ->delete_inode, maybe others.  It
> can do a synchronous write_inode_now() in generic_detach_inode().  We
> seem to run about half the kernel code under iput_final() :(
> 
> I don't recall specifically what deadlock was hitting, and being eight
> years ago it's not necessarily still there.
> 

I know now what to keep an eye out for at least. Thanks.

> > > I did solve that problem before reverting it all but I forget how.  By
> > > holding a page lock to pin the address_space rather than igrab(),
> > > perhaps. 
> > 
> > But this is what I did. That function has a list of locked pages. When I
> > call igrab(), the page is locked so the address_space should be pinned. I
> > unlock the page after I call igrab.
> 
> Right, so you end up with an inode/address_space which has no locked
> pages and on which you hold a refcount.  When that refcount gets
> dropped with iput(), the code can run iput_final().
> 
> <grovels around for a while>
> 
> OK, 2.5.48's mm/page-writeback.c has:
> 
> /*
>  * A library function, which implements the vm_writeback a_op.  It's fairly
>  * lame at this time.  The idea is: the VM wants to liberate this page,
>  * so we pass the page to the address_space and give the fs the opportunity
>  * to write out lots of pages around this one.  It allows extent-based
>  * filesytems to do intelligent things.  It lets delayed-allocate filesystems
>  * perform better file layout.  It lets the address_space opportunistically
>  * write back disk-contiguous pages which are in other zones.
>  *
>  * FIXME: the VM wants to start I/O against *this* page.  Because its zone
>  * is under pressure.  But this function may start writeout against a
>  * totally different set of pages.  Unlikely to be a huge problem, but if it
>  * is, we could just writepage the page if it is still (PageDirty &&
>  * !PageWriteback) (See below).
>  *
>  * Another option is to just reposition page->mapping->dirty_pages so we
>  * *know* that the page will be written.  That will work fine, but seems
>  * unpleasant.  (If the page is not for-sure on ->dirty_pages we're dead).
>  * Plus it assumes that the address_space is performing writeback in
>  * ->dirty_pages order.
>  *
>  * So.  The proper fix is to leave the page locked-and-dirty and to pass
>  * it all the way down.
>  */
> int generic_vm_writeback(struct page *page, struct writeback_control *wbc)
> {
> 	struct inode *inode = page->mapping->host;
> 
> 	/*
> 	 * We don't own this inode, and we don't want the address_space
> 	 * vanishing while writeback is walking its pages.
> 	 */
> 	inode = igrab(inode);
> 	unlock_page(page);
> 
> 	if (inode) {
> 		do_writepages(inode->i_mapping, wbc);
> 
> 		/*
> 		 * This iput() will internally call ext2_discard_prealloc(),
> 		 * which is rather bogus.  But there is no other way of
> 		 * dropping our ref to the inode.  However, there's no harm
> 		 * in dropping the prealloc, because there probably isn't any.
> 		 * Just a waste of cycles.
> 		 */
> 		iput(inode);
> #if 0
> 		if (!PageWriteback(page) && PageDirty(page)) {
> 			lock_page(page);
> 			if (!PageWriteback(page)&&test_clear_page_dirty(page)) {
> 				int ret;
> 
> 				ret = page->mapping->a_ops->writepage(page);
> 				if (ret == -EAGAIN)
> 					__set_page_dirty_nobuffers(page);
> 			} else {
> 				unlock_page(page);
> 			}
> 		}
> #endif
> 	}
> 	return 0;
> }
> 
> and that still uses igrab :(
> 
> I'm pretty sure I did fix this at some stage in some tree, don't recall
> where or how, but I think the fix involved not using igrab/iput, but
> instead ensuring that the code retained at least one locked page until
> it had finished touching the address_space.
> 

I'll do a further investigation again later divided into two parts.
First, if we still can hit this problem in theory and second, if
whatever way you fixed it in the past still works.

> > > Go take a look - it was somewhere between 2.5.1 and 2.5.10 if
> > > I vaguely recall correctly.
> > > 
> > > Or don't take a look - we shouldn't need to do any of this anyway.
> > > 
> > 
> > I'll take a closer look if there is real interest in having the VM use
> > writepages() but it sounds like it's a waste of time.
> 
> Well.  The main problem is that we're doing too much IO off the LRU of
> course.
> 

What would be considered "too much IO"? In the tests I was running, I know
I can sometimes get a chunk of dirty pages at the end of the LRU but it's
rare and under load. To trigger it with dd, 64 jobs had to be running which
in combination were writing files 4 times the tsize of physical memory. Even
then, it was kswapd that did much of the work as can be seen here

					traceonly stackreduce   nodirect
Direct reclaims                             4098     2436     5670 
Direct reclaim pages scanned              393664   215821   505483 
Direct reclaim write sync I/O                  0        0        0 
Direct reclaim write async I/O                 0        0        0 
Wake kswapd requests                      865097   728976  1036147 
Kswapd wakeups                               639      561      585 
Kswapd pages scanned                    11123648 10383929 10561818 
Kswapd reclaim write sync I/O                  0        0        0 
Kswapd reclaim write async I/O              3595        0    19068 
Time stalled direct reclaim              2843.74  2771.71    32.76 
Time kswapd awake                         347.58  8865.65   433.27 

What workload is considered most problematic? Next time, I'll also run a
read/write sysbench tests on postgres but each of these tests take a
long time to complete so it'd be nice to narrow it down.

The worst I saw was with large amounts of writeouts were during stress tests
for high-order allocations when lumpy reclaim is a big factor.  Otherwise,
it didn't seem too bad.

> But a secondary problem is that the pages which are coming off the LRU
> may not be well-ordered wrt their on-disk layout.  Seeky writes to a
> database will do this, as may seeky writes from /usr/bin/ld, etc.  And
> seeky metadata writes to /dev/sda1!  So writing in LRU-based ordering
> can generate crappy IO patterns.
> 

Based on the tests I've seen so far, databases are the most plausible
way of having dirty pages at the end of the LRU. Granted, if you load up
the machine with enough compile jobs and dd, you'll see dirty pages at
the end of the LRU too but that is hardly a surprise.

But by and large, what I've seen suggests that lumpy reclaim when it
happens is a source of writeback from page reclaim but otherwise it's
not a major problem.

> Doing a pgoff_t-based writearound around the target page was an attempt
> to straighten all that out.  And in some circumstances it really should
> provide large reductions in seek traffic, and would still be a good
> area of investigation.  But if we continue to submit IO in the order in
> which pages fall off the tail of the LRU, I don't think there's much to
> be gained in the area of improved IO patterns.  There might be CPU
> consumption benefits, doing less merging work in the block layer.
> 

Ok.

> > I'll focus on
> > 
> > a) identifying how many dirty pages the VM is really writing back with
> >    tracepoints
> > b) not using writepage from direct reclaim because it overflows the
> >    stack
> 
> OK.
> 
> This stuff takes a lot of time.  You see a blob of 1000 dirty pages
> fall off the tail of the LRU and then need to work out how the heck
> they got there and what could be done to prevent that, and to improve
> the clean-to-dirty ratio of those pages.
> 

Again, I'm not really seeing this pattern for the workloads I've tried
unless lumpy reclaim was a major factor. I'll see what sysbench shows
up.

> Obviously another appropach would be just to bisect the thing - write a
> little patch to backport /proc/vmstat:nr_vmscan_write into old kernels,
> pick a simple workload which causes "excessive" increments in
> nr_vmscan_write then go for it.  Bit of a PITA.
> 

I don't think it's feasible really. Even a basic test of this takes 4
hours to complete. Testing everything from 2.6.12 or doing a bisection
would be a woeful PITA.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
