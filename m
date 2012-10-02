Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 978EB6B00BE
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 04:28:05 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id A7B763EE0BC
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 17:28:03 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C3B145DE56
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 17:28:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6682145DE59
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 17:28:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5043F1DB8052
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 17:28:03 +0900 (JST)
Received: from g01jpexchkw11.g01.fujitsu.local (g01jpexchkw11.g01.fujitsu.local [10.0.194.50])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 096911DB8043
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 17:28:03 +0900 (JST)
Message-ID: <506AA57C.1090209@jp.fujitsu.com>
Date: Tue, 2 Oct 2012 17:27:40 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [Patch 1/2] memory-hotplug : Preparation to notify memory block's
 state at memory hot remove
References: <506AA4E2.7070302@jp.fujitsu.com>
In-Reply-To: <506AA4E2.7070302@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

From: Wen Congyang <wency@cn.fujitsu.com>

remove_memory() is called in two cases:
1. echo offline >/sys/devices/system/memory/memoryXX/state
2. hot remove a memory device

In the 1st case, the memory block's state is changed and the notification
that memory block's state changed is sent to userland after calling
remove_memory(). So user can notice memory block is changed.

But in the 2nd case, the memory block's state is not changed and the
notification is not also sent to userspcae even if calling remove_memory().
So user cannot notice memory block is changed.

For adding the notification at memory hot remove, the patch just prepare
as follows:
1st case uses offline_pages() for offlining memory.
2nd case uses remove_memory() for offlining memory and changing memory block's
state and notifing the information.

The patch does not implement notification to remove_memory().

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> 
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 drivers/base/memory.c          |    9 +++------
 include/linux/memory_hotplug.h |    1 +
 mm/memory_hotplug.c            |   13 +++++++++++--
 3 files changed, 15 insertions(+), 8 deletions(-)

Index: linux-3.6/drivers/base/memory.c
===================================================================
--- linux-3.6.orig/drivers/base/memory.c	2012-10-02 16:01:46.000000000 +0900
+++ linux-3.6/drivers/base/memory.c	2012-10-02 16:07:08.278081232 +0900
@@ -248,26 +248,23 @@ static bool pages_correctly_reserved(uns
 static int
 memory_block_action(unsigned long phys_index, unsigned long action)
 {
-	unsigned long start_pfn, start_paddr;
+	unsigned long start_pfn;
 	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
 	struct page *first_page;
 	int ret;
 
 	first_page = pfn_to_page(phys_index << PFN_SECTION_SHIFT);
+	start_pfn = page_to_pfn(first_page);
 
 	switch (action) {
 		case MEM_ONLINE:
-			start_pfn = page_to_pfn(first_page);
-
 			if (!pages_correctly_reserved(start_pfn, nr_pages))
 				return -EBUSY;
 
 			ret = online_pages(start_pfn, nr_pages);
 			break;
 		case MEM_OFFLINE:
-			start_paddr = page_to_pfn(first_page) << PAGE_SHIFT;
-			ret = remove_memory(start_paddr,
-					    nr_pages << PAGE_SHIFT);
+			ret = offline_pages(start_pfn, nr_pages);
 			break;
 		default:
 			WARN(1, KERN_WARNING "%s(%ld, %ld) unknown action: "
Index: linux-3.6/include/linux/memory_hotplug.h
===================================================================
--- linux-3.6.orig/include/linux/memory_hotplug.h	2012-10-02 16:01:46.000000000 +0900
+++ linux-3.6/include/linux/memory_hotplug.h	2012-10-02 16:07:08.281081235 +0900
@@ -233,6 +233,7 @@ static inline int is_mem_section_removab
 extern int mem_online_node(int nid);
 extern int add_memory(int nid, u64 start, u64 size);
 extern int arch_add_memory(int nid, u64 start, u64 size);
+extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
 extern int remove_memory(u64 start, u64 size);
 extern int sparse_add_one_section(struct zone *zone, unsigned long start_pfn,
 								int nr_pages);
Index: linux-3.6/mm/memory_hotplug.c
===================================================================
--- linux-3.6.orig/mm/memory_hotplug.c	2012-10-02 16:01:46.000000000 +0900
+++ linux-3.6/mm/memory_hotplug.c	2012-10-02 16:07:08.279081233 +0900
@@ -870,7 +870,7 @@ check_pages_isolated(unsigned long start
 	return offlined;
 }
 
-static int __ref offline_pages(unsigned long start_pfn,
+static int __ref __offline_pages(unsigned long start_pfn,
 		  unsigned long end_pfn, unsigned long timeout)
 {
 	unsigned long pfn, nr_pages, expire;
@@ -998,15 +998,24 @@ out:
 	return ret;
 }
 
+int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
+{
+	return __offline_pages(start_pfn, start_pfn + nr_pages, 120 * HZ);
+}
+
 int remove_memory(u64 start, u64 size)
 {
 	unsigned long start_pfn, end_pfn;
 
 	start_pfn = PFN_DOWN(start);
 	end_pfn = start_pfn + PFN_DOWN(size);
-	return offline_pages(start_pfn, end_pfn, 120 * HZ);
+	return __offline_pages(start_pfn, end_pfn, 120 * HZ);
 }
 #else
+int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
+{
+	return -EINVAL;
+}
 int remove_memory(u64 start, u64 size)
 {
 	return -EINVAL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
