Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2D2496B0035
	for <linux-mm@kvack.org>; Sat, 10 May 2014 15:53:01 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kp14so5714732pab.26
        for <linux-mm@kvack.org>; Sat, 10 May 2014 12:53:00 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id ko6si4101227pbc.227.2014.05.10.12.52.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 10 May 2014 12:53:00 -0700 (PDT)
Received: by mail-pa0-f54.google.com with SMTP id bj1so4492511pad.13
        for <linux-mm@kvack.org>; Sat, 10 May 2014 12:52:59 -0700 (PDT)
Date: Sat, 10 May 2014 12:51:44 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/3] mm: add comment for __mod_zone_page_stat
In-Reply-To: <1d32d83e54542050dba3f711a8d10b1e951a9a58.1399705884.git.nasa4836@gmail.com>
Message-ID: <alpine.LSU.2.11.1405101142300.1680@eggly.anvils>
References: <1d32d83e54542050dba3f711a8d10b1e951a9a58.1399705884.git.nasa4836@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, cody@linux.vnet.ibm.com, liuj97@gmail.com, zhangyanfei@cn.fujitsu.com, srivatsa.bhat@linux.vnet.ibm.com, dave@sr71.net, iamjoonsoo.kim@lge.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, schwidefsky@de.ibm.com, gorcunov@gmail.com, riel@redhat.com, cl@linux.com, toshi.kani@hp.com, paul.gortmaker@windriver.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 10 May 2014, Jianyu Zhan wrote:

> __mod_zone_page_stat() is not irq-safe, so it should be used carefully.
> And it is not appropirately documented now. This patch adds comment for
> it, and also documents for some of its call sites.
> 
> Suggested-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>

Your original __mod_zone_page_state happened to be correct;
but you have no understanding of why it was correct, so its
comment was very wrong, even after you changed the irq wording.

This series just propagates your misunderstanding further,
while providing an object lesson in how not to present a series.

Sorry, you have quickly developed an unenviable reputation for
patches which waste developers' time: please consider your
patches much more carefully before posting them.

> ---
>  mm/page_alloc.c |  2 ++
>  mm/rmap.c       |  6 ++++++
>  mm/vmstat.c     | 16 +++++++++++++++-
>  3 files changed, 23 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5dba293..9d6f474 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -659,6 +659,8 @@ static inline int free_pages_check(struct page *page)
>   *
>   * And clear the zone's pages_scanned counter, to hold off the "all pages are
>   * pinned" detection logic.
> + *
> + * Note: this function should be used with irq disabled.

Correct, but I don't see that that needed saying.  This is a static
function which is being used as intended: just because it matched your
search for "__mod_zone_page_state" is not a reason for you to add that
comment; irq disabled is only one of its prerequisites.

>   */
>  static void free_pcppages_bulk(struct zone *zone, int count,
>  					struct per_cpu_pages *pcp)
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 9c3e773..6078a30 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -979,6 +979,8 @@ void page_add_anon_rmap(struct page *page,
>  /*
>   * Special version of the above for do_swap_page, which often runs
>   * into pages that are exclusively owned by the current process.
> + * So we could use the irq-unsafe version __{inc|mod}_zone_page_stat
> + * here without others racing change it in between.

And yet you can immediately see them being used without any test
for "exclusive" below: why is that?  Think about it.

>   * Everybody else should continue to use page_add_anon_rmap above.
>   */
>  void do_page_add_anon_rmap(struct page *page,
> @@ -1077,6 +1079,10 @@ void page_remove_rmap(struct page *page)
>  	/*
>  	 * Hugepages are not counted in NR_ANON_PAGES nor NR_FILE_MAPPED
>  	 * and not charged by memcg for now.
> +	 *
> +	 * And we are the last user of this page, so it is safe to use
> +	 * the irq-unsafe version __{mod|dec}_zone_page here, since we
> +	 * have no racer.

Again, the code is correct to be using the irq-unsafe version, but your
comment is doubly wrong.

We are not necessarily the last user of this page, merely the one that
just now brought the mapcount down to 0.

But think: what bearing would being the last user of this page have on
the safety of using __mod_zone_page_state to adjust per-zone counters?

None at all.  A page does not move from one zone to another (though its
contents might be migrated from one page to another when safe to do so).

Once upon a time, from 2.6.16 to 2.6.32, there was indeed a relevant
and helpful comment in __page_set_anon_rmap():
	/*
	 * nr_mapped state can be updated without turning off
	 * interrupts because it is not modified via interrupt.
	 */
	__inc_page_state(nr_mapped);

The comment survived the replacement of nr_mapped, but eventually
it got cleaned away completely.

It is safe to use the irq-unsafe __mod_zone_page_stat on counters
which are never modified via interrupt.

>  	 */
>  	if (unlikely(PageHuge(page)))
>  		goto out;
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 302dd07..778f154 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -207,7 +207,21 @@ void set_pgdat_percpu_threshold(pg_data_t *pgdat,
>  }
>  
>  /*
> - * For use when we know that interrupts are disabled.
> + * Optimized modificatoin function.
> + *
> + * The code basically does the modification in two steps:
> + *
> + *  1. read the current counter based on the processor number
> + *  2. modificate the counter write it back.
> + *
> + * So this function should be used with the guarantee that
> + *
> + *  1. interrupts are disabled, or
> + *  2. interrupts are enabled, but no other sites would race to
> + *     modify this counter in between.
> + *
> + * Otherwise, an irq-safe version mod_zone_page_state() should
> + * be used instead.

You are right that the comment is not good enough, but I don't trust
your version either.  Since percpu variables are involved, it's important
that preemption be disabled too (see comment above __inc_zone_state).

I'd prefer to let Christoph write the definitive version,
but my first stab at it would be:

/*
 * For use when we know that interrupts are disabled,
 * or when we know that preemption is disabled and that
 * particular counter cannot be updated from interrupt context.
 */

Hugh

>   */
>  void __mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
>  				int delta)
> -- 
> 2.0.0-rc1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
