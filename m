Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 721AC6B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 19:50:29 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id os4so26937741pac.5
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 16:50:29 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id o2si6205684pfk.55.2016.10.11.16.50.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Oct 2016 16:50:28 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id 190so9742418pfv.1
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 16:50:28 -0700 (PDT)
From: Ruchi Kandoi <kandoiruchi@google.com>
Subject: [RFC 0/6] Module for tracking/accounting shared memory buffers
Date: Tue, 11 Oct 2016 16:50:04 -0700
Message-Id: <1476229810-26570-1-git-send-email-kandoiruchi@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kandoiruchi@google.com, gregkh@linuxfoundation.org, arve@android.com, riandrews@android.com, sumit.semwal@linaro.org, arnd@arndb.de, labbott@redhat.com, viro@zeniv.linux.org.uk, jlayton@poochiereds.net, bfields@fieldses.org, mingo@redhat.com, peterz@infradead.org, akpm@linux-foundation.org, keescook@chromium.org, mhocko@suse.com, oleg@redhat.com, john.stultz@linaro.org, mguzik@redhat.com, jdanis@google.com, adobriyan@gmail.com, ghackmann@google.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, dave.hansen@linux.intel.com, dan.j.williams@intel.com, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, luto@kernel.org, tj@kernel.org, vdavydov.dev@gmail.com, ebiederm@xmission.com, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

This patchstack introduces a new "memtrack" module for tracking and accounting
memory exported to userspace as shared buffers, like dma-buf fds or GEM handles.

Any process holding a reference to these buffers will keep the kernel from
reclaiming its backing pages.  mm counters don't provide a complete picture of
these allocations, since they only account for pages that are mapped into a
process's address space.  This problem is especially bad for systems like
Android that use dma-buf fds to share graphics and multimedia buffers between
processes: these allocations are often large, have complex sharing patterns,
and are rarely mapped into every process that holds a reference to them.

memtrack maintains a per-process list of shared buffer references, which is
exported to userspace as /proc/[pid]/memtrack.  Buffers can be optionally
"tagged" with a short string: for example, Android userspace would use this
tag to identify whether buffers were allocated on behalf of the camera stack,
GL, etc.  memtrack also exports the VMAs associated with these buffers so
that pages already included in the process's mm counters aren't double-counted.

Shared-buffer allocators can hook into memtrack by embedding
struct memtrack_buffer in their buffer metadata, calling
memtrack_buffer_{init,remove} at buffer allocation and free time, and
memtrack_buffer_{install,uninstall} when a userspace process takes or
drops a reference to the buffer.  For fd-backed buffers like dma-bufs, hooks in
fdtable.c and fork.c automatically notify memtrack when references are added or
removed from a process's fd table.

This patchstack adds memtrack hooks into dma-buf and ion.  If there's upstream
interest in memtrack, it can be extended to other memory allocators as well,
such as GEM implementations.

Greg Hackmann (1):
  drivers: staging: ion: add ION_IOC_TAG ioctl

Ruchi Kandoi (5):
  fs: add installed and uninstalled file_operations
  drivers: misc: add memtrack
  dma-buf: add memtrack support
  memtrack: Adds the accounting to keep track of all mmaped/unmapped
    pages.
  memtrack: Add memtrack accounting for forked processes.

 drivers/android/binder.c                |   4 +-
 drivers/dma-buf/dma-buf.c               |  37 +++
 drivers/misc/Kconfig                    |  16 +
 drivers/misc/Makefile                   |   1 +
 drivers/misc/memtrack.c                 | 516 ++++++++++++++++++++++++++++++++
 drivers/staging/android/ion/ion-ioctl.c |  17 ++
 drivers/staging/android/ion/ion.c       |  60 +++-
 drivers/staging/android/ion/ion_priv.h  |   2 +
 drivers/staging/android/uapi/ion.h      |  25 ++
 fs/file.c                               |  38 ++-
 fs/open.c                               |   2 +-
 fs/proc/base.c                          |   4 +
 include/linux/dma-buf.h                 |   5 +
 include/linux/fdtable.h                 |   4 +-
 include/linux/fs.h                      |   2 +
 include/linux/memtrack.h                | 130 ++++++++
 include/linux/mm.h                      |   3 +
 include/linux/sched.h                   |   3 +
 kernel/fork.c                           |  23 +-
 19 files changed, 875 insertions(+), 17 deletions(-)
 create mode 100644 drivers/misc/memtrack.c
 create mode 100644 include/linux/memtrack.h

-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
