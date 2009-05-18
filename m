Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E1F9D6B005C
	for <linux-mm@kvack.org>; Sun, 17 May 2009 23:49:02 -0400 (EDT)
Date: Mon, 18 May 2009 11:49:07 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/4] zone_reclaim_mode is always 0 by default
Message-ID: <20090518034907.GF5869@localhost>
References: <20090513120155.5879.A69D9226@jp.fujitsu.com> <20090513120729.5885.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090513120729.5885.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, "Zhang, Yanmin" <yanmin.zhang@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 13, 2009 at 12:08:12PM +0900, KOSAKI Motohiro wrote:
> Subject: [PATCH] zone_reclaim_mode is always 0 by default
> 
> Current linux policy is, if the machine has large remote node distance,
>  zone_reclaim_mode is enabled by default because we've be able to assume to 
> large distance mean large server until recently.
> 
> Unfrotunately, recent modern x86 CPU (e.g. Core i7, Opeteron) have P2P transport
> memory controller. IOW it's NUMA from software view.
> 
> Some Core i7 machine has large remote node distance and zone_reclaim don't
> fit desktop and small file server. it cause performance degression.

I can confirm this, Yanmin recently ran into exactly such a
regression, which was fixed by manually disabling the zone reclaim
mode. So I guess you can safely add an

Tested-by: "Zhang, Yanmin" <yanmin.zhang@intel.com>

> Thus, zone_reclaim == 0 is better by default. sorry, HPC gusy. 
> you need to turn zone_reclaim_mode on manually now.
 
I guess the borderline will continue to blur up. It will be more
dependent on workloads instead of physical NUMA capabilities. So

Acked-by: Wu Fengguang <fengguang.wu@intel.com> 

> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Cc: Rik van Riel <riel@redhat.com>
> ---
>  mm/page_alloc.c |    7 -------
>  1 file changed, 7 deletions(-)
> 
> Index: b/mm/page_alloc.c
> ===================================================================
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2494,13 +2494,6 @@ static void build_zonelists(pg_data_t *p
>  		int distance = node_distance(local_node, node);
>  
>  		/*
> -		 * If another node is sufficiently far away then it is better
> -		 * to reclaim pages in a zone before going off node.
> -		 */
> -		if (distance > RECLAIM_DISTANCE)
> -			zone_reclaim_mode = 1;
> -
> -		/*
>  		 * We don't want to pressure a particular node.
>  		 * So adding penalty to the first node in same
>  		 * distance group to make it round-robin.
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
