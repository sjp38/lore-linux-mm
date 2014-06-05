Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 44AB66B003A
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 10:00:55 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id x48so1129705wes.8
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 07:00:54 -0700 (PDT)
Received: from mail.sigma-star.at (mail.sigma-star.at. [95.130.255.111])
        by mx.google.com with ESMTP id es8si41376189wic.43.2014.06.05.07.00.53
        for <linux-mm@kvack.org>;
        Thu, 05 Jun 2014 07:00:53 -0700 (PDT)
From: Richard Weinberger <richard@nod.at>
Subject: [RFC][PATCH] oom: Be less verbose if the oom_control event fd has listeners
Date: Thu,  5 Jun 2014 16:00:41 +0200
Message-Id: <1401976841-3899-2-git-send-email-richard@nod.at>
In-Reply-To: <1401976841-3899-1-git-send-email-richard@nod.at>
References: <1401976841-3899-1-git-send-email-richard@nod.at>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: mhocko@suse.cz, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, vdavydov@parallels.com, tj@kernel.org, handai.szj@taobao.com, rientjes@google.com, oleg@redhat.com, rusty@rustcorp.com.au, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Richard Weinberger <richard@nod.at>

Don't spam the kernel logs if the oom_control event fd has listeners.
In this case there is no need to print that much lines as user space
will anyway notice that the memory cgroup has reached its limit.

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 include/linux/memcontrol.h |  6 ++++++
 mm/memcontrol.c            | 20 ++++++++++++++++++++
 mm/oom_kill.c              |  2 +-
 3 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index b569b8b..506a1a9 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -131,6 +131,7 @@ int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec);
 int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
 unsigned long mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list);
 void mem_cgroup_update_lru_size(struct lruvec *, enum lru_list, int);
+extern int mem_cgroup_has_listeners(struct mem_cgroup *memcg);
 extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 					struct task_struct *p);
 extern void mem_cgroup_replace_page_cache(struct page *oldpage,
@@ -358,6 +359,11 @@ mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
 {
 }
 
+static inline int mem_cgroup_has_listeners(struct mem_cgroup *memcg)
+{
+	return 0;
+}
+
 static inline void
 mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5177c6d..3864c6a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5777,6 +5777,26 @@ static void mem_cgroup_oom_unregister_event(struct mem_cgroup *memcg,
 	spin_unlock(&memcg_oom_lock);
 }
 
+/**
+ * mem_cgroup_has_listeners: Returns true in case we have one ore more
+ * listeners on our oom notifier event fd.
+ * @memcg: The memory cgroup that went over limit
+ */
+int mem_cgroup_has_listeners(struct mem_cgroup *memcg)
+{
+	int ret = 0;
+
+	if (!memcg)
+		goto out;
+
+	spin_lock(&memcg_oom_lock);
+	ret = !list_empty(&memcg->oom_notify);
+	spin_unlock(&memcg_oom_lock);
+
+out:
+	return ret;
+}
+
 static int mem_cgroup_oom_control_read(struct seq_file *sf, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(sf));
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 3291e82..b5c9433 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -434,7 +434,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		return;
 	}
 
-	if (__ratelimit(&oom_rs))
+	if (__ratelimit(&oom_rs) && !mem_cgroup_has_listeners(memcg))
 		dump_header(p, gfp_mask, order, memcg, nodemask);
 
 	task_lock(p);
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
