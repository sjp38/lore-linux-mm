Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 350BB6B003C
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 09:22:54 -0400 (EDT)
Received: by mail-la0-f50.google.com with SMTP id b8so1526562lan.9
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 06:22:53 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id u3si10705657laj.103.2014.06.06.06.22.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jun 2014 06:22:52 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 5/8] slub: make slab_free non-preemptable
Date: Fri, 6 Jun 2014 17:22:42 +0400
Message-ID: <7cd6784a36ed997cc6631615d98e11e02e811b1b.1402060096.git.vdavydov@parallels.com>
In-Reply-To: <cover.1402060096.git.vdavydov@parallels.com>
References: <cover.1402060096.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, iamjoonsoo.kim@lge.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Since per memcg cache destruction is scheduled when the last slab is
freed, to avoid use-after-free in kmem_cache_free we should either
rearrange code in kmem_cache_free so that it won't dereference the cache
ptr after freeing the object, or wait for all kmem_cache_free's to
complete before proceeding to cache destruction.

The former approach isn't a good option from the future development
point of view, because every modifications to kmem_cache_free must be
done with great care then. Hence we should provide a method to wait for
all currently executing kmem_cache_free's to finish.

This patch makes SLUB's implementation of kmem_cache_free
non-preemptable. As a result, synchronize_sched() will work as a barrier
against kmem_cache_free's in flight, so that issuing it before cache
destruction will protect us against the use-after-free.

This won't affect performance of kmem_cache_free, because we already
disable preemption there, and this patch only moves preempt_enable to
the end of the function. Neither should it affect the system latency,
because kmem_cache_free is extremely short, even in its slow path.

SLAB's version of kmem_cache_free already proceeds with irqs disabled,
so nothing to be done there.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/slub.c |   10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 35741592be8c..e46d6abe8a68 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2673,18 +2673,11 @@ static __always_inline void slab_free(struct kmem_cache *s,
 
 	slab_free_hook(s, x);
 
-redo:
-	/*
-	 * Determine the currently cpus per cpu slab.
-	 * The cpu may change afterward. However that does not matter since
-	 * data is retrieved via this pointer. If we are on the same cpu
-	 * during the cmpxchg then the free will succedd.
-	 */
 	preempt_disable();
+redo:
 	c = this_cpu_ptr(s->cpu_slab);
 
 	tid = c->tid;
-	preempt_enable();
 
 	if (likely(page == c->page)) {
 		set_freepointer(s, object, c->freelist);
@@ -2701,6 +2694,7 @@ redo:
 	} else
 		__slab_free(s, page, x, addr);
 
+	preempt_enable();
 }
 
 void kmem_cache_free(struct kmem_cache *s, void *x)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
