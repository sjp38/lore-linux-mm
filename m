Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 95D4A6B02F2
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 18:35:50 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id p80so245494252iop.16
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 15:35:50 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id n81si1259268ioe.149.2017.04.25.15.35.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 15:35:49 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id a188so12811466pfa.2
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 15:35:49 -0700 (PDT)
From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 1/2] ARM: Silence non PLT allocation with CONFIG_ARM_MODULE_PLTS=y
Date: Tue, 25 Apr 2017 15:33:28 -0700
Message-Id: <20170425223332.6999-3-f.fainelli@gmail.com>
In-Reply-To: <20170425223332.6999-1-f.fainelli@gmail.com>
References: <20170425223332.6999-1-f.fainelli@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Florian Fainelli <f.fainelli@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Chris Wilson <chris@chris-wilson.co.uk>, open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, angus@angusclark.org

When CONFIG_ARM_MODULE_PLTS is enabled, the first allocation using the
module space fails, because the module is too big, and then the module
allocation is attempted from vmalloc space. Silence the first allocation
failure in that case, since that scares people out.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 arch/arm/kernel/module.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/arch/arm/kernel/module.c b/arch/arm/kernel/module.c
index 80254b47dc34..503d1a39464a 100644
--- a/arch/arm/kernel/module.c
+++ b/arch/arm/kernel/module.c
@@ -40,8 +40,15 @@
 #ifdef CONFIG_MMU
 void *module_alloc(unsigned long size)
 {
-	void *p = __vmalloc_node_range(size, 1, MODULES_VADDR, MODULES_END,
-				GFP_KERNEL, PAGE_KERNEL_EXEC, 0, NUMA_NO_NODE,
+	gfp_t gfp_mask = GFP_KERNEL;
+	void *p;
+
+#if IS_ENABLED(CONFIG_ARM_MODULE_PLTS)
+	/* Silence the initial allocation */
+	gfp_mask |= __GFP_NOWARN;
+#endif
+	p = __vmalloc_node_range(size, 1, MODULES_VADDR, MODULES_END,
+				gfp_mask, PAGE_KERNEL_EXEC, 0, NUMA_NO_NODE,
 				__builtin_return_address(0));
 	if (!IS_ENABLED(CONFIG_ARM_MODULE_PLTS) || p)
 		return p;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
