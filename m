Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id CF2B56B000E
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 06:13:29 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v3 1/6] memcg: prevent changes to move_charge_at_immigrate during task attach
Date: Mon, 21 Jan 2013 15:13:28 +0400
Message-Id: <1358766813-15095-2-git-send-email-glommer@parallels.com>
In-Reply-To: <1358766813-15095-1-git-send-email-glommer@parallels.com>
References: <1358766813-15095-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Glauber Costa <glommer@parallels.com>

Currently, we rely on the cgroup_lock() to prevent changes to
move_charge_at_immigrate during task migration. However, this is only
needed because the current strategy keeps checking this value throughout
the whole process. Since all we need is serialization, one needs only to
guarantee that whatever decision we made in the beginning of a specific
migration is respected throughout the process.

We can achieve this by just saving it in mc. By doing this, no kind of
locking is needed.

[ v2: change flag name to avoid confusion ]

Signed-off-by: Glauber Costa <glommer@parallels.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 32 +++++++++++++++++++-------------
 1 file changed, 19 insertions(+), 13 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 09255ec..91d90a0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -398,8 +398,8 @@ static bool memcg_kmem_test_and_clear_dead(struct mem_cgroup *memcg)
 
 /* Stuffs for move charges at task migration. */
 /*
- * Types of charges to be moved. "move_charge_at_immitgrate" is treated as a
- * left-shifted bitmap of these types.
+ * Types of charges to be moved. "move_charge_at_immitgrate" and
+ * "immigrate_flags" are treated as a left-shifted bitmap of these types.
  */
 enum move_type {
 	MOVE_CHARGE_TYPE_ANON,	/* private anonymous page and swap of it */
@@ -412,6 +412,7 @@ static struct move_charge_struct {
 	spinlock_t	  lock; /* for from, to */
 	struct mem_cgroup *from;
 	struct mem_cgroup *to;
+	unsigned long immigrate_flags;
 	unsigned long precharge;
 	unsigned long moved_charge;
 	unsigned long moved_swap;
@@ -424,14 +425,12 @@ static struct move_charge_struct {
 
 static bool move_anon(void)
 {
-	return test_bit(MOVE_CHARGE_TYPE_ANON,
-					&mc.to->move_charge_at_immigrate);
+	return test_bit(MOVE_CHARGE_TYPE_ANON, &mc.immigrate_flags);
 }
 
 static bool move_file(void)
 {
-	return test_bit(MOVE_CHARGE_TYPE_FILE,
-					&mc.to->move_charge_at_immigrate);
+	return test_bit(MOVE_CHARGE_TYPE_FILE, &mc.immigrate_flags);
 }
 
 /*
@@ -5146,15 +5145,14 @@ static int mem_cgroup_move_charge_write(struct cgroup *cgrp,
 
 	if (val >= (1 << NR_MOVE_TYPE))
 		return -EINVAL;
+
 	/*
-	 * We check this value several times in both in can_attach() and
-	 * attach(), so we need cgroup lock to prevent this value from being
-	 * inconsistent.
+	 * No kind of locking is needed in here, because ->can_attach() will
+	 * check this value once in the beginning of the process, and then carry
+	 * on with stale data. This means that changes to this value will only
+	 * affect task migrations starting after the change.
 	 */
-	cgroup_lock();
 	memcg->move_charge_at_immigrate = val;
-	cgroup_unlock();
-
 	return 0;
 }
 #else
@@ -6530,8 +6528,15 @@ static int mem_cgroup_can_attach(struct cgroup *cgroup,
 	struct task_struct *p = cgroup_taskset_first(tset);
 	int ret = 0;
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgroup);
+	unsigned long move_charge_at_immigrate;
 
-	if (memcg->move_charge_at_immigrate) {
+	/*
+	 * We are now commited to this value whatever it is. Changes in this
+	 * tunable will only affect upcoming migrations, not the current one.
+	 * So we need to save it, and keep it going.
+	 */
+	move_charge_at_immigrate  = memcg->move_charge_at_immigrate;
+	if (move_charge_at_immigrate) {
 		struct mm_struct *mm;
 		struct mem_cgroup *from = mem_cgroup_from_task(p);
 
@@ -6551,6 +6556,7 @@ static int mem_cgroup_can_attach(struct cgroup *cgroup,
 			spin_lock(&mc.lock);
 			mc.from = from;
 			mc.to = memcg;
+			mc.immigrate_flags = move_charge_at_immigrate;
 			spin_unlock(&mc.lock);
 			/* We set mc.moving_task later */
 
-- 
1.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
