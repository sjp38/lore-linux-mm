Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id QAA03616
	for <linux-mm@kvack.org>; Sun, 15 Sep 2002 16:28:31 -0700 (PDT)
Message-ID: <3D851B5A.49F4296B@digeo.com>
Date: Sun, 15 Sep 2002 16:44:27 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH] ageable slab callbacks
References: <200209151436.20171.tomlins@cam.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Ed.

Ed Tomlinson wrote:
> 
> Hi,
> 
> This lets the vm use callbacks to shrink ageable caches.   With this we avoid
> having to change vmscan if an ageable cache family is added.  It also batches
> calls to the prune methods (SHRINK_BATCH).

I do believe it would be better to move the batching logic into
slab.c and not make the individual cache implementations have
to know about it.  Just put the accumulators into cachep-> and
only call the shrinker when the counter reaches the threshold?


> +/*
> + * shrinker_t
> + *
> + * Manages list of shrinker callbacks used by the vm to apply pressure to
> + * prunable caches.
> + */
> +
> +typedef struct shrinker_s {
> +       kmem_shrinker_t         shrinker;
> +       struct list_head        next;
> +       int                     seeks;  /* seeks to recreate an obj */
> +       int                     nr;     /* objs pending delete */
> +} shrinker_t;

We're trying to get away from these sorts of typedefs, please.
Just `struct shrinker' or whatever will be fine.

> +
> +static spinlock_t              shrinker_lock = SPIN_LOCK_UNLOCKED;
> +static struct list_head        shrinker_list;

static LIST_HEAD(shrinker_list) would initialise this at compile
time...

> ..
> +void kmem_set_shrinker(int seeks, kmem_shrinker_t theshrinker)
> +{
> +       shrinker_t *shrinkerp;
> +       shrinkerp = kmalloc(sizeof(shrinker_t),GFP_KERNEL);
> +       BUG_ON(!shrinkerp);
> +       shrinkerp->shrinker = theshrinker;
> +       shrinkerp->seeks = seeks;
> +       shrinkerp->nr = 0;
> +       spin_lock(&shrinker_lock);
> +       list_add(&shrinkerp->next, &shrinker_list);
> +       spin_lock(&shrinker_lock);
> +}

spin_unlock() here ;)  (You can still run an SMP kernel on UP, and
that would have picked this up).


> +
> +/* Call the shrink functions to age shrinkable caches */
> +int kmem_do_shrinks(int pages, int scanned,  unsigned int gfp_mask)
> +{
> +struct list_head *p;
> +       int ratio;
> +
> +       spin_lock(&shrinker_lock);
> +
> +       list_for_each(p,&shrinker_list) {
> +               shrinker_t *shrinkerp = list_entry(p, shrinker_t, next);
> +               ratio = pages / (shrinkerp->seeks * scanned + 1) + 1;
> +               shrinkerp->nr = (*shrinkerp->shrinker)(shrinkerp->nr,
> +                                       ratio, gfp_mask);
> +       }
> +
> +       spin_unlock(&shrinker_lock);
> +
> +       return 0;
> +}

The cache shrink functions can sleep, and cannot be called under a
spinlock.

Which begs the question: how do we stop a cache from vanishing
while we play with it?  cache_chain_sem I guess.

> ...
> +
> +       INIT_LIST_HEAD(&shrinker_list);
> +       spin_lock_init(&shrinker_lock);
>  }

The list can be statically initialised, as above.  The lock has already
been initialised.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
