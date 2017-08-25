Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3FAB56B04DB
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 05:42:11 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u20so9196850pgb.10
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 02:42:11 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c134si860619pga.205.2017.08.25.02.42.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 02:42:09 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7P9eauD119753
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 05:42:09 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2cjh1b9ruw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 05:42:08 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 25 Aug 2017 10:42:05 +0100
Subject: Re: [PATCH v2 00/20] Speculative page faults
References: <1503007519-26777-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <87c5a62a-e3b9-8337-66b6-2daae976ff79@linux.vnet.ibm.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Fri, 25 Aug 2017 11:41:55 +0200
MIME-Version: 1.0
In-Reply-To: <87c5a62a-e3b9-8337-66b6-2daae976ff79@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <9e22d5f4-4bb9-79c0-0a9e-5206642d2277@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 21/08/2017 08:28, Anshuman Khandual wrote:
> On 08/18/2017 03:34 AM, Laurent Dufour wrote:
>> This is a port on kernel 4.13 of the work done by Peter Zijlstra to
>> handle page fault without holding the mm semaphore [1].
>>
>> The idea is to try to handle user space page faults without holding the
>> mmap_sem. This should allow better concurrency for massively threaded
>> process since the page fault handler will not wait for other threads memory
>> layout change to be done, assuming that this change is done in another part
>> of the process's memory space. This type page fault is named speculative
>> page fault. If the speculative page fault fails because of a concurrency is
>> detected or because underlying PMD or PTE tables are not yet allocating, it
>> is failing its processing and a classic page fault is then tried.
>>
>> The speculative page fault (SPF) has to look for the VMA matching the fault
>> address without holding the mmap_sem, so the VMA list is now managed using
>> SRCU allowing lockless walking. The only impact would be the deferred file
>> derefencing in the case of a file mapping, since the file pointer is
>> released once the SRCU cleaning is done.  This patch relies on the change
>> done recently by Paul McKenney in SRCU which now runs a callback per CPU
>> instead of per SRCU structure [1].
>>
>> The VMA's attributes checked during the speculative page fault processing
>> have to be protected against parallel changes. This is done by using a per
>> VMA sequence lock. This sequence lock allows the speculative page fault
>> handler to fast check for parallel changes in progress and to abort the
>> speculative page fault in that case.
>>
>> Once the VMA is found, the speculative page fault handler would check for
>> the VMA's attributes to verify that the page fault has to be handled
>> correctly or not. Thus the VMA is protected through a sequence lock which
>> allows fast detection of concurrent VMA changes. If such a change is
>> detected, the speculative page fault is aborted and a *classic* page fault
>> is tried.  VMA sequence locks are added when VMA attributes which are
>> checked during the page fault are modified.
>>
>> When the PTE is fetched, the VMA is checked to see if it has been changed,
>> so once the page table is locked, the VMA is valid, so any other changes
>> leading to touching this PTE will need to lock the page table, so no
>> parallel change is possible at this time.
>>
>> Compared to the Peter's initial work, this series introduces a spin_trylock
>> when dealing with speculative page fault. This is required to avoid dead
>> lock when handling a page fault while a TLB invalidate is requested by an
>> other CPU holding the PTE. Another change due to a lock dependency issue
>> with mapping->i_mmap_rwsem.
>>
>> In addition some VMA field values which are used once the PTE is unlocked
>> at the end the page fault path are saved into the vm_fault structure to
>> used the values matching the VMA at the time the PTE was locked.
>>
>> This series builds on top of v4.13-rc5 and is functional on x86 and
>> PowerPC.
>>
>> Tests have been made using a large commercial in-memory database on a
>> PowerPC system with 752 CPU using RFC v5. The results are very encouraging
>> since the loading of the 2TB database was faster by 14% with the
>> speculative page fault.
>>
> 
> You specifically mention loading as most of the page faults will
> happen at that time and then the working set will settle down with
> very less page faults there after ? That means unless there is
> another wave of page faults we wont notice performance improvement
> during the runtime.

I just captured performance statistic during the database loading then
since the database was not stimulated, there was no page faults generated.
Further tests will be made while the database is running but I didn't have
the framework to do so right now.

