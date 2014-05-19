Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id E14A16B0036
	for <linux-mm@kvack.org>; Mon, 19 May 2014 18:58:41 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kq14so6445525pab.38
        for <linux-mm@kvack.org>; Mon, 19 May 2014 15:58:41 -0700 (PDT)
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
        by mx.google.com with ESMTPS id ek4si10564211pbc.511.2014.05.19.15.58.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 May 2014 15:58:40 -0700 (PDT)
Received: by mail-pa0-f53.google.com with SMTP id kp14so6414133pab.12
        for <linux-mm@kvack.org>; Mon, 19 May 2014 15:58:40 -0700 (PDT)
From: Andy Lutomirski <luto@amacapital.net>
Subject: [PATCH 0/4] x86,mm: vdso fixes for an OOPS and /proc/PID/maps
Date: Mon, 19 May 2014 15:58:30 -0700
Message-Id: <cover.1400538962.git.luto@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Pavel Emelyanov <xemul@parallels.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>

[This applies to tip/x86/vdso.  Patch 1/4 is a resend.]

This fixes an OOPS on systems without an HPET and incomplete
information in /proc/PID/maps.

The latter is done by adding a new vm_ops callback to replace
arch_vma_name, which is inflexible and awkward to use correctly.

With this series applied, calling mremap on the vdso results in
sensible output in /proc/PID/maps and the vvar area shows up
correctly.  I don't want to guarantee that mremap on the vdso will
do anything sensible right now, but that's unchanged from before.
In fact, I suspect that mremapping the vdso on 32-bit tasks is
rather broken right now due to sigreturn.

In current kernels, mremapping the vdso blows away the name:
badc0de0000-badc0de2000 r-xp 00000000 00:00 0

Now it doesn't:
badc0de0000-badc0de1000 r-xp 00000000 00:00 0                            [vdso]

As a followup, it might pay to replace install_special_mapping with
a new install_vdso_mapping function that hardcodes the "[vdso]"
name, to separately fix all the other arch_vma_name users (maybe
just ARM?) and then kill arch_vma_name completely.

NB: This touches core mm code.  I'd appreciate some review by the mm
folks.

Andy Lutomirski (4):
  x86,vdso: Fix an OOPS accessing the hpet mapping w/o an hpet
  mm,fs: Add vm_ops->name as an alternative to arch_vma_name
  x86,mm: Improve _install_special_mapping and fix x86 vdso naming
  x86,mm: Replace arch_vma_name with vm_ops->name for vsyscalls

 arch/x86/include/asm/vdso.h  |  6 ++-
 arch/x86/mm/init_64.c        | 20 +++++-----
 arch/x86/vdso/vdso2c.h       |  5 ++-
 arch/x86/vdso/vdso32-setup.c |  7 ----
 arch/x86/vdso/vma.c          | 26 ++++++++-----
 fs/binfmt_elf.c              |  8 ++++
 fs/proc/task_mmu.c           |  6 +++
 include/linux/mm.h           | 10 ++++-
 include/linux/mm_types.h     |  6 +++
 mm/mmap.c                    | 89 +++++++++++++++++++++++++++++---------------
 10 files changed, 124 insertions(+), 59 deletions(-)

-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
