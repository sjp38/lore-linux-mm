Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 142476B0078
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 12:19:15 -0500 (EST)
Received: by wggy19 with SMTP id y19so54743467wgg.13
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 09:19:14 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id eg10si13993010wjd.26.2015.03.05.09.19.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 09:19:05 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 00/21] RFC: userfaultfd v3
Date: Thu,  5 Mar 2015 18:17:43 +0100
Message-Id: <1425575884-2574-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Android Kernel Team <kernel-team@android.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

Hello everyone,

This is a RFC for the userfaultfd syscall API v3 that addresses the
feedback received for the previous v2 submit.

The main change from the v2 is that MADV_USERFAULT/NOUSERFAULT
disappeared (they're replaced by the UFFDIO_REGISTER/UNREGISTER
ioctls). In short userfaults are now only possible through the
userfaultfd. The remap_anon_pages syscall also disappeared replaced by
the UFFDIO_REMAP ioctl which is in turn mostly obsoleted by the newer
UFFDIO_COPY and UFFDIO_ZEROPAGE ioctls that are indeed more efficient
by never having to flush the TLB. The suggestion to copy the data
instead of moving it, in order to resolve the userfault, was
immediately agreed.

The latest code can also be cloned here:

git clone --reference linux -b userfault git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git


Userfaults allow to implement on demand paging from userland and more
generally they allow userland to more efficiently take control on
various types of page faults.

For example userfaults allows a proper and more optimal implementation
of the PROT_NONE+SIGSEGV trick.

There has been interest from multiple users for different use cases:

1) KVM postcopy live migration (one form of cloud memory
   externalization). KVM postcopy live migration is the primary driver
   of this work:
   http://blog.zhaw.ch/icclab/setting-up-post-copy-live-migration-in-openstack/
   http://lists.gnu.org/archive/html/qemu-devel/2015-02/msg04873.html
   )

2) KVM postcopy live snapshotting (allowing to limit/throttle the
   memory usage, unlike fork would, plus the avoidance of fork
   overhead in the first place).

   The syscall API is already contemplating the wrprotect fault
   tracking and it's generic enough to allow its later implementation
   in a backwards compatible fashion.

3) KVM userfaults on shared memory. The UFFDIO_COPY lowlevel method
   should be extended to work also on tmpfs and then the
   uffdio_register.ioctls will notify userland that UFFDIO_COPY is
   available even when the registered virtual memory range is tmpfs
   backed.

4) alternate mechanism to notify web browsers or apps on embedded
   devices that volatile pages have been reclaimed. This basically
   avoids the need to run a syscall before the app can access with the
   CPU the virtual regions marked volatile. This also requires point 3)
   to be fulfilled, as volatile pages happily apply to tmpfs.

5) postcopy live migration of binaries inside linux containers.

Even though there wasn't a real use case requesting it yet, the new
API also allows to implement distributed shared memory in a way that
readonly shared mappings can exist simultaneously in different hosts
and they can be become exclusive at the first wrprotect fault.

The UFFDIO_REMAP method is still present in the patchset but it's
provided primarily to remove (add not) memory from the userfault
range. The addition of the UFFDIO_REMAP method is intentionally kept
at the end of the patchset. The postcopy live migration qemu code will
only use UFFDIO_COPY and UFFDIO_ZEROPAGE. UFFDIO_REMAP isn't intended
to be merged upstream in the short term, and it can be dropped later
if there's an agreement it's a bad idea to keep it around in the
patchset.

David run some KVM postcopy live migration benchmarks on a 8-way CPU
system and he measured that using UFFDIO_COPY instead of UFFDIO_REMAP
resulted in a roughly a -20% reduction in latency which is good. The
standard deviation error on the latency measurement decreased
significantly as well (because the number of CPUs that required IPI
delivery was variable, while the copy always takes roughly the same
time). A bigger improvement is expectable if measured on a larger host
with more CPUs.

All UFFDIO_COPY/ZEROPAGE/REMAP methods already support CRIU postcopy
live migration and the UFFD can be passed to a manager process through
unix domain sockets to satisfy point 5).

I look forward to discuss this further next week at the LSF/MM
summit, if you're attending the summit see you soon!

Comments welcome, thanks,
Andrea

Credits: partially funded by the Orbit EU project.

