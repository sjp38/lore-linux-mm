Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DA93F6B00A7
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 00:55:32 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1D5tUjI024873
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 13 Feb 2009 14:55:30 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 590F645DE54
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 14:55:30 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3596F45DE52
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 14:55:30 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BEE41DB805A
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 14:55:30 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C4A7D1DB803C
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 14:55:29 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] mm: adding comment why mark_page_accessed() would be better than pte_mkyoung() in follow_page()
Message-Id: <20090213145039.77C8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 13 Feb 2009 14:55:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


I and hugh discussed about mark_page_accessed() in follow_page() should be
change or not. and we agreed it isn't needed without adding comment.

==
At first look, mark_page_accessed() in follow_page() seems a bit strange.
it seems pte_mkyoung() would be better and to consist other kernel code.

However, it is intentionally. past commitlog said, 

    ------------------------------------------------
    commit 9e45f61d69be9024a2e6bef3831fb04d90fac7a8
    Author: akpm <akpm>
    Date:   Fri Aug 15 07:24:59 2003 +0000

    [PATCH] Use mark_page_accessed() in follow_page()

    Touching a page via follow_page() counts as a reference so we should be
    either setting the referenced bit in the pte or running mark_page_accessed().

    Altering the pte is tricky because we haven't implemented an atomic
    pte_mkyoung().  And mark_page_accessed() is better anyway because it has more
    aging state: it can move the page onto the active list.

    BKrev: 3f3c8acbplT8FbwBVGtth7QmnqWkIw
    ------------------------------------------------

The atomic issue is still true nowadays. adding comment help to understand 
code intention and it would be better.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <npiggin@suse.de>
---
 mm/memory.c |    5 +++++
 1 file changed, 5 insertions(+)

Index: b/mm/memory.c
===================================================================
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1151,6 +1151,11 @@ struct page *follow_page(struct vm_area_
 		if ((flags & FOLL_WRITE) &&
 		    !pte_dirty(pte) && !PageDirty(page))
 			set_page_dirty(page);
+		/*
+		 * pte_mkyoung() would be more correct here, but atomic care
+		 * is needed to avoid losing dirty bit: easier to
+		 * mark_page_accessed().
+		 */
 		mark_page_accessed(page);
 	}
 unlock:


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
