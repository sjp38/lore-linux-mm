Received: from westrelay01.boulder.ibm.com (westrelay01.boulder.ibm.com [9.17.195.10])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id i9LLFfEx197612
	for <linux-mm@kvack.org>; Thu, 21 Oct 2004 17:15:41 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay01.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id i9LLFePA152748
	for <linux-mm@kvack.org>; Thu, 21 Oct 2004 15:15:40 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id i9LLFevO013238
	for <linux-mm@kvack.org>; Thu, 21 Oct 2004 15:15:40 -0600
Subject: [PATCH] zap_pte_range should not mark non-uptodate pages dirty
From: Dave Kleikamp <shaggy@austin.ibm.com>
Content-Type: text/plain
Message-Id: <1098393346.7157.112.camel@localhost>
Mime-Version: 1.0
Date: Thu, 21 Oct 2004 16:15:46 -0500
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Andrea Arcangeli <andrea@novell.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

zap_pte_range should not mark non-uptodate pages dirty

Doing O_DIRECT writes to an mmapped file caused pages in the page cache to
be marked dirty but not uptodate.  This led to a bug in mpage_writepage.

Signed-off-by: Dave Kleikamp <shaggy@austin.ibm.com>
Signed-off-by: Andrea Arcangeli <andrea@novell.com>

diff -urp linux-2.6.9/mm/memory.c linux/mm/memory.c
--- linux-2.6.9/mm/memory.c	2004-10-21 10:49:26.598031488 -0500
+++ linux/mm/memory.c	2004-10-21 16:01:44.902376232 -0500
@@ -414,7 +414,15 @@ static void zap_pte_range(struct mmu_gat
 			    && linear_page_index(details->nonlinear_vma,
 					address+offset) != page->index)
 				set_pte(ptep, pgoff_to_pte(page->index));
-			if (pte_dirty(pte))
+			/*
+			 * PG_uptodate can be cleared by
+			 * invalidate_inode_pages2, so we must not try to write
+			 * not uptodate pages.  Otherwise we risk invalidating
+			 * underlying O_DIRECT writes, and secondly because
+			 * pdflush would BUG().  Coherency of mmaps against
+			 * O_DIRECT still cannot be guaranteed though.
+			 */
+			if (pte_dirty(pte) && PageUptodate(page))
 				set_page_dirty(page);
 			if (pte_young(pte) && !PageAnon(page))
 				mark_page_accessed(page);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
