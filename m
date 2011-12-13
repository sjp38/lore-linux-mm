Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 68A806B0202
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 22:27:02 -0500 (EST)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH] page_cgroup: cleanup lookup_swap_cgroup()
Date: Tue, 13 Dec 2011 11:33:58 +0800
Message-ID: <1323747238-10252-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, jweiner@redhat.com, mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, bsingharora@gmail.com, Bob Liu <lliubbo@gmail.com>

This patch is based on my previous patch:
page_cgroup: add helper function to get swap_cgroup

As Johannes suggested, change the public interface to lookup_swap_cgroup_id(),
replace swap_cgroup_getsc() with lookup_swap_cgroup() and do some extra
cleanup.

Cc: Johannes Weiner <jweiner@redhat.com>
Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 include/linux/page_cgroup.h |    4 ++--
 mm/memcontrol.c             |    4 ++--
 mm/page_cgroup.c            |   35 ++++++++++++++---------------------
 3 files changed, 18 insertions(+), 25 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index aaa60da..1153095 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -149,7 +149,7 @@ static inline void __init page_cgroup_init_flatmem(void)
 extern unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
 					unsigned short old, unsigned short new);
 extern unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id);
-extern unsigned short lookup_swap_cgroup(swp_entry_t ent);
+extern unsigned short lookup_swap_cgroup_id(swp_entry_t ent);
 extern int swap_cgroup_swapon(int type, unsigned long max_pages);
 extern void swap_cgroup_swapoff(int type);
 #else
@@ -161,7 +161,7 @@ unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
 }
 
 static inline
-unsigned short lookup_swap_cgroup(swp_entry_t ent)
+unsigned short lookup_swap_cgroup_id(swp_entry_t ent)
 {
 	return 0;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8880a32..bc396e7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2405,7 +2405,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 			memcg = NULL;
 	} else if (PageSwapCache(page)) {
 		ent.val = page_private(page);
-		id = lookup_swap_cgroup(ent);
+		id = lookup_swap_cgroup_id(ent);
 		rcu_read_lock();
 		memcg = mem_cgroup_lookup(id);
 		if (memcg && !css_tryget(&memcg->css))
@@ -5114,7 +5114,7 @@ static int is_target_pte_for_mc(struct vm_area_struct *vma,
 	}
 	/* There is a swap entry and a page doesn't exist or isn't charged */
 	if (ent.val && !ret &&
-			css_id(&mc.from->css) == lookup_swap_cgroup(ent)) {
+			css_id(&mc.from->css) == lookup_swap_cgroup_id(ent)) {
 		ret = MC_TARGET_SWAP;
 		if (target)
 			target->ent = ent;
diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 53b5d43..b99d19e 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -334,7 +334,6 @@ struct swap_cgroup {
 	unsigned short		id;
 };
 #define SC_PER_PAGE	(PAGE_SIZE/sizeof(struct swap_cgroup))
-#define SC_POS_MASK	(SC_PER_PAGE - 1)
 
 /*
  * SwapCgroup implements "lookup" and "exchange" operations.
@@ -376,25 +375,19 @@ not_enough_page:
 	return -ENOMEM;
 }
 
-static struct swap_cgroup *swap_cgroup_getsc(swp_entry_t ent,
-					struct swap_cgroup_ctrl **ctrl)
+static struct swap_cgroup *lookup_swap_cgroup(swp_entry_t ent,
+					struct swap_cgroup_ctrl **ctrlp)
 {
-	int type = swp_type(ent);
-	unsigned long offset = swp_offset(ent);
-	unsigned long idx = offset / SC_PER_PAGE;
-	unsigned long pos = offset & SC_POS_MASK;
-	struct swap_cgroup_ctrl *temp_ctrl;
+	pgoff_t offset = swp_offset(ent);
+	struct swap_cgroup_ctrl *ctrl;
 	struct page *mappage;
-	struct swap_cgroup *sc;
 
-	temp_ctrl = &swap_cgroup_ctrl[type];
-	if (ctrl)
-		*ctrl = temp_ctrl;
+	ctrl = &swap_cgroup_ctrl[swp_type(ent)];
+	if (ctrlp)
+		*ctrlp = ctrl;
 
-	mappage = temp_ctrl->map[idx];
-	sc = page_address(mappage);
-	sc += pos;
-	return sc;
+	mappage = ctrl->map[offset / SC_PER_PAGE];
+	return page_address(mappage) + offset % SC_PER_PAGE;
 }
 
 /**
@@ -414,7 +407,7 @@ unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
 	unsigned long flags;
 	unsigned short retval;
 
-	sc = swap_cgroup_getsc(ent, &ctrl);
+	sc = lookup_swap_cgroup(ent, &ctrl);
 
 	spin_lock_irqsave(&ctrl->lock, flags);
 	retval = sc->id;
@@ -441,7 +434,7 @@ unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
 	unsigned short old;
 	unsigned long flags;
 
-	sc = swap_cgroup_getsc(ent, &ctrl);
+	sc = lookup_swap_cgroup(ent, &ctrl);
 
 	spin_lock_irqsave(&ctrl->lock, flags);
 	old = sc->id;
@@ -452,14 +445,14 @@ unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
 }
 
 /**
- * lookup_swap_cgroup - lookup mem_cgroup tied to swap entry
+ * lookup_swap_cgroup_id - lookup mem_cgroup id tied to swap entry
  * @ent: swap entry to be looked up.
  *
  * Returns CSS ID of mem_cgroup at success. 0 at failure. (0 is invalid ID)
  */
-unsigned short lookup_swap_cgroup(swp_entry_t ent)
+unsigned short lookup_swap_cgroup_id(swp_entry_t ent)
 {
-	return swap_cgroup_getsc(ent, NULL)->id;
+	return lookup_swap_cgroup(ent, NULL)->id;
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
