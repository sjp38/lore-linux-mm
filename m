Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 984AA6B0011
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 12:27:28 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id h128so2454856qke.8
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 09:27:28 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 63si3121298qth.293.2018.03.14.09.27.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 09:27:26 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2EGROYw039012
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 12:27:25 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gq5bcwy0w-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 12:27:24 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 14 Mar 2018 16:25:41 -0000
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: Re: [PATCH v9 17/24] mm: Protect mm_rb tree with a rwlock
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1520963994-28477-18-git-send-email-ldufour@linux.vnet.ibm.com>
 <20180314084844.GP4043@hirez.programming.kicks-ass.net>
Date: Wed, 14 Mar 2018 17:25:30 +0100
MIME-Version: 1.0
In-Reply-To: <20180314084844.GP4043@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <399d758c-c329-fe49-d501-065067eb3b29@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 14/03/2018 09:48, Peter Zijlstra wrote:
> On Tue, Mar 13, 2018 at 06:59:47PM +0100, Laurent Dufour wrote:
>> This change is inspired by the Peter's proposal patch [1] which was
>> protecting the VMA using SRCU. Unfortunately, SRCU is not scaling well in
>> that particular case, and it is introducing major performance degradation
>> due to excessive scheduling operations.
> 
> Do you happen to have a little more detail on that?

This has been reported by kemi who find bad performance when running some
benchmarks on top of the v5 series:
https://patchwork.kernel.org/patch/9999687/

It appears that SRCU is generating a lot of additional scheduling to manage the
freeing of the VMA structure. SRCU is dealing through per cpu ressources but
the SRCU callback is And since we are handling this way a per process
ressource (VMA) through a global resource (SRCU) this leads to a lot of
overhead when scheduling the SRCU callback.

>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
>> index 34fde7111e88..28c763ea1036 100644
>> --- a/include/linux/mm_types.h
>> +++ b/include/linux/mm_types.h
>> @@ -335,6 +335,7 @@ struct vm_area_struct {
>>  	struct vm_userfaultfd_ctx vm_userfaultfd_ctx;
>>  #ifdef CONFIG_SPECULATIVE_PAGE_FAULT
>>  	seqcount_t vm_sequence;
>> +	atomic_t vm_ref_count;		/* see vma_get(), vma_put() */
>>  #endif
>>  } __randomize_layout;
>>   
>> @@ -353,6 +354,9 @@ struct kioctx_table;
>>  struct mm_struct {
>>  	struct vm_area_struct *mmap;		/* list of VMAs */
>>  	struct rb_root mm_rb;
>> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
>> +	rwlock_t mm_rb_lock;
>> +#endif
>>  	u32 vmacache_seqnum;                   /* per-thread vmacache */
>>  #ifdef CONFIG_MMU
>>  	unsigned long (*get_unmapped_area) (struct file *filp,
> 
> When I tried this, it simply traded contention on mmap_sem for
> contention on these two cachelines.
> 
> This was for the concurrent fault benchmark, where mmap_sem is only ever
> acquired for reading (so no blocking ever happens) and the bottle-neck
> was really pure cacheline access.

I'd say that this expected if multiple threads are dealing on the same VMA, but
if the VMA differ then this contention is disappearing while it is remaining
when using the mmap_sem.

This being said, test I did on PowerPC using will-it-scale/page_fault1_threads
showed that the number of caches-misses generated in get_vma() are very low
(less than 5%). Am I missing something ?

> Only by using RCU can you avoid that thrashing.

I agree, but this kind of test is the best use case for SRCU because there are
not so many updates, so not a lot of call to the SRCU asynchronous callback.

Honestly, I can't see an ideal solution here, RCU is not optimal when there is
a high number of updates, and using a rwlock may introduced a bottleneck there.
I get better results when using the rwlock than using SRCU in that case, but if
you have another proposal, please advise, I'll give it a try.

> Also note that if your database allocates the one giant mapping, it'll
> be _one_ VMA and that vm_ref_count gets _very_ hot indeed.

In the case of the database product I mentioned in the series header, that's
the opposite, the VMA number is very high so this doesn't happen. But in the
case of one VMA, it's clear that there will be a contention on vm_ref_count,
but this would be better than blocking on the mmap_sem.

Laurent.
