Date: Sat, 16 Dec 2006 17:03:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Fix sparsemem on Cell
Message-Id: <20061216170353.2dfa27b1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20061215114536.dc5c93af.akpm@osdl.org>
References: <20061215165335.61D9F775@localhost.localdomain>
	<4582D756.7090702@shadowen.org>
	<1166203440.8105.22.camel@localhost.localdomain>
	<20061215114536.dc5c93af.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: haveblue@us.ibm.com, apw@shadowen.org, cbe-oss-dev@ozlabs.org, linuxppc-dev@ozlabs.org, linux-mm@kvack.org, mkravetz@us.ibm.com, hch@infradead.org, jk@ozlabs.org, linux-kernel@vger.kernel.org, paulus@samba.org, benh@kernel.crashing.org, gone@us.ibm.com, kmannth@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Fri, 15 Dec 2006 11:45:36 -0800
Andrew Morton <akpm@osdl.org> wrote:

> Perhaps if the function's role in the world was commented it would be clearer.
> 

How about patch like this ? (this one is not tested.)
Already-exisiting-more-generic-flag is available ?
 
-Kame
==
 include/linux/memory_hotplug.h |    8 ++++++++
 mm/memory_hotplug.c            |   14 ++++++++++++++
 mm/page_alloc.c                |   11 +++++++----
 3 files changed, 29 insertions(+), 4 deletions(-)

Index: linux-2.6.20-rc1-mm1/include/linux/memory_hotplug.h
===================================================================
--- linux-2.6.20-rc1-mm1.orig/include/linux/memory_hotplug.h	2006-11-30 06:57:37.000000000 +0900
+++ linux-2.6.20-rc1-mm1/include/linux/memory_hotplug.h	2006-12-16 16:42:40.000000000 +0900
@@ -133,6 +133,10 @@
 #endif /* CONFIG_NUMA */
 #endif /* CONFIG_HAVE_ARCH_NODEDATA_EXTENSION */
 
+extern int under_memory_hotadd(void);
+
+
+
 #else /* ! CONFIG_MEMORY_HOTPLUG */
 /*
  * Stub functions for when hotplug is off
@@ -159,6 +163,10 @@
 	dump_stack();
 	return -ENOSYS;
 }
+static inline int under_memory_hotadd()
+{
+	return 0;
+}
 
 #endif /* ! CONFIG_MEMORY_HOTPLUG */
 static inline int __remove_pages(struct zone *zone, unsigned long start_pfn,
Index: linux-2.6.20-rc1-mm1/mm/memory_hotplug.c
===================================================================
--- linux-2.6.20-rc1-mm1.orig/mm/memory_hotplug.c	2006-12-16 14:24:10.000000000 +0900
+++ linux-2.6.20-rc1-mm1/mm/memory_hotplug.c	2006-12-16 16:51:08.000000000 +0900
@@ -26,6 +26,17 @@
 
 #include <asm/tlbflush.h>
 
+/*
+ * Because memory hotplug shares some codes for initilization with boot,
+ * we sometimes have to check what we are doing ?
+ */
+static atomic_t memory_hotadd_count;
+
+int under_memory_hotadd(void)
+{
+	return atomic_read(&memory_hotadd_count);
+}
+
 /* add this memory to iomem resource */
 static struct resource *register_memory_resource(u64 start, u64 size)
 {
@@ -273,10 +284,13 @@
 		if (ret)
 			goto error;
 	}
+	atomic_inc(&memory_hotadd_count);
 
 	/* call arch's memory hotadd */
 	ret = arch_add_memory(nid, start, size);
 
+	atomic_dec(&memory_hotadd_count);
+
 	if (ret < 0)
 		goto error;
 
Index: linux-2.6.20-rc1-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.20-rc1-mm1.orig/mm/page_alloc.c	2006-12-16 14:24:38.000000000 +0900
+++ linux-2.6.20-rc1-mm1/mm/page_alloc.c	2006-12-16 16:53:02.000000000 +0900
@@ -2069,10 +2069,13 @@
 	unsigned long pfn;
 
 	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
-		if (!early_pfn_valid(pfn))
-			continue;
-		if (!early_pfn_in_nid(pfn, nid))
-			continue;
+		if (!under_memory_hotadd()) {
+			/* we are in boot */
+			if (!early_pfn_valid(pfn))
+				continue;
+			if (!early_pfn_in_nid(pfn, nid))
+				continue;
+		}
 		page = pfn_to_page(pfn);
 		set_page_links(page, zone, nid, pfn);
 		init_page_count(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
