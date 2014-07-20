Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id E36AA6B0036
	for <linux-mm@kvack.org>; Sun, 20 Jul 2014 13:35:24 -0400 (EDT)
Received: by mail-we0-f175.google.com with SMTP id t60so6598929wes.34
        for <linux-mm@kvack.org>; Sun, 20 Jul 2014 10:35:24 -0700 (PDT)
Received: from mail-wg0-x231.google.com (mail-wg0-x231.google.com [2a00:1450:400c:c00::231])
        by mx.google.com with ESMTPS id j3si22960515wjf.168.2014.07.20.10.35.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 20 Jul 2014 10:35:23 -0700 (PDT)
Received: by mail-wg0-f49.google.com with SMTP id k14so5509766wgh.8
        for <linux-mm@kvack.org>; Sun, 20 Jul 2014 10:35:22 -0700 (PDT)
From: David Herrmann <dh.herrmann@gmail.com>
Subject: [PATCH v4 0/6] File Sealing & memfd_create()
Date: Sun, 20 Jul 2014 19:34:34 +0200
Message-Id: <1405877680-999-1-git-send-email-dh.herrmann@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, Greg Kroah-Hartman <greg@kroah.com>, john.stultz@linaro.org, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Hugh Dickins <hughd@google.com>, Andy Lutomirski <luto@amacapital.net>, Alexander Viro <viro@zeniv.linux.org.uk>, David Herrmann <dh.herrmann@gmail.com>

Hi

This is v4 of the File-Sealing and memfd_create() patches. You can find v1 with
a longer introduction at gmane [1], there's also v2 [2] and v3 [3] available.
See also the article about sealing on LWN [4], and a high-level introduction on
the new API in my blog [5]. Last but not least, man-page proposals are
available in my private repository [6].

This series introduces two new APIs:
  memfd_create(): Think of this syscall as malloc() but it returns a
                  file-descriptor instead of a pointer. That file-descriptor is
                  backed by anon-memory and can be memory-mapped for access.
  sealing: The sealing API can be used to prevent a specific set of operations
           on a file-descriptor. You 'seal' the file and give thus the
           guarantee, that those operations will be rejected from now on.

This series adds the memfd_create(2) syscall only to x86 and x86-64. Patches for
most other architectures are available in my private repository [7]. Missing
architectures are:
    alpha, avr32, blackfin, cris, frv, m32r, microblaze, mn10300, sh, sparc,
    um, xtensa
These architectures lack several newer syscalls, so those should be added first
before adding memfd_create(2). I can provide patches for those, if required.
However, I think it should be kept separate from this series.

Changes in v4:
  - drop page-isolation in favor of shmem_wait_for_pins()
  - add unlikely(info->seals) to write_begin hot-path
  - return EPERM for F_ADD_SEALS if file is not writable
  - moved shmem_wait_for_pins() entirely into it's own commit
  - make O_LARGEFILE mandatory part of memfd_create() ABI
  - add lru_add_drain() to shmem_tag_pins() hot-path
  - minor coding-style changes

Thanks
David


[1]    memfd v1: http://thread.gmane.org/gmane.comp.video.dri.devel/102241
[2]    memfd v2: http://thread.gmane.org/gmane.linux.kernel.mm/115713
[3]    memfd v3: http://thread.gmane.org/gmane.linux.kernel.mm/118721
[4] LWN article: https://lwn.net/Articles/593918/
[5]   API Intro: http://dvdhrm.wordpress.com/2014/06/10/memfd_create2/
[6]   Man-pages: http://cgit.freedesktop.org/~dvdhrm/man-pages/log/?h=memfd
[7]    Dev-repo: http://cgit.freedesktop.org/~dvdhrm/linux/log/?h=memfd


David Herrmann (6):
  mm: allow drivers to prevent new writable mappings
  shm: add sealing API
  shm: add memfd_create() syscall
  selftests: add memfd_create() + sealing tests
  selftests: add memfd/sealing page-pinning tests
  shm: wait for pins to be released when sealing

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
 mm/mmap.c                                      |  30 +-
 mm/shmem.c                                     | 324 +++++++++
 mm/swap_state.c                                |   1 +
 tools/testing/selftests/Makefile               |   1 +
 tools/testing/selftests/memfd/.gitignore       |   4 +
 tools/testing/selftests/memfd/Makefile         |  41 ++
 tools/testing/selftests/memfd/fuse_mnt.c       | 110 +++
 tools/testing/selftests/memfd/fuse_test.c      | 311 +++++++++
 tools/testing/selftests/memfd/memfd_test.c     | 913 +++++++++++++++++++++++++
 tools/testing/selftests/memfd/run_fuse_test.sh |  14 +
 21 files changed, 1821 insertions(+), 9 deletions(-)
 create mode 100644 include/uapi/linux/memfd.h
 create mode 100644 tools/testing/selftests/memfd/.gitignore
 create mode 100644 tools/testing/selftests/memfd/Makefile
 create mode 100755 tools/testing/selftests/memfd/fuse_mnt.c
 create mode 100644 tools/testing/selftests/memfd/fuse_test.c
 create mode 100644 tools/testing/selftests/memfd/memfd_test.c
 create mode 100755 tools/testing/selftests/memfd/run_fuse_test.sh

-- 
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
