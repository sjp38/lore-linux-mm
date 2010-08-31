Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9FD9F6B01F0
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 05:29:54 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7V9Tpg3004842
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 31 Aug 2010 18:29:52 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 985DD45DE4F
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 18:29:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A11B45DE4E
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 18:29:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A0181DB8038
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 18:29:51 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 043201DB8037
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 18:29:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [BUGFIX for 2.6.36][RESEND][PATCH 1/2] oom: remove totalpage normalization from oom_badness()
Message-Id: <20100831181911.87E7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 31 Aug 2010 18:29:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

ok, this one got no objection except original patch author.
then, I'll push it to mainline. I'm glad that I who stabilization
developer have finished this work.

If you think this patch is slightly large, please run,
 % git diff a63d83f42^ mm/oom_kill.c
you'll understand this is minimal revert of unnecessary change.

Thanks.

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=46rom 938ce3a7aa79ae4a6cbc275259d586086c41eb87 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 27 Aug 2010 15:24:09 +0900
Subject: [PATCH 1/2] oom: remove totalpage normalization from oom_badness()

Current oom_score_adj is completely broken because It is strongly bound
google usecase and ignore other all.

1) Priority inversion
   As kamezawa-san pointed out, This break cgroup and lxr environment.
   He said,
	> Assume 2 proceses A, B which has oom_score_adj of 300 and 0
	> And A uses 200M, B uses 1G of memory under 4G system
	>
	> Under the system.
	> 	A's socre =3D (200M *1000)/4G + 300 =3D 350
	> 	B's score =3D (1G * 1000)/4G =3D 250.
	>
	> In the cpuset, it has 2G of memory.
	> 	A's score =3D (200M * 1000)/2G + 300 =3D 400
	> 	B's socre =3D (1G * 1000)/2G =3D 500
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
	oom-score =3D oom-base-score x 2^oom_adj
   new tuning parameter mean)
	oom-score =3D oom-base-score + oom_score_adj / (totalram + totalswap)
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

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 fs/proc/base.c        |   33 ++---------
 include/linux/oom.h   |   16 +-----
 include/linux/sched.h |    2 +-
 mm/oom_kill.c         |  144 ++++++++++++++++++++-------------------------=
----
 4 files changed, 68 insertions(+), 127 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index a1c43e7..90ba487 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -434,8 +434,7 @@ static int proc_oom_score(struct task_struct *task, cha=
r *buffer)
=20
 	read_lock(&tasklist_lock);
 	if (pid_alive(task))
-		points =3D oom_badness(task, NULL, NULL,
-					totalram_pages + total_swap_pages);
+		points =3D oom_badness(task, NULL, NULL);
 	read_unlock(&tasklist_lock);
 	return sprintf(buffer, "%lu\n", points);
 }
@@ -1056,15 +1055,7 @@ static ssize_t oom_adjust_write(struct file *file, c=
onst char __user *buf,
 			current->comm, task_pid_nr(current),
 			task_pid_nr(task), task_pid_nr(task));
 	task->signal->oom_adj =3D oom_adjust;
-	/*
-	 * Scale /proc/pid/oom_score_adj appropriately ensuring that a maximum
-	 * value is always attainable.
-	 */
-	if (task->signal->oom_adj =3D=3D OOM_ADJUST_MAX)
-		task->signal->oom_score_adj =3D OOM_SCORE_ADJ_MAX;
-	else
-		task->signal->oom_score_adj =3D (oom_adjust * OOM_SCORE_ADJ_MAX) /
-								-OOM_DISABLE;
+
 	unlock_task_sighand(task, &flags);
 	put_task_struct(task);
