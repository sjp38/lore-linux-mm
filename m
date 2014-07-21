Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id D16CF6B0036
	for <linux-mm@kvack.org>; Sun, 20 Jul 2014 23:57:17 -0400 (EDT)
Received: by mail-oi0-f43.google.com with SMTP id u20so3081542oif.2
        for <linux-mm@kvack.org>; Sun, 20 Jul 2014 20:57:17 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id wm5si33390525oeb.58.2014.07.20.20.57.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 20 Jul 2014 20:57:17 -0700 (PDT)
From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH v2 6/7] memory-hotplug: sh: suitable memory should go to ZONE_MOVABLE
Date: Mon, 21 Jul 2014 11:46:41 +0800
Message-ID: <1405914402-66212-7-git-send-email-wangnan0@huawei.com>
In-Reply-To: <1405914402-66212-1-git-send-email-wangnan0@huawei.com>
References: <1405914402-66212-1-git-send-email-wangnan0@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Yinghai Lu <yinghai@kernel.org>, Mel
 Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Dave
 Hansen <dave.hansen@intel.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: peifeiyue@huawei.com, linux-mm@kvack.org, x86@kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org, wangnan0@huawei.com

This patch introduces zone_for_memory() to arch_add_memory() on sh to
ensure new, higher memory added into ZONE_MOVABLE if movable zone has
already setup.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Dave Hansen <dave.hansen@intel.com>
---
 arch/sh/mm/init.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index 2d089fe..2790b6a 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -495,8 +495,9 @@ int arch_add_memory(int nid, u64 start, u64 size)
 	pgdat = NODE_DATA(nid);
 
 	/* We only have ZONE_NORMAL, so this is easy.. */
-	ret = __add_pages(nid, pgdat->node_zones + ZONE_NORMAL,
-				start_pfn, nr_pages);
+	ret = __add_pages(nid, pgdat->node_zones +
+			zone_for_memory(nid, start, size, ZONE_NORMAL),
+			start_pfn, nr_pages);
 	if (unlikely(ret))
 		printk("%s: Failed, __add_pages() == %d\n", __func__, ret);
 
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
