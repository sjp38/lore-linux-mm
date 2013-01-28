Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id BD99A6B0008
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 05:54:40 -0500 (EST)
Message-ID: <510658E6.9030108@oracle.com>
Date: Mon, 28 Jan 2013 18:54:30 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: [PATCH v2 1/6] memcg: refactor swap_cgroup_swapon()
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org

Refector swap_cgroup_swapon() to setup the number of pages only, and
move the rest to swap_cgroup_prepare(), so that the later can be used
for allocating buffers when creating the first non-root memcg.

Signed-off-by: Jie Liu <jeff.liu@oracle.com>
CC: Glauber Costa <glommer@parallels.com>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Mel Gorman <mgorman@suse.de>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Sha Zhengju <handai.szj@taobao.com>

---
 mm/page_cgroup.c |   17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 6d757e3..c945254 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -360,6 +360,9 @@ static int swap_cgroup_prepare(int type)
 	unsigned long idx, max;
 
 	ctrl = &swap_cgroup_ctrl[type];
+	ctrl->map = vzalloc(ctrl->length * sizeof(void *));
+	if (!ctrl->map)
+		goto nomem;
 
 	for (idx = 0; idx < ctrl->length; idx++) {
 		page = alloc_page(GFP_KERNEL | __GFP_ZERO);
@@ -368,11 +371,13 @@ static int swap_cgroup_prepare(int type)
 		ctrl->map[idx] = page;
 	}
 	return 0;
+
 not_enough_page:
 	max = idx;
 	for (idx = 0; idx < max; idx++)
 		__free_page(ctrl->map[idx]);
-
+	ctrl->map = NULL;
+nomem:
 	return -ENOMEM;
 }
 
@@ -460,8 +465,6 @@ unsigned short lookup_swap_cgroup_id(swp_entry_t ent)
 
 int swap_cgroup_swapon(int type, unsigned long max_pages)
 {
-	void *array;
-	unsigned long array_size;
 	unsigned long length;
 	struct swap_cgroup_ctrl *ctrl;
 
@@ -469,23 +472,15 @@ int swap_cgroup_swapon(int type, unsigned long max_pages)
 		return 0;
 
 	length = DIV_ROUND_UP(max_pages, SC_PER_PAGE);
-	array_size = length * sizeof(void *);
-
-	array = vzalloc(array_size);
-	if (!array)
-		goto nomem;
 
 	ctrl = &swap_cgroup_ctrl[type];
 	mutex_lock(&swap_cgroup_mutex);
 	ctrl->length = length;
-	ctrl->map = array;
 	spin_lock_init(&ctrl->lock);
 	if (swap_cgroup_prepare(type)) {
 		/* memory shortage */
-		ctrl->map = NULL;
 		ctrl->length = 0;
 		mutex_unlock(&swap_cgroup_mutex);
-		vfree(array);
 		goto nomem;
 	}
 	mutex_unlock(&swap_cgroup_mutex);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
