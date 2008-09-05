Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m85HM8Yx030901
	for <linux-mm@kvack.org>; Fri, 5 Sep 2008 13:22:08 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m85HLl5e093442
	for <linux-mm@kvack.org>; Fri, 5 Sep 2008 13:21:47 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m85HLfjW025048
	for <linux-mm@kvack.org>; Fri, 5 Sep 2008 13:21:46 -0400
Date: Fri, 5 Sep 2008 10:21:32 -0700
From: Gary Hade <garyhade@us.ibm.com>
Subject: [PATCH] [RESEND] x86_64: add memory hotremove config option
Message-ID: <20080905172132.GA11692@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, Gary Hade <garyhade@us.ibm.com>, linux-kernel@vger.kernel.org, x86@kernel.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Resending with linux-kernel@vger.kernel.org and x86@kernel.org copied
this time.  No changes other than this and modified Subject line.  The
only response so far on linux-mm has been an Acked-by: from 
Yasunori Goto <y-goto@jp.fujitsu.com>


Add memory hotremove config option to x86_64

Memory hotremove functionality can currently be configured into
the ia64, powerpc, and s390 kernels.  This patch makes it possible
to configure the memory hotremove functionality into the x86_64
kernel as well. 

Signed-off-by: Gary Hade <garyhade@us.ibm.com>

---
 arch/x86/Kconfig      |    3 +++
 arch/x86/mm/init_64.c |   18 ++++++++++++++++++
 2 files changed, 21 insertions(+)

Index: linux-2.6.27-rc5/arch/x86/Kconfig
===================================================================
--- linux-2.6.27-rc5.orig/arch/x86/Kconfig	2008-09-03 13:33:59.000000000 -0700
+++ linux-2.6.27-rc5/arch/x86/Kconfig	2008-09-03 13:34:55.000000000 -0700
@@ -1384,6 +1384,9 @@
 	def_bool y
 	depends on X86_64 || (X86_32 && HIGHMEM)

+config ARCH_ENABLE_MEMORY_HOTREMOVE
+	def_bool y
+
 config HAVE_ARCH_EARLY_PFN_TO_NID
 	def_bool X86_64
 	depends on NUMA
Index: linux-2.6.27-rc5/arch/x86/mm/init_64.c
===================================================================
--- linux-2.6.27-rc5.orig/arch/x86/mm/init_64.c	2008-09-03 13:34:08.000000000 -0700
+++ linux-2.6.27-rc5/arch/x86/mm/init_64.c	2008-09-03 13:34:55.000000000 -0700
@@ -740,6 +740,24 @@
 EXPORT_SYMBOL_GPL(memory_add_physaddr_to_nid);
 #endif

+#ifdef CONFIG_MEMORY_HOTREMOVE
+int remove_memory(u64 start, u64 size)
+{
+	unsigned long start_pfn, end_pfn;
+	unsigned long timeout = 120 * HZ;
+	int ret;
+	start_pfn = start >> PAGE_SHIFT;
+	end_pfn = start_pfn + (size >> PAGE_SHIFT);
+	ret = offline_pages(start_pfn, end_pfn, timeout);
+	if (ret)
+		goto out;
+	/* Arch-specific calls go here */
+out:
+	return ret;
+}
+EXPORT_SYMBOL_GPL(remove_memory);
+#endif /* CONFIG_MEMORY_HOTREMOVE */
+
 #endif /* CONFIG_MEMORY_HOTPLUG */

 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
