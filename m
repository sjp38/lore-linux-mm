Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1CC3F6B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 05:54:11 -0400 (EDT)
Message-ID: <4BB31BDA.8080203@cn.fujitsu.com>
Date: Wed, 31 Mar 2010 17:54:34 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [PATCH V2 4/4] cpuset,mm: update task's mems_allowed lazily
References: <4B94CD2D.8070401@cn.fujitsu.com> <alpine.DEB.2.00.1003081330370.18502@chino.kir.corp.google.com> <4B95F802.9020308@cn.fujitsu.com> <20100311081548.GJ5812@laptop> <4B98C6DE.3060602@cn.fujitsu.com> <20100311110317.GL5812@laptop>
In-Reply-To: <20100311110317.GL5812@laptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Paul Menage <menage@google.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

on 2010-3-11 19:03, Nick Piggin wrote:
>> Ok, I try to make a new patch by using seqlock.
> 
> Well... I do think seqlocks would be a bit simpler because they don't
> require this checking and synchronizing of this patch.
> 
> But you are right: on non-x86 architectures seqlocks would probably be
> more costly than your patch in the fastpaths. Unless you can avoid
> using the seqlock in fastpaths and just have callers handle the rare
> case of an empty nodemask.
> 
> cpuset_node_allowed_*wall doesn't need anything because it is just
> interested in one bit in the mask.
> 
> cpuset_mem_spread_node doesn't matter because it will loop around and
> try again if it doesn't find any nodes online.
> 
> cpuset_mems_allowed seems totally broken anyway
> 
> etc.
> 
> This approach might take a little more work, but I think it might be the
> best way. 

Hi, Nick Piggin

The following is the new patch made by your idea. Could you review it?

Thanks!
Miao
---
 kernel/cpuset.c |   11 +++++++++--
 mm/mempolicy.c  |   20 +++++++++++++++++---
 mm/mmzone.c     |   15 +++++++++++----
 3 files changed, 37 insertions(+), 9 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index d109467..fbb1f1c 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -952,8 +952,6 @@ static void cpuset_migrate_mm(struct mm_struct *mm, const nodemask_t *from,
 static void cpuset_change_task_nodemask(struct task_struct *tsk,
 					nodemask_t *newmems)
 {
-	nodes_or(tsk->mems_allowed, tsk->mems_allowed, *newmems);
-	mpol_rebind_task(tsk, &tsk->mems_allowed);
 	mpol_rebind_task(tsk, newmems);
 	tsk->mems_allowed = *newmems;
 }
@@ -2442,6 +2440,15 @@ int cpuset_mem_spread_node(void)
 	node = next_node(current->cpuset_mem_spread_rotor, current->mems_allowed);
 	if (node == MAX_NUMNODES)
 		node = first_node(current->mems_allowed);
+
+	/*
+	 * if node is still MAX_NUMNODES, that means the kernel allocator saw
+	 * an empty nodemask. In that case, the kernel allocator allocate
+	 * memory on the current node.
+	 */
+	if (unlikely(node == MAX_NUMNODES))
+		node = numa_node_id();
+
 	current->cpuset_mem_spread_rotor = node;
 	return node;
 }
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 8034abd..75e819e 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1449,8 +1449,16 @@ static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *policy)
 		 * the first node in the mask instead.
 		 */
 		if (unlikely(gfp & __GFP_THISNODE) &&
-				unlikely(!node_isset(nd, policy->v.nodes)))
+				unlikely(!node_isset(nd, policy->v.nodes))) {
 			nd = first_node(policy->v.nodes);
+			/*
+			 * When rebinding task->mempolicy, th kernel allocator
+			 * may see an empty nodemask, and first_node() returns
+			 * MAX_NUMNODES, In that case, we will use current node.
+			 */
+			if (unlikely(nd == MAX_NUMNODES))
+				nd = numa_node_id();
+		}
 		break;
 	case MPOL_INTERLEAVE: /* should not happen */
 		break;
@@ -1522,17 +1530,21 @@ unsigned slab_node(struct mempolicy *policy)
 static unsigned offset_il_node(struct mempolicy *pol,
 		struct vm_area_struct *vma, unsigned long off)
 {
-	unsigned nnodes = nodes_weight(pol->v.nodes);
+	nodemask_t tmp_nodes;
+	unsigned nnodes;
 	unsigned target;
 	int c;
 	int nid = -1;
 
+	tmp_nodes = pol->v.nodes;
+	nnodes = nodes_weight(tmp_nodes);
 	if (!nnodes)
 		return numa_node_id();
+
 	target = (unsigned int)off % nnodes;
 	c = 0;
 	do {
-		nid = next_node(nid, pol->v.nodes);
+		nid = next_node(nid, tmp_nodes);
 		c++;
 	} while (c <= target);
 	return nid;
@@ -1631,7 +1643,9 @@ bool init_nodemask_of_mempolicy(nodemask_t *mask)
 	case MPOL_BIND:
 		/* Fall through */
 	case MPOL_INTERLEAVE:
+		task_lock(current);
 		*mask =  mempolicy->v.nodes;
+		task_unlock(current);
 		break;
 
 	default:
diff --git a/mm/mmzone.c b/mm/mmzone.c
index f5b7d17..43ac21b 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -58,6 +58,7 @@ struct zoneref *next_zones_zonelist(struct zoneref *z,
 					nodemask_t *nodes,
 					struct zone **zone)
 {
+	nodemask_t tmp_nodes;
 	/*
 	 * Find the next suitable zone to use for the allocation.
 	 * Only filter based on nodemask if it's set
@@ -65,10 +66,16 @@ struct zoneref *next_zones_zonelist(struct zoneref *z,
 	if (likely(nodes == NULL))
 		while (zonelist_zone_idx(z) > highest_zoneidx)
 			z++;
-	else
-		while (zonelist_zone_idx(z) > highest_zoneidx ||
-				(z->zone && !zref_in_nodemask(z, nodes)))
-			z++;
+	else {
+		tmp_nodes = *nodes;
+		if (nodes_empty(tmp_nodes))
+			while (zonelist_zone_idx(z) > highest_zoneidx)
+				z++;
+		else
+			while (zonelist_zone_idx(z) > highest_zoneidx ||
+				(z->zone && !zref_in_nodemask(z, &tmp_nodes)))
+				z++;
+	}
 
 	*zone = zonelist_zone(z);
 	return z;
-- 
1.6.5.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
