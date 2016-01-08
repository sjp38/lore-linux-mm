Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 95C826B025B
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 21:55:39 -0500 (EST)
Received: by mail-io0-f171.google.com with SMTP id 1so226739829ion.1
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 18:55:39 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id g133si28192054iog.156.2016.01.07.18.55.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 07 Jan 2016 18:55:39 -0800 (PST)
Date: Fri, 8 Jan 2016 11:58:39 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 01/10] slub: cleanup code for kmem cgroup support to
 kmem_cache_free_bulk
Message-ID: <20160108025839.GB14457@js1304-P5Q-DELUXE>
References: <20160107140253.28907.5469.stgit@firesoul>
 <20160107140338.28907.48580.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160107140338.28907.48580.stgit@firesoul>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, Jan 07, 2016 at 03:03:38PM +0100, Jesper Dangaard Brouer wrote:
> This change is primarily an attempt to make it easier to realize the
> optimizations the compiler performs in-case CONFIG_MEMCG_KMEM is not
> enabled.
> 
> Performance wise, even when CONFIG_MEMCG_KMEM is compiled in, the
> overhead is zero. This is because, as long as no process have
> enabled kmem cgroups accounting, the assignment is replaced by
> asm-NOP operations.  This is possible because memcg_kmem_enabled()
> uses a static_key_false() construct.
> 
> It also helps readability as it avoid accessing the p[] array like:
> p[size - 1] which "expose" that the array is processed backwards
> inside helper function build_detached_freelist().

That part is cleande up but overall code doesn't looks readable to me.
How about below change?

Thanks.

---------------------->8------------------
 struct detached_freelist {
+       struct kmem_cache *s;
        struct page *page;
        void *tail;
        void *freelist;
@@ -2852,8 +2853,11 @@ static int build_detached_freelist(struct kmem_cache *s, size_t size,
        if (!object)
                return 0;
 
+       /* Support for memcg */
+       df->s = cache_from_obj(s, object);
+
        /* Start new detached freelist */
-       set_freepointer(s, object, NULL);
+       set_freepointer(df.s, object, NULL);
        df->page = virt_to_head_page(object);
        df->tail = object;
        df->freelist = object;
@@ -2868,7 +2872,7 @@ static int build_detached_freelist(struct kmem_cache *s, size_t size,
                /* df->page is always set at this point */
                if (df->page == virt_to_head_page(object)) {
                        /* Opportunity build freelist */
-                       set_freepointer(s, object, df->freelist);
+                       set_freepointer(df.s, object, df->freelist);
                        df->freelist = object;
                        df->cnt++;
                        p[size] = NULL; /* mark object processed */
@@ -2889,23 +2893,19 @@ static int build_detached_freelist(struct kmem_cache *s, size_t size,
 
 
 /* Note that interrupts must be enabled when calling this function. */
-void kmem_cache_free_bulk(struct kmem_cache *orig_s, size_t size, void **p)
+void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
 {
        if (WARN_ON(!size))
                return;
 
        do {
                struct detached_freelist df;
-               struct kmem_cache *s;
-
-               /* Support for memcg */
-               s = cache_from_obj(orig_s, p[size - 1]);
 
                size = build_detached_freelist(s, size, p, &df);
                if (unlikely(!df.page))
                        continue;
 
-               slab_free(s, df.page, df.freelist, df.tail, df.cnt, _RET_IP_);
+               slab_free(df.s, df.page, df.freelist, df.tail, df.cnt, _RET_IP_);
        } while (likely(size));
 }
 EXPORT_SYMBOL(kmem_cache_free_bulk);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
