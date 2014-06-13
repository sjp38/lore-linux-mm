Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id B74446B00AB
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 06:45:14 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id n15so630000wiw.11
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 03:45:14 -0700 (PDT)
Received: from mail-wg0-x22d.google.com (mail-wg0-x22d.google.com [2a00:1450:400c:c00::22d])
        by mx.google.com with ESMTPS id mz5si1299538wic.67.2014.06.13.03.45.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Jun 2014 03:45:13 -0700 (PDT)
Received: by mail-wg0-f45.google.com with SMTP id l18so2573896wgh.16
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 03:45:12 -0700 (PDT)
From: David Herrmann <dh.herrmann@gmail.com>
Subject: [PATCH v3 0/7] File Sealing & memfd_create()
Date: Fri, 13 Jun 2014 12:36:52 +0200
Message-Id: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, Greg Kroah-Hartman <greg@kroah.com>, john.stultz@linaro.org, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Hugh Dickins <hughd@google.com>, Tony Battersby <tonyb@cybernetics.com>, Andy Lutomirski <luto@amacapital.net>, David Herrmann <dh.herrmann@gmail.com>

Hi

This is v3 of the File-Sealing and memfd_create() patches. You can find v1 with
a longer introduction at gmane:
  http://thread.gmane.org/gmane.comp.video.dri.devel/102241
An LWN article about memfd+sealing is available, too:
  https://lwn.net/Articles/593918/
v2 with some more discussions can be found here:
  http://thread.gmane.org/gmane.linux.kernel.mm/115713

This series introduces two new APIs:
  memfd_create(): Think of this syscall as malloc() but it returns a
                  file-descriptor instead of a pointer. That file-descriptor is
                  backed by anon-memory and can be memory-mapped for access.
  sealing: The sealing API can be used to prevent a specific set of operations
           on a file-descriptor. You 'seal' the file and give thus the
           guarantee, that it cannot be modified in the specific ways.

A short high-level introduction is also available here:
  http://dvdhrm.wordpress.com/2014/06/10/memfd_create2/


Changed in v3:
 - fcntl() now returns EINVAL if the FD does not support sealing. We used to
   return EBADF like pipe_fcntl() does, but that is really weird and I don't
   like repeating that.
 - seals are now saved as "unsigned int" instead of "u32".
 - i_mmap_writable is now an atomic so we can deny writable mappings just like
   i_writecount does.
 - SHMEM_ALLOW_SEALING is dropped. We initialize all objects with F_SEAL_SEAL
   and only unset it for memfds that shall support sealing.
 - memfd_create() no longer has a size argument. It was redundant, use
   ftruncate() or fallocate().
 - memfd_create() flags are "unsigned int" now, instead of "u64".
 - NAME_MAX off-by-one fix
 - several cosmetic changes
 - Added AIO/Direct-IO page-pinning protection

The last point is the most important change in this version: We now bail out if
any page-refcount is elevated while setting SEAL_WRITE. This prevents parallel
GUP users from writing to sealed files _after_ they were sealed. There is also a
new FUSE-based test-case to trigger such situations.

The last 2 patches try to improve the page-pinning handling. I included both in
this series, but obviously only one of them is needed (or we could stack them):
 - 6/7: This waits for up to 150ms for pages to be unpinned
 - 7/7: This isolates pinned pages and replaces them with a fresh copy

Hugh, patch 6 is basically your code. In case that gets merged, can I put your
Signed-off-by on it?

I hope I didn't miss anything. Further comments welcome!

Thanks
David

David Herrmann (7):
  mm: allow drivers to prevent new writable mappings
  shm: add sealing API
  shm: add memfd_create() syscall
  selftests: add memfd_create() + sealing tests
  selftests: add memfd/sealing page-pinning tests
  shm: wait for pins to be released when sealing
  shm: isolate pinned pages when sealing files

 arch/x86/syscalls/syscall_32.tbl               |   1 +
 arch/x86/syscalls/syscall_64.tbl               |   1 +
 fs/fcntl.c                                     |   5 +
 fs/inode.c                                     |   1 +
 include/linux/fs.h                             |  29 +-
 include/linux/shmem_fs.h                       |  17 +
 include/linux/syscalls.h                       |   1 +
 include/uapi/linux/fcntl.h                     |  15 +
 include/uapi/linux/memfd.h                     |   8 +
 kernel/fork.c                                  |   2 +-
 kernel/sys_ni.c                                |   1 +
 mm/mmap.c                                      |  24 +-
 mm/shmem.c                                     | 320 ++++++++-
 mm/swap_state.c                                |   1 +
 tools/testing/selftests/Makefile               |   1 +
 tools/testing/selftests/memfd/.gitignore       |   4 +
 tools/testing/selftests/memfd/Makefile         |  40 ++
 tools/testing/selftests/memfd/fuse_mnt.c       | 110 +++
 tools/testing/selftests/memfd/fuse_test.c      | 311 +++++++++
 tools/testing/selftests/memfd/memfd_test.c     | 913 +++++++++++++++++++++++++
 tools/testing/selftests/memfd/run_fuse_test.sh |  14 +
 21 files changed, 1807 insertions(+), 12 deletions(-)
 create mode 100644 include/uapi/linux/memfd.h
 create mode 100644 tools/testing/selftests/memfd/.gitignore
 create mode 100644 tools/testing/selftests/memfd/Makefile
 create mode 100755 tools/testing/selftests/memfd/fuse_mnt.c
 create mode 100644 tools/testing/selftests/memfd/fuse_test.c
 create mode 100644 tools/testing/selftests/memfd/memfd_test.c
 create mode 100755 tools/testing/selftests/memfd/run_fuse_test.sh

-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
