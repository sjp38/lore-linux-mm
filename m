Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id D39A76B00F4
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 06:09:40 -0400 (EDT)
Received: by mail-la0-f46.google.com with SMTP id hz20so3664857lab.33
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 03:09:39 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ka3si41706161lbc.5.2014.06.10.03.09.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jun 2014 03:09:39 -0700 (PDT)
Date: Tue, 10 Jun 2014 14:09:25 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v2 7/8] slub: make dead memcg caches discard free
 slabs immediately
Message-ID: <20140610100924.GC6293@esperanza>
References: <cover.1402060096.git.vdavydov@parallels.com>
 <3b53266b76556dd042bbf6147207c70473572a7e.1402060096.git.vdavydov@parallels.com>
 <20140610080935.GG19036@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140610080935.GG19036@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: akpm@linux-foundation.org, cl@linux.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 10, 2014 at 05:09:35PM +0900, Joonsoo Kim wrote:
> On Fri, Jun 06, 2014 at 05:22:44PM +0400, Vladimir Davydov wrote:
> > @@ -2064,6 +2066,21 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
> >  
> >  	} while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page)
> >  								!= oldpage);
> > +
> > +	if (memcg_cache_dead(s)) {
> > +               bool done = false;
> > +               unsigned long flags;
> > +
> > +               local_irq_save(flags);
> > +               if (this_cpu_read(s->cpu_slab->partial) == page) {
> > +                       unfreeze_partials(s, this_cpu_ptr(s->cpu_slab));
> > +                       done = true;
> > +               }
> > +               local_irq_restore(flags);
> > +
> > +               if (!done)
> > +                       flush_all(s);
> > +	}
> 
> Now, slab_free() is non-preemptable so flush_all() isn't needed.

Right! Will fix.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
