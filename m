Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id E60106B004D
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 03:36:11 -0400 (EDT)
Message-ID: <50937943.2040302@cn.fujitsu.com>
Date: Fri, 02 Nov 2012 15:41:55 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PART3 Patch 00/14] introduce N_MEMORY
References: <1351670652-9932-1-git-send-email-wency@cn.fujitsu.com> <alpine.DEB.2.00.1210311112010.8809@chino.kir.corp.google.com> <509212FC.8070802@cn.fujitsu.com> <alpine.DEB.2.00.1211011431130.19373@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1211011431130.19373@chino.kir.corp.google.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, Yinghai Lu <yinghai@kernel.org>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>

At 11/02/2012 05:36 AM, David Rientjes Wrote:
> On Thu, 1 Nov 2012, Wen Congyang wrote:
> 
>>> This doesn't describe why we need the new node state, unfortunately.  It 
>>
>> 1. Somethimes, we use the node which contains the memory that can be used by
>>    kernel.
>> 2. Sometimes, we use the node which contains the memory.
>>
>> In case1, we use N_HIGH_MEMORY, and we use N_MEMORY in case2.
>>
> 
> Yeah, that's clear, but the question is still _why_ we want two different 
> nodemasks.  I know that this part of the patchset simply introduces the 
> new nodemask because the name "N_MEMORY" is more clear than 
> "N_HIGH_MEMORY", but there's no real incentive for making that change by 
> introducing a new nodemask where a simple rename would suffice.
> 
> I can only assume that you want to later use one of them for a different 
> purpose: those that do not include nodes that consist of only 
> ZONE_MOVABLE.  But that change for MPOL_BIND is nacked since it 
> significantly changes the semantics of set_mempolicy() and you can't break 
> userspace (see my response to that from yesterday).  Until that problem is 
> addressed, then there's no reason for the additional nodemask so nack on 
> this series as well.
> 

I still think that we need two nodemasks: one store the node which has memory
that the kernel can use, and one store the node which has memory.

For example:

==========================
static void *__meminit alloc_page_cgroup(size_t size, int nid)
{
	gfp_t flags = GFP_KERNEL | __GFP_ZERO | __GFP_NOWARN;
	void *addr = NULL;

	addr = alloc_pages_exact_nid(nid, size, flags);
	if (addr) {
		kmemleak_alloc(addr, size, 1, flags);
		return addr;
	}

	if (node_state(nid, N_HIGH_MEMORY))
		addr = vzalloc_node(size, nid);
	else
		addr = vzalloc(size);

	return addr;
}
==========================
If the node only has ZONE_MOVABLE memory, we should use vzalloc().
So we should have a mask that stores the node which has memory that
the kernel can use.

==========================
static int mpol_set_nodemask(struct mempolicy *pol,
		     const nodemask_t *nodes, struct nodemask_scratch *nsc)
{
	int ret;

	/* if mode is MPOL_DEFAULT, pol is NULL. This is right. */
	if (pol == NULL)
		return 0;
	/* Check N_HIGH_MEMORY */
	nodes_and(nsc->mask1,
		  cpuset_current_mems_allowed, node_states[N_HIGH_MEMORY]);
...
		if (pol->flags & MPOL_F_RELATIVE_NODES)
			mpol_relative_nodemask(&nsc->mask2, nodes,&nsc->mask1);
		else
			nodes_and(nsc->mask2, *nodes, nsc->mask1);
...
}
==========================
If the user specifies 2 nodes: one has ZONE_MOVABLE memory, and the other one doesn't.
nsc->mask2 should contain these 2 nodes. So we should hava a mask that store the node
which has memory.

There maybe something wrong in the change for MPOL_BIND. But this patchset is needed.

Thanks
Wen Congyang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
