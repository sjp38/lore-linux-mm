Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f44.google.com (mail-oa0-f44.google.com [209.85.219.44])
	by kanga.kvack.org (Postfix) with ESMTP id A49DA6B003D
	for <linux-mm@kvack.org>; Sun, 20 Jul 2014 23:58:04 -0400 (EDT)
Received: by mail-oa0-f44.google.com with SMTP id eb12so6697287oac.31
        for <linux-mm@kvack.org>; Sun, 20 Jul 2014 20:58:04 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id t10si33388237oel.91.2014.07.20.20.57.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 20 Jul 2014 20:58:04 -0700 (PDT)
From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH v2 4/7] memory-hotplug: ia64: suitable memory should go to ZONE_MOVABLE
Date: Mon, 21 Jul 2014 11:46:39 +0800
Message-ID: <1405914402-66212-5-git-send-email-wangnan0@huawei.com>
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

This patch introduces zone_for_memory() to arch_add_memory() on ia64 to
ensure new, higher memory added into ZONE_MOVABLE if movable zone has
already setup.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Dave Hansen <dave.hansen@intel.com>
---
 arch/ia64/mm/init.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 25c3502..892d43e 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -631,7 +631,8 @@ int arch_add_memory(int nid, u64 start, u64 size)
 
 	pgdat = NODE_DATA(nid);
 
-	zone = pgdat->node_zones + ZONE_NORMAL;
+	zone = pgdat->node_zones +
+		zone_for_memory(nid, start, size, ZONE_NORMAL);
 	ret = __add_pages(nid, zone, start_pfn, nr_pages);
 
 	if (ret)
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
