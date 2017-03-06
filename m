Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id E22BE6B0388
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 09:21:20 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id g138so67818391itb.4
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 06:21:20 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0095.outbound.protection.outlook.com. [104.47.2.95])
        by mx.google.com with ESMTPS id u125si11017681itg.1.2017.03.06.06.21.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 06 Mar 2017 06:21:19 -0800 (PST)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv6 0/5] Fix compatible mmap() return pointer over 4Gb
Date: Mon, 6 Mar 2017 17:17:16 +0300
Message-ID: <20170306141721.9188-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, x86@kernel.org, linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, linux-kselftest@vger.kernel.org

Note: this patches set has some minor conflicts with Kirill's
set for 5-table paging. (with the patch "mm, x86: introduce
PR_SET_MAX_VADDR and PR_GET_MAX_VADDR").
Conflicts are minor and I'm OK rather rebase this set on linux-next
with his set or help him with rebasing (if he need it).

There are a couple of fixes related to x86 mmap():
o 1-2 are just preparation to introduce new mmap bases
o 3 fixes 32-bit syscall returning address over 4Gb in applications,
  launched from 64-bit binaries. This is done by introducing new bases:
  mmap_compat_base and mmap_compat_legacy_base.
  Those bases are separated from 64-bit ones, which allows to use
  mmap base according to bitness of the syscall.
  Which makes the behavior of 32-bit syscalls the same independently
  of launched binary's bitness (the same for 64-bit syscalls).
  It also makes possible to allocate with 64-bit mmap() address higher
  than 4Gb in compat ELFs - that may be used when 4Gb is not enough or
  with MAP_FIXED for hiding that mapping from 32-bit address space.
o 4 fixes behavior of MAP_32BIT - at this moment it's related
  to the bitness of executed binary, not of the syscall.
o 5 is a selftest to check that 32-bit mmap() does return 32-bit
  pointer.

Changes since v5:
- ifdef fixup (kbuild test robot)
- rebase on linux-next-20170306 (minor: sysret_rip test added)

Changes since v4 (Thomas's review):
- rewrote changelogs (so they should be readable by humans also)
- made code simpler (fighting to ifdef horror, etc)

Changes since v3:
- fixed usage of 64-bit random mask for 32-bit mm->mmap_compat_base,
  during introducing mmap_compat{_legacy,}_base

Changes since v2:
- don't distinguish native and compat tasks by TIF_ADDR32,
  introduced mmap_compat{_legacy,}_base which allows to treat them
  the same
- fixed kbuild errors

Changes since v1:
- Recalculate mmap_base instead of using max possible virtual address
  for compat/native syscall. That will make policy for allocation the
  same in 32-bit binaries and in 32-bit syscalls in 64-bit binaries.
  I need this because sys_mmap() in restored 32-bit process shouldn't
  hit the stack area.
- Fixed mmap() with MAP_32BIT flag in the same usecases
- used in_compat_syscall() helper rather TS_COMPAT check (Andy noticed)
- introduced find_top() helper as suggested by Andy to simplify code
- fixed test error-handeling: it checked the result of sys_mmap() with
  MMAP_FAILED, which is not correct, as it calls raw syscall - now
  checks return value to be aligned to PAGE_SIZE.

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Borislav Petkov <bp@suse.de>
Cc: x86@kernel.org
Cc: linux-mm@kvack.org
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Dmitry Safonov (5):
  x86/mm: introduce arch_rnd() to compute 32/64 mmap rnd
  x86/mm: add task_size parameter to mmap_base()
  x86/mm: introduce mmap_compat_base for 32-bit mmap()
  x86/mm: check in_compat_syscall() instead TIF_ADDR32 for
    mmap(MAP_32BIT)
  selftests/x86: add test for 32-bit mmap() return addr

 arch/Kconfig                                   |   7 +
 arch/x86/Kconfig                               |   1 +
 arch/x86/include/asm/elf.h                     |  27 ++--
 arch/x86/include/asm/processor.h               |   4 +-
 arch/x86/kernel/sys_x86_64.c                   |  27 +++-
 arch/x86/mm/mmap.c                             | 109 ++++++++-----
 include/linux/mm_types.h                       |   5 +
 tools/testing/selftests/x86/Makefile           |   2 +-
 tools/testing/selftests/x86/test_compat_mmap.c | 208 +++++++++++++++++++++++++
 9 files changed, 332 insertions(+), 58 deletions(-)
 create mode 100644 tools/testing/selftests/x86/test_compat_mmap.c

-- 
2.11.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
