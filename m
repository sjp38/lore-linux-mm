Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 134326B0255
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 14:05:46 -0500 (EST)
Received: by pfbo64 with SMTP id o64so31297549pfb.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 11:05:45 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id ho5si10064222pad.175.2015.12.14.11.05.43
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 11:05:43 -0800 (PST)
Subject: [PATCH 00/32] x86: Memory Protection Keys (v7)
From: Dave Hansen <dave@sr71.net>
Date: Mon, 14 Dec 2015 11:05:42 -0800
Message-Id: <20151214190542.39C4886D@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, aarcange@redhat.com, akpm@linux-foundation.org, jack@suse.cz, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, torvalds@linux-foundation.org

Memory Protection Keys for User pages is a CPU feature which will
first appear on Skylake Servers, but will also be supported on
future non-server parts (there is also a QEMU implementation).  It
provides a mechanism for enforcing page-based protections, but
without requiring modification of the page tables when an
application changes protection domains.  See the Documentation/
patch for more details.

This set enables for two things in the end:
1. Allows "execute-only" memory
2. Enables KVM to run Protection-Key-enabled guests

Changes from v6:
 * fix up ??'s showing up in in smaps' VmFlags field
 * added execute-only support
 * removed all the new syscalls from this set.  We can discuss
   them in detail after this is merged.

Changes from v5:

 * make types in read_pkru() u32's, not ints
 * rework VM_* bits to avoid using __ffsl() and clean up
   vma_pkey()
 * rework pte_allows_gup() to use p??_val() instead of passing
   around p{te,md,ud}_t types.
 * Fix up some inconsistent bool vs. int usage
 * corrected name of ARCH_VM_PKEY_FLAGS in patch description
 * remove NR_PKEYS... config option.  Just define it directly

Changes from v4:

 * Made "allow setting of XSAVE state" safe if we got preempted
   between when we saved our FPU state and when we restore it.
   (I would appreciate a look from Ingo on this patch).
 * Fixed up a few things from Thomas's latest comments: splt up
   siginfo in to x86 and generic, removed extra 'eax' variable
   in rdpkru function, reworked vm_flags assignment, reworded
   a comment in pte_allows_gup()
 * Add missing DISABLED/REQUIRED_MASK14 in cpufeature.h
 * Added comment about compile optimization in fault path
 * Left get_user_pages_locked() alone.  Andrea thinks we need it.

Changes from RFCv3:

 * Added 'current' and 'foreign' variants of get_user_pages() to
   help indicate whether protection keys should be enforced.
   Thanks to Jerome Glisse for pointing out this issue.
 * Added "allocation" and set/get system calls so that we can do
   management of proection keys in the kernel.  This opens the
   door to use of specific protection keys for kernel use in the
   future, such as for execute-only memory.
 * Removed the kselftest code for the moment.  It will be
   submitted separately.

Thanks Ingo and Thomas for most of these):
Changes from RFCv2 (Thanks Ingo and Thomas for most of these):

 * few minor compile warnings
 * changed 'nopku' interaction with cpuid bits.  Now, we do not
   clear the PKU cpuid bit, we just skip enabling it.
 * changed __pkru_allows_write() to also check access disable bit
 * removed the unused write_pkru()
 * made si_pkey a u64 and added some patch description details.
   Also made it share space in siginfo with MPX and clarified
   comments.
 * give some real text for the Processor Trace xsave state
 * made vma_pkey() less ugly (and much more optimized actually)
 * added SEGV_PKUERR to copy_siginfo_to_user()
 * remove page table walk when filling in si_pkey, added some
   big fat comments about it being inherently racy.
 * added self test code

This code is not runnable to anyone outside of Intel unless they
have some special hardware or a fancy simulator.  There is a qemu
model to emulate the feature, but it is not currently implemented
fully enough to be usable.  If you are interested in running this
for real, please get in touch with me.  Hardware is available to a
very small but nonzero number of people.

This set is also available here:

	git://git.kernel.org/pub/scm/linux/kernel/git/daveh/x86-pkeys.git pkeys-v018

=== diffstat ===

