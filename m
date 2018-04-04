Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 455806B0005
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 03:59:30 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id v187so6679800qka.5
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 00:59:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n4si4351556qkb.276.2018.04.04.00.59.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 00:59:28 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w347x4W4027941
	for <linux-mm@kvack.org>; Wed, 4 Apr 2018 03:59:27 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2h4tkq8k4h-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Apr 2018 03:59:27 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 4 Apr 2018 08:59:24 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: Re: [PATCH v9 00/24] Speculative page faults
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <20180403203718.GE5935@redhat.com>
Date: Wed, 4 Apr 2018 09:59:13 +0200
MIME-Version: 1.0
In-Reply-To: <20180403203718.GE5935@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <39d6f0da-9172-02bb-b9f6-d7a0758c3625@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

Hi Jerome,

Thanks for reviewing this series.

On 03/04/2018 22:37, Jerome Glisse wrote:
> On Tue, Mar 13, 2018 at 06:59:30PM +0100, Laurent Dufour wrote:
>> This is a port on kernel 4.16 of the work done by Peter Zijlstra to
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
>> address without holding the mmap_sem, this is done by introducing a rwlock
>> which protects the access to the mm_rb tree. Previously this was done using
>> SRCU but it was introducing a lot of scheduling to process the VMA's
>> freeing
>> operation which was hitting the performance by 20% as reported by Kemi Wang
>> [2].Using a rwlock to protect access to the mm_rb tree is limiting the
>> locking contention to these operations which are expected to be in a O(log
>> n)
>> order. In addition to ensure that the VMA is not freed in our back a
>> reference count is added and 2 services (get_vma() and put_vma()) are
>> introduced to handle the reference count. When a VMA is fetch from the RB
>> tree using get_vma() is must be later freeed using put_vma(). Furthermore,
>> to allow the VMA to be used again by the classic page fault handler a
>> service is introduced can_reuse_spf_vma(). This service is expected to be
>> called with the mmap_sem hold. It checked that the VMA is still matching
>> the specified address and is releasing its reference count as the mmap_sem
>> is hold it is ensure that it will not be freed in our back. In general, the
>> VMA's reference count could be decremented when holding the mmap_sem but it
>> should not be increased as holding the mmap_sem is ensuring that the VMA is
>> stable. I can't see anymore the overhead I got while will-it-scale
>> benchmark anymore.
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
>> is tried.  VMA sequence lockings are added when VMA attributes which are
>> checked during the page fault are modified.
>>
>> When the PTE is fetched, the VMA is checked to see if it has been changed,
>> so once the page table is locked, the VMA is valid, so any other changes
>> leading to touching this PTE will need to lock the page table, so no
>> parallel change is possible at this time.
> 
> What would have been nice is some pseudo highlevel code before all the
> above detailed description. Something like:
>   speculative_fault(addr) {
>     mm_lock_for_vma_snapshot()
>     vma_snapshot = snapshot_vma_infos(addr)
>     mm_unlock_for_vma_snapshot()
>     ...
>     if (!vma_can_speculatively_fault(vma_snapshot, addr))
>         return;
>     ...
>     /* Do fault ie alloc memory, read from file ... */
>     page = ...;
> 
>     preempt_disable();
>     if (vma_snapshot_still_valid(vma_snapshot, addr) &&
>         vma_pte_map_lock(vma_snapshot, addr)) {
>         if (pte_same(ptep, orig_pte)) {
>             /* Setup new pte */
>             page = NULL;
>         }
>     }
>     preempt_enable();
>     if (page)
>         put(page)
>   }
> 
> I just find pseudo code easier for grasping the highlevel view of the
> expected code flow.

Fair enough, I agree that sounds easier this way, but one might argue that the
pseudo code is not more valid or accurate at one time :)

As always, the updated documentation is the code itself.

I'll try to put one inspired by yours in the next series's header.

