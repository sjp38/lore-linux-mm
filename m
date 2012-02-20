Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id EE4156B004D
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 11:21:18 -0500 (EST)
Received: by bkty12 with SMTP id y12so6197589bkt.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 08:21:17 -0800 (PST)
Message-ID: <4F4272FA.9000004@openvz.org>
Date: Mon, 20 Feb 2012 20:21:14 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm: replace per-cpu lru-add page-vectors with page-lists
References: <20120219212412.16861.36936.stgit@zurg> <20120219212417.16861.63119.stgit@zurg>
In-Reply-To: <20120219212417.16861.63119.stgit@zurg>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Konstantin Khlebnikov wrote:
> This patch replaces page-vectors with page-lists in lru_cache_add*() functions.
> We can use page->lru for linking because page obviously not in lru.
>
> Now per-cpu batch limited with its pages total size, not pages count,
> otherwise it can be extremely huge if there many huge-pages inside:
> PAGEVEC_SIZE * HPAGE_SIZE = 28Mb, per-cpu!
> These pages are hidden from memory reclaimer for a while.
> New limit: LRU_CACHE_ADD_BATCH = 64 (* PAGE_SIZE = 256Kb)
>
> So, huge-page adding now will always drain per-cpu list. Huge-page allocation
> and preparation is long procedure, thus nobody will notice this draining.
>
> Draining procedure disables preemption only for pages list isolation,
> thus batch size can be increased without negative effect for latency.
>
> Plus this patch introduces new function lru_cache_add_list() and use it in
> mpage_readpages() and read_pages(). There pages already collected in list.
> Unlike to single-page lru-add, list-add reuse page-referencies from caller,
> thus we save one page_get()/page_put() per page.
>
> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
> ---
>   fs/mpage.c           |   21 +++++++----
>   include/linux/swap.h |    2 +
>   mm/readahead.c       |   15 +++++---
>   mm/swap.c            |   99 +++++++++++++++++++++++++++++++++++++++++++++-----
>   4 files changed, 114 insertions(+), 23 deletions(-)
>

>
>   	pvec =&per_cpu(lru_rotate_pvecs, cpu);
> @@ -765,6 +841,11 @@ EXPORT_SYMBOL(pagevec_lookup_tag);
>   void __init swap_setup(void)
>   {
>   	unsigned long megs = totalram_pages>>  (20 - PAGE_SHIFT);
> +	int cpu, lru;
> +
> +	for_each_possible_cpu(cpu)
> +		for_each_lru(lru)
> +			INIT_LIST_HEAD(per_cpu(lru_add_pages, cpu) + lru);

As I afraid, here is is too late for this initialization.
This must be in core-initcall.

I'll send v2 together with update lru-lock splitting rebased to linux-next.

>
>   #ifdef CONFIG_SWAP
>   	bdi_init(swapper_space.backing_dev_info);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
