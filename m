Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1D7E66B0035
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 07:12:08 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id u10so2216736lbd.22
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 04:12:08 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id l7si6794667lae.27.2014.06.20.04.12.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Jun 2014 04:12:07 -0700 (PDT)
From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH] mem-hotplug: improve zone_movable_is_highmem logic
Date: Fri, 20 Jun 2014 18:54:14 +0800
Message-ID: <1403261654-11259-1-git-send-email-wangnan0@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Jiang Liu <liuj97@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wang Nan <wangnan0@huawei.com>, Li Zefan <lizefan@huawei.com>

In original code, zone_movable_is_highmem() assumes ZONE_MOVABLE not
highmem if CONFIG_HAVE_MEMBLOCK_NODE_MAP is not set. In online_pages, it
extracts pages from the previous zone before ZONE_MOVABLE. Which is
logically inconsistent:

If HAVE_MEMBLOCK_NODE_MAP is turned off but HIGHMEM is on,
zone_movable_is_highmem() makes movable zone not highmem, but
online_pages() extracts pages from ZONE_HIGHMEM.

This inconsistency doesn't cause real problem currently, because all
architectures support online_pages also have HAVE_MEMBLOCK_NODE_MAP.
However, fixing it makes code clear, and also helps futher coding.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Cc: Zhang Zhen <zhangzhen@huawei.com>
---
 include/linux/mmzone.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 6cbd1b6..559e659 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -872,6 +872,8 @@ static inline int zone_movable_is_highmem(void)
 {
 #if defined(CONFIG_HIGHMEM) && defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP)
 	return movable_zone == ZONE_HIGHMEM;
+#elif defined(CONFIG_HIGHMEM)
+	return (ZONE_MOVABLE - 1) == ZONE_HIGHMEM;
 #else
 	return 0;
 #endif
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
