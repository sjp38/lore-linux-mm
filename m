Date: Mon, 4 Dec 2006 11:30:51 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Add __GFP_MOVABLE for callers to flag allocations that
 may be migrated
Message-Id: <20061204113051.4e90b249.akpm@osdl.org>
In-Reply-To: <20061204140747.GA21662@skynet.ie>
References: <20061130170746.GA11363@skynet.ie>
	<20061130173129.4ebccaa2.akpm@osdl.org>
	<Pine.LNX.4.64.0612010948320.32594@skynet.skynet.ie>
	<20061201110103.08d0cf3d.akpm@osdl.org>
	<20061204140747.GA21662@skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: clameter@sgi.com, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 4 Dec 2006 14:07:47 +0000
mel@skynet.ie (Mel Gorman) wrote:

> o copy_strings() and variants are no longer setting the flag as the pages
>   are not obviously movable when I took a much closer look.
> 
> o The arch function alloc_zeroed_user_highpage() is now called
>   __alloc_zeroed_user_highpage and takes flags related to
>   movability that will be applied.  alloc_zeroed_user_highpage()
>   calls __alloc_zeroed_user_highpage() with no additional flags to
>   preserve existing behavior of the API for out-of-tree users and
>   alloc_zeroed_user_highpage_movable() sets the __GFP_MOVABLE flag.
> 
> o new_inode() documents that it uses GFP_HIGH_MOVABLE and callers are expected
>   to call mapping_set_gfp_mask() if that is not suitable.

umm, OK.  Could we please have some sort of statement pinning down the
exact semantics of __GFP_MOVABLE, and what its envisaged applications are?

My concern is that __GFP_MOVABLE is useful for fragmentation-avoidance, but
useless for memory hot-unplug.  So that if/when hot-unplug comes along
we'll add more gunk which is a somewhat-superset of the GFP_MOVABLE
infrastructure, hence we didn't need the GFP_MOVABLE code.  Or something.

That depends on how we do hot-unplug, if we do it.  I continue to suspect
that it'll be done via memory zones: effectively by resurrecting
GFP_HIGHMEM.  In which case there's little overlap with anti-frag.  (btw, I
have a suspicion that the most important application of memory hot-unplug
will be power management: destructively turning off DIMMs).

I'd also like to pin down the situation with lumpy-reclaim versus
anti-fragmentation.  No offence, but I would of course prefer to avoid
merging the anti-frag patches simply based on their stupendous size.  It
seems to me that lumpy-reclaim is suitable for the e1000 problem, but
perhaps not for the hugetlbpage problem.  Whereas anti-fragmentation adds
vastly more code, but can address both problems?  Or something.

IOW: big-picture where-do-we-go-from-here stuff.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
