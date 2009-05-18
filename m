Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0D8A46B005A
	for <linux-mm@kvack.org>; Sun, 17 May 2009 23:34:58 -0400 (EDT)
Date: Mon, 18 May 2009 11:35:14 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/4] vmscan: zone_reclaim use may_swap
Message-ID: <20090518033514.GE5869@localhost>
References: <20090513120155.5879.A69D9226@jp.fujitsu.com> <20090513120651.5882.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090513120651.5882.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 13, 2009 at 12:07:30PM +0900, KOSAKI Motohiro wrote:
> Subject: [PATCH] vmscan: zone_reclaim use may_swap
> 
> Documentation/sysctl/vm.txt says
> 
> 	zone_reclaim_mode:
> 
> 	Zone_reclaim_mode allows someone to set more or less aggressive approaches to
> 	reclaim memory when a zone runs out of memory. If it is set to zero then no
> 	zone reclaim occurs. Allocations will be satisfied from other zones / nodes
> 	in the system.
> 
> 	This is value ORed together of
> 
> 	1	= Zone reclaim on
> 	2	= Zone reclaim writes dirty pages out
> 	4	= Zone reclaim swaps pages
> 
> 
> So, "(zone_reclaim_mode & RECLAIM_SWAP) == 0" mean we don't want to reclaim
> swap-backed pages. not mapped file.
> 
> Thus, may_swap is better than may_unmap.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Cc: Rik van Riel <riel@redhat.com>
> ---
>  mm/vmscan.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> Index: b/mm/vmscan.c
> ===================================================================
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2387,8 +2387,8 @@ static int __zone_reclaim(struct zone *z
>  	int priority;
>  	struct scan_control sc = {
>  		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
> -		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
> -		.may_swap = 1,
> +		.may_unmap = 1,
> +		.may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
>  		.swap_cluster_max = max_t(unsigned long, nr_pages,
>  					SWAP_CLUSTER_MAX),
>  		.gfp_mask = gfp_mask,
> 

Acked-by: Wu Fengguang <fengguang.wu@intel.com> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
