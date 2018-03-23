Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id AD34E6B0005
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 12:15:15 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id k4-v6so7954782pls.15
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 09:15:15 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x11-v6si8957936plm.326.2018.03.23.09.15.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 23 Mar 2018 09:15:14 -0700 (PDT)
Date: Fri, 23 Mar 2018 09:15:12 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 3/4] mm: Add free()
Message-ID: <20180323161512.GD5624@bombadil.infradead.org>
References: <20180322195819.24271-1-willy@infradead.org>
 <20180322195819.24271-4-willy@infradead.org>
 <6fd1bba1-e60c-e5b3-58be-52e991cda74f@virtuozzo.com>
 <20180323151421.GC5624@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180323151421.GC5624@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Fri, Mar 23, 2018 at 08:14:21AM -0700, Matthew Wilcox wrote:
> > One more thing, there is
> > some kasan checks on the main way of kfree(), and there is no guarantee they
> > reflected in kmem_cache_free() identical.
> 
> Which function are you talking about here?
> 
> slub calls slab_free() for both kfree() and kmem_cache_free().
> slab calls __cache_free() for both kfree() and kmem_cache_free().
> Each of them do their kasan handling in the called function.

... except for where slub can free large objects without calling slab_free():

        if (unlikely(!PageSlab(page))) {
                BUG_ON(!PageCompound(page));
                kfree_hook(object);
                __free_pages(page, compound_order(page));
                return;
        }
        slab_free(page->slab_cache, page, object, NULL, 1, _RET_IP_);

If you call kmalloc(16384, GFP_KERNEL), slub will hand back an order-2
page without setting PageSlab on it.  So if that gets passed to free(),
it'll call __put_page() which calls free_compound_page() which calls
__free_pages_ok().  Looks like we want another compound_dtor to be sure
we call the kfree hook.
