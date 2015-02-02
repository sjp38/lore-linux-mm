Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4E93E6B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 07:34:27 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id rd3so81830674pab.3
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 04:34:27 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id hv5si23417408pbc.115.2015.02.02.04.34.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Feb 2015 04:34:26 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC -mm] memcg: drop per cgroup kmem accounting configuration
Date: Mon, 2 Feb 2015 15:34:17 +0300
Message-ID: <1422880457-18942-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org

Currently, to enable kmem accounting for a cgroup, one has to set
kmem.limit_in_bytes for it, otherwise the cgroup will not have kmem
accounting enabled. This means we can configure kmem accounting for a
subset of cgroups, while leaving it disabled for the rest.

However, a separate knob for tuning kmem limit is likely to be dropped
in the unified hierarchy, because:

 - in contrast to memory or swap, kmem is not a resource and therefore
   there is no point in limiting it separately (at least, this is true
   for architectures without low/high memory division, which constitute
   the absolute majority on the server market nowadays)

 - kmem and page cache are interconnected - sometimes you cannot reclaim
   one without touching the other (e.g. buffer heads are accounted to
   kmem, but can only be dropped by page cache reclaim); therefore it is
   not clear how to implement kmem-only reclaim

 - though flexible it is, the user interface looks awkward - to enable
   kmem accounting you have to write something to kmem.limit_in_bytes;
   most users want to write -1, although it equals -1 by default

So we have to decide how to change the kmem accounting configuration
scheme to make it compatible with the unified hierarchy.

There are basically two options: either we continue to support per
cgroup kmem accounting configuration, or we drop it in favor of
system-wide setup.

The level of flexibility which per cgroup kmem configuration provides
does not look useful to me. I think most users will either need to
enable kmem accounting for all cgroups if they want security or disable
it altogether if they want performance and can trust their cgroups. So I
propose to move to system-wide setup similar to that the swap extension
provides.

This patch therefore introduces a new config option, MEMCG_KMEM_ENABLED,
and a new boot parameter, kmemaccount, which function exactly as
MEMCG_SWAP_ENABLED and swapaccount except they enable system-wide kmem
accounting rather than swap. With MEMCG_KMEM_ENABLED unset or
kmemaccount=0, there will be neither kmem accounting support nor per
cgroup tunables and hence no overhead, otherwise kmem accounting will be
enabled for all cgroups except the root. Even if kmem accounting is
enabled, there still will be no runtime overhead until memory cgroup is
actually used, thanks to the memcg_kmem_enabled static key.

MEMCG_KMEM_ENABLED is unset by default, because the implementation of
kmem accounting is still unstable.

Note, this patch does not affect the sockets memory accounting part of
the kmem extension: memory.kmem.tcp.* knobs are still available
irrespective of the value of kmemaccount, and skb memory pressure
control is enabled per cgroup upon the first write to
memory.kmem.tcp.limit_in_bytes. I don't think we need these knobs at
all. We might want skb to contribute to memory.kmem though, which is not
the case now.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/net/sock.h |    2 +-
 init/Kconfig       |   13 +++++
 mm/memcontrol.c    |  149 +++++++++++++++++++---------------------------------
 3 files changed, 68 insertions(+), 96 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 28bdf874da4a..bed8ce0ac48b 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -71,7 +71,7 @@
 
 struct cgroup;
 struct cgroup_subsys;
-#ifdef CONFIG_NET
+#if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
 int mem_cgroup_sockets_init(struct mem_cgroup *memcg, struct cgroup_subsys *ss);
 void mem_cgroup_sockets_destroy(struct mem_cgroup *memcg);
 #else
diff --git a/init/Kconfig b/init/Kconfig
index 826aacc7399b..9989601f7d6c 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1037,6 +1037,19 @@ config MEMCG_KMEM
 	  are plenty of kmem available for reclaim. That makes this option
 	  unusable in real life so DO NOT SELECT IT unless for development
 	  purposes.
