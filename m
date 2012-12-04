Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 3DDF46B004D
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 03:36:18 -0500 (EST)
Message-ID: <50BDB5FB.6080707@oracle.com>
Date: Tue, 04 Dec 2012 16:36:11 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: [RFC PATCH 2/3] memcg: disable pages allocation for swap cgroup on
 system booting up
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Glauber Costa <glommer@parallels.com>

- Disable pages allocation for swap cgroup at system boot up stage.
- Perform page allocation if there have child memcg alive, because the user
  might disabled one/more swap files/partitions for some reason.
- Introduce a couple of helpers to deal with page allocation/free for swap cgroup.
- Introduce a new static variable to indicate the status of child memcg create/remove.

Signed-off-by: Jie Liu <jeff.liu@oracle.com>
CC: Glauber Costa <glommer@parallels.com>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Mel Gorman <mgorman@suse.de>
CC: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/page_cgroup.h |   12 +++++
 mm/page_cgroup.c            |  109 ++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 110 insertions(+), 11 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index 777a524..2b94fc0 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -113,6 +113,8 @@ extern unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id);
 extern unsigned short lookup_swap_cgroup_id(swp_entry_t ent);
 extern int swap_cgroup_swapon(int type, unsigned long max_pages);
 extern void swap_cgroup_swapoff(int type);
+extern int swap_cgroup_init(void);
+extern void swap_cgroup_destroy(void);
 #else
 
 static inline
@@ -138,6 +140,16 @@ static inline void swap_cgroup_swapoff(int type)
 	return;
 }
 
+static inline int swap_cgroup_init(void)
+{
+	return 0;
+}
+
+static inline void swap_cgroup_destroy(void)
+{
+	return;
+}
+
 #endif /* CONFIG_MEMCG_SWAP */
 
 #endif /* !__GENERATING_BOUNDS_H */
diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 76b1344..f1b257b 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -321,8 +321,8 @@ void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat)
 
 static DEFINE_MUTEX(swap_cgroup_mutex);
 struct swap_cgroup_ctrl {
-	struct page **map;
-	unsigned long length;
+	struct page	**map;
+	unsigned long	length;
 	spinlock_t	lock;
 };
 
@@ -410,6 +410,8 @@ static struct swap_cgroup *lookup_swap_cgroup(swp_entry_t ent,
 	return sc + offset % SC_PER_PAGE;
 }
 
+static atomic_t swap_cgroup_initialized = ATOMIC_INIT(0);
+
 /**
  * swap_cgroup_cmpxchg - cmpxchg mem_cgroup's id for this swp_entry.
  * @ent: swap entry to be cmpxchged
@@ -497,17 +499,36 @@ int swap_cgroup_swapon(int type, unsigned long max_pages)
 	ctrl->length = length;
 	ctrl->map = array;
 	spin_lock_init(&ctrl->lock);
-	if (swap_cgroup_alloc_pages(type)) {
-		/* memory shortage */
-		ctrl->map = NULL;
-		ctrl->length = 0;
-		mutex_unlock(&swap_cgroup_mutex);
-		vfree(array);
-		goto nomem;
+
+	/*
+	 * We would delay page allocation for swap cgroup if swapon(2)
+	 * is occurred at system boot phase until the first none-parent
+	 * memcg was created.
+	 *
+	 * However, we might run into the following scenarios:
+	 * 1) one/more new swap partitions/files are being enabled
+	 *    with non-parent memcg+swap_cgroup is/are active.
+	 * 2) keep memcg+swap_cgroup being active, but the user has
+	 *    performed swapoff(2) against the given type of swap
+	 *    partition or file for some reason, and then the user
+	 *    turn it on again.
+	 * In those cases, we have to allocate the pages in swapon(2)
+	 * stage since we have no chance to make it in swap_cgroup_init()
+	 * until a new child memcg was created.
+	 */
+	if (atomic_read(&swap_cgroup_initialized)) {
+		if (swap_cgroup_alloc_pages(type)) {
+			/* memory shortage */
+			ctrl->map = NULL;
+			ctrl->length = 0;
+			mutex_unlock(&swap_cgroup_mutex);
+			vfree(array);
+			goto nomem;
+		}
 	}
 	mutex_unlock(&swap_cgroup_mutex);
-
 	return 0;
+
 nomem:
 	printk(KERN_INFO "couldn't allocate enough memory for swap_cgroup.\n");
 	printk(KERN_INFO
@@ -515,10 +536,74 @@ nomem:
 	return -ENOMEM;
 }
 
+/*
+ * This function is called per child memcg created so that we might
+ * arrive here multiple times.  But we only allocate pages for swap
+ * cgroup when the first child memcg was created.
+ */
+int swap_cgroup_init(void)
+{
+	int type;
+
+	if (!do_swap_account)
+		return 0;
+
+	if (atomic_add_return(1, &swap_cgroup_initialized) != 1)
+		return 0;
+
+	mutex_lock(&swap_cgroup_mutex);
+	for (type = 0; type < MAX_SWAPFILES; type++) {
+		if (swap_cgroup_alloc_pages(type) < 0) {
+			struct swap_cgroup_ctrl *ctrl;
+
+			ctrl = &swap_cgroup_ctrl[type];
+			mutex_unlock(&swap_cgroup_mutex);
+			ctrl->length = 0;
+			if (ctrl->map) {
+				vfree(ctrl->map);
+				ctrl->map = NULL;
+			}
+			goto nomem;
+		}
+	}
+	mutex_unlock(&swap_cgroup_mutex);
+
+	return 0;
+
+nomem:
+	pr_info("couldn't initialize swap_cgroup, no enough memory.\n");
+	pr_info("swap_cgroup can be disabled by swapaccount=0 boot option\n");
+	return -ENOMEM;
+}
+
+/*
+ * This function is called per memcg removed so that we might arrive
+ * here multiple times, but we only free pages when the last memcg
+ * was removed.  Note that:
+ * We won't clean the map pointer and the length which were calculated
+ * at swapon(2) stage because of that we need those info to re-allocate
+ * pages if a child memcg was created again.
+ */
+void swap_cgroup_destroy(void)
+{
+	int type;
+
+	if (!do_swap_account)
+		return;
+
+	if (atomic_sub_return(1, &swap_cgroup_initialized))
+		return;
+
+	mutex_lock(&swap_cgroup_mutex);
+	for (type = 0; type < MAX_SWAPFILES; type++)
+		swap_cgroup_free_pages(type);
+	mutex_unlock(&swap_cgroup_mutex);
+}
+
 void swap_cgroup_swapoff(int type)
 {
 	struct page **map;
-	unsigned long i, length;
+	unsigned long length;
 	struct swap_cgroup_ctrl *ctrl;
 
 	if (!do_swap_account)
@@ -533,6 +618,8 @@ void swap_cgroup_swapoff(int type)
 	mutex_unlock(&swap_cgroup_mutex);
 
 	if (map) {
+		unsigned long i;
+
 		for (i = 0; i < length; i++) {
 			struct page *page = map[i];
 			if (page)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
