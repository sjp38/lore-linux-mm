Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7C8B56B00BA
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 12:09:31 -0400 (EDT)
Date: Mon, 18 Oct 2010 13:34:03 -0200
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [PATCH v7 00/12] KVM: Add host swap event notifications for PV
 guest
Message-ID: <20101018153402.GA2067@amt.cnet>
References: <1287048176-2563-1-git-send-email-gleb@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1287048176-2563-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 14, 2010 at 11:22:44AM +0200, Gleb Natapov wrote:
> KVM virtualizes guest memory by means of shadow pages or HW assistance
> like NPT/EPT. Not all memory used by a guest is mapped into the guest
> address space or even present in a host memory at any given time.
> When vcpu tries to access memory page that is not mapped into the guest
> address space KVM is notified about it. KVM maps the page into the guest
> address space and resumes vcpu execution. If the page is swapped out from
> the host memory vcpu execution is suspended till the page is swapped
> into the memory again. This is inefficient since vcpu can do other work
> (run other task or serve interrupts) while page gets swapped in.
> 
> The patch series tries to mitigate this problem by introducing two
> mechanisms. The first one is used with non-PV guest and it works like
> this: when vcpu tries to access swapped out page it is halted and
> requested page is swapped in by another thread. That way vcpu can still
> process interrupts while io is happening in parallel and, with any luck,
> interrupt will cause the guest to schedule another task on the vcpu, so
> it will have work to do instead of waiting for the page to be swapped in.
> 
> The second mechanism introduces PV notification about swapped page state to
> a guest (asynchronous page fault). Instead of halting vcpu upon access to
> swapped out page and hoping that some interrupt will cause reschedule we
> immediately inject asynchronous page fault to the vcpu.  PV aware guest
> knows that upon receiving such exception it should schedule another task
> to run on the vcpu. Current task is put to sleep until another kind of
> asynchronous page fault is received that notifies the guest that page
> is now in the host memory, so task that waits for it can run again.
> 
> To measure performance benefits I use a simple benchmark program (below)
> that starts number of threads. Some of them do work (increment counter),
> others access huge array in random location trying to generate host page
> faults. The size of the array is smaller then guest memory bug bigger
> then host memory so we are guarantied that host will swap out part of
> the array.
> 
> I ran the benchmark on three setups: with current kvm.git (master),
> with my patch series + non-pv guest (nonpv) and with my patch series +
> pv guest (pv).
> 
> Each guest had 4 cpus and 2G memory and was launched inside 512M memory
> container. The command line was "./bm -f 4 -w 4 -t 60" (run 4 faulting
> threads and 4 working threads for a minute).
> 
> Below is the total amount of "work" each guest managed to do
> (average of 10 runs):
>          total work    std error
> master: 122789420615 (3818565029)
> nonpv:  138455939001 (773774299)
> pv:     234351846135 (10461117116)
> 
> Changes:
>  v1->v2
>    Use MSR instead of hypercall.
>    Move most of the code into arch independent place.
>    halt inside a guest instead of doing "wait for page" hypercall if
>     preemption is disabled.
>  v2->v3
>    Use MSR from range 0x4b564dxx.
>    Add slot version tracking.
>    Support migration by restarting all guest processes after migration.
>    Drop patch that tract preemptability for non-preemptable kernels
>     due to performance concerns. Send async PF to non-preemptable
>     guests only when vcpu is executing userspace code.
>  v3->v4
>   Provide alternative page fault handler in PV guest instead of adding hook to
>    standard page fault handler and patch it out on non-PV guests.
>   Allow only limited number of outstanding async page fault per vcpu.
>   Unify  gfn_to_pfn and gfn_to_pfn_async code.
>   Cancel outstanding slow work on reset.
>  v4->v5
>   Move async pv cpu initialization into cpu hotplug notifier.
>   Use GFP_NOWAIT instead of GFP_ATOMIC for allocation that shouldn't sleep
>   Process KVM_REQ_MMU_SYNC even in page_fault_other_cr3() before changing
>    cr3 back
>  v5->v6
>   To many. Will list only major changes here.
>   Replace slow work with work queues.
>   Halt vcpu for non-pv guests.
>   Handle async PF in nested SVM mode.
>   Do not prefault swapped in page for non tdp case.
>  v6->v7
>   Fix "GUP fail in work thread" problem
>   Do prefault only if mmu is in direct map mode
>   Use cpu->request to ask for vcpu halt (drop optimization that tried to
>    skip non-present apf injection if page is swapped in before next vmentry)
>   Keep track of synthetic halt in separate state to prevent it from leaking
>    during migration.
>   Fix memslot tracking problems.
>   More documentation.
>   Other small comments are addressed
> 
> Gleb Natapov (12):
>   Add get_user_pages() variant that fails if major fault is required.
>   Halt vcpu if page it tries to access is swapped out.
>   Retry fault before vmentry
>   Add memory slot versioning and use it to provide fast guest write interface
>   Move kvm_smp_prepare_boot_cpu() from kvmclock.c to kvm.c.
>   Add PV MSR to enable asynchronous page faults delivery.
>   Add async PF initialization to PV guest.
>   Handle async PF in a guest.
>   Inject asynchronous page fault into a PV guest if page is swapped out.
>   Handle async PF in non preemptable context
>   Let host know whether the guest can handle async PF in non-userspace context.
>   Send async PF when guest is not in userspace too.
> 
>  Documentation/kernel-parameters.txt |    3 +
>  Documentation/kvm/cpuid.txt         |    3 +
>  Documentation/kvm/msr.txt           |   36 ++++-
>  arch/x86/include/asm/kvm_host.h     |   28 +++-
>  arch/x86/include/asm/kvm_para.h     |   24 +++
>  arch/x86/include/asm/traps.h        |    1 +
>  arch/x86/kernel/entry_32.S          |   10 +
>  arch/x86/kernel/entry_64.S          |    3 +
>  arch/x86/kernel/kvm.c               |  315 +++++++++++++++++++++++++++++++++++
>  arch/x86/kernel/kvmclock.c          |   13 +--
>  arch/x86/kvm/Kconfig                |    1 +
>  arch/x86/kvm/Makefile               |    1 +
>  arch/x86/kvm/mmu.c                  |   61 ++++++-
>  arch/x86/kvm/paging_tmpl.h          |    8 +-
>  arch/x86/kvm/svm.c                  |   45 ++++-
>  arch/x86/kvm/x86.c                  |  192 +++++++++++++++++++++-
>  fs/ncpfs/mmap.c                     |    2 +
>  include/linux/kvm.h                 |    1 +
>  include/linux/kvm_host.h            |   39 +++++
>  include/linux/kvm_types.h           |    7 +
>  include/linux/mm.h                  |    5 +
>  include/trace/events/kvm.h          |   95 +++++++++++
>  mm/filemap.c                        |    3 +
>  mm/memory.c                         |   31 +++-
>  mm/shmem.c                          |    8 +-
>  virt/kvm/Kconfig                    |    3 +
>  virt/kvm/async_pf.c                 |  213 +++++++++++++++++++++++
>  virt/kvm/async_pf.h                 |   36 ++++
>  virt/kvm/kvm_main.c                 |  132 ++++++++++++---
>  29 files changed, 1255 insertions(+), 64 deletions(-)
>  create mode 100644 virt/kvm/async_pf.c
>  create mode 100644 virt/kvm/async_pf.h

Applied, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
