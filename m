Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 5BE4E6B0071
	for <linux-mm@kvack.org>; Fri,  3 Oct 2014 13:08:46 -0400 (EDT)
Received: by mail-qg0-f46.google.com with SMTP id z60so1230063qgd.5
        for <linux-mm@kvack.org>; Fri, 03 Oct 2014 10:08:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e14si13339429qaa.39.2014.10.03.10.08.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Oct 2014 10:08:44 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 00/17] RFC: userfault v2
Date: Fri,  3 Oct 2014 19:07:50 +0200
Message-Id: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

Hello everyone,

There's a large To/Cc list for this RFC because this adds two new
syscalls (userfaultfd and remap_anon_pages) and
MADV_USERFAULT/MADV_NOUSERFAULT, so suggestions on changes are welcome
sooner than later.

The major change compared to the previous RFC I sent a few months ago
is that the userfaultfd protocol now supports dynamic range
registration. So you can have an unlimited number of userfaults for
each process, so each shared library can use its own userfaultfd on
its own memory independently from other shared libraries or the main
program. This functionality was suggested from Andy Lutomirski (more
details on this are in the commit header of the last patch of this
patchset).

In addition the mmap_sem complexities has been sorted out. In fact the
real userfault patchset starts from patch number 7. Patches 1-6 will
be submitted separately for merging and if applied standalone they
provide a scalability improvement by reducing the mmap_sem hold times
during I/O. I included patch 1-6 here too because they're an hard
dependency for the userfault patchset. The userfaultfd syscall depends
on the first fault to always have FAULT_FLAG_ALLOW_RETRY set (the
later retry faults don't matter, it's fine to clear
FAULT_FLAG_ALLOW_RETRY with the retry faults, following the current
model).

The combination of these features are what I would propose to
implement postcopy live migration in qemu, and in general demand
paging of remote memory, hosted in different cloud nodes.

If the access could ever happen in kernel context through syscalls
(not not just from userland context), then userfaultfd has to be used
on top of MADV_USERFAULT, to make the userfault unnoticeable to the
syscall (no error will be returned). This latter feature is more
advanced than what volatile ranges alone could do with SIGBUS so far
(but it's optional, if the process doesn't register the memory in a
userfaultfd, the regular SIGBUS will fire, if the fd is closed SIGBUS
will also fire for any blocked userfault that was waiting a
userfaultfd_write ack).

userfaultfd is also a generic enough feature, that it allows KVM to
implement postcopy live migration without having to modify a single
line of KVM kernel code. Guest async page faults, FOLL_NOWAIT and all
other GUP features works just fine in combination with userfaults
(userfaults trigger async page faults in the guest scheduler so those
guest processes that aren't waiting for userfaults can keep running in
the guest vcpus).

remap_anon_pages is the syscall to use to resolve the userfaults (it's
not mandatory, vmsplice will likely still be used in the case of local
postcopy live migration just to upgrade the qemu binary, but
remap_anon_pages is faster and ideal for transferring memory across
the network, it's zerocopy and doesn't touch the vma: it only holds
the mmap_sem for reading).

The current behavior of remap_anon_pages is very strict to avoid any
chance of memory corruption going unnoticed. mremap is not strict like
that: if there's a synchronization bug it would drop the destination
range silently resulting in subtle memory corruption for
example. remap_anon_pages would return -EEXIST in that case. If there
are holes in the source range remap_anon_pages will return -ENOENT.

If remap_anon_pages is used always with 2M naturally aligned
addresses, transparent hugepages will not be splitted. In there could
be 4k (or any size) holes in the 2M (or any size) source range,
remap_anon_pages should be used with the RAP_ALLOW_SRC_HOLES flag to
relax some of its strict checks (-ENOENT won't be returned if
RAP_ALLOW_SRC_HOLES is set, remap_anon_pages then will just behave as
a noop on any hole in the source range). This flag is generally useful
when implementing userfaults with THP granularity, but it shouldn't be
set if doing the userfaults with PAGE_SIZE granularity if the
developer wants to benefit from the strict -ENOENT behavior.

The remap_anon_pages syscall API is not vectored, as I expect it to be
used mainly for demand paging (where there can be just one faulting
range per userfault) or for large ranges (with the THP model as an
alternative to zapping re-dirtied pages with MADV_DONTNEED with 4k
granularity before starting the guest in the destination node) where
vectoring isn't going to provide much performance advantages (thanks
to the THP coarser granularity).

On the rmap side remap_anon_pages doesn't add much complexity: there's
no need of nonlinear anon vmas to support it because I added the
constraint that it will fail if the mapcount is more than 1. So in
general the source range of remap_anon_pages should be marked
MADV_DONTFORK to prevent any risk of failure if the process ever
forks (like qemu can in some case).

