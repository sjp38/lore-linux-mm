Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BB4618D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 08:54:44 -0400 (EDT)
Received: by iwl42 with SMTP id 42so5501018iwl.14
        for <linux-mm@kvack.org>; Fri, 18 Mar 2011 05:54:42 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 3/3] memcg: move page-freeing code outside of lock
Date: Fri, 18 Mar 2011 21:54:15 +0900
Message-Id: <1300452855-10194-3-git-send-email-namhyung@gmail.com>
In-Reply-To: <1300452855-10194-1-git-send-email-namhyung@gmail.com>
References: <1300452855-10194-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/page_cgroup.c |   22 +++++++++++++---------
 1 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 29951abc852e..17eb5eb95bab 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -463,8 +463,8 @@ int swap_cgroup_swapon(int type, unsigned long max_pages)
 		/* memory shortage */
 		ctrl->map = NULL;
 		ctrl->length = 0;
-		vfree(array);
 		mutex_unlock(&swap_cgroup_mutex);
+		vfree(array);
 		goto nomem;
 	}
 	mutex_unlock(&swap_cgroup_mutex);
@@ -479,7 +479,8 @@ nomem:
 
 void swap_cgroup_swapoff(int type)
 {
-	int i;
+	struct page **map;
+	unsigned long i, length;
 	struct swap_cgroup_ctrl *ctrl;
 
 	if (!do_swap_account)
@@ -487,17 +488,20 @@ void swap_cgroup_swapoff(int type)
 
 	mutex_lock(&swap_cgroup_mutex);
 	ctrl = &swap_cgroup_ctrl[type];
-	if (ctrl->map) {
-		for (i = 0; i < ctrl->length; i++) {
-			struct page *page = ctrl->map[i];
+	map = ctrl->map;
+	length = ctrl->length;
+	ctrl->map = NULL;
+	ctrl->length = 0;
+	mutex_unlock(&swap_cgroup_mutex);
+
+	if (map) {
+		for (i = 0; i < length; i++) {
+			struct page *page = map[i];
 			if (page)
 				__free_page(page);
 		}
-		vfree(ctrl->map);
-		ctrl->map = NULL;
-		ctrl->length = 0;
+		vfree(map);
 	}
-	mutex_unlock(&swap_cgroup_mutex);
 }
 
 #endif
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
