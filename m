Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id C41B56B0253
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 06:58:59 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 13so101691925itl.0
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 03:58:59 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0119.outbound.protection.outlook.com. [104.47.0.119])
        by mx.google.com with ESMTPS id g16si2525122otd.237.2016.06.29.03.58.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 29 Jun 2016 03:58:58 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv2 0/6] x86: 32-bit compatible C/R on x86_64
Date: Wed, 29 Jun 2016 13:57:30 +0300
Message-ID: <20160629105736.15017-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, linux-mm@kvack.org, mingo@redhat.com, luto@amacapital.net, gorcunov@openvz.org, xemul@virtuozzo.com, oleg@redhat.com, Dmitry Safonov <dsafonov@virtuozzo.com>

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
  x86/vdso: introduce do_map_vdso() and vdso_type enum
  x86/arch_prctl/vdso: add ARCH_MAP_VDSO_*
  x86/coredump: use pr_reg size, rather that TIF_IA32 flag
  x86/ptrace: down with test_thread_flag(TIF_IA32)
  x86/signal: add SA_{X32,IA32}_ABI sa_flags

 arch/x86/entry/vdso/vma.c         | 72 ++++++++++++++++++++++-----------------
 arch/x86/ia32/ia32_signal.c       |  2 +-
 arch/x86/include/asm/compat.h     |  8 ++---
 arch/x86/include/asm/fpu/signal.h |  6 ++++
 arch/x86/include/asm/signal.h     |  4 +++
 arch/x86/include/asm/vdso.h       |  4 +++
 arch/x86/include/uapi/asm/prctl.h |  6 ++++
 arch/x86/kernel/process_64.c      | 10 ++++++
 arch/x86/kernel/ptrace.c          |  2 +-
 arch/x86/kernel/signal.c          | 20 ++++++-----
 arch/x86/kernel/signal_compat.c   | 34 ++++++++++++++++--
 fs/binfmt_elf.c                   | 23 +++++--------
 kernel/signal.c                   |  7 ++++
 13 files changed, 133 insertions(+), 65 deletions(-)

-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
