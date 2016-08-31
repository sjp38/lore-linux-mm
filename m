Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 69E926B025E
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 10:01:54 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id le9so92041565pab.0
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 07:01:54 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0120.outbound.protection.outlook.com. [104.47.0.120])
        by mx.google.com with ESMTPS id pk3si54880pab.101.2016.08.31.07.01.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 31 Aug 2016 07:01:52 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv4 0/6] x86: 32-bit compatible C/R on x86_64
Date: Wed, 31 Aug 2016 16:59:30 +0300
Message-ID: <20160831135936.2281-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, luto@kernel.org, oleg@redhat.com, tglx@linutronix.de, hpa@zytor.com, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, gorcunov@openvz.org, xemul@virtuozzo.com, Dmitry Safonov <dsafonov@virtuozzo.com>

Changes from v3:
- proper ifdefs around vdso_image_32
- missed Reviewed-by tag

Changes from v2:
- reworked map_vdso() part with Andy suggestions
- int arch_prctl(ARCH_MAP_VDSO_*, addr) now returns size of mapped
  vdso blob on success, which is handy for the following blob parsing
  in userspace
- disallowed two vDSO blobs mappings: as Andy noted,
  __insert_special_mapping may not get all accounting right, which
  may lead to abuse this API from userspace. Return -EEXIST if process
  has mapped vdso blob - this will ensure that caller knows what it does.

The following changes are available since v1:
- killed PR_REG_SIZE macro as Oleg suggested
- cleared SA_IA32_ABI|SA_X32_ABI from oact->sa.sa_flags in do_sigaction()
  as noticed by Oleg
- moved SA_IA32_ABI|SA_X32_ABI from uapi header as those flags shouldn't
  be exposed to user-space

I also reworked CRIU's patches to work with this patches set, rather than
on first RFC that swapped TIF_IA32 with arch_prctl. By now it yet fails
~10% of 32-bit tests of CRIU's test suite called ZDTM.
The CRIU branch for this can be viewed on [6] and v3 patches to add
this functionality have been sent to maillist [7].

The patches set is based on [3] and while it's not yet applied -- it
may make kbuild test robot unhappy.

Description from v1 [5]:

This patches set is an attempt to add checkpoint/restore
for 32-bit tasks in compatibility mode on x86_64 hosts.

Restore in CRIU starts from one root restoring process, which
reads info for all threads being restored from images files.
This information is used further to find out which processes
share some resources. Later shared resources are restored only
by one process and all other inherit them.
After that it calls clone() and new threads restore their
properties in parallel. Those threads inherit all parent's
mappings and fetch properties from those mappings
(and do clone themself, if they have children/subthreads). [1]
Then starts restorer blob's play, it's PIE binary, which
unmaps all unneeded for restoring VMAs, maps new VMAs and
finalize restoring with sigreturn syscall. [2]

To restore of 32-bit task we need three things to do in running
x86_64 restorer blob:
a) set code selector to __USER32_CS (to run 32-bit code);
b) remap vdso blob from 64-bit to 32-bit
   This is primary needed because restore may happen on a different
   kernel, which has different vDSO image than we had on dump.
c) if 32-bit vDSO differ to dumped image, move it on free place
   and add jump trampolines to that place.
d) switch TIF_IA32 flag, so kernel would know that it deals with
   compatible 32-bit application.

>From all this:
a) setting CS may be done from userspace, no patches needed;
b) patches 1-3 add ability to map different vDSO blobs on x86 kernel;
c) for remapping/moving 32-bit vDSO blob patches have been send earlier
   and seems to be accepted [3]
d) and for swapping TIF_IA32 flag discussion with Andy ended in conclusion
   that it's better to remove this flag completely.
   Patches 4-6 deletes usage of TIF_IA32 from ptrace, signal and coredump
   code. This is rework/resend of RFC [4]

[1] https://criu.org/Checkpoint/Restore#Restore
[2] https://criu.org/Restorer_context
[3] https://lkml.org/lkml/2016/6/28/489
[4] https://lkml.org/lkml/2016/4/25/650
[5] https://lkml.org/lkml/2016/6/1/425
[6] https://github.com/0x7f454c46/criu/tree/compat-4
[7] https://lists.openvz.org/pipermail/criu/2016-June/029788.html

Dmitry Safonov (6):
  x86/vdso: unmap vdso blob on vvar mapping failure
  x86/vdso: replace calculate_addr in map_vdso() with addr
  x86/arch_prctl/vdso: add ARCH_MAP_VDSO_*
  x86/coredump: use pr_reg size, rather that TIF_IA32 flag
  x86/ptrace: down with test_thread_flag(TIF_IA32)
  x86/signal: add SA_{X32,IA32}_ABI sa_flags

 arch/x86/entry/vdso/vma.c         | 81 +++++++++++++++++++++++++++------------
 arch/x86/ia32/ia32_signal.c       |  2 +-
 arch/x86/include/asm/compat.h     |  8 ++--
 arch/x86/include/asm/fpu/signal.h |  6 +++
 arch/x86/include/asm/signal.h     |  4 ++
 arch/x86/include/asm/vdso.h       |  2 +
 arch/x86/include/uapi/asm/prctl.h |  6 +++
 arch/x86/kernel/process_64.c      | 25 ++++++++++++
 arch/x86/kernel/ptrace.c          |  2 +-
 arch/x86/kernel/signal.c          | 20 +++++-----
 arch/x86/kernel/signal_compat.c   | 34 ++++++++++++++--
 fs/binfmt_elf.c                   | 23 ++++-------
 kernel/signal.c                   |  7 ++++
 13 files changed, 162 insertions(+), 58 deletions(-)

-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
