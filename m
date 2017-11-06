Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 12A4F6B0274
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 04:47:16 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id u97so5821064wrc.3
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 01:47:16 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m91si2772375ede.497.2017.11.06.01.47.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 01:47:13 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vA69ifCZ094207
	for <linux-mm@kvack.org>; Mon, 6 Nov 2017 04:47:12 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2e2h1qkfdp-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 06 Nov 2017 04:47:11 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 6 Nov 2017 09:47:09 -0000
Subject: Re: [PATCH v5 07/22] mm: Protect VMA modifications using VMA sequence
 count
References: <1507729966-10660-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1507729966-10660-8-git-send-email-ldufour@linux.vnet.ibm.com>
 <20171026101833.GF563@redhat.com>
 <2cbea37c-c2a7-bfd4-4528-fd273b210e29@linux.vnet.ibm.com>
 <ae35f020-3898-3f86-6d22-53b399d591be@linux.vnet.ibm.com>
 <20171102200840.GC22686@redhat.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Mon, 6 Nov 2017 10:47:00 +0100
MIME-Version: 1.0
In-Reply-To: <20171102200840.GC22686@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <c774dc09-dc3d-b721-8339-081e7584b709@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

Hi Andrea,

On 02/11/2017 21:08, Andrea Arcangeli wrote:
> On Thu, Nov 02, 2017 at 06:25:11PM +0100, Laurent Dufour wrote:
>> I think there is some memory barrier missing when the VMA is modified so
>> currently the modifications done in the VMA structure may not be written
>> down at the time the pte is locked. So doing that change will also requires
>> to call smp_wmb() before locking the page tables. In the current patch this
>> is ensured by the call to write_seqcount_end().
>> Doing so will still require to have a memory barrier when touching the VMA.
>> Not sure we get far better performance compared to the sequence count
>> change. But I'll give it a try anyway ;)
> 
> Luckily smp_wmb is a noop on x86. I would suggest to ignore the above
> issue completely if you give it a try, and then if this performs, we
> can just embed a smp_wmb() before spin_lock() somewhere in
> pte_offset_map_lock/pte_lockptr/spin_lock_nested for those archs whose
> spin_lock isn't a smp_wmb() equivalent. I would focus at flushing
> writes before every pagetable spin_lock for non-x86 archs, rather than
> after all vma modifications. That should be easier to keep under
> control and it's going to be more efficient too as if something there
> are fewer spin locks than vma modifications.

I do agree that would simplify the patch series a lot.
I'll double check that pte lock is not done in a loop other wise having
smp_wmb() there will be bad.

Another point I'm trying to double check is that we may have inconsistency
while reading the vma's flags in the page fault path until the memory
barrier got it in the VMA's changing path. Especially we may have vm_flags
and vm_page_prot not matching at all, which couldn't happen when checking
for the vm_sequence count.

> 
> For non-x86 archs we may then need a smp_wmb__before_spin_lock. That
> looks more self contained than surrounding all vma modifications and
> it's a noop on x86 anyway.
> 
> I thought about the contention detection logic too yesterday: to
> detect contention we could have a mm->mmap_sem_contention_jiffies and
> if down_read_trylock_exclusive() [same as down_read_if_not_hold in
> prev mail] fails (and it'll fail if either read or write mmap_sem is
> hold, so also convering mremap/mprotect etc..) we set
> mm->mmap_sem_contention_jiffies = jiffies and then to know if you must
> not touch the mmap_sem at all, you compare jiffies against
> mmap_sem_contention_jiffies, if it's equal we go speculative. If
> that's not enough we can just keep going speculative for a few more
> jiffies with time_before(). The srcu lock is non concerning because the
> inc/dec of the fast path is in per-cpu cacheline of course, no false
> sharing possible there or it wouldn't be any better than a normal lock.

I'm sorry, I should have missed something here. I can't see how this would
help fixing the case where a thread is entering the page fault handler
seeing that no one else has the mmap_sem and then grab it. While it is
processing the page fault another thread is entering mprotect for instance
and thus will wait for the mmap_sem to be released by the thread processing
the page fault.

Cheers,
Laurent.

> The vma revalidation is already done by khugepaged and mm/userfaultfd,
> both need to drop the mmap_sem and continue working on the pagetables,
> so we already know it's workable and not too slow.
> 
> Summarizing.. by using a runtime contention triggered speculative
> design that goes speculative only when contention is runtime-detected
> using the above logic (or equivalent), and by having to revalidate the
> vma by hand with find_vma without knowing instantly if the vma become
> stale, we will run with a substantially slower speculative page fault
> than with your current speculative always-on design, but the slower
> speculative page fault runtime will still scale 100% in SMP so it
> should still be faster on large SMP systems. The pros is that it won't
> regress the mmap/brk vma modifications. The whole complexity of
> tracking the vma modifications should also go away and the resulting
> code should be more maintainable and less risky to break in subtle
> ways impossible to reproduce.
> 
> Thanks!
> Andrea
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