> 
>> Using ebizzy test [3], which spreads a lot of threads, the result are good
>> when running on both a large or a small system. When using kernbench, the
> 
> The performance improvements are greater as there is a lot of creation
> and destruction of anon mappings which generates constant flow of page
> faults to be handled.
> 
>> result are quite similar which expected as not so much multi threaded
>> processes are involved. But there is no performance degradation neither
>> which is good.
> 
> If we compile with 'make -j N' there would be a lot of threads but I
> guess the problem is SPF does not support handling file mapping IIUC
> which limits the performance improvement for some workloads.

Yes but that test is showing that there is no performance degradation which
is good.

>>
>> ------------------
>> Benchmarks results
>>
>> Note these test have been made on top of 4.13-rc3 with the following patch
>> from Paul McKenney applied: 
>>  "srcu: Provide ordering for CPU not involved in grace period" [5]
> 
> Is this patch an improvement for SRCU which we are using for walking VMAs.
> 
>>
>> Ebizzy:
>> -------
>> The test is counting the number of records per second it can manage, the
>> higher is the best. I run it like this 'ebizzy -mTRp'. To get consistent
>> result I repeated the test 100 times and measure the average result, mean
>> deviation, max and min.
>>
>> - 16 CPUs x86 VM
>> Records/s	4.13-rc5	4.13-rc5-spf
>> Average		11350.29	21760.36
>> Mean deviation	396.56		881.40
>> Max		13773		26194
>> Min		10567		19223
>>
>> - 80 CPUs Power 8 node:
>> Records/s	4.13-rc5	4.13-rc5-spf
>> Average		33904.67	58847.91
>> Mean deviation	789.40		1753.19
>> Max		36703		68958
>> Min		31759		55125
>>
> 
> Can you also mention % improvement or degradation in a new column.

Fair enough:

- 16 CPUs x86 VM
Records/s	4.13-rc5	4.13-rc5-spf
Average		11350.29	21760.36	+92%
Mean deviation	396.56		881.40		+122%
Max		13773		26194		+90%
Min		10567		19223		+82%

- 80 CPUs Power 8 node:
Records/s	4.13-rc5	4.13-rc5-spf
Average		33904.67	58847.91	+74%
Mean deviation	789.40		1753.19		+122%
Max		36703		68958		+88%
Min		31759		55125		+74%


> 
>> The number of record per second is far better with the speculative page
>> fault.
>> The mean deviation is higher with the speculative page fault, may be
>> because sometime the fault are not handled in a speculative way leading to
>> more variation.
> 
> we need to analyze that. Why speculative page faults failed on those
> occasions for exact same workload.

That's not even clear that the mean deviation increasing is due to
speculative page fault failure. This will need to be study, but even if the
mean deviation is more important, the result are far better anyway.

>>
>>
>> Kernbench:
>> ----------
>> This test is building a 4.12 kernel using platform default config. The
>> build has been run 5 times each time.
>>
>> - 16 CPUs x86 VM
>> Average Half load -j 8 Run (std deviation)
>>  		 4.13.0-rc5		4.13.0-rc5-spf
>> Elapsed Time     166.574 (0.340779)	145.754 (0.776325)		
>> User Time        1080.77 (2.05871)	999.272 (4.12142)		
>> System Time      204.594 (1.02449)	116.362 (1.22974)		
>> Percent CPU 	 771.2 (1.30384)	765 (0.707107)
>> Context Switches 46590.6 (935.591)	66316.4 (744.64)
>> Sleeps           84421.2 (596.612)	85186 (523.041)		
> 
> 
>>
>> Average Optimal load -j 16 Run (std deviation)
>>  		 4.13.0-rc5		4.13.0-rc5-spf
>> Elapsed Time     85.422 (0.42293)	74.81 (0.419345)
>> User Time        1031.79 (51.6557)	954.912 (46.8439)
>> System Time      186.528 (19.0575)	107.514 (9.36902)
>> Percent CPU 	 1059.2 (303.607)	1056.8 (307.624)
>> Context Switches 67240.3 (21788.9)	89360.6 (24299.9)
>> Sleeps           89607.8 (5511.22)	90372.5 (5490.16)
>>
>> The elapsed time is a bit shorter in the case of the SPF release, but the
>> impact less important since there are less multithreaded processes involved
>> here. 
>>
>> - 80 CPUs Power 8 node:
>> Average Half load -j 40 Run (std deviation)
>>  		 4.13.0-rc5		4.13.0-rc5-spf
>> Elapsed Time     117.176 (0.824093)	116.792 (0.695392)
>> User Time        4412.34 (24.29)	4396.02 (24.4819)
>> System Time      131.106 (1.28343)	133.452 (0.708851)
>> Percent CPU      3876.8 (18.1439)	3877.6 (21.9955)
>> Context Switches 72470.2 (466.181)	72971 (673.624)
>> Sleeps           161294 (2284.85)	161946 (2217.9)
>>
>> Average Optimal load -j 80 Run (std deviation)
>>  		 4.13.0-rc5		4.13.0-rc5-spf
>> Elapsed Time     111.176 (1.11123)	111.242 (0.801542)
>> User Time        5930.03 (1600.07)	5929.89 (1617)
>> System Time      166.258 (37.0662)	169.337 (37.8419)
>> Percent CPU      5378.5 (1584.16)	5385.6 (1590.24)
>> Context Switches 117389 (47350.1)	130132 (60256.3)
>> Sleeps           163354 (4153.9)	163219 (2251.27)
>>
> 
> Can you also mention % improvement or degradation in a new column.

