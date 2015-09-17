Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id C0F4C6B0255
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 14:27:16 -0400 (EDT)
Received: by obbda8 with SMTP id da8so20155170obb.1
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 11:27:16 -0700 (PDT)
Received: from g1t6220.austin.hp.com (g1t6220.austin.hp.com. [15.73.96.84])
        by mx.google.com with ESMTPS id s11si2414076oif.120.2015.09.17.11.27.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Sep 2015 11:27:14 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v4 RESEND 1/11] x86/vdso32: Define PGTABLE_LEVELS to 32bit VDSO
Date: Thu, 17 Sep 2015 12:24:14 -0600
Message-Id: <1442514264-12475-2-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1442514264-12475-1-git-send-email-toshi.kani@hpe.com>
References: <1442514264-12475-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com, Toshi Kani <toshi.kani@hpe.com>

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

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
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
