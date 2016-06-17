Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id CE7276B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 12:27:44 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id a4so1852315lfa.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 09:27:44 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p203si232174wmg.104.2016.06.17.09.27.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 09:27:43 -0700 (PDT)
Date: Fri, 17 Jun 2016 12:25:16 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 3/3] mm: memcontrol: fix cgroup creation failure after many
 small jobs
Message-ID: <20160617162516.GD19084@cmpxchg.org>
References: <20160616034244.14839-1-hannes@cmpxchg.org>
 <20160616200617.GD3262@mtj.duckdns.org>
 <20160617162310.GA19084@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160617162310.GA19084@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

The memory controller has quite a bit of state that usually outlives
the cgroup and pins its CSS until said state disappears. At the same
time it imposes a 16-bit limit on the CSS ID space to economically
store IDs in the wild. Consequently, when we use cgroups to contain
frequent but small and short-lived jobs that leave behind some page
cache, we quickly run into the 64k limitations of outstanding CSSs.
Creating a new cgroup fails with -ENOSPC while there are only a few,
or even no user-visible cgroups in existence.

Although pinning CSSs past cgroup removal is common, there are only
two instances that actually need an ID after a cgroup is deleted:
cache shadow entries and swapout records.

Cache shadow entries reference the ID weakly and can deal with the CSS
having disappeared when it's looked up later. They pose no hurdle.

Swap-out records do need to pin the css to hierarchically attribute
swapins after the cgroup has been deleted; though the only pages that
remain swapped out after offlining are tmpfs/shmem pages. And those
references are under the user's control, so they are manageable.

This patch introduces a private 16-bit memcg ID and switches swap and
cache shadow entries over to using that. This ID can then be recycled
after offlining when the CSS remains pinned only by objects that don't
specifically need it.

This script demonstrates the problem by faulting one cache page in a
new cgroup and deleting it again:

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

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 25 ++++++--------
 mm/memcontrol.c            | 82 ++++++++++++++++++++++++++++++++++++++++++----
 mm/slab_common.c           |  4 +--
 3 files changed, 87 insertions(+), 24 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index a805474df4ab..56e6069d2452 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -97,6 +97,11 @@ enum mem_cgroup_events_target {
 #define MEM_CGROUP_ID_SHIFT	16
 #define MEM_CGROUP_ID_MAX	USHRT_MAX
 
+struct mem_cgroup_id {
+	int id;
+	atomic_t ref;
+};
+
 struct mem_cgroup_stat_cpu {
 	long count[MEMCG_NR_STAT];
 	unsigned long events[MEMCG_NR_EVENTS];
@@ -172,6 +177,9 @@ enum memcg_kmem_state {
 struct mem_cgroup {
 	struct cgroup_subsys_state css;
 
+	/* Private memcg ID. Used to ID objects that outlive the cgroup */
+	struct mem_cgroup_id id;
+
 	/* Accounted resources */
 	struct page_counter memory;
 	struct page_counter swap;
@@ -330,22 +338,9 @@ static inline unsigned short mem_cgroup_id(struct mem_cgroup *memcg)
 	if (mem_cgroup_disabled())
 		return 0;
 
-	return memcg->css.id;
-}
-
-/**
- * mem_cgroup_from_id - look up a memcg from an id
- * @id: the id to look up
- *
- * Caller must hold rcu_read_lock() and use css_tryget() as necessary.
- */
-static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
-{
-	struct cgroup_subsys_state *css;
-
-	css = css_from_id(id, &memory_cgrp_subsys);
-	return mem_cgroup_from_css(css);
+	return memcg->id.id;
 }
+struct mem_cgroup *mem_cgroup_from_id(unsigned short id);
 
 /**
  * parent_mem_cgroup - find the accounting parent of a memcg
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 75e74408cc8f..dc92b2df2585 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4057,6 +4057,60 @@ static struct cftype mem_cgroup_legacy_files[] = {
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
+static struct idr mem_cgroup_idr;
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
@@ -4116,6 +4170,12 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	if (!memcg)
 		return NULL;
 
+	memcg->id.id = idr_alloc(&mem_cgroup_idr, NULL,
+				 1, MEM_CGROUP_ID_MAX,
+				 GFP_KERNEL);
+	if (memcg->id.id < 0)
+		goto fail;
+
 	memcg->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
 	if (!memcg->stat)
 		goto fail;
@@ -4142,8 +4202,11 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 #ifdef CONFIG_CGROUP_WRITEBACK
 	INIT_LIST_HEAD(&memcg->cgwb_list);
 #endif
+	idr_replace(&mem_cgroup_idr, memcg, memcg->id.id);
 	return memcg;
 fail:
+	if (memcg->id.id > 0)
+		idr_remove(&mem_cgroup_idr, memcg->id.id);
 	mem_cgroup_free(memcg);
 	return NULL;
 }
@@ -4206,12 +4269,11 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 	return NULL;
 }
 
-static int
-mem_cgroup_css_online(struct cgroup_subsys_state *css)
+static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
 {
-	if (css->id > MEM_CGROUP_ID_MAX)
-		return -ENOSPC;
-
+	/* Online state pins memcg ID, memcg ID pins CSS */
+	mem_cgroup_id_get(mem_cgroup_from_css(css));
+	css_get(css);
 	return 0;
 }
 
@@ -4234,6 +4296,8 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 
 	memcg_offline_kmem(memcg);
 	wb_memcg_offline(memcg);
+
+	mem_cgroup_id_put(memcg);
 }
 
 static void mem_cgroup_css_released(struct cgroup_subsys_state *css)
@@ -5755,6 +5819,7 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	if (!memcg)
 		return;
 
+	mem_cgroup_id_get(memcg);
 	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
 	VM_BUG_ON_PAGE(oldid, page);
 	mem_cgroup_swap_statistics(memcg, true);
@@ -5773,6 +5838,9 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	VM_BUG_ON(!irqs_disabled());
 	mem_cgroup_charge_statistics(memcg, page, false, -1);
 	memcg_check_events(memcg, page);
+
+	if (!mem_cgroup_is_root(memcg))
+		css_put(&memcg->css);
 }
 
 /*
@@ -5803,11 +5871,11 @@ int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry)
 	    !page_counter_try_charge(&memcg->swap, 1, &counter))
 		return -ENOMEM;
 
+	mem_cgroup_id_get(memcg);
 	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
 	VM_BUG_ON_PAGE(oldid, page);
 	mem_cgroup_swap_statistics(memcg, true);
 
-	css_get(&memcg->css);
 	return 0;
 }
 
@@ -5836,7 +5904,7 @@ void mem_cgroup_uncharge_swap(swp_entry_t entry)
 				page_counter_uncharge(&memcg->memsw, 1);
 		}
 		mem_cgroup_swap_statistics(memcg, false);
-		css_put(&memcg->css);
+		mem_cgroup_id_put(memcg);
 	}
 	rcu_read_unlock();
 }
diff --git a/mm/slab_common.c b/mm/slab_common.c
index a65dad7fdcd1..82317abb03ed 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -526,8 +526,8 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 		goto out_unlock;
 
 	cgroup_name(css->cgroup, memcg_name_buf, sizeof(memcg_name_buf));
-	cache_name = kasprintf(GFP_KERNEL, "%s(%d:%s)", root_cache->name,
-			       css->id, memcg_name_buf);
+	cache_name = kasprintf(GFP_KERNEL, "%s(%llu:%s)", root_cache->name,
+			       css->serial_nr, memcg_name_buf);
 	if (!cache_name)
 		goto out_unlock;
 
-- 
2.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
