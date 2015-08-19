Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 38CC26B0038
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 04:20:56 -0400 (EDT)
Received: by pawq9 with SMTP id q9so55734524paw.3
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 01:20:56 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id kn4si3228063pdb.200.2015.08.19.01.20.55
        for <linux-mm@kvack.org>;
        Wed, 19 Aug 2015 01:20:55 -0700 (PDT)
Subject: Re: [Patch V3 3/9] sgi-xp: Replace cpu_to_node() with cpu_to_mem() to
 support memoryless node
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
 <1439781546-7217-4-git-send-email-jiang.liu@linux.intel.com>
 <alpine.DEB.2.10.1508171723290.5527@chino.kir.corp.google.com>
From: Jiang Liu <jiang.liu@linux.intel.com>
Message-ID: <55D43C63.7060802@linux.intel.com>
Date: Wed, 19 Aug 2015 16:20:51 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1508171723290.5527@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, Cliff Whickman <cpw@sgi.com>, Robin Holt <robinmholt@gmail.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

On 2015/8/18 8:25, David Rientjes wrote:
> On Mon, 17 Aug 2015, Jiang Liu wrote:
> 
>> Function xpc_create_gru_mq_uv() allocates memory with __GFP_THISNODE
>> flag set, which may cause permanent memory allocation failure on
>> memoryless node. So replace cpu_to_node() with cpu_to_mem() to better
>> support memoryless node. For node with memory, cpu_to_mem() is the same
>> as cpu_to_node().
>>
>> Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
>> ---
>>  drivers/misc/sgi-xp/xpc_uv.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/misc/sgi-xp/xpc_uv.c b/drivers/misc/sgi-xp/xpc_uv.c
>> index 95c894482fdd..9210981c0d5b 100644
>> --- a/drivers/misc/sgi-xp/xpc_uv.c
>> +++ b/drivers/misc/sgi-xp/xpc_uv.c
>> @@ -238,7 +238,7 @@ xpc_create_gru_mq_uv(unsigned int mq_size, int cpu, char *irq_name,
>>  
>>  	mq->mmr_blade = uv_cpu_to_blade_id(cpu);
>>  
>> -	nid = cpu_to_node(cpu);
>> +	nid = cpu_to_mem(cpu);
>>  	page = alloc_pages_exact_node(nid,
>>  				      GFP_KERNEL | __GFP_ZERO | __GFP_THISNODE,
>>  				      pg_order);
> 
> Why not simply fix build_zonelists_node() so that the __GFP_THISNODE 
> zonelists are set up to reference the zones of cpu_to_mem() for memoryless 
> nodes?
> 
> It seems much better than checking and maintaining every __GFP_THISNODE 
> user to determine if they are using a memoryless node or not.  I don't 
> feel that this solution is maintainable in the longterm.
Hi David,
	There are some usage cases, such as memory migration,
expect the page allocator rejecting memory allocation requests
if there is no memory on local node. So we have:
1) alloc_pages_node(cpu_to_node(), __GFP_THISNODE) to only allocate
memory from local node.
2) alloc_pages_node(cpu_to_mem(), __GFP_THISNODE) to allocate memory
from local node or from nearest node if local node is memoryless.

Not sure whether we could consolidate all callers specifying
__GFP_THISNODE flag into one case, need more investigating here.
Thanks!
Gerry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
