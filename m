Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 203BA6B0253
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 21:26:05 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so175963489pab.1
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 18:26:04 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id fn7si16824579pdb.248.2015.07.10.18.26.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jul 2015 18:26:03 -0700 (PDT)
Received: by padck2 with SMTP id ck2so11713938pad.0
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 18:26:03 -0700 (PDT)
Date: Sat, 11 Jul 2015 10:25:13 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [RFC] mm/shrinker: define INIT_SHRINKER macro
Message-ID: <20150711012513.GB811@swordfish>
References: <20150710011211.GB584@swordfish>
 <20150710153235.835c4992fbce526da23361d0@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150710153235.835c4992fbce526da23361d0@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (07/10/15 15:32), Andrew Morton wrote:
> > Shrinker API does not handle nicely unregister_shrinker() on a not-registered
> > ->shrinker. Looking at shrinker users, they all have to (a) carry on some sort
> > of a flag telling that "unregister_shrinker()" will not blow up... or (b) just
> > be fishy
> > 
> > ...
> >
> > I was thinking of a trivial INIT_SHRINKER macro to init `struct shrinker'
> > internal members (composed in email client, not tested)
> > 
> > include/linux/shrinker.h
> > 
> > #define INIT_SHRINKER(s)			\
> > 	do {					\
> > 		(s)->nr_deferred = NULL;	\
> > 		INIT_LIST_HEAD(&(s)->list);	\
> > 	} while (0)
> 
> Spose so.  Although it would be simpler to change unregister_shrinker()
> to bale out if list.next==NULL and then say "all zeroes is the
> initialized state".

Yes, or '->nr_deferred == NULL' -- we can't have NULL ->nr_deferred
in a properly registered shrinker (as of now)

register_shrinker()
...
        shrinker->nr_deferred = kzalloc(size, GFP_KERNEL);
        if (!shrinker->nr_deferred)
                return -ENOMEM;

        down_write(&shrinker_rwsem);
        list_add_tail(&shrinker->list, &shrinker_list);
        up_write(&shrinker_rwsem);
        return 0;
...


But that will not work if someone has accidentally passed not zeroed
out pointer to unregister.

e.g.

...

	struct foo *bar = kmalloc(..) /* no __GFP_ZERO */

	... something goes wrong and we 'goto err' before
	shrinker_register()

err:
	unregister_shrinker(&bar->shrinker);

...


->list.next and ->nr_deferred won't help us here.
That was the reason to have INIT_SHRINKER/shrinker_init().

But adding an additional check to unregister_shrinker() will not harm.


> > --- a/include/linux/shrinker.h
> > +++ b/include/linux/shrinker.h
> > @@ -63,6 +63,12 @@ struct shrinker {
> >  };
> >  #define DEFAULT_SEEKS 2 /* A good number if you don't know better. */
> >  
> > +#define INIT_SHRINKER(s) 			\
> > +	do {					\
> > +		INIT_LIST_HEAD(&(s)->list);	\
> > +		(s)->nr_deferred = NULL;	\
> > +	} while (0)
> > +
> 
> The only reason to make this a macro would be so that it can be used at
> compile-time, with something like
> 
> static struct shrinker my_shrinker = INIT_SHRINKER(&my_shrinker);
> 
> But as we're not planning on doing that, we implement it in C, please.
> 
> Also, shrinker_init() would be a better name.  Although we already
> mucked up shrinker_register() and shrinker_unregister().
> 

Sure. Will do. Thanks.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
