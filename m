Date: Mon, 19 Nov 2007 14:35:14 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/2] x86_64: Configure stack size
In-Reply-To: <4741D3C4.4020809@sgi.com>
Message-ID: <Pine.LNX.4.64.0711191433480.15026@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0711121147350.27017@schroedinger.engr.sgi.com>
 <4741D3C4.4020809@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>, apw@shadowen.org, Jack Steiner <steiner@sgi.com>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here is a simple patch to use a per cpu cpumask instead of constructing 
one on the stack. I have been running awhile with this one:

Do not use stack to allocate cpumask for cpumask_of_cpu

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/cpumask.h |   12 +-----------
 include/linux/percpu.h  |    2 ++
 kernel/sched.c          |    6 ++++++
 3 files changed, 9 insertions(+), 11 deletions(-)

Index: linux-2.6/include/linux/cpumask.h
===================================================================
--- linux-2.6.orig/include/linux/cpumask.h	2007-11-17 17:10:13.508534650 -0800
+++ linux-2.6/include/linux/cpumask.h	2007-11-17 17:11:34.816785513 -0800
@@ -222,17 +222,7 @@ int __next_cpu(int n, const cpumask_t *s
 #define next_cpu(n, src)	1
 #endif
 
-#define cpumask_of_cpu(cpu)						\
-({									\
-	typeof(_unused_cpumask_arg_) m;					\
-	if (sizeof(m) == sizeof(unsigned long)) {			\
-		m.bits[0] = 1UL<<(cpu);					\
-	} else {							\
-		cpus_clear(m);						\
-		cpu_set((cpu), m);					\
-	}								\
-	m;								\
-})
+#define cpumask_of_cpu(cpu)	per_cpu(cpu_mask, cpu)
 
 #define CPU_MASK_LAST_WORD BITMAP_LAST_WORD_MASK(NR_CPUS)
 
Index: linux-2.6/include/linux/percpu.h
===================================================================
--- linux-2.6.orig/include/linux/percpu.h	2007-11-17 17:10:13.516534409 -0800
+++ linux-2.6/include/linux/percpu.h	2007-11-17 17:11:34.816785513 -0800
@@ -21,6 +21,8 @@
 	(__per_cpu_end - __per_cpu_start + PERCPU_MODULE_RESERVE)
 #endif	/* PERCPU_ENOUGH_ROOM */
 
+DECLARE_PER_CPU(cpumask_t, cpu_mask);
+
 /*
  * Must be an lvalue. Since @var must be a simple identifier,
  * we force a syntax error here if it isn't.
Index: linux-2.6/kernel/sched.c
===================================================================
--- linux-2.6.orig/kernel/sched.c	2007-11-17 17:10:13.524534454 -0800
+++ linux-2.6/kernel/sched.c	2007-11-17 17:11:34.816785513 -0800
@@ -6725,6 +6725,9 @@ static void init_cfs_rq(struct cfs_rq *c
 	cfs_rq->min_vruntime = (u64)(-(1LL << 20));
 }
 
+DEFINE_PER_CPU(cpumask_t, cpu_mask);
+EXPORT_PER_CPU_SYMBOL(cpu_mask);
+
 void __init sched_init(void)
 {
 	int highest_cpu = 0;
@@ -6734,6 +6737,9 @@ void __init sched_init(void)
 		struct rt_prio_array *array;
 		struct rq *rq;
 
+		/* This makes cpumask_of_cpu work */
+		cpu_set(i, per_cpu(cpu_mask, i));
+
 		rq = cpu_rq(i);
 		spin_lock_init(&rq->lock);
 		lockdep_set_class(&rq->lock, &rq->rq_lock_key);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
