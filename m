Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 5626D6B00B7
	for <linux-mm@kvack.org>; Mon, 24 Mar 2014 13:34:31 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id l18so3742486wgh.16
        for <linux-mm@kvack.org>; Mon, 24 Mar 2014 10:34:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id gk2si2079164wic.34.2014.03.24.10.34.28
        for <linux-mm@kvack.org>;
        Mon, 24 Mar 2014 10:34:29 -0700 (PDT)
Message-ID: <53306C73.9030808@redhat.com>
Date: Mon, 24 Mar 2014 13:33:39 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] vmscan: Age anonymous memory even when swap is off.
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org> <1395436655-21670-6-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1395436655-21670-6-git-send-email-john.stultz@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 03/21/2014 05:17 PM, John Stultz wrote:
> Currently we don't shrink/scan the anonymous lrus when swap is off.
> This is problematic for volatile range purging on swapless systems/
>
> This patch naievely changes the vmscan code to continue scanning
> and shrinking the lrus even when there is no swap.
>
> It obviously has performance issues.
>
> Thoughts on how best to implement this would be appreciated.
>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Android Kernel Team <kernel-team@android.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Robert Love <rlove@google.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Dave Hansen <dave@sr71.net>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
> Cc: Neil Brown <neilb@suse.de>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Mike Hommey <mh@glandium.org>
> Cc: Taras Glek <tglek@mozilla.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
> Cc: Michel Lespinasse <walken@google.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: linux-mm@kvack.org <linux-mm@kvack.org>
> Signed-off-by: John Stultz <john.stultz@linaro.org>
> ---
>   mm/vmscan.c | 26 ++++----------------------
>   1 file changed, 4 insertions(+), 22 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 34f159a..07b0a8c 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -155,9 +155,8 @@ static unsigned long zone_reclaimable_pages(struct zone *zone)
>   	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
>   	     zone_page_state(zone, NR_INACTIVE_FILE);
>
> -	if (get_nr_swap_pages() > 0)
> -		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
> -		      zone_page_state(zone, NR_INACTIVE_ANON);
> +	nr += zone_page_state(zone, NR_ACTIVE_ANON) +
> +	      zone_page_state(zone, NR_INACTIVE_ANON);
>
>   	return nr;

Not all of the anonymous pages will be reclaimable.

Is there some counter that keeps track of how many
volatile range pages there are in each zone?


> @@ -1764,13 +1763,6 @@ static int inactive_anon_is_low_global(struct zone *zone)
>    */
>   static int inactive_anon_is_low(struct lruvec *lruvec)
>   {
> -	/*
> -	 * If we don't have swap space, anonymous page deactivation
> -	 * is pointless.
> -	 */
> -	if (!total_swap_pages)
> -		return 0;
> -
>   	if (!mem_cgroup_disabled())
>   		return mem_cgroup_inactive_anon_is_low(lruvec);

This part is correct, and needed.

> @@ -1880,12 +1872,6 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
>   	if (!global_reclaim(sc))
>   		force_scan = true;
>
> -	/* If we have no swap space, do not bother scanning anon pages. */
> -	if (!sc->may_swap || (get_nr_swap_pages() <= 0)) {
> -		scan_balance = SCAN_FILE;
> -		goto out;
> -	}
> -
>   	/*

This part is too.

> @@ -2181,8 +2166,8 @@ static inline bool should_continue_reclaim(struct zone *zone,
>   	 */
>   	pages_for_compaction = (2UL << sc->order);
>   	inactive_lru_pages = zone_page_state(zone, NR_INACTIVE_FILE);
> -	if (get_nr_swap_pages() > 0)
> -		inactive_lru_pages += zone_page_state(zone, NR_INACTIVE_ANON);
> +	inactive_lru_pages += zone_page_state(zone, NR_INACTIVE_ANON);
> +
>   	if (sc->nr_reclaimed < pages_for_compaction &&
>   			inactive_lru_pages > pages_for_compaction)

Not sure this is a good idea, since the pages may not actually
be reclaimable, and the inactive list will continue to be
refilled indefinitely...

If there was a counter of the number of volatile range pages
in a zone, this would be easier.

Of course, the overhead of keeping such a counter might be
too high for what volatile ranges are designed for...

>   		return true;
> @@ -2726,9 +2711,6 @@ static void age_active_anon(struct zone *zone, struct scan_control *sc)
>   {
>   	struct mem_cgroup *memcg;
>
> -	if (!total_swap_pages)
> -		return;
> -

This bit is correct and needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
