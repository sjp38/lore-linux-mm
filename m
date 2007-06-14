Message-Id: <20070614220446.614501106@chello.nl>
References: <20070614215817.389524447@chello.nl>
Date: Thu, 14 Jun 2007 23:58:21 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 04/17] lib: percpu_counter_set
Content-Disposition: inline; filename=percpu_counter_set.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, andrea@suse.de
List-ID: <linux-mm.kvack.org>

Provide a method to set a percpu counter to a specified value.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/percpu_counter.h |    6 ++++++
 lib/percpu_counter.c           |   13 +++++++++++++
 2 files changed, 19 insertions(+)

Index: linux-2.6/include/linux/percpu_counter.h
===================================================================
--- linux-2.6.orig/include/linux/percpu_counter.h	2007-05-23 20:37:41.000000000 +0200
+++ linux-2.6/include/linux/percpu_counter.h	2007-05-23 20:37:54.000000000 +0200
@@ -32,6 +32,7 @@ struct percpu_counter {
 
 void percpu_counter_init(struct percpu_counter *fbc, s64 amount);
 void percpu_counter_destroy(struct percpu_counter *fbc);
+void percpu_counter_set(struct percpu_counter *fbc, s64 amount);
 void __percpu_counter_mod(struct percpu_counter *fbc, s32 amount, s32 batch);
 void __percpu_counter_mod64(struct percpu_counter *fbc, s64 amount, s32 batch);
 s64 percpu_counter_sum(struct percpu_counter *fbc);
@@ -81,6 +82,11 @@ static inline void percpu_counter_destro
 {
 }
 
+static inline void percpu_counter_set(struct percpu_counter *fbc, s64 amount)
+{
+	fbc->count = amount;
+}
+
 #define __percpu_counter_mod(fbc, amount, batch) \
 	percpu_counter_mod(fbc, amount)
 
Index: linux-2.6/lib/percpu_counter.c
===================================================================
--- linux-2.6.orig/lib/percpu_counter.c	2007-05-23 20:37:34.000000000 +0200
+++ linux-2.6/lib/percpu_counter.c	2007-05-23 20:38:03.000000000 +0200
@@ -14,6 +14,19 @@ static LIST_HEAD(percpu_counters);
 static DEFINE_MUTEX(percpu_counters_lock);
 #endif
 
+void percpu_counter_set(struct percpu_counter *fbc, s64 amount)
+{
+	int cpu;
+
+	spin_lock(&fbc->lock);
+	for_each_possible_cpu(cpu) {
+		s32 *pcount = per_cpu_ptr(fbc->counters, cpu);
+		*pcount = 0;
+	}
+	fbc->count = amount;
+	spin_unlock(&fbc->lock);
+}
+
 void __percpu_counter_mod(struct percpu_counter *fbc, s32 amount, s32 batch)
 {
 	long count;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
