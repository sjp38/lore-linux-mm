Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5A3B66B004D
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 21:56:21 -0400 (EDT)
Date: Tue, 1 Sep 2009 09:56:17 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] mm/vsmcan: check shrink_active_list()
	sc->isolate_pages() return value.
Message-ID: <20090901015617.GB11320@localhost>
References: <1251759241-15167-1-git-send-email-macli@brc.ubc.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1251759241-15167-1-git-send-email-macli@brc.ubc.ca>
Sender: owner-linux-mm@kvack.org
To: Vincent Li <macli@brc.ubc.ca>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 01, 2009 at 06:54:01AM +0800, Vincent Li wrote:
> commit 5343daceec (If sc->isolate_pages() return 0...) make shrink_inactive_list handle
> sc->isolate_pages() return value properly. Add similar proper return value check for
> shrink_active_list() sc->isolate_pages().
> 
> Signed-off-by: Vincent Li <macli@brc.ubc.ca>

Looks good to me, thanks.

Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>

> ---
>  mm/vmscan.c |    9 +++++++--
>  1 files changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 460a6f7..2d1c846 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1319,9 +1319,12 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
>  	if (scanning_global_lru(sc)) {
>  		zone->pages_scanned += pgscanned;
>  	}
> -	reclaim_stat->recent_scanned[file] += nr_taken;
> -
>  	__count_zone_vm_events(PGREFILL, zone, pgscanned);
> +
> +	if (nr_taken == 0)
> +		goto done;
> +
> +	reclaim_stat->recent_scanned[file] += nr_taken;
>  	if (file)
>  		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -nr_taken);
>  	else
> @@ -1383,6 +1386,8 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
>  	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
>  	__mod_zone_page_state(zone, LRU_ACTIVE + file * LRU_FILE, nr_rotated);
>  	__mod_zone_page_state(zone, LRU_BASE + file * LRU_FILE, nr_deactivated);
> +
> +done:
>  	spin_unlock_irq(&zone->lru_lock);
>  }
>  
> -- 
> 1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
