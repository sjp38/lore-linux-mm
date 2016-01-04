Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id BA8A46B0006
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 11:17:42 -0500 (EST)
Received: by mail-io0-f169.google.com with SMTP id 77so128958133ioc.2
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 08:17:42 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i128si103750iof.125.2016.01.04.08.17.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 08:17:42 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH v2 1/2] memory-hotplug: don't BUG() in register_memory_resource()
Date: Mon,  4 Jan 2016 17:17:30 +0100
Message-Id: <1451924251-4189-2-git-send-email-vkuznets@redhat.com>
In-Reply-To: <1451924251-4189-1-git-send-email-vkuznets@redhat.com>
References: <1451924251-4189-1-git-send-email-vkuznets@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Sheng Yong <shengyong1@huawei.com>, Zhu Guihua <zhugh.fnst@cn.fujitsu.com>, Dan Williams <dan.j.williams@intel.com>, David Vrabel <david.vrabel@citrix.com>, Igor Mammedov <imammedo@redhat.com>

Out of memory condition is not a bug and while we can't add new memory in
such case crashing the system seems wrong. Propagating the return value
from register_memory_resource() requires interface change.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>
Cc: Sheng Yong <shengyong1@huawei.com>
Cc: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: Igor Mammedov <imammedo@redhat.com>
---
Changes since v1:
- Use ERR_PTR/PTR_ERR/IS_ERR() [David Rientjes]
---
 mm/memory_hotplug.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index a042a9d..92f9595 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -131,7 +131,8 @@ static struct resource *register_memory_resource(u64 start, u64 size)
 {
 	struct resource *res;
 	res = kzalloc(sizeof(struct resource), GFP_KERNEL);
-	BUG_ON(!res);
+	if (!res)
+		return ERR_PTR(-ENOMEM);
 
 	res->name = "System RAM";
 	res->start = start;
@@ -140,7 +141,7 @@ static struct resource *register_memory_resource(u64 start, u64 size)
 	if (request_resource(&iomem_resource, res) < 0) {
 		pr_debug("System RAM resource %pR cannot be added\n", res);
 		kfree(res);
-		res = NULL;
+		return ERR_PTR(-EEXIST);
 	}
 	return res;
 }
@@ -1312,8 +1313,8 @@ int __ref add_memory(int nid, u64 start, u64 size)
 	int ret;
 
 	res = register_memory_resource(start, size);
-	if (!res)
-		return -EEXIST;
+	if (IS_ERR(res))
+		return PTR_ERR(res);
 
 	ret = add_memory_resource(nid, res);
 	if (ret < 0)
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
