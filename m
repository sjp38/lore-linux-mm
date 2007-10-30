Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9UIFlZj017164
	for <linux-mm@kvack.org>; Tue, 30 Oct 2007 14:15:47 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9UIFhMu100210
	for <linux-mm@kvack.org>; Tue, 30 Oct 2007 12:15:44 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9UIFhGt018118
	for <linux-mm@kvack.org>; Tue, 30 Oct 2007 12:15:43 -0600
Subject: [RFC] hotplug memory remove - walk_memory_resource for ppc64
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <18178.52359.953289.638736@cargo.ozlabs.ibm.com>
References: <1191346196.6106.20.camel@dyn9047017100.beaverton.ibm.com>
	 <18178.52359.953289.638736@cargo.ozlabs.ibm.com>
Content-Type: text/plain
Date: Tue, 30 Oct 2007 11:19:11 -0800
Message-Id: <1193771951.8904.22.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mackerras <paulus@samba.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linuxppc-dev@ozlabs.org, linux-mm <linux-mm@kvack.org>, anton@au1.ibm.com
List-ID: <linux-mm.kvack.org>

Hi KAME,

As I mentioned while ago, ppc64 does not export information about
"system RAM" in /proc/iomem. Looking at the code and usage
scenerios I am not sure what its really serving. Could you 
explain what its purpose & how the range can be invalid ?

At least on ppc64, all the memory ranges we get passed comes from
/sysfs memblock information and they are guaranteed to match 
device-tree entries. On ppc64, each 16MB chunk has a /sysfs entry
and it will be part of the /proc/device-tree entry. Since we do
"online" or "offline" to /sysfs entries to add/remove pages - 
these ranges are guaranteed to be valid.

Since this check is redundant for ppc64, I propose following patch.
Is this acceptable ? If some one really really wants, I can code
up this to walk lmb or /proc/device-tree and verify the range &
adjust the entries for overlap (I don't see how that can happen).

Paul & Kame, please comment.

Thanks,
Badari

---
 arch/powerpc/Kconfig  |    3 +++
 arch/powerpc/mm/mem.c |   13 +++++++++++++
 kernel/resource.c     |    2 +-
 3 files changed, 17 insertions(+), 1 deletion(-)

Index: linux-2.6.24-rc1/arch/powerpc/mm/mem.c
===================================================================
--- linux-2.6.24-rc1.orig/arch/powerpc/mm/mem.c	2007-10-30 07:39:16.000000000 -0800
+++ linux-2.6.24-rc1/arch/powerpc/mm/mem.c	2007-10-30 10:05:09.000000000 -0800
@@ -129,6 +129,19 @@ int __devinit arch_add_memory(int nid, u
 	return __add_pages(zone, start_pfn, nr_pages);
 }
 
+/*
+ * I don't think we really need to do anything here to validate the memory
+ * range or walk the memory resource in lmb or device-tree. Only way we get
+ * the memory range here is through /sysfs in 16MB chunks and we are guaranteed
+ * to have a corresponding device-tree entry.
+ */
+int
+walk_memory_resource(unsigned long start_pfn, unsigned long nr_pages, void *arg,
+			int (*func)(unsigned long, unsigned long, void *))
+{
+	return  (*func)(start_pfn, nr_pages, arg);
+}
+
 #endif /* CONFIG_MEMORY_HOTPLUG */
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
Index: linux-2.6.24-rc1/kernel/resource.c
===================================================================
--- linux-2.6.24-rc1.orig/kernel/resource.c	2007-10-23 20:50:57.000000000 -0700
+++ linux-2.6.24-rc1/kernel/resource.c	2007-10-30 08:58:41.000000000 -0800
@@ -228,7 +228,7 @@ int release_resource(struct resource *ol
 
 EXPORT_SYMBOL(release_resource);
 
-#ifdef CONFIG_MEMORY_HOTPLUG
+#if defined(CONFIG_MEMORY_HOTPLUG) && !defined(CONFIG_ARCH_HAS_WALK_MEMORY)
 /*
  * Finds the lowest memory reosurce exists within [res->start.res->end)
  * the caller must specify res->start, res->end, res->flags.
Index: linux-2.6.24-rc1/arch/powerpc/Kconfig
===================================================================
--- linux-2.6.24-rc1.orig/arch/powerpc/Kconfig	2007-10-30 07:39:17.000000000 -0800
+++ linux-2.6.24-rc1/arch/powerpc/Kconfig	2007-10-30 08:54:57.000000000 -0800
@@ -234,6 +234,9 @@ config HOTPLUG_CPU
 config ARCH_ENABLE_MEMORY_HOTPLUG
 	def_bool y
 
+config ARCH_HAS_WALK_MEMORY
+	def_bool y
+
 config ARCH_ENABLE_MEMORY_HOTREMOVE
 	def_bool y
 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
