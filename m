Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f171.google.com (mail-vc0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 452DC6B0035
	for <linux-mm@kvack.org>; Wed, 28 May 2014 14:48:14 -0400 (EDT)
Received: by mail-vc0-f171.google.com with SMTP id lc6so12935317vcb.30
        for <linux-mm@kvack.org>; Wed, 28 May 2014 11:48:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id t13si11383405vek.64.2014.05.28.11.48.12
        for <linux-mm@kvack.org>;
        Wed, 28 May 2014 11:48:13 -0700 (PDT)
Message-ID: <53862f6d.0d283a0a.4682.fffffb19SMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] mm/memory-failure.c: support dedicated thread to handle SIGBUS(BUS_MCEERR_AO) thread
Date: Wed, 28 May 2014 14:47:49 -0400
In-Reply-To: <FDBACF11-D9F6-4DE5-A0D4-800903A243B7@gmail.com>
References: <cover.1400607328.git.tony.luck@intel.com> <eb791998a8ada97b204dddf2719a359149e9ae31.1400607328.git.tony.luck@intel.com> <20140523033438.GC16945@gchen.bj.intel.com> <CA+8MBb+Una+Z5Q-Pn0OoMYaaSx9sPJ3fdriMRMgN=CE1Jdp7Cg@mail.gmail.com> <20140527161613.GC4108@mcs.anl.gov> <5384d07e.4504e00a.2680.ffff8c31SMTPIN_ADDED_BROKEN@mx.google.com> <CA+8MBbKuBo4c2v-Y0TOk-LUJuyJsGG=twqQyAPG5WOa8Aj4GyA@mail.gmail.com> <53852abb.867ce00a.3cef.3c7eSMTPIN_ADDED_BROKEN@mx.google.com> <FDBACF11-D9F6-4DE5-A0D4-800903A243B7@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tony.luck@gmail.com
Cc: iskra@mcs.anl.gov, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Borislav Petkov <bp@suse.de>, gong.chen@linux.jf.intel.com

On Tue, May 27, 2014 at 10:09:54PM -0700, Tony Luck wrote:
> I'm exploring options to see what writers of threaded applications might want/need. I'm very doubtful that they would really want "broadcast to all threads". What if there are hundreds or thousands of threads? We send the signals from the context of the thread that hit the error. But that might take a while. Meanwhile any of those threads that were already scheduled on other CPUs are back running again. So there are big races even if we broadcast.

I see, so this approach is not good. I studied another approach and found
that we have PF_MCE_EARLY flags on each thread, so we can implement
a dedicated thread by setting the flag on that thread. IOW, current code
assumes that PF_MCE_EARLY is always set on the main thread (otherwise ignored),
so we can change this behavior.

The following patch makes kernel aware of PF_MCE_EARLY flag on threads.
Could you take a look?

Thanks,
Naoya Horiguchi
---
Date: Wed, 28 May 2014 03:38:33 -0400
Subject: [PATCH] mm/memory-failure.c: support dedicated thread to handle
 SIGBUS(BUS_MCEERR_AO)

Currently memory error handler handles action optional errors in the deferred
manner by default. And if a recovery aware application wants to handle it
immediately, it can do it by setting PF_MCE_EARLY flag. However, such signal
can be sent only to the main thread, so it's problematic if the application
wants to have a dedicated thread to handler such signals.

So this patch adds dedicated thread support to memory error handler. We have
PF_MCE_EARLY flags for each thread separately, so with this patch AO signal
is sent to the thread with PF_MCE_EARLY flag set, not the main thread. If
you want to implement a dedicated thread, you call prctl() to set PF_MCE_EARLY
on the thread.

Memory error handler collects processes to be killed, so this patch lets it
check PF_MCE_EARLY flag on each thread in the collecting routines.

No behavioral change for all non-early kill cases.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 Documentation/vm/hwpoison.txt |  5 ++++
 mm/memory-failure.c           | 68 ++++++++++++++++++++++++++++++-------------
 2 files changed, 53 insertions(+), 20 deletions(-)

diff --git a/Documentation/vm/hwpoison.txt b/Documentation/vm/hwpoison.txt
index 550068466605..1906fd3bea0e 100644
--- a/Documentation/vm/hwpoison.txt
+++ b/Documentation/vm/hwpoison.txt
@@ -84,6 +84,11 @@ PR_MCE_KILL
 		PR_MCE_KILL_EARLY: Early kill
 		PR_MCE_KILL_LATE:  Late kill
 		PR_MCE_KILL_DEFAULT: Use system global default
