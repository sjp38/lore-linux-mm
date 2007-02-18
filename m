Received: from rune (localhost [127.0.0.1])
	by rune.pobox.com (Postfix) with ESMTP id ECD85B9852
	for <linux-mm@kvack.org>; Sun, 18 Feb 2007 04:44:07 -0500 (EST)
Received: from emit.nirmalvihar.info (house.nirmalvihar.info [61.17.90.7])
	by rune.sasl.smtp.pobox.com (Postfix) with ESMTP id CC856B96E2
	for <linux-mm@kvack.org>; Sun, 18 Feb 2007 04:44:05 -0500 (EST)
Date: Sun, 18 Feb 2007 15:13:36 +0530
From: Joshua N Pritikin <jpritikin@pobox.com>
Subject: [PATCH] allow oom_adj of saintly processes
Message-ID: <20070218094336.GM11084@always.joy.eth.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

If the badness of a process is zero then oom_adj>0 has no effect. This 
patch makes sure that the oom_adj shift actually increases badness 
points appropriately.

I am not subscribed. Please CC me with any comments. Thanks.

Signed-off-by: Joshua N. Pritikin <jpritikin@pobox.com>

--- linux/mm/oom_kill.c.orig	2007-02-18 14:58:35.000000000 +0530
+++ linux/mm/oom_kill.c	2007-02-18 14:57:52.000000000 +0530
@@ -147,9 +147,11 @@ unsigned long badness(struct task_struct
 	 * Adjust the score by oomkilladj.
 	 */
 	if (p->oomkilladj) {
-		if (p->oomkilladj > 0)
+		if (p->oomkilladj > 0) {
+			if (!points)
+				points = 1;
 			points <<= p->oomkilladj;
-		else
+		} else
 			points >>= -(p->oomkilladj);
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
