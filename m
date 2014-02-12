Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 25E286B0035
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 18:04:45 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id up15so9967686pbc.0
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 15:04:44 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id rx8si24135035pac.18.2014.02.12.15.04.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 12 Feb 2014 15:04:44 -0800 (PST)
Received: by mail-pa0-f43.google.com with SMTP id rd3so9844773pab.16
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 15:04:43 -0800 (PST)
Date: Wed, 12 Feb 2014 15:03:31 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 1/2] memcg: reparent charges of children before processing
 parent
Message-ID: <alpine.LSU.2.11.1402121500070.5029@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Filipe Brandenburger <filbranden@google.com>, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Markus Blank-Burian <burian@muenster.de>, Shawn Bohrer <shawn.bohrer@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Filipe Brandenburger <filbranden@google.com>

Sometimes the cleanup after memcg hierarchy testing gets stuck in
mem_cgroup_reparent_charges(), unable to bring non-kmem usage down to 0.

There may turn out to be several causes, but a major cause is this: the
workitem to offline parent can get run before workitem to offline child;
parent's mem_cgroup_reparent_charges() circles around waiting for the
child's pages to be reparented to its lrus, but it's holding cgroup_mutex
which prevents the child from reaching its mem_cgroup_reparent_charges().

Further testing showed that an ordered workqueue for cgroup_destroy_wq
is not always good enough: percpu_ref_kill_and_confirm's call_rcu_sched
stage on the way can mess up the order before reaching the workqueue.

Instead, when offlining a memcg, call mem_cgroup_reparent_charges() on
all its children (and grandchildren, in the correct order) to have their
charges reparented first.

Fixes: e5fca243abae ("cgroup: use a dedicated workqueue for cgroup destruction")
Signed-off-by: Filipe Brandenburger <filbranden@google.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: stable@vger.kernel.org # v3.10+ (but will need extra care)
---
Or, you may prefer my alternative cgroup.c approach in 2/2:
there's no need for both.  Please note that neither of these patches
attempts to handle the unlikely case of racy charges made to child
after its offline, but parent's offline coming before child's free:
mem_cgroup_css_free()'s backstop call to mem_cgroup_reparent_charges()
cannot help in that case, with or without these patches.  Fixing that
would have to be a separate effort - Michal's?

 mm/memcontrol.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

--- 3.14-rc2/mm/memcontrol.c	2014-02-02 18:49:07.897302115 -0800
+++ linux/mm/memcontrol.c	2014-02-11 17:48:07.604582963 -0800
@@ -6595,6 +6595,7 @@ static void mem_cgroup_css_offline(struc
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct mem_cgroup_event *event, *tmp;
+	struct cgroup_subsys_state *iter;
 
 	/*
 	 * Unregister events and notify userspace.
@@ -6611,7 +6612,14 @@ static void mem_cgroup_css_offline(struc
 	kmem_cgroup_css_offline(memcg);
 
 	mem_cgroup_invalidate_reclaim_iterators(memcg);
-	mem_cgroup_reparent_charges(memcg);
+
+	/*
+	 * This requires that offlining is serialized.  Right now that is
+	 * guaranteed because css_killed_work_fn() holds the cgroup_mutex.
+	 */
+	css_for_each_descendant_post(iter, css)
+		mem_cgroup_reparent_charges(mem_cgroup_from_css(iter));
+
 	mem_cgroup_destroy_all_caches(memcg);
 	vmpressure_cleanup(&memcg->vmpressure);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
