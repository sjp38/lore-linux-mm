Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1B38D6B0038
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 18:22:58 -0400 (EDT)
Received: by lbbpu9 with SMTP id pu9so75727601lbb.3
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 15:22:57 -0700 (PDT)
Received: from mail-lb0-x243.google.com (mail-lb0-x243.google.com. [2a00:1450:4010:c04::243])
        by mx.google.com with ESMTPS id xv1si14971261lbb.17.2015.08.10.15.22.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Aug 2015 15:22:57 -0700 (PDT)
Received: by lbcue2 with SMTP id ue2so1330646lbc.0
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 15:22:56 -0700 (PDT)
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Subject: [PATCH v5 1/6] x86/kasan: define KASAN_SHADOW_OFFSET per architecture
Date: Tue, 11 Aug 2015 05:18:14 +0300
Message-Id: <1439259499-13913-2-git-send-email-ryabinin.a.a@gmail.com>
In-Reply-To: <1439259499-13913-1-git-send-email-ryabinin.a.a@gmail.com>
References: <1439259499-13913-1-git-send-email-ryabinin.a.a@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexey Klimov <klimov.linux@gmail.com>, Yury <yury.norov@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org

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
