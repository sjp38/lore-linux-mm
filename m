Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3DA346B0003
	for <linux-mm@kvack.org>; Sun, 18 Mar 2018 09:13:52 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id az5-v6so8636530plb.14
        for <linux-mm@kvack.org>; Sun, 18 Mar 2018 06:13:52 -0700 (PDT)
Received: from huawei.com ([45.249.212.35])
        by mx.google.com with ESMTPS id a2-v6si9997523plp.544.2018.03.18.06.13.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Mar 2018 06:13:50 -0700 (PDT)
From: Abbott Liu <liuwenliang@huawei.com>
Subject: [PATCH 1/7] 2 1-byte checks more safer for memory_is_poisoned_16
Date: Sun, 18 Mar 2018 20:53:36 +0800
Message-ID: <20180318125342.4278-2-liuwenliang@huawei.com>
In-Reply-To: <20180318125342.4278-1-liuwenliang@huawei.com>
References: <20180318125342.4278-1-liuwenliang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@armlinux.org.uk, aryabinin@virtuozzo.com, marc.zyngier@arm.com, kstewart@linuxfoundation.org, gregkh@linuxfoundation.org, f.fainelli@gmail.com, liuwenliang@huawei.com, akpm@linux-foundation.org, afzal.mohd.ma@gmail.com, alexander.levin@verizon.com
Cc: glider@google.com, dvyukov@google.com, christoffer.dall@linaro.org, linux@rasmusvillemoes.dk, mawilcox@microsoft.com, pombredanne@nexb.com, ard.biesheuvel@linaro.org, vladimir.murzin@arm.com, nicolas.pitre@linaro.org, tglx@linutronix.de, thgarnie@google.com, dhowells@redhat.com, keescook@chromium.org, arnd@arndb.de, geert@linux-m68k.org, tixy@linaro.org, mark.rutland@arm.com, james.morse@arm.com, zhichao.huang@linaro.org, jinb.park7@gmail.com, labbott@redhat.com, philip@cog.systems, grygorii.strashko@linaro.org, catalin.marinas@arm.com, opendmb@gmail.com, kirill.shutemov@linux.intel.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, kvmarm@lists.cs.columbia.edu, linux-mm@kvack.org

Because in some architecture(eg. arm) instruction set, non-aligned
access support is not very well, so 2 1-byte checks is more
safer than 1 2-byte check. The impact on performance is small
because 16-byte accesses are not too common.

Cc: Andrey Ryabinin <a.ryabinin@samsung.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Reviewed-by: Russell King - ARM Linux <linux@armlinux.org.uk>
Reviewed-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Acked-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Abbott Liu <liuwenliang@huawei.com>
---
 mm/kasan/kasan.c | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index e13d911..104839a 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -151,13 +151,20 @@ static __always_inline bool memory_is_poisoned_2_4_8(unsigned long addr,
 
 static __always_inline bool memory_is_poisoned_16(unsigned long addr)
 {
-	u16 *shadow_addr = (u16 *)kasan_mem_to_shadow((void *)addr);
-
-	/* Unaligned 16-bytes access maps into 3 shadow bytes. */
-	if (unlikely(!IS_ALIGNED(addr, KASAN_SHADOW_SCALE_SIZE)))
-		return *shadow_addr || memory_is_poisoned_1(addr + 15);
+	u8 *shadow_addr = (u8 *)kasan_mem_to_shadow((void *)addr);
 
-	return *shadow_addr;
+	if (unlikely(shadow_addr[0] || shadow_addr[1])) {
+		return true;
+	} else if (likely(IS_ALIGNED(addr, KASAN_SHADOW_SCALE_SIZE))) {
+		/*
+		 * If two shadow bytes covers 16-byte access, we don't
+		 * need to do anything more. Otherwise, test the last
+		 * shadow byte.
+		 */
+		return false;
+	} else {
+		return memory_is_poisoned_1(addr + 15);
+	}
 }
 
 static __always_inline unsigned long bytes_is_nonzero(const u8 *start,
-- 
2.9.0
