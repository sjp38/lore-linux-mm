Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 63B726B0038
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 04:49:44 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 6so2212911wra.23
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 01:49:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n7si7062642wmi.109.2017.04.12.01.49.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Apr 2017 01:49:42 -0700 (PDT)
Subject: Re: [RFC 2/6] mm, mempolicy: stop adjusting current->il_next in
 mpol_rebind_nodemask()
References: <20170411140609.3787-1-vbabka@suse.cz>
 <20170411140609.3787-3-vbabka@suse.cz>
 <alpine.DEB.2.20.1704111227080.25069@east.gentwo.org>
 <9665a022-197a-4b02-8813-66aca252f0f9@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <97045760-77eb-c892-9bcb-daad10a1d91d@suse.cz>
Date: Wed, 12 Apr 2017 10:49:37 +0200
MIME-Version: 1.0
In-Reply-To: <9665a022-197a-4b02-8813-66aca252f0f9@suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 04/11/2017 09:03 PM, Vlastimil Babka wrote:
> On 11.4.2017 19:32, Christoph Lameter wrote:
>> On Tue, 11 Apr 2017, Vlastimil Babka wrote:
>>
>>> The task->il_next variable remembers the last allocation node for task's
>>> MPOL_INTERLEAVE policy. mpol_rebind_nodemask() updates interleave and
>>> bind mempolicies due to changing cpuset mems. Currently it also tries to
>>> make sure that current->il_next is valid within the updated nodemask. This is
>>> bogus, because 1) we are updating potentially any task's mempolicy, not just
>>> current, and 2) we might be updating per-vma mempolicy, not task one.
>>>
>>> The interleave_nodes() function that uses il_next can cope fine with the value
>>> not being within the currently allowed nodes, so this hasn't manifested as an
>>> actual issue. Thus it also won't be an issue if we just remove this adjustment
>>> completely.
>>
>> Well, interleave_nodes() will then potentially return a node outside of
>> the allowed memory policy when its called for the first time after
>> mpol_rebind_.. . But thenn it will find the next node within the
>> nodemask and work correctly for the next invocations.
> 
> Hmm, you're right. But that could be easily fixed if il_next became il_prev, so
> we would return the result of next_node_in(il_prev) and also store it as the new
> il_prev, right? I somehow assumed it already worked that way.

Like this?
----8<----
commit 0ec64a0b8e614ea655328d0fb539447c407ba7c1
Author: Vlastimil Babka <vbabka@suse.cz>
Date:   Mon Apr 3 13:11:32 2017 +0200

    mm, mempolicy: stop adjusting current->il_next in mpol_rebind_nodemask()
    
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

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 050d7113924a..9aca0db1e588 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -886,7 +886,7 @@ struct task_struct {
 #ifdef CONFIG_NUMA
 	/* Protected by alloc_lock: */
 	struct mempolicy		*mempolicy;
-	short				il_next;
+	short				il_prev;
 	short				pref_node_fork;
 #endif
 #ifdef CONFIG_NUMA_BALANCING
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 37d0b334bfe9..25f9bde58521 100644
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
@@ -863,6 +856,18 @@ static int lookup_node(unsigned long addr)
 	return err;
 }
 
+/* Do dynamic interleaving for a process */
+static unsigned interleave_nodes(struct mempolicy *policy, bool update_prev)
+{
+	unsigned next;
+	struct task_struct *me = current;
+
+	next = next_node_in(me->il_prev, policy->v.nodes);
+	if (next < MAX_NUMNODES && update_prev)
+		me->il_prev = next;
+	return next;
+}
+
 /* Retrieve NUMA policy */
 static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 			     unsigned long addr, unsigned long flags)
@@ -916,7 +921,7 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 			*policy = err;
 		} else if (pol == current->mempolicy &&
 				pol->mode == MPOL_INTERLEAVE) {
-			*policy = current->il_next;
+			*policy = interleave_nodes(current->mempolicy, false);
 		} else {
 			err = -EINVAL;
 			goto out;
@@ -1694,19 +1699,6 @@ static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *policy,
 	return node_zonelist(nd, gfp);
 }
 
-/* Do dynamic interleaving for a process */
-static unsigned interleave_nodes(struct mempolicy *policy)
-{
-	unsigned nid, next;
-	struct task_struct *me = current;
-
-	nid = me->il_next;
-	next = next_node_in(nid, policy->v.nodes);
-	if (next < MAX_NUMNODES)
-		me->il_next = next;
-	return nid;
-}
-
 /*
  * Depending on the memory policy provide a node from which to allocate the
  * next slab entry.
@@ -1731,7 +1723,7 @@ unsigned int mempolicy_slab_node(void)
 		return policy->v.preferred_node;
 
 	case MPOL_INTERLEAVE:
-		return interleave_nodes(policy);
+		return interleave_nodes(policy, true);
 
 	case MPOL_BIND: {
 		struct zoneref *z;
@@ -1794,7 +1786,7 @@ static inline unsigned interleave_nid(struct mempolicy *pol,
 		off += (addr - vma->vm_start) >> shift;
 		return offset_il_node(pol, vma, off);
 	} else
-		return interleave_nodes(pol);
+		return interleave_nodes(pol, true);
 }
 
 #ifdef CONFIG_HUGETLBFS
@@ -2060,7 +2052,8 @@ struct page *alloc_pages_current(gfp_t gfp, unsigned order)
 	 * nor system default_policy
 	 */
 	if (pol->mode == MPOL_INTERLEAVE)
-		page = alloc_page_interleave(gfp, order, interleave_nodes(pol));
+		page = alloc_page_interleave(gfp, order,
+				interleave_nodes(pol, true));
 	else
 		page = __alloc_pages_nodemask(gfp, order,
 				policy_zonelist(gfp, pol, numa_node_id()),


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
