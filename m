Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id E672F6B003B
	for <linux-mm@kvack.org>; Fri, 17 May 2013 11:46:23 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id xb12so3436684pbc.14
        for <linux-mm@kvack.org>; Fri, 17 May 2013 08:46:23 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v7, part3 07/16] mm, acornfb: use free_reserved_area() to simplify code
Date: Fri, 17 May 2013 23:45:09 +0800
Message-Id: <1368805518-2634-8-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1368805518-2634-1-git-send-email-jiang.liu@huawei.com>
References: <1368805518-2634-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Florian Tobias Schandinat <FlorianSchandinat@gmx.de>, linux-fbdev@vger.kernel.org

Use common help function free_reserved_area() to simplify code.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Florian Tobias Schandinat <FlorianSchandinat@gmx.de>
Cc: linux-fbdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/video/acornfb.c | 28 ++--------------------------
 1 file changed, 2 insertions(+), 26 deletions(-)

diff --git a/drivers/video/acornfb.c b/drivers/video/acornfb.c
index 6488a73..344f2bb 100644
--- a/drivers/video/acornfb.c
+++ b/drivers/video/acornfb.c
@@ -1188,32 +1188,8 @@ static int acornfb_detect_monitortype(void)
 static inline void
 free_unused_pages(unsigned int virtual_start, unsigned int virtual_end)
 {
-	int mb_freed = 0;
-
-	/*
-	 * Align addresses
-	 */
-	virtual_start = PAGE_ALIGN(virtual_start);
-	virtual_end = PAGE_ALIGN(virtual_end);
-
-	while (virtual_start < virtual_end) {
-		struct page *page;
-
-		/*
-		 * Clear page reserved bit,
-		 * set count to 1, and free
-		 * the page.
-		 */
-		page = virt_to_page(virtual_start);
-		ClearPageReserved(page);
-		init_page_count(page);
-		free_page(virtual_start);
-
-		virtual_start += PAGE_SIZE;
-		mb_freed += PAGE_SIZE / 1024;
-	}
-
-	printk("acornfb: freed %dK memory\n", mb_freed);
+	free_reserved_area(virtual_start, PAGE_ALIGN(virtual_end),
+			   -1, "acornfb");
 }
 
 static int acornfb_probe(struct platform_device *dev)
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
