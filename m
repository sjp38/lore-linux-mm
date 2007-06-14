Message-Id: <20070614220446.724626895@chello.nl>
References: <20070614215817.389524447@chello.nl>
Date: Thu, 14 Jun 2007 23:58:23 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 06/17] lib: percpu_counter_init_irq
Content-Disposition: inline; filename=percpu_counter_init_irq.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, andrea@suse.de
List-ID: <linux-mm.kvack.org>

provide a way to init percpu_counters that are supposed to be used from irq
safe contexts.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/percpu_counter.h |    4 ++++
 lib/percpu_counter.c           |    8 ++++++++
 2 files changed, 12 insertions(+)

Index: linux-2.6/include/linux/percpu_counter.h
===================================================================
--- linux-2.6.orig/include/linux/percpu_counter.h
+++ linux-2.6/include/linux/percpu_counter.h
@@ -31,6 +31,8 @@ struct percpu_counter {
 #endif
 
 void percpu_counter_init(struct percpu_counter *fbc, s64 amount);
+void percpu_counter_init_irq(struct percpu_counter *fbc, s64 amount);
+
 void percpu_counter_destroy(struct percpu_counter *fbc);
 void percpu_counter_set(struct percpu_counter *fbc, s64 amount);
 void __percpu_counter_mod(struct percpu_counter *fbc, s32 amount, s32 batch);
@@ -89,6 +91,8 @@ static inline void percpu_counter_init(s
 	fbc->count = amount;
 }
 
+#define percpu_counter_init_irq percpu_counter_init
+
 static inline void percpu_counter_destroy(struct percpu_counter *fbc)
 {
 }
Index: linux-2.6/lib/percpu_counter.c
===================================================================
--- linux-2.6.orig/lib/percpu_counter.c
+++ linux-2.6/lib/percpu_counter.c
@@ -87,6 +87,8 @@ s64 __percpu_counter_sum(struct percpu_c
 }
 EXPORT_SYMBOL(__percpu_counter_sum);
 
+static struct lock_class_key percpu_counter_irqsafe;
+
 void percpu_counter_init(struct percpu_counter *fbc, s64 amount)
 {
 	spin_lock_init(&fbc->lock);
@@ -100,6 +102,12 @@ void percpu_counter_init(struct percpu_c
 }
 EXPORT_SYMBOL(percpu_counter_init);
 
+void percpu_counter_init_irq(struct percpu_counter *fbc, s64 amount)
+{
+	percpu_counter_init(fbc, amount);
+	lockdep_set_class(&fbc->lock, &percpu_counter_irqsafe);
+}
+
 void percpu_counter_destroy(struct percpu_counter *fbc)
 {
 	free_percpu(fbc->counters);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
