Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2DAA66B02E1
	for <linux-mm@kvack.org>; Wed, 17 May 2017 04:11:58 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u96so635523wrc.7
        for <linux-mm@kvack.org>; Wed, 17 May 2017 01:11:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 61si1361429wrp.328.2017.05.17.01.11.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 May 2017 01:11:56 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 2/6] mm, mempolicy: stop adjusting current->il_next in mpol_rebind_nodemask()
Date: Wed, 17 May 2017 10:11:36 +0200
Message-Id: <20170517081140.30654-3-vbabka@suse.cz>
In-Reply-To: <20170517081140.30654-1-vbabka@suse.cz>
References: <20170517081140.30654-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

The task->il_next variable stores the next allocation node id for task's
MPOL_INTERLEAVE policy. mpol_rebind_nodemask() updates interleave and
bind mempolicies due to changing cpuset mems. Currently it also tries to
make sure that current->il_next is valid within the updated nodemask. This is
bogus, because 1) we are updating potentially any task's mempolicy, not just
current, and 2) we might be updating a per-vma mempolicy, not task one.

The interleave_nodes() function that uses il_next can cope fine with the value
not being within the currently allowed nodes, so this hasn't manifested as an
actual issue.

We can remove the need for updating il_next completely by changing it to
il_prev and store the node id of the previous interleave allocation instead of
the next id. Then interleave_nodes() can calculate the next id using the
current nodemask and also store it as il_prev, except when querying the next
node via do_get_mempolicy().

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/sched.h |  2 +-
 mm/mempolicy.c        | 22 +++++++---------------
 2 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 6a97386c785e..b72bbfec01f9 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -884,7 +884,7 @@ struct task_struct {
 #ifdef CONFIG_NUMA
 	/* Protected by alloc_lock: */
 	struct mempolicy		*mempolicy;
-	short				il_next;
+	short				il_prev;
 	short				pref_node_fork;
 #endif
 #ifdef CONFIG_NUMA_BALANCING
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 37d0b334bfe9..d77177c7283b 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -349,12 +349,6 @@ static void mpol_rebind_nodemask(struct mempolicy *pol, const nodemask_t *nodes,
 		pol->v.nodes = tmp;
 	else
 		BUG();
-
-	if (!node_isset(current->il_next, tmp)) {
-		current->il_next = next_node_in(current->il_next, tmp);
-		if (current->il_next >= MAX_NUMNODES)
-			current->il_next = numa_node_id();
-	}
 }
 
 static void mpol_rebind_preferred(struct mempolicy *pol,
@@ -812,9 +806,8 @@ static long do_set_mempolicy(unsigned short mode, unsigned short flags,
 	}
 	old = current->mempolicy;
 	current->mempolicy = new;
-	if (new && new->mode == MPOL_INTERLEAVE &&
-	    nodes_weight(new->v.nodes))
-		current->il_next = first_node(new->v.nodes);
+	if (new && new->mode == MPOL_INTERLEAVE)
+		current->il_prev = MAX_NUMNODES-1;
 	task_unlock(current);
 	mpol_put(old);
 	ret = 0;
@@ -916,7 +909,7 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 			*policy = err;
 		} else if (pol == current->mempolicy &&
 				pol->mode == MPOL_INTERLEAVE) {
-			*policy = current->il_next;
+			*policy = next_node_in(current->il_prev, pol->v.nodes);
 		} else {
 			err = -EINVAL;
 			goto out;
@@ -1697,14 +1690,13 @@ static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *policy,
 /* Do dynamic interleaving for a process */
 static unsigned interleave_nodes(struct mempolicy *policy)
 {
-	unsigned nid, next;
+	unsigned next;
 	struct task_struct *me = current;
 
-	nid = me->il_next;
-	next = next_node_in(nid, policy->v.nodes);
+	next = next_node_in(me->il_prev, policy->v.nodes);
 	if (next < MAX_NUMNODES)
-		me->il_next = next;
-	return nid;
+		me->il_prev = next;
+	return next;
 }
 
 /*
-- 
2.12.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
