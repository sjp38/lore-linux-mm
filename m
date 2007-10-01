Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l91M4DdV032240
	for <linux-mm@kvack.org>; Mon, 1 Oct 2007 18:04:13 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l91M4DgL500166
	for <linux-mm@kvack.org>; Mon, 1 Oct 2007 16:04:13 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l91M4Dm4026356
	for <linux-mm@kvack.org>; Mon, 1 Oct 2007 16:04:13 -0600
Subject: [PATCH][-mm only] Error handling in walk_memory_resource()
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: text/plain
Date: Mon, 01 Oct 2007 15:07:18 -0700
Message-Id: <1191276438.30691.13.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I found this while trying to get hotplug memory remove working on ppc64.
ppc64 doesn't show all the memory regions in /proc/iomem like ia64 or
x86_64 and we end up wrongly offling pages.

Thanks,
Badari

walk_memory_resource() should return failure, if it can't find the memory
region in the /proc/iomem. Otherwise, offline_pages() would end up isolating
pages wrongly.

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>

---
 kernel/resource.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.23-rc8/kernel/resource.c
===================================================================
--- linux-2.6.23-rc8.orig/kernel/resource.c	2007-10-01 14:09:01.000000000 -0700
+++ linux-2.6.23-rc8/kernel/resource.c	2007-10-01 14:09:35.000000000 -0700
@@ -284,7 +284,7 @@ walk_memory_resource(unsigned long start
 	struct resource res;
 	unsigned long pfn, len;
 	u64 orig_end;
-	int ret;
+	int ret = -1;
 	res.start = (u64) start_pfn << PAGE_SHIFT;
 	res.end = ((u64)(start_pfn + nr_pages) << PAGE_SHIFT) - 1;
 	res.flags = IORESOURCE_MEM;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
