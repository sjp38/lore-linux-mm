Message-Id: <20070911200012.442552000@chello.nl>
References: <20070911195350.825778000@chello.nl>
Date: Tue, 11 Sep 2007 21:53:54 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 04/23] lib: percpu_counter variable batch
Content-Disposition: inline; filename=percpu_counter_batch.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org
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
--- linux-2.6.orig/include/linux/percpu_counter.h	2007-05-23 20:34:12.000000000 +0200
+++ linux-2.6/include/linux/percpu_counter.h	2007-05-23 20:36:06.000000000 +0200
@@ -32,9 +32,14 @@ struct percpu_counter {
 
 void percpu_counter_init(struct percpu_counter *fbc, s64 amount);
 void percpu_counter_destroy(struct percpu_counter *fbc);
-void percpu_counter_add(struct percpu_counter *fbc, s32 amount);
+void __percpu_counter_add(struct percpu_counter *fbc, s32 amount, s32 batch);
 s64 percpu_counter_sum(struct percpu_counter *fbc);
 
+static inline void percpu_counter_add(struct percpu_counter *fbc, s32 amount)
+{
+	__percpu_counter_add(fbc, amount, FBC_BATCH);
+}
+
 static inline s64 percpu_counter_read(struct percpu_counter *fbc)
 {
 	return fbc->count;
@@ -70,6 +75,9 @@ static inline void percpu_counter_destro
 {
 }
 
+#define __percpu_counter_add(fbc, amount, batch) \
+	percpu_counter_add(fbc, amount)
+
 static inline void
 percpu_counter_add(struct percpu_counter *fbc, s32 amount)
 {
Index: linux-2.6/lib/percpu_counter.c
===================================================================
--- linux-2.6.orig/lib/percpu_counter.c	2007-05-23 20:34:12.000000000 +0200
+++ linux-2.6/lib/percpu_counter.c	2007-05-23 20:36:21.000000000 +0200
@@ -14,7 +14,7 @@ static LIST_HEAD(percpu_counters);
 static DEFINE_MUTEX(percpu_counters_lock);
 #endif
 
-void percpu_counter_add(struct percpu_counter *fbc, s32 amount)
+void __percpu_counter_add(struct percpu_counter *fbc, s32 amount, s32 batch)
 {
 	long count;
 	s32 *pcount;
@@ -22,7 +22,7 @@ void percpu_counter_add(struct percpu_co
 
 	pcount = per_cpu_ptr(fbc->counters, cpu);
 	count = *pcount + amount;
-	if (count >= FBC_BATCH || count <= -FBC_BATCH) {
+	if (count >= batch || count <= -batch) {
 		spin_lock(&fbc->lock);
 		fbc->count += count;
 		*pcount = 0;
@@ -32,7 +32,7 @@ void percpu_counter_add(struct percpu_co
 	}
 	put_cpu();
 }
-EXPORT_SYMBOL(percpu_counter_add);
+EXPORT_SYMBOL(__percpu_counter_add);
 
 /*
  * Add up all the per-cpu counts, return the result.  This is a more accurate

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
