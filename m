Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1C8796B007B
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 10:38:06 -0500 (EST)
Received: by pwj7 with SMTP id 7so1302669pwj.14
        for <linux-mm@kvack.org>; Thu, 18 Feb 2010 07:38:04 -0800 (PST)
Subject: Re: [PATCH 04/12] Export fragmentation index via /proc/pagetypeinfo
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <1265976059-7459-5-git-send-email-mel@csn.ul.ie>
References: <1265976059-7459-1-git-send-email-mel@csn.ul.ie>
	 <1265976059-7459-5-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 19 Feb 2010 00:37:57 +0900
Message-ID: <1266507477.1709.225.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2010-02-12 at 12:00 +0000, Mel Gorman wrote:
> Fragmentation index is a value that makes sense when an allocation of a
> given size would fail. The index indicates whether an allocation failure is
> due to a lack of memory (values towards 0) or due to external fragmentation
> (value towards 1).  For the most part, the huge page size will be the size
> of interest but not necessarily so it is exported on a per-order and per-zone
> basis via /proc/pagetypeinfo.
> 
> The index is normally calculated as a value between 0 and 1 which is
> obviously unsuitable within the kernel. Instead, the first three decimal
> places are used as a value between 0 and 1000 for an integer approximation.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

> ---
>  Documentation/filesystems/proc.txt |   11 ++++++
>  mm/vmstat.c                        |   63 ++++++++++++++++++++++++++++++++++++
>  2 files changed, 74 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> index 0968a81..06bf53c 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -618,6 +618,10 @@ Unusable free space index at order
>  Node    0, zone      DMA                         0      0      0      2      6     18     34     67     99    227    485
>  Node    0, zone    DMA32                         0      0      1      2      4      7     10     17     23     31     34
>  
> +Fragmentation index at order
> +Node    0, zone      DMA                        -1     -1     -1     -1     -1     -1     -1     -1     -1     -1     -1
> +Node    0, zone    DMA32                        -1     -1     -1     -1     -1     -1     -1     -1     -1     -1     -1
> +
>  Number of blocks type     Unmovable  Reclaimable      Movable      Reserve      Isolate
>  Node 0, zone      DMA            2            0            5            1            0
>  Node 0, zone    DMA32           41            6          967            2            0
> @@ -639,6 +643,13 @@ value between 0 and 1000. The higher the value, the more of free memory is
>  unusable and by implication, the worse the external fragmentation is. The
>  percentage of unusable free memory can be found by dividing this value by 10.
>  
> +The fragmentation index, is only meaningful if an allocation would fail and
> +indicates what the failure is due to. A value of -1 such as in the example
> +states that the allocation would succeed. If it would fail, the value is
> +between 0 and 1000. A value tending towards 0 implies the allocation failed
> +due to a lack of memory. A value tending towards 1000 implies it failed
> +due to external fragmentation.
> +
>  If min_free_kbytes has been tuned correctly (recommendations made by hugeadm
>  from libhugetlbfs http://sourceforge.net/projects/libhugetlbfs/), one can
>  make an estimate of the likely number of huge pages that can be allocated
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index d05d610..e2d0cc1 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -494,6 +494,35 @@ static void fill_contig_page_info(struct zone *zone,
>  }
>  
>  /*
> + * A fragmentation index only makes sense if an allocation of a requested
> + * size would fail. If that is true, the fragmentation index indicates
> + * whether external fragmentation or a lack of memory was the problem.
> + * The value can be used to determine if page reclaim or compaction
> + * should be used
> + */
> +int fragmentation_index(struct zone *zone,

Like previous [3/12], why do you remain "zone" argument?
If you will use it in future, I don't care. It's just trivial. 

-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
