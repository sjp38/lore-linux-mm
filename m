Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id F16016B0092
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 08:51:50 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so1365307bkt.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 05:51:50 -0800 (PST)
Subject: [PATCH v3 02/21] memcg: make mm_match_cgroup() hirarchical
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 23 Feb 2012 17:51:46 +0400
Message-ID: <20120223135146.12988.47611.stgit@zurg>
In-Reply-To: <20120223133728.12988.5432.stgit@zurg>
References: <20120223133728.12988.5432.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>

Check mm-owner cgroup membership hierarchically.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/memcontrol.h |   11 ++---------
 mm/memcontrol.c            |   20 ++++++++++++++++++++
 2 files changed, 22 insertions(+), 9 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 8c4d74f..4822d53 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -87,15 +87,8 @@ extern struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm);
 extern struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg);
 extern struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont);
 
-static inline
-int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
-{
-	struct mem_cgroup *memcg;
-	rcu_read_lock();
-	memcg = mem_cgroup_from_task(rcu_dereference((mm)->owner));
-	rcu_read_unlock();
-	return cgroup == memcg;
-}
+extern int mm_match_cgroup(const struct mm_struct *mm,
+			   const struct mem_cgroup *cgroup);
 
 extern struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *memcg);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b8039d2..77f5d48 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -821,6 +821,26 @@ struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
 				struct mem_cgroup, css);
 }
 
+/**
+ * mm_match_cgroup - cgroup hierarchy mm membership test
+ * @mm		mm_struct to test
+ * @cgroup	target cgroup
+ *
+ * Returns true if mm belong this cgroup or any its child in hierarchy
+ */
+int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
+{
+	struct mem_cgroup *memcg;
+
+	rcu_read_lock();
+	memcg = mem_cgroup_from_task(rcu_dereference((mm)->owner));
+	while (memcg != cgroup && memcg && memcg->use_hierarchy)
+		memcg = parent_mem_cgroup(memcg);
+	rcu_read_unlock();
+
+	return cgroup == memcg;
+}
+
 struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
 {
 	struct mem_cgroup *memcg = NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
