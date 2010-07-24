Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 37AEE6B02A5
	for <linux-mm@kvack.org>; Sat, 24 Jul 2010 04:44:53 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6O8ioCD006458
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sat, 24 Jul 2010 17:44:51 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AB10045DE4F
	for <linux-mm@kvack.org>; Sat, 24 Jul 2010 17:44:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 89F7F45DE4E
	for <linux-mm@kvack.org>; Sat, 24 Jul 2010 17:44:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 718DA1DB803A
	for <linux-mm@kvack.org>; Sat, 24 Jul 2010 17:44:50 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3115E1DB8038
	for <linux-mm@kvack.org>; Sat, 24 Jul 2010 17:44:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/2] vmscan: shrink_all_slab() use reclaim_state instead the return value of shrink_slab()
In-Reply-To: <20100724174038.3C96.A69D9226@jp.fujitsu.com>
References: <20100722190100.GA22269@amd> <20100724174038.3C96.A69D9226@jp.fujitsu.com>
Message-Id: <20100724174405.3C99.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sat, 24 Jul 2010 17:44:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frank Mayhar <fmayhar@google.com>, John Stultz <johnstul@us.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Now, shrink_slab() doesn't return number of reclaimed objects. IOW,
current shrink_all_slab() is broken. Thus instead we use reclaim_state
to detect no reclaimable slab objects.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   20 +++++++++-----------
 1 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d7256e0..bfa1975 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -300,18 +300,16 @@ static unsigned long shrink_slab(struct zone *zone, unsigned long scanned, unsig
 void shrink_all_slab(void)
 {
 	struct zone *zone;
-	unsigned long nr;
+	struct reclaim_state reclaim_state;
 
-again:
-	nr = 0;
-	for_each_zone(zone)
-		nr += shrink_slab(zone, 1, 1, 1, GFP_KERNEL);
-	/*
-	 * If we reclaimed less than 10 objects, might as well call
-	 * it a day. Nothing special about the number 10.
-	 */
-	if (nr >= 10)
-		goto again;
+	current->reclaim_state = &reclaim_state;
+	do {
+		reclaim_state.reclaimed_slab = 0;
+		for_each_zone(zone)
+			shrink_slab(zone, 1, 1, 1, GFP_KERNEL);
+	} while (reclaim_state.reclaimed_slab);
+
+	current->reclaim_state = NULL;
 }
 
 static inline int is_page_cache_freeable(struct page *page)
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
