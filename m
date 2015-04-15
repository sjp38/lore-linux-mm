Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6DF086B0038
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 10:17:07 -0400 (EDT)
Received: by wgso17 with SMTP id o17so48660640wgs.1
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 07:17:06 -0700 (PDT)
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com. [195.75.94.112])
        by mx.google.com with ESMTPS id dr2si10230561wid.108.2015.04.15.07.17.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Apr 2015 07:17:05 -0700 (PDT)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 15 Apr 2015 15:17:04 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 1C108219005E
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 15:16:47 +0100 (BST)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3FEH1pf10748366
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 14:17:01 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3FEH0Pg017945
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 08:17:01 -0600
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v5 0/3] Tracking user space vDSO remaping
Date: Wed, 15 Apr 2015 16:16:55 +0200
Message-Id: <cover.1429104776.git.ldufour@linux.vnet.ibm.com>
In-Reply-To: <20150414123853.a3e61b7fa95b6c634e0fcce0@linux-foundation.org>
References: <20150414123853.a3e61b7fa95b6c634e0fcce0@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Pavel Emelyanov <xemul@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Ingo Molnar <mingo@kernel.org>, linuxppc-dev@lists.ozlabs.org
Cc: cov@codeaurora.org, criu@openvz.org

CRIU is recreating the process memory layout by remapping the checkpointee
memory area on top of the current process (criu). This includes remapping
the vDSO to the place it has at checkpoint time.

However some architectures like powerpc are keeping a reference to the vDSO
base address to build the signal return stack frame by calling the vDSO
sigreturn service. So once the vDSO has been moved, this reference is no
more valid and the signal frame built later are not usable.

This patch serie is introducing a new mm hook framework, and a new
arch_remap hook which is called when mremap is done and the mm lock still
hold. The next patch is adding the vDSO remap and unmap tracking to the
powerpc architecture.

Changes in v5:
- Jumping over v4 which was too complex (PowerPC part) for the need.
- Introducing new mm hook framework as suggested by Andrew Morton.

Changes in v4:
- Reviewing the PowerPC part of the patch to handle partial unmap and remap
  of the vDSO.

Changes in v3:
- Fixed grammatical error in a comment of the second patch. 
  Thanks again, Ingo.

Changes in v2:
--------------
- Following the Ingo Molnar's advice, enabling the call to arch_remap through
  the __HAVE_ARCH_REMAP macro. This reduces considerably the first patch.

