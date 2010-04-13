Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1E8796B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 11:59:58 -0400 (EDT)
Date: Tue, 13 Apr 2010 16:59:37 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/6] change alloc function in vmemmap_alloc_block
Message-ID: <20100413155936.GE25756@csn.ul.ie>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com> <3108a367a27c55392904c3f046aa0b5420efe261.1271171877.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <3108a367a27c55392904c3f046aa0b5420efe261.1271171877.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 12:25:01AM +0900, Minchan Kim wrote:
> if node_state is N_HIGH_MEMORY, node doesn't have -1.

Also, if node_state is called with -1, a negative index is being checked in
a bitmap and that would be pretty broken in itself. I can't see a problem
with this patch.

Reviewed-by: Mel Gorman <mel@csn.ul.ie>

> It means node's validity check is unnecessary.
> So we can use alloc_pages_exact_node instead of alloc_pages_node.
> It could avoid comparison and branch as 6484eb3e2a81807722 tried.
> 
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
>  mm/sparse-vmemmap.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
> index 392b9bb..7710ebc 100644
> --- a/mm/sparse-vmemmap.c
> +++ b/mm/sparse-vmemmap.c
> @@ -53,7 +53,7 @@ void * __meminit vmemmap_alloc_block(unsigned long size, int node)
>  		struct page *page;
>  
>  		if (node_state(node, N_HIGH_MEMORY))
> -			page = alloc_pages_node(node,
> +			page = alloc_pages_exact_node(node,
>  				GFP_KERNEL | __GFP_ZERO, get_order(size));
>  		else
>  			page = alloc_pages(GFP_KERNEL | __GFP_ZERO,
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
