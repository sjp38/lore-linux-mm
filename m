Received: from westrelay04.boulder.ibm.com (westrelay04.boulder.ibm.com [9.17.193.32])
	by e32.co.us.ibm.com (8.12.10/8.12.2) with ESMTP id i3NIUrnU727924
	for <linux-mm@kvack.org>; Fri, 23 Apr 2004 14:30:53 -0400
Received: from [9.47.17.128] (d03av02.boulder.ibm.com [9.17.193.82])
	by westrelay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id i3NIUqP3183648
	for <linux-mm@kvack.org>; Fri, 23 Apr 2004 12:30:53 -0600
Subject: PageReserved increment patch
From: Bradley Christiansen <bradc1@us.ibm.com>
Content-Type: text/plain
Message-Id: <1082745080.1854.30.camel@DYN318078BLD.beaverton.ibm.com>
Mime-Version: 1.0
Date: Fri, 23 Apr 2004 11:31:21 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here is a short patch that addresses a problem I found where page->count
gets incremented for all pages in page_cache_get/get_page, but in
put_page it is only decremented for non reserved pages.  

I noticed this problem while trying to keep track of how memory is
allocated and noticing that the zero page count variable was continually
being incremented but never decremented.  This created some very large
counts on the zero page, and while this probably wont hurt anything it
just doesn't seem like its right.

This patch only fixes the problem I know of with the zero page, and
there is still a potential imbalance for any reserved page calling
page_cache_get/get_page.

Brad



--- linux-2.6.4/mm/memory.c     Wed Mar 10 18:55:26 2004
+++ linux-2.6.4-brad/mm/memory.c        Thu Apr 22 16:00:38 2004
@@ -1050,7 +1050,9 @@
        /*
         * Ok, we need to copy. Oh, well..
         */
-       page_cache_get(old_page);
+       if (!PageReserved(old_page))
+               page_cache_get(old_page);
+
        spin_unlock(&mm->page_table_lock);
  
        pte_chain = pte_chain_alloc(GFP_KERNEL);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
