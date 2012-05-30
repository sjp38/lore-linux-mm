Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id B06EB6B006C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 05:03:19 -0400 (EDT)
Received: by vcbfl10 with SMTP id fl10so3498791vcb.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 02:03:18 -0700 (PDT)
From: kosaki.motohiro@gmail.com
Subject: [PATCH 4/6] mempolicy: fix refcount leak in mpol_set_shared_policy()
Date: Wed, 30 May 2012 05:02:07 -0400
Message-Id: <1338368529-21784-5-git-send-email-kosaki.motohiro@gmail.com>
In-Reply-To: <1338368529-21784-1-git-send-email-kosaki.motohiro@gmail.com>
References: <1338368529-21784-1-git-send-email-kosaki.motohiro@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux.com>, stable@vger.kernel.org, hughd@google.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

When shared_policy_replace() failure, new->policy is not freed correctly.
The real problem is, shared mempolicy codes directly call kmem_cache_free()
in multiple place. It can be easily mistake.

This patch creates proper wrapper function and uses it. The bug was introduced
pre-git age (IOW, before 2.6.12-rc2).

Cc: Dave Jones <davej@redhat.com>,
Cc: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>,
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: <stable@vger.kernel.org>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/mempolicy.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d97d2db..7fb7d51 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2150,12 +2150,17 @@ mpol_shared_policy_lookup(struct shared_policy *sp, unsigned long idx)
 	return pol;
 }
 
+static void sp_free(struct sp_node *n)
+{
+	mpol_put(n->policy);
+	kmem_cache_free(sn_cache, n);
+}
+
 static void sp_delete(struct shared_policy *sp, struct sp_node *n)
 {
 	pr_debug("deleting %lx-l%lx\n", n->start, n->end);
 	rb_erase(&n->nd, &sp->root);
-	mpol_put(n->policy);
-	kmem_cache_free(sn_cache, n);
+	sp_free(n);
 }
 
 static void sp_node_init(struct sp_node *node, unsigned long start,
@@ -2320,7 +2325,7 @@ int mpol_set_shared_policy(struct shared_policy *info,
 	}
 	err = shared_policy_replace(info, vma->vm_pgoff, vma->vm_pgoff+sz, new);
 	if (err && new)
-		kmem_cache_free(sn_cache, new);
+		sp_free(new);
 	return err;
 }
 
@@ -2337,9 +2342,7 @@ void mpol_free_shared_policy(struct shared_policy *p)
 	while (next) {
 		n = rb_entry(next, struct sp_node, nd);
 		next = rb_next(&n->nd);
-		rb_erase(&n->nd, &p->root);
-		mpol_put(n->policy);
-		kmem_cache_free(sn_cache, n);
+		sp_delete(p, n);
 	}
 	spin_unlock(&p->lock);
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
