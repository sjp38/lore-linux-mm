Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id AB7CF6B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 17:50:52 -0500 (EST)
Received: by qadc16 with SMTP id c16so5018678qad.14
        for <linux-mm@kvack.org>; Tue, 20 Dec 2011 14:50:51 -0800 (PST)
From: kosaki.motohiro@gmail.com
Subject: [PATCH] mm,mempolicy: mpol_equal() use bool
Date: Tue, 20 Dec 2011 17:50:28 -0500
Message-Id: <1324421434-14342-1-git-send-email-kosaki.motohiro@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Stephen Wilson <wilsons@start.ca>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

mpol_equal() logically return boolean. then it should be used bool.
This change slightly improve readability.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/mempolicy.h |   10 +++++-----
 mm/mempolicy.c            |   14 +++++++-------
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 7978eec..7c727a9 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -164,11 +164,11 @@ static inline void mpol_get(struct mempolicy *pol)
 		atomic_inc(&pol->refcnt);
 }
 
-extern int __mpol_equal(struct mempolicy *a, struct mempolicy *b);
-static inline int mpol_equal(struct mempolicy *a, struct mempolicy *b)
+extern bool __mpol_equal(struct mempolicy *a, struct mempolicy *b);
+static inline bool mpol_equal(struct mempolicy *a, struct mempolicy *b)
 {
 	if (a == b)
-		return 1;
+		return true;
 	return __mpol_equal(a, b);
 }
 
@@ -257,9 +257,9 @@ static inline int vma_migratable(struct vm_area_struct *vma)
 
 struct mempolicy {};
 
-static inline int mpol_equal(struct mempolicy *a, struct mempolicy *b)
+static inline bool mpol_equal(struct mempolicy *a, struct mempolicy *b)
 {
-	return 1;
+	return true;
 }
 
 static inline void mpol_put(struct mempolicy *p)
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index adc3954..475f1c7 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1974,28 +1974,28 @@ struct mempolicy *__mpol_cond_copy(struct mempolicy *tompol,
 }
 
 /* Slow path of a mempolicy comparison */
-int __mpol_equal(struct mempolicy *a, struct mempolicy *b)
+bool __mpol_equal(struct mempolicy *a, struct mempolicy *b)
 {
 	if (!a || !b)
-		return 0;
+		return false;
 	if (a->mode != b->mode)
-		return 0;
+		return false;
 	if (a->flags != b->flags)
-		return 0;
+		return false;
 	if (mpol_store_user_nodemask(a))
 		if (!nodes_equal(a->w.user_nodemask, b->w.user_nodemask))
-			return 0;
+			return false;
 
 	switch (a->mode) {
 	case MPOL_BIND:
 		/* Fall through */
 	case MPOL_INTERLEAVE:
-		return nodes_equal(a->v.nodes, b->v.nodes);
+		return !!nodes_equal(a->v.nodes, b->v.nodes);
 	case MPOL_PREFERRED:
 		return a->v.preferred_node == b->v.preferred_node;
 	default:
 		BUG();
-		return 0;
+		return false;
 	}
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
