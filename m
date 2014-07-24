Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 426B96B0035
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 00:49:45 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id rd3so3120573pab.14
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 21:49:44 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id be2si4608153pbb.236.2014.07.23.21.49.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Jul 2014 21:49:44 -0700 (PDT)
Received: by mail-pa0-f51.google.com with SMTP id ey11so3119995pad.38
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 21:49:43 -0700 (PDT)
Date: Wed, 23 Jul 2014 21:48:04 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v4 0/6] File Sealing & memfd_create()
In-Reply-To: <1405877680-999-1-git-send-email-dh.herrmann@gmail.com>
Message-ID: <alpine.LSU.2.11.1407232132330.991@eggly.anvils>
References: <1405877680-999-1-git-send-email-dh.herrmann@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Herrmann <dh.herrmann@gmail.com>, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, Greg Kroah-Hartman <greg@kroah.com>, john.stultz@linaro.org, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Hugh Dickins <hughd@google.com>, Andy Lutomirski <luto@amacapital.net>, Alexander Viro <viro@zeniv.linux.org.uk>

On Sun, 20 Jul 2014, David Herrmann wrote:

> Hi
> 
> This is v4 of the File-Sealing and memfd_create() patches. You can find v1 with
> a longer introduction at gmane [1], there's also v2 [2] and v3 [3] available.
> See also the article about sealing on LWN [4], and a high-level introduction on
> the new API in my blog [5]. Last but not least, man-page proposals are
> available in my private repository [6].
> 
> This series introduces two new APIs:
>   memfd_create(): Think of this syscall as malloc() but it returns a
>                   file-descriptor instead of a pointer. That file-descriptor is
>                   backed by anon-memory and can be memory-mapped for access.
>   sealing: The sealing API can be used to prevent a specific set of operations
>            on a file-descriptor. You 'seal' the file and give thus the
>            guarantee, that those operations will be rejected from now on.
> 
> This series adds the memfd_create(2) syscall only to x86 and x86-64. Patches for
> most other architectures are available in my private repository [7]. Missing
> architectures are:
>     alpha, avr32, blackfin, cris, frv, m32r, microblaze, mn10300, sh, sparc,
>     um, xtensa
> These architectures lack several newer syscalls, so those should be added first
> before adding memfd_create(2). I can provide patches for those, if required.
> However, I think it should be kept separate from this series.
> 
> Changes in v4:
>   - drop page-isolation in favor of shmem_wait_for_pins()
>   - add unlikely(info->seals) to write_begin hot-path
>   - return EPERM for F_ADD_SEALS if file is not writable
>   - moved shmem_wait_for_pins() entirely into it's own commit
>   - make O_LARGEFILE mandatory part of memfd_create() ABI
>   - add lru_add_drain() to shmem_tag_pins() hot-path
>   - minor coding-style changes
> 
> Thanks
> David
> 
> 
> [1]    memfd v1: http://thread.gmane.org/gmane.comp.video.dri.devel/102241
> [2]    memfd v2: http://thread.gmane.org/gmane.linux.kernel.mm/115713
> [3]    memfd v3: http://thread.gmane.org/gmane.linux.kernel.mm/118721
> [4] LWN article: https://lwn.net/Articles/593918/
> [5]   API Intro: http://dvdhrm.wordpress.com/2014/06/10/memfd_create2/
> [6]   Man-pages: http://cgit.freedesktop.org/~dvdhrm/man-pages/log/?h=memfd
> [7]    Dev-repo: http://cgit.freedesktop.org/~dvdhrm/linux/log/?h=memfd
> 
> 
> David Herrmann (6):
>   mm: allow drivers to prevent new writable mappings
>   shm: add sealing API
>   shm: add memfd_create() syscall
>   selftests: add memfd_create() + sealing tests
>   selftests: add memfd/sealing page-pinning tests
>   shm: wait for pins to be released when sealing

Andrew, I've now given my Ack to all of these, and think they are
ready for inclusion in mmotm, if you agree with the addition of
this sealing feature and the memfd_create() syscall.

Andy Lutomirsky and I agree that it's somewhat unsatisfactory that a
sealed sparse file could be passed, and inflate to something OOMing
when read by the recipient; but I think we can live with that as a
limitation of the initial implementation (the suspicious recipient
can verify non-sparseness with lseek SEEK_HOLE), and it's my job
to work on fixing that aspect - though probably not for 3.17.

Thanks,
Hugh

> 
>  arch/x86/syscalls/syscall_32.tbl               |   1 +
>  arch/x86/syscalls/syscall_64.tbl               |   1 +
>  fs/fcntl.c                                     |   5 +
>  fs/inode.c                                     |   1 +
>  include/linux/fs.h                             |  29 +-
>  include/linux/shmem_fs.h                       |  17 +
>  include/linux/syscalls.h                       |   1 +
>  include/uapi/linux/fcntl.h                     |  15 +
>  include/uapi/linux/memfd.h                     |   8 +
>  kernel/fork.c                                  |   2 +-
>  kernel/sys_ni.c                                |   1 +
>  mm/mmap.c                                      |  30 +-
>  mm/shmem.c                                     | 324 +++++++++
>  mm/swap_state.c                                |   1 +
>  tools/testing/selftests/Makefile               |   1 +
>  tools/testing/selftests/memfd/.gitignore       |   4 +
>  tools/testing/selftests/memfd/Makefile         |  41 ++
>  tools/testing/selftests/memfd/fuse_mnt.c       | 110 +++
>  tools/testing/selftests/memfd/fuse_test.c      | 311 +++++++++
>  tools/testing/selftests/memfd/memfd_test.c     | 913 +++++++++++++++++++++++++
>  tools/testing/selftests/memfd/run_fuse_test.sh |  14 +
>  21 files changed, 1821 insertions(+), 9 deletions(-)
>  create mode 100644 include/uapi/linux/memfd.h
>  create mode 100644 tools/testing/selftests/memfd/.gitignore
>  create mode 100644 tools/testing/selftests/memfd/Makefile
>  create mode 100755 tools/testing/selftests/memfd/fuse_mnt.c
>  create mode 100644 tools/testing/selftests/memfd/fuse_test.c
>  create mode 100644 tools/testing/selftests/memfd/memfd_test.c
>  create mode 100755 tools/testing/selftests/memfd/run_fuse_test.sh
> 
> -- 
> 2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
