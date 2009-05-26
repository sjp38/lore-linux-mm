Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DD7D66B004F
	for <linux-mm@kvack.org>; Tue, 26 May 2009 10:23:42 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E94F882C36A
	for <linux-mm@kvack.org>; Tue, 26 May 2009 10:38:02 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id sybIgUtRgSks for <linux-mm@kvack.org>;
	Tue, 26 May 2009 10:38:02 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5DAB482C37D
	for <linux-mm@kvack.org>; Tue, 26 May 2009 10:37:49 -0400 (EDT)
Date: Tue, 26 May 2009 10:23:36 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] Warn if we run out of swap space
In-Reply-To: <20090526032934.GC9188@linux-sh.org>
Message-ID: <alpine.DEB.1.10.0905261022170.7242@gentwo.org>
References: <alpine.DEB.1.10.0905221454460.7673@qirst.com> <20090524144056.0849.A69D9226@jp.fujitsu.com> <4A1A057A.3080203@oracle.com> <20090526032934.GC9188@linux-sh.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Paul Mundt <lethal@linux-sh.org>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>


Subject: Warn if we run out of swap space

Running out of swap space means that the evicton of anonymous pages may no longer
be possible which can lead to OOM conditions.

Print a warning when swap space first becomes exhausted.
We do not use WARN_ON because that would perform a meaningless stack dump.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/swap.h |    1 +
 mm/swapfile.c        |    7 +++++++
 mm/vmscan.c          |    9 +++++++++
 3 files changed, 17 insertions(+)

Index: linux-2.6/mm/swapfile.c
===================================================================
--- linux-2.6.orig/mm/swapfile.c	2009-05-22 14:03:37.000000000 -0500
+++ linux-2.6/mm/swapfile.c	2009-05-26 09:11:52.000000000 -0500
@@ -374,6 +374,8 @@ no_page:
 	return 0;
 }

+int out_of_swap_message_printed = 0;
+
 swp_entry_t get_swap_page(void)
 {
 	struct swap_info_struct *si;
@@ -410,6 +412,11 @@ swp_entry_t get_swap_page(void)
 	}

 	nr_swap_pages++;
+	if (!out_of_swap_message_printed) {
+		out_of_swap_message_printed = 1;
+		printk(KERN_WARNING "All of swap is in use. Some pages "
+			"cannot be swapped out.\n");
+	}
 noswap:
 	spin_unlock(&swap_lock);
 	return (swp_entry_t) {0};
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2009-05-26 09:06:03.000000000 -0500
+++ linux-2.6/mm/vmscan.c	2009-05-26 09:20:30.000000000 -0500
@@ -1945,6 +1945,15 @@ out:
 		goto loop_again;
 	}

+	/*
+	 * If we had an out of swap condition but things have improved then
+	 * reset the flag so that we print the message again when we run
+	 * out of swap again.
+	 */
+#ifdef CONFIG_SWAP
+	if (out_of_swap_message_printed && !vm_swap_full())
+		out_of_swap_message_printed = 0;
+#endif
 	return sc.nr_reclaimed;
 }

Index: linux-2.6/include/linux/swap.h
===================================================================
--- linux-2.6.orig/include/linux/swap.h	2009-05-26 09:11:00.000000000 -0500
+++ linux-2.6/include/linux/swap.h	2009-05-26 09:11:38.000000000 -0500
@@ -163,6 +163,7 @@ struct swap_list_t {

 /* Swap 50% full? Release swapcache more aggressively.. */
 #define vm_swap_full() (nr_swap_pages*2 < total_swap_pages)
+extern int out_of_swap_message_printed;

 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
