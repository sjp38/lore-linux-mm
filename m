Date: Tue, 22 May 2007 16:08:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [Patch] memory unplug v3 [4/4] ia64 interface
Message-Id: <20070522160813.99323080.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070522155824.563f5873.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070522155824.563f5873.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Add call for offline_pages() to ia64.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: devel-2.6.22-rc1-mm1/arch/ia64/mm/init.c
===================================================================
--- devel-2.6.22-rc1-mm1.orig/arch/ia64/mm/init.c	2007-05-22 14:30:38.000000000 +0900
+++ devel-2.6.22-rc1-mm1/arch/ia64/mm/init.c	2007-05-22 15:12:31.000000000 +0900
@@ -724,7 +724,17 @@
 
 int remove_memory(u64 start, u64 size)
 {
-	return -EINVAL;
+	unsigned long start_pfn, end_pfn;
+	unsigned long timeout = 120 * HZ;
+	int ret;
+	start_pfn = start >> PAGE_SHIFT;
+	end_pfn = start_pfn + (size >> PAGE_SHIFT);
+	ret = offline_pages(start_pfn, end_pfn, timeout);
+	if (ret)
+		goto out;
+	/* we can free mem_map at this point */
+out:
+	return ret;
 }
 EXPORT_SYMBOL_GPL(remove_memory);
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