+config MEMCG_KMEM_ENABLED
+	bool "Memory Resource Controller Kernel Memory accounting enabled by default"
+	depends on MEMCG_KMEM
+	default n
+	help
+	  Memory Resource Controller Kernel Memory accounting comes with its
+	  price in a bigger memory consumption and runtime overhead. General
+	  purpose distribution kernels which want to enable the feature but
+	  keep it disabled by default and let the user enable it by
+	  kmemaccount=1 boot command line parameter should have this option
+	  unselected. For those who want to have the feature enabled by default
+	  should select this option (if, for some reason, they need to disable
+	  it then kmemaccount=0 does the trick).
 
 config CGROUP_HUGETLB
 	bool "HugeTLB Resource Controller for Control Groups"
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f1ab93daa1b7..c3a18a5fe86c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -334,7 +334,6 @@ struct mem_cgroup {
 #if defined(CONFIG_MEMCG_KMEM)
         /* Index in the kmem_cache->memcg_params.memcg_caches array */
 	int kmemcg_id;
-	bool kmem_acct_activated;
 	bool kmem_acct_active;
 #endif
 
@@ -3282,92 +3281,13 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
 }
 
 #ifdef CONFIG_MEMCG_KMEM
-static int memcg_activate_kmem(struct mem_cgroup *memcg,
-			       unsigned long nr_pages)
-{
-	int err = 0;
-	int memcg_id;
-
-	BUG_ON(memcg->kmemcg_id >= 0);
-	BUG_ON(memcg->kmem_acct_activated);
-	BUG_ON(memcg->kmem_acct_active);
-
-	/*
-	 * For simplicity, we won't allow this to be disabled.  It also can't
-	 * be changed if the cgroup has children already, or if tasks had
-	 * already joined.
-	 *
-	 * If tasks join before we set the limit, a person looking at
-	 * kmem.usage_in_bytes will have no way to determine when it took
-	 * place, which makes the value quite meaningless.
-	 *
-	 * After it first became limited, changes in the value of the limit are
-	 * of course permitted.
-	 */
-	mutex_lock(&memcg_create_mutex);
-	if (cgroup_has_tasks(memcg->css.cgroup) ||
-	    (memcg->use_hierarchy && memcg_has_children(memcg)))
-		err = -EBUSY;
-	mutex_unlock(&memcg_create_mutex);
-	if (err)
-		goto out;
-
-	memcg_id = memcg_alloc_cache_id();
-	if (memcg_id < 0) {
-		err = memcg_id;
-		goto out;
-	}
-
-	/*
-	 * We couldn't have accounted to this cgroup, because it hasn't got
-	 * activated yet, so this should succeed.
-	 */
-	err = page_counter_limit(&memcg->kmem, nr_pages);
-	VM_BUG_ON(err);
-
-	static_key_slow_inc(&memcg_kmem_enabled_key);
-	/*
-	 * A memory cgroup is considered kmem-active as soon as it gets
-	 * kmemcg_id. Setting the id after enabling static branching will
-	 * guarantee no one starts accounting before all call sites are
-	 * patched.
-	 */
-	memcg->kmemcg_id = memcg_id;
-	memcg->kmem_acct_activated = true;
-	memcg->kmem_acct_active = true;
-out:
-	return err;
-}
-
 static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
 				   unsigned long limit)
 {
 	int ret;
 
 	mutex_lock(&memcg_limit_mutex);
-	if (!memcg_kmem_is_active(memcg))
-		ret = memcg_activate_kmem(memcg, limit);
-	else
-		ret = page_counter_limit(&memcg->kmem, limit);
-	mutex_unlock(&memcg_limit_mutex);
-	return ret;
-}
-
-static int memcg_propagate_kmem(struct mem_cgroup *memcg)
-{
-	int ret = 0;
-	struct mem_cgroup *parent = parent_mem_cgroup(memcg);
-
-	if (!parent)
-		return 0;
-
-	mutex_lock(&memcg_limit_mutex);
-	/*
-	 * If the parent cgroup is not kmem-active now, it cannot be activated
-	 * after this point, because it has at least one child already.
-	 */
-	if (memcg_kmem_is_active(parent))
-		ret = memcg_activate_kmem(memcg, PAGE_COUNTER_MAX);
+	ret = page_counter_limit(&memcg->kmem, limit);
 	mutex_unlock(&memcg_limit_mutex);
 	return ret;
 }
