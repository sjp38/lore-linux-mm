Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id CAF526B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 01:35:48 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id 33so872206pll.9
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 22:35:48 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id w9si763678pgp.493.2017.11.28.22.35.46
        for <linux-mm@kvack.org>;
        Tue, 28 Nov 2017 22:35:47 -0800 (PST)
Date: Wed, 29 Nov 2017 15:41:46 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm, compaction: direct freepage allocation for async
 direct compaction
Message-ID: <20171129064146.GD8125@js1304-P5Q-DELUXE>
References: <20171122143321.29501-1-hannes@cmpxchg.org>
 <32b5f1b6-e3aa-4f15-4ec6-5cbb5fe158d0@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <32b5f1b6-e3aa-4f15-4ec6-5cbb5fe158d0@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Nov 22, 2017 at 03:52:55PM +0100, Vlastimil Babka wrote:
> On 11/22/2017 03:33 PM, Johannes Weiner wrote:
> > From: Vlastimil Babka <vbabka@suse.cz>
> > 
> > The goal of direct compaction is to quickly make a high-order page available
> > for the pending allocation. The free page scanner can add significant latency
> > when searching for migration targets, although to succeed the compaction, the
> > only important limit on the target free pages is that they must not come from
> > the same order-aligned block as the migrated pages.
> > 
> > This patch therefore makes direct async compaction allocate freepages directly
> > from freelists. Pages that do come from the same block (which we cannot simply
> > exclude from the freelist allocation) are put on separate list and released
> > only after migration to allow them to merge.
> > 
> > In addition to reduced stall, another advantage is that we split larger free
> > pages for migration targets only when smaller pages are depleted, while the
> > free scanner can split pages up to (order - 1) as it encouters them. However,
> > this approach likely sacrifices some of the long-term anti-fragmentation
> > features of a thorough compaction, so we limit the direct allocation approach
> > to direct async compaction.
> > 
> > For observational purposes, the patch introduces two new counters to
> > /proc/vmstat. compact_free_direct_alloc counts how many pages were allocated
> > directly without scanning, and compact_free_direct_miss counts the subset of
> > these allocations that were from the wrong range and had to be held on the
> > separate list.
> > 
> > Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> > 
> > Hi. I'm resending this because we've been struggling with the cost of
> > compaction in our fleet, and this patch helps substantially.
> > 
> > On 128G+ machines, we have seen isolate_freepages_block() eat up 40%
> > of the CPU cycles and scanning up to a billion PFNs per minute. Not in
> > a spike, but continuously, to service higher-order allocations from
> > the network stack, fork (non-vmap stacks), THP, etc. during regular
> > operation.
> > 
> > I've been running this patch on a handful of less-affected but still
> > pretty bad machines for a week, and the results look pretty great:
> > 
> > 	http://cmpxchg.org/compactdirectalloc/compactdirectalloc.png
> 
> Thanks a lot, that's very encouraging!
> 
> > 
> > Note the two different scales - otherwise the compact_free_direct
> > lines wouldn't be visible. The free scanner peaks close to 10M pages
> > checked per minute, whereas the direct allocations peak at under 180
> > per minute, direct misses at 50.
> > 
> > The work doesn't increase over this period, which is a good sign that
> > long-term we're not trending toward worse fragmentation.
> > 
> > There was an outstanding concern from Joonsoo regarding this patch -
> > https://marc.info/?l=linux-mm&m=146035962702122&w=2 - although that
> > didn't seem to affect us much in practice.
> 
> That concern would be easy to fix, but I was also concerned that if there
> are multiple direct compactions in parallel, they might keep too many free
> pages isolated away. Recently I resumed work on this and come up with a
> different approach, where I put the pages immediately back on tail of
> free lists. There might be some downside in more "direct misses".
> Also I didn't plan to restrict this to async compaction anymore, because
> if it's a better way, we should use it everywhere. So here's how it
> looks like now (only briefly tested), we could compare and pick the better
> approach, or go with the older one for now and potentially change it later.

IMHO, "good bye free scanner" is a way to go. My major concern is that
co-existence of two different compaction algorithms make the system
behaviour less predictable and make debugging hard.

And, this compaction stall is immediate and actual problem reported
many times unlike theoretical long term fragmentation which current
freepage scanner try to prevent.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
