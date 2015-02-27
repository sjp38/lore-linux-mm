Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 718A46B0071
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 17:17:51 -0500 (EST)
Received: by iecat20 with SMTP id at20so34619549iec.12
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 14:17:51 -0800 (PST)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com. [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id l7si4515727ioi.71.2015.02.27.14.17.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Feb 2015 14:17:51 -0800 (PST)
Received: by igjz20 with SMTP id z20so4211000igj.4
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 14:17:51 -0800 (PST)
Date: Fri, 27 Feb 2015 14:17:49 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2 3/3] kernel, cpuset: remove exception for __GFP_THISNODE
In-Reply-To: <alpine.DEB.2.10.1502271415510.7225@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1502271417270.7225@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com> <alpine.DEB.2.10.1502271415510.7225@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Pravin Shelar <pshelar@nicira.com>, Jarno Rajahalme <jrajahalme@nicira.com>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, cgroups@vger.kernel.org, dev@openvswitch.org

Nothing calls __cpuset_node_allowed() with __GFP_THISNODE set anymore, so
remove the obscure comment about it and its special-case exception.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 kernel/cpuset.c | 18 +++++-------------
 1 file changed, 5 insertions(+), 13 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -2445,20 +2445,12 @@ static struct cpuset *nearest_hardwall_ancestor(struct cpuset *cs)
  * @node: is this an allowed node?
  * @gfp_mask: memory allocation flags
  *
- * If we're in interrupt, yes, we can always allocate.  If __GFP_THISNODE is
- * set, yes, we can always allocate.  If node is in our task's mems_allowed,
- * yes.  If it's not a __GFP_HARDWALL request and this node is in the nearest
- * hardwalled cpuset ancestor to this task's cpuset, yes.  If the task has been
- * OOM killed and has access to memory reserves as specified by the TIF_MEMDIE
- * flag, yes.
+ * If we're in interrupt, yes, we can always allocate.  If @node is set in
+ * current's mems_allowed, yes.  If it's not a __GFP_HARDWALL request and this
+ * node is set in the nearest hardwalled cpuset ancestor to current's cpuset,
+ * yes.  If current has access to memory reserves due to TIF_MEMDIE, yes.
  * Otherwise, no.
  *
- * The __GFP_THISNODE placement logic is really handled elsewhere,
- * by forcibly using a zonelist starting at a specified node, and by
- * (in get_page_from_freelist()) refusing to consider the zones for
- * any node on the zonelist except the first.  By the time any such
- * calls get to this routine, we should just shut up and say 'yes'.
- *
  * GFP_USER allocations are marked with the __GFP_HARDWALL bit,
  * and do not allow allocations outside the current tasks cpuset
  * unless the task has been OOM killed as is marked TIF_MEMDIE.
@@ -2494,7 +2486,7 @@ int __cpuset_node_allowed(int node, gfp_t gfp_mask)
 	int allowed;			/* is allocation in zone z allowed? */
 	unsigned long flags;
 
-	if (in_interrupt() || (gfp_mask & __GFP_THISNODE))
+	if (in_interrupt())
 		return 1;
 	if (node_isset(node, current->mems_allowed))
 		return 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
