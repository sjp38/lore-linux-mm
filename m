Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id D82926B0260
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 11:06:56 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 93so122763707qtg.1
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 08:06:56 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id fd4si20386536wjb.204.2016.08.15.08.06.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Aug 2016 08:06:55 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id i138so11529604wmf.3
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 08:06:55 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH stable-4.4 1/3] mm: memcontrol: fix cgroup creation failure after many small jobs
Date: Mon, 15 Aug 2016 17:06:44 +0200
Message-Id: <1471273606-15392-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1471273606-15392-1-git-send-email-mhocko@kernel.org>
References: <1471273606-15392-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable tree <stable@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Nikolay Borisov <kernel@kyup.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

From: Johannes Weiner <hannes@cmpxchg.org>

commit 73f576c04b9410ed19660f74f97521bee6e1c546 upstream.

The memory controller has quite a bit of state that usually outlives the
cgroup and pins its CSS until said state disappears.  At the same time
it imposes a 16-bit limit on the CSS ID space to economically store IDs
in the wild.  Consequently, when we use cgroups to contain frequent but
small and short-lived jobs that leave behind some page cache, we quickly
run into the 64k limitations of outstanding CSSs.  Creating a new cgroup
fails with -ENOSPC while there are only a few, or even no user-visible
cgroups in existence.

Although pinning CSSs past cgroup removal is common, there are only two
instances that actually need an ID after a cgroup is deleted: cache
shadow entries and swapout records.

Cache shadow entries reference the ID weakly and can deal with the CSS
having disappeared when it's looked up later.  They pose no hurdle.

Swap-out records do need to pin the css to hierarchically attribute
swapins after the cgroup has been deleted; though the only pages that
remain swapped out after offlining are tmpfs/shmem pages.  And those
references are under the user's control, so they are manageable.

This patch introduces a private 16-bit memcg ID and switches swap and
cache shadow entries over to using that.  This ID can then be recycled
after offlining when the CSS remains pinned only by objects that don't
specifically need it.

This script demonstrates the problem by faulting one cache page in a new
cgroup and deleting it again:

  set -e
  mkdir -p pages
  for x in `seq 128000`; do
    [ $((x % 1000)) -eq 0 ] && echo $x
    mkdir /cgroup/foo
    echo $$ >/cgroup/foo/cgroup.procs
    echo trex >pages/$x
    echo $$ >/cgroup/cgroup.procs
    rmdir /cgroup/foo
  done

When run on an unpatched kernel, we eventually run out of possible IDs
even though there are no visible cgroups:

  [root@ham ~]# ./cssidstress.sh
  [...]
  65000
  mkdir: cannot create directory '/cgroup/foo': No space left on device

After this patch, the IDs get released upon cgroup destruction and the
cache and css objects get released once memory reclaim kicks in.

[hannes@cmpxchg.org: init the IDR]
  Link: http://lkml.kernel.org/r/20160621154601.GA22431@cmpxchg.org
Fixes: b2052564e66d ("mm: memcontrol: continue cache reclaim from offlined groups")
Link: http://lkml.kernel.org/r/20160617162516.GD19084@cmpxchg.org
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reported-by: John Garcia <john.garcia@mesosphere.io>
Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Acked-by: Tejun Heo <tj@kernel.org>
Cc: Nikolay Borisov <kernel@kyup.com>
Cc: <stable@vger.kernel.org>	[3.19+]
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/memcontrol.h |  8 ++++
 mm/memcontrol.c            | 93 ++++++++++++++++++++++++++++++++++++----------
 mm/slab_common.c           |  2 +-
 3 files changed, 83 insertions(+), 20 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index cd0e2413c358..435fd8426b8a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -174,6 +174,11 @@ struct mem_cgroup_thresholds {
 	struct mem_cgroup_threshold_ary *spare;
 };
 
+struct mem_cgroup_id {
+	int id;
+	atomic_t ref;
+};
+
 /*
  * The memory controller data structure. The memory controller controls both
  * page cache and RSS per cgroup. We would eventually like to provide
@@ -183,6 +188,9 @@ struct mem_cgroup_thresholds {
 struct mem_cgroup {
 	struct cgroup_subsys_state css;
 
+	/* Private memcg ID. Used to ID objects that outlive the cgroup */
+	struct mem_cgroup_id id;
+
 	/* Accounted resources */
 	struct page_counter memory;
 	struct page_counter memsw;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 67648e6b2ac8..2c11422f0519 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -272,21 +272,7 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
 
 static inline unsigned short mem_cgroup_id(struct mem_cgroup *memcg)
 {
-	return memcg->css.id;
-}
-
-/*
- * A helper function to get mem_cgroup from ID. must be called under
- * rcu_read_lock().  The caller is responsible for calling
- * css_tryget_online() if the mem_cgroup is used for charging. (dropping
- * refcnt from swap can be called against removed memcg.)
- */
-static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
-{
-	struct cgroup_subsys_state *css;
-
-	css = css_from_id(id, &memory_cgrp_subsys);
-	return mem_cgroup_from_css(css);
+	return memcg->id.id;
 }
 
 /* Writing them here to avoid exposing memcg's inner layout */
@@ -4124,6 +4110,60 @@ static struct cftype mem_cgroup_legacy_files[] = {
 	{ },	/* terminate */
 };
 
