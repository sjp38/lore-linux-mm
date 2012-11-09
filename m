Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 1FEDE6B0044
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 10:25:13 -0500 (EST)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 9 Nov 2012 20:55:10 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA9FP6Nl7405906
	for <linux-mm@kvack.org>; Fri, 9 Nov 2012 20:55:07 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA9FP5bI023665
	for <linux-mm@kvack.org>; Sat, 10 Nov 2012 02:25:06 +1100
Message-ID: <509D200F.2000908@linux.vnet.ibm.com>
Date: Fri, 09 Nov 2012 20:53:59 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/8][Sorted-buddy] mm: Linux VM Infrastructure to
 support Memory Power Management
References: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com> <20121108180257.GC8218@suse.de> <20121109051247.GA499@dirshya.in.ibm.com> <20121109090052.GF8218@suse.de> <509D185D.8070307@linux.vnet.ibm.com>
In-Reply-To: <509D185D.8070307@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, akpm@linux-foundation.org, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, amit.kachhap@linaro.org, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/09/2012 08:21 PM, Srivatsa S. Bhat wrote:
> On 11/09/2012 02:30 PM, Mel Gorman wrote:
>> On Fri, Nov 09, 2012 at 10:44:16AM +0530, Vaidyanathan Srinivasan wrote:
>>> * Mel Gorman <mgorman@suse.de> [2012-11-08 18:02:57]:
[...]
>>>>> Short description of the "Sorted-buddy" design:
>>>>> -----------------------------------------------
>>>>>
>>>>> In this design, the memory region boundaries are captured in a parallel
>>>>> data-structure instead of fitting regions between nodes and zones in the
>>>>> hierarchy. Further, the buddy allocator is altered, such that we maintain the
>>>>> zones' freelists in region-sorted-order and thus do page allocation in the
>>>>> order of increasing memory regions.
>>>>
>>>> Implying that this sorting has to happen in the either the alloc or free
>>>> fast path.
>>>
>>> Yes, in the free path. This optimization can be actually be delayed in
>>> the free fast path and completely avoided if our memory is full and we
>>> are doing direct reclaim during allocations.
>>>
>>
>> Hurting the free fast path is a bad idea as there are workloads that depend
>> on it (buffer allocation and free) even though many workloads do *not*
>> notice it because the bulk of the cost is incurred at exit time. As
>> memory low power usage has many caveats (may be impossible if a page
>> table is allocated in the region for example) but CPU usage has less
>> restrictions it is more important that the CPU usage be kept low.
>>
>> That means, little or no modification to the fastpath. Sorting or linear
>> searches should be minimised or avoided.
>>
> 
> Right. For example, in the previous "hierarchy" design[1], there was no overhead
> in any of the fast paths. Because it split up the zones themselves, so that
> they fit on memory region boundaries. But that design had other problems, like
> zone fragmentation (too many zones).. which kind of out-weighed the benefit
> obtained from zero overhead in the fast-paths. So one of the suggested
> alternatives during that review[2], was to explore modifying the buddy allocator
> to be aware of memory region boundaries, which this "sorted-buddy" design
> implements.
> 
> [1]. http://lwn.net/Articles/445045/
>      http://thread.gmane.org/gmane.linux.kernel.mm/63840
>      http://thread.gmane.org/gmane.linux.kernel.mm/89202
> 
> [2]. http://article.gmane.org/gmane.linux.power-management.general/24862
>      http://article.gmane.org/gmane.linux.power-management.general/25061
>      http://article.gmane.org/gmane.linux.kernel.mm/64689 
> 
> In this patchset, I have tried to minimize the overhead on the fastpaths.
> For example, I have used a special 'next_region' data-structure to keep the
> alloc path fast. Also, in the free path, we don't need to keep the free
> lists fully address sorted; having them region-sorted is sufficient. Of course
> we could explore more ways of avoiding overhead in the fast paths, or even a
> different design that promises to be much better overall. I'm all ears for
> any suggestions :-)
> 

FWIW, kernbench is actually (and surprisingly) showing a slight performance
*improvement* with this patchset, over vanilla 3.7-rc3, as I mentioned in
my other email to Dave.

https://lkml.org/lkml/2012/11/7/428

I don't think I can dismiss it as an experimental error, because I am seeing
those results consistently.. I'm trying to find out what's behind that.

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
