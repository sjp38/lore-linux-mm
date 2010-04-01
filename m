Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8CE396B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 22:16:13 -0400 (EDT)
Message-ID: <4BB40208.4010904@cn.fujitsu.com>
Date: Thu, 01 Apr 2010 10:16:40 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [PATCH V2 4/4] cpuset,mm: update task's mems_allowed lazily
References: <4B94CD2D.8070401@cn.fujitsu.com> <alpine.DEB.2.00.1003081330370.18502@chino.kir.corp.google.com> <4B95F802.9020308@cn.fujitsu.com> <20100311081548.GJ5812@laptop> <4B98C6DE.3060602@cn.fujitsu.com> <20100311110317.GL5812@laptop> <4BB31BDA.8080203@cn.fujitsu.com> <alpine.DEB.2.00.1003310324550.17661@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1003310324550.17661@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Nick Piggin <npiggin@suse.de>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Paul Menage <menage@google.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

on 2010-3-31 18:34, David Rientjes wrote:
> On Wed, 31 Mar 2010, Miao Xie wrote:
> 
>> diff --git a/mm/mmzone.c b/mm/mmzone.c
>> index f5b7d17..43ac21b 100644
>> --- a/mm/mmzone.c
>> +++ b/mm/mmzone.c
>> @@ -58,6 +58,7 @@ struct zoneref *next_zones_zonelist(struct zoneref *z,
>>  					nodemask_t *nodes,
>>  					struct zone **zone)
>>  {
>> +	nodemask_t tmp_nodes;
>>  	/*
>>  	 * Find the next suitable zone to use for the allocation.
>>  	 * Only filter based on nodemask if it's set
>> @@ -65,10 +66,16 @@ struct zoneref *next_zones_zonelist(struct zoneref *z,
>>  	if (likely(nodes == NULL))
>>  		while (zonelist_zone_idx(z) > highest_zoneidx)
>>  			z++;
>> -	else
>> -		while (zonelist_zone_idx(z) > highest_zoneidx ||
>> -				(z->zone && !zref_in_nodemask(z, nodes)))
>> -			z++;
>> +	else {
>> +		tmp_nodes = *nodes;
>> +		if (nodes_empty(tmp_nodes))
>> +			while (zonelist_zone_idx(z) > highest_zoneidx)
>> +				z++;
>> +		else
>> +			while (zonelist_zone_idx(z) > highest_zoneidx ||
>> +				(z->zone && !zref_in_nodemask(z, &tmp_nodes)))
>> +				z++;
>> +	}
>>  
>>  	*zone = zonelist_zone(z);
>>  	return z;
> 
> Unfortunately, you can't allocate a nodemask_t on the stack here because 
> this is used in the iteration for get_page_from_freelist() which can occur 
> very deep in the stack already and there's a probability of overflow.  
> Dynamically allocating a nodemask_t simply wouldn't scale here, either, 
> since it would allocate on every iteration of a zonelist.
> 

Maybe it is better to fix this problem by checking this function's return
value, because this function will return NULL if seeing an empty nodemask.

The new patch is attached below.
---
 kernel/cpuset.c |   11 +++++++++--
 mm/mempolicy.c  |   28 +++++++++++++++++++++++++++-
 2 files changed, 36 insertions(+), 3 deletions(-)

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
index 8034abd..0905b84 100644
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
@@ -1510,6 +1518,14 @@ unsigned slab_node(struct mempolicy *policy)
 		(void)first_zones_zonelist(zonelist, highest_zoneidx,
 							&policy->v.nodes,
 							&zone);
+		/*
+		 * When rebinding task->mempolicy, th kernel allocator
+		 * may see an empty nodemask, and first_zones_zonelist()
+		 * returns a NULL zone, In that case, we will use current
+		 * node.
+		 */
+		if (unlikely(zone == NULL))
+			return numa_node_id();
 		return zone->node;
 	}
 
@@ -1529,10 +1545,18 @@ static unsigned offset_il_node(struct mempolicy *pol,
 
 	if (!nnodes)
 		return numa_node_id();
+
 	target = (unsigned int)off % nnodes;
 	c = 0;
 	do {
 		nid = next_node(nid, pol->v.nodes);
+		/*
+		 * When rebinding task->mempolicy, th kernel allocator
+		 * may see an empty nodemask, and next_node() returns
+		 * MAX_NUMNODES, In that case, we will use current node.
+		 */
+		if (unlikely(nid == MAX_NUMNODES))
+			return numa_node_id();
 		c++;
 	} while (c <= target);
 	return nid;
@@ -1631,7 +1655,9 @@ bool init_nodemask_of_mempolicy(nodemask_t *mask)
 	case MPOL_BIND:
 		/* Fall through */
 	case MPOL_INTERLEAVE:
+		task_lock(current);
 		*mask =  mempolicy->v.nodes;
+		task_unlock(current);
 		break;
 
 	default:
-- 
1.6.5.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
