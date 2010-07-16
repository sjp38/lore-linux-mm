Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5CD396B02AA
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 07:21:28 -0400 (EDT)
Date: Fri, 16 Jul 2010 12:21:09 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 7/7] memcg: add mm_vmscan_memcg_isolate tracepoint
Message-ID: <20100716112109.GJ13117@csn.ul.ie>
References: <20100716191006.7369.A69D9226@jp.fujitsu.com> <20100716191739.737E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100716191739.737E.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 16, 2010 at 07:18:18PM +0900, KOSAKI Motohiro wrote:
> 
> Memcg also need to trace page isolation information as global reclaim.
> This patch does it.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  include/trace/events/vmscan.h |   15 +++++++++++++++
>  mm/memcontrol.c               |    7 +++++++
>  2 files changed, 22 insertions(+), 0 deletions(-)
> 
> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> index e37fe72..eefd399 100644
> --- a/include/trace/events/vmscan.h
> +++ b/include/trace/events/vmscan.h
> @@ -213,6 +213,21 @@ DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_lru_isolate,
>  
>  );
>  
> +DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_memcg_isolate,
> +
> +	TP_PROTO(int order,
> +		unsigned long nr_requested,

I just spotted that this is badly named by myself. It should have been
order.

> +		unsigned long nr_scanned,
> +		unsigned long nr_taken,
> +		unsigned long nr_lumpy_taken,
> +		unsigned long nr_lumpy_dirty,
> +		unsigned long nr_lumpy_failed,
> +		int isolate_mode),
> +
> +	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode)
> +
> +);
> +
>  TRACE_EVENT(mm_vmscan_writepage,
>  
>  	TP_PROTO(struct page *page,
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 81bc9bf..82e191f 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -52,6 +52,9 @@
>  
>  #include <asm/uaccess.h>
>  
> +#include <trace/events/vmscan.h>
> +
> +

Excessive whitespace there.

Otherwise, I didn't spot any problems.

>  struct cgroup_subsys mem_cgroup_subsys __read_mostly;
>  #define MEM_CGROUP_RECLAIM_RETRIES	5
>  struct mem_cgroup *root_mem_cgroup __read_mostly;
> @@ -1042,6 +1045,10 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
>  	}
>  
>  	*scanned = scan;
> +
> +	trace_mm_vmscan_memcg_isolate(0, nr_to_scan, scan, nr_taken,
> +				      0, 0, 0, mode);
> +
>  	return nr_taken;
>  }
>  
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
