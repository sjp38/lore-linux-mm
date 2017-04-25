Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4CC1A6B02FA
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 18:36:11 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id r16so206875130ioi.7
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 15:36:11 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id i4si4536100itc.71.2017.04.25.15.36.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 15:36:10 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id v1so6614620pgv.3
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 15:36:10 -0700 (PDT)
From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 2/2] mm: Silence vmap() allocation failures based on caller gfp_flags
Date: Tue, 25 Apr 2017 15:33:31 -0700
Message-Id: <20170425223332.6999-6-f.fainelli@gmail.com>
In-Reply-To: <20170425223332.6999-1-f.fainelli@gmail.com>
References: <20170425223332.6999-1-f.fainelli@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Florian Fainelli <f.fainelli@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Chris Wilson <chris@chris-wilson.co.uk>, open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, angus@angusclark.org

If the caller has set __GFP_NOWARN don't print the following message:
vmap allocation for size 15736832 failed: use vmalloc=<size> to increase
size.

This can happen with the ARM/Linux module loader built with
CONFIG_ARM_MODULE_PLTS=y which does a first attempt at loading a large
module from module space, then falls back to vmalloc space.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 mm/vmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 0b057628a7ba..5a788eb58741 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -521,7 +521,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 		}
 	}
 
-	if (printk_ratelimit())
+	if (printk_ratelimit() && !(gfp_mask & __GFP_NOWARN))
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
