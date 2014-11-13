Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 585616B00DC
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 04:10:56 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id y10so14003766pdj.14
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 01:10:56 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id gh6si25054139pbc.117.2014.11.13.01.10.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Nov 2014 01:10:54 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm] memcg: zap kmem_account_flags
Date: Thu, 13 Nov 2014 12:10:39 +0300
Message-ID: <1415869839-8212-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The only such flag is KMEM_ACCOUNTED_ACTIVE, but it's set iff
mem_cgroup->kmemcg_id is initialized, so we can check kmemcg_id instead
of having a separate flags field.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c |   31 ++++++++++---------------------
 1 file changed, 10 insertions(+), 21 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5a27e224d561..bb8c237026cc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -296,7 +296,6 @@ struct mem_cgroup {
 	 * Should the accounting and control be hierarchical, per subtree?
 	 */
 	bool use_hierarchy;
-	unsigned long kmem_account_flags; /* See KMEM_ACCOUNTED_*, below */
 
 	bool		oom_lock;
 	atomic_t	under_oom;
@@ -366,22 +365,11 @@ struct mem_cgroup {
 	/* WARNING: nodeinfo must be the last member here */
 };
 
-/* internal only representation about the status of kmem accounting. */
-enum {
-	KMEM_ACCOUNTED_ACTIVE, /* accounted by this cgroup itself */
-};
-
 #ifdef CONFIG_MEMCG_KMEM
-static inline void memcg_kmem_set_active(struct mem_cgroup *memcg)
-{
-	set_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
-}
-
 static bool memcg_kmem_is_active(struct mem_cgroup *memcg)
 {
-	return test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
+	return memcg->kmemcg_id >= 0;
 }
-
 #endif
 
 /* Stuffs for move charges at task migration. */
@@ -3564,23 +3552,21 @@ static int memcg_activate_kmem(struct mem_cgroup *memcg,
 		goto out;
 	}
 
-	memcg->kmemcg_id = memcg_id;
-	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
-
 	/*
-	 * We couldn't have accounted to this cgroup, because it hasn't got the
-	 * active bit set yet, so this should succeed.
+	 * We couldn't have accounted to this cgroup, because it hasn't got
+	 * activated yet, so this should succeed.
 	 */
 	err = page_counter_limit(&memcg->kmem, nr_pages);
 	VM_BUG_ON(err);
 
 	static_key_slow_inc(&memcg_kmem_enabled_key);
 	/*
-	 * Setting the active bit after enabling static branching will
+	 * A memory cgroup is considered kmem-active as soon as it gets
+	 * kmemcg_id. Setting the id after enabling static branching will
 	 * guarantee no one starts accounting before all call sites are
 	 * patched.
 	 */
-	memcg_kmem_set_active(memcg);
+	memcg->kmemcg_id = memcg_id;
 out:
 	return err;
 }
@@ -4252,7 +4238,6 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
 	int ret;
 
-	memcg->kmemcg_id = -1;
 	ret = memcg_propagate_kmem(memcg);
 	if (ret)
 		return ret;
@@ -4786,6 +4771,10 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 	vmpressure_init(&memcg->vmpressure);
 	INIT_LIST_HEAD(&memcg->event_list);
 	spin_lock_init(&memcg->event_list_lock);
+#ifdef CONFIG_MEMCG_KMEM
+	memcg->kmemcg_id = -1;
+	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
+#endif
 
 	return &memcg->css;
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
