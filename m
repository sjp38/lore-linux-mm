Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7F0316B0062
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 06:56:34 -0500 (EST)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH 00/11] KVM: Add asynchronous page fault for PV guest.
Date: Sun,  1 Nov 2009 13:56:19 +0200
Message-Id: <1257076590-29559-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

KVM virtualize guest memory by means of shadow pages or HW assistance
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

Gleb Natapov (11):
  Add shared memory hypercall to PV Linux guest.
  Add "handle page fault" PV helper.
  Handle asynchronous page fault in a PV guest.
  Export __get_user_pages_fast.
  Add get_user_pages() variant that fails if major fault is required.
  Inject asynchronous page fault into a guest if page is swapped out.
  Retry fault before vmentry
  Add "wait for page" hypercall.
  Maintain preemptability count even for !CONFIG_PREEMPT kernels
  Handle async PF in non preemptable context.
  Send async PF when guest is not in userspace too.

 arch/x86/include/asm/kvm_host.h       |   29 ++++-
 arch/x86/include/asm/kvm_para.h       |   14 ++
 arch/x86/include/asm/paravirt.h       |    7 +
 arch/x86/include/asm/paravirt_types.h |    4 +
 arch/x86/kernel/kvm.c                 |  210 ++++++++++++++++++++++++
 arch/x86/kernel/paravirt.c            |    8 +
 arch/x86/kernel/paravirt_patch_32.c   |    8 +
 arch/x86/kernel/paravirt_patch_64.c   |    7 +
 arch/x86/kernel/setup.c               |    1 +
 arch/x86/kernel/smpboot.c             |    3 +
 arch/x86/kvm/mmu.c                    |  284 ++++++++++++++++++++++++++++++++-
 arch/x86/kvm/mmutrace.h               |   79 +++++++++
 arch/x86/kvm/paging_tmpl.h            |   44 +++++-
 arch/x86/kvm/x86.c                    |   97 +++++++++++-
 arch/x86/mm/fault.c                   |    3 +
 arch/x86/mm/gup.c                     |    2 +
 fs/ncpfs/mmap.c                       |    2 +
 include/linux/hardirq.h               |    6 +-
 include/linux/kvm.h                   |    1 +
 include/linux/kvm_para.h              |    5 +
 include/linux/mm.h                    |    5 +
 include/linux/preempt.h               |   22 ++-
 kernel/sched.c                        |    6 -
 lib/kernel_lock.c                     |    1 +
 mm/filemap.c                          |    3 +
 mm/memory.c                           |   31 ++++-
 mm/shmem.c                            |    8 +-
 27 files changed, 855 insertions(+), 35 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
