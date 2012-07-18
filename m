Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id C11E36B005D
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 06:04:50 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 593A83EE0C8
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 19:04:49 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D6F1645DE5A
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 19:04:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id ADEBF45DE4F
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 19:04:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B9E51DB803F
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 19:04:47 +0900 (JST)
Received: from g01jpexchyt07.g01.fujitsu.local (g01jpexchyt07.g01.fujitsu.local [10.128.194.46])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EABB3E08004
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 19:04:46 +0900 (JST)
Message-ID: <50068A2C.2030605@jp.fujitsu.com>
Date: Wed, 18 Jul 2012 19:04:28 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC PATCH 0/13] firmware_map : unify argument of firmware_map_add_early/hotplug
References: <50068974.1070409@jp.fujitsu.com>
In-Reply-To: <50068974.1070409@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

There are two ways to create /sys/firmware/memmap/X sysfs:

  - firmware_map_add_early
    When the system starts, it is calledd from e820_reserve_resources()
  - firmware_map_add_hotplug
    When the memory is hot plugged, it is called from add_memory()

But these functions are called without unifying value of end argument as below:

  - end argument of firmware_map_add_early()   : start + size - 1
  - end argument of firmware_map_add_hogplug() : start + size

The patch unifies them to "start + size". Even if applying the patch,
/sys/firmware/memmap/X/end file content does not change.

CC: Thomas Gleixner <tglx@linutronix.de>
CC: Ingo Molnar <mingo@kernel.org>
CC: H. Peter Anvin <hpa@zytor.com>
CC: Tejun Heo <tj@kernel.org>
CC: Andrew Morton <akpm@linux-foundation.org>
Reviewed-by: Dave Hansen <dave@linux.vnet.ibm.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

---
 arch/x86/kernel/e820.c    |    2 +-
 drivers/firmware/memmap.c |    8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

Index: linux-3.5-rc6/arch/x86/kernel/e820.c
===================================================================
--- linux-3.5-rc6.orig/arch/x86/kernel/e820.c	2012-07-18 17:19:38.391365260 +0900
+++ linux-3.5-rc6/arch/x86/kernel/e820.c	2012-07-18 17:19:43.616300222 +0900
@@ -944,7 +944,7 @@ void __init e820_reserve_resources(void)
 	for (i = 0; i < e820_saved.nr_map; i++) {
 		struct e820entry *entry = &e820_saved.map[i];
 		firmware_map_add_early(entry->addr,
-			entry->addr + entry->size - 1,
+			entry->addr + entry->size,
 			e820_type_to_string(entry->type));
 	}
 }
Index: linux-3.5-rc6/drivers/firmware/memmap.c
===================================================================
--- linux-3.5-rc6.orig/drivers/firmware/memmap.c	2012-07-18 17:19:38.388365299 +0900
+++ linux-3.5-rc6/drivers/firmware/memmap.c	2012-07-18 18:30:47.608390251 +0900
@@ -98,7 +98,7 @@ static LIST_HEAD(map_entries);
 /**
  * firmware_map_add_entry() - Does the real work to add a firmware memmap entry.
  * @start: Start of the memory range.
- * @end:   End of the memory range (inclusive).
+ * @end:   End of the memory range.
  * @type:  Type of the memory range.
  * @entry: Pre-allocated (either kmalloc() or bootmem allocator), uninitialised
  *         entry.
@@ -113,7 +113,7 @@ static int firmware_map_add_entry(u64 st
 	BUG_ON(start > end);
 
 	entry->start = start;
-	entry->end = end;
+	entry->end = end - 1;
 	entry->type = type;
 	INIT_LIST_HEAD(&entry->list);
 	kobject_init(&entry->kobj, &memmap_ktype);
@@ -148,7 +148,7 @@ static int add_sysfs_fw_map_entry(struct
  * firmware_map_add_hotplug() - Adds a firmware mapping entry when we do
  * memory hotplug.
  * @start: Start of the memory range.
- * @end:   End of the memory range (inclusive).
+ * @end:   End of the memory range.
  * @type:  Type of the memory range.
  *
  * Adds a firmware mapping entry. This function is for memory hotplug, it is
@@ -175,7 +175,7 @@ int __meminit firmware_map_add_hotplug(u
 /**
  * firmware_map_add_early() - Adds a firmware mapping entry.
  * @start: Start of the memory range.
- * @end:   End of the memory range (inclusive).
+ * @end:   End of the memory range.
  * @type:  Type of the memory range.
  *
  * Adds a firmware mapping entry. This function uses the bootmem allocator

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
