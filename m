Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id D7B9C6B009A
	for <linux-mm@kvack.org>; Thu, 14 May 2015 13:31:54 -0400 (EDT)
Received: by qkp63 with SMTP id 63so16722271qkp.0
        for <linux-mm@kvack.org>; Thu, 14 May 2015 10:31:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 184si283188qhy.54.2015.05.14.10.31.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 10:31:45 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 00/23] userfaultfd v4
Date: Thu, 14 May 2015 19:30:57 +0200
Message-Id: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org
Cc: Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

Hello everyone,

This is the latest userfaultfd patchset against mm-v4.1-rc3
2015-05-14-10:04.

The postcopy live migration feature on the qemu side is mostly ready
to be merged and it entirely depends on the userfaultfd syscall to be
merged as well. So it'd be great if this patchset could be reviewed
for merging in -mm.

Userfaults allow to implement on demand paging from userland and more
generally they allow userland to more efficiently take control of the
behavior of page faults than what was available before
(PROT_NONE + SIGSEGV trap).

The use cases are:

1) KVM postcopy live migration (one form of cloud memory
   externalization).

   KVM postcopy live migration is the primary driver of this work:

	http://blog.zhaw.ch/icclab/setting-up-post-copy-live-migration-in-openstack/
	http://lists.gnu.org/archive/html/qemu-devel/2015-02/msg04873.html

2) postcopy live migration of binaries inside linux containers:

	http://thread.gmane.org/gmane.linux.kernel.mm/132662

3) KVM postcopy live snapshotting (allowing to limit/throttle the
   memory usage, unlike fork would, plus the avoidance of fork
   overhead in the first place).

   While the wrprotect tracking is not implemented yet, the syscall API is
   already contemplating the wrprotect fault tracking and it's generic enough
   to allow its later implementation in a backwards compatible fashion.

4) KVM userfaults on shared memory. The UFFDIO_COPY lowlevel method
   should be extended to work also on tmpfs and then the
   uffdio_register.ioctls will notify userland that UFFDIO_COPY is
   available even when the registered virtual memory range is tmpfs
   backed.

5) alternate mechanism to notify web browsers or apps on embedded
   devices that volatile pages have been reclaimed. This basically
   avoids the need to run a syscall before the app can access with the
   CPU the virtual regions marked volatile. This depends on point 4)
   to be fulfilled first, as volatile pages happily apply to tmpfs.

Even though there wasn't a real use case requesting it yet, it also
allows to implement distributed shared memory in a way that readonly
shared mappings can exist simultaneously in different hosts and they
can be become exclusive at the first wrprotect fault.

The development version can also be cloned here:

	git clone --reference linux -b userfault git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git

