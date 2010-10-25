Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A6A448D000B
	for <linux-mm@kvack.org>; Sun, 24 Oct 2010 23:26:32 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9P3QTdm029684
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 25 Oct 2010 12:26:29 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 857DA45DE52
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 12:26:29 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6055A45DE4E
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 12:26:29 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 40B081DB8040
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 12:26:29 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D2EF31DB8038
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 12:26:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [resend][PATCH 1/4] oom: remove totalpage normalization from oom_badness()
Message-Id: <20101025122538.9167.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 25 Oct 2010 12:26:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Current oom_score_adj is completely broken because It is strongly bound
google usecase and ignore other all.

1) Priority inversion
   As kamezawa-san pointed out, This break cgroup and lxr environment.
   He said,
	> Assume 2 proceses A, B which has oom_score_adj of 300 and 0
	> And A uses 200M, B uses 1G of memory under 4G system
	>
	> Under the system.
	> 	A's socre = (200M *1000)/4G + 300 = 350
	> 	B's score = (1G * 1000)/4G = 250.
	>
	> In the cpuset, it has 2G of memory.
	> 	A's score = (200M * 1000)/2G + 300 = 400
	> 	B's socre = (1G * 1000)/2G = 500
	>
	> This priority-inversion don't happen in current system.

2) Ratio base point don't works large machine
   oom_score_adj normalize oom-score to 0-1000 range.
   but if the machine has 1TB memory, 1 point (i.e. 0.1%) mean
   1GB. this is no suitable for tuning parameter.
   As I said, proposional value oriented tuning parameter has
   scalability risk.

3) No reason to implement ABI breakage.
   old tuning parameter mean)
	oom-score = oom-base-score x 2^oom_adj
   new tuning parameter mean)
	oom-score = oom-base-score + oom_score_adj / (totalram + totalswap)
   but "oom_score_adj / (totalram + totalswap)" can be calculated in
   userland too. beucase both totalram and totalswap has been exporsed by
   /proc. So no reason to introduce funny new equation.

4) totalram based normalization assume flat memory model.
   example, the machine is assymmetric numa. fat node memory and thin
   node memory might have another wight value.
   In other word, totalram based priority is a one of policy. Fixed and
   workload depended policy shouldn't be embedded in kernel. probably.

Then, this patch remove *UGLY* total_pages suck completely. Googler
can calculate it at userland!

Cc: stable@kernel.org
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 fs/proc/base.c        |   35 +++----------
 include/linux/oom.h   |   16 +-----
 include/linux/sched.h |    2 +-
 mm/oom_kill.c         |  142 ++++++++++++++++++++-----------------------------
 4 files changed, 69 insertions(+), 126 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index dc5d5f5..86c402e 100644
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
@@ -1056,15 +1055,6 @@ static ssize_t oom_adjust_write(struct file *file, const char __user *buf,
 			current->comm, task_pid_nr(current),
 			task_pid_nr(task), task_pid_nr(task));
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
 	unlock_task_sighand(task, &flags);
 	put_task_struct(task);
 
@@ -1077,12 +1067,14 @@ static const struct file_operations proc_oom_adjust_operations = {
 	.llseek		= generic_file_llseek,
 };
 
+#define TMPBUFLEN 21
+
 static ssize_t oom_score_adj_read(struct file *file, char __user *buf,
 					size_t count, loff_t *ppos)
 {
 	struct task_struct *task = get_proc_task(file->f_path.dentry->d_inode);
-	char buffer[PROC_NUMBUF];
-	int oom_score_adj = OOM_SCORE_ADJ_MIN;
+	char buffer[TMPBUFLEN];
+	long oom_score_adj = 0;
 	unsigned long flags;
 	size_t len;
 
@@ -1093,7 +1085,7 @@ static ssize_t oom_score_adj_read(struct file *file, char __user *buf,
 		unlock_task_sighand(task, &flags);
 	}
 	put_task_struct(task);
-	len = snprintf(buffer, sizeof(buffer), "%d\n", oom_score_adj);
+	len = snprintf(buffer, sizeof(buffer), "%ld\n", oom_score_adj);
 	return simple_read_from_buffer(buf, count, ppos, buffer, len);
 }
 
