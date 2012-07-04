Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 89B826B005D
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 23:02:00 -0400 (EDT)
From: Cong Wang <amwang@redhat.com>
Subject: [Patch] mm/policy: use int instead of unsigned for nid
Date: Wed,  4 Jul 2012 11:01:38 +0800
Message-Id: <1341370901-14187-1-git-send-email-amwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, WANG Cong <xiyou.wangcong@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org

From: WANG Cong <xiyou.wangcong@gmail.com>

'nid' should be 'int', not 'unsigned'.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>

---
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 1d771e4..3cabe81 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1580,9 +1580,9 @@ static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *policy,
 }
 
 /* Do dynamic interleaving for a process */
-static unsigned interleave_nodes(struct mempolicy *policy)
+static int interleave_nodes(struct mempolicy *policy)
 {
-	unsigned nid, next;
+	int nid, next;
 	struct task_struct *me = current;
 
 	nid = me->il_next;
@@ -1638,7 +1638,7 @@ unsigned slab_node(struct mempolicy *policy)
 }
 
 /* Do static interleaving for a VMA with known offset. */
-static unsigned offset_il_node(struct mempolicy *pol,
+static int offset_il_node(struct mempolicy *pol,
 		struct vm_area_struct *vma, unsigned long off)
 {
 	unsigned nnodes = nodes_weight(pol->v.nodes);
@@ -1658,7 +1658,7 @@ static unsigned offset_il_node(struct mempolicy *pol,
 }
 
 /* Determine a node number for interleave */
-static inline unsigned interleave_nid(struct mempolicy *pol,
+static inline int interleave_nid(struct mempolicy *pol,
 		 struct vm_area_struct *vma, unsigned long addr, int shift)
 {
 	if (vma) {
@@ -1827,7 +1827,7 @@ out:
 /* Allocate a page in interleaved policy.
    Own path because it needs to do special accounting. */
 static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
-					unsigned nid)
+					int nid)
 {
 	struct zonelist *zl;
 	struct page *page;
@@ -1876,7 +1876,7 @@ retry_cpuset:
 	cpuset_mems_cookie = get_mems_allowed();
 
 	if (unlikely(pol->mode == MPOL_INTERLEAVE)) {
-		unsigned nid;
+		int nid;
 
 		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT + order);
 		mpol_cond_put(pol);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
