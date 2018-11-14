Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5987B6B0277
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 18:16:19 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id 92so41268010qkx.19
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 15:16:19 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id t78si3669821qkg.248.2018.11.14.15.16.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 15:16:17 -0800 (PST)
Subject: Re: [RFC PATCH] mm: thp: implement THP reservations for anonymous
 memory
References: <1541746138-6706-1-git-send-email-anthony.yznaga@oracle.com>
 <20181109121318.3f3ou56ceegrqhcp@kshutemo-mobl1>
 <20181109195150.GA24747@redhat.com>
 <20181110132249.GH23260@techsingularity.net>
 <20181110164412.GB22642@redhat.com>
From: anthony.yznaga@oracle.com
Message-ID: <3310b7c3-4bcf-3378-e567-1c9200061c25@oracle.com>
Date: Wed, 14 Nov 2018 15:15:33 -0800
MIME-Version: 1.0
In-Reply-To: <20181110164412.GB22642@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, aneesh.kumar@linux.ibm.com, akpm@linux-foundation.org, jglisse@redhat.com, khandual@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, mhocko@kernel.org, minchan@kernel.org, peterz@infradead.org, rientjes@google.com, vbabka@suse.cz, willy@infradead.org, ying.huang@intel.com, nitingupta910@gmail.com



On 11/10/2018 08:44 AM, Andrea Arcangeli wrote:
> On Sat, Nov 10, 2018 at 01:22:49PM +0000, Mel Gorman wrote:
>> On Fri, Nov 09, 2018 at 02:51:50PM -0500, Andrea Arcangeli wrote:
>>> And if you're in the camp that is concerned about the use of more RAM
>>> or/and about the higher latency of COW faults, I'm afraid the
>>> intermediate solution will be still slower than the already available
>>> MADV_NOHUGEPAGE or enabled=madvise.
>>>
>> Does that not prevent huge page usage? Maybe you can spell it out a bit
> Yes it prevents huge page usage, but preventing the huge page usage is
> also what is achieved with the reservation.
>
>> better. What is the set of system calls an application should make to
>> not use huge pages either for the address space or on a per-VMA basis
>> and defer to kcompactd? I know that can be tuned globally but that's not
>> quite the same thing given that multiple applications or containers can
>> be running with different requirements.
> Yes, in terms of inheritance that could be used to tune a container
> we've only PR_SET_THP_DISABLE, and that will render MADV_HUGEPAGE
> useless too, but then for microservices that should not be a
> concern. How to make those sysfs tunables reentrant in namespaces is a
> separate issue I think.
>
> The difference is that with the reservation over time they can be
> promoted, with MADV_NOHUGEPAGE they cannot become hugepages later, not
> even khugepaged will scan that vma anymore.
>
> The benefit of the reservation will showup in those regions that will
> not become hugepages, so if you can predict beforehand that those
> ranges don't benefit from THP, it's better if userland calls
> madvise(MADV_NOHUGEPAGE) on the range and then there's no need to undo
> the reservation later during memory pressure.
>
> The reservation and promotion is a bit like auto-detecting when
> MADV_NOHUGEPAGE should be set, so it boils down of how much of a
> corner case that is.
>
> I'm not so concerned about the RAM wasted because I don't think it's
> very significant, after all the application can just do a smaller
> malloc if it wants to reduce memory usage.
>
> A massive amount of huge RAM waste is fairly rare and to the extreme
> it could still be wasted even with 4k if the app uses only 1 bit from
> every 4k page it allocates with malloc.
>
> I'm more concerned about cases where THP is wasting CPU: like in redis
> that is hurted by the 2M COWs. redis will map all pages and they will
> be all promoted to THP also with the reservation logic applied, but
> when the parent writes to the memory (after fork) it must trigger 4k
> cows (not 2M cows) and in turn split the THP before the COW, or it
> won't work as fast as with THP disabled. In addition we should try to
> reuse the same IPI for the transhuge pmd split to cover the COW too.
>
> If we add the reservation and that work makes zero difference for the
> redis corner case, and redis must still use MADV_NOHUGEPAGE, it's not
> great in my view. It looks like we're trying to optimize issues that
> are less critical.
>
> The redis+THP case should be possible to optimize later with uffd WP
> model (once completed, Peter Xu is working on it), and uffd WP will
> also remove fork() and it'll convert it to a clone(). The granularity
> of the fault is decided by the userland that way so when uffd
> wrprotects a 4k fragment of a THP, the THP will be split during the
> uffd mprotect ioctl.
>
>>> Now about the implementation: the whole point of the reservation
>>> complexity is to skip the khugepaged copy, so it can collapse in
>>> place. Is skipping the copy worth it? Isn't the big cost the IPI
>>> anyway to avoid leaving two simultaneous TLB mappings of different
>>> granularity?
>>>
>> Not necessarily. With THP anon in the simple case, it might be just a
>> single thread and kcompact so that's one IPI (kcompactd flushes local and
>> one IPI to the CPU the thread was running on assuming it's not migrating
>> excessively). It would scale up with the number of threads but I suspect
>> the main cost is the actual copying, page table manipulation and the
>> locking required.
> Agreed, the IPI wouldn't be a concern for a single threaded app. I was
> looking more at the worst case scenario. For a single threaded app the
> locking should not be too bad either.
>
>> As an aside, a universal benefit would be looking at reducing the time
>> to allocate the necessary huge page as we know that can be excessive. It
>> would be ortogonal to this series.
> With what I suggested the allocation would happen as usual in
> khugepaged at slow peace, without holding locks. So I don't see
> obvious disadvantages in terms of THP allocation latency.
>
>> Could you and Kirill outline what sort of workloads you would consider
>> acceptable for evaluating this series? One would assume it covers at
>> least the following, potentially with a number of workloads.
> I would prefer to add intelligence to detect when COWs after fork
> should be done at 2m or 4k granularity (in the latter case by
> splitting the pmd before the actual COW while leaving the transhuge
> pmd intact in the other mm), because that would save CPU (and it'd
> automatically optimize redis). The snapshot process especially would
> run faster as it will read with THP performance.
And presumably to maintain the performance benefit in subsequent
snapshots the original split PMD would need to be re-promoted
prior to forking or promoted in the child during fork?

