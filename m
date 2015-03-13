Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 314428299B
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 10:57:36 -0400 (EDT)
Received: by padfa1 with SMTP id fa1so30076702pad.9
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 07:57:35 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ta8si4474715pac.175.2015.03.13.07.57.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 07:57:35 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm] memcg: zap mem_cgroup_lookup
Date: Fri, 13 Mar 2015 17:57:22 +0300
Message-ID: <1426258642-14074-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

mem_cgroup_lookup is a wrapper around mem_cgroup_from_id, which checks
that id != 0 before issuing the function call. Today, there is no point
in this additional check apart from optimization, because there is no
css with id <= 0, so that css_from_id, called by mem_cgroup_from_id,
will return NULL for any id <= 0. Since mem_cgroup_from_id is only
called from mem_cgroup_lookup, let us zap mem_cgroup_lookup,
substituting calls to it with mem_cgroup_from_id and moving the check if
id > 0 to css_from_id.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 kernel/cgroup.c |    2 +-
 mm/memcontrol.c |   24 ++++++++----------------
 2 files changed, 9 insertions(+), 17 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 29a7b2cc593e..747e953ffee9 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -5451,7 +5451,7 @@ struct cgroup_subsys_state *css_tryget_online_from_dir(struct dentry *dentry,
 struct cgroup_subsys_state *css_from_id(int id, struct cgroup_subsys *ss)
 {
 	WARN_ON_ONCE(!rcu_read_lock_held());
-	return idr_find(&ss->css_idr, id);
+	return id > 0 ? idr_find(&ss->css_idr, id) : NULL;
 }
 
 #ifdef CONFIG_CGROUP_DEBUG
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d18d3a6e7337..f9df75ef55d7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -454,6 +454,12 @@ static inline unsigned short mem_cgroup_id(struct mem_cgroup *memcg)
 	return memcg->css.id;
 }
 
+/*
+ * A helper function to get mem_cgroup from ID. must be called under
+ * rcu_read_lock().  The caller is responsible for calling
+ * css_tryget_online() if the mem_cgroup is used for charging. (dropping
+ * refcnt from swap can be called against removed memcg.)
+ */
 static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
 {
 	struct cgroup_subsys_state *css;
@@ -2341,20 +2347,6 @@ static void cancel_charge(struct mem_cgroup *memcg, unsigned int nr_pages)
 }
 
 /*
- * A helper function to get mem_cgroup from ID. must be called under
- * rcu_read_lock().  The caller is responsible for calling
- * css_tryget_online() if the mem_cgroup is used for charging. (dropping
- * refcnt from swap can be called against removed memcg.)
- */
-static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
-{
-	/* ID 0 is unused ID */
-	if (!id)
-		return NULL;
-	return mem_cgroup_from_id(id);
-}
-
-/*
  * try_get_mem_cgroup_from_page - look up page's memcg association
  * @page: the page
  *
@@ -2380,7 +2372,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 		ent.val = page_private(page);
 		id = lookup_swap_cgroup_id(ent);
 		rcu_read_lock();
-		memcg = mem_cgroup_lookup(id);
+		memcg = mem_cgroup_from_id(id);
 		if (memcg && !css_tryget_online(&memcg->css))
 			memcg = NULL;
 		rcu_read_unlock();
@@ -5859,7 +5851,7 @@ void mem_cgroup_uncharge_swap(swp_entry_t entry)
 
 	id = swap_cgroup_record(entry, 0);
 	rcu_read_lock();
-	memcg = mem_cgroup_lookup(id);
+	memcg = mem_cgroup_from_id(id);
 	if (memcg) {
 		if (!mem_cgroup_is_root(memcg))
 			page_counter_uncharge(&memcg->memsw, 1);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
