Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 91B366B5132
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 07:41:23 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id o43-v6so5632895wrf.10
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 04:41:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r10-v6sor50709wmh.19.2018.08.30.04.41.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 Aug 2018 04:41:21 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v6 00/11] arm64: untag user pointers passed to the kernel
Date: Thu, 30 Aug 2018 13:41:05 +0200
Message-Id: <cover.1535629099.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrey Konovalov <andreyknvl@google.com>, Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>

arm64 has a feature called Top Byte Ignore, which allows to embed pointer
tags into the top byte of each pointer. Userspace programs (such as
HWASan, a memory debugging tool [1]) might use this feature and pass
tagged user pointers to the kernel through syscalls or other interfaces.

This patch makes a few of the kernel interfaces accept tagged user
pointers. The kernel is already able to handle user faults with tagged
pointers and has the untagged_addr macro, which this patchset reuses.

Thanks!

[1] http://clang.llvm.org/docs/HardwareAssistedAddressSanitizerDesign.html

Changes in v6:
- Added annotations for user pointer casts found by sparse.
- Rebased onto 050cdc6c (4.19-rc1+).

Changes in v5:
- Added 3 new patches that add untagging to places found with static
  analysis.
- Rebased onto 44c929e1 (4.18-rc8).

Changes in v4:
- Added a selftest for checking that passing tagged pointers to the
  kernel succeeds.
- Rebased onto 81e97f013 (4.18-rc1+).

Changes in v3:
- Rebased onto e5c51f30 (4.17-rc6+).
- Added linux-arch@ to the list of recipients.

Changes in v2:
- Rebased onto 2d618bdf (4.17-rc3+).
- Removed excessive untagging in gup.c.
- Removed untagging pointers returned from __uaccess_mask_ptr.

Changes in v1:
- Rebased onto 4.17-rc1.

Changes in RFC v2:
- Added "#ifndef untagged_addr..." fallback in linux/uaccess.h instead of
  defining it for each arch individually.
- Updated Documentation/arm64/tagged-pointers.txt.
- Dropped "mm, arm64: untag user addresses in memory syscalls".
- Rebased onto 3eb2ce82 (4.16-rc7).

Andrey Konovalov (11):
  arm64: add type casts to untagged_addr macro
  uaccess: add untagged_addr definition for other arches
  arm64: untag user addresses in access_ok and __uaccess_mask_ptr
  mm, arm64: untag user addresses in mm/gup.c
  lib, arm64: untag addrs passed to strncpy_from_user and strnlen_user
  arm64: untag user address in __do_user_fault
  fs, arm64: untag user address in copy_mount_options
  usb, arm64: untag user addresses in devio
  arm64: update Documentation/arm64/tagged-pointers.txt
  selftests, arm64: add a selftest for passing tagged pointers to kernel
  arm64: annotate user pointers casts detected by sparse

 Documentation/arm64/tagged-pointers.txt       |  5 +--
 arch/arm64/include/asm/compat.h               |  2 +-
 arch/arm64/include/asm/uaccess.h              | 16 ++++++----
 arch/arm64/kernel/perf_callchain.c            |  4 +--
 arch/arm64/kernel/signal.c                    | 16 +++++-----
 arch/arm64/kernel/signal32.c                  |  6 ++--
 arch/arm64/mm/fault.c                         |  4 +--
 block/compat_ioctl.c                          | 15 +++++----
 drivers/ata/libata-scsi.c                     |  2 +-
 drivers/block/loop.c                          |  2 +-
 drivers/gpio/gpiolib.c                        |  8 +++--
 drivers/input/evdev.c                         |  2 +-
 drivers/media/dvb-core/dvb_frontend.c         |  3 +-
 drivers/media/v4l2-core/v4l2-compat-ioctl32.c |  9 +++---
 drivers/mmc/core/block.c                      |  6 ++--
 drivers/mtd/mtdchar.c                         |  2 +-
 drivers/net/tap.c                             |  2 +-
 drivers/net/tun.c                             |  2 +-
 drivers/spi/spidev.c                          |  6 ++--
 drivers/tty/tty_ioctl.c                       |  3 +-
 drivers/tty/vt/vt_ioctl.c                     |  5 +--
 drivers/usb/core/devio.c                      | 10 ++++--
 drivers/vfio/vfio.c                           |  6 ++--
 drivers/video/fbdev/core/fbmem.c              |  4 +--
 drivers/xen/gntdev.c                          |  6 ++--
 drivers/xen/privcmd.c                         |  4 +--
 fs/aio.c                                      |  2 +-
 fs/autofs/dev-ioctl.c                         |  3 +-
 fs/autofs/root.c                              |  2 +-
 fs/binfmt_elf.c                               | 10 +++---
 fs/btrfs/ioctl.c                              |  2 +-
 fs/compat_ioctl.c                             | 32 ++++++++++---------
 fs/ext2/ioctl.c                               |  2 +-
 fs/ext4/ioctl.c                               |  2 +-
 fs/fat/file.c                                 |  3 +-
 fs/fuse/file.c                                |  2 +-
 fs/namespace.c                                |  2 +-
 fs/readdir.c                                  |  4 +--
 fs/signalfd.c                                 | 10 +++---
 include/linux/mm.h                            |  2 +-
 include/linux/pagemap.h                       |  8 ++---
 include/linux/socket.h                        |  2 +-
 include/linux/uaccess.h                       |  4 +++
 ipc/shm.c                                     |  4 +--
 kernel/futex.c                                |  6 ++--
 kernel/futex_compat.c                         |  2 +-
 kernel/power/user.c                           |  2 +-
 kernel/signal.c                               |  2 +-
 lib/iov_iter.c                                | 16 +++++-----
 lib/strncpy_from_user.c                       |  4 ++-
 lib/strnlen_user.c                            |  6 ++--
 lib/test_kasan.c                              |  2 +-
 mm/gup.c                                      |  4 +++
 mm/memory.c                                   |  2 +-
 mm/migrate.c                                  |  4 +--
 mm/process_vm_access.c                        | 13 ++++----
 net/bluetooth/hidp/sock.c                     |  2 +-
 net/compat.c                                  | 12 ++++---
 sound/core/control_compat.c                   |  5 +--
 sound/core/pcm_native.c                       |  5 +--
 sound/core/timer_compat.c                     |  3 +-
 tools/testing/selftests/arm64/.gitignore      |  1 +
 tools/testing/selftests/arm64/Makefile        | 11 +++++++
 .../testing/selftests/arm64/run_tags_test.sh  | 12 +++++++
 tools/testing/selftests/arm64/tags_test.c     | 19 +++++++++++
 65 files changed, 232 insertions(+), 147 deletions(-)
 create mode 100644 tools/testing/selftests/arm64/.gitignore
 create mode 100644 tools/testing/selftests/arm64/Makefile
 create mode 100755 tools/testing/selftests/arm64/run_tags_test.sh
 create mode 100644 tools/testing/selftests/arm64/tags_test.c

-- 
2.19.0.rc0.228.g281dcd1b4d0-goog
