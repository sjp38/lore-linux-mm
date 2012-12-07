Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 4DD976B006E
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 03:51:19 -0500 (EST)
Message-ID: <50C1AD6D.7010709@huawei.com>
Date: Fri, 7 Dec 2012 16:48:45 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH V2] MCE: fix an error of mce_bad_pages statistics
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: WuJianguo <wujianguo@huawei.com>, Xishi Qiu <qiuxishi@huawei.com>, Liujiang <jiang.liu@huawei.com>, Vyacheslav.Dubeyko@huawei.com, Borislav Petkov <bp@alien8.de>, andi@firstfloor.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On x86 platform, if we use "/sys/devices/system/memory/soft_offline_page" to offline a
free page twice, the value of mce_bad_pages will be added twice. So this is an error,
since the page was already marked HWPoison, we should skip the page and don't add the
value of mce_bad_pages.

$ cat /proc/meminfo | grep HardwareCorrupted

soft_offline_page()
	get_any_page()
		atomic_long_add(1, &mce_bad_pages)

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
i>>?Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 mm/memory-failure.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 8b20278..de760ca 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1582,8 +1582,11 @@ int soft_offline_page(struct page *page, int flags)
 		return ret;

 done:
-	atomic_long_add(1, &mce_bad_pages);
-	SetPageHWPoison(page);
 	/* keep elevated page count for bad page */
+	if (!PageHWPoison(page)) {
+		atomic_long_add(1, &mce_bad_pages);
+		SetPageHWPoison(page);
+	}
+
 	return ret;
 }
-- 
1.7.6.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
