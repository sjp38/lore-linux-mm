Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 092D96B0257
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 12:42:36 -0400 (EDT)
Received: by igbij6 with SMTP id ij6so21020346igb.1
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 09:42:35 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id bq3si7300460pdb.3.2015.07.24.09.42.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Jul 2015 09:42:34 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NS0007VN3QUA350@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 24 Jul 2015 17:42:30 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v4 3/7] arm64: introduce VA_START macro - the first kernel
 virtual address.
Date: Fri, 24 Jul 2015 19:41:55 +0300
Message-id: <1437756119-12817-4-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1437756119-12817-1-git-send-email-a.ryabinin@samsung.com>
References: <1437756119-12817-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org
Cc: Arnd Bergmann <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexey Klimov <klimov.linux@gmail.com>, Andrey Ryabinin <a.ryabinin@samsung.com>

In order to not use lengthy (UL(0xffffffffffffffff) << VA_BITS) everywhere,
replace it with VA_START.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
---
 arch/arm64/include/asm/memory.h  | 2 ++
 arch/arm64/include/asm/pgtable.h | 2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
index f800d45..288c19d 100644
--- a/arch/arm64/include/asm/memory.h
+++ b/arch/arm64/include/asm/memory.h
@@ -42,12 +42,14 @@
  * PAGE_OFFSET - the virtual address of the start of the kernel image (top
  *		 (VA_BITS - 1))
  * VA_BITS - the maximum number of bits for virtual addresses.
+ * VA_START - the first kernel virtual address.
  * TASK_SIZE - the maximum size of a user space task.
  * TASK_UNMAPPED_BASE - the lower boundary of the mmap VM area.
  * The module space lives between the addresses given by TASK_SIZE
  * and PAGE_OFFSET - it must be within 128MB of the kernel text.
  */
 #define VA_BITS			(CONFIG_ARM64_VA_BITS)
+#define VA_START		(UL(0xffffffffffffffff) << VA_BITS)
 #define PAGE_OFFSET		(UL(0xffffffffffffffff) << (VA_BITS - 1))
 #define MODULES_END		(PAGE_OFFSET)
 #define MODULES_VADDR		(MODULES_END - SZ_64M)
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index 56283f8..a1f9f61 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -40,7 +40,7 @@
  *	fixed mappings and modules
  */
 #define VMEMMAP_SIZE		ALIGN((1UL << (VA_BITS - PAGE_SHIFT)) * sizeof(struct page), PUD_SIZE)
-#define VMALLOC_START		(UL(0xffffffffffffffff) << VA_BITS)
+#define VMALLOC_START		(VA_START)
 #define VMALLOC_END		(PAGE_OFFSET - PUD_SIZE - VMEMMAP_SIZE - SZ_64K)
 
 #define vmemmap			((struct page *)(VMALLOC_END + SZ_64K))
-- 
2.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
