Message-Id: <20070510101128.804168529@chello.nl>
References: <20070510100839.621199408@chello.nl>
Date: Thu, 10 May 2007 12:08:41 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 02/15] lib: percpu_counter variable batch
Content-Disposition: inline; filename=percpu_counter_batch.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

Because the current batch setup has an quadric error bound on the counter,
allow for an alternative setup.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/percpu_counter.h |   10 +++++++++-
 lib/percpu_counter.c           |    6 +++---
 2 files changed, 12 insertions(+), 4 deletions(-)

Index: linux-2.6/include/linux/percpu_counter.h
===================================================================
--- linux-2.6.orig/include/linux/percpu_counter.h	2007-04-29 18:14:37.000000000 +0200
+++ linux-2.6/include/linux/percpu_counter.h	2007-04-29 18:15:26.000000000 +0200
@@ -38,9 +38,14 @@ static inline void percpu_counter_destro
 	free_percpu(fbc->counters);
 }
 
-void percpu_counter_mod(struct percpu_counter *fbc, s32 amount);
+void __percpu_counter_mod(struct percpu_counter *fbc, s32 amount, s32 batch);
 s64 percpu_counter_sum(struct percpu_counter *fbc);
 
+static inline void percpu_counter_mod(struct percpu_counter *fbc, s32 amount)
+{
+	__percpu_counter_mod(fbc, amount, FBC_BATCH);
+}
+
 static inline s64 percpu_counter_read(struct percpu_counter *fbc)
 {
 	return fbc->count;
@@ -76,6 +81,9 @@ static inline void percpu_counter_destro
 {
 }
 
+#define __percpu_counter_mod(fbc, amount, batch) \
+	percpu_counter_mod(fbc, amount)
+
 static inline void
 percpu_counter_mod(struct percpu_counter *fbc, s32 amount)
 {
Index: linux-2.6/lib/percpu_counter.c
===================================================================
--- linux-2.6.orig/lib/percpu_counter.c	2007-04-29 18:14:37.000000000 +0200
+++ linux-2.6/lib/percpu_counter.c	2007-04-29 18:14:40.000000000 +0200
@@ -5,7 +5,7 @@
 #include <linux/percpu_counter.h>
 #include <linux/module.h>
 
-void percpu_counter_mod(struct percpu_counter *fbc, s32 amount)
+void __percpu_counter_mod(struct percpu_counter *fbc, s32 amount, s32 batch)
 {
 	long count;
 	s32 *pcount;
@@ -13,7 +13,7 @@ void percpu_counter_mod(struct percpu_co
 
 	pcount = per_cpu_ptr(fbc->counters, cpu);
 	count = *pcount + amount;
-	if (count >= FBC_BATCH || count <= -FBC_BATCH) {
+	if (count >= batch || count <= -batch) {
 		spin_lock(&fbc->lock);
 		fbc->count += count;
 		*pcount = 0;
@@ -23,7 +23,7 @@ void percpu_counter_mod(struct percpu_co
 	}
 	put_cpu();
 }
-EXPORT_SYMBOL(percpu_counter_mod);
+EXPORT_SYMBOL(__percpu_counter_mod);
 
 /*
  * Add up all the per-cpu counts, return the result.  This is a more accurate

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
