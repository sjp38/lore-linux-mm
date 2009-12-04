Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9014160021B
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 01:49:41 -0500 (EST)
Date: Fri, 4 Dec 2009 14:48:36 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mmotm 2/7] memcg: add interface to move charge at task
 migration
Message-Id: <20091204144836.41401c14.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091204144609.b61cc8c4.nishimura@mxp.nes.nec.co.jp>
References: <20091204144609.b61cc8c4.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

In current memcg, charges associated with a task aren't moved to the new cgroup
at task migration. Some users feel this behavior to be strange.
These patches are for this feature, that is, for charging to the new cgroup
and, of course, uncharging from the old cgroup at task migration.

This patch adds "memory.move_charge_at_immigrate" file, which is a flag file to
determine whether charges should be moved to the new cgroup at task migration or
not and what type of charges should be moved. This patch also adds read and
write handlers of the file.

This patch also adds no-op handlers for this feature. These handlers will be
implemented in later patches. And you cannot write any values other than 0
to move_charge_at_immigrate yet.

Changelog: 2009/12/04
- change the term "recharge" to "move_charge".
- update memory.txt.
Changelog: 2009/11/19
- consolidate changes in Documentation/cgroup/memory.txt, which were made in
  other patches separately.
- handle recharge_at_immigrate as bitmask(as I did in first version).
- use mm->owner instead of thread_group_leader().
Changelog: 2009/09/24
- change the term "migration" to "recharge".
- handle the flag as bool not bitmask to make codes simple.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 Documentation/cgroups/memory.txt |   48 ++++++++++++++++++-
 mm/memcontrol.c                  |   97 ++++++++++++++++++++++++++++++++++++--
 2 files changed, 139 insertions(+), 6 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index b871f25..19b01f7 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -262,10 +262,12 @@ some of the pages cached in the cgroup (page cache pages).
 4.2 Task migration
 
 When a task migrates from one cgroup to another, it's charge is not
-carried forward. The pages allocated from the original cgroup still
+carried forward by default. The pages allocated from the original cgroup still
 remain charged to it, the charge is dropped when the page is freed or
 reclaimed.
 
+Note: You can move charges of a task along with task migration. See 8.
+
 4.3 Removing a cgroup
 
 A cgroup can be removed by rmdir, but as discussed in sections 4.1 and 4.2, a
@@ -414,7 +416,49 @@ NOTE1: Soft limits take effect over a long period of time, since they involve
 NOTE2: It is recommended to set the soft limit always below the hard limit,
        otherwise the hard limit will take precedence.
 
-8. TODO
+8. Move charges at task migration
+
+Users can move charges associated with a task along with task migration, that
+is, uncharge task's pages from the old cgroup and charge them to the new cgroup.
+
+8.1 Interface
+
+This feature is disabled by default. It can be enabled(and disabled again) by
+writing to memory.move_charge_at_immigrate of the destination cgroup.
+
+If you want to enable it:
+
+# echo (some positive value) > memory.move_charge_at_immigrate
+
+Note: Each bits of move_charge_at_immigrate has its own meaning about what type
+      of charges should be moved. See 8.2 for details.
+Note: Charges are moved only when you move mm->owner, IOW, a leader of a thread
+      group.
+Note: If we cannot find enough space for the task in the destination cgroup, we
+      try to make space by reclaiming memory. Task migration may fail if we
+      cannot make enough space.
+Note: It can take several seconds if you move charges in giga bytes order.
+
+And if you want disable it again:
+
+# echo 0 > memory.move_charge_at_immigrate
+
+8.2 Type of charges which can be move
+
+Each bits of move_charge_at_immigrate has its own meaning about what type of
+charges should be moved.
+
+  bit | what type of charges would be moved ?
+ -----+------------------------------------------------------------------------
+   0  | A charge of an anonymous page(or swap of it) used by the target task.
+      | Those pages and swaps must be used only by the target task. You must
+      | enable Swap Extension(see 2.4) to enable move of swap charges.
+
+Note: Those pages and swaps must be charged to the old cgroup.
+Note: More type of pages(e.g. file cache, shmem,) will be supported by other
+      bits in future.
+
+9. TODO
 
 1. Add support for accounting huge pages (as a separate controller)
 2. Make per-cgroup scanner reclaim not-shared pages first
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 951c103..2624d23 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -226,11 +226,26 @@ struct mem_cgroup {
 	bool		memsw_is_minimum;
 
 	/*
+	 * Should we move charges of a task when a task is moved into this
+	 * mem_cgroup ? And what type of charges should we move ?
+	 */
+	unsigned long 	move_charge_at_immigrate;
+
+	/*
 	 * statistics. This must be placed at the end of memcg.
 	 */
 	struct mem_cgroup_stat stat;
 };
 
