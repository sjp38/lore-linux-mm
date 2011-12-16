Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 13B396B004F
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 17:37:55 -0500 (EST)
Date: Fri, 16 Dec 2011 14:37:53 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] vmscan/trace: Add 'file' info to
 trace_mm_vmscan_lru_isolate.
Message-Id: <20111216143753.07588b01.akpm@linux-foundation.org>
In-Reply-To: <1323875693-3504-1-git-send-email-tm@tao.ma>
References: <20111213164507.fbee477c.akpm@linux-foundation.org>
	<1323875693-3504-1-git-send-email-tm@tao.ma>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tao Ma <tm@tao.ma>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Wed, 14 Dec 2011 23:14:53 +0800
Tao Ma <tm@tao.ma> wrote:

> From: Tao Ma <boyu.mt@taobao.com>
> 
> In trace_mm_vmscan_lru_isolate, we don't output 'file'
> information to the trace event and it is a bit inconvenient for the
> user to get the real information(like pasted below).
> mm_vmscan_lru_isolate: isolate_mode=2 order=0 nr_requested=32 nr_scanned=32
> nr_taken=32 contig_taken=0 contig_dirty=0 contig_failed=0
> 
> 'active' can be gotten by analyzing mode(Thanks go to Minchan and Mel),
> So this patch adds 'file' to the trace event and it now looks like:
> mm_vmscan_lru_isolate: isolate_mode=2 order=0 nr_requested=32 nr_scanned=32
> nr_taken=32 contig_taken=0 contig_dirty=0 contig_failed=0 file=0
> 
> ...
>
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1249,7 +1249,7 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
>  	*scanned = scan;
>  
>  	trace_mm_vmscan_memcg_isolate(0, nr_to_scan, scan, nr_taken,
> -				      0, 0, 0, mode);
> +				      0, 0, 0, mode, file);
>  
>  	return nr_taken;
>  }

This tracepoint was removed by Johannes's "mm: make per-memcg LRU lists
exclusive".

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f54a05b..a444dc0 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1221,7 +1221,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  			nr_to_scan, scan,
>  			nr_taken,
>  			nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed,
> -			mode);
> +			mode, file);
>  	return nr_taken;
>  }

So this is the only remaining site for that tracepoint.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