Slides from LSF-MM summit (but beware that they're not uptodate):

	https://www.kernel.org/pub/linux/kernel/people/andrea/userfaultfd/userfaultfd-LSFMM-2015.pdf

Comments welcome.

Thanks,
Andrea

Changelog of the major changes since the last RFC v3:

o The API has been slightly modified to avoid having to introduce a
  second revision of the API, in order to support the non cooperative
  usage.

o Various mixed fixes thanks to the feedback from Dave Hansen and
  David Gilbert.

  The most notable one is the use of mm_users instead of mm_count to
  pin the mm to avoid crashes that assumed the vma still existed (in
  the userfaultfd_release method and in the various ioctl). exit_mmap
  doesn't even set mm->mmap to NULL, so unless I introduce a
  userfaultfd_exit to call in mmput, I have to pin the mm_users to be
  safe. This is a visible change mainly for the non-cooperative usage.

o userfaults are waken immediately even if they're not been "read"
  yet, this can lead to POLLIN false positives (so I only allow poll
  if the fd is open in nonblocking mode to be sure it won't hang).

	http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?h=userfault&id=f222d9de0a5302dc8ac62d6fab53a84251098751

o optimize read to return entries in O(1) and poll which was already
  O(1) becomes lockless. This required to split the waitqueue in two,
  one for pending faults and one for non pending faults, and the
  faults are refiled across the two waitqueues when they're read. Both
  waitqueues are protected by a single lock to be simpler and faster
  at runtime (the fault_pending_wqh one).

	http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?h=userfault&id=9aa033ed43a1134c2223dac8c5d9e02e0100fca1

o Allocate the ctx with kmem_cache_alloc.

	http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?h=userfault&id=f5a8db16d2876eed8906a4d36f1d0e06ca5490f6

o Originally qemu had two bitflags for each page and kept 3 states (of
  the 4 possible with two bits) for each page in order to deal with
  the races that can happen if one thread is reading the userfaults
  and another thread is calling the UFFDIO_COPY ioctl in the
  background. This patch solves all races in the kernel so the two
  bits per page can be dropped from qemu codebase. I started
  documenting the races that can materialize by using 2 threads
  (instead of running the workload single threaded with a single poll
  event loop) and how userland had to solve them until I decided it
  was simpler to fix the race in the kernel by running an ad-hoc
  pagetable walk inside the wait_event()-kind-of-section. This
  simplified qemu significantly (hundreds line of code involving a
  mutex have been deleted and that mutex disappeared as well) and it
  doesn't make the kernel much more complicated.

	http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?h=userfault&id=41efeae4e93f0296436f2a9fc6b28b6b0158512a

  After this patch the only reason to call UFFDIO_WAKE is to handle
  the userfaults in batches in combination with the DONT_WAKE flag of
  UFFDIO_COPY.

o I removed the read recursion from mcopy_atomic. This avoids to
  depend on the write-starvation behavior of rwsem to be safe. After
  this change the rwsem is free to stop any further down_read if
  there's a down_write waiting on the lock.

	http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?h=userfault&id=b1e3a08acc9e3f6c2614e89fc3b8e338daa58e18

o Extendeded the Documentation userfaultfd.txt file to explain how
  QEMU/KVM uses userfaultfd to implement postcopy live migration.

	http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?h=userfault&id=016f9523b7b2238851533736e84452cb00b2ddcd

Andrea Arcangeli (22):
  userfaultfd: linux/Documentation/vm/userfaultfd.txt
  userfaultfd: waitqueue: add nr wake parameter to __wake_up_locked_key
  userfaultfd: uAPI
  userfaultfd: linux/userfaultfd_k.h
  userfaultfd: add vm_userfaultfd_ctx to the vm_area_struct
  userfaultfd: add VM_UFFD_MISSING and VM_UFFD_WP
  userfaultfd: call handle_userfault() for userfaultfd_missing() faults
  userfaultfd: teach vma_merge to merge across vma->vm_userfaultfd_ctx
  userfaultfd: prevent khugepaged to merge if userfaultfd is armed
  userfaultfd: add new syscall to provide memory externalization
  userfaultfd: Rename uffd_api.bits into .features fixup
  userfaultfd: change the read API to return a uffd_msg
  userfaultfd: wake pending userfaults
  userfaultfd: optimize read() and poll() to be O(1)
  userfaultfd: allocate the userfaultfd_ctx cacheline aligned
  userfaultfd: solve the race between UFFDIO_COPY|ZEROPAGE and read
  userfaultfd: buildsystem activation
  userfaultfd: activate syscall
  userfaultfd: UFFDIO_COPY|UFFDIO_ZEROPAGE uAPI
  userfaultfd: mcopy_atomic|mfill_zeropage: UFFDIO_COPY|UFFDIO_ZEROPAGE
    preparation
  userfaultfd: avoid mmap_sem read recursion in mcopy_atomic
  userfaultfd: UFFDIO_COPY and UFFDIO_ZEROPAGE

Pavel Emelyanov (1):
  userfaultfd: Rename uffd_api.bits into .features

 Documentation/ioctl/ioctl-number.txt   |    1 +
 Documentation/vm/userfaultfd.txt       |  142 ++++
 arch/powerpc/include/asm/systbl.h      |    1 +
 arch/powerpc/include/uapi/asm/unistd.h |    1 +
 arch/x86/syscalls/syscall_32.tbl       |    1 +
 arch/x86/syscalls/syscall_64.tbl       |    1 +
 fs/Makefile                            |    1 +
 fs/proc/task_mmu.c                     |    2 +
 fs/userfaultfd.c                       | 1236 ++++++++++++++++++++++++++++++++
 include/linux/mm.h                     |    4 +-
 include/linux/mm_types.h               |   11 +
 include/linux/syscalls.h               |    1 +
 include/linux/userfaultfd_k.h          |   85 +++
 include/linux/wait.h                   |    5 +-
 include/uapi/linux/Kbuild              |    1 +
 include/uapi/linux/userfaultfd.h       |  161 +++++
 init/Kconfig                           |   11 +
 kernel/fork.c                          |    3 +-
 kernel/sched/wait.c                    |    7 +-
 kernel/sys_ni.c                        |    1 +
 mm/Makefile                            |    1 +
 mm/huge_memory.c                       |   75 +-
 mm/madvise.c                           |    3 +-
 mm/memory.c                            |   16 +
 mm/mempolicy.c                         |    4 +-
 mm/mlock.c                             |    3 +-
 mm/mmap.c                              |   40 +-
 mm/mprotect.c                          |    3 +-
 mm/userfaultfd.c                       |  309 ++++++++
 net/sunrpc/sched.c                     |    2 +-
 30 files changed, 2082 insertions(+), 50 deletions(-)
 create mode 100644 Documentation/vm/userfaultfd.txt
 create mode 100644 fs/userfaultfd.c
 create mode 100644 include/linux/userfaultfd_k.h
 create mode 100644 include/uapi/linux/userfaultfd.h
 create mode 100644 mm/userfaultfd.c

Credits: partially funded by the Orbit EU project.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
