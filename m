Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 267376B026B
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 00:55:15 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 80so174417522pfy.2
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 21:55:15 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id h14si14765157plk.127.2017.01.13.21.55.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 21:55:14 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id b1so344431pgc.1
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 21:55:14 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 9/9] slab: remove slub sysfs interface files early for empty memcg caches
Date: Sat, 14 Jan 2017 00:54:49 -0500
Message-Id: <20170114055449.11044-10-tj@kernel.org>
In-Reply-To: <20170114055449.11044-1-tj@kernel.org>
References: <20170114055449.11044-1-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov.dev@gmail.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com, Tejun Heo <tj@kernel.org>

With kmem cgroup support enabled, kmem_caches can be created and
destroyed frequently and a great number of near empty kmem_caches can
accumulate if there are a lot of transient cgroups and the system is
not under memory pressure.  When memory reclaim starts under such
conditions, it can lead to consecutive deactivation and destruction of
many kmem_caches, easily hundreds of thousands on moderately large
systems, exposing scalability issues in the current slab management
code.  This is one of the patches to address the issue.

Each cache has a number of sysfs interface files under
/sys/kernel/slab.  On a system with a lot of memory and transient
memcgs, the number of interface files which have to be removed once
memory reclaim kicks in can reach millions.

Signed-off-by: Tejun Heo <tj@kernel.org>
Reported-by: Jay Vana <jsvana@fb.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/slub.c | 25 +++++++++++++++++++++++--
 1 file changed, 23 insertions(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 8621940..41a3da7 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3951,8 +3951,20 @@ int __kmem_cache_shrink(struct kmem_cache *s)
 #ifdef CONFIG_MEMCG
 static void kmemcg_cache_deact_after_rcu(struct kmem_cache *s)
 {
-	/* called with all the locks held after a sched RCU grace period */
-	__kmem_cache_shrink(s);
+	/*
+	 * Called with all the locks held after a sched RCU grace period.
+	 * Even if @s becomes empty after shrinking, we can't know that @s
+	 * doesn't have allocations already in-flight and thus can't
+	 * destroy @s until the associated memcg is released.
+	 *
+	 * However, let's remove the sysfs files for empty caches here.
+	 * Each cache has a lot of interface files which aren't
+	 * particularly useful for empty draining caches; otherwise, we can
+	 * easily end up with millions of unnecessary sysfs files on
+	 * systems which have a lot of memory and transient cgroups.
+	 */
+	if (!__kmem_cache_shrink(s))
+		sysfs_slab_remove(s);
 }
 
 void __kmemcg_cache_deactivate(struct kmem_cache *s)
@@ -5650,6 +5662,15 @@ static void sysfs_slab_remove(struct kmem_cache *s)
 		 */
 		return;
 
+	if (!s->kobj.state_in_sysfs)
+		/*
+		 * For a memcg cache, this may be called during
+		 * deactivation and again on shutdown.  Remove only once.
+		 * A cache is never shut down before deactivation is
+		 * complete, so no need to worry about synchronization.
+		 */
+		return;
+
 #ifdef CONFIG_MEMCG
 	kset_unregister(s->memcg_kset);
 #endif
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
