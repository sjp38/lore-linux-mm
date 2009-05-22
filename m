Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E88326B0055
	for <linux-mm@kvack.org>; Fri, 22 May 2009 14:57:42 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4147282C7F6
	for <linux-mm@kvack.org>; Fri, 22 May 2009 15:12:12 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id nad-LXoUiiE4 for <linux-mm@kvack.org>;
	Fri, 22 May 2009 15:12:12 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D58D282C802
	for <linux-mm@kvack.org>; Fri, 22 May 2009 15:12:05 -0400 (EDT)
Date: Fri, 22 May 2009 14:58:19 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [PATCH] Warn if we run out of swap space
Message-ID: <alpine.DEB.1.10.0905221454460.7673@qirst.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>


Subject: Warn if we run out of swap space

Running out of swap space means that the evicton of anonymous pages may no longer
be possible which can lead to OOM conditions.

Print a warning when swap space first becomes exhausted.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/swapfile.c |    5 +++++
 1 file changed, 5 insertions(+)

Index: linux-2.6/mm/swapfile.c
===================================================================
--- linux-2.6.orig/mm/swapfile.c	2009-05-22 12:25:19.000000000 -0500
+++ linux-2.6/mm/swapfile.c	2009-05-22 13:56:10.000000000 -0500
@@ -380,6 +380,7 @@ swp_entry_t get_swap_page(void)
 	pgoff_t offset;
 	int type, next;
 	int wrapped = 0;
+	static int printed = 0;

 	spin_lock(&swap_lock);
 	if (nr_swap_pages <= 0)
@@ -410,6 +411,10 @@ swp_entry_t get_swap_page(void)
 	}

 	nr_swap_pages++;
+	if (!printed) {
+		printed = 1;
+		printk(KERN_WARNING "All of swap is in use. Some pages cannot be swapped out.");
+	}
 noswap:
 	spin_unlock(&swap_lock);
 	return (swp_entry_t) {0};

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
