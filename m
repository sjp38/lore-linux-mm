Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6313D6B0266
	for <linux-mm@kvack.org>; Tue, 22 May 2018 12:43:04 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 3-v6so393918itj.8
        for <linux-mm@kvack.org>; Tue, 22 May 2018 09:43:04 -0700 (PDT)
Received: from a9-99.smtp-out.amazonses.com (a9-99.smtp-out.amazonses.com. [54.240.9.99])
        by mx.google.com with ESMTPS id s8-v6si258361itb.41.2018.05.22.09.43.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 May 2018 09:43:02 -0700 (PDT)
Date: Tue, 22 May 2018 16:43:02 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: fix race between kmem_cache destroy, create and
 deactivate
In-Reply-To: <20180521114227.233983ac7038a9f4bf5b7066@linux-foundation.org>
Message-ID: <0100016388bb8ade-de95df0e-6154-4ddc-98bb-ee33811cca85-000000@email.amazonses.com>
References: <20180521174116.171846-1-shakeelb@google.com> <20180521114227.233983ac7038a9f4bf5b7066@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, Linux MM <linux-mm@kvack.org>, cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Mon, 21 May 2018, Andrew Morton wrote:

> The patch seems depressingly complex.
>
> And a bit underdocumented...

Maybe separate out the bits that rename refcount to alias_count?

> > +	refcount_t refcount;
> > +	int alias_count;
>
> The semantic meaning of these two?  What locking protects alias_count?

slab_mutex

>
> >  	int object_size;
> >  	int align;
> >
> > diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
> > index 3773e26c08c1..532d4b6f83ed 100644
> > --- a/include/linux/slub_def.h
> > +++ b/include/linux/slub_def.h
> > @@ -97,7 +97,8 @@ struct kmem_cache {
> >  	struct kmem_cache_order_objects max;
> >  	struct kmem_cache_order_objects min;
> >  	gfp_t allocflags;	/* gfp flags to use on each alloc */
> > -	int refcount;		/* Refcount for slab cache destroy */
> > +	refcount_t refcount;	/* Refcount for slab cache destroy */
> > +	int alias_count;	/* Number of root kmem caches merged */
>
> "merged" what with what in what manner?

That is a basic SLUB feature.
