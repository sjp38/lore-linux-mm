Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id ED4A56B0044
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 03:17:09 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id rq2so1123873pbb.14
        for <linux-mm@kvack.org>; Wed, 07 Nov 2012 00:17:09 -0800 (PST)
Date: Wed, 7 Nov 2012 00:17:06 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, mempolicy: remove duplicate code
Message-ID: <alpine.DEB.2.00.1211070016080.21854@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Remove some duplicate code and simplify alloc_pages_vma().  No functional
change.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/mempolicy.c |   21 ++++-----------------
 1 file changed, 4 insertions(+), 17 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1907,7 +1907,6 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 		unsigned long addr, int node)
 {
 	struct mempolicy *pol;
-	struct zonelist *zl;
 	struct page *page;
 	unsigned int cpuset_mems_cookie;
 
@@ -1926,23 +1925,11 @@ retry_cpuset:
 
 		return page;
 	}
-	zl = policy_zonelist(gfp, pol, node);
-	if (unlikely(mpol_needs_cond_ref(pol))) {
-		/*
-		 * slow path: ref counted shared policy
-		 */
-		struct page *page =  __alloc_pages_nodemask(gfp, order,
-						zl, policy_nodemask(gfp, pol));
-		__mpol_put(pol);
-		if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
-			goto retry_cpuset;
-		return page;
-	}
-	/*
-	 * fast path:  default or task policy
-	 */
-	page = __alloc_pages_nodemask(gfp, order, zl,
+	page = __alloc_pages_nodemask(gfp, order,
+				      policy_zonelist(gfp, pol, node),
 				      policy_nodemask(gfp, pol));
+	if (unlikely(mpol_needs_cond_ref(pol)))
+		__mpol_put(pol);
 	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
 		goto retry_cpuset;
 	return page;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
