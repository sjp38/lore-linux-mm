Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8BE276B0003
	for <linux-mm@kvack.org>; Wed, 30 May 2018 10:13:33 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e3-v6so10959875pfe.15
        for <linux-mm@kvack.org>; Wed, 30 May 2018 07:13:33 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id m9-v6si1849719pfe.128.2018.05.30.07.13.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 07:13:31 -0700 (PDT)
Date: Wed, 30 May 2018 10:15:33 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 07/13] memcontrol: schedule throttling if we are congested
Message-ID: <20180530141533.GC4035@cmpxchg.org>
References: <20180529211724.4531-1-josef@toxicpanda.com>
 <20180529211724.4531-8-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180529211724.4531-8-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: axboe@kernel.dk, kernel-team@fb.com, linux-block@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tj@kernel.org, linux-fsdevel@vger.kernel.org

On Tue, May 29, 2018 at 05:17:18PM -0400, Josef Bacik wrote:
> @@ -5458,6 +5458,30 @@ int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
>  	return ret;
>  }
>  
> +int mem_cgroup_try_charge_delay(struct page *page, struct mm_struct *mm,
> +			  gfp_t gfp_mask, struct mem_cgroup **memcgp,
> +			  bool compound)
> +{
> +	struct mem_cgroup *memcg;
> +	struct block_device *bdev;
> +	int ret;
> +
> +	ret = mem_cgroup_try_charge(page, mm, gfp_mask, memcgp, compound);
> +	memcg = *memcgp;
> +
> +	if (!(gfp_mask & __GFP_IO) || !memcg)
> +		return ret;
> +#if defined(CONFIG_BLOCK) && defined(CONFIG_SWAP)
> +	if (atomic_read(&memcg->css.cgroup->congestion_count) &&
> +	    has_usable_swap()) {
> +		map_swap_page(page, &bdev);

This doesn't work, unfortunately - or only works on accident.

It goes through page_private(), which is only valid for pages in the
swapcache. The newly allocated pages you call it against aren't in the
swapcache, but their page_private() is 0, which is incorrectly
interpreted as "first swap slot on the first swap device" - which
happens to make sense if you have only one swap device.

> +		blkcg_schedule_throttle(bdev_get_queue(bdev), true);

By the time we allocate, we simply cannot know which swap device the
page will end up on. However, we know what's likely: swap_avail_heads
is sorted by order in which we try to allocate swap slots; the first
device on there is where swap io will go. If we walk this list and
throttle on the first device that has built-up delay debt, we'll
throttle against the device that probably gets the current bulk of the
swap writes.

Also, if we have two swap devices with the same priority, swap
allocation will re-order the list for us automatically in order to do
round-robin loading of the devices. See get_swap_pages(). That should
work out nicely for throttling as well.

You can use page_to_nid() on the newly allocated page to index into
swap_avail_heads[].

On an unrelated note, mem_cgroup_try_charge_delay() isn't the most
descriptive name. Since it's not too page specific, we might want to
move the throttling part out of the charge function and do something
simliar to a stand-alone balance_dirty_pages() function.

mem_cgroup_balance_anon_pages()?

mem_cgroup_throttle_swaprate()?

mem_cgroup_anon_throttle()?

mem_cgroup_anon_allocwait()?

Something like that. I personally like balance_anon_pages the best;
not because it is the best name by itself, but because in the MM it
has the notion of throttling the creation of IO liabilities to the
write rate, which is what we're doing here as well.
