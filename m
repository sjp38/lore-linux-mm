Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id A652D6B00EA
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 06:16:28 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [RFC PATCH 6/6] workqueue: use kmalloc_align() instead of hacking
Date: Tue, 20 Mar 2012 18:21:24 +0800
Message-Id: <1332238884-6237-7-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1332238884-6237-1-git-send-email-laijs@cn.fujitsu.com>
References: <1332238884-6237-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lai Jiangshan <laijs@cn.fujitsu.com>

kmalloc_align() makes the code simpler.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 kernel/workqueue.c |   23 +++++------------------
 1 files changed, 5 insertions(+), 18 deletions(-)

diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 5abf42f..beec5fd 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -2897,20 +2897,9 @@ static int alloc_cwqs(struct workqueue_struct *wq)
 
 	if (!(wq->flags & WQ_UNBOUND))
 		wq->cpu_wq.pcpu = __alloc_percpu(size, align);
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
+	else
+		wq->cpu_wq.single = kmalloc_align(size,
+				GFP_KERNEL | __GFP_ZERO, align);
 
 	/* just in case, make sure it's actually aligned */
 	BUG_ON(!IS_ALIGNED(wq->cpu_wq.v, align));
@@ -2921,10 +2910,8 @@ static void free_cwqs(struct workqueue_struct *wq)
 {
 	if (!(wq->flags & WQ_UNBOUND))
 		free_percpu(wq->cpu_wq.pcpu);
-	else if (wq->cpu_wq.single) {
-		/* the pointer to free is stored right after the cwq */
-		kfree(*(void **)(wq->cpu_wq.single + 1));
-	}
+	else if (wq->cpu_wq.single)
+		kfree(wq->cpu_wq.single);
 }
 
 static int wq_clamp_max_active(int max_active, unsigned int flags,
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
