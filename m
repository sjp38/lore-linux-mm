Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 407166B0254
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 09:56:53 -0500 (EST)
Received: by lbblt2 with SMTP id lt2so12516267lbb.3
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 06:56:52 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id r13si1879575lfe.161.2015.12.08.06.56.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 06:56:51 -0800 (PST)
Date: Tue, 8 Dec 2015 17:56:35 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [RFC PATCH 2/2] slab: implement bulk free in SLAB allocator
Message-ID: <20151208145635.GI11488@esperanza>
References: <20151203155600.3589.86568.stgit@firesoul>
 <20151203155736.3589.67424.stgit@firesoul>
 <alpine.DEB.2.20.1512041111180.21819@east.gentwo.org>
 <20151207122549.109e82db@redhat.com>
 <alpine.DEB.2.20.1512070858140.8762@east.gentwo.org>
 <20151208141211.GH11488@esperanza>
 <alpine.DEB.2.20.1512080814350.20678@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1512080814350.20678@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Dec 08, 2015 at 08:15:21AM -0600, Christoph Lameter wrote:
> On Tue, 8 Dec 2015, Vladimir Davydov wrote:
> 
> > If producers are represented by different processes, they can belong to
> > different memory cgroups, so that objects passed to the consumer will
> > come from different kmem caches (per memcg caches), although they are
> > all of the same kind. This means, we must call cache_from_obj() on each
> > object passed to kmem_cache_free_bulk() in order to free each object to
> > the cache it was allocated from.
> 
> The we should change the API so that we do not specify kmem_cache on bulk
> free. Do it like kfree without any cache spec.
> 

Don't think so, because AFAIU the whole kmem_cache_free_bulk
optimization comes from the assumption that objects passed to it are
likely to share the same slab page. So they must be of the same kind,
otherwise no optimization would be possible and the function wouldn't
perform any better than calling kfree directly in a for-loop. By
requiring the caller to specify the cache we emphasize this.

Enabling kmemcg might break the assumption and neglect the benefit of
using kmem_cache_free_bulk, but it is to be expected, because kmem
accounting does not come for free. Callers who do care about the
performance and count every cpu cycle will surely disable it, in which
case cache_from_obj() will be a no-op and kmem_cache_free_bulk will bear
fruit.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
