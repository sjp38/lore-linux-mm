Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 8EA976B004A
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 00:43:57 -0500 (EST)
Received: by bkty12 with SMTP id y12so2120010bkt.14
        for <linux-mm@kvack.org>; Wed, 15 Feb 2012 21:43:55 -0800 (PST)
Message-ID: <4F3C9798.7050800@openvz.org>
Date: Thu, 16 Feb 2012 09:43:52 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC 00/15] mm: memory book keeping and lru_lock splitting
References: <20120215224221.22050.80605.stgit@zurg> <20120216110408.f35c3448.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120216110408.f35c3448.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

KAMEZAWA Hiroyuki wrote:
> On Thu, 16 Feb 2012 02:57:04 +0400
> Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
>
>> There should be no logic changes in this patchset, this is only tossing bits around.
>> [ This patchset is on top some memcg cleanup/rework patches,
>>    which I sent to linux-mm@ today/yesterday ]
>>
>> Most of things in this patchset are self-descriptive, so here brief plan:
>>
>
> AFAIK, Hugh Dickins said he has per-zone-per-lru-lock and is testing it.
> So, please CC him and Johannes, at least.
>

Ok

>
>> * Transmute struct lruvec into struct book. Like real book this struct will
>>    store set of pages for one zone. It will be working unit for reclaimer code.
>> [ If memcg is disabled in config there will only one book embedded into struct zone ]
>>
>
> Why you need to add new structure rahter than enhancing lruvec ?
> "book" means a binder of pages ?
>

I responded to this in the reply to Hugh Dickins.

>
>> * move page-lru counters to struct book
>> [ this adds extra overhead in add_page_to_lru_list()/del_page_from_lru_list() for
>>    non-memcg case, but I believe it will be invisible, only one non-atomic add/sub
>>    in the same cacheline with lru list ]
>>
>
> This seems straightforward.
>
>> * unify inactive_list_is_low_global() and cleanup reclaimer code
>> * replace struct mem_cgroup_zone with single pointer to struct book
>
> Hm, ok.
>
>> * optimize page to book translations, move it upper in the call stack,
>>    replace some struct zone arguments with struct book pointer.
>>
>
> a page->book transrater from patch 2/15
>
> +struct book *page_book(struct page *page)
> +{
> +	struct mem_cgroup_per_zone *mz;
> +	struct page_cgroup *pc;
> +
> +	if (mem_cgroup_disabled())
> +		return&page_zone(page)->book;
> +
> +	pc = lookup_page_cgroup(page);
> +	if (!PageCgroupUsed(pc))
> +		return&page_zone(page)->book;
> +	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
> +	smp_rmb();
> +	mz = mem_cgroup_zoneinfo(pc->mem_cgroup,
> +			page_to_nid(page), page_zonenum(page));
> +	return&mz->book;
> +}
>
> What happens when pc->mem_cgroup is rewritten by move_account() ?
> Where is the guard for lockless access of this ?

Initially this suppose to be protected with lru_lock, in final patch they are protected with rcu.
After final patch all page_book() calls are collected in [__re]lock_page_book[_irq]() functions.
They pick some book reference, lock its lru and recheck page -> book reference in loop till success.

Currently I found there only one potential problem: free_mem_cgroup_per_zone_info() in "mm: memory bookkeeping core"
maybe should call spin_unlock_wait(&zone->lru_lock), because some guy can pick page_book(pfn_to_page(pfn))
and try to isolate this page. But I not sure, how this is possible. In final patch it is totally fixed with rcu.

>
> Thanks,
> -Kame
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
