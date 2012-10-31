Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 4FC1D6B006C
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 07:48:22 -0400 (EDT)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [Patch v4 1/8] memory hotplug: suppress "Device memoryX does not have a release() function" warning
Date: Wed, 31 Oct 2012 19:23:07 +0800
Message-Id: <1351682594-17347-2-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1351682594-17347-1-git-send-email-wency@cn.fujitsu.com>
References: <1351682594-17347-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org
Cc: Jiang Liu <liuj97@gmail.com>, Len Brown <len.brown@intel.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, rjw@sisk.pl, Lai Jiangshan <laijs@cn.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Wen Congyang <wency@cn.fujitsu.com>, Greg KH <greg@kroah.com>

From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

When calling remove_memory_block(), the function shows following message
at device_release().

"Device 'memory528' does not have a release() function, it is broken and
must be fixed."

The reason is memory_block's device struct does not have a release()
function.

So the patch registers memory_block_release() to the device's release()
function for suppressing the warning message.  Additionally, the patch
moves kfree(mem) into the release function since the release function is
prepared as a means to free a memory_block struct.

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Acked-by: David Rientjes <rientjes@google.com>
Cc: Jiang Liu <liuj97@gmail.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>
Cc: Greg KH <greg@kroah.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 drivers/base/memory.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

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
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
