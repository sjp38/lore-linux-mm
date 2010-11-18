Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 99B406B0089
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 08:19:33 -0500 (EST)
Date: Thu, 18 Nov 2010 13:19:17 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 29 of 66] don't alloc harder for gfp nomemalloc even if
	nowait
Message-ID: <20101118131917.GS8135@csn.ul.ie>
References: <patchbomb.1288798055@v2.random> <ed6c78af29bc105fcee3.1288798084@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <ed6c78af29bc105fcee3.1288798084@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 03, 2010 at 04:28:04PM +0100, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Not worth throwing away the precious reserved free memory pool for allocations
> that can fail gracefully (either through mempool or because they're transhuge
> allocations later falling back to 4k allocations).
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Acked-by: Rik van Riel <riel@redhat.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

> ---
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1941,7 +1941,12 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
>  	alloc_flags |= (__force int) (gfp_mask & __GFP_HIGH);
>  
>  	if (!wait) {
> -		alloc_flags |= ALLOC_HARDER;
> +		/*
> +		 * Not worth trying to allocate harder for
> +		 * __GFP_NOMEMALLOC even if it can't schedule.
> +		 */
> +		if  (!(gfp_mask & __GFP_NOMEMALLOC))
> +			alloc_flags |= ALLOC_HARDER;
>  		/*
>  		 * Ignore cpuset if GFP_ATOMIC (!wait) rather than fail alloc.
>  		 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
