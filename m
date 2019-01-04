Return-Path: <linux-kernel-owner@vger.kernel.org>
Subject: Re: [PATCH] mm, page_alloc: Do not wake kswapd with zone lock held
References: <20190103225712.GJ31517@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <51d17b9f-5c5b-5964-0943-668b679964cd@suse.cz>
Date: Fri, 4 Jan 2019 09:18:38 +0100
MIME-Version: 1.0
In-Reply-To: <20190103225712.GJ31517@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-kernel-owner@vger.kernel.org
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Qian Cai <cai@lca.pw>, Dmitry Vyukov <dvyukov@google.com>, syzbot <syzbot+93d94a001cfbce9e60e1@syzkaller.appspotmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux@dominikbrodowski.net, Michal Hocko <mhocko@suse.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>
List-ID: <linux-mm.kvack.org>

On 1/3/19 11:57 PM, Mel Gorman wrote:
> syzbot reported the following regression in the latest merge window
> and it was confirmed by Qian Cai that a similar bug was visible from a
> different context.
> 
> ======================================================
> WARNING: possible circular locking dependency detected
> 4.20.0+ #297 Not tainted
> ------------------------------------------------------
> syz-executor0/8529 is trying to acquire lock:
> 000000005e7fb829 (&pgdat->kswapd_wait){....}, at:
> __wake_up_common_lock+0x19e/0x330 kernel/sched/wait.c:120
> 
> but task is already holding lock:
> 000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: spin_lock
> include/linux/spinlock.h:329 [inline]
> 000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: rmqueue_bulk
> mm/page_alloc.c:2548 [inline]
> 000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: __rmqueue_pcplist
> mm/page_alloc.c:3021 [inline]
> 000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: rmqueue_pcplist
> mm/page_alloc.c:3050 [inline]
> 000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at: rmqueue
> mm/page_alloc.c:3072 [inline]
> 000000009bb7bae0 (&(&zone->lock)->rlock){-.-.}, at:
> get_page_from_freelist+0x1bae/0x52a0 mm/page_alloc.c:3491
> 
> It appears to be a false positive in that the only way the lock
> ordering should be inverted is if kswapd is waking itself and the
> wakeup allocates debugging objects which should already be allocated
> if it's kswapd doing the waking. Nevertheless, the possibility exists
> and so it's best to avoid the problem.
> 
> This patch flags a zone as needing a kswapd using the, surprisingly,
> unused zone flag field. The flag is read without the lock held to
> do the wakeup. It's possible that the flag setting context is not
> the same as the flag clearing context or for small races to occur.
> However, each race possibility is harmless and there is no visible
> degredation in fragmentation treatment.
> 
> While zone->flag could have continued to be unused, there is potential
> for moving some existing fields into the flags field instead. Particularly
> read-mostly ones like zone->initialized and zone->contiguous.
> 
> Reported-by: syzbot+93d94a001cfbce9e60e1@syzkaller.appspotmail.com
> Tested-by: Qian Cai <cai@lca.pw>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Fixes: 1c30844d2dfe ("mm: reclaim small amounts of memory when an
external fragmentation event occurs")
Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  include/linux/mmzone.h | 6 ++++++
>  mm/page_alloc.c        | 8 +++++++-
>  2 files changed, 13 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index cc4a507d7ca4..842f9189537b 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -520,6 +520,12 @@ enum pgdat_flags {
>  	PGDAT_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
>  };
>  
> +enum zone_flags {
> +	ZONE_BOOSTED_WATERMARK,		/* zone recently boosted watermarks.
> +					 * Cleared when kswapd is woken.
> +					 */
> +};
> +
>  static inline unsigned long zone_managed_pages(struct zone *zone)
>  {
>  	return (unsigned long)atomic_long_read(&zone->managed_pages);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index cde5dac6229a..d295c9bc01a8 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2214,7 +2214,7 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
>  	 */
>  	boost_watermark(zone);
>  	if (alloc_flags & ALLOC_KSWAPD)
> -		wakeup_kswapd(zone, 0, 0, zone_idx(zone));
> +		set_bit(ZONE_BOOSTED_WATERMARK, &zone->flags);
>  
>  	/* We are not allowed to try stealing from the whole block */
>  	if (!whole_block)
> @@ -3102,6 +3102,12 @@ struct page *rmqueue(struct zone *preferred_zone,
>  	local_irq_restore(flags);
>  
>  out:
> +	/* Separate test+clear to avoid unnecessary atomics */
> +	if (test_bit(ZONE_BOOSTED_WATERMARK, &zone->flags)) {
> +		clear_bit(ZONE_BOOSTED_WATERMARK, &zone->flags);
> +		wakeup_kswapd(zone, 0, 0, zone_idx(zone));
> +	}
> +
>  	VM_BUG_ON_PAGE(page && bad_range(zone, page), page);
>  	return page;
>  
> 
