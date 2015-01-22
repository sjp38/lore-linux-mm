Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id C64966B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 02:18:08 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fb1so23866335pad.10
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 23:18:08 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id pr1si2645859pbc.194.2015.01.21.23.18.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 21 Jan 2015 23:18:08 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NIK00H7YHSZ4M50@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 22 Jan 2015 07:22:11 +0000 (GMT)
From: Sergey Dyasly <s.dyasly@samsung.com>
Subject: [PATCH] ARM: use default ioremap alignment for SMP or LPAE
Date: Thu, 22 Jan 2015 10:17:55 +0300
Message-id: <1421911075-8814-1-git-send-email-s.dyasly@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Dyasly <s.dyasly@samsung.com>, Russell King <linux@arm.linux.org.uk>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Nicolas Pitre <nicolas.pitre@linaro.org>, James Bottomley <JBottomley@parallels.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd.bergmann@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Safonov <d.safonov@partner.samsung.com>

16MB alignment for ioremap mappings was added by commit a069c896d0d6 ("[ARM]
3705/1: add supersection support to ioremap()") in order to support supersection
mappings. But __arm_ioremap_pfn_caller uses section and supersection mappings
only in !SMP && !LPAE case. There is no need for such big alignment if either
SMP or LPAE is enabled.

After this change, ioremap will use default maximum alignment of 128 pages.

Cc: Russell King <linux@arm.linux.org.uk>
Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: James Bottomley <JBottomley@parallels.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Arnd Bergmann <arnd.bergmann@linaro.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dmitry Safonov <d.safonov@partner.samsung.com>
Link: https://lkml.kernel.org/g/1419328813-2211-1-git-send-email-d.safonov@partner.samsung.com
Signed-off-by: Sergey Dyasly <s.dyasly@samsung.com>
---
 arch/arm/include/asm/memory.h |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm/include/asm/memory.h b/arch/arm/include/asm/memory.h
index 184def0..c3ef139 100644
--- a/arch/arm/include/asm/memory.h
+++ b/arch/arm/include/asm/memory.h
@@ -78,10 +78,12 @@
  */
 #define XIP_VIRT_ADDR(physaddr)  (MODULES_VADDR + ((physaddr) & 0x000fffff))
 
+#if !defined(CONFIG_SMP) && !defined(CONFIG_ARM_LPAE)
 /*
  * Allow 16MB-aligned ioremap pages
  */
 #define IOREMAP_MAX_ORDER	24
+#endif
 
 #else /* CONFIG_MMU */
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
