Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 533B36B025F
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 11:52:19 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id u81so26341890wmu.3
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 08:52:19 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id s17si3647908wmb.62.2016.08.09.08.52.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Aug 2016 08:52:18 -0700 (PDT)
Date: Tue, 9 Aug 2016 16:52:13 +0100
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH v2] mm/slub: Run free_partial() outside of the
 kmem_cache_node->list_lock
Message-ID: <20160809155213.GI21147@nuc-i3427.alporthouse.com>
References: <20160809151743.GF1983@esperanza>
 <1470756466-12493-1-git-send-email-chris@chris-wilson.co.uk>
 <20160809154539.GG1983@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160809154539.GG1983@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Safonov <dsafonov@virtuozzo.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, Dave Gordon <david.s.gordon@intel.com>, linux-mm@kvack.org

On Tue, Aug 09, 2016 at 06:45:39PM +0300, Vladimir Davydov wrote:
> On Tue, Aug 09, 2016 at 04:27:46PM +0100, Chris Wilson wrote:
> ...
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 825ff45..58f0eb6 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -3479,6 +3479,7 @@ static void list_slab_objects(struct kmem_cache *s, struct page *page,
> >   */
> >  static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
> >  {
> > +	LIST_HEAD(partial_list);
> 
> nit: slabs added to this list are not partially used - they are free, so
> let's call it 'free_slabs' or 'discard_list' or just 'discard', please

Ok.

> >  	struct page *page, *h;
> >  
> >  	BUG_ON(irqs_disabled());
> > @@ -3486,13 +3487,16 @@ static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
> >  	list_for_each_entry_safe(page, h, &n->partial, lru) {
> >  		if (!page->inuse) {
> >  			remove_partial(n, page);
> > -			discard_slab(s, page);
> > +			list_add(&page->lru, &partial_list);
> 
> If there are objects left in the cache on destruction, the cache won't
> be destroyed. Instead it will be left on the slab_list and can get
> reused later. So we should use list_move() here to always leave
> n->partial in a consistent state, even in case of a leak.

Since remove_partial() does an unconditional list_del(),
I presume you want to perform the list_move() even if we hit the error
path, right?
i.e.

    list_for_each_entry_safe(page, h, &n->partial, lru) {
                if (!page->inuse) {
                        remove_partial(n, page);
-                       list_add(&page->lru, &partial_list);
                } else {
                        list_slab_objects(s, page,
                        "Objects remaining in %s on __kmem_cache_shutdown()");
                }
+               list_move(&page->lru, &discard);

-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
