Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 783E76B0007
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 23:38:45 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id j22-v6so137357pll.7
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 20:38:45 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d125-v6si2993071pgc.94.2018.06.20.20.38.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Jun 2018 20:38:44 -0700 (PDT)
Date: Wed, 20 Jun 2018 20:38:39 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: mempool: Fix a possible sleep-in-atomic-context bug
 in mempool_resize()
Message-ID: <20180621033839.GB12608@bombadil.infradead.org>
References: <20180621030714.10368-1-baijiaju1990@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180621030714.10368-1-baijiaju1990@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia-Ju Bai <baijiaju1990@gmail.com>
Cc: akpm@linux-foundation.org, dvyukov@google.com, gregkh@linuxfoundation.org, jthumshirn@suse.de, pombredanne@nexb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 21, 2018 at 11:07:14AM +0800, Jia-Ju Bai wrote:
> The kernel may sleep with holding a spinlock.
> The function call path (from bottom to top) in Linux-4.16.7 is:
> 
> [FUNC] remove_element(GFP_KERNEL)
> mm/mempool.c, 250: remove_element in mempool_resize
> mm/mempool.c, 247: _raw_spin_lock_irqsave in mempool_resize
> 
> To fix this bug, GFP_KERNEL is replaced with GFP_ATOMIC.
> 
> This bug is found by my static analysis tool (DSAC-2) and checked by
> my code review.

But ... we don't use the flags argument.

static void *remove_element(mempool_t *pool, gfp_t flags)
{
        void *element = pool->elements[--pool->curr_nr];

        BUG_ON(pool->curr_nr < 0);
        kasan_unpoison_element(pool, element, flags);
        check_element(pool, element);
        return element;
}

...

static void kasan_unpoison_element(mempool_t *pool, void *element, gfp_t flags)
{
        if (pool->alloc == mempool_alloc_slab || pool->alloc == mempool_kmalloc)
                kasan_unpoison_slab(element);
        if (pool->alloc == mempool_alloc_pages)
                kasan_alloc_pages(element, (unsigned long)pool->pool_data);
}

So the correct patch would just remove this argument to remove_element() and
kasan_unpoison_element()?
