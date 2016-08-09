Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5E50D6B0253
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 12:06:24 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id pp5so29627915pac.3
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 09:06:24 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0091.outbound.protection.outlook.com. [104.47.1.91])
        by mx.google.com with ESMTPS id m22si43309931pfg.0.2016.08.09.09.06.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 09 Aug 2016 09:06:23 -0700 (PDT)
Date: Tue, 9 Aug 2016 19:06:12 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH v2] mm/slub: Run free_partial() outside of the
 kmem_cache_node->list_lock
Message-ID: <20160809160612.GH1983@esperanza>
References: <20160809151743.GF1983@esperanza>
 <1470756466-12493-1-git-send-email-chris@chris-wilson.co.uk>
 <20160809154539.GG1983@esperanza>
 <20160809155213.GI21147@nuc-i3427.alporthouse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160809155213.GI21147@nuc-i3427.alporthouse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Safonov <dsafonov@virtuozzo.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, Dave Gordon <david.s.gordon@intel.com>, linux-mm@kvack.org

On Tue, Aug 09, 2016 at 04:52:13PM +0100, Chris Wilson wrote:
...
> > > @@ -3486,13 +3487,16 @@ static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
> > >  	list_for_each_entry_safe(page, h, &n->partial, lru) {
> > >  		if (!page->inuse) {
> > >  			remove_partial(n, page);
> > > -			discard_slab(s, page);
> > > +			list_add(&page->lru, &partial_list);
> > 
> > If there are objects left in the cache on destruction, the cache won't
> > be destroyed. Instead it will be left on the slab_list and can get
> > reused later. So we should use list_move() here to always leave
> > n->partial in a consistent state, even in case of a leak.
> 
> Since remove_partial() does an unconditional list_del(),
> I presume you want to perform the list_move() even if we hit the error
> path, right?

Please ignore my previous remark - I missed that remove_partial() does
list_del(), so using list_add(), as you did in v2, should be just fine.
Feel free, to add

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
