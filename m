Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9146B82F64
	for <linux-mm@kvack.org>; Sat,  7 Nov 2015 11:53:44 -0500 (EST)
Received: by oige206 with SMTP id e206so27832865oig.2
        for <linux-mm@kvack.org>; Sat, 07 Nov 2015 08:53:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id lg6si2794895oeb.20.2015.11.07.08.53.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Nov 2015 08:53:43 -0800 (PST)
Date: Sat, 7 Nov 2015 17:53:38 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH V2 2/2] slub: add missing kmem cgroup support to
 kmem_cache_free_bulk
Message-ID: <20151107175338.12a0368b@redhat.com>
In-Reply-To: <20151105162514.GI29259@esperanza>
References: <20151105153704.1115.10475.stgit@firesoul>
	<20151105153756.1115.41409.stgit@firesoul>
	<20151105162514.GI29259@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, brouer@redhat.com

On Thu, 5 Nov 2015 19:25:14 +0300
Vladimir Davydov <vdavydov@virtuozzo.com> wrote:

> On Thu, Nov 05, 2015 at 04:38:06PM +0100, Jesper Dangaard Brouer wrote:
> > Initial implementation missed support for kmem cgroup support
> > in kmem_cache_free_bulk() call, add this.
> > 
> > If CONFIG_MEMCG_KMEM is not enabled, the compiler should
> > be smart enough to not add any asm code.
> > 
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > 
> > ---
> > V2: Fixes according to input from:
> >  Vladimir Davydov <vdavydov@virtuozzo.com>
> >  and Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> >  mm/slub.c |    3 +++
> >  1 file changed, 3 insertions(+)
> > 
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 8e9e9b2ee6f3..bc64514ad1bb 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -2890,6 +2890,9 @@ void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
> >  	do {
> >  		struct detached_freelist df;
> >  
> > +		/* Support for memcg */
> > +		s = cache_from_obj(s, p[size - 1]);
> > +
> 
> AFAIU all objects in the array should come from the same cache (should
> they?), so it should be enough to call this only once:

Can we be sure all objects in the array come from same cache?

Imagine my use case:
 1. application send packet alloc a SKB (from a slab)
 2. packet TX to NIC via DMA
 3. TX DMA completion cleans up 256 packets and kmem free SKBs

I don't know enough about mem cgroups... but I can imagine two
applications belonging to different mem-cgroups sending packet out same
NIC and later getting their SKB (pkt-metadata struct) free'ed during
the same TX completion (TX softirq) cycle, as a bulk free.

With my limited mem cgroups, it looks like memcg works on the slab-page
level?  And what I'm doing in this code is to group object together
belonging to the same slab-page.

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
