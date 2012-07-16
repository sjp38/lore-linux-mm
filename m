Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 5123C6B005C
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 12:16:20 -0400 (EDT)
Received: by mail-yx0-f169.google.com with SMTP id r5so6211117yen.14
        for <linux-mm@kvack.org>; Mon, 16 Jul 2012 09:16:19 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 3/3] mm: fix return value in __alloc_contig_migrate_range()
Date: Tue, 17 Jul 2012 01:14:32 +0900
Message-Id: <1342455272-32703-3-git-send-email-js1304@gmail.com>
In-Reply-To: <1342455272-32703-1-git-send-email-js1304@gmail.com>
References: <Yes>
 <1342455272-32703-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>

migrate_pages() would return positive value in some failure case,
so 'ret > 0 ? 0 : ret' may be wrong.
This fix it and remove one dead statement.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Christoph Lameter <cl@linux.com>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4403009..02d4519 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5673,7 +5673,6 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
 			}
 			tries = 0;
 		} else if (++tries == 5) {
-			ret = ret < 0 ? ret : -EBUSY;
 			break;
 		}
 
@@ -5683,7 +5682,7 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
 	}
 
 	putback_lru_pages(&cc.migratepages);
-	return ret > 0 ? 0 : ret;
+	return ret <= 0 ? ret : -EBUSY;
 }
 
 /*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
