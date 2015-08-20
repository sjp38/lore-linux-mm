Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 494566B0038
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 02:36:18 -0400 (EDT)
Received: by pawq9 with SMTP id q9so21027371paw.3
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 23:36:18 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id dp1si5845710pbc.138.2015.08.19.23.36.17
        for <linux-mm@kvack.org>;
        Wed, 19 Aug 2015 23:36:17 -0700 (PDT)
Subject: Re: [Patch V3 3/9] sgi-xp: Replace cpu_to_node() with cpu_to_mem() to
 support memoryless node
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
 <1439781546-7217-4-git-send-email-jiang.liu@linux.intel.com>
 <alpine.DEB.2.10.1508171723290.5527@chino.kir.corp.google.com>
 <55D43C63.7060802@linux.intel.com>
 <alpine.DEB.2.10.1508191701010.30666@chino.kir.corp.google.com>
From: Jiang Liu <jiang.liu@linux.intel.com>
Message-ID: <55D5755C.5060803@linux.intel.com>
Date: Thu, 20 Aug 2015 14:36:12 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1508191701010.30666@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, Cliff Whickman <cpw@sgi.com>, Robin Holt <robinmholt@gmail.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

On 2015/8/20 8:02, David Rientjes wrote:
> On Wed, 19 Aug 2015, Jiang Liu wrote:
> 
>>> Why not simply fix build_zonelists_node() so that the __GFP_THISNODE 
>>> zonelists are set up to reference the zones of cpu_to_mem() for memoryless 
>>> nodes?
>>>
>>> It seems much better than checking and maintaining every __GFP_THISNODE 
>>> user to determine if they are using a memoryless node or not.  I don't 
>>> feel that this solution is maintainable in the longterm.
>> Hi David,
>> 	There are some usage cases, such as memory migration,
>> expect the page allocator rejecting memory allocation requests
>> if there is no memory on local node. So we have:
>> 1) alloc_pages_node(cpu_to_node(), __GFP_THISNODE) to only allocate
>> memory from local node.
>> 2) alloc_pages_node(cpu_to_mem(), __GFP_THISNODE) to allocate memory
>> from local node or from nearest node if local node is memoryless.
>>
> 
> Right, so do you think it would be better to make the default zonelists be 
> setup so that cpu_to_node()->zonelists == cpu_to_mem()->zonelists and then 
> individual callers that want to fail for memoryless nodes check 
> populated_zone() themselves?
Hi David,
	Great idea:) I think that means we are going to kill the
concept of memoryless node, and we only need to specially handle
a few callers who really care about whether there is memory on
local node.
	Then I need some time to audit all usages of __GFP_THISNODE
and update you whether it's doable.
Thanks!
Gerry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
