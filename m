Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 1413D6B0037
	for <linux-mm@kvack.org>; Sat, 18 May 2013 19:27:10 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH 3/5] Driver core / MM: Drop offline_memory_block()
Date: Sun, 19 May 2013 01:33:02 +0200
Message-ID: <2529630.QGJsLhExPp@vostro.rjw.lan>
In-Reply-To: <2250271.rGYN6WlBxf@vostro.rjw.lan>
References: <2250271.rGYN6WlBxf@vostro.rjw.lan>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ACPI Devel Maling List <linux-acpi@vger.kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Toshi Kani <toshi.kani@hp.com>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <liuj97@gmail.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, linux-mm@kvack.org

From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

Since offline_memory_block(mem) is functionally equivalent to
device_offline(&mem->dev), make the only caller of the former use
the latter instead and drop offline_memory_block() entirely.

Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
---
 drivers/base/memory.c          |   21 ---------------------
 include/linux/memory_hotplug.h |    1 -
 mm/memory_hotplug.c            |    2 +-
 3 files changed, 1 insertion(+), 23 deletions(-)

Index: linux-pm/drivers/base/memory.c
===================================================================
--- linux-pm.orig/drivers/base/memory.c
+++ linux-pm/drivers/base/memory.c
@@ -735,27 +735,6 @@ int unregister_memory_section(struct mem
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
-/*
- * offline one memory block. If the memory block has been offlined, do nothing.
- *
- * Call under device_hotplug_lock.
- */
-int offline_memory_block(struct memory_block *mem)
-{
-	int ret = 0;
-
-	mutex_lock(&mem->state_mutex);
-	if (mem->state != MEM_OFFLINE) {
-		ret = __memory_block_change_state_uevent(mem, MEM_OFFLINE,
-							 MEM_ONLINE, -1);
-		if (!ret)
-			mem->dev.offline = true;
-	}
-	mutex_unlock(&mem->state_mutex);
-
-	return ret;
-}
-
 /* return true if the memory block is offlined, otherwise, return false */
 bool is_memblock_offlined(struct memory_block *mem)
 {
Index: linux-pm/include/linux/memory_hotplug.h
===================================================================
--- linux-pm.orig/include/linux/memory_hotplug.h
+++ linux-pm/include/linux/memory_hotplug.h
@@ -251,7 +251,6 @@ extern int mem_online_node(int nid);
 extern int add_memory(int nid, u64 start, u64 size);
 extern int arch_add_memory(int nid, u64 start, u64 size);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
-extern int offline_memory_block(struct memory_block *mem);
 extern bool is_memblock_offlined(struct memory_block *mem);
 extern int remove_memory(int nid, u64 start, u64 size);
 extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
Index: linux-pm/mm/memory_hotplug.c
===================================================================
--- linux-pm.orig/mm/memory_hotplug.c
+++ linux-pm/mm/memory_hotplug.c
@@ -1680,7 +1680,7 @@ int walk_memory_range(unsigned long star
 static int offline_memory_block_cb(struct memory_block *mem, void *arg)
 {
 	int *ret = arg;
-	int error = offline_memory_block(mem);
+	int error = device_offline(&mem->dev);
 
 	if (error != 0 && *ret == 0)
 		*ret = error;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
