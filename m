Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 925C16B0038
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 23:04:21 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so123300468pab.1
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 20:04:21 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id e4si1385539pdn.255.2015.07.07.20.04.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 20:04:20 -0700 (PDT)
Received: by pacgz10 with SMTP id gz10so49708860pac.3
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 20:04:20 -0700 (PDT)
Date: Wed, 8 Jul 2015 12:04:10 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6 7/7] zsmalloc: use shrinker to trigger auto-compaction
Message-ID: <20150708030410.GA873@blaptop.AC68U>
References: <1436270221-17844-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1436270221-17844-8-git-send-email-sergey.senozhatsky@gmail.com>
 <20150707134445.GD3898@blaptop>
 <20150707144107.GC1450@swordfish>
 <20150707150143.GC23003@blaptop>
 <20150707151204.GE1450@swordfish>
 <20150708021836.GA1520@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150708021836.GA1520@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hi Sergey,

On Wed, Jul 08, 2015 at 11:18:36AM +0900, Sergey Senozhatsky wrote:
> On (07/08/15 00:12), Sergey Senozhatsky wrote:
> > > I don't think it would fail in *real practice*.
> > > Althout it might happen, what does zram could help in that cases?
> > > 
> > 
> > This argument depends on the current register_shrinker() implementation,
> > should some one add additional return branch there and it's done.
> > 
> > > If it were failed, it means there is already little memory on the system
> > > so zram could not be helpful for those environment.
> > > IOW, zram should be enabled earlier.
> > > 
> > > If you want it strongly, please reproduce such failing and prove that
> > > zram was helpful for the system.
> > 
> > No, thanks. I'll just remove it.
> > 
> 
> hm... This makes error path a bit ugly. What we have now is
> pretty straight forward
> 
> ... zs_create_pool(char *name, gfp_t flags)
> {
> 	..
> 	if (zs_register_shrinker(pool) == 0)
> 		pool->shrinker_enabled = true;
> 	..
> err:
> 	zs_destroy_pool(pool);
> 	return NULL;
> }
> 
> zs_destroy_pool() does a destruction. It performs unconditional
> zs_unregister_shrinker(), which does unregister_shrinker() _if needed_.
> 
> Shrinker API does not handle nicely unregister_shrinker() on a not-registered
> ->shrinker. And error path can be triggered even before we do register_shrinker(),
> so we can't 'fix' unregister_shrinker() in a common way, doing something like
> 
>  void unregister_shrinker(struct shrinker *shrinker)
>  {
> +       if (!unlikely(shrinker->nr_deferred))
> +               return;
> +
>         down_write(&shrinker_rwsem);
>         list_del(&shrinker->list);
>         up_write(&shrinker_rwsem);
> 
> 
> (just for example), because someone can accidentally pass a dirty (not zeroed
> out) `struct shrinker'. e.g.
> 
> struct foo {
> 	const char *b;
> ...
> 	struct shrinker s;
> };
> 
> void bar(void)
> {
> 	struct foo *f = kmalloc(...);
> 
> 	if (!f)
> 		return;
> 
> 	f->a = kmalloc(...);
> 	if (!f->a)
> 		goto err;
> 
> err:
> 	unregister_shrinker(f->s);
> 			^^^^^^ boom
> 	...
> }
> 
> 

Yes, it's ugly.

> 
> So... options:
> 
> (a) we need something to signify that zs_unregister_shrinker() was successful

I think a) is simple way to handle it now.
I don't want to stuck with this issue.

Please comment out why we need such boolean so after someone who has interest
on shrinker clean-up is able to grab a chance.

Thanks!

> 
> or
> 
> (b) factor out 'core' part of zs_destroy_pool() and do a full destruction when
> called from the outside (from zram for example), or a partial destruction when
> called from zs_create_pool() error path.
> 
> 
> 
> or
> 
> (c) introduce INIT_SHRINKER macro to init `struct shrinker' internal
> members
> 
> (!!! composed in email client, not tested !!!)
> 
> include/linux/shrinker.h
> 
> #define INIT_SHRINKER(s)			\
> 	do {					\
> 		(s)->nr_deferred = NULL;	\
> 		INIT_LIST_HEAD(&(s)->list);	\
> 	} while (0)
> 
> 
> and do
> 
> struct zs_pool *zs_create_pool(char *name, gfp_t flags)
> {
> 	..
> 	INIT_SHRINKER(&pool->shrinker);
> 
> 	pool->name = kstrdup(name, GFP_KERNEL);
> 	..
> }
> 
> 
> 
> Looking at shrinker users, they all have to carry on some sort of
> a flag telling that "unregister_shrinker()" will not blow up... or
> just be fishy... like
> 
>  int ldlm_pools_init(void)
>  {
>          int rc;
> 
>          rc = ldlm_pools_thread_start();
>          if (rc == 0) {
>                  register_shrinker(&ldlm_pools_srv_shrinker);
>                  register_shrinker(&ldlm_pools_cli_shrinker);
>          }
>          return rc;
>  }
>  EXPORT_SYMBOL(ldlm_pools_init);
> 
>  void ldlm_pools_fini(void)
>  {
>          unregister_shrinker(&ldlm_pools_srv_shrinker);
>          unregister_shrinker(&ldlm_pools_cli_shrinker);
>          ldlm_pools_thread_stop();
>  }
>  EXPORT_SYMBOL(ldlm_pools_fini);
> 
> 
> 
> or access private members of the `struct shrinker', like
> 
> 
> struct cache_set {
> ...
> 	struct shrinker		shrink;
> ...
> };
> 
>  void bch_btree_cache_free(struct cache_set *c)
>  {
>          struct btree *b;
>          struct closure cl;
>          closure_init_stack(&cl);
> 
>          if (c->shrink.list.next)
>                  unregister_shrinker(&c->shrink);
> 
> 
> Note that `shrink.list.next' check.
> 
> 	-ss

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