=20
@@ -1081,8 +1072,8 @@ static ssize_t oom_score_adj_read(struct file *file, =
char __user *buf,
 					size_t count, loff_t *ppos)
 {
 	struct task_struct *task =3D get_proc_task(file->f_path.dentry->d_inode);
-	char buffer[PROC_NUMBUF];
-	int oom_score_adj =3D OOM_SCORE_ADJ_MIN;
+	char buffer[21];
+	long oom_score_adj =3D 0;
 	unsigned long flags;
 	size_t len;
=20
@@ -1093,7 +1084,7 @@ static ssize_t oom_score_adj_read(struct file *file, =
char __user *buf,
 		unlock_task_sighand(task, &flags);
 	}
 	put_task_struct(task);
-	len =3D snprintf(buffer, sizeof(buffer), "%d\n", oom_score_adj);
+	len =3D snprintf(buffer, sizeof(buffer), "%ld\n", oom_score_adj);
 	return simple_read_from_buffer(buf, count, ppos, buffer, len);
 }
=20
@@ -1101,7 +1092,7 @@ static ssize_t oom_score_adj_write(struct file *file,=
 const char __user *buf,
 					size_t count, loff_t *ppos)
 {
 	struct task_struct *task;
-	char buffer[PROC_NUMBUF];
+	char buffer[21];
 	unsigned long flags;
 	long oom_score_adj;
 	int err;
@@ -1115,9 +1106,6 @@ static ssize_t oom_score_adj_write(struct file *file,=
 const char __user *buf,
 	err =3D strict_strtol(strstrip(buffer), 0, &oom_score_adj);
 	if (err)
 		return -EINVAL;
-	if (oom_score_adj < OOM_SCORE_ADJ_MIN ||
-			oom_score_adj > OOM_SCORE_ADJ_MAX)
-		return -EINVAL;
=20
 	task =3D get_proc_task(file->f_path.dentry->d_inode);
 	if (!task)
@@ -1134,15 +1122,6 @@ static ssize_t oom_score_adj_write(struct file *file=
, const char __user *buf,
 	}
=20
 	task->signal->oom_score_adj =3D oom_score_adj;
-	/*
-	 * Scale /proc/pid/oom_adj appropriately ensuring that OOM_DISABLE is
-	 * always attainable.
-	 */
-	if (task->signal->oom_score_adj =3D=3D OOM_SCORE_ADJ_MIN)
-		task->signal->oom_adj =3D OOM_DISABLE;
-	else
-		task->signal->oom_adj =3D (oom_score_adj * OOM_ADJUST_MAX) /
-							OOM_SCORE_ADJ_MAX;
 	unlock_task_sighand(task, &flags);
 	put_task_struct(task);
 	return count;
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 5e3aa83..21006dc 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -12,13 +12,6 @@
 #define OOM_ADJUST_MIN (-16)
 #define OOM_ADJUST_MAX 15
=20
-/*
- * /proc/<pid>/oom_score_adj set to OOM_SCORE_ADJ_MIN disables oom killing=
 for
- * pid.
- */
-#define OOM_SCORE_ADJ_MIN	(-1000)
-#define OOM_SCORE_ADJ_MAX	1000
-
 #ifdef __KERNEL__
=20
 #include <linux/sched.h>
@@ -40,8 +33,9 @@ enum oom_constraint {
 	CONSTRAINT_MEMCG,
 };
=20
-extern unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *=
mem,
-			const nodemask_t *nodemask, unsigned long totalpages);
+/* The badness from the OOM killer */
+extern unsigned long oom_badness(struct task_struct *p, struct mem_cgroup =
*mem,
+				 const nodemask_t *nodemask);
 extern int try_set_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags=
);
 extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags)=
;
=20
@@ -62,10 +56,6 @@ static inline void oom_killer_enable(void)
 	oom_killer_disabled =3D false;
 }
=20
-/* The badness from the OOM killer */
-extern unsigned long badness(struct task_struct *p, struct mem_cgroup *mem=
,
-		      const nodemask_t *nodemask, unsigned long uptime);
-
 extern struct task_struct *find_lock_task_mm(struct task_struct *p);
=20
 /* sysctls */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 1e2a6db..5e61d60 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -622,7 +622,7 @@ struct signal_struct {
 #endif
=20
 	int oom_adj;		/* OOM kill score adjustment (bit shift) */
-	int oom_score_adj;	/* OOM kill score adjustment */
+	long oom_score_adj;	/* OOM kill score adjustment */
 };