>
> I'm more worried to ensure THP doesn't cause more CPU usage like it
> happens to the above case in COWs, than to just try to save RAM when
> the virtual ranges are only partially utilized by the app.
>
>> 1. Evaluate the collapse and copying costs (probing the entire time
>>    spent in collapse_huge_page might do it)
>> 2. Evaluate mmap_sem hold time during hugepage collapse
>> 3. Estimate excessive RAM use due to unnecessary THP usage
>> 4. Estimate the slowdown due to delayed THP usage 
>>
>> 1 and 2 would indicate how much time is lost due to not using
>> reservations. That potentially goes in the direction of simply making
>> this faster -- fragmentation reduction (posted but unreviewed), faster
>> compaction searches, better page isolation during compaction to
>> avoid free pages being reused before an order-9 is free.
>>
>> 3 should be straight-forward but 4 would be the hardest to evaluate
>> because it would have to be determimed if 4 is offset by improvements to
>> 1-3. If 1-3 is improved enough, it might remove the motivation for the
>> series entirely.
>>
>> In other words, if we agree on a workload in advance, it might bring
>> this the right direction and not accidentally throw Anthony down a hole
>> working on a series that never gets ack'd.
>>
>> I'm not necessarily the best person to answer because my natural inclination
>> after the fragmentation series would be to keep using thpfiosacle
>> (from the fragmentation avoidance series) and work on improving the THP
>> allocation success rates and reduce latencies. I've tunnel vision on that
>> for the moment.
> Deciding the workloads is a good question indeed, but I would also be
> curious to how many of those pages would not end up to be promoted
> with this logic.
>
> What's the number of pte_none that you require in each pmd to avoid
> promotion? If it's just 1 then apps will run slower, if there's
> partial utilization THP already helps. I've an hard time to think at
> an ideal ratio, this is why max_ptes_none is 511 after all.
>
> Can we start by counting the total number of pte_none() in all pmds
> that can fit a THP according to vma->vm_start/end? The pagetable
> dumper in debugfs may already provide the info we need by scanning all
> mm and by printing the number of "none" pte that would generate
> "wasted" memory (and marginally wasted CPU during copy/clear).
>
> Then you can exactly tell how many pmds won't be promoted to transhuge
> pmds with the patch applied in the real life workloads, even before
> running any benchmark. It'd be good to be sure we're talking about a
> significant number in real life workloads or there's not much to
> optimize to begin with.
>
> If the amount of RAM saved is significant in real life workloads and
> in turn there's a chance of having a worthwhile tradeoff from the
> reservation logic, then we can do the benchmarks because the behavior
> will be different for the page fault, and it'll end up running slower
> with the reservation logic.

Thank you, Andrea and Mel, for the feedback.A  I really appreciate it.
I'm going to proceed as suggested and evaluate the huge page
collapse and copy costs and perform more analysis on the potential
RAM savings.

Anthony

>
> Thanks,
> Andrea
