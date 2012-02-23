Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 081046B00F9
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 09:21:07 -0500 (EST)
Received: by bkty12 with SMTP id y12so1410524bkt.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 06:21:06 -0800 (PST)
Message-ID: <4F464B4D.5080907@openvz.org>
Date: Thu, 23 Feb 2012 18:21:01 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 9/10] mm/memcg: move lru_lock into lruvec
References: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils> <alpine.LSU.2.00.1202201537040.23274@eggly.anvils> <4F434300.3080001@openvz.org> <alpine.LSU.2.00.1202211205280.1858@eggly.anvils> <4F440E1D.7050004@openvz.org> <alpine.LSU.2.00.1202211406030.2012@eggly.anvils> <4F446458.8000107@openvz.org> <alpine.LSU.2.00.1202212148430.3515@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1202212148430.3515@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hugh Dickins wrote:
> On Wed, 22 Feb 2012, Konstantin Khlebnikov wrote:
>> Hugh Dickins wrote:
>>> On Wed, 22 Feb 2012, Konstantin Khlebnikov wrote:
>>>> Hugh Dickins wrote:
>>>>>
>>>>> I'll have to come back to think about your locking later too;
>>>>> or maybe that's exactly where I need to look, when investigating
>>>>> the mm_inline.h:41 BUG.
>>>>
>>>> pages_count[] updates looks correct.
>>>> This really may be bug in locking, and this VM_BUG_ON catch it before
>>>> list-debug.
>>>
>>> I've still not got into looking at it yet.
>>>
>>> You're right to mention DEBUG_LIST: I have that on some of the machines,
>>> and I would expect that to be the first to catch a mislocking issue.
>>>
>>> In the past my problems with that BUG (well, the spur to introduce it)
>>> came from hugepages.
>>
>> My patchset hasn't your mem_cgroup_reset_uncharged_to_root protection,
>> or something to replace it. So, there exist race between cgroup remove and
>> isolated uncharged page put-back, but it shouldn't corrupt lru lists.
>> There something different.
>
> Yes, I'm not into removing cgroups yet.

Ok, my v3 patchset can deal with cgroups removing. At least I believe. =)

I was implemented isolated pages counter.
Seems like overhead isn't fatal and can be reduced.
Plus these counters can be used not only as reference counters,
they provides useful statistics for reclaimer.

>
> I've got it: your "can differ only on lumpy reclaim" belief, first
> commented in 17/22 but then assumed in 20/22, is wrong: those swapin
> readahead pages, for example, may shift from root_mem_cgroup to another
> mem_cgroup while the page is isolated by shrink_active or shrink_inactive.

Ok, thanks.

>
> Patch below against the top of my version of your tree: probably won't
> quite apply to yours, since we used different bases here; but easy
> enough to correct yours from it.
>
> Bisection was misleading: it appeared to be much easier to reproduce
> with 22/22 taken off, and led to 16/22, but that's because that one
> introduced a similar bug, which actually got fixed in 22/22:
>
> relock_page_lruvec() and relock_page_lruvec_irq() in 16/22 onwards
> are wrong, in each case the if block needs an
> 	} else
> 		lruvec = page_lruvec(page);

Ok, fixed in v3

>
> You'll want to fix that in 16/22, but here's the patch for the end state:
>
> Signed-off-by: Hugh Dickins<hughd@google.com>
> but forget that, just quietly fold the fixes into yours!

This actually reverts my "mm: optimize putback for 0-order reclaim",
so I removed this wrong optimization in v3

> ---
>   mm/vmscan.c |   20 ++++++--------------
>   1 file changed, 6 insertions(+), 14 deletions(-)
>
> --- 3033K2.orig/mm/vmscan.c	2012-02-21 00:02:13.000000000 -0800
> +++ 3033K2/mm/vmscan.c	2012-02-21 21:23:25.768381375 -0800
> @@ -1342,7 +1342,6 @@ static int too_many_isolated(struct zone
>    */
>   static noinline_for_stack struct lruvec *
>   putback_inactive_pages(struct lruvec *lruvec,
> -		       struct scan_control *sc,
>   		       struct list_head *page_list)
>   {
>   	struct zone_reclaim_stat *reclaim_stat =&lruvec->reclaim_stat;
> @@ -1364,11 +1363,8 @@ putback_inactive_pages(struct lruvec *lr
>   			continue;
>   		}
>
> -		/* can differ only on lumpy reclaim */
> -		if (sc->order) {
> -			lruvec = __relock_page_lruvec(lruvec, page);
> -			reclaim_stat =&lruvec->reclaim_stat;
> -		}
> +		lruvec = __relock_page_lruvec(lruvec, page);
> +		reclaim_stat =&lruvec->reclaim_stat;
>
>   		SetPageLRU(page);
>   		lru = page_lru(page);
> @@ -1566,7 +1562,7 @@ shrink_inactive_list(unsigned long nr_to
>   		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
>   	__count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
>
> -	lruvec = putback_inactive_pages(lruvec, sc,&page_list);
> +	lruvec = putback_inactive_pages(lruvec,&page_list);
>
>   	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
>   	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
> @@ -1631,7 +1627,6 @@ shrink_inactive_list(unsigned long nr_to
>
>   static struct lruvec *
>   move_active_pages_to_lru(struct lruvec *lruvec,
> -			 struct scan_control *sc,
>   			 struct list_head *list,
>   			 struct list_head *pages_to_free,
>   			 enum lru_list lru)
> @@ -1643,10 +1638,7 @@ move_active_pages_to_lru(struct lruvec *
>   		int numpages;
>
>   		page = lru_to_page(list);
> -
> -		/* can differ only on lumpy reclaim */
> -		if (sc->order)
> -			lruvec = __relock_page_lruvec(lruvec, page);
> +		lruvec = __relock_page_lruvec(lruvec, page);
>
>   		VM_BUG_ON(PageLRU(page));
>   		SetPageLRU(page);
> @@ -1770,9 +1762,9 @@ static void shrink_active_list(unsigned
>   	 */
>   	reclaim_stat->recent_rotated[file] += nr_rotated;
>
> -	lruvec = move_active_pages_to_lru(lruvec, sc,&l_active,&l_hold,
> +	lruvec = move_active_pages_to_lru(lruvec,&l_active,&l_hold,
>   						LRU_ACTIVE + file * LRU_FILE);
> -	lruvec = move_active_pages_to_lru(lruvec, sc,&l_inactive,&l_hold,
> +	lruvec = move_active_pages_to_lru(lruvec,&l_inactive,&l_hold,
>   						LRU_BASE   + file * LRU_FILE);
>   	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
>   	unlock_lruvec_irq(lruvec);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