Dave Hansen (32):
      mm, gup: introduce concept of "foreign" get_user_pages()
      x86, fpu: add placeholder for Processor Trace XSAVE state
      x86, pkeys: Add Kconfig option
      x86, pkeys: cpuid bit definition
      x86, pkeys: define new CR4 bit
      x86, pkeys: add PKRU xsave fields and data structure(s)
      x86, pkeys: PTE bits for storing protection key
      x86, pkeys: new page fault error code bit: PF_PK
      x86, pkeys: store protection in high VMA flags
      x86, pkeys: arch-specific protection bits
      x86, pkeys: pass VMA down in to fault signal generation code
      signals, pkeys: notify userspace about protection key faults
      x86, pkeys: fill in pkey field in siginfo
      x86, pkeys: add functions to fetch PKRU
      mm: factor out VMA fault permission checking
      x86, mm: simplify get_user_pages() PTE bit handling
      x86, pkeys: check VMAs and PTEs for protection keys
      mm: add gup flag to indicate "foreign" mm access
      x86, pkeys: optimize fault handling in access_error()
      x86, pkeys: differentiate instruction fetches
      x86, pkeys: dump PKRU with other kernel registers
      x86, pkeys: dump PTE pkey in /proc/pid/smaps
      x86, pkeys: add Kconfig prompt to existing config option
      x86, pkeys: actually enable Memory Protection Keys in CPU
      mm, multi-arch: pass a protection key in to calc_vm_flag_bits()
      x86, pkeys: add arch_validate_pkey()
      x86: separate out LDT init from context init
      x86, fpu: allow setting of XSAVE state
      x86, pkeys: allow kernel to modify user pkey rights register
      x86, pkeys: create an x86 arch_calc_vm_prot_bits() for VMA flags
      x86, pkeys: execute-only support
      x86, pkeys: Documentation

 Documentation/kernel-parameters.txt         |   3 +
 Documentation/x86/protection-keys.txt       |  27 +++
 arch/mips/mm/gup.c                          |   3 +-
 arch/powerpc/include/asm/mman.h             |   5 +-
 arch/powerpc/include/asm/mmu_context.h      |  12 ++
 arch/s390/include/asm/mmu_context.h         |  12 ++
 arch/s390/mm/gup.c                          |   3 +-
 arch/sh/mm/gup.c                            |   2 +-
 arch/sparc/mm/gup.c                         |   2 +-
 arch/unicore32/include/asm/mmu_context.h    |  12 ++
 arch/x86/Kconfig                            |  16 ++
 arch/x86/include/asm/cpufeature.h           |  56 +++---
 arch/x86/include/asm/disabled-features.h    |  13 ++
 arch/x86/include/asm/fpu/internal.h         |   2 +
 arch/x86/include/asm/fpu/types.h            |  12 ++
 arch/x86/include/asm/fpu/xstate.h           |   4 +-
 arch/x86/include/asm/mmu_context.h          |  85 ++++++++-
 arch/x86/include/asm/pgtable.h              |  38 ++++
 arch/x86/include/asm/pgtable_types.h        |  34 +++-
 arch/x86/include/asm/pkeys.h                |  34 ++++
 arch/x86/include/asm/required-features.h    |   5 +
 arch/x86/include/asm/special_insns.h        |  22 +++
 arch/x86/include/uapi/asm/mman.h            |  22 +++
 arch/x86/include/uapi/asm/processor-flags.h |   2 +
 arch/x86/kernel/cpu/common.c                |  42 +++++
 arch/x86/kernel/fpu/core.c                  |  63 +++++++
 arch/x86/kernel/fpu/xstate.c                | 185 +++++++++++++++++++-
 arch/x86/kernel/ldt.c                       |   4 +-
 arch/x86/kernel/process_64.c                |   2 +
 arch/x86/kernel/setup.c                     |   9 +
 arch/x86/mm/Makefile                        |   2 +
 arch/x86/mm/fault.c                         | 171 +++++++++++++++---
 arch/x86/mm/gup.c                           |  46 +++--
 arch/x86/mm/mpx.c                           |   4 +-
 arch/x86/mm/pkeys.c                         | 101 +++++++++++
 drivers/char/agp/frontend.c                 |   2 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c     |   4 +-
 drivers/gpu/drm/i915/i915_gem_userptr.c     |   2 +-
 drivers/gpu/drm/radeon/radeon_ttm.c         |   4 +-
 drivers/gpu/drm/via/via_dmablit.c           |   3 +-
 drivers/infiniband/core/umem.c              |   2 +-
 drivers/infiniband/core/umem_odp.c          |   8 +-
 drivers/infiniband/hw/mthca/mthca_memfree.c |   3 +-
 drivers/infiniband/hw/qib/qib_user_pages.c  |   3 +-
 drivers/infiniband/hw/usnic/usnic_uiom.c    |   2 +-
 drivers/iommu/amd_iommu_v2.c                |   8 +-
 drivers/media/pci/ivtv/ivtv-udma.c          |   4 +-
 drivers/media/pci/ivtv/ivtv-yuv.c           |  10 +-
 drivers/media/v4l2-core/videobuf-dma-sg.c   |   3 +-
 drivers/misc/sgi-gru/grufault.c             |   3 +-
 drivers/scsi/st.c                           |   2 -
 drivers/staging/android/ashmem.c            |   4 +-
 drivers/video/fbdev/pvr2fb.c                |   4 +-
 drivers/virt/fsl_hypervisor.c               |   5 +-
 fs/exec.c                                   |   8 +-
 fs/proc/task_mmu.c                          |  14 ++
 include/asm-generic/mm_hooks.h              |  12 ++
 include/linux/mm.h                          |  60 +++++--
 include/linux/mman.h                        |   6 +-
 include/linux/pkeys.h                       |  33 ++++
 include/uapi/asm-generic/siginfo.h          |  17 +-

Cc: linux-api@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: aarcange@redhat.com
Cc: akpm@linux-foundation.org
Cc: jack@suse.cz
Cc: kirill.shutemov@linux.intel.com
Cc: linux-api@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: n-horiguchi@ah.jp.nec.com
Cc: x86@kernel.org
Cc: torvalds@linux-foundation.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
