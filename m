Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id BF3B44403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 00:57:31 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id 65so33123176pfd.2
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 21:57:31 -0800 (PST)
Received: from mail-pf0-x232.google.com (mail-pf0-x232.google.com. [2607:f8b0:400e:c00::232])
        by mx.google.com with ESMTPS id v4si14320448pfi.237.2016.02.03.21.57.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 21:57:31 -0800 (PST)
Received: by mail-pf0-x232.google.com with SMTP id w123so33239416pfb.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 21:57:31 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 1/5] mm/vmalloc: query dynamic DEBUG_PAGEALLOC setting
Date: Thu,  4 Feb 2016 14:56:22 +0900
Message-Id: <1454565386-10489-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1454565386-10489-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1454565386-10489-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Takashi Iwai <tiwai@suse.com>, Chris Metcalf <cmetcalf@ezchip.com>, Christoph Lameter <cl@linux.com>, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

We can disable debug_pagealloc processing even if the code is complied
with CONFIG_DEBUG_PAGEALLOC. This patch changes the code to query
whether it is enabled or not in runtime.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/vmalloc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index fb42a5b..e0e51bd 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -543,10 +543,10 @@ static void vmap_debug_free_range(unsigned long start, unsigned long end)
 	 * debugging doesn't do a broadcast TLB flush so it is a lot
 	 * faster).
 	 */
-#ifdef CONFIG_DEBUG_PAGEALLOC
-	vunmap_page_range(start, end);
-	flush_tlb_kernel_range(start, end);
-#endif
+	if (debug_pagealloc_enabled()) {
+		vunmap_page_range(start, end);
+		flush_tlb_kernel_range(start, end);
+	}
 }
 
 /*
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
