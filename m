Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id EA7BC6B0047
	for <linux-mm@kvack.org>; Fri,  1 Oct 2010 14:37:14 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o91IZ2UI027341
	for <linux-mm@kvack.org>; Fri, 1 Oct 2010 12:35:02 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o91Ib8Nh155898
	for <linux-mm@kvack.org>; Fri, 1 Oct 2010 12:37:08 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o91Ib7aE022448
	for <linux-mm@kvack.org>; Fri, 1 Oct 2010 12:37:07 -0600
Message-ID: <4CA62A51.70807@austin.ibm.com>
Date: Fri, 01 Oct 2010 13:37:05 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 8/9] v3 Define memory_block_size_bytes for x86_64 with CONFIG_X86_UV
 set
References: <4CA62700.7010809@austin.ibm.com>
In-Reply-To: <4CA62700.7010809@austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org
Cc: Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Robin Holt <holt@sgi.com>, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

Define a version of memory_block_size_bytes for x86_64 when CONFIG_X86_UV is
set.

Signed-off-by: Robin Holt <holt@sgi.com>
Signed-off-by: Jack Steiner <steiner@sgi.com>

---
 arch/x86/mm/init_64.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

Index: linux-next/arch/x86/mm/init_64.c
===================================================================
--- linux-next.orig/arch/x86/mm/init_64.c	2010-09-29 14:56:25.000000000 -0500
+++ linux-next/arch/x86/mm/init_64.c	2010-10-01 13:00:50.000000000 -0500
@@ -51,6 +51,7 @@
 #include <asm/numa.h>
 #include <asm/cacheflush.h>
 #include <asm/init.h>
+#include <asm/uv/uv.h>
 #include <linux/bootmem.h>
 
 static int __init parse_direct_gbpages_off(char *arg)
@@ -902,6 +903,19 @@
 	return NULL;
 }
 
+#ifdef CONFIG_X86_UV
+#define MIN_MEMORY_BLOCK_SIZE   (1 << SECTION_SIZE_BITS)
+
+unsigned long memory_block_size_bytes(void)
+{
+	if (is_uv_system()) {
+		printk(KERN_INFO "UV: memory block size 2GB\n");
+		return 2UL * 1024 * 1024 * 1024;
+	}
+	return MIN_MEMORY_BLOCK_SIZE;
+}
+#endif
+
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 /*
  * Initialise the sparsemem vmemmap using huge-pages at the PMD level.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
