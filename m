Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7FC3B828E1
	for <linux-mm@kvack.org>; Tue, 28 Jun 2016 07:37:00 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id u81so21791025oia.3
        for <linux-mm@kvack.org>; Tue, 28 Jun 2016 04:37:00 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0113.outbound.protection.outlook.com. [157.55.234.113])
        by mx.google.com with ESMTPS id h77si80265oib.276.2016.06.28.04.36.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 28 Jun 2016 04:36:59 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv10 0/2] mremap vDSO for 32-bit
Date: Tue, 28 Jun 2016 14:35:37 +0300
Message-ID: <20160628113539.13606-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, mingo@redhat.com, luto@kernel.org, linux-mm@kvack.org, Dmitry Safonov <dsafonov@virtuozzo.com>

The first patch adds support of mremapping 32-bit vDSO.
One could move vDSO vma before this patch, but fast syscalls
on moved vDSO hasn't been working. It's because of code that
relies on mm->context.vdso pointer.
So all this code is just fixup for that pointer on moving.
(Also adds preventing for splitting vDSO vma).
As Andy notted, 64-bit vDSO mremap also has worked only by a chance
before this patches.
The second patch adds a test for the new functionality.

I need possibility to move vDSO in CRIU - on restore we need
to choose vma's position:
- if vDSO blob of restoring application is the same as the kernel has,
  we need to move it on the same place;
- if it differs, we need to choose place that wasn't tooken by other
  vma of restoring application and than add jump trampolines to it
  from the place of vDSO in restoring application.

CRIU code now relies on possibility on x86_64 to mremap vDSO.
Without this patch that may be broken in future.
And as I work on C/R of compatible 32-bit applications on x86_64,
I need mremap to work also for 32-bit vDSO. Which does not work,
because of context.vdso pointer mentioned above. 

Changes:
v10: run selftest after fork() and treat child segfaults for a nice
     error reports.
v9: Added cover-letter with changelog and reasons for patches
v8: Add WARN_ON_ONCE on current->mm != new_vma->vm_mm;
    run test for x86_64 too;
    removed fixed VDSO_SIZE - check EINVAL mremap return for partial remapping
v7: Build fix
v6: Moved vdso_image_32 check and fixup code into vdso_fix_landing function
    with ifdefs around
v5: As Andy suggested, add a check that new_vma->vm_mm and current->mm are
    the same, also check not only in_ia32_syscall() but image == &vdso_image_32;
    added test for mremapping vDSO
v4: Drop __maybe_unused & use image from mm->context instead vdso_image_32
v3: As Andy suggested, return EINVAL in case of splitting vdso blob on mremap;
    used is_ia32_task instead of ifdefs 
v2: Added __maybe_unused for pt_regs in vdso_mremap

Dmitry Safonov (2):
  x86/vdso: add mremap hook to vm_special_mapping
  selftest/x86: add mremap vdso test

 arch/x86/entry/vdso/vma.c                      |  47 +++++++++--
 include/linux/mm_types.h                       |   3 +
 mm/mmap.c                                      |  10 +++
 tools/testing/selftests/x86/Makefile           |   3 +-
 tools/testing/selftests/x86/test_mremap_vdso.c | 111 +++++++++++++++++++++++++
 5 files changed, 168 insertions(+), 6 deletions(-)
 create mode 100644 tools/testing/selftests/x86/test_mremap_vdso.c

-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
