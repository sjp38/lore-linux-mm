Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 65F846B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 13:24:52 -0500 (EST)
Received: by mail-ie0-f181.google.com with SMTP id rp18so10327455iec.12
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 10:24:52 -0800 (PST)
Received: from resqmta-po-10v.sys.comcast.net (resqmta-po-10v.sys.comcast.net. [2001:558:fe16:19:96:114:154:169])
        by mx.google.com with ESMTPS id 9si7982051iod.8.2015.01.26.10.24.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 26 Jan 2015 10:24:51 -0800 (PST)
Date: Mon, 26 Jan 2015 12:24:49 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm 1/3] slub: don't fail kmem_cache_shrink if slab
 placement optimization fails
In-Reply-To: <20150126170147.GB28978@esperanza>
Message-ID: <alpine.DEB.2.11.1501261216120.16638@gentwo.org>
References: <cover.1422275084.git.vdavydov@parallels.com> <3804a429071f939e6b4f654b6c6426c1fdd95f7e.1422275084.git.vdavydov@parallels.com> <alpine.DEB.2.11.1501260944550.15849@gentwo.org> <20150126170147.GB28978@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 26 Jan 2015, Vladimir Davydov wrote:

> Anyways, I think that silently relying on the fact that the allocator
> never fails small allocations is kind of unreliable. What if this

We are not doing that though. If the allocation fails we do nothing.

> > > +			if (page->inuse < objects)
> > > +				list_move(&page->lru,
> > > +					  slabs_by_inuse + page->inuse);
> > >  			if (!page->inuse)
> > >  				n->nr_partial--;
> > >  		}
> >
> > The condition is always true. A page that has page->inuse == objects
> > would not be on the partial list.
> >
>
> This is in case we failed to allocate the slabs_by_inuse array. We only
> have a list for empty slabs then (on stack).

Ok in that case objects == 1. If you want to do this maybe do it in a more
general way?

You could allocate an array on the stack to deal with the common cases. I
believe an array of 32 objects would be fine to allocate and cover most of
the slab caches on the system? Would eliminate most of the allocations in
kmem_cache_shrink.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
