Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 4E3E76B0038
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 10:14:04 -0500 (EST)
Received: by qgcc31 with SMTP id c31so20011942qgc.3
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 07:14:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h82si3746533qhd.119.2015.12.08.07.14.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 07:14:03 -0800 (PST)
Date: Tue, 8 Dec 2015 16:13:57 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 2/2] slab: implement bulk free in SLAB allocator
Message-ID: <20151208161357.47323842@redhat.com>
In-Reply-To: <20151208145635.GI11488@esperanza>
References: <20151203155600.3589.86568.stgit@firesoul>
	<20151203155736.3589.67424.stgit@firesoul>
	<alpine.DEB.2.20.1512041111180.21819@east.gentwo.org>
	<20151207122549.109e82db@redhat.com>
	<alpine.DEB.2.20.1512070858140.8762@east.gentwo.org>
	<20151208141211.GH11488@esperanza>
	<alpine.DEB.2.20.1512080814350.20678@east.gentwo.org>
	<20151208145635.GI11488@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, brouer@redhat.com

On Tue, 8 Dec 2015 17:56:35 +0300
Vladimir Davydov <vdavydov@virtuozzo.com> wrote:

> On Tue, Dec 08, 2015 at 08:15:21AM -0600, Christoph Lameter wrote:
> > On Tue, 8 Dec 2015, Vladimir Davydov wrote:
> > 
> > > If producers are represented by different processes, they can belong to
> > > different memory cgroups, so that objects passed to the consumer will
> > > come from different kmem caches (per memcg caches), although they are
> > > all of the same kind. This means, we must call cache_from_obj() on each
> > > object passed to kmem_cache_free_bulk() in order to free each object to
> > > the cache it was allocated from.
> > 
> > The we should change the API so that we do not specify kmem_cache on bulk
> > free. Do it like kfree without any cache spec.
> > 
> 
> Don't think so, because AFAIU the whole kmem_cache_free_bulk
> optimization comes from the assumption that objects passed to it are
> likely to share the same slab page. So they must be of the same kind,
> otherwise no optimization would be possible and the function wouldn't
> perform any better than calling kfree directly in a for-loop. By
> requiring the caller to specify the cache we emphasize this.

I agree with Vladimir here.  The performance gain for SLUB is
especially depended on that objects are likely to share the same slab
page.  It might not hurt SLAB as much.

> Enabling kmemcg might break the assumption and neglect the benefit of
> using kmem_cache_free_bulk, but it is to be expected, because kmem
> accounting does not come for free. Callers who do care about the
> performance and count every cpu cycle will surely disable it, in which
> case cache_from_obj() will be a no-op and kmem_cache_free_bulk will bear
> fruit.

True, compiler does realize, when CONFIG_MEMCG_KMEM is disabled, that it
can optimize the call to cache_from_obj() away.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
