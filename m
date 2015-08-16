Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 084E96B0253
	for <linux-mm@kvack.org>; Sun, 16 Aug 2015 16:49:37 -0400 (EDT)
Received: by qgj62 with SMTP id 62so82743788qgj.2
        for <linux-mm@kvack.org>; Sun, 16 Aug 2015 13:49:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o81si13792743qkl.91.2015.08.16.13.49.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Aug 2015 13:49:36 -0700 (PDT)
From: Mark Salter <msalter@redhat.com>
Subject: [PATCH V3 0/3] mm: Add generic copy from early unmapped RAM
Date: Sun, 16 Aug 2015 16:49:25 -0400
Message-Id: <1439758168-29427-1-git-send-email-msalter@redhat.com>
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

 arch/arm64/kernel/setup.c           | 59 +++++++++++++++++++++++++++++++++++++
 arch/x86/kernel/setup.c             | 22 +-------------
 include/asm-generic/early_ioremap.h |  6 ++++
 mm/early_ioremap.c                  | 22 ++++++++++++++
 4 files changed, 88 insertions(+), 21 deletions(-)

-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
