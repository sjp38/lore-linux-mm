Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 651FA6B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 21:11:49 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so174322142pdb.1
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 18:11:49 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id o6si11801358pdn.123.2015.07.09.18.11.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 18:11:48 -0700 (PDT)
Received: by pactm7 with SMTP id tm7so159127613pac.2
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 18:11:48 -0700 (PDT)
Date: Fri, 10 Jul 2015 10:12:11 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [RFC] mm/shrinker: define INIT_SHRINKER macro
Message-ID: <20150710011211.GB584@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Hello,

Forked from http://www.gossamer-threads.com/lists/linux/kernel/2209873#2209873
with some adjustments.

Shrinker API does not handle nicely unregister_shrinker() on a not-registered
->shrinker. Looking at shrinker users, they all have to (a) carry on some sort
of a flag telling that "unregister_shrinker()" will not blow up... or (b) just
be fishy

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

or (c) access private members `struct shrinker'

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


Note that `shrink.list.next' check.


We can't `fix' unregister_shrinker() (by looking at some flag or checking
`!shrinker->nr_deferred'), simply because someone can do something like
this:

:struct foo {
:	const char *b;
: ...
:	struct shrinker s;
:};
:
:void bar(void)
:{
:	struct foo *f = kmalloc(...); /* or kzalloc() to NULL deref it*/
:
:	if (!f)
:		return;
:
:	f->a = kmalloc(...);
:	if (!f->a)
:		goto err;
: ...
:	register_shrinker(...);
: ...
:	return;
:
:err:
:	unregister_shrinker(&f->s);
:			^^^^^^ boom
: ...
:}

Passing a `garbaged' or zeroed out `struct shrinker' to unregister_shrinker()

:void unregister_shrinker(struct shrinker *shrinker)
:{
:        down_write(&shrinker_rwsem);
:        list_del(&shrinker->list);
:        up_write(&shrinker_rwsem);
:        kfree(shrinker->nr_deferred);
:}


I was thinking of a trivial INIT_SHRINKER macro to init `struct shrinker'
internal members (composed in email client, not tested)

include/linux/shrinker.h

#define INIT_SHRINKER(s)			\
	do {					\
		(s)->nr_deferred = NULL;	\
		INIT_LIST_HEAD(&(s)->list);	\
	} while (0)

Of course, every shrinker user need to INIT_SHRINKER() early enough to
guarantee that unregister_shrinker() will be legal should anything go
wrong. Example:

:struct zs_pool *zs_create_pool(char *name, gfp_t flags)
:{
:	..
:+	INIT_SHRINKER(&pool->shrinker);
:
:	pool->name = kstrdup(name, GFP_KERNEL);
:	if (!pool->name)
		goto err;
:	..
:	register_shrinker(&pool->shrinker);
:	..
:	return pool;
:
:err:
:	unregister_shrinker(&pool->shrinker);
:	..
:}

Not much better, but at least some hacks can be avoided and
accidental unregister_shrinker() happening in error path is
safe now.

How does it sound?

---

 include/linux/shrinker.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 4fcacd9..10adfc2 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -63,6 +63,12 @@ struct shrinker {
 };
 #define DEFAULT_SEEKS 2 /* A good number if you don't know better. */
 
+#define INIT_SHRINKER(s) 			\
+	do {					\
+		INIT_LIST_HEAD(&(s)->list);	\
+		(s)->nr_deferred = NULL;	\
+	} while (0)
+
 /* Flags */
 #define SHRINKER_NUMA_AWARE	(1 << 0)
 #define SHRINKER_MEMCG_AWARE	(1 << 1)
-- 
2.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
