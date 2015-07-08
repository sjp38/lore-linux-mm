Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id EE4796B0255
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 09:04:33 -0400 (EDT)
Received: by lagc2 with SMTP id c2so221982596lag.3
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 06:04:33 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id en18si3855472wjd.70.2015.07.08.06.04.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Jul 2015 06:04:25 -0700 (PDT)
From: Michal Hocko <mhocko@suse.com>
Subject: [PATCH 1/4] oom: Do not panic when OOM killer is sysrq triggered
Date: Wed,  8 Jul 2015 15:04:18 +0200
Message-Id: <1436360661-31928-2-git-send-email-mhocko@suse.com>
In-Reply-To: <1436360661-31928-1-git-send-email-mhocko@suse.com>
References: <1436360661-31928-1-git-send-email-mhocko@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Jakob Unterwurzacher <jakobunt@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

From: Michal Hocko <mhocko@suse.cz>

OOM killer might be triggered explicitly via sysrq+f. This is supposed
to kill a task no matter what e.g. a task is selected even though there
is an OOM victim on the way to exit. This is a big hammer for an admin
to help to resolve a memory short condition when the system is not able
to cope with it on its own in a reasonable time frame (e.g. when the
system is trashing or the OOM killer cannot make sufficient progress)

E.g. it doesn't make any sense to obey panic_on_oom setting because
a) administrator could have used other sysrqs to achieve the
panic/reboot and b) the policy would break an existing usecase to
kill a memory hog which would be recoverable unlike the panic which
might be configured for the real OOM condition.

It also doesn't make much sense to panic the system when there is no
OOM killable task because administrator might choose to do additional
steps before rebooting/panicking the system.

While we are there also add a comment explaining why
sysctl_oom_kill_allocating_task doesn't apply to sysrq triggered OOM
killer even though there is no explicit check and we subtly rely
on current->mm being NULL for the context from which it is triggered.

Also be more explicit about sysrq+f behavior in the documentation.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 Documentation/sysrq.txt |  5 ++++-
 mm/oom_kill.c           | 15 ++++++++++++---
 2 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/Documentation/sysrq.txt b/Documentation/sysrq.txt
index 0e307c94809a..7664e93411d2 100644
--- a/Documentation/sysrq.txt
+++ b/Documentation/sysrq.txt
@@ -75,7 +75,10 @@ On other - If you know of the key combos for other architectures, please
 
 'e'     - Send a SIGTERM to all processes, except for init.
 
-'f'	- Will call oom_kill to kill a memory hog process.
+'f'	- Will call oom_kill to kill a memory hog process. Please note that
+	  parallel OOM killer is ignored and a task is killed even though
+	  there was an oom victim selected already. panic_on_oom is ignored
+	  and the system doesn't panic if there are no oom killable tasks.
 
 'g'	- Used by kgdb (kernel debugger)
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index dff991e0681e..f2737d66f66a 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -687,8 +687,13 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	constraint = constrained_alloc(zonelist, gfp_mask, nodemask,
 						&totalpages);
 	mpol_mask = (constraint == CONSTRAINT_MEMORY_POLICY) ? nodemask : NULL;
-	check_panic_on_oom(constraint, gfp_mask, order, mpol_mask, NULL);
+	if (!force_kill)
+		check_panic_on_oom(constraint, gfp_mask, order, mpol_mask, NULL);
 
+	/*
+	 * not affecting force_kill because sysrq triggered OOM killer runs from
+	 * the workqueue context so current->mm will be NULL
+	 */
 	if (sysctl_oom_kill_allocating_task && current->mm &&
 	    !oom_unkillable_task(current, NULL, nodemask) &&
 	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
@@ -702,8 +707,12 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	p = select_bad_process(&points, totalpages, mpol_mask, force_kill);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!p) {
-		dump_header(NULL, gfp_mask, order, NULL, mpol_mask);
-		panic("Out of memory and no killable processes...\n");
+		if (!force_kill) {
+			dump_header(NULL, gfp_mask, order, NULL, mpol_mask);
+			panic("Out of memory and no killable processes...\n");
+		} else {
+			pr_info("Sysrq triggered out of memory. No killable task found...\n");
+		}
 	}
 	if (p != (void *)-1UL) {
 		oom_kill_process(p, gfp_mask, order, points, totalpages, NULL,
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