=20
 /* Context switch must be unlocked if interrupts are to be enabled */
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index fc81cb2..c1beda0 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -143,55 +143,41 @@ static bool oom_unkillable_task(struct task_struct *p=
, struct mem_cgroup *mem,
 /**
  * oom_badness - heuristic function to determine which candidate task to k=
ill
  * @p: task struct of which task we should calculate
- * @totalpages: total present RAM allowed for page allocation
  *
  * The heuristic for determining which task to kill is made to be as simpl=
e and
  * predictable as possible.  The goal is to return the highest value for t=
he
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
+	int oom_adj =3D p->signal->oom_adj;
+	long oom_score_adj =3D p->signal->oom_score_adj;
=20
-	if (oom_unkillable_task(p, mem, nodemask))
-		return 0;
=20
-	p =3D find_lock_task_mm(p);
-	if (!p)
+	if (oom_unkillable_task(p, mem, nodemask))
 		return 0;
-
-	/*
-	 * Shortcut check for OOM_SCORE_ADJ_MIN so the entire heuristic doesn't
-	 * need to be executed for something that cannot be killed.
-	 */
-	if (p->signal->oom_score_adj =3D=3D OOM_SCORE_ADJ_MIN) {
-		task_unlock(p);
+	if (oom_adj =3D=3D OOM_DISABLE)
 		return 0;
-	}
=20
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
=20
-	/*
-	 * The memory controller may have a limit of 0 bytes, so avoid a divide
-	 * by zero, if necessary.
-	 */
-	if (!totalpages)
-		totalpages =3D 1;
+	p =3D find_lock_task_mm(p);
+	if (!p)
+		return 0;
=20
 	/*
 	 * The baseline for the badness score is the proportion of RAM that each
 	 * task's rss and swap space use.
 	 */
-	points =3D (get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS)) * 100=
0 /
-			totalpages;
+	points =3D (get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS));
 	task_unlock(p);
=20
 	/*
@@ -199,18 +185,28 @@ unsigned int oom_badness(struct task_struct *p, struc=
t mem_cgroup *mem,
 	 * implementation used by LSMs.
 	 */
 	if (has_capability_noaudit(p, CAP_SYS_ADMIN))
-		points -=3D 30;
+		points -=3D points / 32;
=20
 	/*
-	 * /proc/pid/oom_score_adj ranges from -1000 to +1000 such that it may
-	 * either completely disable oom killing or always prefer a certain
-	 * task.
+	 * Adjust the score by oom_adj and oom_score_adj.
 	 */
-	points +=3D p->signal->oom_score_adj;
+	points_orig =3D points;
+	points +=3D oom_score_adj;
+	if ((oom_score_adj > 0) && (points < points_orig))
+		points =3D ULONG_MAX;	/* may be overflow */
+	if ((oom_score_adj < 0) && (points > points_orig))
+		points =3D 0;		/* may be underflow */
+
+	if (oom_adj) {
+		if (oom_adj > 0) {
+			if (!points)
+				points =3D 1;
+			points <<=3D oom_adj;
+		} else
+			points >>=3D -(oom_adj);
+	}
=20
-	if (points < 0)
-		return 0;
-	return (points < 1000) ? points : 1000;
+	return points;
 }
=20
 /*
@@ -218,17 +214,11 @@ unsigned int oom_badness(struct task_struct *p, struc=
t mem_cgroup *mem,
  */
 #ifdef CONFIG_NUMA
 static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
