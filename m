Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 390496B0037
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 14:38:54 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id um1so9852830pbc.16
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 11:38:53 -0700 (PDT)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id ef1si1500525pbc.472.2014.04.15.11.38.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 11:38:53 -0700 (PDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so9637142pdj.8
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 11:38:52 -0700 (PDT)
From: David Herrmann <dh.herrmann@gmail.com>
Subject: [PATCH v2 0/3] File Sealing & memfd_create()
Date: Tue, 15 Apr 2014 20:38:35 +0200
Message-Id: <1397587118-1214-1-git-send-email-dh.herrmann@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, john.stultz@linaro.org, =?UTF-8?q?Kristian=20H=C3=B8gsberg?= <krh@bitplanet.net>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, David Herrmann <dh.herrmann@gmail.com>

Hi

This is v2 of the File-Sealing and memfd_create() patches. You can find v1 with
a longer introduction at gmane:
  http://thread.gmane.org/gmane.comp.video.dri.devel/102241
An LWN article about memfd+sealing is available, too:
  https://lwn.net/Articles/593918/

Shortlog of changes since v1:
 - Dropped the "exclusive reference" idea
   Now sealing is a one-shot operation. Once a given seal is set, you cannot
   remove this seal again, ever. This allows us to drop all the ref-count
   checking and simplifies the code a lot. We also no longer have all the races
   we have to test for.
 - The i_writecount fix is now upstream (slightly different, by Al Viro) so I
   dropped it from the series.
 - Change SHMEM_* prefix to F_* to avoid any API-association to shmem.
 - Sealing is disabled on all files by default (even though we still haven't
   found any DoS attack). You need to pass MFD_ALLOW_SEALING to memfd_create()
   to get an object that supports the sealing API.
 - Changed F_SET_SEALS to F_ADD_SEALS. This better reflects the API. You can
   never remove seals, you can only add seals. Note that the semantics also
   changed slightly: You can now _always_ call F_ADD_SEALS to add _more_ seals.
   However, a new seal was added which "seals sealing" (F_SEAL_SEAL). So once
   F_SEAL_SEAL is set, F_ADD_SEAL is no longer allowed.
   This feature was requested by the glib developers.
 - memfd_create() names are now limited to NAME_MAX instead of 256 hardcoded.
 - Rewrote the test suite

The biggest change in v2 is the removal of the "exclusive reference" idea. It
was a nice optimization, but the implementation was ugly and racy regarding
file-table changes. Linus didn't like it either so we decided to drop it
entirely. Sealing is a one-shot operation now. A sealed file can never be
unsealed, even if you're the only holder.

I also addressed most of the concerns regarding API naming and semantics. I got
feedback from glib, EFL, wayland, kdbus, ostree, audio developers and we
discussed many possible use-cases (and also cases that don't make sense). So I
think we're in a very good state right now.

People requested to make this interface more generic. I renamed the API to
reflect that, but I didn't change the implementation. Thing is, seals cannot be
removed, ever. Therefore, semantics for sealing on non-volatile storage are
undefined. We don't write them to disc and it is unclear whether a sealed file
can be unlinked/removed again. There're more issues with this and no-one came up
with a use-case, hence I didn't bother implementing it.
There's also an ongoing discussion about an AIO race, but this also affects
other inode-protections like S_IMMUTABLE/etc. So I don't think we should tie
the fix to this series.
Another discussion was about preventing /proc/self/fd/. But again, no-one could
tell me _why_, so I didn't bother. On the contrary, I even provided several
use-cases that make use of /proc/self/fd/ to get read-only FDs to pass around.

If anyone wants to test this, please use 3.15-rc1 as base. The i_writecount
fixes are required for this series.

Comments welcome!
David

David Herrmann (3):
  shm: add sealing API
  shm: add memfd_create() syscall
  selftests: add memfd_create() + sealing tests

 arch/x86/syscalls/syscall_32.tbl           |   1 +
 arch/x86/syscalls/syscall_64.tbl           |   1 +
 fs/fcntl.c                                 |   5 +
 include/linux/shmem_fs.h                   |  20 +
 include/linux/syscalls.h                   |   1 +
 include/uapi/linux/fcntl.h                 |  15 +
 include/uapi/linux/memfd.h                 |  10 +
 kernel/sys_ni.c                            |   1 +
 mm/shmem.c                                 | 236 +++++++-
 tools/testing/selftests/Makefile           |   1 +
 tools/testing/selftests/memfd/.gitignore   |   2 +
 tools/testing/selftests/memfd/Makefile     |  29 +
 tools/testing/selftests/memfd/memfd_test.c | 944 +++++++++++++++++++++++++++++
 13 files changed, 1263 insertions(+), 3 deletions(-)
 create mode 100644 include/uapi/linux/memfd.h
 create mode 100644 tools/testing/selftests/memfd/.gitignore
 create mode 100644 tools/testing/selftests/memfd/Makefile
 create mode 100644 tools/testing/selftests/memfd/memfd_test.c

-- 
1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
