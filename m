Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5B9916B0032
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 03:23:15 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id y10so17493973pdj.9
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 00:23:15 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id cl8si486580pdb.257.2015.01.27.00.23.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jan 2015 00:23:14 -0800 (PST)
Date: Tue, 27 Jan 2015 11:23:01 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm 3/3] slub: make dead caches discard free slabs
 immediately
Message-ID: <20150127082301.GD28978@esperanza>
References: <cover.1422275084.git.vdavydov@parallels.com>
 <42d95683e3c7f4bb00be4d777e2b334e8981d552.1422275084.git.vdavydov@parallels.com>
 <20150127080009.GB11358@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150127080009.GB11358@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Joonsoo,

On Tue, Jan 27, 2015 at 05:00:09PM +0900, Joonsoo Kim wrote:
> On Mon, Jan 26, 2015 at 03:55:29PM +0300, Vladimir Davydov wrote:
> > @@ -3381,6 +3390,15 @@ void __kmem_cache_shrink(struct kmem_cache *s)
> >  		kmalloc(sizeof(struct list_head) * objects, GFP_KERNEL);
> >  	unsigned long flags;
> >  
> > +	if (deactivate) {
> > +		/*
> > +		 * Disable empty slabs caching. Used to avoid pinning offline
> > +		 * memory cgroups by freeable kmem pages.
> > +		 */
> > +		s->cpu_partial = 0;
> > +		s->min_partial = 0;
> > +	}
> > +
> 
> Maybe, kick_all_cpus_sync() is needed here since object would
> be freed asynchronously so they can't see this updated value.

I thought flush_all() should do the trick, no?

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
