Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 77C976B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 17:57:22 -0400 (EDT)
Received: by igui7 with SMTP id i7so22421985igu.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 14:57:22 -0700 (PDT)
Received: from g2t2354.austin.hp.com (g2t2354.austin.hp.com. [15.217.128.53])
        by mx.google.com with ESMTPS id i3si10808733ioi.144.2015.08.25.14.57.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 14:57:20 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v4 1/11] x86/vdso32: Define PGTABLE_LEVELS to 32bit VDSO
Date: Tue, 25 Aug 2015 15:55:01 -0600
Message-Id: <1440539711-2985-2-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1440539711-2985-1-git-send-email-toshi.kani@hp.com>
References: <1440539711-2985-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hp.com, Toshi Kani <toshi.kani@hp.com>

In case of CONFIG_X86_64, vdso32/vclock_gettime.c fakes a 32-bit
non-PAE kernel configuration by re-defining it to CONFIG_X86_32.
However, it does not re-define CONFIG_PGTABLE_LEVELS leaving it
as 4 levels.

This mismatch leads <asm/pgtable_type.h> to NOT include <asm-generic/
pgtable-nopud.h> and <asm-generic/pgtable-nopmd.h>, which will cause
compile errors when a later patch enhances <asm/pgtable_type.h> to
use PUD_SHIFT and PMD_SHIFT.  These -nopud & -nopmd headers define
these SHIFTs for the 32-bit non-PAE kernel.

Fix it by re-defining CONFIG_PGTABLE_LEVELS to 2 levels.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
---
 arch/x86/entry/vdso/vdso32/vclock_gettime.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/x86/entry/vdso/vdso32/vclock_gettime.c b/arch/x86/entry/vdso/vdso32/vclock_gettime.c
index 175cc72..87a86e0 100644
--- a/arch/x86/entry/vdso/vdso32/vclock_gettime.c
+++ b/arch/x86/entry/vdso/vdso32/vclock_gettime.c
@@ -14,11 +14,13 @@
  */
 #undef CONFIG_64BIT
 #undef CONFIG_X86_64
+#undef CONFIG_PGTABLE_LEVELS
 #undef CONFIG_ILLEGAL_POINTER_VALUE
 #undef CONFIG_SPARSEMEM_VMEMMAP
 #undef CONFIG_NR_CPUS
 
 #define CONFIG_X86_32 1
+#define CONFIG_PGTABLE_LEVELS 2
 #define CONFIG_PAGE_OFFSET 0
 #define CONFIG_ILLEGAL_POINTER_VALUE 0
 #define CONFIG_NR_CPUS 1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
