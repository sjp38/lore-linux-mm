Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C443F6B7117
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 17:47:11 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id 143so9922119pgc.3
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 14:47:11 -0800 (PST)
Received: from terminus.zytor.com (terminus.zytor.com. [198.137.202.136])
        by mx.google.com with ESMTPS id d1si17219626pla.412.2018.12.04.14.47.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Dec 2018 14:47:10 -0800 (PST)
Date: Tue, 4 Dec 2018 14:47:04 -0800
From: "tip-bot for Paul E. McKenney" <tipbot@zytor.com>
Message-ID: <tip-6564a25e6c185e65ca3148ed6e18f80882f6798f@git.kernel.org>
Reply-To: tglx@linutronix.de, penberg@kernel.org, mingo@kernel.org,
        cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, rientjes@google.com,
        paulmck@linux.ibm.com, hpa@zytor.com
Subject: [tip:core/rcu] slab: Replace synchronize_sched() with
 synchronize_rcu()
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, hpa@zytor.com, paulmck@linux.ibm.com, rientjes@google.com, mingo@kernel.org, penberg@kernel.org, tglx@linutronix.de, cl@linux.com

Commit-ID:  6564a25e6c185e65ca3148ed6e18f80882f6798f
Gitweb:     https://git.kernel.org/tip/6564a25e6c185e65ca3148ed6e18f80882f6798f
Author:     Paul E. McKenney <paulmck@linux.ibm.com>
AuthorDate: Tue, 6 Nov 2018 19:24:33 -0800
Committer:  Paul E. McKenney <paulmck@linux.ibm.com>
CommitDate: Tue, 27 Nov 2018 09:21:45 -0800

slab: Replace synchronize_sched() with synchronize_rcu()

Now that synchronize_rcu() waits for preempt-disable regions of code
as well as RCU read-side critical sections, synchronize_sched() can be
replaced by synchronize_rcu().  This commit therefore makes this change.

Signed-off-by: Paul E. McKenney <paulmck@linux.ibm.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: <linux-mm@kvack.org>
---
 mm/slab.c        | 4 ++--
 mm/slab_common.c | 6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 2a5654bb3b3f..3abb9feb3818 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -962,10 +962,10 @@ static int setup_kmem_cache_node(struct kmem_cache *cachep,
 	 * To protect lockless access to n->shared during irq disabled context.
 	 * If n->shared isn't NULL in irq disabled context, accessing to it is
 	 * guaranteed to be valid until irq is re-enabled, because it will be
-	 * freed after synchronize_sched().
+	 * freed after synchronize_rcu().
 	 */
 	if (old_shared && force_change)
-		synchronize_sched();
+		synchronize_rcu();
 
 fail:
 	kfree(old_shared);
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 7eb8dc136c1c..9c11e8a937d2 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -724,7 +724,7 @@ void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
 	css_get(&s->memcg_params.memcg->css);
 
 	s->memcg_params.deact_fn = deact_fn;
-	call_rcu_sched(&s->memcg_params.deact_rcu_head, kmemcg_deactivate_rcufn);
+	call_rcu(&s->memcg_params.deact_rcu_head, kmemcg_deactivate_rcufn);
 }
 
 void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
@@ -839,11 +839,11 @@ static void flush_memcg_workqueue(struct kmem_cache *s)
 	mutex_unlock(&slab_mutex);
 
 	/*
-	 * SLUB deactivates the kmem_caches through call_rcu_sched. Make
+	 * SLUB deactivates the kmem_caches through call_rcu. Make
 	 * sure all registered rcu callbacks have been invoked.
 	 */
 	if (IS_ENABLED(CONFIG_SLUB))
-		rcu_barrier_sched();
+		rcu_barrier();
 
 	/*
 	 * SLAB and SLUB create memcg kmem_caches through workqueue and SLUB
