Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5985D6B0175
	for <linux-mm@kvack.org>; Tue, 26 May 2015 07:50:25 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so62271056wic.0
        for <linux-mm@kvack.org>; Tue, 26 May 2015 04:50:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fq10si17684303wib.108.2015.05.26.04.50.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 26 May 2015 04:50:23 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 2/3] memcg: Use mc.moving_task as the indication for charge moving
Date: Tue, 26 May 2015 13:50:05 +0200
Message-Id: <1432641006-8025-3-git-send-email-mhocko@suse.cz>
In-Reply-To: <1432641006-8025-1-git-send-email-mhocko@suse.cz>
References: <1432641006-8025-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

move_charge_struct::to not being NULL has been used to indicate whether
the currently ongoing move operation should migrate the charges. The follow up
patch will require mc.to being initialized even when we do not migrate
charges so replace the check by checking mc.moving_task which is set
only when the migration is requested. Also replace the open coded check
by a helper function (mc_move_charge).

mem_cgroup_clear_mc has to be called unconditionally now because it
has to clean up from and to pointers. __mem_cgroup_clear_mc does the
migration specific cleanup so it still checks for mc_move_charge.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 63 +++++++++++++++++++++++++++++++--------------------------
 1 file changed, 34 insertions(+), 29 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f3d92cf0caf4..4d905209f00f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4984,14 +4984,22 @@ static void __mem_cgroup_clear_mc(void)
 	wake_up_all(&mc.waitq);
 }
 
+static bool mc_move_charge(void)
+{
+	/* moving_task is configured only if the charge is really moved */
+	return mc.moving_task != NULL;
+}
+
 static void mem_cgroup_clear_mc(void)
 {
+	bool move_charge = mc_move_charge();
 	/*
 	 * we must clear moving_task before waking up waiters at the end of
 	 * task migration.
 	 */
 	mc.moving_task = NULL;
-	__mem_cgroup_clear_mc();
+	if (move_charge)
+		__mem_cgroup_clear_mc();
 	spin_lock(&mc.lock);
 	mc.from = NULL;
 	mc.to = NULL;
@@ -5008,15 +5016,6 @@ static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
 	unsigned long move_flags;
 	int ret = 0;
 
-	/*
-	 * We are now commited to this value whatever it is. Changes in this
-	 * tunable will only affect upcoming migrations, not the current one.
-	 * So we need to save it, and keep it going.
-	 */
-	move_flags = READ_ONCE(memcg->move_charge_at_immigrate);
-	if (!move_flags)
-		return 0;
-
 	p = cgroup_taskset_first(tset);
 	from = mem_cgroup_from_task(p);
 
@@ -5025,21 +5024,29 @@ static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
 	mm = get_task_mm(p);
 	if (!mm)
 		return 0;
-	/* We move charges only when we move a owner of the mm */
-	if (mm->owner == p) {
-		VM_BUG_ON(mc.from);
-		VM_BUG_ON(mc.to);
-		VM_BUG_ON(mc.precharge);
-		VM_BUG_ON(mc.moved_charge);
-		VM_BUG_ON(mc.moved_swap);
-
-		spin_lock(&mc.lock);
-		mc.from = from;
-		mc.to = memcg;
-		mc.flags = move_flags;
-		spin_unlock(&mc.lock);
-		/* We set mc.moving_task later */
 
+	VM_BUG_ON(mc.from);
+	VM_BUG_ON(mc.to);
+	VM_BUG_ON(mc.precharge);
+	VM_BUG_ON(mc.moved_charge);
+	VM_BUG_ON(mc.moved_swap);
+
+	spin_lock(&mc.lock);
+	mc.from = from;
+	mc.to = memcg;
+	mc.flags = move_flags;
+	spin_unlock(&mc.lock);
+	/* We set mc.moving_task later */
+
+	/*
+	 * We are now commited to this value whatever it is. Changes in this
+	 * tunable will only affect upcoming migrations, not the current one.
+	 * So we need to save it, and keep it going.
+	 */
+	move_flags = READ_ONCE(memcg->move_charge_at_immigrate);
+
+	/* We move charges only when we move a owner of the mm */
+	if (move_flags && mm->owner == p) {
 		ret = mem_cgroup_precharge_mc(mm);
 		if (ret)
 			mem_cgroup_clear_mc();
@@ -5051,8 +5058,7 @@ static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
 static void mem_cgroup_cancel_attach(struct cgroup_subsys_state *css,
 				     struct cgroup_taskset *tset)
 {
-	if (mc.to)
-		mem_cgroup_clear_mc();
+	mem_cgroup_clear_mc();
 }
 
 static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
@@ -5198,12 +5204,11 @@ static void mem_cgroup_move_task(struct cgroup_subsys_state *css,
 	struct mm_struct *mm = get_task_mm(p);
 
 	if (mm) {
-		if (mc.to)
+		if (mc_move_charge())
 			mem_cgroup_move_charge(mm);
 		mmput(mm);
 	}
-	if (mc.to)
-		mem_cgroup_clear_mc();
+	mem_cgroup_clear_mc();
 }
 #else	/* !CONFIG_MMU */
 static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
