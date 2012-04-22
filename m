Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 8AD706B00EF
	for <linux-mm@kvack.org>; Sun, 22 Apr 2012 19:58:10 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 23/23] slub: create slabinfo file for memcg
Date: Sun, 22 Apr 2012 20:53:40 -0300
Message-Id: <1335138820-26590-12-git-send-email-glommer@parallels.com>
In-Reply-To: <1334959051-18203-1-git-send-email-glommer@parallels.com>
References: <1334959051-18203-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, fweisbec@gmail.com, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Glauber Costa <glommer@parallels.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

This patch implements mem_cgroup_slabinfo() for the slub.
With that, we can also probe the used caches for it.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Suleiman Souhlal <suleiman@google.com>
---
 mm/slub.c |   27 +++++++++++++++++++++++++++
 1 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 1031d4d..495a4f1 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4150,6 +4150,33 @@ void kmem_cache_drop_ref(struct kmem_cache *s)
 
 int mem_cgroup_slabinfo(struct mem_cgroup *memcg, struct seq_file *m)
 {
+	struct kmem_cache *s;
+	int node;
+	unsigned long nr_objs = 0;
+	unsigned long nr_free = 0;
+
+	seq_printf(m, "# name            <active_objs> <num_objs> <objsize>\n");
+
+	down_read(&slub_lock);
+	list_for_each_entry(s, &slab_caches, list) {
+		if (s->memcg_params.memcg != memcg)
+			continue;
+
+		for_each_online_node(node) {
+			struct kmem_cache_node *n = get_node(s, node);
+
+			if (!n)
+				continue;
+
+			nr_objs += atomic_long_read(&n->total_objects);
+			nr_free += count_partial(n, count_free);
+		}
+
+		seq_printf(m, "%-17s %6lu %6lu %6u\n", s->name,
+			   nr_objs - nr_free, nr_objs, s->size);
+	}
+	up_read(&slub_lock);
+
 	return 0;
 }
 #endif
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
