Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id CE97D6B02E2
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 23:41:50 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id e12so3283682pga.5
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 20:41:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r9sor1402316pge.312.2018.01.05.20.41.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Jan 2018 20:41:49 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH] mm: ratelimit end_swap_bio_write() error
Date: Sat,  6 Jan 2018 13:34:07 +0900
Message-Id: <20180106043407.25193-1-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Use the ratelimited printk() version for swap-device write error
reporting. We can use ZRAM as a swap-device, and the tricky part
here is that zsmalloc() stores compressed objects in memory, thus
it has to allocates pages during swap-out. If the system is short
on memory, then we begin to flood printk() log buffer with the
same "Write-error on swap-device XXX" error messages and sometimes
simply lockup the system.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/page_io.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_io.c b/mm/page_io.c
index e93f1a4cacd7..422cd49bcba8 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -63,7 +63,7 @@ void end_swap_bio_write(struct bio *bio)
 		 * Also clear PG_reclaim to avoid rotate_reclaimable_page()
 		 */
 		set_page_dirty(page);
-		pr_alert("Write-error on swap-device (%u:%u:%llu)\n",
+		pr_alert_ratelimited("Write-error on swap-device (%u:%u:%llu)\n",
 			 MAJOR(bio_dev(bio)), MINOR(bio_dev(bio)),
 			 (unsigned long long)bio->bi_iter.bi_sector);
 		ClearPageReclaim(page);
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
