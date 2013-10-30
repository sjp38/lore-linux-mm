Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f208.google.com (mail-pd0-f208.google.com [209.85.192.208])
	by kanga.kvack.org (Postfix) with ESMTP id F38CA6B0038
	for <linux-mm@kvack.org>; Fri,  1 Nov 2013 10:06:37 -0400 (EDT)
Received: by mail-pd0-f208.google.com with SMTP id y10so73902pdj.7
        for <linux-mm@kvack.org>; Fri, 01 Nov 2013 07:06:37 -0700 (PDT)
Received: from psmtp.com ([74.125.245.181])
        by mx.google.com with SMTP id dj3si41490pbc.250.2013.10.30.14.58.25
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 14:58:26 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/3] mm: memcg: fix test for child groups
Date: Wed, 30 Oct 2013 17:55:27 -0400
Message-Id: <1383170127-32284-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1383170127-32284-1-git-send-email-hannes@cmpxchg.org>
References: <1383170127-32284-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When memcg code needs to know whether any given memcg has children, it
uses the cgroup child iteration primitives and returns true/false
depending on whether the iteration loop is executed at least once or
not.

Because a cgroup's list of children is RCU protected, these primitives
require the RCU read-lock to be held, which is not the case for all
memcg callers.  This results in the following splat when e.g. enabling
hierarchy mode:

[    3.683974] WARNING: CPU: 3 PID: 1 at /home/hannes/src/linux/linux/kernel/cgroup.c:3043 css_next_child+0xa3/0x160()
[    3.686266] CPU: 3 PID: 1 Comm: systemd Not tainted 3.12.0-rc5-00117-g83f11a9-dirty #18
[    3.688616] Hardware name: LENOVO 3680B56/3680B56, BIOS 6QET69WW (1.39 ) 04/26/2012
[    3.690900]  0000000000000009 ffff88013227bdc8 ffffffff8173602f 0000000000000000
[    3.693225]  ffff88013227be00 ffffffff81090af8 0000000000000000 ffff88013220d000
[    3.695606]  ffff8800b6c50028 ffff88013220d000 0000000000000000 ffff88013227be10
[    3.697950] Call Trace:
[    3.700233]  [<ffffffff8173602f>] dump_stack+0x54/0x74
[    3.702503]  [<ffffffff81090af8>] warn_slowpath_common+0x78/0xa0
[    3.704764]  [<ffffffff81090c0a>] warn_slowpath_null+0x1a/0x20
[    3.707009]  [<ffffffff81101173>] css_next_child+0xa3/0x160
[    3.709255]  [<ffffffff8118ae7b>] mem_cgroup_hierarchy_write+0x5b/0xa0
[    3.711497]  [<ffffffff810fe428>] cgroup_file_write+0x108/0x2a0
[    3.713721]  [<ffffffff8119b90d>] ? __sb_start_write+0xed/0x1b0
[    3.715936]  [<ffffffff811980fb>] ? vfs_write+0x1bb/0x1e0
[    3.718155]  [<ffffffff810b8d3f>] ? up_write+0x1f/0x40
[    3.720356]  [<ffffffff81197ffd>] vfs_write+0xbd/0x1e0
[    3.722539]  [<ffffffff8119820c>] SyS_write+0x4c/0xa0
[    3.724685]  [<ffffffff817400d2>] system_call_fastpath+0x16/0x1b
[    3.726809] ---[ end trace ec33c7d4de043d06 ]---

In the memcg case, we only care about children when we are attempting
to modify inheritable attributes interactively.  Racing with deletion
could mean a spurious -EBUSY, no problem.  Racing with addition is
handled just fine as well through the memcg_create_mutex: if the child
group is not on the list after the mutex is acquired, it won't be
initialized from the parent's attributes until after the unlock.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 35 +++++++++++------------------------
 1 file changed, 11 insertions(+), 24 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3e8cd0d9f716..8804be1cb826 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4959,31 +4959,18 @@ static void mem_cgroup_reparent_charges(struct mem_cgroup *memcg)
 	} while (usage > 0);
 }
 
-/*
- * This mainly exists for tests during the setting of set of use_hierarchy.
- * Since this is the very setting we are changing, the current hierarchy value
- * is meaningless
- */
-static inline bool __memcg_has_children(struct mem_cgroup *memcg)
-{
-	struct cgroup_subsys_state *pos;
-
-	/* bounce at first found */
-	css_for_each_child(pos, &memcg->css)
-		return true;
-	return false;
-}
-
-/*
- * Must be called with memcg_create_mutex held, unless the cgroup is guaranteed
- * to be already dead (as in mem_cgroup_force_empty, for instance).  This is
- * from mem_cgroup_count_children(), in the sense that we don't really care how
- * many children we have; we only need to know if we have any.  It also counts
- * any memcg without hierarchy as infertile.
- */
 static inline bool memcg_has_children(struct mem_cgroup *memcg)
 {
-	return memcg->use_hierarchy && __memcg_has_children(memcg);
+	lockdep_assert_held(&memcg_create_mutex);
+	/*
+	 * The lock does not prevent addition or deletion to the list
+	 * of children, but it prevents a new child from being
+	 * initialized based on this parent in css_online(), so it's
+	 * enough to decide whether hierarchically inherited
+	 * attributes can still be changed or not.
+	 */
+	return memcg->use_hierarchy &&
+		!list_empty(&memcg->css.cgroup->children);
 }
 
 /*
@@ -5063,7 +5050,7 @@ static int mem_cgroup_hierarchy_write(struct cgroup_subsys_state *css,
 	 */
 	if ((!parent_memcg || !parent_memcg->use_hierarchy) &&
 				(val == 1 || val == 0)) {
-		if (!__memcg_has_children(memcg))
+		if (list_empty(&memcg->css.cgroup->children))
 			memcg->use_hierarchy = val;
 		else
 			retval = -EBUSY;
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
