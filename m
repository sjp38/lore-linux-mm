Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id E8AC66B002C
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 06:04:08 -0500 (EST)
Date: Thu, 1 Mar 2012 12:04:04 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 5/9] writeback: introduce the pageout work
Message-ID: <20120301110404.GC4385@quack.suse.cz>
References: <20120228140022.614718843@intel.com>
 <20120228144747.198713792@intel.com>
 <20120228160403.9c9fa4dc.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120228160403.9c9fa4dc.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 28-02-12 16:04:03, Andrew Morton wrote:
...
> > --- linux.orig/mm/vmscan.c	2012-02-28 19:07:06.065064464 +0800
> > +++ linux/mm/vmscan.c	2012-02-28 20:26:15.559731455 +0800
> > @@ -874,12 +874,22 @@ static unsigned long shrink_page_list(st
> >  			nr_dirty++;
> >  
> >  			/*
> > -			 * Only kswapd can writeback filesystem pages to
> > -			 * avoid risk of stack overflow but do not writeback
> > -			 * unless under significant pressure.
> > +			 * Pages may be dirtied anywhere inside the LRU. This
> > +			 * ensures they undergo a full period of LRU iteration
> > +			 * before considering pageout. The intention is to
> > +			 * delay writeout to the flusher thread, unless when
> > +			 * run into a long segment of dirty pages.
> > +			 */
> > +			if (references == PAGEREF_RECLAIM_CLEAN &&
> > +			    priority == DEF_PRIORITY)
> > +				goto keep_locked;
> > +
> > +			/*
> > +			 * Try relaying the pageout I/O to the flusher threads
> > +			 * for better I/O efficiency and avoid stack overflow.
> >  			 */
> > -			if (page_is_file_cache(page) &&
> > -					(!current_is_kswapd() || priority >= DEF_PRIORITY - 2)) {
> > +			if (page_is_file_cache(page) && mapping &&
> > +			    queue_pageout_work(mapping, page) >= 0) {
> >  				/*
> >  				 * Immediately reclaim when written back.
> >  				 * Similar in principal to deactivate_page()
> > @@ -892,8 +902,13 @@ static unsigned long shrink_page_list(st
> >  				goto keep_locked;
> >  			}
> >  
> > -			if (references == PAGEREF_RECLAIM_CLEAN)
> > +			/*
> > +			 * Only kswapd can writeback filesystem pages to
> > +			 * avoid risk of stack overflow.
> > +			 */
> > +			if (page_is_file_cache(page) && !current_is_kswapd())
> 
> And here we run into big problems.
> 
> When a page-allocator enters direct reclaim, that process is trying to
> allocate a page from a particular zone (or set of zones).  For example,
> he wants a ZONE_NORMAL or ZONE_DMA page.  Asking flusher threads to go
> off and write back three gigabytes of ZONE_HIGHMEM is pointless,
> inefficient and doesn't fix the caller's problem at all.
> 
> This has always been the biggest problem with the
> avoid-writeback-from-direct-reclaim patches.  And your patchset (as far
> as I've read) doesn't address the problem at all and appears to be
> blissfully unaware of its existence.
> 
> 
> I've attempted versions of this I think twice, and thrown the patches
> away in disgust.  One approach I tried was, within direct reclaim, to
> grab the page I wanted (ie: one which is in one of the caller's desired
> zones) and to pass that page over to the kernel threads.  The kernel
> threads would ensure that this particular page was included in the
> writearound preparation.  So that we at least make *some* progress
> toward what the caller is asking us to do.
> 
> iirc, the way I "grabbed" the page was to actually lock it, with
> [try_]_lock_page().  And unlock it again way over within the writeback
> thread.  I forget why I did it this way, rather than get_page() or
> whatever.  Locking the page is a good way of preventing anyone else
> from futzing with it.  It also pins the inode, which perhaps meant that
> with careful management, I could avoid the igrab()/iput() horrors
> discussed above.
  I think using get_page() might be a good way to go. Naive implementation:
If we need to write a page from kswapd, we do get_page(), attach page to
wb_writeback_work and push it to flusher thread to deal with it.
Flusher thread sees the work, takes a page lock, verifies the page is still
attached to some inode & dirty (it could have been truncated / cleaned by
someone else) and if yes, it submits page for IO (possibly with some
writearound). This scheme won't have problems with iput() and won't have
problems with umount. Also we guarantee some progress - either flusher
thread does it, or some else must have done the work before flusher thread
got to it.

For better efficiency, we could further refine the scheme - record mapping
pointer (as an opaque cookie), starting index, and writeout length in
wb_writeback_work together with page pointer. That way if we need to
writeout another page, we can check whether it's not already included in an
existing work or whether extending existing work wouldn't be better. The
downside of this scheme is, that the progress guarantee isn't that strong
anymore - we guarantee that the page referenced from the work is cleaned
but not necessarily all those other pages that were bundled in the same
work item (because once our referenced page is cleaned, we cannot get to
inode anymore). To mitigate this, we could:
a) have references to N pages from work item and at most that many pages
to be packed into a single work - this restores the progress guarantee.
b) have references to N pages from work item but don't limit how many page
writeout requests are packed - isn't as strong as a) but lowers probability
of not enough progress. Also we could further lower the probability we
don't have a usable page reference in work item by including a reference
to a page whose writeout was last bundled to the work item.

What do you think?

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
