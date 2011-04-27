Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7F7659000C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 04:09:44 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 8F49C3EE0BC
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:09:41 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7647945DE51
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:09:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5413A45DE4E
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:09:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 477781DB803B
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:09:41 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 074731DB802F
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:09:41 +0900 (JST)
Date: Wed, 27 Apr 2011 17:03:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 3/8] vmscan: make isolate_lru_page with filter aware
Message-Id: <20110427170304.d31c1398.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <232562452317897b5acb1445803410d74233a923.1303833417.git.minchan.kim@gmail.com>
References: <cover.1303833415.git.minchan.kim@gmail.com>
	<232562452317897b5acb1445803410d74233a923.1303833417.git.minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, 27 Apr 2011 01:25:20 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> In some __zone_reclaim case, we don't want to shrink mapped page.
> Nonetheless, we have isolated mapped page and re-add it into
> LRU's head. It's unnecessary CPU overhead and makes LRU churning.
> 
> Of course, when we isolate the page, the page might be mapped but
> when we try to migrate the page, the page would be not mapped.
> So it could be migrated. But race is rare and although it happens,
> it's no big deal.
> 
> Cc: Christoph Lameter <cl@linux.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>


Hmm, it seems mm/memcontrol.c::mem_cgroup_isolate_pages() should be updated, too.

But it's okay you start from global LRU.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
>  mm/vmscan.c |   11 ++++++-----
>  1 files changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 71d2da9..e8d6190 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1147,7 +1147,8 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  
>  static unsigned long isolate_pages_global(unsigned long nr,
>  					struct list_head *dst,
> -					unsigned long *scanned, int order,
> +					unsigned long *scanned,
> +					struct scan_control *sc,
>  					int mode, struct zone *z,
>  					int active, int file)
>  {
> @@ -1156,8 +1157,8 @@ static unsigned long isolate_pages_global(unsigned long nr,
>  		lru += LRU_ACTIVE;
>  	if (file)
>  		lru += LRU_FILE;
> -	return isolate_lru_pages(nr, &z->lru[lru].list, dst, scanned, order,
> -					mode, file, 0, 0);
> +	return isolate_lru_pages(nr, &z->lru[lru].list, dst, scanned, sc->order,
> +					mode, file, 0, !sc->may_unmap);
>  }
>  
>  /*
> @@ -1407,7 +1408,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
>  
>  	if (scanning_global_lru(sc)) {
>  		nr_taken = isolate_pages_global(nr_to_scan,
> -			&page_list, &nr_scanned, sc->order,
> +			&page_list, &nr_scanned, sc,
>  			sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
>  					ISOLATE_BOTH : ISOLATE_INACTIVE,
>  			zone, 0, file);
> @@ -1531,7 +1532,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
>  	spin_lock_irq(&zone->lru_lock);
>  	if (scanning_global_lru(sc)) {
>  		nr_taken = isolate_pages_global(nr_pages, &l_hold,
> -						&pgscanned, sc->order,
> +						&pgscanned, sc,
>  						ISOLATE_ACTIVE, zone,
>  						1, file);
>  		zone->pages_scanned += pgscanned;
> -- 
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
