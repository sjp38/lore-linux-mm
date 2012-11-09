Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 02F4B6B002B
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 09:52:29 -0500 (EST)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 9 Nov 2012 20:22:26 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA9EqISJ11206782
	for <linux-mm@kvack.org>; Fri, 9 Nov 2012 20:22:19 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA9KM7JZ014464
	for <linux-mm@kvack.org>; Sat, 10 Nov 2012 07:22:09 +1100
Message-ID: <509D185D.8070307@linux.vnet.ibm.com>
Date: Fri, 09 Nov 2012 20:21:09 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/8][Sorted-buddy] mm: Linux VM Infrastructure to
 support Memory Power Management
References: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com> <20121108180257.GC8218@suse.de> <20121109051247.GA499@dirshya.in.ibm.com> <20121109090052.GF8218@suse.de>
In-Reply-To: <20121109090052.GF8218@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, akpm@linux-foundation.org, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, amit.kachhap@linaro.org, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/09/2012 02:30 PM, Mel Gorman wrote:
> On Fri, Nov 09, 2012 at 10:44:16AM +0530, Vaidyanathan Srinivasan wrote:
>> * Mel Gorman <mgorman@suse.de> [2012-11-08 18:02:57]:
>>
[...]
>>> How much power is saved?
>>
>> On embedded platform the savings could be around 5% as discussed in
>> the earlier thread: http://article.gmane.org/gmane.linux.kernel.mm/65935
>>
>> On larger servers with large amounts of memory the savings could be
>> more.  We do not yet have all the pieces together to evaluate.
>>
> 
> Ok, it's something to keep an eye on because if memory power savings
> require large amounts of CPU (for smart placement or migration) or more
> disk accesses (due to reclaim) then the savings will be offset by
> increased power usage elsehwere.
> 

True.

>>>> ACPI 5.0 has introduced MPST tables (Memory Power State Tables) [5] so that
>>>> the firmware can expose information regarding the boundaries of such memory
>>>> power management domains to the OS in a standard way.
>>>>
>>>
>>> I'm not familiar with the ACPI spec but is there support for parsing of
>>> MPST and interpreting the associated ACPI events? For example, if ACPI
>>> fires an event indicating that a memory power node is to enter a low
>>> state then presumably the OS should actively migrate pages away -- even
>>> if it's going into a state where the contents are still refreshed
>>> as exiting that state could take a long time.
>>>
>>> I did not look closely at the patchset at all because it looked like the
>>> actual support to use it and measure the benefit is missing.
>>
>> Correct.  The platform interface part is not included in this patch
>> set mainly because there is not much design required there.  Each
>> platform can have code to collect the memory region boundaries from
>> BIOS/firmware and load it into the Linux VM.  The goal of this patch
>> is to brainstorm on the idea of hos core VM should used the region
>> information.
>>  
> 
> Ok. It does mean that the patches should not be merged until there is
> some platform support that can take advantage of them.
>

That's right, but the development of the VM algorithms and the platform
support for different platforms can go on in parallel. And once we have all
the pieces designed, we can fit them together and merge them.
 
>>>> How can Linux VM help memory power savings?
>>>>
>>>> o Consolidate memory allocations and/or references such that they are
>>>> not spread across the entire memory address space.  Basically area of memory
>>>> that is not being referenced, can reside in low power state.
>>>>
>>>
>>> Which the series does not appear to do.
>>
>> Correct.  We need to design the correct reclaim strategy for this to
>> work.  However having buddy list sorted by region address could get us
>> one step closer to shaping the allocations.
>>
> 
> If you reclaim, it means that the information is going to disk and will
> have to be refaulted in sooner rather than later. If you concentrate on
> reclaiming low memory regions and memory is almost full, it will lead to
> a situation where you almost always reclaim newer pages and increase
> faulting. You will save a few milliwatts on memory and lose way more
> than that on increase disk traffic and CPU usage.
> 

Yes, we should ensure that our reclaim strategy won't back-fire like that.
We definitely need to depend on LRU ordering for reclaim for the most part,
but try to opportunistically reclaim from within the required region boundaries
while doing that. We definitely need to think more about this...

But the point of making the free lists sorted region-wise in this patchset
was to exploit the shaping of page allocations the way we want (ie.,
constrained to lesser number of regions).

>>>> o Support targeted memory reclaim, where certain areas of memory that can be
>>>> easily freed can be offlined, allowing those areas of memory to be put into
>>>> lower power states.
>>>>
>>>
>>> Which the series does not appear to do judging from this;
>>>
>>>   include/linux/mm.h     |   38 +++++++
>>>   include/linux/mmzone.h |   52 +++++++++
>>>   mm/compaction.c        |    8 +
>>>   mm/page_alloc.c        |  263 ++++++++++++++++++++++++++++++++++++++++++++----
>>>   mm/vmstat.c            |   59 ++++++++++-
>>>
>>> This does not appear to be doing anything with reclaim and not enough with
>>> compaction to indicate that the series actively manages memory placement
>>> in response to ACPI events.
>>
>> Correct.  Evaluating different ideas for reclaim will be next step
>> before getting into the platform interface parts.
>>
[...]
>>
>> This patch is roughly based on the idea that ACPI MPST will give us
>> memory region boundaries.  It is not designed to implement all options
>> defined in the spec. 
> 
> Ok, but as it is the only potential consumer of this interface that you
> mentioned then it should at least be able to handle it. The spec talks about
> overlapping memory regions where the regions potentially have differnet
> power states. This is pretty damn remarkable and hard to see how it could
> be interpreted in a sensible way but it forces your implementation to take
> it into account.
>

