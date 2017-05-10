Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75E32280842
	for <linux-mm@kvack.org>; Wed, 10 May 2017 04:38:47 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 44so6178196wry.5
        for <linux-mm@kvack.org>; Wed, 10 May 2017 01:38:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p53si2560628wrc.129.2017.05.10.01.38.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 May 2017 01:38:46 -0700 (PDT)
Date: Wed, 10 May 2017 10:38:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Patch v2] mm/vmscan: fix unsequenced modification and access
 warning
Message-ID: <20170510083844.GG31466@dhcp22.suse.cz>
References: <20170510071511.GA31466@dhcp22.suse.cz>
 <20170510082734.2055-1-nick.desaulniers@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170510082734.2055-1-nick.desaulniers@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Desaulniers <nick.desaulniers@gmail.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 10-05-17 01:27:34, Nick Desaulniers wrote:
> Clang flags this file with the -Wunsequenced error that GCC does not
> have.
> 
> unsequenced modification and access to 'gfp_mask'
> 
> It seems that gfp_mask is both read and written without a sequence point
> in between, which is undefined behavior.
> 
> Signed-off-by: Nick Desaulniers <nick.desaulniers@gmail.com>

I will definitely not object to the patch as the code is cleaner and less tricky.
You can add
Acked-by: Michal Hocko <mhocko@suse.com>

But I
still do not understand which part of the code is undefined and why. My
reading and understanding of the C specification is that
struct A {
	int a;
	int b;
};

struct A f = { .a = c = foo(c), .b = c};

as long as foo(c) doesn't have any side effects because because .a is
initialized before b and the assignment ordering will make sure that c
is initialized before a.

6.7.8 par 19 (ISO/IEC 9899)
19 The initialization shall occur in initializer list order, each
   initializer provided for a particular subobject overriding any
   previously listed initializer for the same subobject; all subobjects
   that are not initialized explicitly shall be initialized implicitly
   the same as objects that have static storage duration.

So is my understanding of the specification wrong or is this a bug in
-Wunsequenced in Clang?

> ---
> Changes in v2:
> - don't assign back to gfp_mask, reuse sc.gfp_mask
> - initialize reclaim_idx directly, without classzone_idx
> 
>  mm/vmscan.c | 13 ++++++-------
>  1 file changed, 6 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 4e7ed65842af..d32c42d17935 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2958,7 +2958,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>  	unsigned long nr_reclaimed;
>  	struct scan_control sc = {
>  		.nr_to_reclaim = SWAP_CLUSTER_MAX,
> -		.gfp_mask = (gfp_mask = current_gfp_context(gfp_mask)),
> +		.gfp_mask = current_gfp_context(gfp_mask),
>  		.reclaim_idx = gfp_zone(gfp_mask),
>  		.order = order,
>  		.nodemask = nodemask,
> @@ -2973,12 +2973,12 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>  	 * 1 is returned so that the page allocator does not OOM kill at this
>  	 * point.
>  	 */
> -	if (throttle_direct_reclaim(gfp_mask, zonelist, nodemask))
> +	if (throttle_direct_reclaim(sc.gfp_mask, zonelist, nodemask))
>  		return 1;
>  
>  	trace_mm_vmscan_direct_reclaim_begin(order,
>  				sc.may_writepage,
> -				gfp_mask,
> +				sc.gfp_mask,
>  				sc.reclaim_idx);
>  
>  	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
> @@ -3763,16 +3763,15 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
>  	const unsigned long nr_pages = 1 << order;
>  	struct task_struct *p = current;
>  	struct reclaim_state reclaim_state;
> -	int classzone_idx = gfp_zone(gfp_mask);
>  	struct scan_control sc = {
>  		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
> -		.gfp_mask = (gfp_mask = current_gfp_context(gfp_mask)),
> +		.gfp_mask = current_gfp_context(gfp_mask),
>  		.order = order,
>  		.priority = NODE_RECLAIM_PRIORITY,
>  		.may_writepage = !!(node_reclaim_mode & RECLAIM_WRITE),
>  		.may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
>  		.may_swap = 1,
> -		.reclaim_idx = classzone_idx,
> +		.reclaim_idx = gfp_zone(gfp_mask),
>  	};
>  
>  	cond_resched();
> @@ -3782,7 +3781,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
>  	 * and RECLAIM_UNMAP.
>  	 */
>  	p->flags |= PF_MEMALLOC | PF_SWAPWRITE;
> -	lockdep_set_current_reclaim_state(gfp_mask);
> +	lockdep_set_current_reclaim_state(sc.gfp_mask);
>  	reclaim_state.reclaimed_slab = 0;
>  	p->reclaim_state = &reclaim_state;
>  
> -- 
> 2.11.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
