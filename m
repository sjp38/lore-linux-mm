Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 10A486B0387
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 23:39:44 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id b2so20126229pgc.6
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 20:39:44 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id w86si6227449pfa.192.2017.02.23.20.39.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 20:39:43 -0800 (PST)
Subject: Re: [PATCH V3 0/4] Define coherent device memory node
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
 <20170215182010.reoahjuei5eaxr5s@suse.de>
 <dfd5fd02-aa93-8a7b-b01f-52570f4c87ac@linux.vnet.ibm.com>
 <20170221111107.GJ15595@dhcp22.suse.cz>
 <890fb824-d1f0-3711-4fe6-d6ddf29a0d80@linux.vnet.ibm.com>
 <60b3dd35-a802-ba93-c2c5-d6b2b3dd72ea@huawei.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <1261339c-0188-fca0-654a-8bca5e3648c3@nvidia.com>
Date: Thu, 23 Feb 2017 20:39:41 -0800
MIME-Version: 1.0
In-Reply-To: <60b3dd35-a802-ba93-c2c5-d6b2b3dd72ea@huawei.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <liubo95@huawei.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On 02/23/2017 05:06 PM, Bob Liu wrote:
> On 2017/2/21 21:39, Anshuman Khandual wrote:
>> On 02/21/2017 04:41 PM, Michal Hocko wrote:
>>> On Fri 17-02-17 17:11:57, Anshuman Khandual wrote:
>>> [...]
>>>
>>> Could you also explain why the transparent view is really better than
>>> using a device specific mmap (aka CDM awareness)?
>>
>> Okay with a transparent view, we can achieve a control flow of application
>> like the following.
>>
>> (1) Allocate a buffer:		alloc_buffer(buf, size)
>> (2) CPU compute on buffer:	cpu_compute(buf, size)
>> (3) Device compute on buffer:	device_compute(buf, size)
>> (4) CPU compute on buffer:	cpu_compute(buf, size)
>> (5) Release the buffer:		release_buffer(buf, size)
>>
>> With assistance from a device specific driver, the actual page mapping of
>> the buffer can change between system RAM and device memory depending on
>> which side is accessing at a given point. This will be achieved through
>> driver initiated migrations.
>>
>
> Sorry, I'm a bit confused here.
> What's the difference with the Heterogeneous memory management?
> Which also "allows to use device memory transparently inside any process
> without any modifications to process program code."

OK, Jerome, let me answer this one. :)

Hi Bob,

Yes, from a userspace app's point of view, both HMM and the various NUMA-based proposals appear to 
provide the same thing: transparent, coherent access to both CPU and device memory. It's just the 
implementation that's different, and each implementation has a role:

HMM: for systems that do not provide direct access to device memory, we do need HMM. It provides a 
fault-based mechanism for transparently moving pages to the right place, and mapping them to the 
local process (CPU or device). You can think of HMM as something that provides coherent memory 
access, via software.

NUMA-based solutions: for systems that *can* provide directly addressable, coherent device memory, 
we let programs directly address the memory, and let the (probably enhanced) NUMA system handle page 
placement. There will be lots more NUMA enhancement discussions and patchsets coming, from what I 
can tell.

There are distinct advantages and disadvantages to each approach. For example, fault-based HMM can 
be slow, but it works even with hardware that doesn't directly provide coherent access--and it also 
has page fault information to guide it on page placement (thrashing detection). And NUMA systems, 
which do *not* fault nearly as much, require various artificial ways to detect when a page (or 
process) is on a suboptimal node. The NUMA approach is also, very arguably, conceptually simpler (it 
really depends on which area you look at).

So again: yes, both systems are providing a sort of coherent memory. HMM provides software based 
coherence, while NUMA assumes hardware-based memory coherence as a prerequisite.

I hope that helps, and doesn't just further muddy the waters?

--
John Hubbard
NVIDIA

>
> Thanks,
> -Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
