Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 695DD6B0038
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 21:35:44 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id u62so102133726pfk.1
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 18:35:44 -0800 (PST)
Received: from mail-pg0-x233.google.com (mail-pg0-x233.google.com. [2607:f8b0:400e:c05::233])
        by mx.google.com with ESMTPS id y6si9061653pgo.299.2017.03.02.18.35.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 18:35:43 -0800 (PST)
Received: by mail-pg0-x233.google.com with SMTP id s67so38586389pgb.3
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 18:35:43 -0800 (PST)
From: AKASHI Takahiro <takahiro.akashi@linaro.org>
Subject: [PATCH] memblock: fix memblock_next_valid_pfn()
Date: Fri,  3 Mar 2017 11:37:45 +0900
Message-Id: <20170303023745.9104-1-takahiro.akashi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: paul.burton@imgtec.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, AKASHI Takahiro <takahiro.akashi@linaro.org>

Obviously, we should not access memblock.memory.regions[right]
if 'right' is outside of [0..memblock.memory.cnt>.

Fixes: b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns where possible")
Signed-off-by: AKASHI Takahiro <takahiro.akashi@linaro.org>
---
 mm/memblock.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index b64b47803e52..696f06d17c4e 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1118,7 +1118,10 @@ unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn,
 		}
 	} while (left < right);
 
-	return min(PHYS_PFN(type->regions[right].base), max_pfn);
+	if (right == type->cnt)
+		return max_pfn;
+	else
+		return min(PHYS_PFN(type->regions[right].base), max_pfn);
 }
 
 /**
-- 
2.11.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
