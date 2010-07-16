Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id EB959600921
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 06:26:16 -0400 (EDT)
Date: Fri, 16 Jul 2010 11:25:58 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/7] memcg: sc.nr_to_reclaim should be initialized
Message-ID: <20100716102557.GE13117@csn.ul.ie>
References: <20100716191006.7369.A69D9226@jp.fujitsu.com> <20100716191256.736C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100716191256.736C.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 16, 2010 at 07:13:31PM +0900, KOSAKI Motohiro wrote:
> Currently, mem_cgroup_shrink_node_zone() initialize sc.nr_to_reclaim as 0.
> It mean shrink_zone() only scan 32 pages and immediately return even if
> it doesn't reclaim any pages.
> 

Do you mean it immediately returns once one page is reclaimed? i.e. this
check

               if (nr_reclaimed >= nr_to_reclaim && priority < DEF_PRIORITY)
                        break;


> This patch fixes it.
> 

Otherwise it seems ok. It's unrelated to trace points though so should
be submitted on its own.

> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

> ---
>  mm/vmscan.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 1691ad0..bd1d035 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1932,6 +1932,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
>  						struct zone *zone, int nid)
>  {
>  	struct scan_control sc = {
> +		.nr_to_reclaim = SWAP_CLUSTER_MAX,
>  		.may_writepage = !laptop_mode,
>  		.may_unmap = 1,
>  		.may_swap = !noswap,
> -- 
> 1.6.5.2
> 
> 
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
