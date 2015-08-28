Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id C4F036B0254
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 18:02:40 -0400 (EDT)
Received: by ykek5 with SMTP id k5so15298528yke.3
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 15:02:40 -0700 (PDT)
Received: from mail-yk0-x235.google.com (mail-yk0-x235.google.com. [2607:f8b0:4002:c07::235])
        by mx.google.com with ESMTPS id r62si4957348ywe.153.2015.08.28.15.02.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 15:02:39 -0700 (PDT)
Received: by ykba134 with SMTP id a134so16193369ykb.1
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 15:02:39 -0700 (PDT)
Date: Fri, 28 Aug 2015 18:02:37 -0400
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 2/2] memcg: always enable kmemcg on the default hierarchy
Message-ID: <20150828220237.GE11089@htj.dyndns.org>
References: <20150828220158.GD11089@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150828220158.GD11089@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

On the default hierarchy, all memory consumption will be accounted
together and controlled by the same set of limits.  Enable kmemcg on
the default hierarchy by default.  Boot parameter "disable_kmemcg" can
be specified to turn it off.

v2: - v1 triggered oops on nested cgroup creations.  Moved enabling
      mechanism to memcg_propagate_kmem().
    - Bypass busy test on kmem activation as it's unnecessary and gets
      confused by controller being enabled on a cgroup which already
      has processes.
    - "disable_kmemcg" boot param added.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 mm/memcontrol.c |   43 ++++++++++++++++++++++++++++++-------------
 1 file changed, 30 insertions(+), 13 deletions(-)

--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -346,6 +346,17 @@ EXPORT_SYMBOL(tcp_proto_cgroup);
 #endif
 
 #ifdef CONFIG_MEMCG_KMEM
+
+static bool kmemcg_disabled;
+
+static int __init disable_kmemcg(char *s)
+{
+	kmemcg_disabled = true;
+	pr_info("memcg: kernel memory support disabled on cgroup2");
+	return 0;
+}
+__setup("disable_kmemcg", disable_kmemcg);
+
 /*
  * This will be the memcg's index in each cache's ->memcg_params.memcg_caches.
  * The main reason for not using cgroup id for this:
@@ -2908,9 +2919,9 @@ static int memcg_activate_kmem(struct me
 	BUG_ON(memcg->kmem_acct_active);
 
 	/*
-	 * For simplicity, we won't allow this to be disabled.  It also can't
-	 * be changed if the cgroup has children already, or if tasks had
-	 * already joined.
+	 * On traditional hierarchies, for simplicity, we won't allow this
+	 * to be disabled.  It also can't be changed if the cgroup has
+	 * children already, or if tasks had already joined.
 	 *
 	 * If tasks join before we set the limit, a person looking at
 	 * kmem.usage_in_bytes will have no way to determine when it took
@@ -2919,13 +2930,15 @@ static int memcg_activate_kmem(struct me
 	 * After it first became limited, changes in the value of the limit are
 	 * of course permitted.
 	 */
-	mutex_lock(&memcg_create_mutex);
-	if (cgroup_has_tasks(memcg->css.cgroup) ||
-	    (memcg->use_hierarchy && memcg_has_children(memcg)))
-		err = -EBUSY;
-	mutex_unlock(&memcg_create_mutex);
-	if (err)
-		goto out;
+	if (!cgroup_on_dfl(memcg->css.cgroup)) {
+		mutex_lock(&memcg_create_mutex);
+		if (cgroup_has_tasks(memcg->css.cgroup) ||
+		    (memcg->use_hierarchy && memcg_has_children(memcg)))
+			err = -EBUSY;
+		mutex_unlock(&memcg_create_mutex);
+		if (err)
+			goto out;
+	}
 
 	memcg_id = memcg_alloc_cache_id();
 	if (memcg_id < 0) {
@@ -2978,10 +2991,14 @@ static int memcg_propagate_kmem(struct m
 
 	mutex_lock(&memcg_limit_mutex);
 	/*
-	 * If the parent cgroup is not kmem-active now, it cannot be activated
-	 * after this point, because it has at least one child already.
+	 * On the default hierarchy, automatically enable kmemcg unless
+	 * explicitly disabled by the boot param.  On traditional
+	 * hierarchies, inherit from the parent.  If the parent cgroup is
+	 * not kmem-active now, it cannot be activated after this point,
+	 * because it has at least one child already.
 	 */
-	if (memcg_kmem_is_active(parent))
+	if ((!kmemcg_disabled && cgroup_on_dfl(memcg->css.cgroup)) ||
+	    memcg_kmem_is_active(parent))
 		ret = memcg_activate_kmem(memcg, PAGE_COUNTER_MAX);
 	mutex_unlock(&memcg_limit_mutex);
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
