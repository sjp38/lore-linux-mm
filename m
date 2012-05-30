Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 80E1C6B006C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 05:03:14 -0400 (EDT)
Received: by mail-vb0-f41.google.com with SMTP id ey12so4077167vbb.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 02:03:14 -0700 (PDT)
From: kosaki.motohiro@gmail.com
Subject: [PATCH 3/6] mempolicy: fix a race in shared_policy_replace()
Date: Wed, 30 May 2012 05:02:06 -0400
Message-Id: <1338368529-21784-4-git-send-email-kosaki.motohiro@gmail.com>
In-Reply-To: <1338368529-21784-1-git-send-email-kosaki.motohiro@gmail.com>
References: <1338368529-21784-1-git-send-email-kosaki.motohiro@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux.com>, stable@vger.kernel.org, hughd@google.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

shared_policy_replace() uses sp_alloc() wrongly. 1) sp_node can't be dereferenced when
not holding sp->lock and 2) another thread can modify sp_node between spin_unlock for
restarting and next spin_lock, we shouldn't believe n->end and n->policy were not
modified.

This patch fixes them.

Note: The bug was introduced pre-git age (IOW, before 2.6.12-rc2). I believe nobody
uses this feature in production systems.

Cc: Dave Jones <davej@redhat.com>,
Cc: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>,
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: <stable@vger.kernel.org>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/mempolicy.c |   55 ++++++++++++++++++++++++++++++++++++++-----------------
 1 files changed, 38 insertions(+), 17 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 9505cb9..d97d2db 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2158,6 +2158,14 @@ static void sp_delete(struct shared_policy *sp, struct sp_node *n)
 	kmem_cache_free(sn_cache, n);
 }
 
+static void sp_node_init(struct sp_node *node, unsigned long start,
+			 unsigned long end, struct mempolicy *pol)
+{
+	node->start = start;
+	node->end = end;
+	node->policy = pol;
+}
+
 static struct sp_node *sp_alloc(unsigned long start, unsigned long end,
 				struct mempolicy *pol)
 {
@@ -2174,10 +2182,7 @@ static struct sp_node *sp_alloc(unsigned long start, unsigned long end,
 		return NULL;
 	}
 	newpol->flags |= MPOL_F_SHARED;
-
-	n->start = start;
-	n->end = end;
-	n->policy = newpol;
+	sp_node_init(n, start, end, newpol);
 
 	return n;
 }
@@ -2186,7 +2191,9 @@ static struct sp_node *sp_alloc(unsigned long start, unsigned long end,
 static int shared_policy_replace(struct shared_policy *sp, unsigned long start,
 				 unsigned long end, struct sp_node *new)
 {
+	int err;
 	struct sp_node *n, *new2 = NULL;
+	struct mempolicy *new2_pol = NULL;
 
 restart:
 	spin_lock(&sp->lock);
@@ -2202,16 +2209,16 @@ restart:
 		} else {
 			/* Old policy spanning whole new range. */
 			if (n->end > end) {
-				if (!new2) {
-					spin_unlock(&sp->lock);
-					new2 = sp_alloc(end, n->end, n->policy);
-					if (!new2)
-						return -ENOMEM;
-					goto restart;
-				}
-				n->end = start;
+				if (!new2)
+					goto alloc_new2;
+
+				*new2_pol = *n->policy;
+				atomic_set(&new2_pol->refcnt, 1);
+				sp_node_init(new2, n->end, end, new2_pol);
 				sp_insert(sp, new2);
+				n->end = start;
 				new2 = NULL;
+				new2_pol = NULL;
 				break;
 			} else
 				n->end = start;
@@ -2223,11 +2230,25 @@ restart:
 	if (new)
 		sp_insert(sp, new);
 	spin_unlock(&sp->lock);
-	if (new2) {
-		mpol_put(new2->policy);
-		kmem_cache_free(sn_cache, new2);
-	}
-	return 0;
+	err = 0;
+
+ err_out:
+	if (new2_pol)
+		mpol_put(new2_pol);
+        if (new2)
+                kmem_cache_free(sn_cache, new2);
+	return err;
+
+ alloc_new2:
+	spin_unlock(&sp->lock);
+	err = -ENOMEM;
+	new2 = kmem_cache_alloc(sn_cache, GFP_KERNEL);
+	if (!new2)
+		goto err_out;
+	new2_pol = kmem_cache_alloc(policy_cache, GFP_KERNEL);
+	if (!new2_pol)
+		goto err_out;
+	goto restart;
 }
 
 /**
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
