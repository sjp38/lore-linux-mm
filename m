Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3B8626B007E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 07:55:16 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id t8so4115603oif.2
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 04:55:16 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t82si67016oig.118.2016.06.08.04.55.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Jun 2016 04:55:15 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: oom: deduplicate victim selection code for memcg and global oom
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <40e03fd7aaf1f55c75d787128d6d17c5a71226c2.1464358556.git.vdavydov@virtuozzo.com>
	<3bbc7b70dae6ace0b8751e0140e878acfdfffd74.1464358556.git.vdavydov@virtuozzo.com>
	<20160608083334.GF22570@dhcp22.suse.cz>
In-Reply-To: <20160608083334.GF22570@dhcp22.suse.cz>
Message-Id: <201606082018.EDC09327.HMQOFOVJFSOFtL@I-love.SAKURA.ne.jp>
Date: Wed, 8 Jun 2016 20:18:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, vdavydov@virtuozzo.com
Cc: akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> The victim selection code can be reduced because it is basically
> shared between the two, only the iterator differs. But I guess that
> can be eliminated by a simple helper.

Thank you for CC: me. I like this clean up.

> ---
>  include/linux/oom.h |  5 +++++
>  mm/memcontrol.c     | 47 ++++++-----------------------------------
>  mm/oom_kill.c       | 60 ++++++++++++++++++++++++++++-------------------------
>  3 files changed, 43 insertions(+), 69 deletions(-)

I think we can apply your version with below changes folded into your version.
(I think totalpages argument can be passed via oom_control as well. Also, according to
http://lkml.kernel.org/r/201602192336.EJF90671.HMFLFSVOFJOtOQ@I-love.SAKURA.ne.jp ,
we can safely replace oc->memcg in oom_badness() in oom_evaluate_task() with NULL. )

 include/linux/oom.h |   10 ----------
 mm/memcontrol.c     |    7 +++++--
 mm/oom_kill.c       |   14 ++++++++++++--
 3 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 7b3eb25..77e98a0 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -49,13 +49,6 @@ enum oom_constraint {
 	CONSTRAINT_MEMCG,
 };
 
-enum oom_scan_t {
-	OOM_SCAN_OK,		/* scan thread and find its badness */
-	OOM_SCAN_CONTINUE,	/* do not consider thread for oom kill */
-	OOM_SCAN_ABORT,		/* abort the iteration and return */
-	OOM_SCAN_SELECT,	/* always select this thread first */
-};
-
 extern struct mutex oom_lock;
 
 static inline void set_current_oom_origin(void)
@@ -96,9 +89,6 @@ extern void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 extern void check_panic_on_oom(struct oom_control *oc,
 			       enum oom_constraint constraint);
 
-extern enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
-					       struct task_struct *task);
-
 extern bool out_of_memory(struct oom_control *oc);
 
 extern void exit_oom_victim(struct task_struct *tsk);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9c51b4d..f3482a2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1288,12 +1288,15 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 
 		css_task_iter_start(&iter->css, &it);
 		while ((task = css_task_iter_next(&it)))
-			if (!oom_evaluate_task(&oc, task, totalpages))
+			if (!oom_evaluate_task(&oc, task, totalpages)) {
+				css_task_iter_end(&it);
+				mem_cgroup_iter_break(memcg, iter);
 				break;
+			}
 		css_task_iter_end(&it);
 	}
 
-	if (oc.chosen) {
+	if (oc.chosen && oc.chosen != (void *) -1UL) {
 		points = oc.chosen_points * 1000 / totalpages;
 		oom_kill_process(&oc, oc.chosen, points, totalpages,
 				 "Memory cgroup out of memory");
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index bce3ea2..f634bca 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -273,8 +273,15 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc,
 }
 #endif
 
-enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
-					struct task_struct *task)
+enum oom_scan_t {
+	OOM_SCAN_OK,		/* scan thread and find its badness */
+	OOM_SCAN_CONTINUE,	/* do not consider thread for oom kill */
+	OOM_SCAN_ABORT,		/* abort the iteration and return */
+	OOM_SCAN_SELECT,	/* always select this thread first */
+};
+
+static enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
+					       struct task_struct *task)
 {
 	if (oom_unkillable_task(task, NULL, oc->nodemask))
 		return OOM_SCAN_CONTINUE;
@@ -307,6 +314,9 @@ int oom_evaluate_task(struct oom_control *oc, struct task_struct *p, unsigned lo
 	case OOM_SCAN_CONTINUE:
 		return 1;
 	case OOM_SCAN_ABORT:
+		if (oc->chosen)
+			put_task_struct(oc->chosen);
+		oc->chosen = (void *) -1UL;
 		return 0;
 	case OOM_SCAN_OK:
 		break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
