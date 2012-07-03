Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id D55736B0075
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 01:59:53 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 6E8003EE0B5
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 14:59:52 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D07A45DE58
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 14:59:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 349BC45DE56
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 14:59:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BAA55E0800A
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 14:59:51 +0900 (JST)
Received: from g01jpexchyt04.g01.fujitsu.local (g01jpexchyt04.g01.fujitsu.local [10.128.194.43])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FE89E08002
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 14:59:50 +0900 (JST)
Message-ID: <4FF28A46.3040607@jp.fujitsu.com>
Date: Tue, 3 Jul 2012 14:59:34 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC PATCH v2 6/13] memory-hotplug : add memory_block_release
References: <4FF287C3.4030901@jp.fujitsu.com>
In-Reply-To: <4FF287C3.4030901@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

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
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

---
 drivers/base/memory.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

Index: linux-3.5-rc4/drivers/base/memory.c
===================================================================
--- linux-3.5-rc4.orig/drivers/base/memory.c	2012-07-03 14:21:58.335263984 +0900
+++ linux-3.5-rc4/drivers/base/memory.c	2012-07-03 14:22:08.094141981 +0900
@@ -108,6 +108,15 @@ bool is_memblk_offline(unsigned long sta
 }
 EXPORT_SYMBOL(is_memblk_offline);

+#define to_memory_block(device) container_of(device, struct memory_block, dev)
+
+static void release_memory_block(struct device *dev)
+{
+	struct memory_block *mem = to_memory_block(dev);
+
+	kfree(mem);
+}
+
 /*
  * register_memory - Setup a sysfs device for a memory block
  */
@@ -118,6 +127,7 @@ int register_memory(struct memory_block

 	memory->dev.bus = &memory_subsys;
 	memory->dev.id = memory->start_section_nr / sections_per_block;
+	memory->dev.release = release_memory_block;

 	error = device_register(&memory->dev);
 	return error;
@@ -668,7 +678,6 @@ int remove_memory_block(unsigned long no
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
