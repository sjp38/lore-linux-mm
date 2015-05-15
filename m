Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9EA006B006C
	for <linux-mm@kvack.org>; Fri, 15 May 2015 09:59:20 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so13572132pac.2
        for <linux-mm@kvack.org>; Fri, 15 May 2015 06:59:20 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id tg11si2759908pac.21.2015.05.15.06.59.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 15 May 2015 06:59:19 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NOE00A4J9IQF380@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 15 May 2015 14:59:14 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v2 1/5] kasan, x86: move KASAN_SHADOW_OFFSET to the arch Kconfig
Date: Fri, 15 May 2015 16:59:00 +0300
Message-id: <1431698344-28054-2-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, David Keitel <dkeitel@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Andrey Ryabinin <a.ryabinin@samsung.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "maintainer:X86 ARCHITECTURE..." <x86@kernel.org>

KASAN_SHADOW_OFFSET is purely arch specific setting,
so it should be in arch's Kconfig file. This simplifies
porting KASan to other architectures and maintenance of it.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 arch/x86/Kconfig  | 4 ++++
 lib/Kconfig.kasan | 4 ----
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index c92fdcc..b530967 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -251,6 +251,10 @@ config ARCH_SUPPORTS_OPTIMIZED_INLINING
 config ARCH_SUPPORTS_DEBUG_PAGEALLOC
 	def_bool y
 
+config KASAN_SHADOW_OFFSET
+	hex
+	default 0xdffffc0000000000
+
 config HAVE_INTEL_TXT
 	def_bool y
 	depends on INTEL_IOMMU && ACPI
diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index 777eda7..39f24d6 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -18,10 +18,6 @@ config KASAN
 	  For better error detection enable CONFIG_STACKTRACE,
 	  and add slub_debug=U to boot cmdline.
 
-config KASAN_SHADOW_OFFSET
-	hex
-	default 0xdffffc0000000000 if X86_64
-
 choice
 	prompt "Instrumentation type"
 	depends on KASAN
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
