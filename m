Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3BCF36B01E3
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 17:22:27 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [10.3.21.3])
	by smtp-out.google.com with ESMTP id o32LMNJP010568
	for <linux-mm@kvack.org>; Fri, 2 Apr 2010 14:22:24 -0700
Received: from pva18 (pva18.prod.google.com [10.241.209.18])
	by hpaq3.eem.corp.google.com with ESMTP id o32LMKH4002581
	for <linux-mm@kvack.org>; Fri, 2 Apr 2010 23:22:22 +0200
Received: by pva18 with SMTP id 18so1035136pva.19
        for <linux-mm@kvack.org>; Fri, 02 Apr 2010 14:22:20 -0700 (PDT)
Date: Fri, 2 Apr 2010 14:22:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm v2] oom: exclude tasks with badness score of 0 from being
 selected
In-Reply-To: <20100402210459.GA5112@redhat.com>
Message-ID: <alpine.DEB.2.00.1004021421060.5599@chino.kir.corp.google.com>
References: <20100331175836.GA11635@redhat.com> <20100331204718.GD11635@redhat.com> <alpine.DEB.2.00.1004010133190.6285@chino.kir.corp.google.com> <20100401135927.GA12460@redhat.com> <alpine.DEB.2.00.1004011210380.30661@chino.kir.corp.google.com>
 <20100402111406.GA4432@redhat.com> <alpine.DEB.2.00.1004021159310.1773@chino.kir.corp.google.com> <20100402191414.GA982@redhat.com> <alpine.DEB.2.00.1004021244010.15445@chino.kir.corp.google.com> <alpine.DEB.2.00.1004021253480.18402@chino.kir.corp.google.com>
 <20100402210459.GA5112@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

An oom_badness() score of 0 means "never kill" according to
Documentation/filesystems/proc.txt, so exclude it from being selected for
kill.  These tasks have either detached their p->mm or are set to
OOM_DISABLE.

Also removes an unnecessary initialization of points to 0 in
mem_cgroup_out_of_memory(), select_bad_process() does this already.

Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   13 ++-----------
 1 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -326,17 +326,8 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 			*ppoints = 1000;
 		}
 
-		/*
-		 * skip kernel threads and tasks which have already released
-		 * their mm.
-		 */
-		if (!p->mm)
-			continue;
-		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
-			continue;
-
 		points = oom_badness(p, totalpages);
-		if (points > *ppoints || !chosen) {
+		if (points > *ppoints) {
 			chosen = p;
 			*ppoints = points;
 		}
@@ -478,7 +469,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
 {
 	unsigned long limit;
-	unsigned int points = 0;
+	unsigned int points;
 	struct task_struct *p;
 
 	if (sysctl_panic_on_oom == 2)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