+/* Stuffs for move charges at task migration. */
+/*
+ * Types of charges to be moved. "move_charge_at_immitgrate" is treated as a
+ * left-shifted bitmap of these types.
+ */
+enum move_type {
+	NR_MOVE_TYPE,
+};
+
 /*
  * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
  * limit reclaim to prevent infinite loops, if they ever occur.
@@ -2867,6 +2882,31 @@ static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
 	return 0;
 }
 
+static u64 mem_cgroup_move_charge_read(struct cgroup *cgrp,
+					struct cftype *cft)
+{
+	return mem_cgroup_from_cont(cgrp)->move_charge_at_immigrate;
+}
+
+static int mem_cgroup_move_charge_write(struct cgroup *cgrp,
+					struct cftype *cft, u64 val)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
+
+	if (val >= (1 << NR_MOVE_TYPE))
+		return -EINVAL;
+	/*
+	 * We check this value several times in both in can_attach() and
+	 * attach(), so we need cgroup lock to prevent this value from being
+	 * inconsistent.
+	 */
+	cgroup_lock();
+	mem->move_charge_at_immigrate = val;
+	cgroup_unlock();
+
+	return 0;
+}
+
 
 /* For read statistics */
 enum {
@@ -3100,6 +3140,11 @@ static struct cftype mem_cgroup_files[] = {
 		.read_u64 = mem_cgroup_swappiness_read,
 		.write_u64 = mem_cgroup_swappiness_write,
 	},
+	{
+		.name = "move_charge_at_immigrate",
+		.read_u64 = mem_cgroup_move_charge_read,
+		.write_u64 = mem_cgroup_move_charge_write,
+	},
 };
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
@@ -3347,6 +3392,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	if (parent)
 		mem->swappiness = get_swappiness(parent);
 	atomic_set(&mem->refcnt, 1);
+	mem->move_charge_at_immigrate = 0;
 	return &mem->css;
 free_out:
 	__mem_cgroup_free(mem);
@@ -3383,16 +3429,57 @@ static int mem_cgroup_populate(struct cgroup_subsys *ss,
 	return ret;
 }
 
+/* Handlers for move charge at task migration. */
+static int mem_cgroup_can_move_charge(void)
+{
+	return 0;
+}
+
+static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
+				struct cgroup *cgroup,
+				struct task_struct *p,
+				bool threadgroup)
+{
+	int ret = 0;
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cgroup);
+
+	if (mem->move_charge_at_immigrate) {
+		struct mm_struct *mm;
+		struct mem_cgroup *from = mem_cgroup_from_task(p);
+
+		VM_BUG_ON(from == mem);
+
+		mm = get_task_mm(p);
+		if (!mm)
+			return 0;
+
+		/* We move charges only when we move a owner of the mm */
+		if (mm->owner == p)
+			ret = mem_cgroup_can_move_charge();
+
+		mmput(mm);
+	}
+	return ret;
+}
+
+static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
+				struct cgroup *cgroup,
+				struct task_struct *p,
+				bool threadgroup)
+{
+}
+
+static void mem_cgroup_move_charge(void)
+{
+}
+
 static void mem_cgroup_move_task(struct cgroup_subsys *ss,
 				struct cgroup *cont,
 				struct cgroup *old_cont,
 				struct task_struct *p,
 				bool threadgroup)
 {
-	/*
-	 * FIXME: It's better to move charges of this process from old
-	 * memcg to new memcg. But it's just on TODO-List now.
-	 */
+	mem_cgroup_move_charge();
 }
 
 struct cgroup_subsys mem_cgroup_subsys = {
@@ -3402,6 +3489,8 @@ struct cgroup_subsys mem_cgroup_subsys = {
 	.pre_destroy = mem_cgroup_pre_destroy,
 	.destroy = mem_cgroup_destroy,
 	.populate = mem_cgroup_populate,
+	.can_attach = mem_cgroup_can_attach,
+	.cancel_attach = mem_cgroup_cancel_attach,
 	.attach = mem_cgroup_move_task,
 	.early_init = 0,
 	.use_id = 1,
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
