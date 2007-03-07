From: Con Kolivas <kernel@kolivas.org>
Subject: [PATCH] swap prefetch: avoid repeating entry
Date: Wed, 7 Mar 2007 18:14:04 +1100
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200703071814.04531.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I've been unable for 4 months to find someone to test this Andrew. I'm going
to assume it fixes the problem on numa=64 (or something like that) so please
apply it.

---
Avoid entering trickle_swap() when first initialising kprefetchd to prevent
endless loops.

Signed-off-by: Con Kolivas <kernel@kolivas.org>

---
 mm/swap_prefetch.c |    4 ++++
 1 file changed, 4 insertions(+)

Index: linux-2.6.21-rc2-mm2/mm/swap_prefetch.c
===================================================================
--- linux-2.6.21-rc2-mm2.orig/mm/swap_prefetch.c	2007-03-06 22:23:26.000000000 +1100
+++ linux-2.6.21-rc2-mm2/mm/swap_prefetch.c	2007-03-07 18:11:50.000000000 +1100
@@ -515,6 +515,10 @@ static int kprefetchd(void *__unused)
 	/* Set ioprio to lowest if supported by i/o scheduler */
 	sys_ioprio_set(IOPRIO_WHO_PROCESS, 0, IOPRIO_CLASS_IDLE);
 
+	/* kprefetchd has nothing to do until it is woken up the first time */
+	set_current_state(TASK_INTERRUPTIBLE);
+	schedule();
+
 	do {
 		try_to_freeze();
 

-- 
-ck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
