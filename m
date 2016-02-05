Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 79245440441
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 11:55:07 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id w123so71792852pfb.0
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 08:55:07 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id uv2si24987718pac.41.2016.02.05.08.55.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Feb 2016 08:55:06 -0800 (PST)
Date: Fri, 5 Feb 2016 19:54:54 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCHv6] mm: slab: free kmem_cache_node after destroy sysfs file
Message-ID: <20160205165454.GB22456@esperanza>
References: <1454687136-19298-1-git-send-email-dsafonov@virtuozzo.com>
 <20160205161124.GA26693@esperanza>
 <56B4D171.6000000@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <56B4D171.6000000@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, Feb 05, 2016 at 07:44:33PM +0300, Dmitry Safonov wrote:
...
> >>@@ -2414,8 +2415,6 @@ int __kmem_cache_shrink(struct kmem_cache *cachep, bool deactivate)
> >>  int __kmem_cache_shutdown(struct kmem_cache *cachep)
> >>  {
> >>-	int i;
> >>-	struct kmem_cache_node *n;
> >>  	int rc = __kmem_cache_shrink(cachep, false);
> >>  	if (rc)
> >>@@ -2423,6 +2422,14 @@ int __kmem_cache_shutdown(struct kmem_cache *cachep)
> >>  	free_percpu(cachep->cpu_cache);
> >And how come ->cpu_cache (and ->cpu_slab in case of SLUB) is special?
> >Can't sysfs access it either? I propose to introduce a method called
> >__kmem_cache_release (instead of __kmem_cache_free_nodes), which would
> >do all freeing, both per-cpu and per-node.
> AFAICS, they aren't used by this sysfs.

They are: alloc_calls_show -> list_locations -> flush_all accesses
->cpu_slab.

Thanks,
Vladimir

> Anyway, seems reasonable, will do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
