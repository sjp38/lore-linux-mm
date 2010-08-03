Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1A2D46008E4
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 01:55:24 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7360YqC016205
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 3 Aug 2010 15:00:34 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E1B345DE4F
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 15:00:34 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 25A0F45DE4E
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 15:00:34 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B00E21DB8014
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 15:00:33 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id F0D241DB8013
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 15:00:32 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 1/2] oom: badness heuristic rewrite
In-Reply-To: <20100802134312.c0f48615.akpm@linux-foundation.org>
References: <20100730195338.4AF6.A69D9226@jp.fujitsu.com> <20100802134312.c0f48615.akpm@linux-foundation.org>
Message-Id: <20100803114624.5A6F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  3 Aug 2010 15:00:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@in.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Fri, 30 Jul 2010 20:02:13 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > On Fri, 30 Jul 2010 09:12:26 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > > 
> > > > > On Sat, 17 Jul 2010 12:16:33 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> > > > > 
> > > > > > This a complete rewrite of the oom killer's badness() heuristic 
> > > > > 
> > > > > Any comments here, or are we ready to proceed?
> > > > > 
> > > > > Gimme those acked-bys, reviewed-bys and tested-bys, please!
> > > > 
> > > > If he continue to resend all of rewrite patch, I continue to refuse them.
> > > > I explained it multi times.
> > > 
> > > There are about 1000 emails on this topic.  Please briefly explain it again.
> > 
> > Major homework are
> > 
> > - make patch series instead unreviewable all in one patch.
> 
> Sometimes that's not very practical and the splitup isn't necessarily a
> lot easier to understand and review.

Yes, sometimes. 
But in this case, _I_ am reviewing the patch sometimes and I'd say. Isn't
this enough reason?


> It's still possible to review the end result - just read the patched code.
> 
> > - kill oom_score_adj
> 
> Unclear why?

Summrize here

1. kosaki pointed some technical issue.

Tue,  8 Jun 2010
KOSAKI Motohiro wrote:
> Sorry I can't ack this. again and again, I try to explain why this is wrong
> (hopefully last)
> 
> 1) incompatibility
>    oom_score is one of ABI. then, we can't change this. from enduser view,
>    this change is no merit. In general, an incompatibility is allowed on very
>    limited situation such as that an end-user get much benefit than compatibility.
>    In other word, old style ABI doesn't works fine from end user view.
>    But, in this case, it isn't.
> 
> 2) technically incorrect
>    this math is not correct math. this is not represented "allowed memory".
>    example, 1) this is not accumulated mlocked memory, but it can be freed
>    task kill 2) SHM_LOCKED memory freeablility depend on IPC_RMID did or not.
>    if not, task killing doesn't free SYSV IPC memory.
>    In additon, 3) This normalization doesn't works on asymmetric numa. 
>    total pages and oom are not related almostly. 4) scalability. if the 
>    system 10TB memory, 1 point oom score mean 10GB memory consumption.
>    it seems too rough. generically, a value suppression itself is evil for
>    scalability software.
> 
> Then, we can't merge this our kernel. if your workload really need this,
> we consider following simplest hook instead.
> 
> 	if (badness_hook_fn)
> 		points = badness_hook_fn(p)
> 	else
> 		points = oom_badness(p);
> 
> Please implement your specific oom-score in your hook func.


2. akpm also wrote this

