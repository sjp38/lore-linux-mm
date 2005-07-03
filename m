Date: Sun, 3 Jul 2005 17:57:23 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: [PATCH] print order information when OOM killing
Message-ID: <20050703205723.GB21166@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, linux-mm@kvack.org, Nick Piggin <piggin@cyberone.com.au>
List-ID: <linux-mm.kvack.org>

Subject says it all.

Description: Dump the current allocation order when OOM killing.

--- linux-2.6.11.orig/mm/page_alloc.c	2005-03-02 04:38:34.000000000 -0300
+++ linux-2.6.11/mm/page_alloc.c	2005-07-03 11:27:42.000000000 -0300
@@ -819,7 +819,7 @@
 				goto got_pg;
 		}
 
-		out_of_memory(gfp_mask);
+		out_of_memory(gfp_mask, order);
 		goto restart;
 	}
 
--- linux-2.6.11.orig/mm/oom_kill.c	2005-03-02 04:38:09.000000000 -0300
+++ linux-2.6.11/mm/oom_kill.c	2005-07-03 11:31:30.000000000 -0300
@@ -253,7 +253,7 @@
  * OR try to be smart about which process to kill. Note that we
  * don't have to be perfect here, we just have to be good.
  */
-void out_of_memory(int gfp_mask)
+void out_of_memory(int gfp_mask, int order)
 {
 	struct mm_struct *mm = NULL;
 	task_t * p;
@@ -272,7 +272,7 @@
 		panic("Out of memory and no killable processes...\n");
 	}
 
-	printk("oom-killer: gfp_mask=0x%x\n", gfp_mask);
+	printk("oom-killer: gfp_mask=0x%x order=%d\n", gfp_mask, order);
 	show_free_areas();
 	mm = oom_kill_process(p);
 	if (!mm)
--- linux-2.6.11.orig/include/linux/swap.h	2005-03-02 04:37:45.000000000 -0300
+++ linux-2.6.11/include/linux/swap.h	2005-07-03 11:28:19.000000000 -0300
@@ -148,7 +148,7 @@
 #define vm_swap_full() (nr_swap_pages*2 < total_swap_pages)
 
 /* linux/mm/oom_kill.c */
-extern void out_of_memory(int gfp_mask);
+extern void out_of_memory(int gfp_mask, int order);
 
 /* linux/mm/memory.c */
 extern void swapin_readahead(swp_entry_t, unsigned long, struct vm_area_struct *);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
