Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2C28F6B0389
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 20:09:58 -0500 (EST)
Received: by mail-yb0-f198.google.com with SMTP id t7so12719314yba.1
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 17:09:58 -0800 (PST)
Received: from dggrg02-dlp.huawei.com ([45.249.212.188])
        by mx.google.com with ESMTPS id l68si1679387ywd.108.2017.02.23.17.09.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Feb 2017 17:09:56 -0800 (PST)
Subject: Re: [PATCH V3 0/4] Define coherent device memory node
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
 <20170215182010.reoahjuei5eaxr5s@suse.de>
 <dfd5fd02-aa93-8a7b-b01f-52570f4c87ac@linux.vnet.ibm.com>
 <20170221111107.GJ15595@dhcp22.suse.cz>
 <890fb824-d1f0-3711-4fe6-d6ddf29a0d80@linux.vnet.ibm.com>
From: Bob Liu <liubo95@huawei.com>
Message-ID: <60b3dd35-a802-ba93-c2c5-d6b2b3dd72ea@huawei.com>
Date: Fri, 24 Feb 2017 09:06:19 +0800
MIME-Version: 1.0
In-Reply-To: <890fb824-d1f0-3711-4fe6-d6ddf29a0d80@linux.vnet.ibm.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On 2017/2/21 21:39, Anshuman Khandual wrote:
> On 02/21/2017 04:41 PM, Michal Hocko wrote:
>> On Fri 17-02-17 17:11:57, Anshuman Khandual wrote:
>> [...]
>>> * User space using mbind() to get CDM memory is an additional benefit
>>>   we get by making the CDM plug in as a node and be part of the buddy
>>>   allocator. But the over all idea from the user space point of view
>>>   is that the application can allocate any generic buffer and try to
>>>   use the buffer either from the CPU side or from the device without
>>>   knowing about where the buffer is really mapped physically. That
>>>   gives a seamless and transparent view to the user space where CPU
>>>   compute and possible device based compute can work together. This
>>>   is not possible through a driver allocated buffer.
>>
>> But how are you going to define any policy around that. Who is allowed
> 
> The user space VMA can define the policy with a mbind(MPOL_BIND) call
> with CDM/CDMs in the nodemask.
> 
>> to allocate and how much of this "special memory". Is it possible that
> 
> Any user space application with mbind(MPOL_BIND) call with CDM/CDMs in
> the nodemask can allocate from the CDM memory. "How much" gets controlled
> by how we fault from CPU and the default behavior of the buddy allocator.
> 
>> we will eventually need some access control mechanism? If yes then mbind
> 
> No access control mechanism is needed. If an application wants to use
> CDM memory by specifying in the mbind() it can. Nothing prevents it
> from using the CDM memory.
> 
>> is really not suitable interface to (ab)use. Also what should happen if
>> the mbind mentions only CDM memory and that is depleted?
> 
> IIUC *only CDM* cannot be requested from user space as there are no user
> visible interface which can translate to __GFP_THISNODE. MPOL_BIND with
> CDM in the nodemask will eventually pick a FALLBACK zonelist which will
> have zones of the system including CDM ones. If the resultant CDM zones
> run out of memory, we fail the allocation request as usual.
> 
>>
>> Could you also explain why the transparent view is really better than
>> using a device specific mmap (aka CDM awareness)?
> 
> Okay with a transparent view, we can achieve a control flow of application
> like the following.
> 
> (1) Allocate a buffer:		alloc_buffer(buf, size)
> (2) CPU compute on buffer:	cpu_compute(buf, size)
> (3) Device compute on buffer:	device_compute(buf, size)
> (4) CPU compute on buffer:	cpu_compute(buf, size)
> (5) Release the buffer:		release_buffer(buf, size)
> 
> With assistance from a device specific driver, the actual page mapping of
> the buffer can change between system RAM and device memory depending on
> which side is accessing at a given point. This will be achieved through
> driver initiated migrations.
> 

Sorry, I'm a bit confused here.
What's the difference with the Heterogeneous memory management?
Which also "allows to use device memory transparently inside any process
without any modifications to process program code."

Thanks,
-Bob

>>  
>>> * The placement of the memory on the buffer can happen on system memory
>>>   when the CPU faults while accessing it. But a driver can manage the
>>>   migration between system RAM and CDM memory once the buffer is being
>>>   used from CPU and the device interchangeably. As you have mentioned
>>>   driver will have more information about where which part of the buffer
>>>   should be placed at any point of time and it can make it happen with
>>>   migration. So both allocation and placement are decided by the driver
>>>   during runtime. CDM provides the framework for this can kind device
>>>   assisted compute and driver managed memory placements.
>>>
>>> * If any application is not using CDM memory for along time placed on
>>>   its buffer and another application is forced to fallback on system
>>>   RAM when it really wanted is CDM, the driver can detect these kind
>>>   of situations through memory access patterns on the device HW and
>>>   take necessary migration decisions.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
