From: Christoph Lameter <cl@linux.com>
Subject: [thisops uV3 09/18] fs: Use this_cpu_xx operations in buffer.c
Date: Tue, 30 Nov 2010 13:07:16 -0600
Message-ID: <20101130190846.390522413@linux.com>
References: <20101130190707.457099608@linux.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PNVZZ-0000N4-Mb
	for glkm-linux-mm-2@m.gmane.org; Tue, 30 Nov 2010 20:09:06 +0100
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 534966B0092
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 14:08:49 -0500 (EST)
Content-Disposition: inline; filename=this_cpu_buffer
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Optimize various per cpu area operations through the new this cpu
operations. These operations avoid address calculations through the use
of segment prefixes avoid multiple memory references through RMW
instructions etc.

Reduces code size:

Before:

christoph@linux-2.6$ size fs/buffer.o
   text	   data	    bss	    dec	    hex	filename
  19169	     80	     28	  19277	   4b4d	fs/buffer.o

After:

christoph@linux-2.6$ size fs/buffer.o
   text	   data	    bss	    dec	    hex	filename
  19138	     80	     28	  19246	   4b2e	fs/buffer.o

Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Christoph Hellwig <hch@lst.de>
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 fs/buffer.c |   37 ++++++++++++++++++-------------------
 1 file changed, 18 insertions(+), 19 deletions(-)

Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c	2010-11-30 09:41:30.000000000 -0600
+++ linux-2.6/fs/buffer.c	2010-11-30 09:55:55.000000000 -0600
@@ -1270,12 +1270,10 @@ static inline void check_irqs_on(void)
 static void bh_lru_install(struct buffer_head *bh)
 {
 	struct buffer_head *evictee = NULL;
-	struct bh_lru *lru;
 
 	check_irqs_on();
 	bh_lru_lock();
-	lru = &__get_cpu_var(bh_lrus);
-	if (lru->bhs[0] != bh) {
+	if (__this_cpu_read(bh_lrus.bhs[0]) != bh) {
 		struct buffer_head *bhs[BH_LRU_SIZE];
 		int in;
 		int out = 0;
@@ -1283,7 +1281,8 @@ static void bh_lru_install(struct buffer
 		get_bh(bh);
 		bhs[out++] = bh;
 		for (in = 0; in < BH_LRU_SIZE; in++) {
-			struct buffer_head *bh2 = lru->bhs[in];
+			struct buffer_head *bh2 =
+				__this_cpu_read(bh_lrus.bhs[in]);
 
 			if (bh2 == bh) {
 				__brelse(bh2);
@@ -1298,7 +1297,7 @@ static void bh_lru_install(struct buffer
 		}
 		while (out < BH_LRU_SIZE)
 			bhs[out++] = NULL;
-		memcpy(lru->bhs, bhs, sizeof(bhs));
+		memcpy(__this_cpu_ptr(&bh_lrus.bhs), bhs, sizeof(bhs));
 	}
 	bh_lru_unlock();
 
@@ -1313,23 +1312,22 @@ static struct buffer_head *
 lookup_bh_lru(struct block_device *bdev, sector_t block, unsigned size)
 {
 	struct buffer_head *ret = NULL;
-	struct bh_lru *lru;
 	unsigned int i;
 
 	check_irqs_on();
 	bh_lru_lock();
-	lru = &__get_cpu_var(bh_lrus);
 	for (i = 0; i < BH_LRU_SIZE; i++) {
-		struct buffer_head *bh = lru->bhs[i];
+		struct buffer_head *bh = __this_cpu_read(bh_lrus.bhs[i]);
 
 		if (bh && bh->b_bdev == bdev &&
 				bh->b_blocknr == block && bh->b_size == size) {
 			if (i) {
 				while (i) {
-					lru->bhs[i] = lru->bhs[i - 1];
+					__this_cpu_write(bh_lrus.bhs[i],
+						__this_cpu_read(bh_lrus.bhs[i - 1]));
 					i--;
 				}
-				lru->bhs[0] = bh;
+				__this_cpu_write(bh_lrus.bhs[0], bh);
 			}
 			get_bh(bh);
 			ret = bh;
@@ -3203,22 +3201,23 @@ static void recalc_bh_state(void)
 	int i;
 	int tot = 0;
 
-	if (__get_cpu_var(bh_accounting).ratelimit++ < 4096)
+	if (__this_cpu_inc_return(bh_accounting.ratelimit) < 4096)
 		return;
-	__get_cpu_var(bh_accounting).ratelimit = 0;
+	__this_cpu_write(bh_accounting.ratelimit, 0);
 	for_each_online_cpu(i)
 		tot += per_cpu(bh_accounting, i).nr;
 	buffer_heads_over_limit = (tot > max_buffer_heads);
 }
-	
+
 struct buffer_head *alloc_buffer_head(gfp_t gfp_flags)
 {
 	struct buffer_head *ret = kmem_cache_zalloc(bh_cachep, gfp_flags);
 	if (ret) {
 		INIT_LIST_HEAD(&ret->b_assoc_buffers);
-		get_cpu_var(bh_accounting).nr++;
+		preempt_disable();
+		__this_cpu_inc(bh_accounting.nr);
 		recalc_bh_state();
-		put_cpu_var(bh_accounting);
+		preempt_enable();
 	}
 	return ret;
 }
@@ -3228,9 +3227,10 @@ void free_buffer_head(struct buffer_head
 {
 	BUG_ON(!list_empty(&bh->b_assoc_buffers));
 	kmem_cache_free(bh_cachep, bh);
-	get_cpu_var(bh_accounting).nr--;
+	preempt_disable();
+	__this_cpu_dec(bh_accounting.nr);
 	recalc_bh_state();
-	put_cpu_var(bh_accounting);
+	preempt_enable();
 }
 EXPORT_SYMBOL(free_buffer_head);
 
@@ -3243,9 +3243,8 @@ static void buffer_exit_cpu(int cpu)
 		brelse(b->bhs[i]);
 		b->bhs[i] = NULL;
 	}
-	get_cpu_var(bh_accounting).nr += per_cpu(bh_accounting, cpu).nr;
+	this_cpu_add(bh_accounting.nr, per_cpu(bh_accounting, cpu).nr);
 	per_cpu(bh_accounting, cpu).nr = 0;
-	put_cpu_var(bh_accounting);
 }
 
 static int buffer_cpu_notify(struct notifier_block *self,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
