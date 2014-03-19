Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f46.google.com (mail-bk0-f46.google.com [209.85.214.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3FC4D6B016E
	for <linux-mm@kvack.org>; Wed, 19 Mar 2014 15:07:51 -0400 (EDT)
Received: by mail-bk0-f46.google.com with SMTP id v15so655318bkz.33
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 12:07:50 -0700 (PDT)
Received: from mail-bk0-x235.google.com (mail-bk0-x235.google.com [2a00:1450:4008:c01::235])
        by mx.google.com with ESMTPS id tx1si9999136bkb.325.2014.03.19.12.07.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Mar 2014 12:07:48 -0700 (PDT)
Received: by mail-bk0-f53.google.com with SMTP id r7so633624bkg.40
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 12:07:48 -0700 (PDT)
From: David Herrmann <dh.herrmann@gmail.com>
Subject: [PATCH 0/6] File Sealing & memfd_create()
Date: Wed, 19 Mar 2014 20:06:45 +0100
Message-Id: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <matthew@wil.cx>, Karol Lewandowski <k.lewandowsk@samsung.com>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, =?UTF-8?q?Kristian=20H=C3=B8gsberg?= <krh@bitplanet.net>, john.stultz@linaro.org, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, dri-devel@lists.freedesktop.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, David Herrmann <dh.herrmann@gmail.com>

Hi

This series introduces the concept of "file sealing". Sealing a file restricts
the set of allowed operations on the file in question. Multiple seals are
defined and each seal will cause a different set of operations to return EPERM
if it is set. The following seals are introduced:

 * SEAL_SHRINK: If set, the inode size cannot be reduced
 * SEAL_GROW: If set, the inode size cannot be increased
 * SEAL_WRITE: If set, the file content cannot be modified

Unlike existing techniques that provide similar protection, sealing allows
file-sharing without any trust-relationship. This is enforced by rejecting seal
modifications if you don't own an exclusive reference to the given file. So if
you own a file-descriptor, you can be sure that no-one besides you can modify
the seals on the given file. This allows mapping shared files from untrusted
parties without the fear of the file getting truncated or modified by an
attacker.

Several use-cases exist that could make great use of sealing:

  1) Graphics Compositors
     If a graphics client creates a memory-backed render-buffer and passes a
     file-decsriptor to it to the graphics server for display, the server
     _has_ to setup SIGBUS handlers whenever mapping the given file. Otherwise,
     the client might run ftruncate() or O_TRUNC on the on file in parallel,
     thus crashing the server.
     With sealing, a compositor can reject any incoming file-descriptor that
     does _not_ have SEAL_SHRINK set. This way, any memory-mappings are
     guaranteed to stay accessible. Furthermore, we still allow clients to
     increase the buffer-size in case they want to resize the render-buffer for
     the next frame. We also allow parallel writes so the client can render new
     frames into the same buffer (client is responsible of never rendering into
     a front-buffer if you want to avoid artifacts).

     Real use-case: Wayland wl_shm buffers can be transparently converted

  2) Geneal-purpose IPC
     IPC mechanisms that do not require a mutual trust-relationship (like dbus)
     cannot do zero-copy so far. With sealing, zero-copy can be easily done by
     sharing a file-descriptor that has SEAL_SHRINK | SEAL_GROW | SEAL_WRITE
     set. This way, the source can store sensible data in the file, seal the
     file and then pass it to the destination. The destination verifies these
     seals are set and then can parse the message in-line.
     Note that these files are usually one-shot files. Without any
     trust-relationship, a destination can notify the source that it released a
     file again, but a source can never rely on it. So unless the destination
     releases the file, a source cannot clear the seals for modification again.
     However, this is inherent to situations without any trust-relationship.

     Real use-case: kdbus messages already use a similar interface and can be
                    transparently converted to use these seals

Other similar use-cases exist (eg., audio), but these two I am personally
working on. Interest in this interface has been raised from several other camps
and I've put respective maintainers into CC. If more information on these
use-cases is needed, I think they can give some insights.

The API introduced by this patchset is:

 * fcntl() extension:
   Two new fcntl() commands are added that allow retrieveing (SHMEM_GET_SEALS)
   and setting (SHMEM_SET_SEALS) seals on a file. Only shmfs implements them so
   far and there is no intention to implement them on other file-systems.
   All shmfs based files support sealing.

   Patch 2/6

 * memfd_create() syscall:
   The new memfd_create() syscall is a public frontend to the shmem_file_new()
   interface in the kernel. It avoids the need of a local shmfs mount-point (as
   requested by android people) and acts more like MAP_ANON than O_TMPFILE.

   Patch 3/6

The other 4 patches are cleanups, self-tests and docs.

The commit-messages explain the API extensions in detail. Man-page proposals
are also provided. Last but not least, the extensive self-tests document the
intended behavior, in case it is still not clear.

Technically, sealing and memfd_create() are independent, but the described
use-cases would greatly benefit from the combination of both. Hence, I merged
them into the same series. Please also note that this series is based on earlier
works (ashmem, memfd, shmgetfd, ..) and unifies these attempts.

Comments welcome!

Thanks
David

David Herrmann (4):
  fs: fix i_writecount on shmem and friends
  shm: add sealing API
  shm: add memfd_create() syscall
  selftests: add memfd_create() + sealing tests

David Herrmann (2): (man-pages)
  fcntl.2: document SHMEM_SET/GET_SEALS commands
  memfd_create.2: add memfd_create() man-page

 arch/x86/syscalls/syscall_32.tbl           |   1 +
 arch/x86/syscalls/syscall_64.tbl           |   1 +
 fs/fcntl.c                                 |  12 +-
 fs/file_table.c                            |  27 +-
 include/linux/shmem_fs.h                   |  17 +
 include/linux/syscalls.h                   |   1 +
 include/uapi/linux/fcntl.h                 |  13 +
 include/uapi/linux/memfd.h                 |   9 +
 kernel/sys_ni.c                            |   1 +
 mm/shmem.c                                 | 267 +++++++-
 tools/testing/selftests/Makefile           |   1 +
 tools/testing/selftests/memfd/.gitignore   |   2 +
 tools/testing/selftests/memfd/Makefile     |  29 +
 tools/testing/selftests/memfd/memfd_test.c | 972 +++++++++++++++++++++++++++++
 14 files changed, 1338 insertions(+), 15 deletions(-)
 create mode 100644 include/uapi/linux/memfd.h
 create mode 100644 tools/testing/selftests/memfd/.gitignore
 create mode 100644 tools/testing/selftests/memfd/Makefile
 create mode 100644 tools/testing/selftests/memfd/memfd_test.c

-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