+	Note that if you want to have a dedicated thread which handles
+	the SIGBUS(BUS_MCEERR_AO) on behalf of the process, you should
+	call prctl() on the thread. Otherwise, the SIGBUS is sent to
+	the main thread.
+
 PR_MCE_KILL_GET
 	return current mode
 
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index a18007ada3cb..3bd0428b2534 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -294,6 +294,46 @@ struct to_kill {
  */
 
 /*
+ * Find a dedicated thread which is supposed to handle SIGBUS(BUS_MCEERR_AO)
+ * on behalf of the thread group. Return task_struct of the (first found)
+ * dedicated thread if found, and return NULL otherwise.
+ */
+static struct task_struct *find_early_kill_thread(struct task_struct *tsk)
+{
+	struct task_struct *t;
+	rcu_read_lock();
+	for_each_thread(tsk, t)
+		if (t->flags & PF_MCE_PROCESS && t->flags & PF_MCE_EARLY)
+			goto found;
+	t = NULL;
+found:
+	rcu_read_unlock();
+	return t;
+}
+
+/*
+ * Determine whether a given process is "early kill" process which expects
+ * to be signaled when some page under the process is hwpoisoned.
+ * Return task_struct of the dedicated thread (main thread unless explicitly
+ * specified) if the process is "early kill," and otherwise returns NULL.
+ */
+static struct task_struct *task_early_kill(struct task_struct *tsk,
+					   int force_early)
+{
+	struct task_struct *t;
+	if (!tsk->mm)
+		return NULL;
+	if (force_early)
+		return tsk;
+	t = find_early_kill_thread(tsk);
+	if (t)
+		return t;
+	if (sysctl_memory_failure_early_kill)
+		return tsk;
+	return NULL;
+}
+
+/*
  * Schedule a process for later kill.
  * Uses GFP_ATOMIC allocations to avoid potential recursions in the VM.
  * TBD would GFP_NOIO be enough?
@@ -380,17 +420,6 @@ static void kill_procs(struct list_head *to_kill, int forcekill, int trapno,
 	}
 }
 
-static int task_early_kill(struct task_struct *tsk, int force_early)
-{
-	if (!tsk->mm)
-		return 0;
-	if (force_early)
-		return 1;
-	if (tsk->flags & PF_MCE_PROCESS)
-		return !!(tsk->flags & PF_MCE_EARLY);
-	return sysctl_memory_failure_early_kill;
-}
-
 /*
  * Collect processes when the error hit an anonymous page.
  */
@@ -410,16 +439,16 @@ static void collect_procs_anon(struct page *page, struct list_head *to_kill,
 	read_lock(&tasklist_lock);
 	for_each_process (tsk) {
 		struct anon_vma_chain *vmac;
-
-		if (!task_early_kill(tsk, force_early))
+		struct task_struct *t = task_early_kill(tsk, force_early);
+		if (!t)
 			continue;
 		anon_vma_interval_tree_foreach(vmac, &av->rb_root,
 					       pgoff, pgoff) {
 			vma = vmac->vma;
 			if (!page_mapped_in_vma(page, vma))
 				continue;
-			if (vma->vm_mm == tsk->mm)
-				add_to_kill(tsk, page, vma, to_kill, tkc);
+			if (vma->vm_mm == t->mm)
+				add_to_kill(t, page, vma, to_kill, tkc);
 		}
 	}
 	read_unlock(&tasklist_lock);
@@ -440,10 +469,9 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 	read_lock(&tasklist_lock);
 	for_each_process(tsk) {
 		pgoff_t pgoff = page_pgoff(page);
-
-		if (!task_early_kill(tsk, force_early))
+		struct task_struct *t = task_early_kill(tsk, force_early);
+		if (!t)
 			continue;
-
 		vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff,
 				      pgoff) {
 			/*
@@ -453,8 +481,8 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 			 * Assume applications who requested early kill want
 			 * to be informed of all such data corruptions.
 			 */
-			if (vma->vm_mm == tsk->mm)
-				add_to_kill(tsk, page, vma, to_kill, tkc);
+			if (vma->vm_mm == t->mm)
+				add_to_kill(t, page, vma, to_kill, tkc);
 		}
 	}
 	read_unlock(&tasklist_lock);
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
