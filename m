Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id C7EC66B0038
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 04:09:13 -0400 (EDT)
Received: by pdbmi9 with SMTP id mi9so37465593pdb.3
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 01:09:13 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id uj2si35072627pab.146.2015.08.19.01.09.12
        for <linux-mm@kvack.org>;
        Wed, 19 Aug 2015 01:09:12 -0700 (PDT)
Subject: Re: [Patch V3 0/9] Enable memoryless node support for x86
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
 <55D302CA.9010703@cn.fujitsu.com>
From: Jiang Liu <jiang.liu@linux.intel.com>
Message-ID: <55D439A4.6020407@linux.intel.com>
Date: Wed, 19 Aug 2015 16:09:08 +0800
MIME-Version: 1.0
In-Reply-To: <55D302CA.9010703@cn.fujitsu.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tejun Heo <tj@kernel.org>
Cc: Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

On 2015/8/18 18:02, Tang Chen wrote:
> 
> On 08/17/2015 11:18 AM, Jiang Liu wrote:
>> This is the third version to enable memoryless node support on x86
>> platforms. The previous version (https://lkml.org/lkml/2014/7/11/75)
>> blindly replaces numa_node_id()/cpu_to_node() with numa_mem_id()/
>> cpu_to_mem(). That's not the right solution as pointed out by Tejun
>> and Peter due to:
>> 1) We shouldn't shift the burden to normal slab users.
>> 2) Details of memoryless node should be hidden in arch and mm code
>>     as much as possible.
>>
>> After digging into more code and documentation, we found the rules to
>> deal with memoryless node should be:
>> 1) Arch code should online corresponding NUMA node before onlining any
>>     CPU or memory, otherwise it may cause invalid memory access when
>>     accessing NODE_DATA(nid).
>> 2) For normal memory allocations without __GFP_THISNODE setting in the
>>     gfp_flags, we should prefer numa_node_id()/cpu_to_node() instead of
>>     numa_mem_id()/cpu_to_mem() because the latter loses hardware topology
>>     information as pointed out by Tejun:
>>        A - B - X - C - D
>>     Where X is the memless node.  numa_mem_id() on X would return
>>     either B or C, right?  If B or C can't satisfy the allocation,
>>     the allocator would fallback to A from B and D for C, both of
>>     which aren't optimal. It should first fall back to C or B
>>     respectively, which the allocator can't do anymoe because the
>>     information is lost when the caller side performs numa_mem_id().
> 
> Hi Liu,
> 
> BTW, how is this A - B - X - C - D problem solved ?
> I don't quite follow this.
> 
> I cannot tell the difference between numa_node_id()/cpu_to_node() and
> numa_mem_id()/cpu_to_mem() on this point. Even with hardware topology
> info, how could it avoid this problem ?
> 
> Isn't it still possible falling back to A from B and D for C ?
Hi Chen,
For the imagined topology, A<->B<->X<->C<->D, where A, B, C, D has
memory and X is memoryless.
Possible fallback lists are:
B: [ B, A, C, D]
X: [ B, C, A, D]
C: [ C, D, B, A]

cpu_to_mem(X) will either return B or C. Let's assume it returns B.
Then we will use "B: [ B, A, C, D]" to allocate memory for X, which
is not the optimal fallback list for X. And cpu_to_node(X) returns
X, and "X: [ B, C, A, D]" is the optimal fallback list for X.
Thanks!
Gerry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
