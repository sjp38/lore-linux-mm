Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id EF1436B0038
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 14:41:09 -0500 (EST)
Received: by obc18 with SMTP id 18so42158614obc.2
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 11:41:09 -0800 (PST)
Received: from resqmta-po-01v.sys.comcast.net (resqmta-po-01v.sys.comcast.net. [2001:558:fe16:19:96:114:154:160])
        by mx.google.com with ESMTPS id zd2si771996obb.43.2015.12.09.11.41.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 09 Dec 2015 11:41:08 -0800 (PST)
Date: Wed, 9 Dec 2015 13:41:07 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH V2 8/9] slab: implement bulk free in SLAB allocator
In-Reply-To: <20151209195325.68eaf314@redhat.com>
Message-ID: <alpine.DEB.2.20.1512091338240.7552@east.gentwo.org>
References: <20151208161751.21945.53936.stgit@firesoul> <20151208161903.21945.33876.stgit@firesoul> <alpine.DEB.2.20.1512090945570.30894@east.gentwo.org> <20151209195325.68eaf314@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov@virtuozzo.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 9 Dec 2015, Jesper Dangaard Brouer wrote:

> I really like the idea of making it able to free kmalloc'ed objects.
> But I hate to change the API again... (I do have a use-case in the
> network stack where I could use this feature).

Now is the time to fix the API since its not that much in use yet if at
all.

> I'm traveling (to Sweden) Thursday (afternoon) and will be back late
> Friday (and have to play Viking in the weekend), thus to be realistic
> I'll start working on this Monday, so we can get some benchmark numbers
> to guide this decision.

Ok great.
> > -		struct kmem_cache *s;
> > +		struct page *page;
> >
> > -		/* Support for memcg */
> > -		s = cache_from_obj(orig_s, p[size - 1]);
> > +		page = virt_to_head_page(p[size - 1]);
>
> Think we can drop this.

Well then you wont be able to check for a compound page. And you do not
want this check in build detached freelist.

>
> > -		size = build_detached_freelist(s, size, p, &df);
> > +		if (unlikely(!PageSlab(page))) {
> > +			BUG_ON(!PageCompound(page));
> > +			kfree_hook(p[size - 1]);
> > +			__free_kmem_pages(page, compound_order(page));
> > +			p[--size] = NULL;
> > +			continue;
> > +		}
>
> and move above into build_detached_freelist() and make it a little more
> pretty code wise (avoiding the p[size -1] juggling).

If we do this check here then we wont be needing it in
build_detached_freelist.

> > +
> > +		size = build_detached_freelist(page->slab_cache, size, p, &df);
>
> also think we should be able to drop the kmem_cache param "page->slab_cache".

Yep.

>
>
> >  		if (unlikely(!df.page))
> >  			continue;
> >
> > -		slab_free(s, df.page, df.freelist, df.tail, df.cnt, _RET_IP_);
> > +		slab_free(page->slab_cache, df.page, df.freelist, df.tail, df.cnt, _RET_IP_);

Then we need df.slab_cache or something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
