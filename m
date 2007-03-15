Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l2FE6Kvj279696
	for <linux-mm@kvack.org>; Fri, 16 Mar 2007 01:06:20 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2FDqnsK144618
	for <linux-mm@kvack.org>; Fri, 16 Mar 2007 00:52:50 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2FDnJQP010444
	for <linux-mm@kvack.org>; Fri, 16 Mar 2007 00:49:19 +1100
Date: Thu, 15 Mar 2007 19:19:21 +0530
Subject: [PATCH] oom fix: prevent oom from killing a process with children/sibling unkillable
Message-ID: <20070315134921.GD18033@in.ibm.com>
Reply-To: Ankita Garg <ankita@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
From: ankita@in.ibm.com (Ankita Garg)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Looking at oom_kill.c, found that the intention to not kill the selected
process if any of its children/siblings has OOM_DISABLE set, is not being met.


Signed-off-by: Ankita Garg <ankita@in.ibm.com>

Index: ankita/linux-2.6.20.1/mm/oom_kill.c
===================================================================
--- ankita.orig/linux-2.6.20.1/mm/oom_kill.c	2007-02-20 12:04:32.000000000 +0530
+++ ankita/linux-2.6.20.1/mm/oom_kill.c	2007-03-15 12:44:50.000000000 +0530
@@ -320,7 +320,7 @@
 	 * Don't kill the process if any threads are set to OOM_DISABLE
 	 */
 	do_each_thread(g, q) {
-		if (q->mm == mm && p->oomkilladj == OOM_DISABLE)
+		if (q->mm == mm && q->oomkilladj == OOM_DISABLE)
 			return 1;
 	} while_each_thread(g, q);
 

Regards,
-- 
Ankita Garg (ankita@in.ibm.com)
Linux Technology Center
IBM India Systems & Technology Labs, 
Bangalore, India   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
