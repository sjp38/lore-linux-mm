Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id A58DB6B0315
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 18:36:18 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id g74so246012214ioi.4
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 15:36:18 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id i127si2640115iti.95.2017.04.25.15.36.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 15:36:17 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id a188so12812441pfa.2
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 15:36:17 -0700 (PDT)
From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 3/3] arm64: Silence first allocation with CONFIG_ARM64_MODULE_PLTS=y
Date: Tue, 25 Apr 2017 15:33:32 -0700
Message-Id: <20170425223332.6999-7-f.fainelli@gmail.com>
In-Reply-To: <20170425223332.6999-1-f.fainelli@gmail.com>
References: <20170425223332.6999-1-f.fainelli@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Florian Fainelli <f.fainelli@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Chris Wilson <chris@chris-wilson.co.uk>, open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, angus@angusclark.org

When CONFIG_ARM64_MODULE_PLTS is enabled, the first allocation using the
module space fails, because the module is too big, and then the module
allocation is attempted from vmalloc space. Silence the first allocation
failure in that case by setting __GFP_NOWARN.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 arch/arm64/kernel/module.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/kernel/module.c b/arch/arm64/kernel/module.c
index 7f316982ce00..58bd5cfdd544 100644
--- a/arch/arm64/kernel/module.c
+++ b/arch/arm64/kernel/module.c
@@ -32,11 +32,16 @@
 
 void *module_alloc(unsigned long size)
 {
+	gfp_t gfp_mask = GFP_KERNEL;
 	void *p;
 
+#if IS_ENABLED(CONFIG_ARM64_MODULE_PLTS)
+	/* Silence the initial allocation */
+	gfp_mask |= __GFP_NOWARN;
+#endif
 	p = __vmalloc_node_range(size, MODULE_ALIGN, module_alloc_base,
 				module_alloc_base + MODULES_VSIZE,
-				GFP_KERNEL, PAGE_KERNEL_EXEC, 0,
+				gfp_mask, PAGE_KERNEL_EXEC, 0,
 				NUMA_NO_NODE, __builtin_return_address(0));
 
 	if (!p && IS_ENABLED(CONFIG_ARM64_MODULE_PLTS) &&
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
