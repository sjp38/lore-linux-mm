Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id E12DC6B002B
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 04:14:33 -0400 (EDT)
Date: Fri, 10 Aug 2012 09:14:28 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/6] mm: vmscan: Scale number of pages reclaimed by
 reclaim/compaction based on failures
Message-ID: <20120810081428.GL12690@suse.de>
References: <1344342677-5845-3-git-send-email-mgorman@suse.de>
 <20120808014824.GB4247@bbox>
 <20120808075526.GI29814@suse.de>
 <20120808082738.GF4247@bbox>
 <20120808085112.GJ29814@suse.de>
 <20120808235127.GA17835@bbox>
 <20120809074949.GA12690@suse.de>
 <20120809082715.GA19802@bbox>
 <20120809092035.GD12690@suse.de>
 <50241DC5.7090704@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <50241DC5.7090704@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Minchan Kim <minchan@kernel.org>, Linux-MM <linux-mm@kvack.org>, Jim Schutt <jaschut@sandia.gov>, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 09, 2012 at 04:29:57PM -0400, Rik van Riel wrote:
> On 08/09/2012 05:20 AM, Mel Gorman wrote:
> 
> >The intention is that an allocation can fail but each subsequent attempt will
> >try harder until there is success. Each allocation request does a portion
> >of the necessary work to spread the cost between multiple requests.
> 
> At some point we need to stop doing that work, though.
> 
> Otherwise we could end up back at the problem where
> way too much memory gets evicted, and we get swap
> storms.

That's the case without this patch as it'll still be running
reclaim/compaction just less aggressively. For it to continually try like
the system must be either continually under load preventing compaction ever
working (which may be undesirable for order-3 and the like) or so badly
fragmented it cannot recover (not aware of a situation where this happened).

You could add a separate patch that checked if
defer_shift == COMPACT_MAX_DEFER_SHIFT and to disable reclaim/compaction in
that case but that will require enough SWAP_CLUSTER_MAX pages to be reclaimed
over time or a large process to exit before compaction succeeds again.

I would expect rates under load to be very low with such a patch
applied.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
