Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 76B986B02EE
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 14:19:13 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id a19so9240275qkg.22
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:19:13 -0700 (PDT)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id z41si3680311qtz.67.2017.04.27.11.19.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 11:19:11 -0700 (PDT)
Received: by mail-qk0-x243.google.com with SMTP id o85so5871387qkh.0
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:19:11 -0700 (PDT)
From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH v3 1/3] mm: Silence vmap() allocation failures based on caller gfp_flags
Date: Thu, 27 Apr 2017 11:19:00 -0700
Message-Id: <20170427181902.28829-2-f.fainelli@gmail.com>
In-Reply-To: <20170427181902.28829-1-f.fainelli@gmail.com>
References: <20170427181902.28829-1-f.fainelli@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Florian Fainelli <f.fainelli@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Chris Wilson <chris@chris-wilson.co.uk>, open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, angus@angusclark.org

If the caller has set __GFP_NOWARN don't print the following message:
vmap allocation for size 15736832 failed: use vmalloc=<size> to increase
size.

This can happen with the ARM/Linux or ARM64/Linux module loader built
with CONFIG_ARM{,64}_MODULE_PLTS=y which does a first attempt at loading
a large module from module space, then falls back to vmalloc space.

Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 mm/vmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 0b057628a7ba..b74f1d01ef76 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -521,7 +521,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 		}
 	}
 
-	if (printk_ratelimit())
+	if (!(gfp_mask & __GFP_NOWARN) && printk_ratelimit())
 		pr_warn("vmap allocation for size %lu failed: use vmalloc=<size> to increase size\n",
 			size);
 	kfree(va);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
