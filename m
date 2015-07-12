Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 765C86B0253
	for <linux-mm@kvack.org>; Sat, 11 Jul 2015 22:48:24 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so43478721pdj.3
        for <linux-mm@kvack.org>; Sat, 11 Jul 2015 19:48:24 -0700 (PDT)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com. [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id x10si21548330pdr.182.2015.07.11.19.48.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Jul 2015 19:48:23 -0700 (PDT)
Received: by pdbep18 with SMTP id ep18so205408943pdb.1
        for <linux-mm@kvack.org>; Sat, 11 Jul 2015 19:48:23 -0700 (PDT)
Date: Sun, 12 Jul 2015 11:47:32 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH 0/2] mm/shrinker: make unregister_shrinker() less fragile
Message-ID: <20150712024732.GA787@swordfish>
References: <1436583115-6323-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20150711100232.GA4607@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150711100232.GA4607@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Hello Christoph,

On (07/11/15 03:02), Christoph Hellwig wrote:
> > Shrinker API does not handle nicely unregister_shrinker() on a not-registered
> > ->shrinker. Looking at shrinker users, they all have to
> > (a) carry on some sort of a flag to make sure that "unregister_shrinker()"
> > will not blow up later
> > (b) be fishy (potentially can Oops)
> > (c) access private members `struct shrinker' (e.g. `shrink.list.next')
> 
> Ayone who does that is broken.  You just need to have clear init (with
> proper unwinding) and exit functions and order things properly.  It
> works like most register/unregister calls and should stay that way.
> 
> Maye you you should ty to explain what practical problem you're seeing
> to start with.

Yes, but the main difference here is that it seems that shrinker users
don't tend to treat shrinker registration failures as fatal errors and
just continue with shrinker functionality disabled. And it makes sense.

(copy paste from https://lkml.org/lkml/2015/7/9/751)

> Ayone who does that is broken

I'm afraid, in that case we almost don't have not-broken shrinker users.


-- ignoring register_shrinker() error

: int ldlm_pools_init(void)
: {
:         int rc;
:
:         rc = ldlm_pools_thread_start();
:         if (rc == 0) {
:                 register_shrinker(&ldlm_pools_srv_shrinker);
:                 register_shrinker(&ldlm_pools_cli_shrinker);
:         }
:         return rc;
: }
: EXPORT_SYMBOL(ldlm_pools_init);
:
: void ldlm_pools_fini(void)
: {
:         unregister_shrinker(&ldlm_pools_srv_shrinker);
:         unregister_shrinker(&ldlm_pools_cli_shrinker);
:         ldlm_pools_thread_stop();
: }
: EXPORT_SYMBOL(ldlm_pools_fini);


-- and here

:void i915_gem_shrinker_init(struct drm_i915_private *dev_priv)
:{
:        dev_priv->mm.shrinker.scan_objects = i915_gem_shrinker_scan;
:        dev_priv->mm.shrinker.count_objects = i915_gem_shrinker_count;
:        dev_priv->mm.shrinker.seeks = DEFAULT_SEEKS;
:        register_shrinker(&dev_priv->mm.shrinker);
:
:        dev_priv->mm.oom_notifier.notifier_call = i915_gem_shrinker_oom;
:        register_oom_notifier(&dev_priv->mm.oom_notifier);
:}


-- and here

:int __init gfs2_glock_init(void)
:{
:        unsigned i;
...
:        register_shrinker(&glock_shrinker);
:
:        return 0;
:}
:
:void gfs2_glock_exit(void)
:{
:        unregister_shrinker(&glock_shrinker);
:        destroy_workqueue(glock_workqueue);
:        destroy_workqueue(gfs2_delete_workqueue);
:}


-- and here

:static int __init lowmem_init(void)
:{
:        register_shrinker(&lowmem_shrinker);
:        return 0;
:}
:
:static void __exit lowmem_exit(void)
:{
:        unregister_shrinker(&lowmem_shrinker);
:}



-- accessing private member 'c->shrink.list.next' to distinguish between
'register_shrinker() was successful and need to unregister it' and
'register_shrinker() failed, don't unregister_shrinker() because it
may Oops'

:struct cache_set {
: ...
:	struct shrinker		shrink;
: ...
:};
:
: ...
:
: void bch_btree_cache_free(struct cache_set *c)
: {
:         struct btree *b;
:         struct closure cl;
:         closure_init_stack(&cl);
:
:         if (c->shrink.list.next)
:                 unregister_shrinker(&c->shrink);


-- and here
:int bch_btree_cache_alloc(struct cache_set *c)
:{
...
:        register_shrinker(&c->shrink);
:
:
...
:
:void bch_btree_cache_free(struct cache_set *c)
:{
:        struct btree *b;
:        struct closure cl;
:        closure_init_stack(&cl);
:
:        if (c->shrink.list.next)
:                unregister_shrinker(&c->shrink);
:


And so on and on.

In fact, 'git grep = register_shrinker' gives only

$ git grep '= register_shrinker'
fs/ext4/extents_status.c:       err = register_shrinker(&sbi->s_es_shrinker);
fs/nfsd/nfscache.c:     status = register_shrinker(&nfsd_reply_cache_shrinker);
fs/ubifs/super.c:       err = register_shrinker(&ubifs_shrinker_info);
mm/huge_memory.c:       err = register_shrinker(&huge_zero_page_shrinker);
mm/workingset.c:        ret = register_shrinker(&workingset_shadow_shrinker);


The rest is 'broken'.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
