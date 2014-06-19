Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id 281356B0038
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 16:29:42 -0400 (EDT)
Received: by mail-qc0-f177.google.com with SMTP id r5so2659982qcx.8
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 13:29:41 -0700 (PDT)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id k6si7827166qct.2.2014.06.19.13.29.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 13:29:41 -0700 (PDT)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 19 Jun 2014 14:29:40 -0600
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 719DC3E40083
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 14:29:30 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s5JKTTIU10354976
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 22:29:30 +0200
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s5JKXPEi028413
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 14:33:25 -0600
Date: Thu, 19 Jun 2014 13:29:28 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: slub/debugobjects: lockup when freeing memory
Message-ID: <20140619202928.GG4904@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <53A2F406.4010109@oracle.com>
 <alpine.DEB.2.11.1406191001090.2785@gentwo.org>
 <20140619165247.GA4904@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1406192127100.5170@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1406192127100.5170@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Christoph Lameter <cl@gentwo.org>, Sasha Levin <sasha.levin@oracle.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 19, 2014 at 09:29:08PM +0200, Thomas Gleixner wrote:
> On Thu, 19 Jun 2014, Paul E. McKenney wrote:
> 
> > On Thu, Jun 19, 2014 at 10:03:04AM -0500, Christoph Lameter wrote:
> > > On Thu, 19 Jun 2014, Sasha Levin wrote:
> > > 
> > > > [  690.770137] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
> > > > [  690.770137] __slab_alloc (mm/slub.c:1732 mm/slub.c:2205 mm/slub.c:2369)
> > > > [  690.770137] ? __lock_acquire (kernel/locking/lockdep.c:3189)
> > > > [  690.770137] ? __debug_object_init (lib/debugobjects.c:100 lib/debugobjects.c:312)
> > > > [  690.770137] kmem_cache_alloc (mm/slub.c:2442 mm/slub.c:2484 mm/slub.c:2489)
> > > > [  690.770137] ? __debug_object_init (lib/debugobjects.c:100 lib/debugobjects.c:312)
> > > > [  690.770137] ? debug_object_activate (lib/debugobjects.c:439)
> > > > [  690.770137] __debug_object_init (lib/debugobjects.c:100 lib/debugobjects.c:312)
> > > > [  690.770137] debug_object_init (lib/debugobjects.c:365)
> > > > [  690.770137] rcuhead_fixup_activate (kernel/rcu/update.c:231)
> > > > [  690.770137] debug_object_activate (lib/debugobjects.c:280 lib/debugobjects.c:439)
> > > > [  690.770137] ? discard_slab (mm/slub.c:1486)
> > > > [  690.770137] __call_rcu (kernel/rcu/rcu.h:76 (discriminator 2) kernel/rcu/tree.c:2585 (discriminator 2))
> > > 
> > > __call_rcu does a slab allocation? This means __call_rcu can no longer be
> > > used in slab allocators? What happened?
> > 
> > My guess is that the root cause is a double call_rcu(), call_rcu_sched(),
> > call_rcu_bh(), or call_srcu().
> > 
> > Perhaps the DEBUG_OBJECTS code now allocates memory to report errors?
> > That would be unfortunate...
> 
> Well, no. Look at the callchain:
> 
> __call_rcu
>     debug_object_activate
>        rcuhead_fixup_activate
>           debug_object_init
>               kmem_cache_alloc
> 
> So call rcu activates the object, but the object has no reference in
> the debug objects code so the fixup code is called which inits the
> object and allocates a reference ....

OK, got it.  And you are right, call_rcu() has done this for a very
long time, so not sure what changed.  But it seems like the right
approach is to provide a debug-object-free call_rcu_alloc() for use
by the memory allocators.

Seem reasonable?  If so, please see the following patch.

						Thanx, Paul

------------------------------------------------------------------------

rcu: Provide call_rcu_alloc() and call_rcu_sched_alloc() to avoid recursion

The sl*b allocators use call_rcu() to manage object lifetimes, but
call_rcu() can use debug-objects, which in turn invokes the sl*b
allocators.  These allocators are not prepared for this sort of
recursion, which can result in failures.

This commit therefore creates call_rcu_alloc() and call_rcu_sched_alloc(),
which act as their call_rcu() and call_rcu_sched() counterparts, but
which avoid invoking debug-objects.  These new API members are intended
only for use by the sl*b allocators, and this commit makes the sl*b
allocators use call_rcu_alloc().  Why call_rcu_sched_alloc()?  Because
in CONFIG_PREEMPT=n kernels, call_rcu() maps to call_rcu_sched(), so
therefore call_rcu_alloc() must map to call_rcu_sched_alloc().

