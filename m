Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9VFk6lH012312
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 11:46:06 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9VFk6ba119212
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 09:46:06 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9VFk5u2027315
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 09:46:06 -0600
Subject: [PATCH 1/3] Add remove_memory() for ppc64
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: text/plain
Date: Wed, 31 Oct 2007 08:49:35 -0800
Message-Id: <1193849375.17412.34.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linuxppc-dev@ozlabs.org, anton@au1.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Supply arch specific remove_memory() for PPC64. There is nothing
ppc specific code here and its exactly same as ia64 version. 
For now, lets keep it arch specific - so each arch can add
its own special things if needed.

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
---
 arch/powerpc/mm/mem.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

Index: linux-2.6.23/arch/powerpc/mm/mem.c
===================================================================
--- linux-2.6.23.orig/arch/powerpc/mm/mem.c	2007-10-25 11:34:54.000000000 -0700
+++ linux-2.6.23/arch/powerpc/mm/mem.c	2007-10-25 11:35:24.000000000 -0700
@@ -131,6 +131,20 @@ int __devinit arch_add_memory(int nid, u
 
 #endif /* CONFIG_MEMORY_HOTPLUG */
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
+int remove_memory(u64 start, u64 size)
+{
+	unsigned long start_pfn, end_pfn;
+	unsigned long timeout = 120 * HZ;
+	int ret;
+	start_pfn = start >> PAGE_SHIFT;
+	end_pfn = start_pfn + (size >> PAGE_SHIFT);
+	ret = offline_pages(start_pfn, end_pfn, timeout);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(remove_memory);
+#endif /* CONFIG_MEMORY_HOTREMOVE */
+
 void show_mem(void)
 {
 	unsigned long total = 0, reserved = 0;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
