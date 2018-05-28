Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id DFA246B000C
	for <linux-mm@kvack.org>; Mon, 28 May 2018 04:47:17 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id b36-v6so7309796pli.2
        for <linux-mm@kvack.org>; Mon, 28 May 2018 01:47:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l67-v6si29838382pfg.326.2018.05.28.01.47.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 May 2018 01:47:16 -0700 (PDT)
Date: Mon, 28 May 2018 10:34:51 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: WARNING: CPU: 0 PID: 21 at ../mm/page_alloc.c:4258
 __alloc_pages_nodemask+0xa88/0xfec
Message-ID: <20180528083451.GE1517@dhcp22.suse.cz>
References: <CA+7wUswp_Sr=hHqi1bwRZ3FE2wY5ozZWZ8Z1BgrFnSAmijUKjA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+7wUswp_Sr=hHqi1bwRZ3FE2wY5ozZWZ8Z1BgrFnSAmijUKjA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Malaterre <malat@debian.org>
Cc: linux-mm@kvack.org

On Sat 26-05-18 09:14:35, Mathieu Malaterre wrote:
> Hi Michal,
> 
> For the last couple of days, I am seeing the following appearing in
> dmesg (*). I am a happy kmemleak user on an oldish Mac Mini G4
> (ppc32), it has been working great. What does this new warning checks:
> 
>     /*
>      * All existing users of the __GFP_NOFAIL are blockable, so warn
>      * of any new users that actually require GFP_NOWAIT
>      */
>     if (WARN_ON_ONCE(!can_direct_reclaim))
>       goto fail;

Interesting. Where does this path get GFP_NOFAIL from? I am looking at
the current upstream code and 
get_swap_bio(GFP_NOIO)
  bio_alloc(gfp_mask)
    bio_alloc_bioset(gfp_mask)
      mempool_alloc(gfp_msk & ~__GFP_DIRECT_RECLAIM)

mempool_alloc does play some tricks with the gfp_mask but it doesn't add
GFP_NOFAIL AFAICS.
 
> Thanks,
> 
> (*)
> [  269.038911] WARNING: CPU: 0 PID: 21 at ../mm/page_alloc.c:4258
> __alloc_pages_nodemask+0xa88/0xfec
[...]
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
> [  269.039304] Instruction dump:
> [  269.039311] 7f44d378 7fa3eb78 4802bd95 4bfff9f4 485d7309 4bfff998 7f03c378 7fc5f378
> [  269.039326] 7f44d378 4802bd79 7c781b78 4bfffd48 <0fe00000> 8081002c 3ca0c08b 7fe6fb78
> [  269.039343] ---[ end trace c255e24f03e28d77 ]---
> [  269.039351] kmemleak: Cannot allocate a kmemleak_object structure
> [  269.039373] kmemleak: Kernel memory leak detector disabled
> [  269.039412] kmemleak: Automatic memory scanning thread ended

-- 
Michal Hocko
SUSE Labs
