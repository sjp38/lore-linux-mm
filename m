Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 01C088D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 07:44:22 -0400 (EDT)
From: Phil Carmody <ext-phil.2.carmody@nokia.com>
Subject: [PATCH] kmemleak: Never return a pointer you didn't 'get'
Date: Thu, 21 Apr 2011 14:39:32 +0300
Message-Id: <1303385972-2518-1-git-send-email-ext-phil.2.carmody@nokia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, ext-phil.2.carmody@nokia.com

Old - If you don't get the last pointer that you looked at, then it will
still be put, as there's no way of knowing you didn't get it.

New - If you didn't get it, then it refers to something deleted, and
your work is done, so return NULL.

Signed-off-by: Phil Carmody <ext-phil.2.carmody@nokia.com>
---
 mm/kmemleak.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 8bf765c..3bf204d 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1350,17 +1350,21 @@ static void *kmemleak_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	struct kmemleak_object *prev_obj = v;
 	struct kmemleak_object *next_obj = NULL;
 	struct list_head *n = &prev_obj->object_list;
+	int found = 0;
 
 	++(*pos);
 
 	list_for_each_continue_rcu(n, &object_list) {
 		next_obj = list_entry(n, struct kmemleak_object, object_list);
-		if (get_object(next_obj))
+		if (get_object(next_obj)) {
+			found = 1;
 			break;
+		}
 	}
 
 	put_object(prev_obj);
-	return next_obj;
+
+	return found ? next_obj : NULL;
 }
 
 /*
-- 
1.7.2.rc1.37.gf8c40

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
