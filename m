Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B7B416B0278
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 13:11:50 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u84so11075492pfj.6
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 10:11:50 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0117.outbound.protection.outlook.com. [104.47.1.117])
        by mx.google.com with ESMTPS id y77si8781763pff.233.2016.10.27.10.11.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 27 Oct 2016 10:11:49 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv3 0/8] powerpc/mm: refactor vDSO mapping code
Date: Thu, 27 Oct 2016 20:09:40 +0300
Message-ID: <20161027170948.8279-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andy Lutomirski <luto@amacapital.net>, Oleg Nesterov <oleg@redhat.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Laurent Dufour <ldufour@linux.vnet.ibm.com>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>

Changes since v1, v2:
- use vdso64_pages only under CONFIG_PPC64 (32-bit build fix)
- remove arch_vma_name helper as not needed anymore,
  simplify vdso_base pointer initializing in map_vdso()

Cleanup patches for vDSO on powerpc.
Originally, I wanted to add vDSO remapping on arm/aarch64 and
I decided to cleanup that part on powerpc.
I've add a hook for vm_ops for vDSO just like I did for x86,
which makes cross-arch arch_mremap hook no more needed.
Other changes - reduce exhaustive code duplication by
separating the common vdso code.

No visible to userspace changes expected.
Tested on qemu with buildroot rootfs.

Dmitry Safonov (8):
  powerpc/vdso: unify return paths in setup_additional_pages
  powerpc/vdso: remove unused params in vdso_do_func_patch{32,64}
  powerpc/vdso: separate common code in vdso_common
  powerpc/vdso: introduce init_vdso{32,64}_pagelist
  powerpc/vdso: split map_vdso from arch_setup_additional_pages
  powerpc/vdso: switch from legacy_special_mapping_vmops
  mm: kill arch_mremap
  powerpc/vdso: remove arch_vma_name

 arch/alpha/include/asm/Kbuild            |   1 -
 arch/arc/include/asm/Kbuild              |   1 -
 arch/arm/include/asm/Kbuild              |   1 -
 arch/arm64/include/asm/Kbuild            |   1 -
 arch/avr32/include/asm/Kbuild            |   1 -
 arch/blackfin/include/asm/Kbuild         |   1 -
 arch/c6x/include/asm/Kbuild              |   1 -
 arch/cris/include/asm/Kbuild             |   1 -
 arch/frv/include/asm/Kbuild              |   1 -
 arch/h8300/include/asm/Kbuild            |   1 -
 arch/hexagon/include/asm/Kbuild          |   1 -
 arch/ia64/include/asm/Kbuild             |   1 -
 arch/m32r/include/asm/Kbuild             |   1 -
 arch/m68k/include/asm/Kbuild             |   1 -
 arch/metag/include/asm/Kbuild            |   1 -
 arch/microblaze/include/asm/Kbuild       |   1 -
 arch/mips/include/asm/Kbuild             |   1 -
 arch/mn10300/include/asm/Kbuild          |   1 -
 arch/nios2/include/asm/Kbuild            |   1 -
 arch/openrisc/include/asm/Kbuild         |   1 -
 arch/parisc/include/asm/Kbuild           |   1 -
 arch/powerpc/include/asm/mm-arch-hooks.h |  28 --
 arch/powerpc/kernel/vdso.c               | 502 +++++--------------------------
 arch/powerpc/kernel/vdso_common.c        | 248 +++++++++++++++
 arch/s390/include/asm/Kbuild             |   1 -
 arch/score/include/asm/Kbuild            |   1 -
 arch/sh/include/asm/Kbuild               |   1 -
 arch/sparc/include/asm/Kbuild            |   1 -
 arch/tile/include/asm/Kbuild             |   1 -
 arch/um/include/asm/Kbuild               |   1 -
 arch/unicore32/include/asm/Kbuild        |   1 -
 arch/x86/include/asm/Kbuild              |   1 -
 arch/xtensa/include/asm/Kbuild           |   1 -
 include/asm-generic/mm-arch-hooks.h      |  16 -
 include/linux/mm-arch-hooks.h            |  25 --
 mm/mremap.c                              |   4 -
 36 files changed, 324 insertions(+), 529 deletions(-)
 delete mode 100644 arch/powerpc/include/asm/mm-arch-hooks.h
 create mode 100644 arch/powerpc/kernel/vdso_common.c
 delete mode 100644 include/asm-generic/mm-arch-hooks.h
 delete mode 100644 include/linux/mm-arch-hooks.h

-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
