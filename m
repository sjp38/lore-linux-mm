Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 78B226B0003
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 15:53:07 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id b9so3295497wra.1
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 12:53:07 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b12si534903wrg.445.2018.02.08.12.53.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Feb 2018 12:53:05 -0800 (PST)
Date: Thu, 8 Feb 2018 12:53:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v7 00/24] Speculative page faults
Message-Id: <20180208125301.99445c91979343756e4cca9b@linux-foundation.org>
In-Reply-To: <1517935810-31177-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1517935810-31177-1-git-send-email-ldufour@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Tue,  6 Feb 2018 17:49:46 +0100 Laurent Dufour <ldufour@linux.vnet.ibm.com> wrote:

> This is a port on kernel 4.15 of the work done by Peter Zijlstra to
> handle page fault without holding the mm semaphore [1].
> 
> The idea is to try to handle user space page faults without holding the
> mmap_sem. This should allow better concurrency for massively threaded
> process since the page fault handler will not wait for other threads memory
> layout change to be done, assuming that this change is done in another part
> of the process's memory space. This type page fault is named speculative
> page fault. If the speculative page fault fails because of a concurrency is
> detected or because underlying PMD or PTE tables are not yet allocating, it
> is failing its processing and a classic page fault is then tried.
> 
> The speculative page fault (SPF) has to look for the VMA matching the fault
> address without holding the mmap_sem, this is done by introducing a rwlock
> which protects the access to the mm_rb tree. Previously this was done using
> SRCU but it was introducing a lot of scheduling to process the VMA's
> freeing
> operation which was hitting the performance by 20% as reported by Kemi Wang
> [2].Using a rwlock to protect access to the mm_rb tree is limiting the
> locking contention to these operations which are expected to be in a O(log
> n)
> order. In addition to ensure that the VMA is not freed in our back a
> reference count is added and 2 services (get_vma() and put_vma()) are
> introduced to handle the reference count. When a VMA is fetch from the RB
> tree using get_vma() is must be later freeed using put_vma(). Furthermore,
> to allow the VMA to be used again by the classic page fault handler a
> service is introduced can_reuse_spf_vma(). This service is expected to be
> called with the mmap_sem hold. It checked that the VMA is still matching
> the specified address and is releasing its reference count as the mmap_sem
> is hold it is ensure that it will not be freed in our back. In general, the
> VMA's reference count could be decremented when holding the mmap_sem but it
> should not be increased as holding the mmap_sem is ensuring that the VMA is
> stable. I can't see anymore the overhead I got while will-it-scale
> benchmark anymore.
> 
> The VMA's attributes checked during the speculative page fault processing
> have to be protected against parallel changes. This is done by using a per
> VMA sequence lock. This sequence lock allows the speculative page fault
> handler to fast check for parallel changes in progress and to abort the
> speculative page fault in that case.
> 
> Once the VMA is found, the speculative page fault handler would check for
> the VMA's attributes to verify that the page fault has to be handled
> correctly or not. Thus the VMA is protected through a sequence lock which
> allows fast detection of concurrent VMA changes. If such a change is
> detected, the speculative page fault is aborted and a *classic* page fault
> is tried.  VMA sequence lockings are added when VMA attributes which are
> checked during the page fault are modified.
> 
> When the PTE is fetched, the VMA is checked to see if it has been changed,
> so once the page table is locked, the VMA is valid, so any other changes
> leading to touching this PTE will need to lock the page table, so no
> parallel change is possible at this time.
> 
> The locking of the PTE is done with interrupts disabled, this allows to
> check for the PMD to ensure that there is not an ongoing collapsing
> operation. Since khugepaged is firstly set the PMD to pmd_none and then is
> waiting for the other CPU to have catch the IPI interrupt, if the pmd is
> valid at the time the PTE is locked, we have the guarantee that the
> collapsing opertion will have to wait on the PTE lock to move foward. This
> allows the SPF handler to map the PTE safely. If the PMD value is different
> than the one recorded at the beginning of the SPF operation, the classic
> page fault handler will be called to handle the operation while holding the
> mmap_sem. As the PTE lock is done with the interrupts disabled, the lock is
> done using spin_trylock() to avoid dead lock when handling a page fault
> while a TLB invalidate is requested by an other CPU holding the PTE.
> 
> Support for THP is not done because when checking for the PMD, we can be
> confused by an in progress collapsing operation done by khugepaged. The
> issue is that pmd_none() could be true either if the PMD is not already
> populate or if the underlying PTE are in the way to be collapsed. So we
> cannot safely allocate a PMD if pmd_none() is true.
> 
> This series builds on top of v4.15-mmotm-2018-01-31-16-51 and is
> functional on x86 and PowerPC.

One question which people will want to answer is "is this thing
working".  ie, how frequently does the code fall back to the regular
heavyweight fault path.

I see that trace events have been added for this, but the overall
changelog doesn't describe them.  I think this material is important
enough to justify including it here.

Also, a few words to help people figure out how to gather these stats
would be nice.  And maybe helper scripts if appropriate?

I'm wondering if this info should even be presented via
/proc/self/something, dunno.

And it would be interesting to present the fallback frequency in the
benchmark results.

> ------------------
> Benchmarks results
> 
> There is no functional change compared to the v6 so benchmark results are
> the same.
> Please see https://lkml.org/lkml/2018/1/12/515 for details.

Please include this vitally important info in the [0/n], don't make
people chase links.

And I'd really like to see some quantitative testing results for real
workloads, not just a bunch of microbenchmarks.  Help us understand how
useful this patchset is to our users.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
