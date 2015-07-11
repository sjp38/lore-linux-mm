Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id EF06F6B0253
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 21:49:02 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so176161293pab.1
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 18:49:02 -0700 (PDT)
Received: from mail-pd0-x234.google.com (mail-pd0-x234.google.com. [2607:f8b0:400e:c02::234])
        by mx.google.com with ESMTPS id hk6si16948367pac.147.2015.07.10.18.49.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jul 2015 18:49:02 -0700 (PDT)
Received: by pdrg1 with SMTP id g1so60873686pdr.2
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 18:49:02 -0700 (PDT)
Date: Sat, 11 Jul 2015 10:48:12 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [RFC] mm/shrinker: define INIT_SHRINKER macro
Message-ID: <20150711014812.GD811@swordfish>
References: <20150710011211.GB584@swordfish>
 <20150710153235.835c4992fbce526da23361d0@linux-foundation.org>
 <20150711012513.GB811@swordfish>
 <20150710183357.30605207.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150710183357.30605207.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (07/10/15 18:33), Andrew Morton wrote:
> > > > I was thinking of a trivial INIT_SHRINKER macro to init `struct shrinker'
> > > > internal members (composed in email client, not tested)
> > > > 
> > > > include/linux/shrinker.h
> > > > 
> > > > #define INIT_SHRINKER(s)			\
> > > > 	do {					\
> > > > 		(s)->nr_deferred = NULL;	\
> > > > 		INIT_LIST_HEAD(&(s)->list);	\
> > > > 	} while (0)
> > > 
> > > Spose so.  Although it would be simpler to change unregister_shrinker()
> > > to bale out if list.next==NULL and then say "all zeroes is the
> > > initialized state".
> > 
> > Yes, or '->nr_deferred == NULL' -- we can't have NULL ->nr_deferred
> > in a properly registered shrinker (as of now)
> 
> list.next seems safer because that will always be non-zero.  But
> whatever - we can change it later.
>  
> > But that will not work if someone has accidentally passed not zeroed
> > out pointer to unregister.
> 
> I wouldn't worry about that really.  If you pass a pointer to
> uninitialized memory, the kernel will explode.  That's true of just
> about every pointer-accepting function in the kernel.
>

True. But with shrinker it's hard to say whether we have a properly
initialized shrinker embedded in our `struct foo' or we don't (unless
we treat register_shrinker() errors as a show stopper) by simply looking at
shrinker struct (w/o touching it's private members). In zsmalloc, for
instance, we don't consider failed register_shrinker() to be critical
enough to forbid zs_pool creation and usage. It makes things harder later
in zs_destroy_pool(), because we need to carry some sort of flag for that
purpose. But `list.next' check in unregister_shrinker() would suffice in
zsmalloc case, I must admit, because we kzalloc() the entire zs_pool
struct.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
