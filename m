Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5756D6B050C
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 09:07:39 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id h24-v6so5538481ede.9
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 06:07:39 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j26-v6si518284ejt.47.2018.11.07.06.07.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 06:07:37 -0800 (PST)
Date: Wed, 7 Nov 2018 15:07:36 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH 2/3] mm: Use line-buffered printk() for show_free_areas().
Message-ID: <20181107140736.hmsomid74ofzpxvd@pathway.suse.cz>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1541165517-3557-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1541165517-3557-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On Fri 2018-11-02 22:31:56, Tetsuo Handa wrote:
> syzbot is sometimes getting mixed output like below due to concurrent
> printk(). Mitigate such output by using line-buffered printk() API.
> 
>   Node 0 DMA: 1*4kB (U) 0*8kB 0*16kB 1*32kB 
>   syz-executor0: page allocation failure: order:0, mode:0x484020(GFP_ATOMIC|__GFP_COMP), nodemask=(null)
>   (U) 
>   syz-executor0 cpuset=
>   2*64kB 
>   syz0
>   (U) 
>    mems_allowed=0
>   1*128kB 
>   CPU: 0 PID: 7592 Comm: syz-executor0 Not tainted 4.19.0-rc6+ #118
>   (U) 
>   Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
>   1*256kB (U) 
>   Call Trace:
>   0*512kB 
>    <IRQ>
>   1*1024kB 
>    __dump_stack lib/dump_stack.c:77 [inline]
>    dump_stack+0x1c4/0x2b4 lib/dump_stack.c:113
>   (U) 
>   1*2048kB 
>    warn_alloc.cold.119+0xb7/0x1bd mm/page_alloc.c:3426
>   (M) 
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  mm/page_alloc.c | 32 +++++++++++++++++---------------
>  1 file changed, 17 insertions(+), 15 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a919ba5..4411d5a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4694,10 +4694,10 @@ unsigned long nr_free_pagecache_pages(void)
>  	return nr_free_zone_pages(gfp_zone(GFP_HIGHUSER_MOVABLE));
>  }
>  
> -static inline void show_node(struct zone *zone)
> +static inline void show_node(struct zone *zone, struct printk_buffer *buf)
>  {
>  	if (IS_ENABLED(CONFIG_NUMA))
> -		printk("Node %d ", zone_to_nid(zone));
> +		printk_buffered(buf, "Node %d ", zone_to_nid(zone));

The conversion looks fine to me. I just think about renaming
printk_buffered to bprintk().

Best Regards,
Petr
