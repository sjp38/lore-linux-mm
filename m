Date: Mon, 13 Sep 2004 20:38:35 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: [PATCH] shrink per_cpu_pages to fit 32byte cacheline 
Message-ID: <20040913233835.GA23894@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, "Martin J. Bligh" <mbligh@aracnet.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Subject says it all, the following patch shrinks per_cpu_pages
struct from 24 to 16bytes, that makes the per CPU array containing
hot and cold "per_cpu_pages[2]" fit on 32byte cacheline. This structure
is often used so I bet this is a useful optimization.

The counters never reach 2 ^ 16 (the maximum "batch" can get is 64).

Please apply

--- linux-2.6.9-rc1-mm4/include/linux/mmzone.h.orig	2004-09-09 18:42:32.000000000 -0300
+++ linux-2.6.9-rc1-mm4/include/linux/mmzone.h	2004-09-13 13:41:55.589436224 -0300
@@ -43,10 +43,10 @@
 #endif
 
 struct per_cpu_pages {
-	int count;		/* number of pages in the list */
-	int low;		/* low watermark, refill needed */
-	int high;		/* high watermark, emptying needed */
-	int batch;		/* chunk size for buddy add/remove */
+	short int count;		/* number of pages in the list */
+	short int low;		/* low watermark, refill needed */
+	short int high;		/* high watermark, emptying needed */
+	short int batch;		/* chunk size for buddy add/remove */
 	struct list_head list;	/* the list of pages */
 };
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
