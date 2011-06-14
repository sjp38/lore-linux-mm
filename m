Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id EDA1E900117
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 20:59:17 -0400 (EDT)
Subject: [PATCH 2/2] powerpc/mm: Fix memory_block_size_bytes() for
 non-pseries
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 14 Jun 2011 10:57:51 +1000
Message-ID: <1308013071.2874.785.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

Just compiling pseries in the kernel causes it to override
memory_block_size_bytes() regardless of what is the runtime
platform.

This cleans up the implementation of that function, fixing
a bug or two while at it, so that it's harmless (and potentially
useful) for other platforms. Without this, bugs in that code
would trigger a WARN_ON() in drivers/base/memory.c when
booting some different platforms. 

If/when we have another platform supporting memory hotplug we
might want to either move that out to a generic place or
make it a ppc_md. callback.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

diff --git a/arch/powerpc/platforms/pseries/hotplug-memory.c b/arch/powerpc/platforms/pseries/hotplug-memory.c
index 33867ec..9d6a8ef 100644
--- a/arch/powerpc/platforms/pseries/hotplug-memory.c
+++ b/arch/powerpc/platforms/pseries/hotplug-memory.c
@@ -12,6 +12,8 @@
 #include <linux/of.h>
 #include <linux/memblock.h>
 #include <linux/vmalloc.h>
+#include <linux/memory.h>
+
 #include <asm/firmware.h>
 #include <asm/machdep.h>
 #include <asm/pSeries_reconfig.h>
@@ -20,24 +22,25 @@
 static unsigned long get_memblock_size(void)
 {
 	struct device_node *np;
-	unsigned int memblock_size = 0;
+	unsigned int memblock_size = MIN_MEMORY_BLOCK_SIZE;
+	struct resource r;
 
 	np = of_find_node_by_path("/ibm,dynamic-reconfiguration-memory");
 	if (np) {
-		const unsigned long *size;
+		const __be64 *size;
 
 		size = of_get_property(np, "ibm,lmb-size", NULL);
-		memblock_size = size ? *size : 0;
-
+		if (size)
+			memblock_size = be64_to_cpup(size);
 		of_node_put(np);
-	} else {
+	} else  if (machine_is(pseries)) {
+		/* This fallback really only applies to pseries */
 		unsigned int memzero_size = 0;
-		const unsigned int *regs;
 
 		np = of_find_node_by_path("/memory@0");
 		if (np) {
-			regs = of_get_property(np, "reg", NULL);
-			memzero_size = regs ? regs[3] : 0;
+			if (!of_address_to_resource(np, 0, &r))
+				memzero_size = resource_size(&r);
 			of_node_put(np);
 		}
 
@@ -50,16 +53,21 @@ static unsigned long get_memblock_size(void)
 			sprintf(buf, "/memory@%x", memzero_size);
 			np = of_find_node_by_path(buf);
 			if (np) {
-				regs = of_get_property(np, "reg", NULL);
-				memblock_size = regs ? regs[3] : 0;
+				if (!of_address_to_resource(np, 0, &r))
+					memblock_size = resource_size(&r);
 				of_node_put(np);
 			}
 		}
 	}
-
 	return memblock_size;
 }
 
+/* WARNING: This is going to override the generic definition whenever
+ * pseries is built-in regardless of what platform is active at boot
+ * time. This is fine for now as this is the only "option" and it
+ * should work everywhere. If not, we'll have to turn this into a
+ * ppc_md. callback
+ */
 unsigned long memory_block_size_bytes(void)
 {
 	return get_memblock_size();


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
