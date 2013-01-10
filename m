Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 7EC066B006C
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 19:26:04 -0500 (EST)
Date: Wed, 9 Jan 2013 16:26:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm: forcely swapout when we are out of page cache
Message-Id: <20130109162602.53a60e77.akpm@linux-foundation.org>
In-Reply-To: <1357712474-27595-3-git-send-email-minchan@kernel.org>
References: <1357712474-27595-1-git-send-email-minchan@kernel.org>
	<1357712474-27595-3-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Sonny Rao <sonnyrao@google.com>, Bryan Freed <bfreed@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

On Wed,  9 Jan 2013 15:21:14 +0900
Minchan Kim <minchan@kernel.org> wrote:

> If laptop_mode is enable, VM try to avoid I/O for saving the power.
> But if there isn't reclaimable memory without I/O, we should do I/O
> for preventing unnecessary OOM kill although we sacrifices power.
> 
> One of example is that we are out of page cache. Remained one is
> only anonymous pages, for swapping out, we needs may_writepage = 1.
> 
> Reported-by: Luigi Semenzato <semenzato@google.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/vmscan.c |    6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 439cc47..624c816 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1728,6 +1728,12 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
>  		free = zone_page_state(zone, NR_FREE_PAGES);
>  		if (unlikely(file + free <= high_wmark_pages(zone))) {
>  			scan_balance = SCAN_ANON;
> +			/*
> +			 * From now on, we have to swap out
> +			 * for peventing OOM kill although
> +			 * we sacrifice power consumption.
> +			 */
> +			sc->may_writepage = 1;
>  			goto out;
>  		}
>  	}

This is pretty ugly.  get_scan_count() is, as its name implies, an
idempotent function which inspects the state of things and returns a
result.  As such, it has no business going in and altering the state of
the scan_control.

We have code in both direct reclaim and in kswapd to set may_writepage
if vmscan is getting into trouble.  I don't see why adding another
instance is necessary if the existing instances are working correctly.



(Is it correct that __zone_reclaim() ignores laptop_mode?)


I have a feeling that laptop mode has bitrotted and these patches are
kinda hacking around as-yet-not-understood failures...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
