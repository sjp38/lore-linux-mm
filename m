Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id AC8A66B005D
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 01:22:52 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 46D1D3EE081
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 14:22:51 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A8A045DE4F
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 14:22:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 134CA45DE4E
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 14:22:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 076C71DB8041
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 14:22:51 +0900 (JST)
Received: from G01JPEXCHKW28.g01.fujitsu.local (G01JPEXCHKW28.g01.fujitsu.local [10.0.193.111])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BA3D61DB803B
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 14:22:50 +0900 (JST)
Message-ID: <50765797.3080709@jp.fujitsu.com>
Date: Thu, 11 Oct 2012 14:22:31 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 1/2]suppress "Device memoryX does not have a release() function"
 warning
References: <507656D1.5020703@jp.fujitsu.com>
In-Reply-To: <507656D1.5020703@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, rientjes@google.com, liuj97@gmail.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

When calling remove_memory_block(), the function shows following message at
device_release().

"Device 'memory528' does not have a release() function, it is broken and must
be fixed."

The reason is memory_block's device struct does not have a release() function.

So the patch registers memory_block_release() to the device's release() function
for suppressing the warning message. Additionally, the patch moves kfree(mem)
into the release function since the release function is prepared as a means
to free a memory_block struct.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Wen Congyang <wency@cn.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 drivers/base/memory.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

Index: linux-3.6/drivers/base/memory.c
===================================================================
--- linux-3.6.orig/drivers/base/memory.c	2012-10-11 11:37:33.404668048 +0900
+++ linux-3.6/drivers/base/memory.c	2012-10-11 11:38:27.865672989 +0900
@@ -70,6 +70,13 @@ void unregister_memory_isolate_notifier(
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
@@ -80,6 +87,7 @@ int register_memory(struct memory_block 
 
 	memory->dev.bus = &memory_subsys;
 	memory->dev.id = memory->start_section_nr / sections_per_block;
+	memory->dev.release = memory_block_release;
 
 	error = device_register(&memory->dev);
 	return error;
@@ -630,7 +638,6 @@ int remove_memory_block(unsigned long no
 		mem_remove_simple_file(mem, phys_device);
 		mem_remove_simple_file(mem, removable);
 		unregister_memory(mem);
-		kfree(mem);
 	} else
 		kobject_put(&mem->dev.kobj);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
