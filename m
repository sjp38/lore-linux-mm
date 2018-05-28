Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6A9166B0006
	for <linux-mm@kvack.org>; Mon, 28 May 2018 11:32:18 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k18-v6so10641624wrm.6
        for <linux-mm@kvack.org>; Mon, 28 May 2018 08:32:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l32-v6si449890ede.433.2018.05.28.08.32.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 May 2018 08:32:16 -0700 (PDT)
Date: Mon, 28 May 2018 15:24:10 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
Message-ID: <20180528132410.GD27180@dhcp22.suse.cz>
References: <CA+7wUswp_Sr=hHqi1bwRZ3FE2wY5ozZWZ8Z1BgrFnSAmijUKjA@mail.gmail.com>
 <20180528083451.GE1517@dhcp22.suse.cz>
 <f054219d-6daa-68b1-0c60-0acd9ad8c5ab@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f054219d-6daa-68b1-0c60-0acd9ad8c5ab@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Mathieu Malaterre <malat@debian.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>, Chunyu Hu <chuhu@redhat.com>

I've found the previous report [1] finally. Adding Chunyu Hu to the CC
list. The report which triggered this one is [2]

[1] http://lkml.kernel.org/r/1524243513-29118-1-git-send-email-chuhu@redhat.com
[2] http://lkml.kernel.org/r/CA+7wUswp_Sr=hHqi1bwRZ3FE2wY5ozZWZ8Z1BgrFnSAmijUKjA@mail.gmail.com

I am not really familiar with the kmemleak code but the expectation that
you can make a forward progress in an unknown allocation context seems
broken to me. Why kmemleak cannot pre-allocate a pool of object_cache
and refill it from a reasonably strong contexts (e.g. in a sleepable
context)?

On Mon 28-05-18 22:05:21, Tetsuo Handa wrote:
> >From f0b7f6c2146f693fec6706bf9e3c34687c73f21a Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Mon, 28 May 2018 21:49:51 +0900
> Subject: [PATCH] kmemleak: don't use __GFP_NOFAIL
> 
> Commit d9570ee3bd1d4f20 ("kmemleak: allow to coexist with fault injection")
> added __GFP_NOFAIL to gfp_kmemleak_mask() macro because memory allocation
> fault injection trivially disables kmemleak.
> 
> But since !__GFP_DIRECT_RECLAIM && __GFP_NOFAIL memory allocation is not
> supported, Mathieu Malaterre is observing warning messages upon
> mempool_alloc(gfp_msk & ~__GFP_DIRECT_RECLAIM) allocation request.
> 
> [  269.039118] NIP [c020e8f8] __alloc_pages_nodemask+0xa88/0xfec
> [  269.039124] LR [c020e2e0] __alloc_pages_nodemask+0x470/0xfec
> [  269.039128] Call Trace:
> [  269.039136] [dde3b750] [c020e2e0]  __alloc_pages_nodemask+0x470/0xfec (unreliable)
> [  269.039146] [dde3b820] [c0288c14] new_slab+0x53c/0x970
> [  269.039155] [dde3b880] [c028b61c] ___slab_alloc.constprop.23+0x28c/0x468
> [  269.039163] [dde3b920] [c028c754] kmem_cache_alloc+0x290/0x3dc
> [  269.039177] [dde3b990] [c02a6030] create_object+0x50/0x3d0
> [  269.039185] [dde3b9e0] [c028c7a8] kmem_cache_alloc+0x2e4/0x3dc
> [  269.039193] [dde3ba50] [c0200f88] mempool_alloc+0x7c/0x164
> [  269.039205] [dde3bab0] [c03e33c0] bio_alloc_bioset+0x130/0x298
> [  269.039216] [dde3baf0] [c0278694] get_swap_bio+0x34/0xe8
> [  269.039223] [dde3bb30] [c0278fb4] __swap_writepage+0x22c/0x644
> [  269.039237] [dde3bbb0] [c022528c] pageout.isra.13+0x238/0x52c
> [  269.039246] [dde3bc10] [c02288a0] shrink_page_list+0x9d4/0x1768
> [  269.039254] [dde3bcb0] [c022a264] shrink_inactive_list+0x2c4/0xa34
> [  269.039262] [dde3bd40] [c022b454] shrink_node_memcg+0x344/0xe34
> [  269.039270] [dde3bde0] [c022c068] shrink_node+0x124/0x73c
> [  269.039277] [dde3be50] [c022d78c] kswapd+0x318/0xb2c
> [  269.039291] [dde3bf10] [c008e264] kthread+0x138/0x1f0
> [  269.039300] [dde3bf40] [c001b2e4] ret_from_kernel_thread+0x5c/0x64
> 
> Since the intent of adding __GFP_NOFAIL is not to disable kmemleak by
> failing the N'th allocation request, it should be possible to workaround
> it by simply retrying N'th allocation request. Thus, this patch changes
> callers of gfp_kmemleak_mask() macro to retry for several times.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Reported-by: Mathieu Malaterre <malat@debian.org>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Michal Hocko <mhocko@suse.com>
> ---
>  mm/kmemleak.c | 15 ++++++++++-----
>  1 file changed, 10 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index 9a085d5..973998b 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -126,7 +126,7 @@
>  /* GFP bitmask for kmemleak internal allocations */
>  #define gfp_kmemleak_mask(gfp)	(((gfp) & (GFP_KERNEL | GFP_ATOMIC)) | \
>  				 __GFP_NORETRY | __GFP_NOMEMALLOC | \
> -				 __GFP_NOWARN | __GFP_NOFAIL)
> +				 __GFP_NOWARN)
>  
>  /* scanning area inside a memory block */
>  struct kmemleak_scan_area {
> @@ -548,10 +548,12 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
>  					     int min_count, gfp_t gfp)
>  {
>  	unsigned long flags;
> -	struct kmemleak_object *object, *parent;
> +	struct kmemleak_object *object = NULL, *parent;
>  	struct rb_node **link, *rb_parent;
> +	unsigned int i;
>  
> -	object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
> +	for (i = 0; i < 10 && !object; i++)
> +		object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
>  	if (!object) {
>  		pr_warn("Cannot allocate a kmemleak_object structure\n");
>  		kmemleak_disable();
> @@ -763,7 +765,8 @@ static void add_scan_area(unsigned long ptr, size_t size, gfp_t gfp)
>  {
>  	unsigned long flags;
>  	struct kmemleak_object *object;
> -	struct kmemleak_scan_area *area;
> +	struct kmemleak_scan_area *area = NULL;
> +	unsigned int i;
>  
>  	object = find_and_get_object(ptr, 1);
>  	if (!object) {
> @@ -772,7 +775,9 @@ static void add_scan_area(unsigned long ptr, size_t size, gfp_t gfp)
>  		return;
>  	}
>  
> -	area = kmem_cache_alloc(scan_area_cache, gfp_kmemleak_mask(gfp));
> +	for (i = 0; i < 10 && !area; i++)
> +		area = kmem_cache_alloc(scan_area_cache,
> +					gfp_kmemleak_mask(gfp));
>  	if (!area) {
>  		pr_warn("Cannot allocate a scan area\n");
>  		goto out;
> -- 
> 1.8.3.1
> 
> 

-- 
Michal Hocko
SUSE Labs
