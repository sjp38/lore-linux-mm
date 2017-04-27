Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id CE1466B02EE
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 13:39:23 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id u140so14348594ywf.1
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 10:39:23 -0700 (PDT)
Received: from mail-qk0-x241.google.com (mail-qk0-x241.google.com. [2607:f8b0:400d:c09::241])
        by mx.google.com with ESMTPS id q66si1364990ywf.1.2017.04.27.10.39.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 10:39:23 -0700 (PDT)
Received: by mail-qk0-x241.google.com with SMTP id y63so5727907qkd.3
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 10:39:23 -0700 (PDT)
From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH v2 1/3] mm: Silence vmap() allocation failures based on caller gfp_flags
Date: Thu, 27 Apr 2017 10:38:58 -0700
Message-Id: <20170427173900.2538-2-f.fainelli@gmail.com>
In-Reply-To: <20170427173900.2538-1-f.fainelli@gmail.com>
References: <20170427173900.2538-1-f.fainelli@gmail.com>
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

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 mm/vmalloc.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 0b057628a7ba..d8a851634674 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -521,9 +521,13 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 		}
 	}
 
+	if (gfp_mask & __GFP_NOWARN)
+		goto out;
+
 	if (printk_ratelimit())
 		pr_warn("vmap allocation for size %lu failed: use vmalloc=<size> to increase size\n",
 			size);
+out:
 	kfree(va);
 	return ERR_PTR(-EBUSY);
 }
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
