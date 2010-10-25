Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4BF168D0015
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 02:43:08 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9P6h5i2019492
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 25 Oct 2010 15:43:05 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7EE6145DE4F
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 15:43:05 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6274245DE4E
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 15:43:05 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 458501DB8013
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 15:43:05 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 03226E38002
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 15:43:05 +0900 (JST)
Date: Mon, 25 Oct 2010 15:37:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] fix is_mem_section_removable() page_order BUG_ON
 check.
Message-Id: <20101025153726.2ae9baec.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, fengguang.wu@intel.com, Mel Gorman <mel@csn.ul.ie>"akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

I wonder this should be for stable tree...but want to hear opinions before.
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

page_order() is called by memory hotplug's user interface to check 
the section is removable or not. (is_mem_section_removable())

It calls page_order() withoug holding zone->lock.
So, even if the caller does

	if (PageBuddy(page))
		ret = page_order(page) ...
The caller may hit BUG_ON().

For fixing this, there are 2 choices.
  1. add zone->lock.
  2. remove BUG_ON().

is_mem_section_removable() is used for some "advice" and doesn't need
to be 100% accurate. This is_removable() can be called via user program..
We don't want to take this important lock for long by user's request.
So, this patch removes BUG_ON().

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/internal.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: mmotm-1024/mm/internal.h
===================================================================
--- mmotm-1024.orig/mm/internal.h
+++ mmotm-1024/mm/internal.h
@@ -62,7 +62,7 @@ extern bool is_free_buddy_page(struct pa
  */
 static inline unsigned long page_order(struct page *page)
 {
-	VM_BUG_ON(!PageBuddy(page));
+	/* PageBuddy() must be checked by the caller */
 	return page_private(page);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
