Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8CB9D620113
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 09:35:08 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o73DevSq032101
	for <linux-mm@kvack.org>; Tue, 3 Aug 2010 09:40:57 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o73DhQKW2236528
	for <linux-mm@kvack.org>; Tue, 3 Aug 2010 09:43:26 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o73DhPBv029184
	for <linux-mm@kvack.org>; Tue, 3 Aug 2010 10:43:25 -0300
Message-ID: <4C581CFB.6010306@austin.ibm.com>
Date: Tue, 03 Aug 2010 08:43:23 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 8/9] v4  Define memory_block_size_bytes() for ppc/pseries
References: <4C581A6D.9030908@austin.ibm.com>
In-Reply-To: <4C581A6D.9030908@austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
Cc: Greg KH <greg@kroah.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Define a version of memory_block_size_bytes() for powerpc/pseries such that
a memory block spans an entire lmb.

Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>
---
 arch/powerpc/platforms/pseries/hotplug-memory.c |   66 +++++++++++++++++++-----
 1 file changed, 53 insertions(+), 13 deletions(-)

Index: linux-2.6/arch/powerpc/platforms/pseries/hotplug-memory.c
===================================================================
--- linux-2.6.orig/arch/powerpc/platforms/pseries/hotplug-memory.c	2010-08-02 13:57:03.000000000 -0500
+++ linux-2.6/arch/powerpc/platforms/pseries/hotplug-memory.c	2010-08-02 14:09:52.000000000 -0500
@@ -17,6 +17,54 @@
 #include <asm/pSeries_reconfig.h>
 #include <asm/sparsemem.h>
 
+static u32 get_memblock_size(void)
+{
+	struct device_node *np;
+	unsigned int memblock_size = 0;
+
+	np = of_find_node_by_path("/ibm,dynamic-reconfiguration-memory");
+	if (np) {
+		const unsigned long *size;
+
+		size = of_get_property(np, "ibm,lmb-size", NULL);
+		memblock_size = size ? *size : 0;
+
+		of_node_put(np);
+	} else {
+		unsigned int memzero_size = 0;
+		const unsigned int *regs;
+
+		np = of_find_node_by_path("/memory@0");
+		if (np) {
+			regs = of_get_property(np, "reg", NULL);
+			memzero_size = regs ? regs[3] : 0;
+			of_node_put(np);
+		}
+
+		if (memzero_size) {
+			/* We now know the size of memory@0, use this to find
+			 * the first memoryblock and get its size.
+			 */
+			char buf[64];
+
+			sprintf(buf, "/memory@%x", memzero_size);
+			np = of_find_node_by_path(buf);
+			if (np) {
+				regs = of_get_property(np, "reg", NULL);
+				memblock_size = regs ? regs[3] : 0;
+				of_node_put(np);
+			}
+		}
+	}
+
+	return memblock_size;
+}
+
+u32 memory_block_size_bytes(void)
+{
+	return get_memblock_size();
+}
+
 static int pseries_remove_memblock(unsigned long base, unsigned int memblock_size)
 {
 	unsigned long start, start_pfn;
@@ -127,30 +175,22 @@ static int pseries_add_memory(struct dev
 
 static int pseries_drconf_memory(unsigned long *base, unsigned int action)
 {
-	struct device_node *np;
-	const unsigned long *lmb_size;
+	unsigned long memblock_size;
 	int rc;
 
-	np = of_find_node_by_path("/ibm,dynamic-reconfiguration-memory");
-	if (!np)
+	memblock_size = get_memblock_size();
+	if (!memblock_size)
 		return -EINVAL;
 
-	lmb_size = of_get_property(np, "ibm,lmb-size", NULL);
-	if (!lmb_size) {
-		of_node_put(np);
-		return -EINVAL;
-	}
-
 	if (action == PSERIES_DRCONF_MEM_ADD) {
-		rc = memblock_add(*base, *lmb_size);
+		rc = memblock_add(*base, memblock_size);
 		rc = (rc < 0) ? -EINVAL : 0;
 	} else if (action == PSERIES_DRCONF_MEM_REMOVE) {
-		rc = pseries_remove_memblock(*base, *lmb_size);
+		rc = pseries_remove_memblock(*base, memblock_size);
 	} else {
 		rc = -EINVAL;
 	}
 
-	of_node_put(np);
 	return rc;
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
