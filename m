Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m2BIlhuU016078
	for <linux-mm@kvack.org>; Wed, 12 Mar 2008 05:47:43 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2BIlvS24636798
	for <linux-mm@kvack.org>; Wed, 12 Mar 2008 05:47:57 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2BIluq8027102
	for <linux-mm@kvack.org>; Wed, 12 Mar 2008 05:47:57 +1100
Message-ID: <47D6D3CC.5070705@linux.vnet.ibm.com>
Date: Wed, 12 Mar 2008 00:17:40 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] Move memory controller allocations to their own slabs
 (v2)
References: <20080311061836.6664.5072.sendpatchset@localhost.localdomain> <Pine.LNX.4.64.0803111230410.15328@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0803111230410.15328@blonde.site>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Tue, 11 Mar 2008, Balbir Singh wrote:
>> Move the memory controller data structure page_cgroup to its own slab cache.
>> It saves space on the system, allocations are not necessarily pushed to order
>> of 2 and should provide performance benefits. Users who disable the memory
>> controller can also double check that the memory controller is not allocating
>> page_cgroup's.
>>
>> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> I certainly approve of giving page_cgroups their own kmem_cache
> (and agree with Kame that it was overkill for the zones).
> 

Thanks, yes, I agreed with Kame as well.

> But I don't agree with the SLAB_HWCACHE_ALIGN you've slipped into
> this version.  That'll be wasting a lot of (all? more than?) the
> space you're trying to save with a kmem_cache, won't it?  Let me
> talk about that separately, in reply to the mail where you report
> the numbers.
> 

I slipped in the SLAB_HWCACHE_ALIGN to reduce page cgroup cache contention. Yes
you are right, we do lose out on space due to the extra alignment. My test
results (lmbench) on kmalloc, slub and slab are not very conclusive about
performance. SLUB had the best results w.r.t protection faults and context switches.

> Are you proposing this page_cgroup_cache mod for 2.6.25 or for 2.6.26?

I am OK with any version as long as we can get good feedback. I suspect the
feature will be useful for 2.6.25.

> I ask because I want to build upon it to fix up some GFP_ flag issues:
> I think we end up claiming the page_cgroups are __GFP_MOVABLE when they
> should be called __GFP_RECLAIMABLE; but I don't know how seriously we
> take MOVABLE/RECLAIMABLE discrepancies at present.
> 

That's a very good question. I am not sure about the correct answer to that
myself at the moment.

> There's a patch I'd also like to build upon from Christoph in -mm
> (remove-set_migrateflags.patch), which sheds light on a similar issue
> with radix_tree_nodes).  It's importance is again dependent on how
> seriously we're taking MOVABLE/RECLAIMABLE discrepancies.
> 

I'll look at Christoph's patch and see what it addresses to understand the
MOVABLE/RECLAIMABLE discrepancy better.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
