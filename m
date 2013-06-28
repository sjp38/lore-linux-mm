Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 27A996B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 18:15:11 -0400 (EDT)
Date: Sat, 29 Jun 2013 00:14:59 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 5/7] mm: compaction: increase the high order pages in the
 watermarks
Message-ID: <20130628221459.GA6120@redhat.com>
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com>
 <1370445037-24144-6-git-send-email-aarcange@redhat.com>
 <51AF9D1D.6030709@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51AF9D1D.6030709@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

On Wed, Jun 05, 2013 at 04:18:37PM -0400, Rik van Riel wrote:
> On 06/05/2013 11:10 AM, Andrea Arcangeli wrote:
> > Require more high order pages in the watermarks, to give more margin
> > for concurrent allocations. If there are too few pages, they can
> > disappear too soon.
> 
> Not sure what to do with this patch.
> 
> Not scaling min for pageblock_order-2 allocations seems like
> it could be excessive.
<
> Presumably this scaling was introduced for a good reason.

I think the reason is that even if we generate plenty of hugepages
they may be splitted to lower orders well before other hugepage
allocations will be invoked. So we risk doing too much work.

> 
> Why is that reason no longer valid?
> 
> Why is it safe to make this change?
> 
> Would it be safer to simply scale min less steeply?

This simply makes the scaling down for pageblock_order-1 equal to the
scaling of pageblock_order-2. So compaction will generate more
hugepages before stopping.

The larger the order size of the allocation and the more aggressive we
scale it down "min" for larger allocations, the fewer order pages
there will be within the low-min wmarks. this changes increases the
number of hugepages within low-min wmarks.

In my testing what happened with too few large order pages within the
low-min wmark, is that those few pages may be allocated or splitted to
lower orders well before the CPU doing the compaction has a chance to
allocate those. This patch made a difference in increasing the
reliability of a threaded workload running with CPU NODE pinning and
zone_reclaim_mode=1, and in turn it may be beneficial in general.

The patch simpy reduces the scaling factor, because having a few more
pages of margin between low-min wmarks is beneficial not just for 4k
pages but for any order size in presence of threads. The downside is
the risk of doing more compaction work but then nobody keeps
allocating hugepages.

> >   		/* Require fewer higher order pages to be free */
> > -		min >>= 1;
> > +		if (o >= pageblock_order-1)
> > +			min >>= 1;

On my laptop I get min:44764kB low:55952kB high:67144kB

scaling down like upstream we get:

order9 -> 218kb low wmark

not even 1 hugepage of buffer between low-min -> very unreliable.

with my patch:

order9 -> 27mbyte low wmark
order9 -> 22mbyte min wmark

2 hugepages of margin: at least a bit of margin with concurrent
allocations from different CPUs.

But this whole logic is wrong and needs to be improved further: it
makes no sense to have the min wmark scaled down to 22mbytes for order
9. The min must be scaled down way more aggressively and _differently_
than "low" for large order allocations. The "min" exists only for
PF_MEMALLOC and other emergency allocations, and those must never
require order > 0. Hence the min should shift down towards 0, while
"low" must not.

What I mean is that right now we generate just 1 hugepage, we should
generate 3 to have more margin for concurrent allocations, but not
22mbyte of hugepages that won't even have a chance to be used for
anything but PF_MEMALLOC paths that shouldn't depend on high order.

We still need plenty of free memory in the "min" wmark, but no
hugepage is ok in the min.

> Why this and not this?
> 
> 		if (order & 1)
> 			min >>=1;

I can test it but it would be less aggressive.

> Not saying my idea is any better than yours, just saying that
> a change like this needs more justification than provided by
> your changelog...

I'll improve the changelog and I'll try to improve the logic so that
it says reliable as with my patch but the min is scaled down more
aggressively in hugepage terms.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
