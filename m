Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 6645C6B004D
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 03:38:59 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC v7 07/11] keep mm_struct to vrange when system call context
Date: Tue, 12 Mar 2013 16:38:31 +0900
Message-Id: <1363073915-25000-8-git-send-email-minchan@kernel.org>
In-Reply-To: <1363073915-25000-1-git-send-email-minchan@kernel.org>
References: <1363073915-25000-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, John Stultz <john.stultz@linaro.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>

We need mm_struct for discarding vrange pages in kswapd context.
It's a preparatoin for it.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/vrange.h |  1 +
 mm/vrange.c            | 20 +++++++++++---------
 2 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/include/linux/vrange.h b/include/linux/vrange.h
index 24ed4c1..5238a67 100644
--- a/include/linux/vrange.h
+++ b/include/linux/vrange.h
@@ -11,6 +11,7 @@ static DECLARE_RWSEM(vrange_fork_lock);
 struct vrange {
 	struct interval_tree_node node;
 	bool purged;
+	struct mm_struct *mm;
 };
 
 #define vrange_entry(ptr) \
diff --git a/mm/vrange.c b/mm/vrange.c
index 89fcae4..f4c1d04 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -29,8 +29,9 @@ static inline void __set_vrange(struct vrange *range,
 }
 
 static void __add_range(struct vrange *range,
-				struct rb_root *root)
+			struct rb_root *root, struct mm_struct *mm)
 {
+	range->mm = mm;
 	interval_tree_insert(&range->node, root);
 }
 
@@ -52,11 +53,12 @@ static void free_vrange(struct vrange *range)
 
 static inline void range_resize(struct rb_root *root,
 		struct vrange *range,
-		unsigned long start, unsigned long end)
+		unsigned long start, unsigned long end,
+		struct mm_struct *mm)
 {
 	__remove_range(range, root);
 	__set_vrange(range, start, end);
-	__add_range(range, root);
+	__add_range(range, root, mm);
 }
 
 int add_vrange(struct mm_struct *mm,
@@ -95,8 +97,7 @@ int add_vrange(struct mm_struct *mm,
 
 	__set_vrange(new_range, start, end);
 	new_range->purged = purged;
-
-	__add_range(new_range, root);
+	__add_range(new_range, root, mm);
 out:
 	vrange_unlock(mm);
 	return 0;
@@ -129,15 +130,16 @@ int remove_vrange(struct mm_struct *mm,
 			__remove_range(range, root);
 			free_vrange(range);
 		} else if (node->start >= start) {
-			range_resize(root, range, end, node->last);
+			range_resize(root, range, end, node->last, mm);
 		} else if (node->last <= end) {
-			range_resize(root, range, node->start, start);
+			range_resize(root, range, node->start, start, mm);
 		} else {
 			used_new = true;
 			__set_vrange(new_range, end, node->last);
 			new_range->purged = range->purged;
-			range_resize(root, range, node->start, start);
-			__add_range(new_range, root);
+			new_range->mm = mm;
+			range_resize(root, range, node->start, start, mm);
+			__add_range(new_range, root, mm);
 			break;
 		}
 
-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