Well, sorry for not mentioning in the cover-letter, but the VM algorithms for
memory power management could benefit other platforms too, like ARM, not just
ACPI-based systems. Last year, Amit had evaluated them on Samsung boards with
a simplistic layout for memory regions, based on the Samsung exynos board's
configuration.

http://article.gmane.org/gmane.linux.kernel.mm/65935
 
>> We have taken a general case of regions do not
>> overlap while memory addresses itself can be discontinuous.
>>
> 
> Why is the general case? You referred to the ACPI spec where it is not
> the case and no other examples.
> 

ARM is another example, where we could describe the memory regions in a simple
manner with respect to the Samsung exynos board.

So the idea behind this patchset was to start by assuming a simplistic layout
for memory regions and focussing on the design of the VM algorithms, and
evaluating how this "sorted-buddy" design would perform in comparison to the
previous "hierarchy" design that was explored last year.

But of course, you are absolutely right in pointing out that, to make all this
consumable, we need to revisit this with a focus on the layout of memory
regions themselves, so that all interested platforms can make use of it
effectively.

[...]

>>>> Short description of the "Sorted-buddy" design:
>>>> -----------------------------------------------
>>>>
>>>> In this design, the memory region boundaries are captured in a parallel
>>>> data-structure instead of fitting regions between nodes and zones in the
>>>> hierarchy. Further, the buddy allocator is altered, such that we maintain the
>>>> zones' freelists in region-sorted-order and thus do page allocation in the
>>>> order of increasing memory regions.
>>>
>>> Implying that this sorting has to happen in the either the alloc or free
>>> fast path.
>>
>> Yes, in the free path. This optimization can be actually be delayed in
>> the free fast path and completely avoided if our memory is full and we
>> are doing direct reclaim during allocations.
>>
> 
> Hurting the free fast path is a bad idea as there are workloads that depend
> on it (buffer allocation and free) even though many workloads do *not*
> notice it because the bulk of the cost is incurred at exit time. As
> memory low power usage has many caveats (may be impossible if a page
> table is allocated in the region for example) but CPU usage has less
> restrictions it is more important that the CPU usage be kept low.
> 
> That means, little or no modification to the fastpath. Sorting or linear
> searches should be minimised or avoided.
> 

Right. For example, in the previous "hierarchy" design[1], there was no overhead
in any of the fast paths. Because it split up the zones themselves, so that
they fit on memory region boundaries. But that design had other problems, like
zone fragmentation (too many zones).. which kind of out-weighed the benefit
obtained from zero overhead in the fast-paths. So one of the suggested
alternatives during that review[2], was to explore modifying the buddy allocator
to be aware of memory region boundaries, which this "sorted-buddy" design
implements.

[1]. http://lwn.net/Articles/445045/
     http://thread.gmane.org/gmane.linux.kernel.mm/63840
     http://thread.gmane.org/gmane.linux.kernel.mm/89202

[2]. http://article.gmane.org/gmane.linux.power-management.general/24862
     http://article.gmane.org/gmane.linux.power-management.general/25061
     http://article.gmane.org/gmane.linux.kernel.mm/64689 

In this patchset, I have tried to minimize the overhead on the fastpaths.
For example, I have used a special 'next_region' data-structure to keep the
alloc path fast. Also, in the free path, we don't need to keep the free
lists fully address sorted; having them region-sorted is sufficient. Of course
we could explore more ways of avoiding overhead in the fast paths, or even a
different design that promises to be much better overall. I'm all ears for
any suggestions :-)

>> At this point we want to look at overheads of having region
>> infrastructure in VM and how does that trade off in terms of
>> requirements that we can meet.
>>
>> The first goal is to have memory allocations fill as few regions as
>> possible when system's memory usage is significantly lower. 
> 
> While it's a reasonable starting objective, the fast path overhead is very
> unfortunate and such a strategy can be easily defeated by running sometime
> metadata intensive (like find over the entire system) while a large memory
> user starts at the same time to spread kernel and user space allocations
> throughout the address space. This will spread the allocations throughout
> the address space and persist even after the two processes exit due to
> the page cache usage from the metadata intensive workload.
> 
> Basically, it'll only work as long as the system is idle or never uses
> much memory during the lifetime of the system.
> 

Well, page cache usage could definitely come in the way of memory power
management. Probably having a separate driver shrink the page cache
(depending on how aggressive we want to get with respect to power-management)
is the way to go?

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
