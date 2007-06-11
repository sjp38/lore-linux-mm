Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 8258C12235
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 16:33:10 +0200 (CEST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 2 of 2] run panic the same way in both places
Message-Id: <dffa158c3b3c7849ffb0.1181572241@v2.random>
In-Reply-To: <patchbomb.1181572239@v2.random>
Date: Mon, 11 Jun 2007 16:30:41 +0200
From: andrea@suse.de
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1181572232 -7200
# Node ID dffa158c3b3c7849ffb08ec0551ec999f50e2e59
# Parent  aa5f6b86a146552d4b0c26b2aa5cc009a3093e49
run panic the same way in both places

The other panic is called after releasing some core global lock, that
sounds safe to have for both panics (just in case panic tries to do
anything more than oops does).

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -428,8 +428,11 @@ void out_of_memory(struct zonelist *zone
 			last_tif_memdie_jiffies = jiffies;
 		}
 
-		if (sysctl_panic_on_oom)
+		if (sysctl_panic_on_oom) {
+			read_unlock(&tasklist_lock);
+			cpuset_unlock();
 			panic("out of memory. panic_on_oom is selected\n");
+		}
 retry:
 		/*
 		 * Rambo mode: Shoot down a process and hope it solves whatever
@@ -437,7 +440,7 @@ retry:
 		 */
 		p = select_bad_process(&points);
 		/* Found nothing?!?! Either we hang forever, or we panic. */
-		if (!p) {
+		if (unlikely(!p)) {
 			read_unlock(&tasklist_lock);
 			cpuset_unlock();
 			panic("Out of memory and no killable processes...\n");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
