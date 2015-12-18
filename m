Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8662C6B0005
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 09:50:30 -0500 (EST)
Received: by mail-qk0-f172.google.com with SMTP id t125so112143930qkh.3
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 06:50:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c67si16519467qgc.16.2015.12.18.06.50.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Dec 2015 06:50:29 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH] memory-hotplug: don't BUG() in register_memory_resource()
Date: Fri, 18 Dec 2015 15:50:24 +0100
Message-Id: <1450450224-18515-1-git-send-email-vkuznets@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Sheng Yong <shengyong1@huawei.com>, David Rientjes <rientjes@google.com>, Zhu Guihua <zhugh.fnst@cn.fujitsu.com>, Dan Williams <dan.j.williams@intel.com>, David Vrabel <david.vrabel@citrix.com>, Igor Mammedov <imammedo@redhat.com>

Out of memory condition is not a bug and while we can't add new memory in
such case crashing the system seems wrong. Propagating the return value
from register_memory_resource() requires interface change.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>
Cc: Sheng Yong <shengyong1@huawei.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: Igor Mammedov <imammedo@redhat.com>
Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 mm/memory_hotplug.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 67d488a..9392f01 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -127,11 +127,13 @@ void mem_hotplug_done(void)
 }
 
 /* add this memory to iomem resource */
-static struct resource *register_memory_resource(u64 start, u64 size)
+static int register_memory_resource(u64 start, u64 size,
+				    struct resource **resource)
 {
 	struct resource *res;
 	res = kzalloc(sizeof(struct resource), GFP_KERNEL);
-	BUG_ON(!res);
+	if (!res)
+		return -ENOMEM;
 
 	res->name = "System RAM";
 	res->start = start;
@@ -140,9 +142,10 @@ static struct resource *register_memory_resource(u64 start, u64 size)
 	if (request_resource(&iomem_resource, res) < 0) {
 		pr_debug("System RAM resource %pR cannot be added\n", res);
 		kfree(res);
-		res = NULL;
+		return -EEXIST;
 	}
-	return res;
+	*resource = res;
+	return 0;
 }
 
 static void release_memory_resource(struct resource *res)
@@ -1311,9 +1314,9 @@ int __ref add_memory(int nid, u64 start, u64 size)
 	struct resource *res;
 	int ret;
 
-	res = register_memory_resource(start, size);
-	if (!res)
-		return -EEXIST;
+	ret = register_memory_resource(start, size, &res);
+	if (ret)
+		return ret;
 
 	ret = add_memory_resource(nid, res);
 	if (ret < 0)
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