Fair enough:
- 16 CPUs x86 VM
Average Half load -j 8 Run (std deviation)
                 4.13.0-rc5             4.13.0-rc5-spf
Elapsed Time     166.574 (0.340779)     145.754 (0.776325)	-12.5%
User Time        1080.77 (2.05871)      999.272 (4.12142)	-7.54%
System Time      204.594 (1.02449)      116.362 (1.22974)	-43.13%
Percent CPU      771.2 (1.30384)        765 (0.707107)		-0.8%
Context Switches 46590.6 (935.591)      66316.4 (744.64)	+42.34%
Sleeps           84421.2 (596.612)      85186 (523.041)		+0.9%

Average Optimal load -j 16 Run (std deviation)
                 4.13.0-rc5             4.13.0-rc5-spf
Elapsed Time     85.422 (0.42293)       74.81 (0.419345)	-12.42%
User Time        1031.79 (51.6557)      954.912 (46.8439)	-7.45%
System Time      186.528 (19.0575)      107.514 (9.36902)	-42.36%
Percent CPU      1059.2 (303.607)       1056.8 (307.624)	-0.23%
Context Switches 67240.3 (21788.9)      89360.6 (24299.9)	+32.9%
Sleeps           89607.8 (5511.22)      90372.5 (5490.16)	+0.85%

- 80 CPUs Power 8 node:
Average Half load -j 40 Run (std deviation)
                 4.13.0-rc5             4.13.0-rc5-spf
Elapsed Time     117.176 (0.824093)     116.792 (0.695392)	-0.33%
User Time        4412.34 (24.29)        4396.02 (24.4819)	-0.37%
System Time      131.106 (1.28343)      133.452 (0.708851)	+1.79%
Percent CPU      3876.8 (18.1439)       3877.6 (21.9955)	+0.02%
Context Switches 72470.2 (466.181)      72971 (673.624)		+0.69%
Sleeps           161294 (2284.85)       161946 (2217.9)		+0.40%

Average Optimal load -j 80 Run (std deviation)
                 4.13.0-rc5             4.13.0-rc5-spf
Elapsed Time     111.176 (1.11123)      111.242 (0.801542)	+0.06%
User Time        5930.03 (1600.07)      5929.89 (1617)		+0%
System Time      166.258 (37.0662)      169.337 (37.8419)	+1.85%
Percent CPU      5378.5 (1584.16)       5385.6 (1590.24)	+0.13%
Context Switches 117389 (47350.1)       130132 (60256.3)	+10.86%
Sleeps           163354 (4153.9)        163219 (2251.27)	-0.08%


>> Here the elapsed time is a bit shorter using the spf release, but we
>> remain in the error margin. It has to be noted that this system is not
>> correctly balanced on the NUMA point of view as all the available memory is
>> attached to one core.
> 
> Why different NUMA configuration would have changed the outcome ?

I guess, process will have been scheduled nearest the memory, or spread in
a different way on the core if memory will be attached to.

>>
>> ------------------------
>> Changes since v1:
>>  - Remove PERF_COUNT_SW_SPF_FAILED perf event.
>>  - Add tracing events to details speculative page fault failures.
>>  - Cache VMA fields values which are used once the PTE is unlocked at the
>>  end of the page fault events.
> 
> Why is this required ?

Please see patch 07/20 for details.

Cheers,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
