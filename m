Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id EFB566B01B9
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 20:06:56 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2O06sO9005692
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 24 Mar 2010 09:06:54 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EBE4145DE50
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 09:06:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CBCC245DE4E
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 09:06:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AB5BFE38003
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 09:06:53 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 544F41DB8038
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 09:06:53 +0900 (JST)
Date: Wed, 24 Mar 2010 09:03:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 05/11] Export unusable free space index via
 /proc/unusable_index
Message-Id: <20100324090312.4e1cc725.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1269347146-7461-6-git-send-email-mel@csn.ul.ie>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie>
	<1269347146-7461-6-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Mar 2010 12:25:40 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> Unusable free space index is a measure of external fragmentation that
> takes the allocation size into account. For the most part, the huge page
> size will be the size of interest but not necessarily so it is exported
> on a per-order and per-zone basis via /proc/unusable_index.
> 
> The index is a value between 0 and 1. It can be expressed as a
> percentage by multiplying by 100 as documented in
> Documentation/filesystems/proc.txt.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> ---
>  Documentation/filesystems/proc.txt |   13 ++++-
>  mm/vmstat.c                        |  120 +++++++++++++++++++++++++++++++++
>  2 files changed, 132 insertions(+), 1 deletions(-)
> 
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> index 5e132b5..5c4b0fb 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -452,6 +452,7 @@ Table 1-5: Kernel info in /proc
>   sys         See chapter 2                                     
>   sysvipc     Info of SysVIPC Resources (msg, sem, shm)		(2.4)
>   tty	     Info of tty drivers
> + unusable_index Additional page allocator information (see text)(2.5)
>   uptime      System uptime                                     
>   version     Kernel version                                    
>   video	     bttv info of video resources			(2.4)
> @@ -609,7 +610,7 @@ ZONE_DMA, 4 chunks of 2^1*PAGE_SIZE in ZONE_DMA, 101 chunks of 2^4*PAGE_SIZE
>  available in ZONE_NORMAL, etc... 
>  
>  More information relevant to external fragmentation can be found in
> -pagetypeinfo.
> +pagetypeinfo and unusable_index
>  
>  > cat /proc/pagetypeinfo
>  Page block order: 9
> @@ -650,6 +651,16 @@ unless memory has been mlock()'d. Some of the Reclaimable blocks should
>  also be allocatable although a lot of filesystem metadata may have to be
>  reclaimed to achieve this.
>  
> +> cat /proc/unusable_index
> +Node 0, zone      DMA 0.000 0.000 0.000 0.001 0.005 0.013 0.021 0.037 0.037 0.101 0.230
> +Node 0, zone   Normal 0.000 0.000 0.000 0.001 0.002 0.002 0.005 0.015 0.028 0.028 0.054
> +
> +The unusable free space index measures how much of the available free
> +memory cannot be used to satisfy an allocation of a given size and is a
> +value between 0 and 1. The higher the value, the more of free memory is
> +unusable and by implication, the worse the external fragmentation is. This
> +can be expressed as a percentage by multiplying by 100.
> +
>  ..............................................................................
>  
>  meminfo:
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 7f760cb..ca42e10 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -453,6 +453,106 @@ static int frag_show(struct seq_file *m, void *arg)
>  	return 0;
>  }
>  
> +
> +struct contig_page_info {
> +	unsigned long free_pages;
> +	unsigned long free_blocks_total;
> +	unsigned long free_blocks_suitable;
> +};
> +
> +/*
> + * Calculate the number of free pages in a zone, how many contiguous
> + * pages are free and how many are large enough to satisfy an allocation of
> + * the target size. Note that this function makes to attempt to estimate
> + * how many suitable free blocks there *might* be if MOVABLE pages were
> + * migrated. Calculating that is possible, but expensive and can be
> + * figured out from userspace
> + */
> +static void fill_contig_page_info(struct zone *zone,
> +				unsigned int suitable_order,
> +				struct contig_page_info *info)
> +{
> +	unsigned int order;
> +
> +	info->free_pages = 0;
> +	info->free_blocks_total = 0;
> +	info->free_blocks_suitable = 0;
> +
> +	for (order = 0; order < MAX_ORDER; order++) {
> +		unsigned long blocks;
> +
> +		/* Count number of free blocks */
> +		blocks = zone->free_area[order].nr_free;
> +		info->free_blocks_total += blocks;

....for what this free_blocks_total is ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
