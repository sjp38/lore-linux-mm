Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id D46E96B0062
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 01:39:28 -0400 (EDT)
From: wency@cn.fujitsu.com
Subject: [PATCH 1/4] memory-hotplug: add memory_block_release
Date: Thu, 27 Sep 2012 13:45:02 +0800
Message-Id: <1348724705-23779-2-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1348724705-23779-1-git-send-email-wency@cn.fujitsu.com>
References: <1348724705-23779-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Wen Congyang <wency@cn.fujitsu.com>

From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

When calling remove_memory_block(), the function shows following message at
device_release().

Device 'memory528' does not have a release() function, it is broken and must
be fixed.

remove_memory_block() calls kfree(mem). I think it shouled be called from
device_release(). So the patch implements memory_block_release()

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Wen Congyang <wency@cn.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 drivers/base/memory.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 7dda4f7..da457e5 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -70,6 +70,13 @@ void unregister_memory_isolate_notifier(struct notifier_block *nb)
 }
 EXPORT_SYMBOL(unregister_memory_isolate_notifier);
 
+static void release_memory_block(struct device *dev)
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
+	memory->dev.release = release_memory_block;
 
 	error = device_register(&memory->dev);
 	return error;
@@ -630,7 +638,6 @@ int remove_memory_block(unsigned long node_id, struct mem_section *section,
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
