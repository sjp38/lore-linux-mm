Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 998F76B000D
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 08:47:52 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id j68so7598349oih.14
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 05:47:52 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id s135si2793170oie.532.2018.02.12.05.47.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Feb 2018 05:47:51 -0800 (PST)
Subject: Re: [PATCH v2] lockdep: Fix fs_reclaim warning.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201801292047.EHC05241.OHSQOJOVtFMFLF@I-love.SAKURA.ne.jp>
	<20180129135547.GR2269@hirez.programming.kicks-ass.net>
	<201802012036.FEE78102.HOMFFOtJVFOSQL@I-love.SAKURA.ne.jp>
	<201802082043.FFJ39503.SVQFFFOJMHLOtO@I-love.SAKURA.ne.jp>
	<e6f5dc9b-2066-4f31-8e0f-c713f53e6592@suse.com>
In-Reply-To: <e6f5dc9b-2066-4f31-8e0f-c713f53e6592@suse.com>
Message-Id: <201802122246.FAI52698.FVOStMHQFLFJOO@I-love.SAKURA.ne.jp>
Date: Mon, 12 Feb 2018 22:46:51 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nborisov@suse.com, peterz@infradead.org
Cc: torvalds@linux-foundation.org, davej@codemonkey.org.uk, npiggin@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, mhocko@kernel.org, linux-btrfs@vger.kernel.org

Nikolay Borisov wrote:
> I think I've hit another incarnation of that one. The call stack is:
> http://paste.opensuse.org/3f22d013
> 
> The cleaned up callstack of all the ? entries look like:
> 
> __lock_acquire+0x2d8a/0x4b70
> lock_acquire+0x110/0x330
> kmem_cache_alloc+0x29/0x2c0
> __clear_extent_bit+0x488/0x800
> try_release_extent_mapping+0x288/0x3c0
> __btrfs_releasepage+0x6c/0x140
> shrink_page_list+0x227e/0x3110
> shrink_inactive_list+0x414/0xdb0
> shrink_node_memcg+0x7c8/0x1250
> shrink_node+0x2ae/0xb50
> do_try_to_free_pages+0x2b1/0xe20
> try_to_free_pages+0x205/0x570
>  __alloc_pages_nodemask+0xb91/0x2160
> new_slab+0x27a/0x4e0
> ___slab_alloc+0x355/0x610
>  __slab_alloc+0x4c/0xa0
> kmem_cache_alloc+0x22d/0x2c0
> mempool_alloc+0xe1/0x280

Yes, for mempool_alloc() is adding __GFP_NOMEMALLOC | __GFP_NOWARN to gfp_mask.

	gfp_mask |= __GFP_NOMEMALLOC;   /* don't allocate emergency reserves */
	gfp_mask |= __GFP_NORETRY;      /* don't loop in __alloc_pages */
	gfp_mask |= __GFP_NOWARN;       /* failures are OK */

> bio_alloc_bioset+0x1d7/0x830
> ext4_mpage_readpages+0x99f/0x1000 <-
> __do_page_cache_readahead+0x4be/0x840
> filemap_fault+0x8c8/0xfc0
> ext4_filemap_fault+0x7d/0xb0
> __do_fault+0x7a/0x150
> __handle_mm_fault+0x1542/0x29d0
> __do_page_fault+0x557/0xa30
> async_page_fault+0x4c/0x60

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