@@ -4003,15 +3923,34 @@ static int mem_cgroup_oom_control_write(struct cgroup_subsys_state *css,
 }
 
 #ifdef CONFIG_MEMCG_KMEM
-static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
+static int do_kmem_account = IS_ENABLED(CONFIG_MEMCG_KMEM_ENABLED);
+
+static int __init enable_kmem_account(char *s)
 {
-	int ret;
+	if (!strcmp(s, "1"))
+		do_kmem_account = 1;
+	else if (!strcmp(s, "0"))
+		do_kmem_account = 0;
+	return 1;
+}
+__setup("kmemaccount=", enable_kmem_account);
 
-	ret = memcg_propagate_kmem(memcg);
-	if (ret)
-		return ret;
+static int memcg_init_kmem(struct mem_cgroup *memcg)
+{
+	int idx;
+
+	if (!do_kmem_account || mem_cgroup_is_root(memcg))
+		return 0;
+
+	idx = memcg_alloc_cache_id();
+	if (idx < 0)
+		return idx;
 
-	return mem_cgroup_sockets_init(memcg, ss);
+	memcg->kmemcg_id = idx;
+	memcg->kmem_acct_active = true;
+
+	static_key_slow_inc(&memcg_kmem_enabled_key);
+	return 0;
 }
 
 static void memcg_deactivate_kmem(struct mem_cgroup *memcg)
@@ -4062,12 +4001,12 @@ static void memcg_deactivate_kmem(struct mem_cgroup *memcg)
 
 static void memcg_destroy_kmem(struct mem_cgroup *memcg)
 {
-	if (memcg->kmem_acct_activated) {
-		memcg_destroy_kmem_caches(memcg);
-		static_key_slow_dec(&memcg_kmem_enabled_key);
-		WARN_ON(page_counter_read(&memcg->kmem));
-	}
-	mem_cgroup_sockets_destroy(memcg);
+	if (!do_kmem_account || mem_cgroup_is_root(memcg))
+		return;
+
+	memcg_destroy_kmem_caches(memcg);
+	static_key_slow_dec(&memcg_kmem_enabled_key);
+	WARN_ON(page_counter_read(&memcg->kmem));
 }
 #else
 static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
@@ -4381,7 +4320,11 @@ static struct cftype mem_cgroup_legacy_files[] = {
 		.seq_show = memcg_numa_stat_show,
 	},
 #endif
+	{ },	/* terminate */
+};
+
 #ifdef CONFIG_MEMCG_KMEM
+static struct cftype mem_cgroup_kmem_files[] = {
 	{
 		.name = "kmem.limit_in_bytes",
 		.private = MEMFILE_PRIVATE(_KMEM, RES_LIMIT),
@@ -4414,10 +4357,19 @@ static struct cftype mem_cgroup_legacy_files[] = {
 		.seq_show = memcg_slab_show,
 	},
 #endif
-#endif
 	{ },	/* terminate */
 };
 
+static int __init mem_cgroup_kmem_init(void)
+{
+	if (!mem_cgroup_disabled() && do_kmem_account)
+		WARN_ON(cgroup_add_legacy_cftypes(&memory_cgrp_subsys,
+						  mem_cgroup_kmem_files));
+	return 0;
+}
+subsys_initcall(mem_cgroup_kmem_init);
+#endif /* CONFIG_MEMCG_KMEM */
+
 static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 {
 	struct mem_cgroup_per_node *pn;
@@ -4601,10 +4553,16 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	}
 	mutex_unlock(&memcg_create_mutex);
 
-	ret = memcg_init_kmem(memcg, &memory_cgrp_subsys);
+	ret = mem_cgroup_sockets_init(memcg, &memory_cgrp_subsys);
 	if (ret)
 		return ret;
 
+	ret = memcg_init_kmem(memcg);
+	if (ret) {
+		mem_cgroup_sockets_destroy(memcg);
+		return ret;
+	}
+
 	/*
 	 * Make sure the memcg is initialized: mem_cgroup_iter()
 	 * orders reading memcg->initialized against its callers
@@ -4642,6 +4600,7 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
 	memcg_destroy_kmem(memcg);
+	mem_cgroup_sockets_destroy(memcg);
 	__mem_cgroup_free(memcg);
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
