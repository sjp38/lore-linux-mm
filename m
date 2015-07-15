Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6D8D528027E
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 07:15:19 -0400 (EDT)
Received: by wiga1 with SMTP id a1so125755130wig.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 04:15:19 -0700 (PDT)
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id bd2si7304056wjc.130.2015.07.15.04.15.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 04:15:18 -0700 (PDT)
Received: by wgxm20 with SMTP id m20so30741800wgx.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 04:15:17 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 4/5] memcg: restructure mem_cgroup_can_attach()
Date: Wed, 15 Jul 2015 13:14:44 +0200
Message-Id: <1436958885-18754-5-git-send-email-mhocko@kernel.org>
In-Reply-To: <1436958885-18754-1-git-send-email-mhocko@kernel.org>
References: <1436958885-18754-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

From: Tejun Heo <tj@kernel.org>

Restructure it to lower nesting level and help the planned threadgroup
leader iteration changes.

This is pure reorganization.

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>
Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 61 ++++++++++++++++++++++++++++++---------------------------
 1 file changed, 32 insertions(+), 29 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a3543dedc153..5d4fba8cbdd0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4828,10 +4828,12 @@ static void mem_cgroup_clear_mc(void)
 static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
 				 struct cgroup_taskset *tset)
 {
-	struct task_struct *p = cgroup_taskset_first(tset);
-	int ret = 0;
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+	struct mem_cgroup *from;
+	struct task_struct *p;
+	struct mm_struct *mm;
 	unsigned long move_flags;
+	int ret = 0;
 
 	/*
 	 * We are now commited to this value whatever it is. Changes in this
@@ -4839,36 +4841,37 @@ static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
 	 * So we need to save it, and keep it going.
 	 */
 	move_flags = READ_ONCE(memcg->move_charge_at_immigrate);
-	if (move_flags) {
-		struct mm_struct *mm;
-		struct mem_cgroup *from = mem_cgroup_from_task(p);
+	if (!move_flags)
+		return 0;
 
-		VM_BUG_ON(from == memcg);
+	p = cgroup_taskset_first(tset);
+	from = mem_cgroup_from_task(p);
 
-		mm = get_task_mm(p);
-		if (!mm)
-			return 0;
-		/* We move charges only when we move a owner of the mm */
-		if (mm->owner == p) {
-			VM_BUG_ON(mc.from);
-			VM_BUG_ON(mc.to);
-			VM_BUG_ON(mc.precharge);
-			VM_BUG_ON(mc.moved_charge);
-			VM_BUG_ON(mc.moved_swap);
-
-			spin_lock(&mc.lock);
-			mc.from = from;
-			mc.to = memcg;
-			mc.flags = move_flags;
-			spin_unlock(&mc.lock);
-			/* We set mc.moving_task later */
-
-			ret = mem_cgroup_precharge_mc(mm);
-			if (ret)
-				mem_cgroup_clear_mc();
-		}
-		mmput(mm);
+	VM_BUG_ON(from == memcg);
+
+	mm = get_task_mm(p);
+	if (!mm)
+		return 0;
+	/* We move charges only when we move a owner of the mm */
+	if (mm->owner == p) {
+		VM_BUG_ON(mc.from);
+		VM_BUG_ON(mc.to);
+		VM_BUG_ON(mc.precharge);
+		VM_BUG_ON(mc.moved_charge);
+		VM_BUG_ON(mc.moved_swap);
+
+		spin_lock(&mc.lock);
+		mc.from = from;
+		mc.to = memcg;
+		mc.flags = move_flags;
+		spin_unlock(&mc.lock);
+		/* We set mc.moving_task later */
+
+		ret = mem_cgroup_precharge_mc(mm);
+		if (ret)
+			mem_cgroup_clear_mc();
 	}
+	mmput(mm);
 	return ret;
 }
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