The MADV_USERFAULT feature should be generic enough that it can
provide the userfaults to the Android volatile range feature too, on
access of reclaimed volatile pages. Or it could be used for other
similar things with tmpfs in the future. I've been discussing how to
extend it to tmpfs for example. Currently if MADV_USERFAULT is set on
a non-anonymous vma, it will return -EINVAL and that's enough to
provide backwards compatibility once MADV_USERFAULT will be extended
to tmpfs. An orthogonal problem then will be to identify the optimal
mechanism to atomically resolve a tmpfs backed userfault (like
remap_anon_pages does it optimally for anonymous memory) but that's
beyond the scope of the userfault functionality (in theory
remap_anon_pages is also orthogonal and I could split it off in a
separate patchset if somebody prefers). Of course remap_file_pages
should do it fine too, but it would create rmap nonlinearity which
isn't optimal.

The code can be found here:

git clone --reference linux git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git -b userfault 

The branch is rebased so you can get updates for example with:

git fetch && git checkout -f origin/userfault

Comments welcome, thanks!
Andrea

Andrea Arcangeli (15):
  mm: gup: add get_user_pages_locked and get_user_pages_unlocked
  mm: gup: use get_user_pages_unlocked within get_user_pages_fast
  mm: gup: make get_user_pages_fast and __get_user_pages_fast latency
    conscious
  mm: gup: use get_user_pages_fast and get_user_pages_unlocked
  mm: madvise MADV_USERFAULT: prepare vm_flags to allow more than 32bits
  mm: madvise MADV_USERFAULT
  mm: PT lock: export double_pt_lock/unlock
  mm: rmap preparation for remap_anon_pages
  mm: swp_entry_swapcount
  mm: sys_remap_anon_pages
  waitqueue: add nr wake parameter to __wake_up_locked_key
  userfaultfd: add new syscall to provide memory externalization
  userfaultfd: make userfaultfd_write non blocking
  powerpc: add remap_anon_pages and userfaultfd
  userfaultfd: implement USERFAULTFD_RANGE_REGISTER|UNREGISTER

Andres Lagar-Cavilla (2):
  mm: gup: add FOLL_TRIED
  kvm: Faults which trigger IO release the mmap_sem

 arch/alpha/include/uapi/asm/mman.h     |   3 +
 arch/mips/include/uapi/asm/mman.h      |   3 +
 arch/mips/mm/gup.c                     |   8 +-
 arch/parisc/include/uapi/asm/mman.h    |   3 +
 arch/powerpc/include/asm/systbl.h      |   2 +
 arch/powerpc/include/asm/unistd.h      |   2 +-
 arch/powerpc/include/uapi/asm/unistd.h |   2 +
 arch/powerpc/mm/gup.c                  |   6 +-
 arch/s390/kvm/kvm-s390.c               |   4 +-
 arch/s390/mm/gup.c                     |   6 +-
 arch/sh/mm/gup.c                       |   6 +-
 arch/sparc/mm/gup.c                    |   6 +-
 arch/x86/mm/gup.c                      | 235 +++++++----
 arch/x86/syscalls/syscall_32.tbl       |   2 +
 arch/x86/syscalls/syscall_64.tbl       |   2 +
 arch/xtensa/include/uapi/asm/mman.h    |   3 +
 drivers/dma/iovlock.c                  |  10 +-
 drivers/iommu/amd_iommu_v2.c           |   6 +-
 drivers/media/pci/ivtv/ivtv-udma.c     |   6 +-
 drivers/scsi/st.c                      |  10 +-
 drivers/video/fbdev/pvr2fb.c           |   5 +-
 fs/Makefile                            |   1 +
 fs/proc/task_mmu.c                     |   5 +-
 fs/userfaultfd.c                       | 722 +++++++++++++++++++++++++++++++++
 include/linux/huge_mm.h                |  11 +-
 include/linux/ksm.h                    |   4 +-
 include/linux/mm.h                     |  15 +-
 include/linux/mm_types.h               |  13 +-
 include/linux/swap.h                   |   6 +
 include/linux/syscalls.h               |   5 +
 include/linux/userfaultfd.h            |  55 +++
 include/linux/wait.h                   |   5 +-
 include/uapi/asm-generic/mman-common.h |   3 +
 init/Kconfig                           |  11 +
 kernel/sched/wait.c                    |   7 +-
 kernel/sys_ni.c                        |   2 +
 mm/fremap.c                            | 506 +++++++++++++++++++++++
 mm/gup.c                               | 182 ++++++++-
 mm/huge_memory.c                       | 208 ++++++++--
 mm/ksm.c                               |   2 +-
 mm/madvise.c                           |  22 +-
 mm/memory.c                            |  14 +
 mm/mempolicy.c                         |   4 +-
 mm/mlock.c                             |   3 +-
 mm/mmap.c                              |  39 +-
 mm/mprotect.c                          |   3 +-
 mm/mremap.c                            |   2 +-
 mm/nommu.c                             |  23 ++
 mm/process_vm_access.c                 |   7 +-
 mm/rmap.c                              |   9 +
 mm/swapfile.c                          |  13 +
 mm/util.c                              |  10 +-
 net/ceph/pagevec.c                     |   9 +-
 net/sunrpc/sched.c                     |   2 +-
 virt/kvm/async_pf.c                    |   4 +-
 virt/kvm/kvm_main.c                    |   4 +-
 56 files changed, 2025 insertions(+), 236 deletions(-)
 create mode 100644 fs/userfaultfd.c
 create mode 100644 include/linux/userfaultfd.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