>>
>> The locking of the PTE is done with interrupts disabled, this allows to
>> check for the PMD to ensure that there is not an ongoing collapsing
>> operation. Since khugepaged is firstly set the PMD to pmd_none and then is
>> waiting for the other CPU to have catch the IPI interrupt, if the pmd is
>> valid at the time the PTE is locked, we have the guarantee that the
>> collapsing opertion will have to wait on the PTE lock to move foward. This
>> allows the SPF handler to map the PTE safely. If the PMD value is different
>> than the one recorded at the beginning of the SPF operation, the classic
>> page fault handler will be called to handle the operation while holding the
>> mmap_sem. As the PTE lock is done with the interrupts disabled, the lock is
>> done using spin_trylock() to avoid dead lock when handling a page fault
>> while a TLB invalidate is requested by an other CPU holding the PTE.
>>
>> Support for THP is not done because when checking for the PMD, we can be
>> confused by an in progress collapsing operation done by khugepaged. The
>> issue is that pmd_none() could be true either if the PMD is not already
>> populated or if the underlying PTE are in the way to be collapsed. So we
>> cannot safely allocate a PMD if pmd_none() is true.
> 
> Might be a good topic fo LSF/MM, should we set the pmd to something
> else then 0 when collapsing pmd (apply to pud too) ? This would allow
> support THP.

Absolutely !

> [...]
> 
>>
>> Ebizzy:
>> -------
>> The test is counting the number of records per second it can manage, the
>> higher is the best. I run it like this 'ebizzy -mTRp'. To get consistent
>> result I repeated the test 100 times and measure the average result. The
>> number is the record processes per second, the higher is the best.
>>
>>   		BASE		SPF		delta	
>> 16 CPUs x86 VM	14902.6		95905.16	543.55%
>> 80 CPUs P8 node	37240.24	78185.67	109.95%
> 
> I find those results interesting as it seems that SPF do not scale well
> on big configuration. Note that it still have a sizeable improvement so
> it is still a very interesting feature i believe.
> 
> Still understanding what is happening here might a good idea. From the
> numbers below it seems there is 2 causes to the scaling issue. First
> pte lock contention (kind of expected i guess). Second changes to vma
> while faulting.
> 
> Have you thought about this ? Do i read those numbers in the wrong way ?

Your reading of the numbers is correct, but there is also another point to keep
in mind, on ppc64, the default page size is 64K, and since we are mapping new
pages for user space, those pages have to be cleared, leading to more time
spent clearing pages on ppc64 which leads to less page fault ratio on ppc64.
And since the VMA is checked again once the cleared page is allocated, there is
a major chance for that VMA to be touched in the ebizzy case.

>>
>> Here are the performance counter read during a run on a 16 CPUs x86 VM:
>>  Performance counter stats for './ebizzy -mRTp':
>>             As always, the updated documentation is the code itself.
>>             888157      faults
>>             884773      spf
>>                 92      pagefault:spf_pte_lock
>>               2379      pagefault:spf_vma_changed
>>                  0      pagefault:spf_vma_noanon
>>                 80      pagefault:spf_vma_notsup
>>                  0      pagefault:spf_vma_access
>>                  0      pagefault:spf_pmd_changed
>>
>> And the ones captured during a run on a 80 CPUs Power node:
>>  Performance counter stats for './ebizzy -mRTp':
>>             762134      faults
>>             728663      spf
>>              19101      pagefault:spf_pte_lock
>>              13969      pagefault:spf_vma_changed
>>                  0      pagefault:spf_vma_noanon
>>                272      pagefault:spf_vma_notsup
>>                  0      pagefault:spf_vma_access
>>                  0      pagefault:spf_pmd_changed
> 
> 
> There is one aspect that i would like to see cover. Maybe i am not
> understanding something fundamental, but it seems to me that SPF can
> trigger OOM or at very least over stress page allocation.
> 
> Assume you have a lot of concurrent SPF to anonymous vma and they all
> allocate new pages, then you might overallocate for a single address
> by a factor correlated with the number of CPUs in your system. Now,
> multiply this for several distinc address and you might be allocating
> a lot of memory transiently ie just for a short period time. While
> the fact that you quickly free when you fail should prevent the OOM
> reaper. But still this might severly stress the memory allocation
> path.

That's an interesting point, and you're right, SPF may lead to page allocation
that will not be used.
But as you mentioned this will be a factor of CPU numbers, so the max page
overhead, assuming that all minus one threads of the same process are dealing
with page on the same VMA and the last one is touching that VMA parallel,
is (nrcpus-1) page allocated at one time which may not be used immediately.

I'm not sure this will be a major risk, but I might be too optimistic.

This raises also the question of the cleared page cache, I'd have to see if
there is such a cache is in place.

> Am i missing something in how this all work ? Or is the above some-
> thing that might be of concern ? Should there be some boundary on the
> maximum number of concurrent SPF (and thus boundary on maximum page
> temporary page allocation) ?

I don't think you're missing anything ;)

It would be easy to introduce such a limit in the case OOM are trigger too many
times due to SPF handling.

Cheers,
Laurent.
