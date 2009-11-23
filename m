Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7179E6B0062
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 09:09:10 -0500 (EST)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v2 00/12] KVM: Add asynchronous page fault for PV guest.
Date: Mon, 23 Nov 2009 16:05:55 +0200
Message-Id: <1258985167-29178-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

KVM virtuaize guest memory by means of shadow pages or HW assistance
like NPT/EPT. Not all memory used by a guest is mapped into the guest
address space or even present in a host memory at any given time.
When vcpu tries to access memory page that is not mapped into guest
address space KVM is notified about it. KVM maps the page into guest
address space and resumes vcpu execution. If the page is swapped out
from host memory vcpu execution is suspended till page is not swapped
into the memory again. This is inefficient since vcpu can do other work
(run other task or serve interrupts) while page gets swapped in.

To overcome this inefficient this patch series implements "asynchronous
page fault" for paravirtualized  KVM guests. If a page that vcpu is trying
to access is swapped out KVM sends async PF to the vcpu and continues vcpu
execution. Requested page is swapped in by another thread in parallel.
When vcpu gets async PF it puts the task that faulted to sleep until
"wake up" interrupt is delivered. When page is brought to host memory
KVM sends "wake up" interrupt and the guest task resumes execution.

Changes:
 v1->v2
   Use MSR instead of hypercall.
   Move most of the code into arch independent place.
   halt inside a guest instead of doing "wait for page" hypercall if
    preemption is disabled.
   
Gleb Natapov (12):
  Move kvm_smp_prepare_boot_cpu() from kvmclock.c to kvm.c.
  Add PV MSR to enable asynchronous page faults delivery.
  Add async PF initialization to PV guest.
  Add "handle page fault" PV helper.
  Handle asynchronous page fault in a PV guest.
  Export __get_user_pages_fast.
  Add get_user_pages() variant that fails if major fault is required.
  Inject asynchronous page fault into a guest if page is swapped out.
  Retry fault before vmentry
  Maintain preemptability count even for !CONFIG_PREEMPT kernels
  Handle async PF in non preemptable context.
  Send async PF when guest is not in userspace too.

 arch/x86/include/asm/kvm_host.h       |   22 +++-
 arch/x86/include/asm/kvm_para.h       |   11 ++
 arch/x86/include/asm/paravirt.h       |    7 +
 arch/x86/include/asm/paravirt_types.h |    4 +
 arch/x86/kernel/kvm.c                 |  215 +++++++++++++++++++++++++++++++
 arch/x86/kernel/kvmclock.c            |   13 +--
 arch/x86/kernel/paravirt.c            |    8 +
 arch/x86/kernel/paravirt_patch_32.c   |    8 +
 arch/x86/kernel/paravirt_patch_64.c   |    7 +
 arch/x86/kernel/smpboot.c             |    3 +
 arch/x86/kvm/Kconfig                  |    2 +
 arch/x86/kvm/mmu.c                    |   46 ++++++-
 arch/x86/kvm/paging_tmpl.h            |   50 +++++++-
 arch/x86/kvm/x86.c                    |   86 ++++++++++++-
 arch/x86/mm/fault.c                   |    3 +
 arch/x86/mm/gup.c                     |    2 +
 fs/ncpfs/mmap.c                       |    2 +
 include/linux/hardirq.h               |   14 +--
 include/linux/kvm.h                   |    1 +
 include/linux/kvm_host.h              |   27 ++++
 include/linux/kvm_para.h              |    2 +
 include/linux/mm.h                    |    5 +
 include/linux/preempt.h               |   22 +++-
 include/linux/sched.h                 |    4 -
 include/trace/events/kvm.h            |   60 +++++++++
 kernel/sched.c                        |    6 -
 lib/kernel_lock.c                     |    1 +
 mm/filemap.c                          |    3 +
 mm/memory.c                           |   31 ++++-
 mm/shmem.c                            |    8 +-
 virt/kvm/Kconfig                      |    3 +
 virt/kvm/kvm_main.c                   |  227 ++++++++++++++++++++++++++++++++-
 32 files changed, 846 insertions(+), 57 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
