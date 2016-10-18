Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6AF5A6B0261
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 02:56:30 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id os4so226583400pac.5
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 23:56:30 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id vs8si28529028pab.244.2016.10.17.23.56.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 23:56:29 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 3/6] mm: remove free_unmap_vmap_area_noflush
Date: Tue, 18 Oct 2016 08:56:08 +0200
Message-Id: <1476773771-11470-4-git-send-email-hch@lst.de>
In-Reply-To: <1476773771-11470-1-git-send-email-hch@lst.de>
References: <1476773771-11470-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: joelaf@google.com, jszhang@marvell.com, chris@chris-wilson.co.uk, joaodias@google.com, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org

Just inline it into the only caller.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/vmalloc.c | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 9830514..8cedfa0 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -697,22 +697,13 @@ static void free_vmap_area_noflush(struct vmap_area *va)
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