Andrew Morton wrote:
> On Sun, 6 Jun 2010 15:34:54 -0700 (PDT)
> David Rientjes <rientjes@google.com> wrote:
> 
> > This a complete rewrite of the oom killer's badness() heuristic which is
> > used to determine which task to kill in oom conditions.  The goal is to
> > make it as simple and predictable as possible so the results are better
> > understood and we end up killing the task which will lead to the most
> > memory freeing while still respecting the fine-tuning from userspace.
> 
> It's not obvious from this description that then end result is better! 
> Have you any testcases or scenarios which got improved?
> 
> > Instead of basing the heuristic on mm->total_vm for each task, the task's
> > rss and swap space is used instead.  This is a better indication of the
> > amount of memory that will be freeable if the oom killed task is chosen
> > and subsequently exits.
> 
> Again, why should we optimise for the amount of memory which a killing
> will yield (if that's what you mean).  We only need to free enough
> memory to unblock the oom condition then proceed.
> 
> The last thing we want to do is to kill a process which has consumed
> 1000 CPU hours, or which is providing some system-critical service or
> whatever.  Amount-of-memory-freeable is a relatively minor criterion.
> 
> >  This helps specifically in cases where KDE or
> > GNOME is chosen for oom kill on desktop systems instead of a memory
> > hogging task.
> 
> It helps how?  Examples and test cases?
> 
> > The baseline for the heuristic is a proportion of memory that each task is
> > currently using in memory plus swap compared to the amount of "allowable"
> > memory.
> 
> What does "swap" mean?  swapspace includes swap-backed swapcache,
> un-swap-backed swapcache and non-resident swap.  Which of all these is
> being used here and for what reason?
> 
> >  "Allowable," in this sense, means the system-wide resources for
> > unconstrained oom conditions, the set of mempolicy nodes, the mems
> > attached to current's cpuset, or a memory controller's limit.  The
> > proportion is given on a scale of 0 (never kill) to 1000 (always kill),
> > roughly meaning that if a task has a badness() score of 500 that the task
> > consumes approximately 50% of allowable memory resident in RAM or in swap
> > space.
> 
> So is a new aim of this code to also free up swap space?  Confused.
> 
> > The proportion is always relative to the amount of "allowable" memory and
> > not the total amount of RAM systemwide so that mempolicies and cpusets may
> > operate in isolation; they shall not need to know the true size of the
> > machine on which they are running if they are bound to a specific set of
> > nodes or mems, respectively.
> > 
> > Root tasks are given 3% extra memory just like __vm_enough_memory()
> > provides in LSMs.  In the event of two tasks consuming similar amounts of
> > memory, it is generally better to save root's task.
> > 
> > Because of the change in the badness() heuristic's baseline, it is also
> > necessary to introduce a new user interface to tune it.  It's not possible
> > to redefine the meaning of /proc/pid/oom_adj with a new scale since the
> > ABI cannot be changed for backward compatability.  Instead, a new tunable,
> > /proc/pid/oom_score_adj, is added that ranges from -1000 to +1000.  It may
> > be used to polarize the heuristic such that certain tasks are never
> > considered for oom kill while others may always be considered.  The value
> > is added directly into the badness() score so a value of -500, for
> > example, means to discount 50% of its memory consumption in comparison to
> > other tasks either on the system, bound to the mempolicy, in the cpuset,
> > or sharing the same memory controller.
> > 
> > /proc/pid/oom_adj is changed so that its meaning is rescaled into the
> > units used by /proc/pid/oom_score_adj, and vice versa.  Changing one of
> > these per-task tunables will rescale the value of the other to an
> > equivalent meaning.  Although /proc/pid/oom_adj was originally defined as
> > a bitshift on the badness score, it now shares the same linear growth as
> > /proc/pid/oom_score_adj but with different granularity.  This is required
> > so the ABI is not broken with userspace applications and allows oom_adj to
> > be deprecated for future removal.
> 
> It was a mistake to add oom_adj in the first place.  Because it's a
> user-visible knob which us tied to a particular in-kernel
> implementation.  As we're seeing now, the presence of that knob locks
> us into a particular implementation.
> 
> Given that oom_score_adj is just a rescaled version of oom_adj
> (correct?), I guess things haven't got a lot worse on that front as a
> result of these changes.
> 
> 
> General observation regarding the patch description: I'm not seeing a
> lot of reason for merging the patch!  What value does it bring to our
> users?  What problems got solved?
> 
> Some of Kosaki's observations sounded fairly serious so I'll go into
> wait-and-see mode on this patch.


But any issue have not been fixed yet if my understanding is correct.

I didn't wrote "hey! this is still buggy" because the patch is still
unreviewable chaos and I can missed something.



Another summize here, 

1. I pointed out oom_score_adj is too google specific and harmful for
   desktop user.


> > > But oom_score_adj have no benefit form end-uses view. That's problem.
> > > Please consider to make end-user friendly good patch at first.
> > > 
> > 
> > Of course it does, it actually has units whereas oom_adj only grows or 
> > shrinks the badness score exponentially.  oom_score_adj's units are well 
> > understood: on a machine with 4G of memory, 250 means we're trying to 
> > prejudice it by 1G of memory so that can be used by other tasks, -250 
> > means other tasks should be prejudiced by 1G in comparison to this task, 
> > etc.  It's actually quite powerful.
> 
> And, no real user want such power.
> 
> When we consider desktop user case, End-users don't use oom_adj by themself.
> their application are using it.  It mean now oom_adj behave as syscall like
> system interface, unlike kernel knob. application developers also don't 
> need oom_score_adj because application developers don't know end-users 
> machine mem size.
> 
> Then, you will get the change's merit but end users will get the demerit.
> That's out of balance.


2. DavidR answered this.


> > > Of course it does, it actually has units whereas oom_adj only grows or 
> > > shrinks the badness score exponentially.  oom_score_adj's units are well 
> > > understood: on a machine with 4G of memory, 250 means we're trying to 
> > > prejudice it by 1G of memory so that can be used by other tasks, -250 
> > > means other tasks should be prejudiced by 1G in comparison to this task, 
> > > etc.  It's actually quite powerful.
> > 
> > And, no real user want such power.
> > 
> 
> Google does, and I imagine other users will want to be able to normalize 
> each task's memory usage against the others.  It's perfectly legitimate 
> for one task to consume 3G while another consumes 1G and want to select 
> the 1G task to kill.  Setting the 3G task's oom_score_adj value in this 
> case to be -250, for example, depending on the memory capacity of the 
> machine, makes much more sense than influencing it as a bitshift on 
> top of a vastly unpredictable heuristic with oom_adj.  This seems rather 
> trivial to understand.
> 
> > When we consider desktop user case, End-users don't use oom_adj by themself.
> > their application are using it.  It mean now oom_adj behave as syscall like
> > system interface, unlike kernel knob. application developers also don't 
> > need oom_score_adj because application developers don't know end-users 
> > machine mem size.
> > 
> 
> I agree, oom_score_adj isn't targeted to the desktop nor is it targeted to 
> application developers (unless they are setting it to OOM_SCORE_ADJ_MIN to 
> disable oom killing for that task, for example).  It's targeted at 
> sysadmins and daemons that partition a machine to run a number of 
> concurrent jobs.  It's fine to use memcg, for example, to do such 
> partitioning, but memcg can also cause oom conditions with the cgroup.  We 
> want to be able to tell the kernel, through an interface such as this, 
> that one task shouldn't killed because it's expected to use 3G of memory 
> but should be killed when it's using 8G, for example.

I thought he agree to remove desktop regression and back to requirement 
analisys and make much better patches. but It didn't happen. I'm sad.

Although someone think google usecase is most important in the world, _I_
don't think so yet. I still worry about rest almost all user.

I'm complain just resending an unfixed patch set.



> > - write test way and test result
> 
> I think David's done quite a bit of that?

Hmm, you misunderstand my point, probably my last mail was unclear.
I'm sorry.

I didn't say he didn't tested. I'd say, need to confirm test cases
match typical use case. About two month ago, David posted previous 
patch series. he and you talked about this is well tested. but When
I ran, forkbom detection feature of it don't works at all in typical
case. That said, google testing/production enviromnnet is a bit
differenct from other almost world. I'm worry about this.

And again, I'd prefer to ack all of desktop improvemnt and prefer to
nack all of desktop regression. Is there any reason to refuse test
case inspection?



> > So, I'm pending reviewing until finish them. I'd like to point out 
> > rest minor topics while reviewing process.
> 
> I think I'll merge it into 2.6.36.  That gives us two months to
> continue to review it, to test it and if necessary, to fix it or revert
> it.

I have question. Why did you changed your mention? All of your question
were solved? if so, can you please share your conclustion and decision
reason?


While observe this thread, kamezawa-san found another problem in
oom_score_adj, but he seems to prefer to merge rest parts.

So, I would propose minimum oom_score_adj reverting patch here.
I don't worry rest parts so much. because they don't have ABI change.
so we can revert them later if we've found another issue later.

Thanks.



============================================================
Subject: [PATCH] revert oom_score_adj

oom_score_adj bring to a lot of harm than its worth. and It haven't
get any concensus. so revert it.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 Documentation/feature-removal-schedule.txt |   25 -----
 Documentation/filesystems/proc.txt         |   97 +++++++-----------
 fs/proc/base.c                             |   99 +-----------------
 include/linux/memcontrol.h                 |    8 --
 include/linux/oom.h                        |   14 +--
 include/linux/sched.h                      |    1 -
 kernel/fork.c                              |    1 -
 mm/memcontrol.c                            |   18 ----
 mm/oom_kill.c                              |  154 +++++++++++-----------------
 9 files changed, 99 insertions(+), 318 deletions(-)

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 19b0a3a..702a5a8 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -151,31 +151,6 @@ Who:	Eric Biederman <ebiederm@xmission.com>
 
 ---------------------------
 
-What:	/proc/<pid>/oom_adj
-When:	August 2012
-Why:	/proc/<pid>/oom_adj allows userspace to influence the oom killer's
-	badness heuristic used to determine which task to kill when the kernel
-	is out of memory.
-
-	The badness heuristic has since been rewritten since the introduction of
-	this tunable such that its meaning is deprecated.  The value was
-	implemented as a bitshift on a score generated by the badness()
-	function that did not have any precise units of measure.  With the
-	rewrite, the score is given as a proportion of available memory to the
-	task allocating pages, so using a bitshift which grows the score
-	exponentially is, thus, impossible to tune with fine granularity.
-
-	A much more powerful interface, /proc/<pid>/oom_score_adj, was
-	introduced with the oom killer rewrite that allows users to increase or
-	decrease the badness() score linearly.  This interface will replace
-	/proc/<pid>/oom_adj.
-
-	A warning will be emitted to the kernel log if an application uses this
-	deprecated interface.  After it is printed once, future warnings will be
-	suppressed until the kernel is rebooted.
-
----------------------------
-
 What:	remove EXPORT_SYMBOL(kernel_thread)
 When:	August 2006
 Files:	arch/*/kernel/*_ksyms.c
diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index bf6ab27..9fb6cbe 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -33,8 +33,7 @@ Table of Contents
   2	Modifying System Parameters
 
   3	Per-Process Parameters
-  3.1	/proc/<pid>/oom_adj & /proc/<pid>/oom_score_adj - Adjust the oom-killer
-								score
+  3.1	/proc/<pid>/oom_adj - Adjust the oom-killer score
   3.2	/proc/<pid>/oom_score - Display current oom-killer score
   3.3	/proc/<pid>/io - Display the IO accounting fields
   3.4	/proc/<pid>/coredump_filter - Core dump filtering settings
@@ -1235,64 +1234,42 @@ of the kernel.
 CHAPTER 3: PER-PROCESS PARAMETERS
 ------------------------------------------------------------------------------
 
-3.1 /proc/<pid>/oom_adj & /proc/<pid>/oom_score_adj- Adjust the oom-killer score
---------------------------------------------------------------------------------
-
-These file can be used to adjust the badness heuristic used to select which
-process gets killed in out of memory conditions.
-
-The badness heuristic assigns a value to each candidate task ranging from 0
-(never kill) to 1000 (always kill) to determine which process is targeted.  The
-units are roughly a proportion along that range of allowed memory the process
-may allocate from based on an estimation of its current memory and swap use.
-For example, if a task is using all allowed memory, its badness score will be
-1000.  If it is using half of its allowed memory, its score will be 500.
-
-There is an additional factor included in the badness score: root
-processes are given 3% extra memory over other tasks.
-
-The amount of "allowed" memory depends on the context in which the oom killer
-was called.  If it is due to the memory assigned to the allocating task's cpuset
-being exhausted, the allowed memory represents the set of mems assigned to that
-cpuset.  If it is due to a mempolicy's node(s) being exhausted, the allowed
-memory represents the set of mempolicy nodes.  If it is due to a memory
-limit (or swap limit) being reached, the allowed memory is that configured
-limit.  Finally, if it is due to the entire system being out of memory, the
-allowed memory represents all allocatable resources.
-
-The value of /proc/<pid>/oom_score_adj is added to the badness score before it
-is used to determine which task to kill.  Acceptable values range from -1000
-(OOM_SCORE_ADJ_MIN) to +1000 (OOM_SCORE_ADJ_MAX).  This allows userspace to
-polarize the preference for oom killing either by always preferring a certain
-task or completely disabling it.  The lowest possible value, -1000, is
-equivalent to disabling oom killing entirely for that task since it will always
-report a badness score of 0.
-
-Consequently, it is very simple for userspace to define the amount of memory to
-consider for each task.  Setting a /proc/<pid>/oom_score_adj value of +500, for
-example, is roughly equivalent to allowing the remainder of tasks sharing the
-same system, cpuset, mempolicy, or memory controller resources to use at least
-50% more memory.  A value of -500, on the other hand, would be roughly
-equivalent to discounting 50% of the task's allowed memory from being considered
-as scoring against the task.
-
-For backwards compatibility with previous kernels, /proc/<pid>/oom_adj may also
-be used to tune the badness score.  Its acceptable values range from -16
-(OOM_ADJUST_MIN) to +15 (OOM_ADJUST_MAX) and a special value of -17
-(OOM_DISABLE) to disable oom killing entirely for that task.  Its value is
-scaled linearly with /proc/<pid>/oom_score_adj.
-
-Writing to /proc/<pid>/oom_score_adj or /proc/<pid>/oom_adj will change the
-other with its scaled value.
-
-NOTICE: /proc/<pid>/oom_adj is deprecated and will be removed, please see
-Documentation/feature-removal-schedule.txt.
-
-Caveat: when a parent task is selected, the oom killer will sacrifice any first
-generation children with seperate address spaces instead, if possible.  This
-avoids servers and important system daemons from being killed and loses the
-minimal amount of work.
-
+3.1 /proc/<pid>/oom_adj - Adjust the oom-killer score
+------------------------------------------------------
+
+This file can be used to adjust the score used to select which processes
+should be killed in an  out-of-memory  situation.  Giving it a high score will
+increase the likelihood of this process being killed by the oom-killer.  Valid
+values are in the range -16 to +15, plus the special value -17, which disables
+oom-killing altogether for this process.
+
+The process to be killed in an out-of-memory situation is selected among all others
+based on its badness score. This value equals the original memory size of the process
+and is then updated according to its CPU time (utime + stime) and the
+run time (uptime - start time). The longer it runs the smaller is the score.
+Badness score is divided by the square root of the CPU time and then by
+the double square root of the run time.
+
+Swapped out tasks are killed first. Half of each child's memory size is added to
+the parent's score if they do not share the same memory. Thus forking servers
+are the prime candidates to be killed. Having only one 'hungry' child will make
+parent less preferable than the child.
+
+/proc/<pid>/oom_score shows process' current badness score.
+
+The following heuristics are then applied:
+ * if the task was reniced, its score doubles
+ * superuser or direct hardware access tasks (CAP_SYS_ADMIN, CAP_SYS_RESOURCE
+ 	or CAP_SYS_RAWIO) have their score divided by 4
+ * if oom condition happened in one cpuset and checked process does not belong
+ 	to it, its score is divided by 8
+ * the resulting score is multiplied by two to the power of oom_adj, i.e.
+	points <<= oom_adj when it is positive and
+	points >>= -(oom_adj) otherwise
+
+The task with the highest badness score is then selected and its children
+are killed, process itself will be killed in an OOM situation when it does
+not have children or some of them disabled oom like described above.
 
 3.2 /proc/<pid>/oom_score - Display current oom-killer score
 -------------------------------------------------------------
diff --git a/fs/proc/base.c b/fs/proc/base.c
index cad2e08..f238415 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -434,8 +434,7 @@ static int proc_oom_score(struct task_struct *task, char *buffer)
 
 	read_lock(&tasklist_lock);
 	if (pid_alive(task))
-		points = oom_badness(task, NULL, NULL,
-					totalram_pages + total_swap_pages);
+		points = oom_badness(task, NULL, NULL);
 	read_unlock(&tasklist_lock);
 	return sprintf(buffer, "%lu\n", points);
 }
@@ -1049,24 +1048,8 @@ static ssize_t oom_adjust_write(struct file *file, const char __user *buf,
 		return -EACCES;
 	}
 
-	/*
-	 * Warn that /proc/pid/oom_adj is deprecated, see
-	 * Documentation/feature-removal-schedule.txt.
-	 */
-	printk_once(KERN_WARNING "%s (%d): /proc/%d/oom_adj is deprecated, "
-			"please use /proc/%d/oom_score_adj instead.\n",
-			current->comm, task_pid_nr(current),
-			task_pid_nr(task), task_pid_nr(task));
 	task->signal->oom_adj = oom_adjust;
-	/*
-	 * Scale /proc/pid/oom_score_adj appropriately ensuring that a maximum
-	 * value is always attainable.
-	 */
-	if (task->signal->oom_adj == OOM_ADJUST_MAX)
-		task->signal->oom_score_adj = OOM_SCORE_ADJ_MAX;
-	else
-		task->signal->oom_score_adj = (oom_adjust * OOM_SCORE_ADJ_MAX) /
-								-OOM_DISABLE;
+
 	unlock_task_sighand(task, &flags);
 	put_task_struct(task);
 
@@ -1079,82 +1062,6 @@ static const struct file_operations proc_oom_adjust_operations = {
 	.llseek		= generic_file_llseek,
 };
 
-static ssize_t oom_score_adj_read(struct file *file, char __user *buf,
-					size_t count, loff_t *ppos)
-{
-	struct task_struct *task = get_proc_task(file->f_path.dentry->d_inode);
-	char buffer[PROC_NUMBUF];
-	int oom_score_adj = OOM_SCORE_ADJ_MIN;
-	unsigned long flags;
-	size_t len;
-
-	if (!task)
-		return -ESRCH;
-	if (lock_task_sighand(task, &flags)) {
-		oom_score_adj = task->signal->oom_score_adj;
-		unlock_task_sighand(task, &flags);
-	}
-	put_task_struct(task);
-	len = snprintf(buffer, sizeof(buffer), "%d\n", oom_score_adj);
-	return simple_read_from_buffer(buf, count, ppos, buffer, len);
-}
-
-static ssize_t oom_score_adj_write(struct file *file, const char __user *buf,
-					size_t count, loff_t *ppos)
-{
-	struct task_struct *task;
-	char buffer[PROC_NUMBUF];
-	unsigned long flags;
-	long oom_score_adj;
-	int err;
-
-	memset(buffer, 0, sizeof(buffer));
-	if (count > sizeof(buffer) - 1)
-		count = sizeof(buffer) - 1;
-	if (copy_from_user(buffer, buf, count))
-		return -EFAULT;
-
-	err = strict_strtol(strstrip(buffer), 0, &oom_score_adj);
-	if (err)
-		return -EINVAL;
-	if (oom_score_adj < OOM_SCORE_ADJ_MIN ||
-			oom_score_adj > OOM_SCORE_ADJ_MAX)
-		return -EINVAL;
-
-	task = get_proc_task(file->f_path.dentry->d_inode);
-	if (!task)
-		return -ESRCH;
-	if (!lock_task_sighand(task, &flags)) {
-		put_task_struct(task);
-		return -ESRCH;
-	}
-	if (oom_score_adj < task->signal->oom_score_adj &&
-			!capable(CAP_SYS_RESOURCE)) {
-		unlock_task_sighand(task, &flags);
-		put_task_struct(task);
-		return -EACCES;
-	}
-
-	task->signal->oom_score_adj = oom_score_adj;
-	/*
-	 * Scale /proc/pid/oom_adj appropriately ensuring that OOM_DISABLE is
-	 * always attainable.
-	 */
-	if (task->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
-		task->signal->oom_adj = OOM_DISABLE;
-	else
-		task->signal->oom_adj = (oom_score_adj * OOM_ADJUST_MAX) /
-							OOM_SCORE_ADJ_MAX;
-	unlock_task_sighand(task, &flags);
-	put_task_struct(task);
-	return count;
-}
-
-static const struct file_operations proc_oom_score_adj_operations = {
-	.read		= oom_score_adj_read,
-	.write		= oom_score_adj_write,
-};
-
 #ifdef CONFIG_AUDITSYSCALL
 #define TMPBUFLEN 21
 static ssize_t proc_loginuid_read(struct file * file, char __user * buf,
@@ -2727,7 +2634,6 @@ static const struct pid_entry tgid_base_stuff[] = {
 #endif
 	INF("oom_score",  S_IRUGO, proc_oom_score),
 	REG("oom_adj",    S_IRUGO|S_IWUSR, proc_oom_adjust_operations),
-	REG("oom_score_adj", S_IRUGO|S_IWUSR, proc_oom_score_adj_operations),
 #ifdef CONFIG_AUDITSYSCALL
 	REG("loginuid",   S_IWUSR|S_IRUGO, proc_loginuid_operations),
 	REG("sessionid",  S_IRUGO, proc_sessionid_operations),
@@ -3062,7 +2968,6 @@ static const struct pid_entry tid_base_stuff[] = {
 #endif
 	INF("oom_score", S_IRUGO, proc_oom_score),
 	REG("oom_adj",   S_IRUGO|S_IWUSR, proc_oom_adjust_operations),
-	REG("oom_score_adj", S_IRUGO|S_IWUSR, proc_oom_score_adj_operations),
 #ifdef CONFIG_AUDITSYSCALL
 	REG("loginuid",  S_IWUSR|S_IRUGO, proc_loginuid_operations),
 	REG("sessionid",  S_IRUSR, proc_sessionid_operations),
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 73564ca..9f1afd3 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -125,8 +125,6 @@ void mem_cgroup_update_file_mapped(struct page *page, int val);
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask, int nid,
 						int zid);
-u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
-
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct mem_cgroup;
 
@@ -306,12 +304,6 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 	return 0;
 }
 
-static inline
-u64 mem_cgroup_get_limit(struct mem_cgroup *mem)
-{
-	return 0;
-}
-
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 5e3aa83..9c0d4f0 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -2,9 +2,6 @@
 #define __INCLUDE_LINUX_OOM_H
 
 /*
- * /proc/<pid>/oom_adj is deprecated, see
- * Documentation/feature-removal-schedule.txt.
- *
  * /proc/<pid>/oom_adj set to -17 protects from the oom-killer
  */
 #define OOM_DISABLE (-17)
@@ -12,13 +9,6 @@
 #define OOM_ADJUST_MIN (-16)
 #define OOM_ADJUST_MAX 15
 
-/*
- * /proc/<pid>/oom_score_adj set to OOM_SCORE_ADJ_MIN disables oom killing for
- * pid.
- */
-#define OOM_SCORE_ADJ_MIN	(-1000)
-#define OOM_SCORE_ADJ_MAX	1000
-
 #ifdef __KERNEL__
 
 #include <linux/sched.h>
@@ -40,8 +30,8 @@ enum oom_constraint {
 	CONSTRAINT_MEMCG,
 };
 
-extern unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
-			const nodemask_t *nodemask, unsigned long totalpages);
+extern unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *mem,
+				const nodemask_t *nodemask);
 extern int try_set_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 6276635..f4bcf73 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -627,7 +627,6 @@ struct signal_struct {
 #endif
 
 	int oom_adj;		/* OOM kill score adjustment (bit shift) */
-	int oom_score_adj;	/* OOM kill score adjustment */
 };
 
 /* Context switch must be unlocked if interrupts are to be enabled */
diff --git a/kernel/fork.c b/kernel/fork.c
index 98b4508..a82a65c 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -899,7 +899,6 @@ static int copy_signal(unsigned long clone_flags, struct task_struct *tsk)
 	tty_audit_fork(sig);
 
 	sig->oom_adj = current->signal->oom_adj;
-	sig->oom_score_adj = current->signal->oom_score_adj;
 
 	return 0;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6cf4f1d..2b648ce 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1172,24 +1172,6 @@ static int mem_cgroup_count_children(struct mem_cgroup *mem)
 }
 
 /*
- * Return the memory (and swap, if configured) limit for a memcg.
- */
-u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
-{
-	u64 limit;
-	u64 memsw;
-
-	limit = res_counter_read_u64(&memcg->res, RES_LIMIT) +
-			total_swap_pages;
-	memsw = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
-	/*
-	 * If memsw is finite and limits the amount of swap space available
-	 * to this memcg, return that limit.
-	 */
-	return min(limit, memsw);
-}
-
-/*
  * Visit the first child (need not be the first child as per the ordering
  * of the cgroup list, since we track last_scanned_child) of @mem and use
  * that to reclaim free pages from.
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5014e50..c8beaa2 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -32,6 +32,7 @@
 #include <linux/mempolicy.h>
 #include <linux/security.h>
 
+
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
@@ -143,55 +144,38 @@ static bool oom_unkillable_task(struct task_struct *p, struct mem_cgroup *mem,
 /**
  * oom_badness - heuristic function to determine which candidate task to kill
  * @p: task struct of which task we should calculate
- * @totalpages: total present RAM allowed for page allocation
  *
  * The heuristic for determining which task to kill is made to be as simple and
  * predictable as possible.  The goal is to return the highest value for the
  * task consuming the most memory to avoid subsequent oom failures.
  */
-unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
-		      const nodemask_t *nodemask, unsigned long totalpages)
+unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *mem,
+			  const nodemask_t *nodemask)
 {
+	int oom_adj = p->signal->oom_adj;
 	int points;
 
 	if (oom_unkillable_task(p, mem, nodemask))
 		return 0;
-
-	p = find_lock_task_mm(p);
-	if (!p)
-		return 0;
-
-	/*
-	 * Shortcut check for OOM_SCORE_ADJ_MIN so the entire heuristic doesn't
-	 * need to be executed for something that cannot be killed.
-	 */
-	if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
-		task_unlock(p);
+	if (oom_adj == OOM_DISABLE)
 		return 0;
-	}
 
 	/*
 	 * When the PF_OOM_ORIGIN bit is set, it indicates the task should have
 	 * priority for oom killing.
 	 */
-	if (p->flags & PF_OOM_ORIGIN) {
-		task_unlock(p);
-		return 1000;
-	}
+	if (p->flags & PF_OOM_ORIGIN)
+		return ULONG_MAX;
 
-	/*
-	 * The memory controller may have a limit of 0 bytes, so avoid a divide
-	 * by zero, if necessary.
-	 */
-	if (!totalpages)
-		totalpages = 1;
+	p = find_lock_task_mm(p);
+	if (!p)
+		return 0;
 
 	/*
 	 * The baseline for the badness score is the proportion of RAM that each
 	 * task's rss and swap space use.
 	 */
