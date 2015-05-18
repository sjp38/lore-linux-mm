Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 983D46B006E
	for <linux-mm@kvack.org>; Mon, 18 May 2015 15:50:03 -0400 (EDT)
Received: by qkgv12 with SMTP id v12so42071585qkg.0
        for <linux-mm@kvack.org>; Mon, 18 May 2015 12:50:03 -0700 (PDT)
Received: from mail-qc0-x231.google.com (mail-qc0-x231.google.com. [2607:f8b0:400d:c01::231])
        by mx.google.com with ESMTPS id n86si8063133qkh.90.2015.05.18.12.50.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 12:50:02 -0700 (PDT)
Received: by qcir1 with SMTP id r1so28305614qci.3
        for <linux-mm@kvack.org>; Mon, 18 May 2015 12:50:02 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 2/7] memcg: restructure mem_cgroup_can_attach()
Date: Mon, 18 May 2015 15:49:50 -0400
Message-Id: <1431978595-12176-3-git-send-email-tj@kernel.org>
In-Reply-To: <1431978595-12176-1-git-send-email-tj@kernel.org>
References: <1431978595-12176-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com
Cc: cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>

Restructure it to lower nesting level and help the planned threadgroup
leader iteration changes.

This is pure reorganization.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 61 ++++++++++++++++++++++++++++++---------------------------
 1 file changed, 32 insertions(+), 29 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 14c2f20..b1b834d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4997,10 +4997,12 @@ static void mem_cgroup_clear_mc(void)
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
@@ -5008,36 +5010,37 @@ static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
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
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
