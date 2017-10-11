Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E423E6B026B
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 04:24:49 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id a192so2818771pge.5
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 01:24:49 -0700 (PDT)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id x65si4418017pfk.375.2017.10.11.01.24.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Oct 2017 01:24:48 -0700 (PDT)
From: Abbott Liu <liuwenliang@huawei.com>
Subject: [PATCH 06/11] change memory_is_poisoned_16 for aligned error
Date: Wed, 11 Oct 2017 16:22:22 +0800
Message-ID: <20171011082227.20546-7-liuwenliang@huawei.com>
In-Reply-To: <20171011082227.20546-1-liuwenliang@huawei.com>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@armlinux.org.uk, aryabinin@virtuozzo.com, liuwenliang@huawei.com, afzal.mohd.ma@gmail.com, f.fainelli@gmail.com, labbott@redhat.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, cdall@linaro.org, marc.zyngier@arm.com, catalin.marinas@arm.com, akpm@linux-foundation.org, mawilcox@microsoft.com, tglx@linutronix.de, thgarnie@google.com, keescook@chromium.org, arnd@arndb.de, vladimir.murzin@arm.com, tixy@linaro.org, ard.biesheuvel@linaro.org, robin.murphy@arm.com, mingo@kernel.org, grygorii.strashko@linaro.org
Cc: glider@google.com, dvyukov@google.com, opendmb@gmail.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, jiazhenghua@huawei.com, dylix.dailei@huawei.com, zengweilin@huawei.com, heshaoliang@huawei.com

 Because arm instruction set don't support access the address which is
 not aligned, so must change memory_is_poisoned_16 for arm.

Cc:  Andrey Ryabinin <a.ryabinin@samsung.com>
Signed-off-by: Abbott Liu <liuwenliang@huawei.com>
---
 mm/kasan/kasan.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 12749da..e0e152b 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -149,6 +149,25 @@ static __always_inline bool memory_is_poisoned_2_4_8(unsigned long addr,
 	return memory_is_poisoned_1(addr + size - 1);
 }
 
+#ifdef CONFIG_ARM
+static __always_inline bool memory_is_poisoned_16(unsigned long addr)
+{
+	u8 *shadow_addr = (u8 *)kasan_mem_to_shadow((void *)addr);
+
+	if (unlikely(shadow_addr[0] || shadow_addr[1])) return true;
+	else {
+		/*
+		 * If two shadow bytes covers 16-byte access, we don't
+		 * need to do anything more. Otherwise, test the last
+		 * shadow byte.
+		 */
+		if (likely(IS_ALIGNED(addr, KASAN_SHADOW_SCALE_SIZE)))
+			return false;
+		return memory_is_poisoned_1(addr + 15);
+	}
+}
+
+#else
 static __always_inline bool memory_is_poisoned_16(unsigned long addr)
 {
 	u16 *shadow_addr = (u16 *)kasan_mem_to_shadow((void *)addr);
@@ -159,6 +178,7 @@ static __always_inline bool memory_is_poisoned_16(unsigned long addr)
 
 	return *shadow_addr;
 }
+#endif
 
 static __always_inline unsigned long bytes_is_nonzero(const u8 *start,
 					size_t size)
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
