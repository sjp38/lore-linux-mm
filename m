Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8D5BB9003C7
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 17:41:53 -0400 (EDT)
Received: by qkbm65 with SMTP id m65so31263607qkb.2
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 14:41:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 49si14226917qgp.63.2015.08.06.14.41.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Aug 2015 14:41:52 -0700 (PDT)
From: Mark Salter <msalter@redhat.com>
Subject: [PATCH V2 0/3] mm: Add generic copy from early unmapped RAM
Date: Thu,  6 Aug 2015 17:41:36 -0400
Message-Id: <1438897299-2266-1-git-send-email-msalter@redhat.com>
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

Changes from V1:

  * Change cover letter subject to highlight the added generic code

  * Add patch for x86 to use common copy_from_early_mem()

Mark Salter (3):
  mm: add utility for early copy from unmapped ram
  arm64: support initrd outside kernel linear map
  x86: use generic early mem copy

 arch/arm64/kernel/setup.c           | 55 +++++++++++++++++++++++++++++++++++++
 arch/x86/kernel/setup.c             | 21 +-------------
 include/asm-generic/early_ioremap.h |  6 ++++
 mm/early_ioremap.c                  | 22 +++++++++++++++
 4 files changed, 84 insertions(+), 20 deletions(-)

-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
