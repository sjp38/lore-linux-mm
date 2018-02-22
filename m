Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8260F6B02B4
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 07:15:26 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id o23so3485281wrc.9
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 04:15:26 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.22])
        by mx.google.com with ESMTPS id a128si154988wmf.267.2018.02.22.04.15.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 04:15:25 -0800 (PST)
From: =?UTF-8?q?Jonathan=20Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>
Subject: [PATCH 0/5] PPC32/ioremap: Use memblock API to check for RAM
Date: Thu, 22 Feb 2018 13:15:11 +0100
Message-Id: <20180222121516.23415-1-j.neuschaefer@gmx.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: linux-kernel@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, Joel Stanley <joel@jms.id.au>, Christophe LEROY <christophe.leroy@c-s.fr>, =?UTF-8?q?Jonathan=20Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>

This patchset solves the same problem as my previous one[1] but follows
a rather different approach. Instead of implementing DISCONTIGMEM for
PowerPC32, I simply switched the "is this RAM" check in __ioremap_caller
to the existing page_is_ram function, and unified page_is_ram to search
memblock.memory on PPC64 and PPC32.

The intended result is, as before, that my Wii can allocate the MMIO
range of its GPIO controller, which was previously not possible, because
the reserved memory hack (__allow_ioremap_reserved) didn't affect the
API in kernel/resource.c.

Thanks to Christophe Leroy for reviewing the previous patchset.

[1]: https://www.spinics.net/lists/kernel/msg2726786.html

Jonathan NeuschA?fer (5):
  powerpc: mm: Simplify page_is_ram by using memblock_is_memory
  powerpc: mm: Use memblock API for PPC32 page_is_ram
  powerpc/mm/32: Use page_is_ram to check for RAM
  powerpc: wii: Don't rely on the reserved memory hack
  powerpc/mm/32: Remove the reserved memory hack

 arch/powerpc/mm/init_32.c                |  5 -----
 arch/powerpc/mm/mem.c                    | 12 +-----------
 arch/powerpc/mm/mmu_decl.h               |  1 -
 arch/powerpc/mm/pgtable_32.c             |  4 +---
 arch/powerpc/platforms/embedded6xx/wii.c | 14 +-------------
 5 files changed, 3 insertions(+), 33 deletions(-)

-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
