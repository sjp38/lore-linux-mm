Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4F6306B0047
	for <linux-mm@kvack.org>; Fri,  2 Dec 2011 04:43:08 -0500 (EST)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH] page_cgroup: add helper function to get swap_cgroup
Date: Fri, 2 Dec 2011 17:42:11 +0800
Message-ID: <1322818931-2674-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, jweiner@redhat.com, bsingharora@gmail.com, Bob Liu <lliubbo@gmail.com>

There are multi places need to get swap_cgroup, so add a helper
function:
static struct swap_cgroup *swap_cgroup_getsc(swp_entry_t ent);
to simple the code.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/page_cgroup.c |   49 ++++++++++++++++++++++---------------------------
 1 files changed, 22 insertions(+), 27 deletions(-)

diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index f0559e0..ee1766a 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -362,6 +362,24 @@ not_enough_page:
 	return -ENOMEM;
 }
 
+static struct swap_cgroup *swap_cgroup_getsc(swp_entry_t ent)
+{
+	int type = swp_type(ent);
+	unsigned long offset = swp_offset(ent);
+	unsigned long idx = offset / SC_PER_PAGE;
+	unsigned long pos = offset & SC_POS_MASK;
+	struct swap_cgroup_ctrl *ctrl;
+	struct page *mappage;
+	struct swap_cgroup *sc;
+
+	ctrl = &swap_cgroup_ctrl[type];
+
+	mappage = ctrl->map[idx];
+	sc = page_address(mappage);
+	sc += pos;
+	return sc;
+}
+
 /**
  * swap_cgroup_cmpxchg - cmpxchg mem_cgroup's id for this swp_entry.
  * @end: swap entry to be cmpxchged
@@ -375,20 +393,14 @@ unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
 					unsigned short old, unsigned short new)
 {
 	int type = swp_type(ent);
-	unsigned long offset = swp_offset(ent);
-	unsigned long idx = offset / SC_PER_PAGE;
-	unsigned long pos = offset & SC_POS_MASK;
 	struct swap_cgroup_ctrl *ctrl;
-	struct page *mappage;
 	struct swap_cgroup *sc;
 	unsigned long flags;
 	unsigned short retval;
 
 	ctrl = &swap_cgroup_ctrl[type];
+	sc = swap_cgroup_getsc(ent);
 
-	mappage = ctrl->map[idx];
-	sc = page_address(mappage);
-	sc += pos;
 	spin_lock_irqsave(&ctrl->lock, flags);
 	retval = sc->id;
 	if (retval == old)
@@ -410,20 +422,14 @@ unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
 unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
 {
 	int type = swp_type(ent);
-	unsigned long offset = swp_offset(ent);
-	unsigned long idx = offset / SC_PER_PAGE;
-	unsigned long pos = offset & SC_POS_MASK;
 	struct swap_cgroup_ctrl *ctrl;
-	struct page *mappage;
 	struct swap_cgroup *sc;
 	unsigned short old;
 	unsigned long flags;
 
 	ctrl = &swap_cgroup_ctrl[type];
+	sc = swap_cgroup_getsc(ent);
 
-	mappage = ctrl->map[idx];
-	sc = page_address(mappage);
-	sc += pos;
 	spin_lock_irqsave(&ctrl->lock, flags);
 	old = sc->id;
 	sc->id = id;
@@ -440,21 +446,10 @@ unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
  */
 unsigned short lookup_swap_cgroup(swp_entry_t ent)
 {
-	int type = swp_type(ent);
-	unsigned long offset = swp_offset(ent);
-	unsigned long idx = offset / SC_PER_PAGE;
-	unsigned long pos = offset & SC_POS_MASK;
-	struct swap_cgroup_ctrl *ctrl;
-	struct page *mappage;
 	struct swap_cgroup *sc;
-	unsigned short ret;
 
-	ctrl = &swap_cgroup_ctrl[type];
-	mappage = ctrl->map[idx];
-	sc = page_address(mappage);
-	sc += pos;
-	ret = sc->id;
-	return ret;
+	sc = swap_cgroup_getsc(ent);
+	return sc->id;
 }
 
 int swap_cgroup_swapon(int type, unsigned long max_pages)
-- 
1.7.0.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
