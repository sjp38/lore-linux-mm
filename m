Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f49.google.com (mail-lf0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2D9306B0009
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 04:41:56 -0500 (EST)
Received: by mail-lf0-f49.google.com with SMTP id j78so104543372lfb.1
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 01:41:56 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id k75si3586931lfg.104.2016.02.16.01.41.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Feb 2016 01:41:55 -0800 (PST)
Message-ID: <56C2EDC1.2090509@huawei.com>
Date: Tue, 16 Feb 2016 17:37:05 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm: add MM_SWAPENTS and page table when calculate tasksize
 in lowmem_scan()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, arve@android.com, riandrews@android.com, devel@driverdev.osuosl.org, zhong jiang <zhongjiang@huawei.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

Currently tasksize in lowmem_scan() only calculate rss, and not include swap.
But usually smart phones enable zram, so swap space actually use ram.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 drivers/staging/android/lowmemorykiller.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
index 8b5a4a8..718ab8e 100644
--- a/drivers/staging/android/lowmemorykiller.c
+++ b/drivers/staging/android/lowmemorykiller.c
@@ -139,7 +139,10 @@ static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
 			task_unlock(p);
 			continue;
 		}
-		tasksize = get_mm_rss(p->mm);
+		tasksize = get_mm_rss(p->mm) +
+			   get_mm_counter(p->mm, MM_SWAPENTS) +
+			   atomic_long_read(&p->mm->nr_ptes) +
+			   mm_nr_pmds(p->mm);
 		task_unlock(p);
 		if (tasksize <= 0)
 			continue;
-- 
1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