PS. There is one TODO detail worth mentioning for completeness that
affects usage 2) and UFFDIO_REMAP if used to remove memory from the
userfault range: handle_userfault() is only effective if
FAULT_FLAG_ALLOW_RETRY is set... but that is only set at the first
attempted page fault. If by accident some thread was already faulting
in the range and the first page fault attempt returned VM_FAULT_RETRY
and UFFDIO_REMAP or UFFDIO_WP jumps in to arm the userfault just
before the second attempt starts, a SIGBUS would be raised by the page
fault. Stopping all thread access to the userfault ranges during
UFFDIO_REMAP/WP while possible, isn't optimal. Currently (excluding
real filebacked mappings and handle_userfault() itself which is
clearly no problem) only tmpfs or a swapin can return
VM_FAULT_RETRY. To close this SIGBUS window for all usages, the
simplest solution would be that if FAULT_FLAG_TRIED is set
VM_FAULT_RETRY can still be returned (but only by handle_userfault
that has a legitimate reason for insisting a second time in a row with
VM_FAULT_RETRY). That would require some change to the FAULT_FLAG
semantics. Again userland could cope with this detail but it'd be
inefficient to solve it in userland. This would be a fully backwards
compatible change and it's only strictly required by the wrprotect
tracking mode, so it's no problem to solve this later. Because of its
inherent racy nature, nobody could possibly depend on a racy SIGBUS
being raised now, when it won't be raised anymore later.

Andrea Arcangeli (21):
  userfaultfd: waitqueue: add nr wake parameter to __wake_up_locked_key
  userfaultfd: linux/Documentation/vm/userfaultfd.txt
  userfaultfd: uAPI
  userfaultfd: linux/userfaultfd_k.h
  userfaultfd: add vm_userfaultfd_ctx to the vm_area_struct
  userfaultfd: add VM_UFFD_MISSING and VM_UFFD_WP
  userfaultfd: call handle_userfault() for userfaultfd_missing() faults
  userfaultfd: teach vma_merge to merge across vma->vm_userfaultfd_ctx
  userfaultfd: prevent khugepaged to merge if userfaultfd is armed
  userfaultfd: add new syscall to provide memory externalization
  userfaultfd: buildsystem activation
  userfaultfd: activate syscall
  userfaultfd: UFFDIO_COPY|UFFDIO_ZEROPAGE uAPI
  userfaultfd: mcopy_atomic|mfill_zeropage: UFFDIO_COPY|UFFDIO_ZEROPAGE
    preparation
  userfaultfd: UFFDIO_COPY and UFFDIO_ZEROPAGE
  userfaultfd: remap_pages: rmap preparation
  userfaultfd: remap_pages: swp_entry_swapcount() preparation
  userfaultfd: UFFDIO_REMAP uABI
  userfaultfd: remap_pages: UFFDIO_REMAP preparation
  userfaultfd: UFFDIO_REMAP
  userfaultfd: add userfaultfd_wp mm helpers

 Documentation/ioctl/ioctl-number.txt   |    1 +
 Documentation/vm/userfaultfd.txt       |   97 +++
 arch/powerpc/include/asm/systbl.h      |    1 +
 arch/powerpc/include/asm/unistd.h      |    2 +-
 arch/powerpc/include/uapi/asm/unistd.h |    1 +
 arch/x86/syscalls/syscall_32.tbl       |    1 +
 arch/x86/syscalls/syscall_64.tbl       |    1 +
 fs/Makefile                            |    1 +
 fs/userfaultfd.c                       | 1128 ++++++++++++++++++++++++++++++++
 include/linux/mm.h                     |    4 +-
 include/linux/mm_types.h               |   11 +
 include/linux/swap.h                   |    6 +
 include/linux/syscalls.h               |    1 +
 include/linux/userfaultfd_k.h          |  112 ++++
 include/linux/wait.h                   |    5 +-
 include/uapi/linux/userfaultfd.h       |  150 +++++
 init/Kconfig                           |   11 +
 kernel/fork.c                          |    3 +-
 kernel/sched/wait.c                    |    7 +-
 kernel/sys_ni.c                        |    1 +
 mm/Makefile                            |    1 +
 mm/huge_memory.c                       |  217 +++++-
 mm/madvise.c                           |    3 +-
 mm/memory.c                            |   16 +
 mm/mempolicy.c                         |    4 +-
 mm/mlock.c                             |    3 +-
 mm/mmap.c                              |   39 +-
 mm/mprotect.c                          |    3 +-
 mm/rmap.c                              |    9 +
 mm/swapfile.c                          |   13 +
 mm/userfaultfd.c                       |  793 ++++++++++++++++++++++
 net/sunrpc/sched.c                     |    2 +-
 32 files changed, 2593 insertions(+), 54 deletions(-)
 create mode 100644 Documentation/vm/userfaultfd.txt
 create mode 100644 fs/userfaultfd.c
 create mode 100644 include/linux/userfaultfd_k.h
 create mode 100644 include/uapi/linux/userfaultfd.h
 create mode 100644 mm/userfaultfd.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
