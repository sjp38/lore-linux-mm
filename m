Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 994D46B0036
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 04:21:24 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ey11so1283881pad.10
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 01:21:24 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ow8si840032pdb.334.2014.07.23.01.21.23
        for <linux-mm@kvack.org>;
        Wed, 23 Jul 2014 01:21:23 -0700 (PDT)
Message-ID: <53CF7048.20302@linux.intel.com>
Date: Wed, 23 Jul 2014 16:20:24 +0800
From: Jiang Liu <jiang.liu@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [RFC Patch V1 00/30] Enable memoryless node on x86 platforms
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com> <20140721172331.GB4156@linux.vnet.ibm.com> <CA+8MBbK+ZdisT_yXh_jkWSd4hWEMisG614s4s0EyNV3j-7YOow@mail.gmail.com> <20140721175736.GG4156@linux.vnet.ibm.com>
In-Reply-To: <20140721175736.GG4156@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, Tony Luck <tony.luck@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-hotplug@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>



On 2014/7/22 1:57, Nishanth Aravamudan wrote:
> On 21.07.2014 [10:41:59 -0700], Tony Luck wrote:
>> On Mon, Jul 21, 2014 at 10:23 AM, Nishanth Aravamudan
>> <nacc@linux.vnet.ibm.com> wrote:
>>> It seems like the issue is the order of onlining of resources on a
>>> specific x86 platform?
>>
>> Yes. When we online a node the BIOS hits us with some ACPI hotplug events:
>>
>> First: Here are some new cpus
> 
> Ok, so during this period, you might get some remote allocations. Do you
> know the topology of these CPUs? That is they belong to a
> (soon-to-exist) NUMA node? Can you online that currently offline NUMA
> node at this point (so that NODE_DATA()) resolves, etc.)?
Hi Nishanth,
	We have method to get the NUMA information about the CPU, and
patch "[RFC Patch V1 30/30] x86, NUMA: Online node earlier when doing
CPU hot-addition" tries to solve this issue by onlining NUMA node
as early as possible. Actually we are trying to enable memoryless node
as you have suggested.

Regards!
Gerry

> 
>> Next: Here is some new memory
> 
> And then update the NUMA topology at this point? That is,
> set_cpu_numa_node/mem as appropriate so the underlying allocators do the
> right thing?
> 
>> Last; Here are some new I/O things (PCIe root ports, PCIe devices,
>> IOAPICs, IOMMUs, ...)
>>
>> So there is a period where the node is memoryless - although that will
>> generally be resolved when the memory hot plug event arrives ... that
>> isn't guaranteed to occur (there might not be any memory on the node,
>> or what memory there is may have failed self-test and been disabled).
> 
> Right, but the allocator(s) generally does the right thing already in
> the face of memoryless nodes -- they fallback to the nearest node. That
> leads to poor performance, but is functional. Based upon the previous
> thread Jiang pointed to, it seems like the real issue here isn't that
> the node is memoryless, but that it's not even online yet? So NODE_DATA
> access crashes?
> 
> Thanks,
> Nish
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
