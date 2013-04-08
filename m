Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 395E96B0099
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 02:37:54 -0400 (EDT)
Message-ID: <51626584.7050405@huawei.com>
Date: Mon, 8 Apr 2013 14:36:52 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 13/12] memcg: don't need memcg->memcg_name
References: <5162648B.9070802@huawei.com>
In-Reply-To: <5162648B.9070802@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

Now memcg has the same life cycle as its corresponding cgroup,
we don't have to save the cgroup path name in memcg->memcg_name.

Signed-off-by: Li Zefan <lizefan@huawei.com>
---
 mm/memcontrol.c | 65 +++++++++++++++++++++------------------------------------
 1 file changed, 24 insertions(+), 41 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index aeab1d3..06e995e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -306,20 +306,12 @@ struct mem_cgroup {
 		struct list_head dead;
 	};
 
-	union {
-		/*
-		 * Should we move charges of a task when a task is moved into
-		 * this mem_cgroup ? And what type of charges should we move ?
-		 */
-		unsigned long move_charge_at_immigrate;
+	/*
+	 * Should we move charges of a task when a task is moved into
+	 * this mem_cgroup ? And what type of charges should we move ?
+	 */
+	unsigned long move_charge_at_immigrate;
 
-		/*
-		 * We are no longer concerned about moving charges after memcg
-		 * is dead. So we will fill this up with its name, to aid
-		 * debugging.
-		 */
-		char *memcg_name;
-	};
 	/*
 	 * set > 0 if pages under this cgroup are moving to other cgroup.
 	 */
@@ -381,36 +373,10 @@ static inline void memcg_dangling_free(struct mem_cgroup *memcg)
 	mutex_lock(&dangling_memcgs_mutex);
 	list_del(&memcg->dead);
 	mutex_unlock(&dangling_memcgs_mutex);
-	free_pages((unsigned long)memcg->memcg_name, 0);
 }
 
 static inline void memcg_dangling_add(struct mem_cgroup *memcg)
 {
-	/*
-	 * cgroup.c will do page-sized allocations most of the time,
-	 * so we'll just follow the pattern. Also, __get_free_pages
-	 * is a better interface than kmalloc for us here, because
-	 * we'd like this memory to be always billed to the root cgroup,
-	 * not to the process removing the memcg. While kmalloc would
-	 * require us to wrap it into memcg_stop/resume_kmem_account,
-	 * with __get_free_pages we just don't pass the memcg flag.
-	 */
-	memcg->memcg_name = (char *)__get_free_pages(GFP_KERNEL, 0);
-
-	/*
-	 * we will, in general, just ignore failures. No need to go crazy,
-	 * being this just a debugging interface. It is nice to copy a memcg
-	 * name over, but if we (unlikely) can't, just the address will do
-	 */
-	if (!memcg->memcg_name)
-		goto add_list;
-
-	if (cgroup_path(memcg->css.cgroup, memcg->memcg_name, PAGE_SIZE) < 0) {
-		free_pages((unsigned long)memcg->memcg_name, 0);
-		memcg->memcg_name = NULL;
-	}
-
-add_list:
 	INIT_LIST_HEAD(&memcg->dead);
 	mutex_lock(&dangling_memcgs_mutex);
 	list_add(&memcg->dead, &dangling_memcgs);
@@ -5188,12 +5154,28 @@ static int mem_cgroup_dangling_read(struct cgroup *cont, struct cftype *cft,
 					struct seq_file *m)
 {
 	struct mem_cgroup *memcg;
+	char *memcg_name;
+	int ret;
+
+	/*
+	 * cgroup.c will do page-sized allocations most of the time,
+	 * so we'll just follow the pattern. Also, __get_free_pages
+	 * is a better interface than kmalloc for us here, because
+	 * we'd like this memory to be always billed to the root cgroup,
+	 * not to the process removing the memcg. While kmalloc would
+	 * require us to wrap it into memcg_stop/resume_kmem_account,
+	 * with __get_free_pages we just don't pass the memcg flag.
+	 */
+	memcg_name = (char *)__get_free_pages(GFP_KERNEL, 0);
+	if (!memcg_name)
+		return -ENOMEM;
 
 	mutex_lock(&dangling_memcgs_mutex);
 
 	list_for_each_entry(memcg, &dangling_memcgs, dead) {
-		if (memcg->memcg_name)
-			seq_printf(m, "%s:\n", memcg->memcg_name);
+		ret = cgroup_path(memcg->css.cgroup, memcg_name, PAGE_SIZE);
+		if (!ret)
+			seq_printf(m, "%s:\n", memcg_name);
 		else
 			seq_printf(m, "%p (name lost):\n", memcg);
 
@@ -5203,6 +5185,7 @@ static int mem_cgroup_dangling_read(struct cgroup *cont, struct cftype *cft,
 	}
 
 	mutex_unlock(&dangling_memcgs_mutex);
+	free_pages((unsigned long)memcg_name, 0);
 	return 0;
 }
 #endif
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
