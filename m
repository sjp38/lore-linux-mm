Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 456966B006E
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 11:24:37 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so224381080pdb.2
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 08:24:37 -0700 (PDT)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com. [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id in5si5843688pbd.231.2015.03.24.08.24.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 08:24:36 -0700 (PDT)
Received: by pdbcz9 with SMTP id cz9so224292734pdb.3
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 08:24:36 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH 1/2] zsmalloc: do not remap dst page while prepare next src page
Date: Wed, 25 Mar 2015 00:24:46 +0900
Message-Id: <1427210687-6634-2-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1427210687-6634-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1427210687-6634-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

object may belong to different pages. zs_object_copy() handles
this case and maps a new source page (get_next_page() and
kmap_atomic()) when object crosses boundaries of the current
source page. But it also performs unnecessary kunmap/kmap_atomic
of the destination page (it remains unchanged), which can be
avoided.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index d920e8b..7af4456 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1536,12 +1536,10 @@ static void zs_object_copy(unsigned long src, unsigned long dst,
 			break;
 
 		if (s_off + size >= PAGE_SIZE) {
-			kunmap_atomic(d_addr);
 			kunmap_atomic(s_addr);
 			s_page = get_next_page(s_page);
 			BUG_ON(!s_page);
 			s_addr = kmap_atomic(s_page);
-			d_addr = kmap_atomic(d_page);
 			s_size = class->size - written;
 			s_off = 0;
 		} else {
-- 
2.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