-				gfp_t gfp_mask, nodemask_t *nodemask,
-				unsigned long *totalpages)
+			gfp_t gfp_mask, nodemask_t *nodemask)
 {
 	struct zone *zone;
 	struct zoneref *z;
 	enum zone_type high_zoneidx =3D gfp_zone(gfp_mask);
-	bool cpuset_limited =3D false;
-	int nid;
-
-	/* Default to all available memory */
-	*totalpages =3D totalram_pages + total_swap_pages;
=20
 	if (!zonelist)
 		return CONSTRAINT_NONE;
@@ -245,33 +235,21 @@ static enum oom_constraint constrained_alloc(struct z=
onelist *zonelist,
 	 * the page allocator means a mempolicy is in effect.  Cpuset policy
 	 * is enforced in get_page_from_freelist().
 	 */
-	if (nodemask && !nodes_subset(node_states[N_HIGH_MEMORY], *nodemask)) {
-		*totalpages =3D total_swap_pages;
-		for_each_node_mask(nid, *nodemask)
-			*totalpages +=3D node_spanned_pages(nid);
+	if (nodemask && !nodes_subset(node_states[N_HIGH_MEMORY], *nodemask))
 		return CONSTRAINT_MEMORY_POLICY;
-	}
=20
 	/* Check this allocation failure is caused by cpuset's wall function */
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 			high_zoneidx, nodemask)
 		if (!cpuset_zone_allowed_softwall(zone, gfp_mask))
-			cpuset_limited =3D true;
+			return CONSTRAINT_CPUSET;
=20
-	if (cpuset_limited) {
-		*totalpages =3D total_swap_pages;
-		for_each_node_mask(nid, cpuset_current_mems_allowed)
-			*totalpages +=3D node_spanned_pages(nid);
-		return CONSTRAINT_CPUSET;
-	}
 	return CONSTRAINT_NONE;
 }
 #else
 static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
-				gfp_t gfp_mask, nodemask_t *nodemask,
-				unsigned long *totalpages)
+					gfp_t gfp_mask, nodemask_t *nodemask)
 {
-	*totalpages =3D totalram_pages + total_swap_pages;
 	return CONSTRAINT_NONE;
 }
 #endif
