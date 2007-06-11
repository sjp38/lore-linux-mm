Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 4EF8E215C4
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 16:32:57 +0200 (CEST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 1 of 2] apply the anti deadlock features only to global oom
Message-Id: <aa5f6b86a146552d4b0c.1181572240@v2.random>
In-Reply-To: <patchbomb.1181572239@v2.random>
Date: Mon, 11 Jun 2007 16:30:40 +0200
From: andrea@suse.de
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1181572232 -7200
# Node ID aa5f6b86a146552d4b0c26b2aa5cc009a3093e49
# Parent  1187bc6a44bb2b14560132ac5199849f3a830e48
apply the anti deadlock features only to global oom

Cc: Christoph Lameter <clameter@sgi.com>
The local numa oom will keep killing the current task hoping that's it's
not an innocent task and it won't alter the behavior of the rest of the
VM. The global oom will not wait for TIF_MEMDIE tasks anymore, so this
will be a really local event, not like before when the local-TIF_MEMDIE
was effectively a global flag that the global oom would depend on too.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -386,9 +386,6 @@ void out_of_memory(struct zonelist *zone
 		/* Got some memory back in the last second. */
 		return;
 
-	if (down_trylock(&OOM_lock))
-		return;
-
 	if (sysctl_panic_on_oom == 2)
 		panic("out of memory. Compulsory panic_on_oom is selected.\n");
 
@@ -398,32 +395,39 @@ void out_of_memory(struct zonelist *zone
 	 */
 	constraint = constrained_alloc(zonelist, gfp_mask);
 	cpuset_lock();
-	read_lock(&tasklist_lock);
-
-	/*
-	 * This holds the down(OOM_lock)+read_lock(tasklist_lock), so it's
-	 * equivalent to write_lock_irq(tasklist_lock) as far as VM_is_OOM
-	 * is concerned.
-	 */
-	if (unlikely(test_bit(0, &VM_is_OOM))) {
-		if (time_before(jiffies, last_tif_memdie_jiffies + 10*HZ))
-			goto out;
-		printk("detected probable OOM deadlock, so killing another task\n");
-		last_tif_memdie_jiffies = jiffies;
-	}
 
 	switch (constraint) {
 	case CONSTRAINT_MEMORY_POLICY:
+		read_lock(&tasklist_lock);
 		oom_kill_process(current, points,
 				 "No available memory (MPOL_BIND)", gfp_mask, order);
+		read_unlock(&tasklist_lock);
 		break;
 
 	case CONSTRAINT_CPUSET:
+		read_lock(&tasklist_lock);
 		oom_kill_process(current, points,
 				 "No available memory in cpuset", gfp_mask, order);
+		read_unlock(&tasklist_lock);
 		break;
 
 	case CONSTRAINT_NONE:
+		if (down_trylock(&OOM_lock))
+			break;
+		read_lock(&tasklist_lock);
+
+		/*
+		 * This holds the down(OOM_lock)+read_lock(tasklist_lock),
+		 * so it's equivalent to write_lock_irq(tasklist_lock) as
+		 * far as VM_is_OOM is concerned.
+		 */
+		if (unlikely(test_bit(0, &VM_is_OOM))) {
+			if (time_before(jiffies, last_tif_memdie_jiffies + 10*HZ))
+				goto out;
+			printk("detected probable OOM deadlock, so killing another task\n");
+			last_tif_memdie_jiffies = jiffies;
+		}
+
 		if (sysctl_panic_on_oom)
 			panic("out of memory. panic_on_oom is selected\n");
 retry:
@@ -442,12 +446,11 @@ retry:
 		if (oom_kill_process(p, points, "Out of memory", gfp_mask, order))
 			goto retry;
 
+	out:
+		read_unlock(&tasklist_lock);
+		up(&OOM_lock);
 		break;
 	}
 
-out:
-	read_unlock(&tasklist_lock);
 	cpuset_unlock();
-
-	up(&OOM_lock);
-}
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
