Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 26FA36B004F
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 01:28:20 -0500 (EST)
Date: Wed, 14 Jan 2009 07:28:16 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: fix assertion
Message-ID: <20090114062816.GA15671@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

(I ran into this when debugging the lockless pagecache barrier problem btw)

--

This assertion is incorrect for lockless pagecache. By definition if we have an
unpinned page that we are trying to take a speculative reference to, it may
become the tail of a compound page at any time (if it is freed, then reallocated
as a compound page).

It was still a valid assertion for the vmscan.c LRU isolation case, but it
doesn't seem incredibly helpful... if somebody wants it, they can put it back
directly where it applies in the vmscan code.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h	2009-01-05 14:53:29.000000000 +1100
+++ linux-2.6/include/linux/mm.h	2009-01-05 14:53:54.000000000 +1100
@@ -270,7 +270,6 @@ static inline int put_page_testzero(stru
  */
 static inline int get_page_unless_zero(struct page *page)
 {
-	VM_BUG_ON(PageTail(page));
 	return atomic_inc_not_zero(&page->_count);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
