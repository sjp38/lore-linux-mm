Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D44996B01F5
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 00:15:18 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3F4FCIb032451
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 15 Apr 2010 13:15:12 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F4C245DE4E
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:15:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F40245DE4D
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:15:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 07317E08005
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:15:12 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B0132E08003
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:15:11 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 4/4] vmscan: delegate page cleaning io to flusher thread if VM pressure is low
In-Reply-To: <20100415130212.D16E.A69D9226@jp.fujitsu.com>
References: <20100415013436.GO2493@dastard> <20100415130212.D16E.A69D9226@jp.fujitsu.com>
Message-Id: <20100415131420.D17D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu, 15 Apr 2010 13:15:11 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Dave Chinner <david@fromorbit.com>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Even if pageout() is called from direct reclaim, we can delegate io to
flusher thread if vm pressure is low.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8b78b49..eab6028 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -623,6 +623,13 @@ static enum page_references page_check_references(struct page *page,
 	if (current_is_kswapd())
 		return PAGEREF_RECLAIM_CLEAN;
 
+	/*
+	 * Now VM pressure is not so high. then we can delegate
+	 * page cleaning to flusher thread safely.
+	 */
+	if (!sc->order && sc->priority > DEF_PRIORITY/2)
+		return PAGEREF_RECLAIM_CLEAN;
+
 	return PAGEREF_RECLAIM;
 }
 
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
