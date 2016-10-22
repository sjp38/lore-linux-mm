Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 605986B0253
	for <linux-mm@kvack.org>; Sat, 22 Oct 2016 11:17:29 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x70so35038363pfk.0
        for <linux-mm@kvack.org>; Sat, 22 Oct 2016 08:17:29 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id l9si6129056paw.129.2016.10.22.08.17.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Oct 2016 08:17:28 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 1/7] mm: remove free_unmap_vmap_area_noflush
Date: Sat, 22 Oct 2016 17:17:14 +0200
Message-Id: <1477149440-12478-2-git-send-email-hch@lst.de>
In-Reply-To: <1477149440-12478-1-git-send-email-hch@lst.de>
References: <1477149440-12478-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: joelaf@google.com, jszhang@marvell.com, chris@chris-wilson.co.uk, joaodias@google.com, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org

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
