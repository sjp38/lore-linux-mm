Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id D6C136B00A5
	for <linux-mm@kvack.org>; Sun, 26 May 2013 09:41:49 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kl12so2518371pab.20
        for <linux-mm@kvack.org>; Sun, 26 May 2013 06:41:49 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v8, part3 06/14] mm, acornfb: use free_reserved_area() to simplify code
Date: Sun, 26 May 2013 21:38:34 +0800
Message-Id: <1369575522-26405-7-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1369575522-26405-1-git-send-email-jiang.liu@huawei.com>
References: <1369575522-26405-1-git-send-email-jiang.liu@huawei.com>
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
 drivers/video/acornfb.c | 45 ++++++---------------------------------------
 1 file changed, 6 insertions(+), 39 deletions(-)

diff --git a/drivers/video/acornfb.c b/drivers/video/acornfb.c
index 6488a73..8f7374f 100644
--- a/drivers/video/acornfb.c
+++ b/drivers/video/acornfb.c
@@ -1180,42 +1180,6 @@ static int acornfb_detect_monitortype(void)
 	return 4;
 }
 
-/*
- * This enables the unused memory to be freed on older Acorn machines.
- * We are freeing memory on behalf of the architecture initialisation
- * code here.
- */
-static inline void
-free_unused_pages(unsigned int virtual_start, unsigned int virtual_end)
-{
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
-}
-
 static int acornfb_probe(struct platform_device *dev)
 {
 	unsigned long size;
@@ -1312,10 +1276,13 @@ static int acornfb_probe(struct platform_device *dev)
 #endif
 #if defined(HAS_VIDC)
 	/*
-	 * Archimedes/A5000 machines use a fixed address for their
-	 * framebuffers.  Free unused pages
+	 * We are freeing memory on behalf of the architecture initialisation
+	 * code here. Archimedes/A5000 machines use a fixed address for their
+	 * framebuffers.
 	 */
-	free_unused_pages(PAGE_OFFSET + size, PAGE_OFFSET + MAX_SIZE);
+	free_reserved_area((void *)(PAGE_OFFSET + size),
+			   (void *)PAGE_ALIGN(PAGE_OFFSET + MAX_SIZE),
+			   -1, "acornfb");
 #endif
 
 	fb_info.fix.smem_len = size;
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
