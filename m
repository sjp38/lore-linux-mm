Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0A3AC6B2A3A
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 08:22:48 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id c33so4696520otb.18
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 05:22:48 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m18si7981438otp.53.2018.11.22.05.22.45
        for <linux-mm@kvack.org>;
        Thu, 22 Nov 2018 05:22:46 -0800 (PST)
Subject: Re: [PATCH 2/7] node: Add heterogenous memory performance
References: <20181114224921.12123-2-keith.busch@intel.com>
 <20181114224921.12123-3-keith.busch@intel.com>
 <91369e94-d389-7cb9-6274-f46c9ec779d3@arm.com>
 <20181119154604.GC23062@localhost.localdomain>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <2482fbdf-e672-8d46-edcb-021f7af8d9b7@arm.com>
Date: Thu, 22 Nov 2018 18:52:43 +0530
MIME-Version: 1.0
In-Reply-To: <20181119154604.GC23062@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>



On 11/19/2018 09:16 PM, Keith Busch wrote:
> On Mon, Nov 19, 2018 at 09:05:07AM +0530, Anshuman Khandual wrote:
>> On 11/15/2018 04:19 AM, Keith Busch wrote:
>>> Heterogeneous memory systems provide memory nodes with latency
>>> and bandwidth performance attributes that are different from other
>>> nodes. Create an interface for the kernel to register these attributes
>>
>> There are other properties like power consumption, reliability which can
>> be associated with a particular PA range. Also the set of properties has
>> to be extensible for the future.
> 
> Sure, I'm just starting with the attributes available from HMAT, 
> If there are additional possible attributes that make sense to add, I
> don't see why we can't continue appending them if this patch is okay.

As I mentioned on the other thread

1) The interface needs to be compact to avoid large number of files
2) Single U64 will be able to handle 8 attributes with 8 bit values
3) 8 bit value needs needs to be arch independent and abstracted out

I guess 8 attributes should be good enough for all type of memory in
foreseeable future.

>  
>>> under the node that provides the memory. If the system provides this
>>> information, applications can query the node attributes when deciding
>>> which node to request memory.
>>
>> Right but each (memory initiator, memory target) should have these above
>> mentioned properties enumerated to have an 'property as seen' from kind
>> of semantics.
>>
>>>
>>> When multiple memory initiators exist, accessing the same memory target
>>> from each may not perform the same as the other. The highest performing
>>> initiator to a given target is considered to be a local initiator for
>>> that target. The kernel provides performance attributes only for the
>>> local initiators.
>>
>> As mentioned above the interface must enumerate a future extensible set
>> of properties for each (memory initiator, memory target) pair available
>> on the system.
> 
> That seems less friendly to use if forces the application to figure out
> which CPU is the best for a given memory node rather than just provide
> that answer directly.

Why ? The application would just have to scan all possible values out
there and decide for itself. A complete set of attribute values for
each pair makes the sysfs more comprehensive and gives the application
more control over it's choices.

> 
>>> The memory's compute node should be symlinked in sysfs as one of the
>>> node's initiators.
>>
>> Right. IIUC the first patch skips the linking process of for two nodes A
>> and B if (A == B) preventing association to local memory initiator.
> 
> Right, CPUs and memory sharing a proximity domain are assumed to be
> local to each other, so not going to set up those links to itself.

But this will be required for applications to evaluate correctly between
possible values from all node pairs.
