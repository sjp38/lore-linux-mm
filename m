Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 357B06B0087
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 13:16:22 -0500 (EST)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0AI2wHx005671
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 11:02:58 -0700
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0AIGGcZ102300
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 11:16:16 -0700
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0AIGFo4011482
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 11:16:16 -0700
Message-ID: <4D2B4CEE.2050905@austin.ibm.com>
Date: Mon, 10 Jan 2011 12:16:14 -0600
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 4/4] Define memory_block_size_bytes for x86_64 with CONFIG_X86_UV
 defined
References: <4D2B4B38.80102@austin.ibm.com>
In-Reply-To: <4D2B4B38.80102@austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg KH <greg@kroah.com>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Robin Holt <holt@sgi.com>
List-ID: <linux-mm.kvack.org>

Define a version of memory_block_size_bytes for x86_64 when CONFIG_X86_UV is
set.

Signed-off-by: Robin Holt <holt@sgi.com>
Signed-off-by: Jack Steiner <steiner@sgi.com>
Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>

---
 arch/x86/mm/init_64.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

Index: linux-2.6/arch/x86/mm/init_64.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/init_64.c	2011-01-05 10:08:13.000000000 -0600
+++ linux-2.6/arch/x86/mm/init_64.c	2011-01-05 10:17:51.000000000 -0600
@@ -51,6 +51,7 @@
 #include <asm/numa.h>
 #include <asm/cacheflush.h>
 #include <asm/init.h>
+#include <asm/uv/uv.h>
 
 static int __init parse_direct_gbpages_off(char *arg)
 {
@@ -908,6 +909,19 @@ const char *arch_vma_name(struct vm_area
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
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