-	points = (get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS)) * 1000 /
-			totalpages;
+	points = get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS);
 	task_unlock(p);
 
 	/*
@@ -202,15 +186,18 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
 		points -= 30;
 
 	/*
-	 * /proc/pid/oom_score_adj ranges from -1000 to +1000 such that it may
-	 * either completely disable oom killing or always prefer a certain
-	 * task.
+	 * Adjust the score by oom_adj.
 	 */
-	points += p->signal->oom_score_adj;
+	if (oom_adj) {
+		if (oom_adj > 0) {
+			if (!points)
+				points = 1;
+			points <<= oom_adj;
+		} else
+			points >>= -(oom_adj);
+	}
 
-	if (points < 0)
-		return 0;
-	return (points < 1000) ? points : 1000;
+	return points;
 }
 
 /*
@@ -218,17 +205,11 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
  */
 #ifdef CONFIG_NUMA
 static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
-				gfp_t gfp_mask, nodemask_t *nodemask,
-				unsigned long *totalpages)
+					gfp_t gfp_mask, nodemask_t *nodemask)
 {
 	struct zone *zone;
 	struct zoneref *z;
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
-	bool cpuset_limited = false;
-	int nid;
-
-	/* Default to all available memory */
-	*totalpages = totalram_pages + total_swap_pages;
 
 	if (!zonelist)
 		return CONSTRAINT_NONE;
@@ -245,33 +226,21 @@ static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
 	 * the page allocator means a mempolicy is in effect.  Cpuset policy
 	 * is enforced in get_page_from_freelist().
 	 */
-	if (nodemask && !nodes_subset(node_states[N_HIGH_MEMORY], *nodemask)) {
-		*totalpages = total_swap_pages;
-		for_each_node_mask(nid, *nodemask)
-			*totalpages += node_spanned_pages(nid);
+	if (nodemask && !nodes_subset(node_states[N_HIGH_MEMORY], *nodemask))
 		return CONSTRAINT_MEMORY_POLICY;
-	}
 
 	/* Check this allocation failure is caused by cpuset's wall function */
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 			high_zoneidx, nodemask)
 		if (!cpuset_zone_allowed_softwall(zone, gfp_mask))
