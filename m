Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C76F96B003D
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 07:33:36 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1BCXY0K006484
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 11 Feb 2009 21:33:34 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 726E145DD74
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 21:33:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5370645DD72
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 21:33:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 557581DB803E
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 21:33:34 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F26E1DB803A
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 21:33:34 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/2] mm: don't mark_page_accessed() in do_swap_page()
Message-Id: <20090211213201.C3CA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 11 Feb 2009 21:33:33 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


commit bf3f3bc5e734706730c12a323f9b2068052aa1f0 (mm: don't mark_page_accessed
in fault path) only remove the mark_page_accessed() in filemap_fault().

Therefore, swap-backed page and file-backed page have inconsistency behavior now.
mark_page_accessed() should be removed from do_swap_page().


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Nick Piggin <npiggin@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>
---
 mm/memory.c |    2 --
 1 file changed, 2 deletions(-)

Index: b/mm/memory.c
===================================================================
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2440,8 +2440,6 @@ static int do_swap_page(struct mm_struct
 		count_vm_event(PGMAJFAULT);
 	}
 
-	mark_page_accessed(page);
-
 	lock_page(page);
 	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
