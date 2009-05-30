Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0652B6B00BD
	for <linux-mm@kvack.org>; Sat, 30 May 2009 07:11:29 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4UBBb6o003954
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 30 May 2009 20:11:38 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 44F4A45DD7D
	for <linux-mm@kvack.org>; Sat, 30 May 2009 20:11:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2332B45DD7B
	for <linux-mm@kvack.org>; Sat, 30 May 2009 20:11:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 090021DB8046
	for <linux-mm@kvack.org>; Sat, 30 May 2009 20:11:37 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AE67D1DB8037
	for <linux-mm@kvack.org>; Sat, 30 May 2009 20:11:36 +0900 (JST)
Message-ID: <f391c30e66dc962826031b5ffa8ab44e.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090529145510.b4ff541e.akpm@linux-foundation.org>
References: <20090528135455.0c83bedc.kamezawa.hiroyu@jp.fujitsu.com>
    <20090528142047.3069543b.kamezawa.hiroyu@jp.fujitsu.com>
    <20090529145510.b4ff541e.akpm@linux-foundation.org>
Date: Sat, 30 May 2009 20:11:35 +0900 (JST)
Subject: Re: [PATCH 3/4] reuse unused swap entry if necessary
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, hugh.dickins@tiscali.co.uk, hannes@cmpxchg.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Thu, 28 May 2009 14:20:47 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
>> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> Now, we can know a swap entry is just used as SwapCache via swap_map,
>> without looking up swap cache.
>>
>> Then, we have a chance to reuse swap-cache-only swap entries in
>> get_swap_pages().
>>
>> This patch tries to free swap-cache-only swap entries if swap is
>> not enough.
>> Note: We hit following path when swap_cluster code cannot find
>> a free cluster. Then, vm_swap_full() is not only condition to allow
>> the kernel to reclaim unused swap.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>>  mm/swapfile.c |   39 +++++++++++++++++++++++++++++++++++++++
>>  1 file changed, 39 insertions(+)
>>
>> Index: new-trial-swapcount2/mm/swapfile.c
>> ===================================================================
>> --- new-trial-swapcount2.orig/mm/swapfile.c
>> +++ new-trial-swapcount2/mm/swapfile.c
>> @@ -73,6 +73,25 @@ static inline unsigned short make_swap_c
>>  	return ret;
>>  }
>>
>> +static int
>> +try_to_reuse_swap(struct swap_info_struct *si, unsigned long offset)
>> +{
>> +	int type = si - swap_info;
>> +	swp_entry_t entry = swp_entry(type, offset);
>> +	struct page *page;
>> +	int ret = 0;
>> +
>> +	page = find_get_page(&swapper_space, entry.val);
>> +	if (!page)
>> +		return 0;
>> +	if (trylock_page(page)) {
>> +		ret = try_to_free_swap(page);
>> +		unlock_page(page);
>> +	}
>> +	page_cache_release(page);
>> +	return ret;
>> +}
>
> This function could do with some comments explaining what it does, and
> why.  Also describing the semantics of its return value.
>
Ah, there are no comments ...

> afacit it's misnamed.  It doesn't 'reuse' anything.  It in fact tries
> to release a swap entry so that (presumably) its _caller_ can reuse the
> swap slot.
>
yes.

> The missing comment should also explain why this function is forced to
> use the nasty trylock_page().
>
> Why _is_ this function forced to use the nasty trylock_page()?
>
Because get_swap_page() is called by vmscan.c and when this is called
the caller hold page_lock() on a page. IIUC, nesting lock_page()
without trylock is not good here.

I'll explain this in the next post.


>>  /*
>>   * We need this because the bdev->unplug_fn can sleep and we cannot
>>   * hold swap_lock while calling the unplug_fn. And swap_lock
>> @@ -294,6 +313,18 @@ checks:
>>  		goto no_page;
>>  	if (offset > si->highest_bit)
>>  		scan_base = offset = si->lowest_bit;
>> +
>> +	/* reuse swap entry of cache-only swap if not busy. */
>> +	if (vm_swap_full() && si->swap_map[offset] == SWAP_HAS_CACHE) {
>> +		int ret;
>> +		spin_unlock(&swap_lock);
>> +		ret = try_to_reuse_swap(si, offset);
>> +		spin_lock(&swap_lock);
>> +		if (ret)
>> +			goto checks; /* we released swap_lock. retry. */
>> +		goto scan; /* In some racy case */
>> +	}
>
> So..  what prevents an infinite (or long) busy loop here?  It appears
> that if try_to_reuse_swap() returned non-zero, it will have cleared
> si->swap_map[offset], so we don't rerun try_to_reuse_swap().  Yes?
>
yes.

> `ret' is a poor choice of identifier.  It is usually used to hold the
> value which this function will be returning.  Ditto `retval'.  But that
> is not this variable's role in this case.  Perhaps a better name would
> be slot_was_freed or something.
>
Sure, I'll modifty this patch to be more clear one.
Thank you for review!

-Kame


>>  	if (si->swap_map[offset])
>>  		goto scan;
>>
>> @@ -375,6 +406,10 @@ scan:
>>  			spin_lock(&swap_lock);
>>  			goto checks;
>>  		}
>> +		if (vm_swap_full() && si->swap_map[offset] == SWAP_HAS_CACHE) {
>> +			spin_lock(&swap_lock);
>> +			goto checks;
>> +		}
>>  		if (unlikely(--latency_ration < 0)) {
>>  			cond_resched();
>>  			latency_ration = LATENCY_LIMIT;
>> @@ -386,6 +421,10 @@ scan:
>>  			spin_lock(&swap_lock);
>>  			goto checks;
>>  		}
>> +		if (vm_swap_full() && si->swap_map[offset] == SWAP_HAS_CACHE) {
>> +			spin_lock(&swap_lock);
>> +			goto checks;
>> +		}
>>  		if (unlikely(--latency_ration < 0)) {
>>  			cond_resched();
>>  			latency_ration = LATENCY_LIMIT;
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
