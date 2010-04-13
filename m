Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6EBB96B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 11:48:43 -0400 (EDT)
Date: Tue, 13 Apr 2010 16:48:20 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/6] change alloc function in pcpu_alloc_pages
Message-ID: <20100413154820.GC25756@csn.ul.ie>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com> <d5d70d4b57376bc89f178834cf0e424eaa681ab4.1271171877.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <d5d70d4b57376bc89f178834cf0e424eaa681ab4.1271171877.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 12:24:59AM +0900, Minchan Kim wrote:
> alloc_pages_node is called with cpu_to_node(cpu).
> I think cpu_to_node(cpu) never returns -1.
> (But I am not sure we need double check.)
> 
> So we can use alloc_pages_exact_node instead of alloc_pages_node.
> It could avoid comparison and branch as 6484eb3e2a81807722 tried.
> 

Well, numa_node_id() is implemented as

#ifndef numa_node_id
#define numa_node_id()          (cpu_to_node(raw_smp_processor_id()))
#endif

and the mapping table on x86 at least is based on possible CPUs in
init_cpu_to_node() leaves the mapping as 0 if the APIC is bad or the numa
node is reported in apicid_to_node as -1. It would appear on power that
the node will be 0 for possible CPUs as well.

Hence, I believe this to be safe but a confirmation from Tejun would be
nice. I would continue digging but this looks like an initialisation path
so I'll move on to the next patch rather than spending more time.

> Cc: Tejun Heo <tj@kernel.org>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
>  mm/percpu.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/percpu.c b/mm/percpu.c
> index 768419d..ec3e671 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -720,7 +720,7 @@ static int pcpu_alloc_pages(struct pcpu_chunk *chunk,
>  		for (i = page_start; i < page_end; i++) {
>  			struct page **pagep = &pages[pcpu_page_idx(cpu, i)];
>  
> -			*pagep = alloc_pages_node(cpu_to_node(cpu), gfp, 0);
> +			*pagep = alloc_pages_exact_node(cpu_to_node(cpu), gfp, 0);
>  			if (!*pagep) {
>  				pcpu_free_pages(chunk, pages, populated,
>  						page_start, page_end);
> -- 
> 1.7.0.5
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
