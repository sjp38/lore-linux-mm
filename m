Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8CFEF6B0255
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 03:30:53 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so228010809pab.0
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 00:30:53 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id yd7si3715191pab.46.2015.11.10.00.30.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 00:30:52 -0800 (PST)
Date: Tue, 10 Nov 2015 11:30:42 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH V3 1/2] slub: fix kmem cgroup bug in kmem_cache_alloc_bulk
Message-ID: <20151110083042.GS31308@esperanza>
References: <20151109181604.8231.22983.stgit@firesoul>
 <20151109181703.8231.66384.stgit@firesoul>
 <20151109191335.GM31308@esperanza>
 <alpine.DEB.2.20.1511091603240.26497@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1511091603240.26497@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Nov 09, 2015 at 04:04:51PM -0600, Christoph Lameter wrote:
> On Mon, 9 Nov 2015, Vladimir Davydov wrote:
> 
> > I think it must be &object
> >
> > BTW why is object defined as void **? I suspect we can safely drop one
> > star.
> 
> See get_freepointer()
> 
> static inline void *get_freepointer(struct kmem_cache *s, void *object)
> {
>         return *(void **)(object + s->offset);
> }

In this function object has type (void *)

> 
> The object at some point has a freepointer and ** allows the use of the
> s->offset field to get to it.

But it doesn't mean we have to define it as (void **) in
slab_alloc_node. Actually, the fact that object is of type (void **) is
never used in slab_alloc_node, and all functions called by it accept
(void *) for object, not (void **). Dropping one star there doesn't
break anything and looks less confusing IMO.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
