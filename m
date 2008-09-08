Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m88Lqfcd010846
	for <linux-mm@kvack.org>; Mon, 8 Sep 2008 17:52:41 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m88LqWQV169084
	for <linux-mm@kvack.org>; Mon, 8 Sep 2008 15:52:41 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m88LqVbH018958
	for <linux-mm@kvack.org>; Mon, 8 Sep 2008 15:52:32 -0600
Subject: [PATCH] Cleanup to make  remove_memory() arch neutral
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20080905181754.GA14258@elte.hu>
References: <20080905172132.GA11692@us.ibm.com>
	 <20080905174449.GC27395@elte.hu> <1220638478.25932.20.camel@badari-desktop>
	 <20080905181754.GA14258@elte.hu>
Content-Type: text/plain
Date: Mon, 08 Sep 2008 14:52:34 -0700
Message-Id: <1220910754.25932.57.camel@badari-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>Andrew Morton <akpm@linux-foundation.org>
Cc: Gary Hade <garyhade@us.ibm.com>, linux-mm@kvack.org, Yasunori Goto <y-goto@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, linux-kernel@vger.kernel.org, x86@kernel.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

There is nothing architecture specific about remove_memory().
remove_memory() function is common for all architectures which
support hotplug memory remove. Instead of duplicating it in every
architecture, collapse them into arch neutral function.

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>

 arch/ia64/mm/init.c   |   17 -----------------
 arch/powerpc/mm/mem.c |   17 -----------------
 arch/s390/mm/init.c   |   11 -----------
 mm/memory_hotplug.c   |   10 ++++++++++
 4 files changed, 10 insertions(+), 45 deletions(-)

Index: linux-2.6.27-rc5/arch/ia64/mm/init.c
===================================================================
--- linux-2.6.27-rc5.orig/arch/ia64/mm/init.c	2008-08-28 15:52:02.000000000 -0700
+++ linux-2.6.27-rc5/arch/ia64/mm/init.c	2008-09-08 12:38:59.000000000 -0700
@@ -701,23 +701,6 @@ int arch_add_memory(int nid, u64 start, 
 
 	return ret;
 }
-#ifdef CONFIG_MEMORY_HOTREMOVE
-int remove_memory(u64 start, u64 size)
-{
-	unsigned long start_pfn, end_pfn;
-	unsigned long timeout = 120 * HZ;
-	int ret;
-	start_pfn = start >> PAGE_SHIFT;
-	end_pfn = start_pfn + (size >> PAGE_SHIFT);
-	ret = offline_pages(start_pfn, end_pfn, timeout);
-	if (ret)
-		goto out;
-	/* we can free mem_map at this point */
-out:
-	return ret;
-}
-EXPORT_SYMBOL_GPL(remove_memory);
-#endif /* CONFIG_MEMORY_HOTREMOVE */
 #endif
 
 /*
Index: linux-2.6.27-rc5/arch/powerpc/mm/mem.c
===================================================================
--- linux-2.6.27-rc5.orig/arch/powerpc/mm/mem.c	2008-08-28 15:52:02.000000000 -0700
+++ linux-2.6.27-rc5/arch/powerpc/mm/mem.c	2008-09-08 12:39:19.000000000 -0700
@@ -135,23 +135,6 @@ int arch_add_memory(int nid, u64 start, 
 
 	return __add_pages(zone, start_pfn, nr_pages);
 }
-
-#ifdef CONFIG_MEMORY_HOTREMOVE
-int remove_memory(u64 start, u64 size)
-{
-	unsigned long start_pfn, end_pfn;
-	int ret;
-
-	start_pfn = start >> PAGE_SHIFT;
-	end_pfn = start_pfn + (size >> PAGE_SHIFT);
-	ret = offline_pages(start_pfn, end_pfn, 120 * HZ);
-	if (ret)
-		goto out;
-	/* Arch-specific calls go here - next patch */
-out:
-	return ret;
-}
-#endif /* CONFIG_MEMORY_HOTREMOVE */
 #endif /* CONFIG_MEMORY_HOTPLUG */
 
 /*
Index: linux-2.6.27-rc5/arch/s390/mm/init.c
===================================================================
--- linux-2.6.27-rc5.orig/arch/s390/mm/init.c	2008-08-28 15:52:02.000000000 -0700
+++ linux-2.6.27-rc5/arch/s390/mm/init.c	2008-09-08 12:40:41.000000000 -0700
@@ -189,14 +189,3 @@ int arch_add_memory(int nid, u64 start, 
 	return rc;
 }
 #endif /* CONFIG_MEMORY_HOTPLUG */
-
-#ifdef CONFIG_MEMORY_HOTREMOVE
-int remove_memory(u64 start, u64 size)
-{
-	unsigned long start_pfn, end_pfn;
-
-	start_pfn = PFN_DOWN(start);
-	end_pfn = start_pfn + PFN_DOWN(size);
-	return offline_pages(start_pfn, end_pfn, 120 * HZ);
-}
-#endif /* CONFIG_MEMORY_HOTREMOVE */
Index: linux-2.6.27-rc5/mm/memory_hotplug.c
===================================================================
--- linux-2.6.27-rc5.orig/mm/memory_hotplug.c	2008-08-28 15:52:02.000000000 -0700
+++ linux-2.6.27-rc5/mm/memory_hotplug.c	2008-09-08 12:41:37.000000000 -0700
@@ -26,6 +26,7 @@
 #include <linux/delay.h>
 #include <linux/migrate.h>
 #include <linux/page-isolation.h>
+#include <linux/pfn.h>
 
 #include <asm/tlbflush.h>
 
@@ -849,6 +850,15 @@ failed_removal:
 
 	return ret;
 }
+
+int remove_memory(u64 start, u64 size)
+{
+	unsigned long start_pfn, end_pfn;
+
+	start_pfn = PFN_DOWN(start);
+	end_pfn = start_pfn + PFN_DOWN(size);
+	return offline_pages(start_pfn, end_pfn, 120 * HZ);
+}
 #else
 int remove_memory(u64 start, u64 size)
 {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
