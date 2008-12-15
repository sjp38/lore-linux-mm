Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9976E6B0070
	for <linux-mm@kvack.org>; Mon, 15 Dec 2008 18:40:45 -0500 (EST)
Received: by yx-out-1718.google.com with SMTP id 36so1136258yxh.26
        for <linux-mm@kvack.org>; Mon, 15 Dec 2008 15:42:12 -0800 (PST)
Message-ID: <28c262360812151542g2ac032fay6c5b03d846d05a77@mail.gmail.com>
Date: Tue, 16 Dec 2008 08:42:12 +0900
From: "MinChan Kim" <minchan.kim@gmail.com>
Subject: Re: [rfc][patch] SLQB slab allocator
In-Reply-To: <20081212002518.GH8294@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081212002518.GH8294@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi, Nick.
I am interested in SLQB.
So I tested slqb, slub, slab by kernel compile time.

make all -j 8

slqb and slub not DEBUG.
my test environment is as follows.

cpu family	: 6
model		: 15
model name	: Intel(R) Core(TM)2 Quad CPU    Q6600  @ 2.40GHz
stepping	: 11
cpu MHz		: 1600.000
cache size	: 4096 KB

Below is average for ten time test.

slab :
user : 2376.484, system : 192.616 elapsed : 12:22.0
slub :
user : 2378.439, system : 194.989 elapsed : 12:22.4
slqb :
user : 2380.556, system : 194.801 elapsed : 12:23.0

so, slqb is rather slow although it is a big difference.
Interestingly, slqb consumes less time than slub in system.

And I found some trivial bug. :)

<snip>

> +static struct slqb_page *new_slab_page(struct kmem_cache *s, gfp_t flags, int node)
> +{
> +       struct slqb_page *page;
> +       void *start;
> +       void *last;
> +       void *p;
> +
> +       BUG_ON(flags & GFP_SLAB_BUG_MASK);
> +
> +       page = allocate_slab(s,
> +               flags & (GFP_RECLAIM_MASK | GFP_CONSTRAINT_MASK), node);
> +       if (!page)
> +               goto out;
> +
> +       page->flags |= 1 << PG_slab;

PG_slab set is redundant.
It's already set in alloc_slqb_pags_node.

> +       start = page_address(&page->page);
> +
> +       if (unlikely(slab_poison(s)))
> +               memset(start, POISON_INUSE, PAGE_SIZE << s->order);

<snip>

> +void kfree(const void *object)
> +{
> +       struct kmem_cache *s;
> +       struct page *p;
> +       struct slqb_page *page;
> +       unsigned long flags;
> +
> +       if (unlikely(ZERO_OR_NULL_PTR(object)))
> +               return;
> +
> +       p = virt_to_page(object);
> +       prefetch(p);
> +       prefetchw(object);
> +
> +#ifdef CONFIG_SLQB_DEBUG
> +       page = (struct slqb_page *)compound_head(p);
> +       s = page->list->cache;
> +       debug_check_no_locks_freed(object, s->objsize);
> +       if (likely(object) && unlikely(slab_debug(s))) {
> +               if (unlikely(!free_debug_processing(s, object, __builtin_return_address(0))))
> +                       return;
> +       }
> +#endif
> +
> +       local_irq_save(flags);
> +#ifndef CONFIG_SLQB_DEBUG
> +       page = (struct slqb_page *)compound_head(p);
> +       s = page->list->cache;
> +#endif

If it is not defined CONFIG_SLQB_DEBUG, page is garbage.

> +       __slab_free(s, page, object);
> +       local_irq_restore(flags);
> +}
> +EXPORT_SYMBOL(kfree);
> +


-- 
Kinds regards,
MinChan Kim
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
