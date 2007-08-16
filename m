Message-Id: <20070816074625.733774000@chello.nl>
References: <20070816074525.065850000@chello.nl>
Date: Thu, 16 Aug 2007 09:45:30 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 05/23] lib: make percpu_counter_add take s64
Content-Disposition: inline; filename=percpu_counter_add64.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

percpu_counter is a s64 counter, make _add consitent.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/percpu_counter.h |    6 +++---
 lib/percpu_counter.c           |    4 ++--
 2 files changed, 5 insertions(+), 5 deletions(-)

Index: linux-2.6/include/linux/percpu_counter.h
===================================================================
--- linux-2.6.orig/include/linux/percpu_counter.h
+++ linux-2.6/include/linux/percpu_counter.h
@@ -32,10 +32,10 @@ struct percpu_counter {
 
 void percpu_counter_init(struct percpu_counter *fbc, s64 amount);
 void percpu_counter_destroy(struct percpu_counter *fbc);
-void __percpu_counter_add(struct percpu_counter *fbc, s32 amount, s32 batch);
+void __percpu_counter_add(struct percpu_counter *fbc, s64 amount, s32 batch);
 s64 percpu_counter_sum(struct percpu_counter *fbc);
 
-static inline void percpu_counter_add(struct percpu_counter *fbc, s32 amount)
+static inline void percpu_counter_add(struct percpu_counter *fbc, s64 amount)
 {
 	__percpu_counter_add(fbc, amount, FBC_BATCH);
 }
@@ -79,7 +79,7 @@ static inline void percpu_counter_destro
 	percpu_counter_add(fbc, amount)
 
 static inline void
-percpu_counter_add(struct percpu_counter *fbc, s32 amount)
+percpu_counter_add(struct percpu_counter *fbc, s64 amount)
 {
 	preempt_disable();
 	fbc->count += amount;
Index: linux-2.6/lib/percpu_counter.c
===================================================================
--- linux-2.6.orig/lib/percpu_counter.c
+++ linux-2.6/lib/percpu_counter.c
@@ -14,9 +14,9 @@ static LIST_HEAD(percpu_counters);
 static DEFINE_MUTEX(percpu_counters_lock);
 #endif
 
-void __percpu_counter_add(struct percpu_counter *fbc, s32 amount, s32 batch)
+void __percpu_counter_add(struct percpu_counter *fbc, s64 amount, s32 batch)
 {
-	long count;
+	s64 count;
 	s32 *pcount;
 	int cpu = get_cpu();
 

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
