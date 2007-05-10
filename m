Message-Id: <20070510101128.887438283@chello.nl>
References: <20070510100839.621199408@chello.nl>
Date: Thu, 10 May 2007 12:08:42 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 03/15] lib: percpu_counter_mod64
Content-Disposition: inline; filename=percpu_counter_mod.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

Add percpu_counter_mod64() to allow large modifications.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/percpu_counter.h |   17 +++++++++++++++++
 lib/percpu_counter.c           |   20 ++++++++++++++++++++
 2 files changed, 37 insertions(+)

Index: linux-2.6/include/linux/percpu_counter.h
===================================================================
--- linux-2.6.orig/include/linux/percpu_counter.h	2007-04-29 18:15:26.000000000 +0200
+++ linux-2.6/include/linux/percpu_counter.h	2007-04-29 18:16:49.000000000 +0200
@@ -39,6 +39,7 @@ static inline void percpu_counter_destro
 }
 
 void __percpu_counter_mod(struct percpu_counter *fbc, s32 amount, s32 batch);
+void __percpu_counter_mod64(struct percpu_counter *fbc, s64 amount, s32 batch);
 s64 percpu_counter_sum(struct percpu_counter *fbc);
 
 static inline void percpu_counter_mod(struct percpu_counter *fbc, s32 amount)
@@ -46,6 +47,11 @@ static inline void percpu_counter_mod(st
 	__percpu_counter_mod(fbc, amount, FBC_BATCH);
 }
 
+static inline void percpu_counter_mod64(struct percpu_counter *fbc, s64 amount)
+{
+	__percpu_counter_mod64(fbc, amount, FBC_BATCH);
+}
+
 static inline s64 percpu_counter_read(struct percpu_counter *fbc)
 {
 	return fbc->count;
@@ -92,6 +98,17 @@ percpu_counter_mod(struct percpu_counter
 	preempt_enable();
 }
 
+#define __percpu_counter_mod64(fbc, amount, batch) \
+	percpu_counter_mod64(fbc, amount)
+
+static inline void
+percpu_counter_mod64(struct percpu_counter *fbc, s64 amount)
+{
+	preempt_disable();
+	fbc->count += amount;
+	preempt_enable();
+}
+
 static inline s64 percpu_counter_read(struct percpu_counter *fbc)
 {
 	return fbc->count;
Index: linux-2.6/lib/percpu_counter.c
===================================================================
--- linux-2.6.orig/lib/percpu_counter.c	2007-04-29 18:14:40.000000000 +0200
+++ linux-2.6/lib/percpu_counter.c	2007-04-29 18:15:34.000000000 +0200
@@ -25,6 +25,26 @@ void __percpu_counter_mod(struct percpu_
 }
 EXPORT_SYMBOL(__percpu_counter_mod);
 
+void __percpu_counter_mod64(struct percpu_counter *fbc, s64 amount, s32 batch)
+{
+	s64 count;
+	s32 *pcount;
+	int cpu = get_cpu();
+
+	pcount = per_cpu_ptr(fbc->counters, cpu);
+	count = *pcount + amount;
+	if (count >= batch || count <= -batch) {
+		spin_lock(&fbc->lock);
+		fbc->count += count;
+		*pcount = 0;
+		spin_unlock(&fbc->lock);
+	} else {
+		*pcount = count;
+	}
+	put_cpu();
+}
+EXPORT_SYMBOL(__percpu_counter_mod64);
+
 /*
  * Add up all the per-cpu counts, return the result.  This is a more accurate
  * but much slower version of percpu_counter_read_positive()

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
