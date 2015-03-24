Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0441A6B0070
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 11:24:41 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so228828119pad.3
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 08:24:40 -0700 (PDT)
Received: from mail-pd0-x234.google.com (mail-pd0-x234.google.com. [2607:f8b0:400e:c02::234])
        by mx.google.com with ESMTPS id ch12si6002890pdb.146.2015.03.24.08.24.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 08:24:40 -0700 (PDT)
Received: by pdnc3 with SMTP id c3so224606373pdn.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 08:24:40 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH 2/2] zsmalloc: micro-optimize zs_object_copy()
Date: Wed, 25 Mar 2015 00:24:47 +0900
Message-Id: <1427210687-6634-3-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1427210687-6634-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1427210687-6634-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

A micro-optimization. Avoid additional branching and reduce
(a bit) registry pressure (f.e. s_off += size; d_off += size;
may be calculated twise: first for >= PAGE_SIZE check and later
for offset update in "else" clause).

/scripts/bloat-o-meter shows some improvement

add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-10 (-10)
function                          old     new   delta
zs_object_copy                    550     540     -10

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 7af4456..dc35328 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1535,28 +1535,27 @@ static void zs_object_copy(unsigned long src, unsigned long dst,
 		if (written == class->size)
 			break;
 
-		if (s_off + size >= PAGE_SIZE) {
+		s_off += size;
+		s_size -= size;
+		d_off += size;
+		d_size -= size;
+
+		if (s_off >= PAGE_SIZE) {
 			kunmap_atomic(s_addr);
 			s_page = get_next_page(s_page);
 			BUG_ON(!s_page);
 			s_addr = kmap_atomic(s_page);
 			s_size = class->size - written;
 			s_off = 0;
-		} else {
-			s_off += size;
-			s_size -= size;
 		}
 
-		if (d_off + size >= PAGE_SIZE) {
+		if (d_off >= PAGE_SIZE) {
 			kunmap_atomic(d_addr);
 			d_page = get_next_page(d_page);
 			BUG_ON(!d_page);
 			d_addr = kmap_atomic(d_page);
 			d_size = class->size - written;
 			d_off = 0;
-		} else {
-			d_off += size;
-			d_size -= size;
 		}
 	}
 
-- 
2.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
