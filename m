Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id CE1B86B005A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 11:50:35 -0400 (EDT)
Received: by ggm4 with SMTP id 4so692926ggm.14
        for <linux-mm@kvack.org>; Tue, 17 Jul 2012 08:50:34 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 3/4 v3] mm: fix return value in __alloc_contig_migrate_range()
Date: Wed, 18 Jul 2012 00:49:16 +0900
Message-Id: <1342540156-3512-1-git-send-email-js1304@gmail.com>
In-Reply-To: <CAAmzW4N+CJGnn3a6PUQZAeEeb4njp_zwXMhOSdSrHc36OLsDjg@mail.gmail.com>
References: <CAAmzW4N+CJGnn3a6PUQZAeEeb4njp_zwXMhOSdSrHc36OLsDjg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>

migrate_pages() can return positive value while at the same time emptying
the list of pages it was called with.  Such situation means that it went
through all the pages on the list some of which failed to be migrated.

If that happens, __alloc_contig_migrate_range()'s loop may finish without
"++tries == 5" never being checked.  This in turn means that at the end
of the function, ret may have a positive value, which should be treated
as an error.

This patch changes __alloc_contig_migrate_range() so that the return
statement converts positive ret value into -EBUSY error.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Christoph Lameter <cl@linux.com>
Acked-by: Christoph Lameter <cl@linux.com>
Acked-by: Michal Nazarewicz <mina86@mina86.com>

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
