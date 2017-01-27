Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8F2DD6B0038
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 16:00:45 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id c73so364896859pfb.7
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 13:00:45 -0800 (PST)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20122.outbound.protection.outlook.com. [40.107.2.122])
        by mx.google.com with ESMTPS id s5si2759909pgj.385.2017.01.27.13.00.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 27 Jan 2017 13:00:44 -0800 (PST)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv3 0/5] Fix compatible mmap() return pointer over 4Gb
Date: Sat, 28 Jan 2017 00:00:24 +0300
Message-ID: <20170127210029.31566-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, x86@kernel.org, linux-mm@kvack.org, Shuah Khan <shuah@kernel.org>, linux-kselftest@vger.kernel.org

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

Description from v1 [2]:

A fix for bug in mmap() that I referenced in [1].
Also selftest for it.

I would like to mark the fix as for stable v4.9 kernel if it'll
be accepted, as I try to support compatible 32-bit C/R
after v4.9 and working compatible mmap() is really wanted there.

[1]: https://marc.info/?l=linux-kernel&m=148311451525315
[2]: https://marc.info/?l=linux-kernel&m=148415888707662

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Borislav Petkov <bp@suse.de>
Cc: x86@kernel.org
Cc: linux-mm@kvack.org

Dmitry Safonov (5):
  x86/mm: split arch_mmap_rnd() on compat/native versions
  x86/mm: introduce mmap{,_legacy}_base
  x86/mm: fix 32-bit mmap() for 64-bit ELF
  x86/mm: check in_compat_syscall() instead TIF_ADDR32 for
    mmap(MAP_32BIT)
  selftests/x86: add test to check compat mmap() return addr

 arch/Kconfig                                   |   7 +
 arch/x86/Kconfig                               |   1 +
 arch/x86/include/asm/elf.h                     |   4 +-
 arch/x86/include/asm/processor.h               |   3 +-
 arch/x86/kernel/sys_x86_64.c                   |  32 +++-
 arch/x86/mm/mmap.c                             |  80 ++++++----
 include/linux/mm_types.h                       |   5 +
 tools/testing/selftests/x86/Makefile           |   2 +-
 tools/testing/selftests/x86/test_compat_mmap.c | 208 +++++++++++++++++++++++++
 9 files changed, 307 insertions(+), 35 deletions(-)
 create mode 100644 tools/testing/selftests/x86/test_compat_mmap.c

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
