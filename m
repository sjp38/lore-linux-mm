Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6E5EE6B004D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 04:39:21 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6G8dKTQ017351
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 16 Jul 2009 17:39:20 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D8B945DE4E
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 17:39:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FD7045DE4D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 17:39:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A1F51DB8037
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 17:39:20 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DA0B31DB803C
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 17:39:19 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 3/5]  Kill unnecessary prefetch
In-Reply-To: <20090716173449.9D4B.A69D9226@jp.fujitsu.com>
References: <20090716173449.9D4B.A69D9226@jp.fujitsu.com>
Message-Id: <20090716173848.9D51.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 16 Jul 2009 17:39:19 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Subject: Kill unnecessary prefetch

The pages in the list passed move_active_pages_to_lru() are
already touched by shrink_active_list(). IOW the prefetch in
move_active_pages_to_lru() don't populate any cache. it's pointless.

This patch remove it.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |    1 -
 1 file changed, 1 deletion(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1225,7 +1225,6 @@ static void move_active_pages_to_lru(str
 
 	while (!list_empty(list)) {
 		page = lru_to_page(list);
-		prefetchw_prev_lru_page(page, list, flags);
 
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