@@ -282,16 +260,16 @@ static enum oom_constraint constrained_alloc(struct z=
onelist *zonelist,
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
 	struct task_struct *chosen =3D NULL;
 	*ppoints =3D 0;
=20
 	for_each_process(p) {
-		unsigned int points;
+		unsigned long points;
=20
 		if (oom_unkillable_task(p, mem, nodemask))
 			continue;
@@ -323,10 +301,10 @@ static struct task_struct *select_bad_process(unsigne=
d int *ppoints,
 				return ERR_PTR(-1UL);
=20
 			chosen =3D p;
-			*ppoints =3D 1000;
+			*ppoints =3D ULONG_MAX;
 		}
=20
-		points =3D oom_badness(p, mem, nodemask, totalpages);
+		points =3D oom_badness(p, mem, nodemask);
 		if (points > *ppoints) {
 			chosen =3D p;
 			*ppoints =3D points;
@@ -371,7 +349,7 @@ static void dump_tasks(const struct mem_cgroup *mem)
 			continue;
 		}
=20
-		pr_info("[%5d] %5d %5d %8lu %8lu %3u     %3d         %5d %s\n",
+		pr_info("[%5d] %5d %5d %8lu %8lu %3u     %3d         %5ld %s\n",
 			task->pid, task_uid(task), task->tgid,
 			task->mm->total_vm, get_mm_rss(task->mm),
 			task_cpu(task), task->signal->oom_adj,
@@ -385,7 +363,7 @@ static void dump_header(struct task_struct *p, gfp_t gf=
p_mask, int order,
 {
 	task_lock(current);
 	pr_warning("%s invoked oom-killer: gfp_mask=3D0x%x, order=3D%d, "
-		"oom_adj=3D%d, oom_score_adj=3D%d\n",
+		"oom_adj=3D%d, oom_score_adj=3D%ld\n",
 		current->comm, gfp_mask, order, current->signal->oom_adj,
 		current->signal->oom_score_adj);
 	cpuset_print_task_mems_allowed(current);
@@ -426,14 +404,13 @@ static int oom_kill_task(struct task_struct *p, struc=
t mem_cgroup *mem)
 #undef K
=20
 static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int ord=
er,
-			    unsigned int points, unsigned long totalpages,
-			    struct mem_cgroup *mem, nodemask_t *nodemask,
-			    const char *message)
+			    unsigned long points, struct mem_cgroup *mem,
+			    nodemask_t *nodemask, const char *message)
 {
 	struct task_struct *victim =3D p;
 	struct task_struct *child;
 	struct task_struct *t =3D p;
-	unsigned int victim_points =3D 0;
+	unsigned long victim_points =3D 0;
=20
 	if (printk_ratelimit())
 		dump_header(p, gfp_mask, order, mem);
@@ -449,7 +426,7 @@ static int oom_kill_process(struct task_struct *p, gfp_=
t gfp_mask, int order,
 	}
=20
 	task_lock(p);
-	pr_err("%s: Kill process %d (%s) score %d or sacrifice child\n",
+	pr_err("%s: Kill process %d (%s) score %lu or sacrifice child\n",
 		message, task_pid_nr(p), p->comm, points);
 	task_unlock(p);
=20
@@ -461,13 +438,12 @@ static int oom_kill_process(struct task_struct *p, gf=
p_t gfp_mask, int order,
 	 */
 	do {
 		list_for_each_entry(child, &t->children, sibling) {
-			unsigned int child_points;
+			unsigned long child_points;
=20
 			/*
 			 * oom_badness() returns 0 if the thread is unkillable
 			 */
-			child_points =3D oom_badness(child, mem, nodemask,
-								totalpages);
+			child_points =3D oom_badness(child, mem, nodemask);
 			if (child_points > victim_points) {
 				victim =3D child;
 				victim_points =3D child_points;
@@ -505,19 +481,17 @@ static void check_panic_on_oom(enum oom_constraint co=
nstraint, gfp_t gfp_mask,
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
 {
-	unsigned long limit;
-	unsigned int points =3D 0;
+	unsigned long points =3D 0;
 	struct task_struct *p;
=20
 	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, 0);
-	limit =3D mem_cgroup_get_limit(mem) >> PAGE_SHIFT;
 	read_lock(&tasklist_lock);
 retry:
-	p =3D select_bad_process(&points, limit, mem, NULL);
+	p =3D select_bad_process(&points, mem, NULL);
 	if (!p || PTR_ERR(p) =3D=3D -1UL)
 		goto out;
=20
-	if (oom_kill_process(p, gfp_mask, 0, points, limit, mem, NULL,
+	if (oom_kill_process(p, gfp_mask, 0, points, mem, NULL,
 				"Memory cgroup out of memory"))
 		goto retry;
 out:
@@ -642,9 +616,8 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp=
_mask,
 		int order, nodemask_t *nodemask)
 {
 	struct task_struct *p;
-	unsigned long totalpages;
 	unsigned long freed =3D 0;
-	unsigned int points;
+	unsigned long points;
 	enum oom_constraint constraint =3D CONSTRAINT_NONE;
 	int killed =3D 0;
=20
@@ -668,8 +641,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp=
_mask,
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA) that may require different handling.
 	 */
-	constraint =3D constrained_alloc(zonelist, gfp_mask, nodemask,
-						&totalpages);
+	constraint =3D constrained_alloc(zonelist, gfp_mask, nodemask);
 	check_panic_on_oom(constraint, gfp_mask, order);
=20
 	read_lock(&tasklist_lock);
@@ -681,14 +653,14 @@ void out_of_memory(struct zonelist *zonelist, gfp_t g=
fp_mask,
 		 * non-zero, current could not be killed so we must fallback to
 		 * the tasklist scan.
 		 */
-		if (!oom_kill_process(current, gfp_mask, order, 0, totalpages,
+		if (!oom_kill_process(current, gfp_mask, order, 0,
 				NULL, nodemask,
 				"Out of memory (oom_kill_allocating_task)"))
 			goto out;
 	}
=20
 retry:
-	p =3D select_bad_process(&points, totalpages, NULL,
+	p =3D select_bad_process(&points, NULL,
 			constraint =3D=3D CONSTRAINT_MEMORY_POLICY ? nodemask :
 								 NULL);
 	if (PTR_ERR(p) =3D=3D -1UL)
@@ -701,7 +673,7 @@ retry:
 		panic("Out of memory and no killable processes...\n");
 	}
=20
-	if (oom_kill_process(p, gfp_mask, order, points, totalpages, NULL,
+	if (oom_kill_process(p, gfp_mask, order, points, NULL,
 				nodemask, "Out of memory"))
 		goto retry;
 	killed =3D 1;
--=20
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
