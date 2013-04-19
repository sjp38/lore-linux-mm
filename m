Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 476A86B0005
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 11:21:30 -0400 (EDT)
Message-ID: <5171622B.2060509@linux.intel.com>
Date: Fri, 19 Apr 2013 08:26:35 -0700
From: Srinivas Pandruvada <srinivas.pandruvada@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v2 00/15][Sorted-buddy] mm: Memory Power Management
References: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com> <5170D781.3000102@gmail.com> <5170EE4F.9030908@linux.vnet.ibm.com>
In-Reply-To: <5170EE4F.9030908@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: Simon Jeons <simon.jeons@gmail.com>, akpm@linux-foundation.org, mgorman@suse.de, matthew.garrett@nebula.com, dave@sr71.net, rientjes@google.com, riel@redhat.com, arjan@linux.intel.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, wujianguo@huawei.com, kmpark@infradead.org, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/19/2013 12:12 AM, Srivatsa S. Bhat wrote:
> On 04/19/2013 11:04 AM, Simon Jeons wrote:
>> Hi Srivatsa,
>> On 04/10/2013 05:45 AM, Srivatsa S. Bhat wrote:
>>> [I know, this cover letter is a little too long, but I wanted to clearly
>>> explain the overall goals and the high-level design of this patchset in
>>> detail. I hope this helps more than it annoys, and makes it easier for
>>> reviewers to relate to the background and the goals of this patchset.]
>>>
>>>
>>> Overview of Memory Power Management and its implications to the Linux MM
>>> ========================================================================
>>>
>>> Today, we are increasingly seeing computer systems sporting larger and
>>> larger
>>> amounts of RAM, in order to meet workload demands. However, memory
>>> consumes a
>>> significant amount of power, potentially upto more than a third of
>>> total system
>>> power on server systems. So naturally, memory becomes the next big
>>> target for
>>> power management - on embedded systems and smartphones, and all the
>>> way upto
>>> large server systems.
>>>
>>> Power-management capabilities in modern memory hardware:
>>> -------------------------------------------------------
>>>
>>> Modern memory hardware such as DDR3 support a number of power management
>>> capabilities - for instance, the memory controller can automatically put
>> memory controller is integrated in cpu in NUMA system and mount on PCI-E
>> in UMA, correct? How can memory controller know which memory DIMMs/banks
>> it will control?
>>
> Um? That sounds like a strange question to me. If the memory controller
> itself doesn't know what it is controlling, then who will??
<Modern memory controller or smart enough to put into low power content 
preserving state, if you don't touch any ranks. So if you don't access a 
rank, it will go to low power state.>
>>> memory DIMMs/banks into content-preserving low-power states, if it
>>> detects
>>> that that *entire* memory DIMM/bank has not been referenced for a
>>> threshold
>>> amount of time, thus reducing the energy consumption of the memory
>>> hardware.
>>> We term these power-manageable chunks of memory as "Memory Regions".
>>>
>>> Exporting memory region info of the platform to the OS:
>>> ------------------------------------------------------
>>>
>>> The OS needs to know about the granularity at which the hardware can
>>> perform
>>> automatic power-management of the memory banks (i.e., the address
>>> boundaries
>>> of the memory regions). On ARM platforms, the bootloader can be
>>> modified to
>>> pass on this info to the kernel via the device-tree. On x86 platforms,
>>> the
>>> new ACPI 5.0 spec has added support for exporting the power-management
>>> capabilities of the memory hardware to the OS in a standard way[5].
>>>
>>> Estimate of power-savings from power-aware Linux MM:
>>> ---------------------------------------------------
>>>
>>> Once the firmware/bootloader exports the required info to the OS, it
>>> is upto
>>> the kernel's MM subsystem to make the best use of these capabilities
>>> and manage
>>> memory power-efficiently. It had been demonstrated on a Samsung Exynos
>>> board
>>> (with 2 GB RAM) that upto 6 percent of total system power can be saved by
>>> making the Linux kernel MM subsystem power-aware[4]. (More savings can be
>>> expected on systems with larger amounts of memory, and perhaps
>>> improved further
>>> using better MM designs).
>> How to know there are 6 percent of total system power can be saved by
>> making the Linux kernel MM subsystem power-aware?
>>
> By looking at the link I gave, I suppose? :-) Let me put it here again:
>
> [4]. Estimate of potential power savings on Samsung exynos board
>       http://article.gmane.org/gmane.linux.kernel.mm/65935
>
> That was measured by running the earlier patchset which implemented the
> "Hierarchy" design[2], with aggressive memory savings policies. But in any
> case, it gives an idea of the amount of power savings we can get by doing
> memory power management.
>
>>>
>>> Role of the Linux MM in enhancing memory power savings:
>>> ------------------------------------------------------
>>>
>>> Often, this simply translates to having the Linux MM understand the
>>> granularity
>>> at which RAM modules can be power-managed, and keeping the memory
>>> allocations
>>> and references consolidated to a minimum no. of these power-manageable
>>> "memory regions". It is of particular interest to note that most of
>>> these memory
>>> hardware have the intelligence to automatically save power, by putting
>>> memory
>>> banks into (content-preserving) low-power states when not referenced
>>> for a
>> How to know DIMM/bank is not referenced?
>>
> That's upto the hardware to figure out. It would be engraved in the
> hardware logic. The kernel need not worry about it. The kernel has to
> simply understand the PFN ranges corresponding to independently
> power-manageable chunks of memory and try to keep the memory allocations
> consolidated to a minimum no. of such memory regions. That's because we
> never reference (access) unallocated memory. So keeping the allocations
> consolidated also indirectly keeps the references consolidated.
>
> But going further, as I had mentioned in my TODO list, we can be smarter
> than this while doing compaction to evacuate memory regions - we can
> choose to migrate only the active pages, and leave the inactive pages
> alone. Because, the goal is to actually consolidate the *references* and
> not necessarily the *allocations* themselves.
>
>>> threshold amount of time. All that the kernel has to do, is avoid
>>> wrecking
>>> the power-savings logic by scattering its allocations and references
>>> all over
>>> the system memory. (The kernel/MM doesn't have to perform the actual
>>> power-state
>>> transitions; its mostly done in the hardware automatically, and this
>>> is OK
>>> because these are *content-preserving* low-power states).
>>>
>>>
>>> Brief overview of the design/approach used in this patchset:
>>> -----------------------------------------------------------
>>>
>>> This patchset implements the 'Sorted-buddy design' for Memory Power
>>> Management,
>>> in which the buddy (page) allocator is altered to keep the buddy
>>> freelists
>>> region-sorted, which helps influence the page allocation paths to keep
>>> the
>> If this will impact normal zone based buddy freelists?
>>
> The freelists continue to remain zone-based. No change in that. We are
> not fragmenting them further to be per-memory-region. Instead, we simply
> maintain pointers within the freelists to differentiate pageblocks belonging
> to different memory regions.
>
>>> allocations consolidated to a minimum no. of memory regions. This
>>> patchset also
>>> includes a light-weight targetted compaction/reclaim algorithm that works
>>> hand-in-hand with the page-allocator, to evacuate lightly-filled
>>> memory regions
>>> when memory gets fragmented, in order to further enhance memory power
>>> savings.
>>>
>>> This Sorted-buddy design was developed based on some of the suggestions
>>> received[1] during the review of the earlier patchset on Memory Power
>>> Management written by Ankita Garg ('Hierarchy design')[2].
>>> One of the key aspects of this Sorted-buddy design is that it avoids the
>>> zone-fragmentation problem that was present in the earlier design[3].
>>>
>>>
> Regards,
> Srivatsa S. Bhat
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