@@ -1101,7 +1093,7 @@ static ssize_t oom_score_adj_write(struct file *file, const char __user *buf,
 					size_t count, loff_t *ppos)
 {
 	struct task_struct *task;
-	char buffer[PROC_NUMBUF];
+	char buffer[TMPBUFLEN];
 	unsigned long flags;
 	long oom_score_adj;
 	int err;
@@ -1115,9 +1107,6 @@ static ssize_t oom_score_adj_write(struct file *file, const char __user *buf,
 	err = strict_strtol(strstrip(buffer), 0, &oom_score_adj);
 	if (err)
 		return -EINVAL;
-	if (oom_score_adj < OOM_SCORE_ADJ_MIN ||
-			oom_score_adj > OOM_SCORE_ADJ_MAX)
-		return -EINVAL;
 
 	task = get_proc_task(file->f_path.dentry->d_inode);
 	if (!task)
@@ -1134,15 +1123,6 @@ static ssize_t oom_score_adj_write(struct file *file, const char __user *buf,
 	}
 
 	task->signal->oom_score_adj = oom_score_adj;
-	/*
-	 * Scale /proc/pid/oom_adj appropriately ensuring that OOM_DISABLE is
-	 * always attainable.
-	 */
-	if (task->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
-		task->signal->oom_adj = OOM_DISABLE;
-	else
-		task->signal->oom_adj = (oom_score_adj * OOM_ADJUST_MAX) /
-							OOM_SCORE_ADJ_MAX;
 	unlock_task_sighand(task, &flags);
 	put_task_struct(task);
 	return count;
@@ -1155,7 +1135,6 @@ static const struct file_operations proc_oom_score_adj_operations = {
 };
 
 #ifdef CONFIG_AUDITSYSCALL
-#define TMPBUFLEN 21
 static ssize_t proc_loginuid_read(struct file * file, char __user * buf,
 				  size_t count, loff_t *ppos)
 {
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 5e3aa83..21006dc 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -12,13 +12,6 @@
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
@@ -40,8 +33,9 @@ enum oom_constraint {
 	CONSTRAINT_MEMCG,
 };
 
-extern unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
-			const nodemask_t *nodemask, unsigned long totalpages);
+/* The badness from the OOM killer */
+extern unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *mem,
+				 const nodemask_t *nodemask);
 extern int try_set_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 
@@ -62,10 +56,6 @@ static inline void oom_killer_enable(void)
 	oom_killer_disabled = false;
 }
 
-/* The badness from the OOM killer */
-extern unsigned long badness(struct task_struct *p, struct mem_cgroup *mem,
-		      const nodemask_t *nodemask, unsigned long uptime);
-
 extern struct task_struct *find_lock_task_mm(struct task_struct *p);
 
 /* sysctls */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 56154bb..74ed859 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -625,7 +625,7 @@ struct signal_struct {
 #endif
 
 	int oom_adj;		/* OOM kill score adjustment (bit shift) */
-	int oom_score_adj;	/* OOM kill score adjustment */
+	long oom_score_adj;	/* OOM kill score adjustment */
 };
 
 /* Context switch must be unlocked if interrupts are to be enabled */
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4029583..d58925e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -143,55 +143,41 @@ static bool oom_unkillable_task(struct task_struct *p,
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
-	int points;
+	unsigned long points;
+	unsigned long points_orig;
+	int oom_adj = p->signal->oom_adj;
+	long oom_score_adj = p->signal->oom_score_adj;
 
-	if (oom_unkillable_task(p, mem, nodemask))
-		return 0;
 
-	p = find_lock_task_mm(p);
-	if (!p)
+	if (oom_unkillable_task(p, mem, nodemask))
 		return 0;
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
+	points = (get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS));
 	task_unlock(p);
 
 	/*
@@ -199,14 +185,26 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
 	 * implementation used by LSMs.
 	 */
 	if (has_capability_noaudit(p, CAP_SYS_ADMIN))
-		points -= 30;
+		points -= points / 32;
 
 	/*
-	 * /proc/pid/oom_score_adj ranges from -1000 to +1000 such that it may
-	 * either completely disable oom killing or always prefer a certain
-	 * task.
+	 * Adjust the score by oom_adj and oom_score_adj.
 	 */
-	points += p->signal->oom_score_adj;
+	points_orig = points;
+	points += oom_score_adj;
+	if ((oom_score_adj > 0) && (points < points_orig))
+		points = ULONG_MAX;	/* may be overflow */
+	if ((oom_score_adj < 0) && (points > points_orig))
+		points = 0;		/* may be underflow */
+
+	if (oom_adj) {
+		if (oom_adj > 0) {
+			if (!points)
+				points = 1;
+			points <<= oom_adj;
+		} else
+			points >>= -(oom_adj);
+	}
 
 	/*
 	 * Never return 0 for an eligible task that may be killed since it's
@@ -215,7 +213,7 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
 	 */
 	if (points <= 0)
 		return 1;
-	return (points < 1000) ? points : 1000;
+	return points;
 }
 
 /*
@@ -223,17 +221,11 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
  */
 #ifdef CONFIG_NUMA
 static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
