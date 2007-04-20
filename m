Message-Id: <20070420155502.787144532@chello.nl>
References: <20070420155154.898600123@chello.nl>
Date: Fri, 20 Apr 2007 17:51:58 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 04/10] lib: percpu_counter_mod64
Content-Disposition: inline; filename=percpu_counter_mod.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

Add percpu_counter_mod64() to allow large modifications.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/percpu_counter.h |    9 +++++++++
 lib/percpu_counter.c           |   28 ++++++++++++++++++++++++++++
 2 files changed, 37 insertions(+)

Index: linux-2.6/include/linux/percpu_counter.h
===================================================================
--- linux-2.6.orig/include/linux/percpu_counter.h	2007-04-12 13:54:55.000000000 +0200
+++ linux-2.6/include/linux/percpu_counter.h	2007-04-12 14:00:21.000000000 +0200
@@ -36,6 +36,7 @@ static inline void percpu_counter_destro
 }
 
 void percpu_counter_mod(struct percpu_counter *fbc, s32 amount);
+void percpu_counter_mod64(struct percpu_counter *fbc, s64 amount);
 s64 percpu_counter_sum(struct percpu_counter *fbc);
 
 static inline s64 percpu_counter_read(struct percpu_counter *fbc)
@@ -81,6 +82,14 @@ percpu_counter_mod(struct percpu_counter
 	preempt_enable();
 }
 
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
--- linux-2.6.orig/lib/percpu_counter.c	2006-07-31 13:07:38.000000000 +0200
+++ linux-2.6/lib/percpu_counter.c	2007-04-12 14:17:12.000000000 +0200
@@ -25,6 +25,34 @@ void percpu_counter_mod(struct percpu_co
 }
 EXPORT_SYMBOL(percpu_counter_mod);
 
+void percpu_counter_mod64(struct percpu_counter *fbc, s64 amount)
+{
+	long count;
+	s32 *pcount;
+	int cpu;
+
+	if (amount >= FBC_BATCH || amount <= -FBC_BATCH) {
+		spin_lock(&fbc->lock);
+		fbc->count += amount;
+		spin_unlock(&fbc->lock);
+		return;
+	}
+
+	cpu = get_cpu();
+	pcount = per_cpu_ptr(fbc->counters, cpu);
+	count = *pcount + amount;
+	if (count >= FBC_BATCH || count <= -FBC_BATCH) {
+		spin_lock(&fbc->lock);
+		fbc->count += count;
+		*pcount = 0;
+		spin_unlock(&fbc->lock);
+	} else {
+		*pcount = count;
+	}
+	put_cpu();
+}
+EXPORT_SYMBOL(percpu_counter_mod64);
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
