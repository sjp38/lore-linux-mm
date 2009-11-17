Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8155A6B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 02:17:54 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAH7HpPi030891
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 17 Nov 2009 16:17:52 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A87D345DE53
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:17:51 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B2E545DE52
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:17:51 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 508701DB8038
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:17:51 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id F1ED4E1800D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:17:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/7] mmc: Don't use PF_MEMALLOC
In-Reply-To: <20091117161551.3DD4.A69D9226@jp.fujitsu.com>
References: <20091117161551.3DD4.A69D9226@jp.fujitsu.com>
Message-Id: <20091117161711.3DDA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 17 Nov 2009 16:17:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mmc@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Non MM subsystem must not use PF_MEMALLOC. Memory reclaim need few
memory, anyone must not prevent it. Otherwise the system cause
mysterious hang-up and/or OOM Killer invokation.

Cc: linux-mmc@vger.kernel.org
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 drivers/mmc/card/queue.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/mmc/card/queue.c b/drivers/mmc/card/queue.c
index 49e5823..5deb996 100644
--- a/drivers/mmc/card/queue.c
+++ b/drivers/mmc/card/queue.c
@@ -46,8 +46,6 @@ static int mmc_queue_thread(void *d)
 	struct mmc_queue *mq = d;
 	struct request_queue *q = mq->queue;
 
-	current->flags |= PF_MEMALLOC;
-
 	down(&mq->thread_sem);
 	do {
 		struct request *req = NULL;
-- 
1.6.2.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
