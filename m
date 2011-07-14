Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 7426B90011A
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 03:37:49 -0400 (EDT)
Date: Thu, 14 Jul 2011 08:37:42 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/5] Reduce filesystem writeback from page reclaim
 (again)
Message-ID: <20110714073742.GS7529@suse.de>
References: <1310567487-15367-1-git-send-email-mgorman@suse.de>
 <20110714003340.GZ23038@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110714003340.GZ23038@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Thu, Jul 14, 2011 at 10:33:40AM +1000, Dave Chinner wrote:
> On Wed, Jul 13, 2011 at 03:31:22PM +0100, Mel Gorman wrote:
> > (Revisting this from a year ago and following on from the thread
> > "Re: [PATCH 03/27] xfs: use write_cache_pages for writeback
> > clustering". Posting an prototype to see if anything obvious is
> > being missed)
> 
> Hi Mel,
> 
> Thanks for picking this up again. The results are definitely
> promising, but I'd like to see a comparison against simply not doing
> IO from memory reclaim at all combined with the enhancements in this
> patchset.

Convered elsewhere. In these tests we are already writing 0 pages so it
won't make a difference and I'm wary of eliminating writes entirely
unless kswapd has a way of priotising pages the flusher writes back
because of the risk of premature OOM kill.

> After all, that's what I keep asking for (so we can get
> rid of .writepage altogether), and if the numbers don't add up, then
> I'll shut up about it. ;)
> 

Christoph covered this.

> .....
> 
> > use-once LRU logic). The command line for fs_mark looked something like
> > 
> > ./fs_mark  -d  /tmp/fsmark-2676  -D  100  -N  150  -n  150  -L  25  -t  1  -S0  -s  10485760
> > 
> > The machine was booted with "nr_cpus=1 mem=512M" as according to Dave
> > this triggers the worst behaviour.
> ....
> > During testing, a number of monitors were running to gather information
> > from ftrace in particular. This disrupts the results of course because
> > recording the information generates IO in itself but I'm ignoring
> > that for the moment so the effect of the patches can be seen.
> > 
> > I've posted the raw reports for each filesystem at
> > 
> > http://www.csn.ul.ie/~mel/postings/reclaim-20110713/writeback-ext3/sandy/comparison.html
> > http://www.csn.ul.ie/~mel/postings/reclaim-20110713/writeback-ext4/sandy/comparison.html
> > http://www.csn.ul.ie/~mel/postings/reclaim-20110713/writeback-btrfs/sandy/comparison.html
> > http://www.csn.ul.ie/~mel/postings/reclaim-20110713/writeback-xfs/sandy/comparison.html
> .....
> > Average files per second is increased by a nice percentage albeit
> > just within the standard deviation. Consider the type of test this is,
> > variability was inevitable but will double check without monitoring.
> > 
> > The overhead (time spent in non-filesystem-related activities) is
> > reduced a *lot* and is a lot less variable.
> 
> Given that userspace is doing the same amount of work in all test
> runs, that implies that the userspace process is retaining it's
> working set hot in the cache over syscalls with this patchset.
> 

It's one possibility. The more likely one is that the fs_marks anonymous
pages are getting swapped out leading to variability. If IO is less
seeky as a result of the change, the swap in/outs would be faster.

> > Direct reclaim work is significantly reduced going from 37% of all
> > pages scanned to 1% with all patches applied. This implies that
> > processes are getting stalled less.
> 
> And that directly implicates page scanning during direct reclaim as
> the prime contributor to turfing the application's working set out
> of the CPU cache....
> 

It's a possibility.

> > Page writes by reclaim is what is motivating this series. It goes
> > from 14511 pages to 4084 which is a big improvement. We'll see later
> > if these were anonymous or file-backed pages.
> 
> Which were anon pages, so this is a major improvement. However,
> given that there were no dirty pages writen directly by memory
> reclaim, perhaps we don't need to do IO at all from here and
> throttling is all that is needed?  ;)
> 

I wouldn't bet my life on it due to potential premature OOM kill problem
if we cannot reclaim pages at all :)

> > Direct reclaim writes were never a problem according to this.
> 
> That's true. but we disable direct reclaim for other reasons, namely
> that writeback from direct reclaim blows the stack.
> 

Correct. I should have been clearer and said direct reclaim wasn't
a problem in terms of queueing pages for IO.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
