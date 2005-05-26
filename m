Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j4QH0LT2018431
	for <linux-mm@kvack.org>; Thu, 26 May 2005 13:00:21 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4QH0KZi122108
	for <linux-mm@kvack.org>; Thu, 26 May 2005 13:00:21 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j4QH0KOg016245
	for <linux-mm@kvack.org>; Thu, 26 May 2005 13:00:20 -0400
Message-ID: <42959095.1030706@us.ibm.com>
Date: Thu, 26 May 2005 02:02:13 -0700
From: Janet Morgan <janetmor@us.ibm.com>
MIME-Version: 1.0
Subject: [PATCH] add OOM debug
Content-Type: multipart/mixed;
 boundary="------------020609090806030304050901"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: davej@redhat.com
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------020609090806030304050901
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch provides more debug info when the system is OOM.   It displays
memory stats (basically sysrq-m info) from __alloc_pages() when page 
allocation
fails and during OOM kill.

Thanks to Dave Jones for coming up with the idea.


--------------020609090806030304050901
Content-Type: text/plain;
 name="showmem.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="showmem.patch"

Signed-off-by:  Janet Morgan <janetmor@us.ibm.com>

--- linux-2.6.12-rc5/mm/oom_kill.c	2005-05-24 20:31:20.000000000 -0700
+++ showmem/mm/oom_kill.c	2005-05-25 11:27:33.000000000 -0700
@@ -258,6 +258,10 @@ void out_of_memory(unsigned int __nocast
 	struct mm_struct *mm = NULL;
 	task_t * p;
 
+	printk("oom-killer: gfp_mask=0x%x\n", gfp_mask);
+	/* print memory stats */
+	show_mem();
+
 	read_lock(&tasklist_lock);
 retry:
 	p = select_bad_process();
@@ -268,12 +272,9 @@ retry:
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!p) {
 		read_unlock(&tasklist_lock);
-		show_free_areas();
 		panic("Out of memory and no killable processes...\n");
 	}
 
-	printk("oom-killer: gfp_mask=0x%x\n", gfp_mask);
-	show_free_areas();
 	mm = oom_kill_process(p);
 	if (!mm)
 		goto retry;
--- linux-2.6.12-rc5/mm/page_alloc.c	2005-05-24 20:31:20.000000000 -0700
+++ showmem/mm/page_alloc.c	2005-05-25 11:25:19.000000000 -0700
@@ -905,6 +905,7 @@ nopage:
 			" order:%d, mode:0x%x\n",
 			p->comm, order, gfp_mask);
 		dump_stack();
+		show_mem();
 	}
 	return NULL;
 got_pg:

--------------020609090806030304050901--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
