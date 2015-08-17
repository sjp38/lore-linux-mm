Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2A1626B0253
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 13:01:19 -0400 (EDT)
Received: by qgj62 with SMTP id 62so98278957qgj.2
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 10:01:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y15si26096851qky.100.2015.08.17.10.01.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Aug 2015 10:01:18 -0700 (PDT)
From: Mark Salter <msalter@redhat.com>
Subject: [PATCH V4 0/3] mm: Add generic copy from early unmapped RAM
Date: Mon, 17 Aug 2015 13:01:04 -0400
Message-Id: <1439830867-14935-1-git-send-email-msalter@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, x86@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Mark Rutland <mark.rutland@arm.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Mark Salter <msalter@redhat.com>

When booting an arm64 kernel w/initrd using UEFI/grub, use of mem= will likely
cut off part or all of the initrd. This leaves it outside the kernel linear
map which leads to failure when unpacking. The x86 code has a similar need to
relocate an initrd outside of mapped memory in some cases.

The current x86 code uses early_memremap() to copy the original initrd from
unmapped to mapped RAM. This patchset creates a generic copy_from_early_mem()
utility based on that x86 code and has arm64 and x86 share it in their
respective initrd relocation code.

Changes from V3:

  * Fixed arm64 build error with !CONFIG_BLK_DEV_INITRD case

  * Fixed nonsensical comment in arm64 relocate_initrd()

Changes from V2:

  * Fixed sparse warning in copy_from_early_mem()

  * Removed unneeded MAX_MAP_CHUNK from x86 setup.c

  * Moved #ifdef outside arm64 relocate_initrd() definition.
  
Changes from V1:

  * Change cover letter subject to highlight the added generic code

  * Add patch for x86 to use common copy_from_early_mem()


Mark Salter (3):
  mm: add utility for early copy from unmapped ram
  arm64: support initrd outside kernel linear map
  x86: use generic early mem copy

 arch/arm64/kernel/setup.c           | 62 +++++++++++++++++++++++++++++++++++++
 arch/x86/kernel/setup.c             | 22 +------------
 include/asm-generic/early_ioremap.h |  6 ++++
 mm/early_ioremap.c                  | 22 +++++++++++++
 4 files changed, 91 insertions(+), 21 deletions(-)

-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
