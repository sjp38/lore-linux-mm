Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 573AE6B0071
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 03:27:38 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id x13so602575wgg.30
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 00:27:37 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dz7si11026220wib.103.2014.10.21.00.27.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Oct 2014 00:27:36 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 3/4] OOM, PM: OOM killed task shouldn't escape PM suspend
Date: Tue, 21 Oct 2014 09:27:14 +0200
Message-Id: <1413876435-11720-4-git-send-email-mhocko@suse.cz>
In-Reply-To: <1413876435-11720-1-git-send-email-mhocko@suse.cz>
References: <1413876435-11720-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>
Cc: Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

PM freezer relies on having all tasks frozen by the time devices are
getting frozen so that no task will touch them while they are getting
frozen. But OOM killer is allowed to kill an already frozen task in
order to handle OOM situtation. In order to protect from late wake ups
OOM killer is disabled after all tasks are frozen. This, however, still
keeps a window open when a killed task didn't manage to die by the time
freeze_processes finishes.

Reduce the race window by checking all tasks after OOM killer has been
disabled. This is still not race free completely unfortunately because
oom_killer_disable cannot stop an already ongoing OOM killer so a task
might still wake up from the fridge and get killed without
freeze_processes noticing. Full synchronization of OOM and freezer is,
however, too heavy weight for this highly unlikely case.

Introduce and check oom_kills counter which gets incremented early when
the allocator enters __alloc_pages_may_oom path and only check all the
tasks if the counter changes during the freezing attempt. The counter
is updated so early to reduce the race window since allocator checked
oom_killer_disabled which is set by PM-freezing code. A false positive
will push the PM-freezer into a slow path but that is not a big deal.

Fixes: f660daac474c6f (oom: thaw threads if oom killed thread is frozen before deferring)
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Rafael J. Wysocki <rjw@rjwysocki.net>
Cc: Tejun Heo <tj@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: stable@vger.kernel.org # 3.2+
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/oom.h    |  3 +++
 kernel/power/process.c | 31 ++++++++++++++++++++++++++++++-
 mm/oom_kill.c          | 17 +++++++++++++++++
 mm/page_alloc.c        |  8 ++++++++
 4 files changed, 58 insertions(+), 1 deletion(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 647395a1a550..e8d6e1058723 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -50,6 +50,9 @@ static inline bool oom_task_origin(const struct task_struct *p)
 extern unsigned long oom_badness(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask,
 		unsigned long totalpages);
+
+extern int oom_kills_count(void);
+extern void note_oom_kill(void);
 extern void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 			     unsigned int points, unsigned long totalpages,
 			     struct mem_cgroup *memcg, nodemask_t *nodemask,
diff --git a/kernel/power/process.c b/kernel/power/process.c
index 4ee194eb524b..a397fa161d11 100644
--- a/kernel/power/process.c
+++ b/kernel/power/process.c
@@ -118,6 +118,7 @@ static int try_to_freeze_tasks(bool user_only)
 int freeze_processes(void)
 {
 	int error;
+	int oom_kills_saved;
 
 	error = __usermodehelper_disable(UMH_FREEZING);
 	if (error)
@@ -131,12 +132,40 @@ int freeze_processes(void)
 
 	printk("Freezing user space processes ... ");
 	pm_freezing = true;
+	oom_kills_saved = oom_kills_count();
 	error = try_to_freeze_tasks(true);
 	if (!error) {
-		printk("done.");
 		__usermodehelper_set_disable_depth(UMH_DISABLED);
 		oom_killer_disable();
+
+		/*
+		 * There might have been an OOM kill while we were
+		 * freezing tasks and the killed task might be still
+		 * on the way out so we have to double check for race.
+		 */
+		if (oom_kills_count() != oom_kills_saved) {
+			struct task_struct *g, *p;
+
+			read_lock(&tasklist_lock);
+			for_each_process_thread(g, p) {
+				if (p == current || freezer_should_skip(p) ||
+				    frozen(p))
+					continue;
+				error = -EBUSY;
+				goto out_loop;
+			}
+out_loop:
+			read_unlock(&tasklist_lock);
+
+			if (error) {
+				__usermodehelper_set_disable_depth(UMH_ENABLED);
+				printk("OOM in progress.");
+				goto done;
+			}
+		}
+		printk("done.");
 	}
+done:
 	printk("\n");
 	BUG_ON(in_atomic());
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index bbf405a3a18f..5340f6b91312 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -404,6 +404,23 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 		dump_tasks(memcg, nodemask);
 }
 
+/*
+ * Number of OOM killer invocations (including memcg OOM killer).
+ * Primarily used by PM freezer to check for potential races with
+ * OOM killed frozen task.
+ */
+static atomic_t oom_kills = ATOMIC_INIT(0);
+
+int oom_kills_count(void)
+{
+	return atomic_read(&oom_kills);
+}
+
+void note_oom_kill(void)
+{
+	atomic_inc(&oom_kills);
+}
+
 #define K(x) ((x) << (PAGE_SHIFT-10))
 /*
  * Must be called while holding a reference to p, which will be released upon
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cb573b10af12..efccbbadd7c9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2286,6 +2286,14 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	}
 
 	/*
+	 * PM-freezer should be notified that there might be an OOM killer on its
+	 * way to kill and wake somebody up. This is too early and we might end
+	 * up not killing anything but false positives are acceptable.
+	 * See freeze_processes.
+	 */
+	note_oom_kill();
+
+	/*
 	 * Go through the zonelist yet one more time, keep very high watermark
 	 * here, this is only to catch a parallel oom killing, we must fail if
 	 * we're still under heavy pressure.
-- 
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
