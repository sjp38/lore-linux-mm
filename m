Date: Tue, 10 Feb 2004 14:23:01 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] skip offline CPUs in show_free_areas
Message-ID: <20040210132301.GA11045@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Without this ouput on a box with 8cpus and NR_CPUS=64 looks rather
strange.


Index: mm/page_alloc.c
===================================================================
RCS file: /home/cvs/linux/mm/page_alloc.c,v
retrieving revision 1.113
diff -u -p -r1.113 page_alloc.c
--- mm/page_alloc.c	10 Jan 2004 04:59:57 -0000	1.113
+++ mm/page_alloc.c	10 Feb 2004 13:17:43 -0000
@@ -972,7 +972,13 @@ void show_free_areas(void)
 			printk("\n");
 
 		for (cpu = 0; cpu < NR_CPUS; ++cpu) {
-			struct per_cpu_pageset *pageset = zone->pageset + cpu;
+			struct per_cpu_pageset *pageset;
+	
+			if (!cpu_online(cpu))
+				continue;
+
+			pageset = zone->pageset + cpu;
+
 			for (temperature = 0; temperature < 2; temperature++)
 				printk("cpu %d %s: low %d, high %d, batch %d\n",
 					cpu,
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
