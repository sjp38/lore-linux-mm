Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B2E5C6B0410
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 08:04:08 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c4so141757450pfb.7
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 05:04:08 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id x27si8184164pff.112.2016.11.18.05.04.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 05:04:07 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 01/10] mm: remove free_unmap_vmap_area_noflush
Date: Fri, 18 Nov 2016 14:03:47 +0100
Message-Id: <1479474236-4139-2-git-send-email-hch@lst.de>
In-Reply-To: <1479474236-4139-1-git-send-email-hch@lst.de>
References: <1479474236-4139-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: aryabinin@virtuozzo.com, joelaf@google.com, jszhang@marvell.com, chris@chris-wilson.co.uk, joaodias@google.com, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

Just inline it into the only caller.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Tested-by: Jisheng Zhang <jszhang@marvell.com>
---
 mm/vmalloc.c | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index f2481cb..45de736 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -711,22 +711,13 @@ static void free_vmap_area_noflush(struct vmap_area *va)
 }
 
 /*
- * Free and unmap a vmap area, caller ensuring flush_cache_vunmap had been
- * called for the correct range previously.
- */
-static void free_unmap_vmap_area_noflush(struct vmap_area *va)
-{
-	unmap_vmap_area(va);
-	free_vmap_area_noflush(va);
-}
-
-/*
  * Free and unmap a vmap area
  */
 static void free_unmap_vmap_area(struct vmap_area *va)
 {
 	flush_cache_vunmap(va->va_start, va->va_end);
-	free_unmap_vmap_area_noflush(va);
+	unmap_vmap_area(va);
+	free_vmap_area_noflush(va);
 }
 
 static struct vmap_area *find_vmap_area(unsigned long addr)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