+/*
+ * Private memory cgroup IDR
+ *
+ * Swap-out records and page cache shadow entries need to store memcg
+ * references in constrained space, so we maintain an ID space that is
+ * limited to 16 bit (MEM_CGROUP_ID_MAX), limiting the total number of
+ * memory-controlled cgroups to 64k.
+ *
+ * However, there usually are many references to the oflline CSS after
+ * the cgroup has been destroyed, such as page cache or reclaimable
+ * slab objects, that don't need to hang on to the ID. We want to keep
+ * those dead CSS from occupying IDs, or we might quickly exhaust the
+ * relatively small ID space and prevent the creation of new cgroups
+ * even when there are much fewer than 64k cgroups - possibly none.
+ *
+ * Maintain a private 16-bit ID space for memcg, and allow the ID to
+ * be freed and recycled when it's no longer needed, which is usually
+ * when the CSS is offlined.
+ *
+ * The only exception to that are records of swapped out tmpfs/shmem
+ * pages that need to be attributed to live ancestors on swapin. But
+ * those references are manageable from userspace.
+ */
+
+static DEFINE_IDR(mem_cgroup_idr);
+
+static void mem_cgroup_id_get(struct mem_cgroup *memcg)
+{
+	atomic_inc(&memcg->id.ref);
+}
+
+static void mem_cgroup_id_put(struct mem_cgroup *memcg)
+{
+	if (atomic_dec_and_test(&memcg->id.ref)) {
+		idr_remove(&mem_cgroup_idr, memcg->id.id);
+		memcg->id.id = 0;
+
+		/* Memcg ID pins CSS */
+		css_put(&memcg->css);
+	}
+}
+
+/**
+ * mem_cgroup_from_id - look up a memcg from a memcg id
+ * @id: the memcg id to look up
+ *
+ * Caller must hold rcu_read_lock().
+ */
+struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
+{
+	WARN_ON_ONCE(!rcu_read_lock_held());
+	return idr_find(&mem_cgroup_idr, id);
+}
+
 static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 {
 	struct mem_cgroup_per_node *pn;
@@ -4173,11 +4213,17 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 
 	memcg->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
 	if (!memcg->stat)
-		goto out_free;
+		goto out_idr;
 
 	if (memcg_wb_domain_init(memcg, GFP_KERNEL))
 		goto out_free_stat;
 
+	memcg->id.id = idr_alloc(&mem_cgroup_idr, NULL,
+				 1, MEM_CGROUP_ID_MAX,
+				 GFP_KERNEL);
+	if (memcg->id.id < 0)
+		goto out_free_stat;
+
 	return memcg;
 
 out_free_stat:
@@ -4263,9 +4309,11 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 #ifdef CONFIG_CGROUP_WRITEBACK
 	INIT_LIST_HEAD(&memcg->cgwb_list);
 #endif
+	idr_replace(&mem_cgroup_idr, memcg, memcg->id.id);
 	return &memcg->css;
 
 free_out:
+	idr_remove(&mem_cgroup_idr, memcg->id.id);
 	__mem_cgroup_free(memcg);
 	return ERR_PTR(error);
 }
@@ -4277,8 +4325,9 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	struct mem_cgroup *parent = mem_cgroup_from_css(css->parent);
 	int ret;
 
-	if (css->id > MEM_CGROUP_ID_MAX)
-		return -ENOSPC;
+	/* Online state pins memcg ID, memcg ID pins CSS */
+	mem_cgroup_id_get(mem_cgroup_from_css(css));
+	css_get(css);
 
 	if (!parent)
 		return 0;
@@ -4352,6 +4401,8 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	memcg_deactivate_kmem(memcg);
 
 	wb_memcg_offline(memcg);
+
+	mem_cgroup_id_put(memcg);
 }
 
 static void mem_cgroup_css_released(struct cgroup_subsys_state *css)
@@ -5685,6 +5736,7 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	if (!memcg)
 		return;
 
+	mem_cgroup_id_get(memcg);
 	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
 	VM_BUG_ON_PAGE(oldid, page);
 	mem_cgroup_swap_statistics(memcg, true);
@@ -5703,6 +5755,9 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	VM_BUG_ON(!irqs_disabled());
 	mem_cgroup_charge_statistics(memcg, page, -1);
 	memcg_check_events(memcg, page);
+
+	if (!mem_cgroup_is_root(memcg))
+		css_put(&memcg->css);
 }
 
 /**
@@ -5726,7 +5781,7 @@ void mem_cgroup_uncharge_swap(swp_entry_t entry)
 		if (!mem_cgroup_is_root(memcg))
 			page_counter_uncharge(&memcg->memsw, 1);
 		mem_cgroup_swap_statistics(memcg, false);
-		css_put(&memcg->css);
+		mem_cgroup_id_put(memcg);
 	}
 	rcu_read_unlock();
 }
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 3c6a86b4ec25..312ef6f7b7b1 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -522,7 +522,7 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 
 	cgroup_name(css->cgroup, memcg_name_buf, sizeof(memcg_name_buf));
 	cache_name = kasprintf(GFP_KERNEL, "%s(%d:%s)", root_cache->name,
-			       css->id, memcg_name_buf);
+			       css->serial_nr, memcg_name_buf);
 	if (!cache_name)
 		goto out_unlock;
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
