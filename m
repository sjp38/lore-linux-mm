Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 08FCB6B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 04:57:46 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [10.3.21.14])
	by smtp-out.google.com with ESMTP id o318vg6A012252
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 01:57:43 -0700
Received: from pwi1 (pwi1.prod.google.com [10.241.219.1])
	by hpaq14.eem.corp.google.com with ESMTP id o318vdjE003551
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 10:57:41 +0200
Received: by pwi1 with SMTP id 1so820627pwi.39
        for <linux-mm@kvack.org>; Thu, 01 Apr 2010 01:57:39 -0700 (PDT)
Date: Thu, 1 Apr 2010 01:57:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] oom: hold tasklist_lock when dumping tasks
In-Reply-To: <alpine.DEB.2.00.1004010133190.6285@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1004010157020.29497@chino.kir.corp.google.com>
References: <20100326150805.f5853d1c.akpm@linux-foundation.org> <20100326223356.GA20833@redhat.com> <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com> <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com>
 <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330154659.GA12416@redhat.com> <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com> <20100331175836.GA11635@redhat.com> <20100331204718.GD11635@redhat.com>
 <alpine.DEB.2.00.1004010133190.6285@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

dump_header() always requires tasklist_lock to be held because it calls 
dump_tasks() which iterates through the tasklist.  There are a few places
where this isn't maintained, so make sure tasklist_lock is always held
whenever calling dump_header().

Reported-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   23 ++++++++++-------------
 1 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -395,6 +395,9 @@ static void dump_tasks(const struct mem_cgroup *mem)
 	} while_each_thread(g, p);
 }
 
+/*
+ * Call with tasklist_lock read-locked.
+ */
 static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 							struct mem_cgroup *mem)
 {
@@ -641,8 +644,8 @@ retry:
 
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!p) {
-		read_unlock(&tasklist_lock);
 		dump_header(NULL, gfp_mask, order, NULL);
+		read_unlock(&tasklist_lock);
 		panic("Out of memory and no killable processes...\n");
 	}
 
@@ -675,11 +678,6 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		/* Got some memory back in the last second. */
 		return;
 
-	if (sysctl_panic_on_oom == 2) {
-		dump_header(NULL, gfp_mask, order, NULL);
-		panic("out of memory. Compulsory panic_on_oom is selected.\n");
-	}
-
 	/*
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA) that may require different handling.
@@ -688,15 +686,12 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 						&totalpages);
 	read_lock(&tasklist_lock);
 	if (unlikely(sysctl_panic_on_oom)) {
-		/*
-		 * panic_on_oom only affects CONSTRAINT_NONE, the kernel
-		 * should not panic for cpuset or mempolicy induced memory
-		 * failures.
-		 */
-		if (constraint == CONSTRAINT_NONE) {
+		if (sysctl_panic_on_oom == 2 || constraint == CONSTRAINT_NONE) {
 			dump_header(NULL, gfp_mask, order, NULL);
 			read_unlock(&tasklist_lock);
-			panic("Out of memory: panic_on_oom is enabled\n");
+			panic("Out of memory: %s panic_on_oom is enabled\n",
+				sysctl_panic_on_oom == 2 ? "compulsory" :
+							   "system-wide");
 		}
 	}
 	__out_of_memory(gfp_mask, order, totalpages, constraint, nodemask);
@@ -724,8 +719,10 @@ void pagefault_out_of_memory(void)
 
 	if (try_set_system_oom()) {
 		constrained_alloc(NULL, 0, NULL, &totalpages);
+		read_lock(&tasklist_lock);
 		err = oom_kill_process(current, 0, 0, 0, totalpages, NULL,
 					"Out of memory (pagefault)");
+		read_unlock(&tasklist_lock);
 		if (err)
 			out_of_memory(NULL, 0, 0, NULL);
 		clear_system_oom();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
