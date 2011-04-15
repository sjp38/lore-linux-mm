Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7ADA4900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 13:38:31 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3FHMmN4025482
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 11:22:48 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3FHcQ0Q083350
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 11:38:26 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3FHcQLR025404
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 11:38:26 -0600
Subject: [RFC][PATCH 3/3] use pte pages in OOM score
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Fri, 15 Apr 2011 10:38:24 -0700
References: <20110415173821.62660715@kernel>
In-Reply-To: <20110415173821.62660715@kernel>
Message-Id: <20110415173824.79D354F4@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave@linux.vnet.ibm.com>


PTE pages eat up memory just like anything else, but we do
not account for them in any way in the OOM scores.  They
are also _guaranteed_ to get freed up when a process is OOM
killed, while RSS is not.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/mm/oom_kill.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff -puN mm/oom_kill.c~use-pte-pages-in-oom-scire mm/oom_kill.c
--- linux-2.6.git/mm/oom_kill.c~use-pte-pages-in-oom-scire	2011-04-15 10:37:13.184831585 -0700
+++ linux-2.6.git-dave/mm/oom_kill.c	2011-04-15 10:37:13.192831581 -0700
@@ -192,8 +192,10 @@ unsigned int oom_badness(struct task_str
 	 * The baseline for the badness score is the proportion of RAM that each
 	 * task's rss and swap space use.
 	 */
-	points = (get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS)) * 1000 /
-			totalpages;
+	points = (get_mm_rss(p->mm) +
+		  get_mm_counter(p->mm, MM_SWAPENTS) +
+		  get_mm_counter(p->mm, MM_PTEPAGES))
+		 * 1000 / totalpages;
 	task_unlock(p);
 
 	/*
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
