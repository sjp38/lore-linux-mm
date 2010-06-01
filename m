Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 84E246B01DF
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 03:19:13 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o517JAbi020019
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 00:19:10 -0700
Received: from pxi5 (pxi5.prod.google.com [10.243.27.5])
	by kpbe14.cbf.corp.google.com with ESMTP id o517J8Ce009889
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 00:19:08 -0700
Received: by pxi5 with SMTP id 5so2658519pxi.37
        for <linux-mm@kvack.org>; Tue, 01 Jun 2010 00:19:08 -0700 (PDT)
Date: Tue, 1 Jun 2010 00:19:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 14/18] oom: check PF_KTHREAD instead of !mm to skip
 kthreads
In-Reply-To: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006010016580.29202@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: Oleg Nesterov <oleg@redhat.com>

select_bad_process() thinks a kernel thread can't have ->mm != NULL, this
is not true due to use_mm().

Change the code to check PF_KTHREAD.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -317,8 +317,8 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 	for_each_process(p) {
 		unsigned int points;
 
-		/* skip the init task */
-		if (is_global_init(p))
+		/* skip the init task and kthreads */
+		if (is_global_init(p) || (p->flags & PF_KTHREAD))
 			continue;
 		if (mem && !task_in_mem_cgroup(p, mem))
 			continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
