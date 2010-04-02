Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 114506B01F0
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 14:33:35 -0400 (EDT)
Date: Fri, 2 Apr 2010 20:31:32 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH -mm 1/4] oom: select_bad_process: check PF_KTHREAD instead
	of !mm to skip kthreads
Message-ID: <20100402183132.GB31723@redhat.com>
References: <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330154659.GA12416@redhat.com> <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com> <20100331175836.GA11635@redhat.com> <20100331204718.GD11635@redhat.com> <alpine.DEB.2.00.1004010133190.6285@chino.kir.corp.google.com> <20100401135927.GA12460@redhat.com> <alpine.DEB.2.00.1004011210380.30661@chino.kir.corp.google.com> <20100402111406.GA4432@redhat.com> <20100402183057.GA31723@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100402183057.GA31723@redhat.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

select_bad_process() thinks a kernel thread can't have ->mm != NULL,
this is not true due to use_mm().

Change the code to check PF_KTHREAD.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---

 mm/oom_kill.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

--- MM/mm/oom_kill.c~1_FLITER_OUT_KTHREADS	2010-03-31 17:47:14.000000000 +0200
+++ MM/mm/oom_kill.c	2010-04-02 18:51:05.000000000 +0200
@@ -290,8 +290,8 @@ static struct task_struct *select_bad_pr
 	for_each_process(p) {
 		unsigned int points;
 
-		/* skip the init task */
-		if (is_global_init(p))
+		/* skip the init task and kthreads */
+		if (is_global_init(p) || (p->flags & PF_KTHREAD))
 			continue;
 		if (mem && !task_in_mem_cgroup(p, mem))
 			continue;
@@ -331,8 +331,7 @@ static struct task_struct *select_bad_pr
 		}
 
 		/*
-		 * skip kernel threads and tasks which have already released
-		 * their mm.
+		 * skip the tasks which have already released their mm.
 		 */
 		if (!p->mm)
 			continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
