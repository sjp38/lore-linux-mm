Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 624156B0068
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 12:58:48 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/5] mempolicy: fix a race in shared_policy_replace()
Date: Tue,  9 Oct 2012 17:58:39 +0100
Message-Id: <1349801921-16598-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1349801921-16598-1-git-send-email-mgorman@suse.de>
References: <1349801921-16598-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Jones <davej@redhat.com>, Christoph Lameter <cl@linux.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>

commit b22d127a39ddd10d93deee3d96e643657ad53a49 upstream.

shared_policy_replace() use of sp_alloc() is unsafe.  1) sp_node cannot
be dereferenced if sp->lock is not held and 2) another thread can modify
sp_node between spin_unlock for allocating a new sp node and next
spin_lock.  The bug was introduced before 2.6.12-rc2.

Kosaki's original patch for this problem was to allocate an sp node and
policy within shared_policy_replace and initialise it when the lock is
reacquired.  I was not keen on this approach because it partially
duplicates sp_alloc().  As the paths were sp->lock is taken are not that
performance critical this patch converts sp->lock to sp->mutex so it can
sleep when calling sp_alloc().

[kosaki.motohiro@jp.fujitsu.com: Original patch]
Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Christoph Lameter <cl@linux.com>
Cc: Josh Boyer <jwboyer@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mempolicy.h |    2 +-
 mm/mempolicy.c            |   37 ++++++++++++++++---------------------
 2 files changed, 17 insertions(+), 22 deletions(-)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 95b738c..df08254 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -188,7 +188,7 @@ struct sp_node {
 
 struct shared_policy {
 	struct rb_root root;
-	spinlock_t lock;
+	struct mutex mutex;
 };
 
 void mpol_shared_policy_init(struct shared_policy *sp, struct mempolicy *mpol);
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index f0728ae..b2f12ec 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2083,7 +2083,7 @@ bool __mpol_equal(struct mempolicy *a, struct mempolicy *b)
  */
 
 /* lookup first element intersecting start-end */
-/* Caller holds sp->lock */
+/* Caller holds sp->mutex */
 static struct sp_node *
 sp_lookup(struct shared_policy *sp, unsigned long start, unsigned long end)
 {
@@ -2147,13 +2147,13 @@ mpol_shared_policy_lookup(struct shared_policy *sp, unsigned long idx)
 
 	if (!sp->root.rb_node)
 		return NULL;
-	spin_lock(&sp->lock);
+	mutex_lock(&sp->mutex);
 	sn = sp_lookup(sp, idx, idx+1);
 	if (sn) {
 		mpol_get(sn->policy);
 		pol = sn->policy;
 	}
-	spin_unlock(&sp->lock);
+	mutex_unlock(&sp->mutex);
 	return pol;
 }
 
@@ -2193,10 +2193,10 @@ static struct sp_node *sp_alloc(unsigned long start, unsigned long end,
 static int shared_policy_replace(struct shared_policy *sp, unsigned long start,
 				 unsigned long end, struct sp_node *new)
 {
-	struct sp_node *n, *new2 = NULL;
+	struct sp_node *n;
+	int ret = 0;
 
-restart:
-	spin_lock(&sp->lock);
+	mutex_lock(&sp->mutex);
 	n = sp_lookup(sp, start, end);
 	/* Take care of old policies in the same range. */
 	while (n && n->start < end) {
@@ -2209,16 +2209,14 @@ restart:
 		} else {
 			/* Old policy spanning whole new range. */
 			if (n->end > end) {
+				struct sp_node *new2;
+				new2 = sp_alloc(end, n->end, n->policy);
 				if (!new2) {
-					spin_unlock(&sp->lock);
-					new2 = sp_alloc(end, n->end, n->policy);
-					if (!new2)
-						return -ENOMEM;
-					goto restart;
+					ret = -ENOMEM;
+					goto out;
 				}
 				n->end = start;
 				sp_insert(sp, new2);
-				new2 = NULL;
 				break;
 			} else
 				n->end = start;
@@ -2229,12 +2227,9 @@ restart:
 	}
 	if (new)
 		sp_insert(sp, new);
-	spin_unlock(&sp->lock);
-	if (new2) {
-		mpol_put(new2->policy);
-		kmem_cache_free(sn_cache, new2);
-	}
-	return 0;
+out:
+	mutex_unlock(&sp->mutex);
+	return ret;
 }
 
 /**
@@ -2252,7 +2247,7 @@ void mpol_shared_policy_init(struct shared_policy *sp, struct mempolicy *mpol)
 	int ret;
 
 	sp->root = RB_ROOT;		/* empty tree == default mempolicy */
-	spin_lock_init(&sp->lock);
+	mutex_init(&sp->mutex);
 
 	if (mpol) {
 		struct vm_area_struct pvma;
@@ -2318,7 +2313,7 @@ void mpol_free_shared_policy(struct shared_policy *p)
 
 	if (!p->root.rb_node)
 		return;
-	spin_lock(&p->lock);
+	mutex_lock(&p->mutex);
 	next = rb_first(&p->root);
 	while (next) {
 		n = rb_entry(next, struct sp_node, nd);
@@ -2327,7 +2322,7 @@ void mpol_free_shared_policy(struct shared_policy *p)
 		mpol_put(n->policy);
 		kmem_cache_free(sn_cache, n);
 	}
-	spin_unlock(&p->lock);
+	mutex_unlock(&p->mutex);
 }
 
 /* assumes fs == KERNEL_DS */
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
