Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E9ECA6B0047
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 21:37:53 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o811boIC015434
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Sep 2010 10:37:51 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BC34B45DE4E
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 10:37:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 94EB145DE51
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 10:37:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 61FCC1DB8038
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 10:37:50 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E3329E08001
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 10:37:49 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] vmscan,tmpfs: treat used once pages on tmpfs as used once
Message-Id: <20100901103653.974C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  1 Sep 2010 10:37:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

When a page has PG_referenced, shrink_page_list() discard it only
if it is no dirty. This rule works completely fine if the backend
filesystem is regular one. PG_dirty is good signal that it was used
recently because flusher thread clean pages periodically. In addition,
page writeback is costly rather than simple page discard.

However, When a page is on tmpfs, this heuristic don't works because
flusher thread don't writeback tmpfs pages. then, tmpfs pages always
rotate lru twice at least and it makes unnecessary lru churn. Merely
tmpfs streaming io shouldn't cause large anonymous page swap-out.

This patch remove this unncessary reclaim bonus of tmpfs pages.

Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1919d8a..aba3402 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -617,7 +617,7 @@ static enum page_references page_check_references(struct page *page,
 	}
 
 	/* Reclaim if clean, defer dirty pages to writeback */
-	if (referenced_page)
+	if (referenced_page && !PageSwapBacked(page))
 		return PAGEREF_RECLAIM_CLEAN;
 
 	return PAGEREF_RECLAIM;
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
