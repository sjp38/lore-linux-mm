Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 657186B0062
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 02:41:10 -0400 (EDT)
From: wency@cn.fujitsu.com
Subject: [PATCH v3 1/9] suppress "Device memoryX does not have a release() function" warning
Date: Fri, 19 Oct 2012 14:46:34 +0800
Message-Id: <1350629202-9664-2-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1350629202-9664-1-git-send-email-wency@cn.fujitsu.com>
References: <1350629202-9664-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Wen Congyang <wency@cn.fujitsu.com>

From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

When calling remove_memory_block(), the function shows following message at
device_release().

"Device 'memory528' does not have a release() function, it is broken and must
be fixed."

The reason is memory_block's device struct does not have a release() function.

So the patch registers memory_block_release() to the device's release() function
for suppressing the warning message. Additionally, the patch moves kfree(mem)
into the release function since the release function is prepared as a means
to free a memory_block struct.

CC: Jiang Liu <liuj97@gmail.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Wen Congyang <wency@cn.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Acked-by: David Rientjes <rientjes@google.com>
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 drivers/base/memory.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 86c8821..7eb1211 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -70,6 +70,13 @@ void unregister_memory_isolate_notifier(struct notifier_block *nb)
 }
 EXPORT_SYMBOL(unregister_memory_isolate_notifier);
 
+static void memory_block_release(struct device *dev)
+{
+	struct memory_block *mem = container_of(dev, struct memory_block, dev);
+
+	kfree(mem);
+}
+
 /*
  * register_memory - Setup a sysfs device for a memory block
  */
@@ -80,6 +87,7 @@ int register_memory(struct memory_block *memory)
 
 	memory->dev.bus = &memory_subsys;
 	memory->dev.id = memory->start_section_nr / sections_per_block;
+	memory->dev.release = memory_block_release;
 
 	error = device_register(&memory->dev);
 	return error;
@@ -635,7 +643,6 @@ int remove_memory_block(unsigned long node_id, struct mem_section *section,
 		mem_remove_simple_file(mem, phys_device);
 		mem_remove_simple_file(mem, removable);
 		unregister_memory(mem);
-		kfree(mem);
 	} else
 		kobject_put(&mem->dev.kobj);
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
