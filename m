Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5D4DA8D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 07:59:34 -0400 (EDT)
Received: by pwi10 with SMTP id 10so1602961pwi.14
        for <linux-mm@kvack.org>; Wed, 23 Mar 2011 04:59:32 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH] memcg: move page-freeing code out of lock
Date: Wed, 23 Mar 2011 20:59:18 +0900
Message-Id: <1300881558-13523-1-git-send-email-namhyung@gmail.com>
In-Reply-To: <20110323133614.95553de8.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110323133614.95553de8.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org

Move page-freeing code out of swap_cgroup_mutex in the hope that it
could reduce few of theoretical contentions between swapons and/or
swapoffs.

This is just a cleanup, no functional changes.

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
Cc: Paul Menage <menage@google.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>
Cc: containers@lists.linux-foundation.org
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
