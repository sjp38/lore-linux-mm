Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 18 of 24] run panic the same way in both places
Message-Id: <040cab5c8aafe1efcb6f.1187786945@v2.random>
In-Reply-To: <patchbomb.1187786927@v2.random>
Date: Wed, 22 Aug 2007 14:49:05 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1187778125 -7200
# Node ID 040cab5c8aafe1efcb6fc21d1f268c11202dac02
# Parent  efd1da1efb392cc4e015740d088ea9c6235901e0
run panic the same way in both places

The other panic is called after releasing some core global lock, that
sounds safe to have for both panics (just in case panic tries to do
anything more than oops does).

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -429,8 +429,11 @@ void out_of_memory(struct zonelist *zone
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
@@ -438,7 +441,7 @@ retry:
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