-				gfp_t gfp_mask, nodemask_t *nodemask,
-				unsigned long *totalpages)
+				gfp_t gfp_mask, nodemask_t *nodemask)
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
@@ -250,33 +242,21 @@ static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
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
@@ -287,16 +267,16 @@ static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
  *
  * (not docbooked, we don't want this one cluttering up the manual)
  */
-static struct task_struct *select_bad_process(unsigned int *ppoints,
-		unsigned long totalpages, struct mem_cgroup *mem,
-		const nodemask_t *nodemask)
+static struct task_struct *select_bad_process(unsigned long *ppoints,
+					      struct mem_cgroup *mem,
+					      const nodemask_t *nodemask)
 {
 	struct task_struct *p;
 	struct task_struct *chosen = NULL;
 	*ppoints = 0;
 
 	for_each_process(p) {
-		unsigned int points;
+		unsigned long points;
 
 		if (oom_unkillable_task(p, mem, nodemask))
 			continue;
@@ -328,10 +308,10 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
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
@@ -374,7 +354,7 @@ static void dump_tasks(const struct mem_cgroup *mem, const nodemask_t *nodemask)
 			continue;
 		}
 
-		pr_info("[%5d] %5d %5d %8lu %8lu %3u     %3d         %5d %s\n",
+		pr_info("[%5d] %5d %5d %8lu %8lu %3u     %3d         %5ld %s\n",
 			task->pid, task_uid(task), task->tgid,
 			task->mm->total_vm, get_mm_rss(task->mm),
 			task_cpu(task), task->signal->oom_adj,
@@ -388,7 +368,7 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 {
 	task_lock(current);
 	pr_warning("%s invoked oom-killer: gfp_mask=0x%x, order=%d, "
-		"oom_adj=%d, oom_score_adj=%d\n",
+		"oom_adj=%d, oom_score_adj=%ld\n",
 		current->comm, gfp_mask, order, current->signal->oom_adj,
 		current->signal->oom_score_adj);
 	cpuset_print_task_mems_allowed(current);
@@ -429,14 +409,13 @@ static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
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
 		dump_header(p, gfp_mask, order, mem, nodemask);
@@ -452,7 +431,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	}
 
 	task_lock(p);
-	pr_err("%s: Kill process %d (%s) score %d or sacrifice child\n",
+	pr_err("%s: Kill process %d (%s) score %lu or sacrifice child\n",
 		message, task_pid_nr(p), p->comm, points);
 	task_unlock(p);
 
@@ -464,13 +443,12 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
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
@@ -508,19 +486,17 @@ static void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
 {
-	unsigned long limit;
-	unsigned int points = 0;
+	unsigned long points = 0;
 	struct task_struct *p;
 
 	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, 0, NULL);
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
@@ -646,9 +622,8 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 {
 	const nodemask_t *mpol_mask;
 	struct task_struct *p;
-	unsigned long totalpages;
 	unsigned long freed = 0;
-	unsigned int points;
+	unsigned long points;
 	enum oom_constraint constraint = CONSTRAINT_NONE;
 	int killed = 0;
 
@@ -672,8 +647,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA) that may require different handling.
 	 */
-	constraint = constrained_alloc(zonelist, gfp_mask, nodemask,
-						&totalpages);
+	constraint = constrained_alloc(zonelist, gfp_mask, nodemask);
 	mpol_mask = (constraint == CONSTRAINT_MEMORY_POLICY) ? nodemask : NULL;
 	check_panic_on_oom(constraint, gfp_mask, order, mpol_mask);
 
@@ -686,14 +660,14 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		 * non-zero, current could not be killed so we must fallback to
 		 * the tasklist scan.
 		 */
-		if (!oom_kill_process(current, gfp_mask, order, 0, totalpages,
+		if (!oom_kill_process(current, gfp_mask, order, 0,
 				NULL, nodemask,
 				"Out of memory (oom_kill_allocating_task)"))
 			goto out;
 	}
 
 retry:
-	p = select_bad_process(&points, totalpages, NULL, mpol_mask);
+	p = select_bad_process(&points, NULL, mpol_mask);
 	if (PTR_ERR(p) == -1UL)
 		goto out;
 
@@ -704,7 +678,7 @@ retry:
 		panic("Out of memory and no killable processes...\n");
 	}
 
-	if (oom_kill_process(p, gfp_mask, order, points, totalpages, NULL,
+	if (oom_kill_process(p, gfp_mask, order, points, NULL,
 				nodemask, "Out of memory"))
 		goto retry;
 	killed = 1;
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