-			cpuset_limited = true;
+			return CONSTRAINT_CPUSET;
 
-	if (cpuset_limited) {
-		*totalpages = total_swap_pages;
-		for_each_node_mask(nid, cpuset_current_mems_allowed)
-			*totalpages += node_spanned_pages(nid);
-		return CONSTRAINT_CPUSET;
-	}
 	return CONSTRAINT_NONE;
 }
 #else
 static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
-				gfp_t gfp_mask, nodemask_t *nodemask,
-				unsigned long *totalpages)
+				gfp_t gfp_mask, nodemask_t *nodemask)
 {
-	*totalpages = totalram_pages + total_swap_pages;
 	return CONSTRAINT_NONE;
 }
 #endif
@@ -282,16 +251,16 @@ static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
  *
  * (not docbooked, we don't want this one cluttering up the manual)
  */
-static struct task_struct *select_bad_process(unsigned int *ppoints,
-		unsigned long totalpages, struct mem_cgroup *mem,
-		const nodemask_t *nodemask)
+static struct task_struct *select_bad_process(unsigned long *ppoints,
+		struct mem_cgroup *mem, const nodemask_t *nodemask)
+
 {
 	struct task_struct *p;
 	struct task_struct *chosen = NULL;
 	*ppoints = 0;
 
 	for_each_process(p) {
-		unsigned int points;
+		unsigned long points;
 
 		if (oom_unkillable_task(p, mem, nodemask))
 			continue;
@@ -323,10 +292,10 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
 				return ERR_PTR(-1UL);
 
 			chosen = p;
-			*ppoints = 1000;
+			*ppoints = ULONG_MAX;
 		}
 
-		points = oom_badness(p, mem, nodemask, totalpages);
+		points = oom_badness(p, mem, nodemask);
 		if (points > *ppoints) {
 			chosen = p;
 			*ppoints = points;
@@ -342,7 +311,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
  *
  * Dumps the current memory state of all system tasks, excluding kernel threads.
  * State information includes task's pid, uid, tgid, vm size, rss, cpu, oom_adj
- * value, oom_score_adj value, and name.
+ * value, and name.
  *
  * If the actual is non-NULL, only tasks that are a member of the mem_cgroup are
  * shown.
@@ -354,7 +323,8 @@ static void dump_tasks(const struct mem_cgroup *mem)
 	struct task_struct *p;
 	struct task_struct *task;
 
-	pr_info("[ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name\n");
+	printk(KERN_INFO "[ pid ]   uid  tgid total_vm      rss cpu oom_adj "
+	       "name\n");
 	for_each_process(p) {
 		if (p->flags & PF_KTHREAD)
 			continue;
@@ -371,11 +341,10 @@ static void dump_tasks(const struct mem_cgroup *mem)
 			continue;
 		}
 
-		pr_info("[%5d] %5d %5d %8lu %8lu %3u     %3d         %5d %s\n",
-			task->pid, __task_cred(task)->uid, task->tgid,
-			task->mm->total_vm, get_mm_rss(task->mm),
-			task_cpu(task), task->signal->oom_adj,
-			task->signal->oom_score_adj, task->comm);
+		printk(KERN_INFO "[%5d] %5d %5d %8lu %8lu %3u     %3d %s\n",
+		       task->pid, __task_cred(task)->uid, task->tgid,
+		       task->mm->total_vm, get_mm_rss(task->mm),
+		       task_cpu(task), task->signal->oom_adj, task->comm);
 		task_unlock(task);
 	}
 }
@@ -385,9 +354,8 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 {
 	task_lock(current);
 	pr_warning("%s invoked oom-killer: gfp_mask=0x%x, order=%d, "
-		"oom_adj=%d, oom_score_adj=%d\n",
-		current->comm, gfp_mask, order, current->signal->oom_adj,
-		current->signal->oom_score_adj);
+		   "oom_adj=%d\n",
+		   current->comm, gfp_mask, order, current->signal->oom_adj);
 	cpuset_print_task_mems_allowed(current);
 	task_unlock(current);
 	dump_stack();
@@ -427,14 +395,13 @@ static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
 #undef K
 
 static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
-			    unsigned int points, unsigned long totalpages,
-			    struct mem_cgroup *mem, nodemask_t *nodemask,
-			    const char *message)
+			    unsigned long points, struct mem_cgroup *mem,
+			    nodemask_t *nodemask, const char *message)
 {
 	struct task_struct *victim = p;
 	struct task_struct *child;
 	struct task_struct *t = p;
-	unsigned int victim_points = 0;
+	unsigned long victim_points = 0;
 
 	if (printk_ratelimit())
 		dump_header(p, gfp_mask, order, mem);
@@ -450,7 +417,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	}
 
 	task_lock(p);
