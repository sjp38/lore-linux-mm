Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 467866B0044
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 03:36:01 -0500 (EST)
Message-ID: <50BDB5EB.70909@oracle.com>
Date: Tue, 04 Dec 2012 16:35:55 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: [RFC PATCH 1/3] memcg: refactor pages allocation/free for swap_cgroup
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Glauber Costa <glommer@parallels.com>

- Rename swap_cgroup_prepare to swap_cgroup_alloc_pages()
- Introduce a new helper swap_cgroup_free_pages() to free
  pages from swap cgroup upon a given type.

Signed-off-by: Jie Liu <jeff.liu@oracle.com>
CC: Glauber Costa <glommer@parallels.com>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Mel Gorman <mgorman@suse.de>
CC: Andrew Morton <akpm@linux-foundation.org>
---
 mm/page_cgroup.c |   44 ++++++++++++++++++++++++++++++++------------
 1 file changed, 32 insertions(+), 12 deletions(-)

diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 5ddad0c..76b1344 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -348,31 +348,51 @@ struct swap_cgroup {
  */
 
 /*
- * allocate buffer for swap_cgroup.
+ * Allocate pages for swap_cgroup upon a given type.
  */
-static int swap_cgroup_prepare(int type)
+static int swap_cgroup_alloc_pages(int type)
 {
-	struct page *page;
 	struct swap_cgroup_ctrl *ctrl;
-	unsigned long idx, max;
+	unsigned long i, length, max;
 
 	ctrl = &swap_cgroup_ctrl[type];
-
-	for (idx = 0; idx < ctrl->length; idx++) {
-		page = alloc_page(GFP_KERNEL | __GFP_ZERO);
+	length = ctrl->length;
+	for (i = 0; i < length; i++) {
+		struct page *page = alloc_page(GFP_KERNEL | __GFP_ZERO);
 		if (!page)
 			goto not_enough_page;
-		ctrl->map[idx] = page;
+		ctrl->map[i] = page;
 	}
+
 	return 0;
+
 not_enough_page:
-	max = idx;
-	for (idx = 0; idx < max; idx++)
-		__free_page(ctrl->map[idx]);
+	max = i;
+	for (i = 0; i < max; i++)
+		__free_page(ctrl->map[i]);
 
 	return -ENOMEM;
 }
 
+static void swap_cgroup_free_pages(int type)
+{
+	struct swap_cgroup_ctrl *ctrl;
+	struct page **map;
+
+	ctrl = &swap_cgroup_ctrl[type];
+	map = ctrl->map;
+	if (map) {
+		unsigned long length = ctrl->length;
+		unsigned long i;
+
+		for (i = 0; i < length; i++) {
+			struct page *page = map[i];
+			if (page)
+				__free_page(page);
+		}
+	}
+}
+
 static struct swap_cgroup *lookup_swap_cgroup(swp_entry_t ent,
 					struct swap_cgroup_ctrl **ctrlp)
 {
@@ -477,7 +497,7 @@ int swap_cgroup_swapon(int type, unsigned long max_pages)
 	ctrl->length = length;
 	ctrl->map = array;
 	spin_lock_init(&ctrl->lock);
-	if (swap_cgroup_prepare(type)) {
+	if (swap_cgroup_alloc_pages(type)) {
 		/* memory shortage */
 		ctrl->map = NULL;
 		ctrl->length = 0;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
