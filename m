Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 85F466B0005
	for <linux-mm@kvack.org>; Sun, 11 Nov 2018 14:44:22 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c12-v6so3759663ede.6
        for <linux-mm@kvack.org>; Sun, 11 Nov 2018 11:44:22 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o25-v6si2375968edt.64.2018.11.11.11.44.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Nov 2018 11:44:20 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wABJiAsw036616
	for <linux-mm@kvack.org>; Sun, 11 Nov 2018 14:44:19 -0500
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2npdbnsp6b-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 11 Nov 2018 14:44:19 -0500
Received: from localhost
	by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sun, 11 Nov 2018 19:44:18 -0000
From: "Paul E. McKenney" <paulmck@linux.ibm.com>
Subject: [PATCH tip/core/rcu 28/41] slab: Replace synchronize_sched() with synchronize_rcu()
Date: Sun, 11 Nov 2018 11:43:57 -0800
In-Reply-To: <20181111194104.GA4787@linux.ibm.com>
References: <20181111194104.GA4787@linux.ibm.com>
Message-Id: <20181111194410.6368-28-paulmck@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mingo@kernel.org, jiangshanlai@gmail.com, dipankar@in.ibm.com, akpm@linux-foundation.org, mathieu.desnoyers@efficios.com, josh@joshtriplett.org, tglx@linutronix.de, peterz@infradead.org, rostedt@goodmis.org, dhowells@redhat.com, edumazet@google.com, fweisbec@gmail.com, oleg@redhat.com, joel@joelfernandes.org, "Paul E. McKenney" <paulmck@linux.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org

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
-- 
2.17.1
