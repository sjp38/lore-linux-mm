Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1C23A6B0256
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 09:04:36 -0400 (EDT)
Received: by wifm2 with SMTP id m2so88910349wif.1
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 06:04:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f4si3876627wjs.29.2015.07.08.06.04.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Jul 2015 06:04:26 -0700 (PDT)
From: Michal Hocko <mhocko@suse.com>
Subject: [PATCH 4/4] oom: split out forced OOM killer
Date: Wed,  8 Jul 2015 15:04:21 +0200
Message-Id: <1436360661-31928-5-git-send-email-mhocko@suse.com>
In-Reply-To: <1436360661-31928-1-git-send-email-mhocko@suse.com>
References: <1436360661-31928-1-git-send-email-mhocko@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Jakob Unterwurzacher <jakobunt@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

From: Michal Hocko <mhocko@suse.cz>

The forced OOM killing is currently wired into out_of_memory() call
even though their objective is different which makes the code ugly
and harder to follow. Generic out_of_memory path has to deal with
configuration settings and heuristics which are completely irrelevant
to the forced OOM killer (e.g. sysctl_oom_kill_allocating_task or
OOM killer prevention for already dying tasks). All of them are
either relying on explicit force_kill check or indirectly by checking
current->mm which is always NULL for sysrq+f. This is not nice, hard
to follow and error prone.

Let's pull forced OOM killer code out into a separate function
(force_out_of_memory) which is really trivial now.
As a bonus we can clearly state that this is a forced OOM killer
in the OOM message which is helpful to distinguish it from the
regular OOM killer.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 drivers/tty/sysrq.c |  9 +--------
 include/linux/oom.h |  1 +
 mm/oom_kill.c       | 57 ++++++++++++++++++++++++++++++++++++-----------------
 3 files changed, 41 insertions(+), 26 deletions(-)

diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
index 865b837a9aee..6a3def693ded 100644
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -356,15 +356,8 @@ static struct sysrq_key_op sysrq_term_op = {
 
 static void moom_callback(struct work_struct *ignored)
 {
-	const gfp_t gfp_mask = GFP_KERNEL;
-	struct oom_context oc = {
-		.zonelist = node_zonelist(first_memory_node, gfp_mask),
-		.gfp_mask = gfp_mask,
-		.force_kill = true,
-	};
-
 	mutex_lock(&oom_lock);
-	if (!out_of_memory(&oc))
+	if (!force_out_of_memory())
 		pr_info("OOM request ignored because killer is disabled\n");
 	mutex_unlock(&oom_lock);
 }
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 094407cb2d2e..6af2d12d6134 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -77,6 +77,7 @@ extern enum oom_scan_t oom_scan_process_thread(struct oom_context *oc,
 		struct task_struct *task, unsigned long totalpages);
 
 extern bool out_of_memory(struct oom_context *oc);
+extern bool force_out_of_memory(void);
 
 extern void exit_oom_victim(void);
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 01aa4cb86857..6a0b09296236 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -627,6 +627,38 @@ int unregister_oom_notifier(struct notifier_block *nb)
 EXPORT_SYMBOL_GPL(unregister_oom_notifier);
 
 /**
+ * force_out_of_memory - forces OOM killer to kill a process
+ *
+ * Explicitly trigger the OOM killer. The system doesn't have to be under
+ * OOM condition (e.g. sysrq+f).
+ */
+bool force_out_of_memory(void)
+{
+	struct task_struct *p;
+	unsigned long totalpages;
+	unsigned int points;
+	const gfp_t gfp_mask = GFP_KERNEL;
+	struct oom_context oc = {
+		.zonelist = node_zonelist(first_memory_node, gfp_mask),
+		.gfp_mask = gfp_mask,
+		.force_kill = true,
+	};
+
+	if (oom_killer_disabled)
+		return false;
+
+	constrained_alloc(&oc, &totalpages);
+	p = select_bad_process(&oc, &points, totalpages);
+	if (p != (void *)-1UL)
+		oom_kill_process(&oc, p, points, totalpages, NULL,
+				 "Forced out of memory killer");
+	else
+		pr_warn("Sysrq triggered out of memory. No killable task found...\n");
+
+	return true;
+}
+
+/**
  * out_of_memory - kill the "best" process when we run out of memory
  * @oc: pointer to struct oom_context
  *
@@ -647,12 +679,10 @@ bool out_of_memory(struct oom_context *oc)
 	if (oom_killer_disabled)
 		return false;
 
-	if (!oc->force_kill) {
-		blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
-		if (freed > 0)
-			/* Got some memory back in the last second. */
-			goto out;
-	}
+	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
+	if (freed > 0)
+		/* Got some memory back in the last second. */
+		goto out;
 
 	/*
 	 * If current has a pending SIGKILL or is exiting, then automatically
@@ -675,13 +705,8 @@ bool out_of_memory(struct oom_context *oc)
 	constraint = constrained_alloc(oc, &totalpages);
 	if (constraint != CONSTRAINT_MEMORY_POLICY)
 		oc->nodemask = NULL;
-	if (!oc->force_kill)
-		check_panic_on_oom(oc, constraint, NULL);
+	check_panic_on_oom(oc, constraint, NULL);
 
-	/*
-	 * not affecting force_kill because sysrq triggered OOM killer runs from
-	 * the workqueue context so current->mm will be NULL
-	 */
 	if (sysctl_oom_kill_allocating_task && current->mm &&
 	    !oom_unkillable_task(current, NULL, oc->nodemask) &&
 	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
@@ -694,12 +719,8 @@ bool out_of_memory(struct oom_context *oc)
 	p = select_bad_process(oc, &points, totalpages);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!p) {
-		if (!oc->force_kill) {
-			dump_header(oc, NULL, NULL);
-			panic("Out of memory and no killable processes...\n");
-		} else {
-			pr_info("Sysrq triggered out of memory. No killable task found...\n");
-		}
+		dump_header(oc, NULL, NULL);
+		panic("Out of memory and no killable processes...\n");
 	}
 	if (p != (void *)-1UL) {
 		oom_kill_process(oc, p, points, totalpages, NULL,
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