Reported-by: Sasha Levin <sasha.levin@oracle.com>
Set-straight-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
index d5e40a42cc43..1f708a7f9e7d 100644
--- a/include/linux/rcupdate.h
+++ b/include/linux/rcupdate.h
@@ -140,13 +140,24 @@ void do_trace_rcu_torture_read(const char *rcutorturename,
  * if CPU A and CPU B are the same CPU (but again only if the system has
  * more than one CPU).
  */
-void call_rcu(struct rcu_head *head,
-	      void (*func)(struct rcu_head *head));
+void call_rcu(struct rcu_head *head, void (*func)(struct rcu_head *head));
+
+/**
+ * call_rcu__alloc() - Queue an RCU for invocation after grace period.
+ * @head: structure to be used for queueing the RCU updates.
+ * @func: actual callback function to be invoked after the grace period
+ *
+ * Similar to call_rcu(), but avoids invoking debug-objects.  This permits
+ * this to be called from allocators without needing to worry about
+ * recursive calls into those allocators for debug-objects allocations.
+ */
+void call_rcu_alloc(struct rcu_head *head, void (*func)(struct rcu_head *rcu));
 
 #else /* #ifdef CONFIG_PREEMPT_RCU */
 
 /* In classic RCU, call_rcu() is just call_rcu_sched(). */
 #define	call_rcu	call_rcu_sched
+#define	call_rcu_alloc	call_rcu_sched_alloc
 
 #endif /* #else #ifdef CONFIG_PREEMPT_RCU */
 
@@ -196,6 +207,19 @@ void call_rcu_bh(struct rcu_head *head,
 void call_rcu_sched(struct rcu_head *head,
 		    void (*func)(struct rcu_head *rcu));
 
+/**
+ * call_rcu_sched_alloc() - Queue RCU for invocation after sched grace period.
+ * @head: structure to be used for queueing the RCU updates.
+ * @func: actual callback function to be invoked after the grace period
+ *
+ * Similar to call_rcu_sched(), but avoids invoking debug-objects.
+ * This permits this to be called from allocators without needing to
+ * worry about recursive calls into those allocators for debug-objects
+ * allocations.
+ */
+void call_rcu_sched_alloc(struct rcu_head *head,
+			  void (*func)(struct rcu_head *rcu));
+
 void synchronize_sched(void);
 
 #ifdef CONFIG_PREEMPT_RCU
diff --git a/kernel/rcu/tiny.c b/kernel/rcu/tiny.c
index d9efcc13008c..515e60067c53 100644
--- a/kernel/rcu/tiny.c
+++ b/kernel/rcu/tiny.c
@@ -338,15 +338,14 @@ void synchronize_sched(void)
 EXPORT_SYMBOL_GPL(synchronize_sched);
 
 /*
- * Helper function for call_rcu() and call_rcu_bh().
+ * Provide call_rcu() function, but avoid invoking debug objects.
  */
-static void __call_rcu(struct rcu_head *head,
-		       void (*func)(struct rcu_head *rcu),
-		       struct rcu_ctrlblk *rcp)
+static void __call_rcu_nodo(struct rcu_head *head,
+			    void (*func)(struct rcu_head *rcu),
+			    struct rcu_ctrlblk *rcp)
 {
 	unsigned long flags;
 
-	debug_rcu_head_queue(head);
 	head->func = func;
 	head->next = NULL;
 
@@ -358,6 +357,17 @@ static void __call_rcu(struct rcu_head *head,
 }
 
 /*
+ * Helper function for call_rcu() and call_rcu_bh().
+ */
+static void __call_rcu(struct rcu_head *head,
+		       void (*func)(struct rcu_head *rcu),
+		       struct rcu_ctrlblk *rcp)
+{
+	debug_rcu_head_queue(head);
+	__call_rcu_nodo(head, func, rcp);
+}
+
+/*
  * Post an RCU callback to be invoked after the end of an RCU-sched grace
  * period.  But since we have but one CPU, that would be after any
  * quiescent state.
@@ -369,6 +379,18 @@ void call_rcu_sched(struct rcu_head *head, void (*func)(struct rcu_head *rcu))
 EXPORT_SYMBOL_GPL(call_rcu_sched);
 
 /*
+ * Similar to call_rcu_sched(), but avoids debug-objects and thus calls
+ * into the memory allocators, which don't appreciate that sort of
+ * recursion.
+ */
+void call_rcu_sched_alloc(struct rcu_head *head,
+			  void (*func)(struct rcu_head *rcu))
+{
+	__call_rcu_nodo(head, func, &rcu_sched_ctrlblk);
+}
+EXPORT_SYMBOL_GPL(call_rcu_sched_alloc);
+
+/*
  * Post an RCU bottom-half callback to be invoked after any subsequent
  * quiescent state.
  */
diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index 8c47d04ecdea..593195d38850 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -2640,25 +2640,16 @@ static void rcu_leak_callback(struct rcu_head *rhp)
 }
 
 /*
- * Helper function for call_rcu() and friends.  The cpu argument will
- * normally be -1, indicating "currently running CPU".  It may specify
- * a CPU only if that CPU is a no-CBs CPU.  Currently, only _rcu_barrier()
- * is expected to specify a CPU.
+ * Provide call_rcu() function, but avoid invoking debug objects.
  */
 static void
-__call_rcu(struct rcu_head *head, void (*func)(struct rcu_head *rcu),
-	   struct rcu_state *rsp, int cpu, bool lazy)
+__call_rcu_nodo(struct rcu_head *head, void (*func)(struct rcu_head *rcu),
+		struct rcu_state *rsp, int cpu, bool lazy)
 {
 	unsigned long flags;
 	struct rcu_data *rdp;
 
 	WARN_ON_ONCE((unsigned long)head & 0x1); /* Misaligned rcu_head! */
-	if (debug_rcu_head_queue(head)) {
-		/* Probable double call_rcu(), so leak the callback. */
-		ACCESS_ONCE(head->func) = rcu_leak_callback;
-		WARN_ONCE(1, "__call_rcu(): Leaked duplicate callback\n");
-		return;
-	}
 	head->func = func;
 	head->next = NULL;
 
@@ -2704,6 +2695,25 @@ __call_rcu(struct rcu_head *head, void (*func)(struct rcu_head *rcu),
 }
 
 /*
+ * Helper function for call_rcu() and friends.  The cpu argument will
+ * normally be -1, indicating "currently running CPU".  It may specify
+ * a CPU only if that CPU is a no-CBs CPU.  Currently, only _rcu_barrier()
+ * is expected to specify a CPU.
+ */
+static void
+__call_rcu(struct rcu_head *head, void (*func)(struct rcu_head *rcu),
+	   struct rcu_state *rsp, int cpu, bool lazy)
+{
+	if (debug_rcu_head_queue(head)) {
+		/* Probable double call_rcu(), so leak the callback. */
+		ACCESS_ONCE(head->func) = rcu_leak_callback;
+		WARN_ONCE(1, "__call_rcu(): Leaked duplicate callback\n");
+		return;
+	}
+	__call_rcu_nodo(head, func, rsp, cpu, lazy);
+}
+
+/*
  * Queue an RCU-sched callback for invocation after a grace period.
  */
 void call_rcu_sched(struct rcu_head *head, void (*func)(struct rcu_head *rcu))
@@ -2713,6 +2723,18 @@ void call_rcu_sched(struct rcu_head *head, void (*func)(struct rcu_head *rcu))
 EXPORT_SYMBOL_GPL(call_rcu_sched);
 
 /*
+ * Similar to call_rcu_sched(), but avoids debug-objects and thus calls
+ * into the memory allocators, which don't appreciate that sort of
+ * recursion.
+ */
+void call_rcu_sched_alloc(struct rcu_head *head,
+			  void (*func)(struct rcu_head *rcu))
+{
+	__call_rcu_nodo(head, func, &rcu_sched_state, -1, 0);
+}
+EXPORT_SYMBOL_GPL(call_rcu_sched_alloc);
+
+/*
  * Queue an RCU callback for invocation after a quicker grace period.
  */
 void call_rcu_bh(struct rcu_head *head, void (*func)(struct rcu_head *rcu))
diff --git a/kernel/rcu/tree_plugin.h b/kernel/rcu/tree_plugin.h
index 569b390daa15..e9362d7f8328 100644
--- a/kernel/rcu/tree_plugin.h
+++ b/kernel/rcu/tree_plugin.h
@@ -679,6 +679,17 @@ void call_rcu(struct rcu_head *head, void (*func)(struct rcu_head *rcu))
 }
 EXPORT_SYMBOL_GPL(call_rcu);
 
+/*
+ * Similar to call_rcu(), but avoids debug-objects and thus calls
+ * into the memory allocators, which don't appreciate that sort of
+ * recursion.
+ */
+void call_rcu_alloc(struct rcu_head *head, void (*func)(struct rcu_head *rcu))
+{
+	__call_rcu_nodo(head, func, &rcu_preempt_state, -1, 0);
+}
+EXPORT_SYMBOL_GPL(call_rcu_alloc);
+
 /**
  * synchronize_rcu - wait until a grace period has elapsed.
  *
diff --git a/mm/slab.c b/mm/slab.c
index 9ca3b87edabc..1e5de0d39701 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1994,7 +1994,7 @@ static void slab_destroy(struct kmem_cache *cachep, struct page *page)
 		 * we can use it safely.
 		 */
 		head = (void *)&page->rcu_head;
-		call_rcu(head, kmem_rcu_free);
+		call_rcu_alloc(head, kmem_rcu_free);
 
 	} else {
 		kmem_freepages(cachep, page);
diff --git a/mm/slob.c b/mm/slob.c
index 21980e0f39a8..47ad4a43521a 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -605,7 +605,7 @@ void kmem_cache_free(struct kmem_cache *c, void *b)
 		struct slob_rcu *slob_rcu;
 		slob_rcu = b + (c->size - sizeof(struct slob_rcu));
 		slob_rcu->size = c->size;
-		call_rcu(&slob_rcu->head, kmem_rcu_free);
+		call_rcu_alloc(&slob_rcu->head, kmem_rcu_free);
 	} else {
 		__kmem_cache_free(b, c->size);
 	}
diff --git a/mm/slub.c b/mm/slub.c
index b2b047327d76..7f01e57fd99f 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1512,7 +1512,7 @@ static void free_slab(struct kmem_cache *s, struct page *page)
 			head = (void *)&page->lru;
 		}
 
-		call_rcu(head, rcu_free_slab);
+		call_rcu_alloc(head, rcu_free_slab);
 	} else
 		__free_slab(s, page);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
