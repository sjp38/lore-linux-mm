Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E0D566B004D
	for <linux-mm@kvack.org>; Mon,  5 Oct 2009 22:40:48 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n962eiL4026896
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 6 Oct 2009 11:40:44 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 70D3F45DE55
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 11:40:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2361745DE50
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 11:40:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 064A81DB8046
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 11:40:44 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A20F61DB8042
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 11:40:43 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/2] Implement lru_add_drain_all_async()
Message-Id: <20091006112803.5FA5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  6 Oct 2009 11:40:42 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Oleg Nesterov <oleg@redhat.com>, Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


===================================================================
Implement asynchronous lru_add_drain_all()

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/swap.h |    1 +
 mm/swap.c            |   24 ++++++++++++++++++++++++
 2 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 4ec9001..1f5772a 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -204,6 +204,7 @@ extern void activate_page(struct page *);
 extern void mark_page_accessed(struct page *);
 extern void lru_add_drain(void);
 extern int lru_add_drain_all(void);
+extern int lru_add_drain_all_async(void);
 extern void rotate_reclaimable_page(struct page *page);
 extern void swap_setup(void);
 
diff --git a/mm/swap.c b/mm/swap.c
index 308e57d..e16cd40 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -38,6 +38,7 @@ int page_cluster;
 
 static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
+static DEFINE_PER_CPU(struct work_struct, lru_drain_work);
 
 /*
  * This path almost never happens for VM activity - pages are normally
@@ -312,6 +313,24 @@ int lru_add_drain_all(void)
 }
 
 /*
+ * Returns 0 for success
+ */
+int lru_add_drain_all_async(void)
+{
+	int cpu;
+
+	get_online_cpus();
+	for_each_online_cpu(cpu) {
+		struct work_struct *work = &per_cpu(lru_drain_work, cpu);
+		schedule_work_on(cpu, work);
+	}
+	put_online_cpus();
+
+	return 0;
+}
+
+
+/*
  * Batched page_cache_release().  Decrement the reference count on all the
  * passed pages.  If it fell to zero then remove the page from the LRU and
  * free it.
@@ -497,6 +516,7 @@ EXPORT_SYMBOL(pagevec_lookup_tag);
 void __init swap_setup(void)
 {
 	unsigned long megs = totalram_pages >> (20 - PAGE_SHIFT);
+	int cpu;
 
 #ifdef CONFIG_SWAP
 	bdi_init(swapper_space.backing_dev_info);
@@ -511,4 +531,8 @@ void __init swap_setup(void)
 	 * Right now other parts of the system means that we
 	 * _really_ don't want to cluster much more
 	 */
+
+	for_each_possible_cpu(cpu) {
+		INIT_WORK(&per_cpu(lru_drain_work, cpu), lru_add_drain_per_cpu);
+	}
 }
-- 
1.6.2.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
