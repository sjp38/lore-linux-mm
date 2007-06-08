Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 34C192187B
	for <linux-mm@kvack.org>; Fri,  8 Jun 2007 22:07:32 +0200 (CEST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 10 of 16] stop useless vm trashing while we wait the
	TIF_MEMDIE task to exit
Message-Id: <24250f0be1aa26e5c6e3.1181332988@v2.random>
In-Reply-To: <patchbomb.1181332978@v2.random>
Date: Fri, 08 Jun 2007 22:03:08 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1181332962 -7200
# Node ID 24250f0be1aa26e5c6e33fd97b9eae125db9fbde
# Parent  4a70e6a4142230fa161dd37202cd62fede122880
stop useless vm trashing while we wait the TIF_MEMDIE task to exit

There's no point in trying to free memory if we're oom.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/include/linux/swap.h b/include/linux/swap.h
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -159,6 +159,8 @@ struct swap_list_t {
 #define vm_swap_full() (nr_swap_pages*2 < total_swap_pages)
 
 /* linux/mm/oom_kill.c */
+extern unsigned long VM_is_OOM;
+#define is_VM_OOM() unlikely(test_bit(0, &VM_is_OOM))
 extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order);
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -923,6 +923,8 @@ static unsigned long shrink_zone(int pri
 		nr_inactive = 0;
 
 	while (nr_active || nr_inactive) {
+		if (is_VM_OOM())
+			break;
 		if (nr_active) {
 			nr_to_scan = min(nr_active,
 					(unsigned long)sc->swap_cluster_max);
@@ -1032,6 +1034,17 @@ unsigned long try_to_free_pages(struct z
 	}
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
+		if (is_VM_OOM()) {
+			if (!test_thread_flag(TIF_MEMDIE)) {
+				/* get out of the way */
+				schedule_timeout_interruptible(1);
+				/* don't waste cpu if we're still oom */
+				if (is_VM_OOM())
+					goto out;
+			} else
+				goto out;
+		}
+
 		sc.nr_scanned = 0;
 		if (!priority)
 			disable_swap_token();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
