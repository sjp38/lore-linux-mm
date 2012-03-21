Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id EFFE26B0044
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 10:31:26 -0400 (EDT)
Date: Wed, 21 Mar 2012 09:12:04 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Patch workqueue: create new slab cache instead of hacking
In-Reply-To: <CAOS58YPydFUap4HjuRATxza6VZgyrXmQHVxR83G7GRJL50ZTRQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1203210910450.20482@router.home>
References: <1332238884-6237-1-git-send-email-laijs@cn.fujitsu.com> <1332238884-6237-7-git-send-email-laijs@cn.fujitsu.com> <20120320154619.GA5684@google.com> <4F6944D9.5090002@cn.fujitsu.com>
 <CAOS58YPydFUap4HjuRATxza6VZgyrXmQHVxR83G7GRJL50ZTRQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

How about this instead?

Subject: workqueues: Use new kmem cache to get aligned memory for workqueues

The workqueue logic currently improvises by doing a kmalloc allocation and
then aligning the object. Create a slab cache for that purpose with the
proper alignment instead.

Cleans up the code and makes things much simpler. No need anymore to carry
an additional pointer to the beginning of the kmalloc object.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 kernel/workqueue.c |   50 +++++++++++++++++++++-----------------------------
 1 file changed, 21 insertions(+), 29 deletions(-)

Index: linux-2.6/kernel/workqueue.c
===================================================================
--- linux-2.6.orig/kernel/workqueue.c	2012-03-21 09:07:07.000000000 -0500
+++ linux-2.6/kernel/workqueue.c	2012-03-21 09:07:24.000000000 -0500
@@ -2884,36 +2884,27 @@ int keventd_up(void)
 	return system_wq != NULL;
 }

+/*
+ * cwqs are forced aligned according to WORK_STRUCT_FLAG_BITS.
+ * Make sure that the alignment isn't lower than that of
+ * unsigned long long.
+ */
+
+#define WQ_ALIGN (max_t(size_t, 1 << WORK_STRUCT_FLAG_BITS, \
+			   __alignof__(unsigned long long)))
+
+struct kmem_cache *wq_slab;
+
 static int alloc_cwqs(struct workqueue_struct *wq)
 {
-	/*
-	 * cwqs are forced aligned according to WORK_STRUCT_FLAG_BITS.
-	 * Make sure that the alignment isn't lower than that of
-	 * unsigned long long.
-	 */
-	const size_t size = sizeof(struct cpu_workqueue_struct);
-	const size_t align = max_t(size_t, 1 << WORK_STRUCT_FLAG_BITS,
-				   __alignof__(unsigned long long));
-
 	if (!(wq->flags & WQ_UNBOUND))
-		wq->cpu_wq.pcpu = __alloc_percpu(size, align);
-	else {
-		void *ptr;
-
-		/*
-		 * Allocate enough room to align cwq and put an extra
-		 * pointer at the end pointing back to the originally
-		 * allocated pointer which will be used for free.
-		 */
-		ptr = kzalloc(size + align + sizeof(void *), GFP_KERNEL);
-		if (ptr) {
-			wq->cpu_wq.single = PTR_ALIGN(ptr, align);
-			*(void **)(wq->cpu_wq.single + 1) = ptr;
-		}
-	}
+		wq->cpu_wq.pcpu = __alloc_percpu(sizeof(struct cpu_workqueue_struct),
+					WQ_ALIGN);
+	else
+		wq->cpu_wq.single = kmem_cache_zalloc(wq_slab, GFP_KERNEL);

 	/* just in case, make sure it's actually aligned */
-	BUG_ON(!IS_ALIGNED(wq->cpu_wq.v, align));
+	BUG_ON(!IS_ALIGNED(wq->cpu_wq.v, WQ_ALIGN));
 	return wq->cpu_wq.v ? 0 : -ENOMEM;
 }

@@ -2921,10 +2912,8 @@ static void free_cwqs(struct workqueue_s
 {
 	if (!(wq->flags & WQ_UNBOUND))
 		free_percpu(wq->cpu_wq.pcpu);
-	else if (wq->cpu_wq.single) {
-		/* the pointer to free is stored right after the cwq */
-		kfree(*(void **)(wq->cpu_wq.single + 1));
-	}
+	else if (wq->cpu_wq.single)
+		kmem_cache_free(wq_slab, wq->cpu_wq.single);
 }

 static int wq_clamp_max_active(int max_active, unsigned int flags,
@@ -3770,6 +3759,9 @@ static int __init init_workqueues(void)
 	unsigned int cpu;
 	int i;

+	wq_slab = kmem_cache_create("workqueue", sizeof(struct cpu_workqueue_struct),
+			WQ_ALIGN, SLAB_PANIC, NULL);
+
 	cpu_notifier(workqueue_cpu_callback, CPU_PRI_WORKQUEUE);

 	/* initialize gcwqs */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
