Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BA7D86B0253
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 18:41:01 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id l14so6323899pgu.17
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 15:41:01 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id y29si4889715pff.367.2017.12.07.15.41.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 15:41:00 -0800 (PST)
Date: Thu, 7 Dec 2017 15:40:56 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH] mm: kasan: suppress soft lockup in slub when
 !CONFIG_PREEMPT
Message-ID: <20171207234056.GF26792@bombadil.infradead.org>
References: <1512689407-100663-1-git-send-email-yang.s@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1512689407-100663-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: aryabinin@virtuozzo.com, glider@google.com, dvyukov@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org

On Fri, Dec 08, 2017 at 07:30:07AM +0800, Yang Shi wrote:
> When running stress test with KASAN enabled, the below softlockup may
> happen occasionally:
> 
> NMI watchdog: BUG: soft lockup - CPU#7 stuck for 22s!
> hardirqs last  enabled at (0): [<          (null)>]      (null)
> hardirqs last disabled at (0): [] copy_process.part.30+0x5c6/0x1f50
> softirqs last  enabled at (0): [] copy_process.part.30+0x5c6/0x1f50
> softirqs last disabled at (0): [<          (null)>]      (null)

> Call Trace:
>  [] __slab_free+0x19c/0x270
>  [] ___cache_free+0xa6/0xb0
>  [] qlist_free_all+0x47/0x80
>  [] quarantine_reduce+0x159/0x190
>  [] kasan_kmalloc+0xaf/0xc0
>  [] kasan_slab_alloc+0x12/0x20
>  [] kmem_cache_alloc+0xfa/0x360
>  [] ? getname_flags+0x4f/0x1f0
>  [] getname_flags+0x4f/0x1f0
>  [] getname+0x12/0x20
>  [] do_sys_open+0xf9/0x210
>  [] SyS_open+0x1e/0x20
>  [] entry_SYSCALL_64_fastpath+0x1f/0xc2

This feels like papering over a problem.  KASAN only calls
quarantine_reduce() when it's allowed to block.  Presumably it has
millions of entries on the free list at this point.  I think the right
thing to do is for qlist_free_all() to call cond_resched() after freeing
every N items.

> The code is run in irq disabled or preempt disabled context, so
> cond_resched() can't be used in this case. Touch softlockup watchdog when
> KASAN is enabled to suppress the warning.
> 
> Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
> ---
>  mm/slub.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index cfd56e5..4ae435e 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -35,6 +35,7 @@
>  #include <linux/prefetch.h>
>  #include <linux/memcontrol.h>
>  #include <linux/random.h>
> +#include <linux/nmi.h>
>  
>  #include <trace/events/kmem.h>
>  
> @@ -2266,6 +2267,10 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
>  		page->pobjects = pobjects;
>  		page->next = oldpage;
>  
> +#ifdef CONFIG_KASAN
> +		touch_softlockup_watchdog();
> +#endif
> +
>  	} while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page)
>  								!= oldpage);
>  	if (unlikely(!s->cpu_partial)) {
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
