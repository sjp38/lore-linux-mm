Message-Id: <20070614220446.659716697@chello.nl>
References: <20070614215817.389524447@chello.nl>
Date: Thu, 14 Jun 2007 23:58:22 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 05/17] lib: percpu_count_sum_signed()
Content-Disposition: inline; filename=percpu_counter_sum.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, andrea@suse.de
List-ID: <linux-mm.kvack.org>

Provide an accurate version of percpu_counter_read.

Should we go and replace the current use of percpu_counter_sum()
with percpu_counter_sum_positive(), and call this new primitive
percpu_counter_sum() instead?

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/percpu_counter.h |   18 +++++++++++++++++-
 lib/percpu_counter.c           |    6 +++---
 2 files changed, 20 insertions(+), 4 deletions(-)

Index: linux-2.6/include/linux/percpu_counter.h
===================================================================
--- linux-2.6.orig/include/linux/percpu_counter.h	2007-05-23 20:37:54.000000000 +0200
+++ linux-2.6/include/linux/percpu_counter.h	2007-05-23 20:38:09.000000000 +0200
@@ -35,7 +35,18 @@ void percpu_counter_destroy(struct percp
 void percpu_counter_set(struct percpu_counter *fbc, s64 amount);
 void __percpu_counter_mod(struct percpu_counter *fbc, s32 amount, s32 batch);
 void __percpu_counter_mod64(struct percpu_counter *fbc, s64 amount, s32 batch);
-s64 percpu_counter_sum(struct percpu_counter *fbc);
+s64 __percpu_counter_sum(struct percpu_counter *fbc);
+
+static inline s64 percpu_counter_sum(struct percpu_counter *fbc)
+{
+	s64 ret = __percpu_counter_sum(fbc);
+	return ret < 0 ? 0 : ret;
+}
+
+static inline s64 percpu_counter_sum_signed(struct percpu_counter *fbc)
+{
+	return __percpu_counter_sum(fbc);
+}
 
 static inline void percpu_counter_mod(struct percpu_counter *fbc, s32 amount)
 {
@@ -124,6 +135,11 @@ static inline s64 percpu_counter_sum(str
 	return percpu_counter_read_positive(fbc);
 }
 
+static inline s64 percpu_counter_sum_signed(struct percpu_counter *fbc)
+{
+	return fbc->count;
+}
+
 #endif	/* CONFIG_SMP */
 
 static inline void percpu_counter_inc(struct percpu_counter *fbc)
Index: linux-2.6/lib/percpu_counter.c
===================================================================
--- linux-2.6.orig/lib/percpu_counter.c	2007-05-23 20:38:03.000000000 +0200
+++ linux-2.6/lib/percpu_counter.c	2007-05-23 20:38:18.000000000 +0200
@@ -71,7 +71,7 @@ EXPORT_SYMBOL(__percpu_counter_mod64);
  * Add up all the per-cpu counts, return the result.  This is a more accurate
  * but much slower version of percpu_counter_read_positive()
  */
-s64 percpu_counter_sum(struct percpu_counter *fbc)
+s64 __percpu_counter_sum(struct percpu_counter *fbc)
 {
 	s64 ret;
 	int cpu;
@@ -83,9 +83,9 @@ s64 percpu_counter_sum(struct percpu_cou
 		ret += *pcount;
 	}
 	spin_unlock(&fbc->lock);
-	return ret < 0 ? 0 : ret;
+	return ret;
 }
-EXPORT_SYMBOL(percpu_counter_sum);
+EXPORT_SYMBOL(__percpu_counter_sum);
 
 void percpu_counter_init(struct percpu_counter *fbc, s64 amount)
 {

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
