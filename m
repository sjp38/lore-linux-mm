Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BF69D6B004D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 03:56:44 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n92865Rx025264
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 2 Oct 2009 17:06:05 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id F2DD845DE51
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 17:06:04 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D845745DE4E
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 17:06:04 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id BC3C71DB803E
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 17:06:04 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 75C541DB8037
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 17:06:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] congestion_wait() don't use WRITE
Message-Id: <20091002170343.5F67.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  2 Oct 2009 17:06:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Jens Axboe <jens.axboe@oracle.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


commit 8aa7e847d (Fix congestion_wait() sync/async vs read/write confusion)
replace WRITE with BLK_RW_ASYNC.
Unfortunately, concurrent mm development made the unchanged place
accidentally.

This patch fixes it too.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4a7b0d5..e4a915b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1088,7 +1088,7 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 	int lumpy_reclaim = 0;
 
 	while (unlikely(too_many_isolated(zone, file, sc))) {
-		congestion_wait(WRITE, HZ/10);
+		congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 		/* We are about to die and free our memory. Return now. */
 		if (fatal_signal_pending(current))
-- 
1.6.0.GIT



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