Laurent Dufour (3):
  mm: New mm hook framework
  mm: New arch_remap hook
  powerpc/mm: Tracking vDSO remap

 arch/alpha/include/asm/mm-arch-hooks.h      | 15 +++++++++++++++
 arch/arc/include/asm/mm-arch-hooks.h        | 15 +++++++++++++++
 arch/arm/include/asm/mm-arch-hooks.h        | 15 +++++++++++++++
 arch/arm64/include/asm/mm-arch-hooks.h      | 15 +++++++++++++++
 arch/avr32/include/asm/mm-arch-hooks.h      | 15 +++++++++++++++
 arch/blackfin/include/asm/mm-arch-hooks.h   | 15 +++++++++++++++
 arch/c6x/include/asm/mm-arch-hooks.h        | 15 +++++++++++++++
 arch/cris/include/asm/mm-arch-hooks.h       | 15 +++++++++++++++
 arch/frv/include/asm/mm-arch-hooks.h        | 15 +++++++++++++++
 arch/hexagon/include/asm/mm-arch-hooks.h    | 15 +++++++++++++++
 arch/ia64/include/asm/mm-arch-hooks.h       | 15 +++++++++++++++
 arch/m32r/include/asm/mm-arch-hooks.h       | 15 +++++++++++++++
 arch/m68k/include/asm/mm-arch-hooks.h       | 15 +++++++++++++++
 arch/metag/include/asm/mm-arch-hooks.h      | 15 +++++++++++++++
 arch/microblaze/include/asm/mm-arch-hooks.h | 15 +++++++++++++++
 arch/mips/include/asm/mm-arch-hooks.h       | 15 +++++++++++++++
 arch/mn10300/include/asm/mm-arch-hooks.h    | 15 +++++++++++++++
 arch/nios2/include/asm/mm-arch-hooks.h      | 15 +++++++++++++++
 arch/openrisc/include/asm/mm-arch-hooks.h   | 15 +++++++++++++++
 arch/parisc/include/asm/mm-arch-hooks.h     | 15 +++++++++++++++
 arch/powerpc/include/asm/mm-arch-hooks.h    | 28 ++++++++++++++++++++++++++++
 arch/powerpc/include/asm/mmu_context.h      | 23 ++++++++++++++++++++++-
 arch/s390/include/asm/mm-arch-hooks.h       | 15 +++++++++++++++
 arch/score/include/asm/mm-arch-hooks.h      | 15 +++++++++++++++
 arch/sh/include/asm/mm-arch-hooks.h         | 15 +++++++++++++++
 arch/sparc/include/asm/mm-arch-hooks.h      | 15 +++++++++++++++
 arch/tile/include/asm/mm-arch-hooks.h       | 15 +++++++++++++++
 arch/um/include/asm/mm-arch-hooks.h         | 15 +++++++++++++++
 arch/unicore32/include/asm/mm-arch-hooks.h  | 15 +++++++++++++++
 arch/x86/include/asm/mm-arch-hooks.h        | 15 +++++++++++++++
 arch/xtensa/include/asm/mm-arch-hooks.h     | 15 +++++++++++++++
 include/linux/mm-arch-hooks.h               | 25 +++++++++++++++++++++++++
 mm/mremap.c                                 | 17 +++++++++++------
 33 files changed, 521 insertions(+), 7 deletions(-)
 create mode 100644 arch/alpha/include/asm/mm-arch-hooks.h
 create mode 100644 arch/arc/include/asm/mm-arch-hooks.h
 create mode 100644 arch/arm/include/asm/mm-arch-hooks.h
 create mode 100644 arch/arm64/include/asm/mm-arch-hooks.h
 create mode 100644 arch/avr32/include/asm/mm-arch-hooks.h
 create mode 100644 arch/blackfin/include/asm/mm-arch-hooks.h
 create mode 100644 arch/c6x/include/asm/mm-arch-hooks.h
 create mode 100644 arch/cris/include/asm/mm-arch-hooks.h
 create mode 100644 arch/frv/include/asm/mm-arch-hooks.h
 create mode 100644 arch/hexagon/include/asm/mm-arch-hooks.h
 create mode 100644 arch/ia64/include/asm/mm-arch-hooks.h
 create mode 100644 arch/m32r/include/asm/mm-arch-hooks.h
 create mode 100644 arch/m68k/include/asm/mm-arch-hooks.h
 create mode 100644 arch/metag/include/asm/mm-arch-hooks.h
 create mode 100644 arch/microblaze/include/asm/mm-arch-hooks.h
 create mode 100644 arch/mips/include/asm/mm-arch-hooks.h
 create mode 100644 arch/mn10300/include/asm/mm-arch-hooks.h
 create mode 100644 arch/nios2/include/asm/mm-arch-hooks.h
 create mode 100644 arch/openrisc/include/asm/mm-arch-hooks.h
 create mode 100644 arch/parisc/include/asm/mm-arch-hooks.h
 create mode 100644 arch/powerpc/include/asm/mm-arch-hooks.h
 create mode 100644 arch/s390/include/asm/mm-arch-hooks.h
 create mode 100644 arch/score/include/asm/mm-arch-hooks.h
 create mode 100644 arch/sh/include/asm/mm-arch-hooks.h
 create mode 100644 arch/sparc/include/asm/mm-arch-hooks.h
 create mode 100644 arch/tile/include/asm/mm-arch-hooks.h
 create mode 100644 arch/um/include/asm/mm-arch-hooks.h
 create mode 100644 arch/unicore32/include/asm/mm-arch-hooks.h
 create mode 100644 arch/x86/include/asm/mm-arch-hooks.h
 create mode 100644 arch/xtensa/include/asm/mm-arch-hooks.h
 create mode 100644 include/linux/mm-arch-hooks.h

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
