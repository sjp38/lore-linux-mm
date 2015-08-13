Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id F04D26B0038
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 01:37:45 -0400 (EDT)
Received: by lahi9 with SMTP id i9so20188779lah.2
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 22:37:45 -0700 (PDT)
Received: from mail-lb0-x22f.google.com (mail-lb0-x22f.google.com. [2a00:1450:4010:c04::22f])
        by mx.google.com with ESMTPS id kt9si1170651lac.26.2015.08.12.22.37.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Aug 2015 22:37:43 -0700 (PDT)
Received: by lbcbn3 with SMTP id bn3so20928425lbc.2
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 22:37:43 -0700 (PDT)
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Subject: [PATCH v6 1/2] x86/kasan: define KASAN_SHADOW_OFFSET per architecture
Date: Thu, 13 Aug 2015 08:37:23 +0300
Message-Id: <1439444244-26057-2-git-send-email-ryabinin.a.a@gmail.com>
In-Reply-To: <1439444244-26057-1-git-send-email-ryabinin.a.a@gmail.com>
References: <1439444244-26057-1-git-send-email-ryabinin.a.a@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Arnd Bergmann <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexey Klimov <klimov.linux@gmail.com>, Yury <yury.norov@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Current definition of  KASAN_SHADOW_OFFSET in include/linux/kasan.h
will not work for upcomming arm64, so move it to the arch header.

Signed-off-by: Andrey Ryabinin <ryabinin.a.a@gmail.com>
---
 arch/x86/include/asm/kasan.h | 3 +++
 include/linux/kasan.h        | 1 -
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/kasan.h b/arch/x86/include/asm/kasan.h
index 74a2a8d..1410b56 100644
--- a/arch/x86/include/asm/kasan.h
+++ b/arch/x86/include/asm/kasan.h
@@ -1,6 +1,9 @@
 #ifndef _ASM_X86_KASAN_H
 #define _ASM_X86_KASAN_H
 
+#include <linux/const.h>
+#define KASAN_SHADOW_OFFSET _AC(CONFIG_KASAN_SHADOW_OFFSET, UL)
+
 /*
  * Compiler uses shadow offset assuming that addresses start
  * from 0. Kernel addresses don't start from 0, so shadow
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 5486d77..6fb1c7d 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -10,7 +10,6 @@ struct vm_struct;
 #ifdef CONFIG_KASAN
 
 #define KASAN_SHADOW_SCALE_SHIFT 3
-#define KASAN_SHADOW_OFFSET _AC(CONFIG_KASAN_SHADOW_OFFSET, UL)
 
 #include <asm/kasan.h>
 #include <linux/sched.h>
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
