Message-Id: <20070417071702.933410506@chello.nl>
References: <20070417071046.318415445@chello.nl>
Date: Tue, 17 Apr 2007 09:10:49 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 03/12] lib: dampen the percpu_counter FBC_BATCH
Content-Disposition: inline; filename=percpu_counter_batch.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

With the current logic the percpu_counter's accuracy delta is quadric
wrt the number of cpus in the system, reduce this to O(n ln n).

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/percpu_counter.h |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

Index: linux-2.6-mm/include/linux/percpu_counter.h
===================================================================
--- linux-2.6-mm.orig/include/linux/percpu_counter.h
+++ linux-2.6-mm/include/linux/percpu_counter.h
@@ -11,6 +11,7 @@
 #include <linux/threads.h>
 #include <linux/percpu.h>
 #include <linux/types.h>
+#include <linux/log2.h>
 
 #ifdef CONFIG_SMP
 
@@ -20,11 +21,7 @@ struct percpu_counter {
 	s32 *counters;
 };
 
-#if NR_CPUS >= 16
-#define FBC_BATCH	(NR_CPUS*2)
-#else
-#define FBC_BATCH	(NR_CPUS*4)
-#endif
+#define FBC_BATCH	(8*ilog2(NR_CPUS))
 
 static inline void percpu_counter_init(struct percpu_counter *fbc, s64 amount)
 {

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
