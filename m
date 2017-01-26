Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A28426B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 15:58:28 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id yr2so42337272wjc.4
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 12:58:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b31si3355916wra.284.2017.01.26.12.58.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Jan 2017 12:58:27 -0800 (PST)
Date: Thu, 26 Jan 2017 20:58:24 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 5/5] mm: vmscan: move dirty pages out of the way until
 they're flushed
Message-ID: <20170126205824.fmc6favnij2lx5x7@suse.de>
References: <20170123181641.23938-1-hannes@cmpxchg.org>
 <20170123181641.23938-6-hannes@cmpxchg.org>
 <20170126101916.tmqa3hswtxfa6nsj@suse.de>
 <20170126200745.GC30636@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170126200745.GC30636@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Jan 26, 2017 at 03:07:45PM -0500, Johannes Weiner wrote:
> On Thu, Jan 26, 2017 at 10:19:16AM +0000, Mel Gorman wrote:
> > On Mon, Jan 23, 2017 at 01:16:41PM -0500, Johannes Weiner wrote:
> > > We noticed a performance regression when moving hadoop workloads from
> > > 3.10 kernels to 4.0 and 4.6. This is accompanied by increased pageout
> > > activity initiated by kswapd as well as frequent bursts of allocation
> > > stalls and direct reclaim scans. Even lowering the dirty ratios to the
> > > equivalent of less than 1% of memory would not eliminate the issue,
> > > suggesting that dirty pages concentrate where the scanner is looking.
> > 
> > Note that some of this is also impacted by
> > bbddabe2e436aa7869b3ac5248df5c14ddde0cbf because it can have the effect
> > of dirty pages reaching the end of the LRU sooner if they are being
> > written. It's not impossible that hadoop is rewriting the same files,
> > hitting the end of the LRU due to no reads and then throwing reclaim
> > into a hole.
> > 
> > I've seen a few cases where random write only workloads regressed and it
> > was based on whether the random number generator was selecting the same
> > pages. With that commit, the LRU was effectively LIFO.
> > 
> > Similarly, I'd seen a case where a databases whose working set was
> > larger than the shared memory area regressed because the spill-over from
> > the database buffer to RAM was not being preserved because it was all
> > rights. That said, the same patch prevents the database being swapped so
> > it's not all bad but there have been consequences.
> > 
> > I don't have a problem with the patch although would prefer to have seen
> > more data for the series. However, I'm not entirely convinced that
> > thrash detection was the only problem. I think not activating pages on
> > write was a contributing factor although this patch looks better than
> > considering reverting bbddabe2e436aa7869b3ac5248df5c14ddde0cbf.
> 
> We didn't backport this commit into our 4.6 kernel, so it couldn't
> have been a factor in our particular testing. But I will fully agree
> with you that this change probably exacerbates the problem.
> 

Ah, ok. I was not aware the patch couldn't have been part of what you
were seeing.

> Another example is the recent shrinking of the inactive list:
> 59dc76b0d4df ("mm: vmscan: reduce size of inactive file list"). That
> one we did in fact backport, after which the problem we were already
> debugging got worse. That was a good hint where the problem was:
> 
> Every time we got better at keeping the clean hot cache separated out
> on the active list, we increased the concentration of dirty pages on
> the inactive list.

Somewhat ironic because the improved separation increases the
chances of kswapd writing out pages and direct reclaimers stalling on
wait_iff_congested.

> Whether this is workingset.c activating refaulting
> pages, whether that's not activating writeback cache, or whether that
> is shrinking the inactive list size, they all worked toward exposing
> the same deficiency in the reclaim-writeback model: that waiting for
> writes is worse than potentially causing reads. That flaw has always
> been there - since we had wait_on_page_writeback() in the reclaim
> scanner and the split between inactive and active cache. It was just
> historically much harder to trigger problems like this in practice.
> 
> That's why this is a regression over a period of kernel development
> and cannot really be pinpointed to a specific commit.
> 

Understood.

> This patch, by straight-up putting dirty/writeback pages at the head
> of the combined page cache double LRU regardless of access frequency,
> is making an explicit update to the reclaim-writeback model to codify
> the trade-off between writes and potential refaults. Any alternative
> (implementation differences aside of course) would require regressing
> use-once separation to previous levels in some form.
> 
> The lack of data is not great, agreed as well. The thing I can say is
> that for the hadoop workloads - and this is a whole spectrum of jobs
> running on hundreds of machines in a test group over several days -
> this patch series restores average job completions, allocation stalls,
> amount of kswapd-initiated IO, sys% and iowait% to 3.10 levels - with
> a high confidence, and no obvious metric that could have regressed.
> 

That's fair enough. It's rarely the case that a regression in a complex
workload has a single root cause. If it was, bisections would always work.

> Is there something specific that you would like to see tested? Aside
> from trying that load with more civilized flusher wakeups in kswapd?

Nothing specific that I'll force on you. At some point I'll shove Chris's
simoop workload through it has it allegedly has similar propertys to what
you're seeing. I only got around to examining it last week to see how it
behaved. It was very obvious that between 4.4 and 4.9 it started writing
heavily from reclaim context. However, it had also stopped swappiing which
pointing towards the grab_cache_page_write() commit. Kswapd scan rates had
also doubled. Detailed examination of the stall stats showed extremely long
stalls. I expect these patches to have an impact and would be surprised
if they didn't.

Similarly, any random read/write workload that is write intensive might
also be interesting although that might just hit the dirty balancing limits
if not tuned properly.

A write-only sysbench would also be interesting. That is also a workload
that between 4.4 and 4.9 had regressed severely. Partly this was dirty
pages getting to the tail of the LRU and the other part was the random
number generator reusing some pages that the activations preserved. I
think your patches would at least mitigate the first problem.

If you have the chance to do any of them, it would be nice, but the
patches make enough sense from plain review. If I thought they were
shakier than I would make more of a fuss.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