-	pr_err("%s: Kill process %d (%s) score %d or sacrifice child\n",
+	pr_err("%s: Kill process %d (%s) score %lu or sacrifice child\n",
 		message, task_pid_nr(p), p->comm, points);
 	task_unlock(p);
 
@@ -462,13 +429,12 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	 */
 	do {
 		list_for_each_entry(child, &t->children, sibling) {
-			unsigned int child_points;
+			unsigned long child_points;
 
 			/*
 			 * oom_badness() returns 0 if the thread is unkillable
 			 */
-			child_points = oom_badness(child, mem, nodemask,
-								totalpages);
+			child_points = oom_badness(child, mem, nodemask);
 			if (child_points > victim_points) {
 				victim = child;
 				victim_points = child_points;
@@ -506,19 +472,17 @@ static void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
 {
-	unsigned long limit;
-	unsigned int points = 0;
+	unsigned long points = 0;
 	struct task_struct *p;
 
 	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, 0);
-	limit = mem_cgroup_get_limit(mem) >> PAGE_SHIFT;
 	read_lock(&tasklist_lock);
 retry:
-	p = select_bad_process(&points, limit, mem, NULL);
+	p = select_bad_process(&points, mem, NULL);
 	if (!p || PTR_ERR(p) == -1UL)
 		goto out;
 
-	if (oom_kill_process(p, gfp_mask, 0, points, limit, mem, NULL,
+	if (oom_kill_process(p, gfp_mask, 0, points, mem, NULL,
 				"Memory cgroup out of memory"))
 		goto retry;
 out:
@@ -643,9 +607,8 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		int order, nodemask_t *nodemask)
 {
 	struct task_struct *p;
-	unsigned long totalpages;
 	unsigned long freed = 0;
-	unsigned int points;
+	unsigned long points;
 	enum oom_constraint constraint = CONSTRAINT_NONE;
 
 	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
@@ -668,8 +631,9 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA) that may require different handling.
 	 */
-	constraint = constrained_alloc(zonelist, gfp_mask, nodemask,
-						&totalpages);
+	constraint = constrained_alloc(zonelist, gfp_mask, nodemask);
+	if (constraint != CONSTRAINT_MEMORY_POLICY)
+		nodemask = NULL;
 	check_panic_on_oom(constraint, gfp_mask, order);
 
 	read_lock(&tasklist_lock);
@@ -681,16 +645,14 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		 * non-zero, current could not be killed so we must fallback to
 		 * the tasklist scan.
 		 */
-		if (!oom_kill_process(current, gfp_mask, order, 0, totalpages,
-				NULL, nodemask,
+		if (!oom_kill_process(current, gfp_mask, order, 0, NULL,
+				      nodemask,
 				"Out of memory (oom_kill_allocating_task)"))
 			return;
 	}
 
 retry:
-	p = select_bad_process(&points, totalpages, NULL,
-			constraint == CONSTRAINT_MEMORY_POLICY ? nodemask :
-								 NULL);
+	p = select_bad_process(&points, NULL, nodemask);
 	if (PTR_ERR(p) == -1UL)
 		return;
 
@@ -701,8 +663,8 @@ retry:
 		panic("Out of memory and no killable processes...\n");
 	}
 
-	if (oom_kill_process(p, gfp_mask, order, points, totalpages, NULL,
-				nodemask, "Out of memory"))
+	if (oom_kill_process(p, gfp_mask, order, points, NULL, nodemask,
+			     "Out of memory"))
 		goto retry;
 	read_unlock(&tasklist_lock);
 
-- 
1.6.5.2




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
