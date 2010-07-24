Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E53626B02A9
	for <linux-mm@kvack.org>; Sat, 24 Jul 2010 04:46:27 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6O8kO04032712
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sat, 24 Jul 2010 17:46:24 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5BA9845DE4E
	for <linux-mm@kvack.org>; Sat, 24 Jul 2010 17:46:24 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A76445DE52
	for <linux-mm@kvack.org>; Sat, 24 Jul 2010 17:46:24 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C3EE1DB8040
	for <linux-mm@kvack.org>; Sat, 24 Jul 2010 17:46:24 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C873D1DB805D
	for <linux-mm@kvack.org>; Sat, 24 Jul 2010 17:46:23 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/2] vmscan: change shrink_slab() return tyep with void
In-Reply-To: <20100724174038.3C96.A69D9226@jp.fujitsu.com>
References: <20100722190100.GA22269@amd> <20100724174038.3C96.A69D9226@jp.fujitsu.com>
Message-Id: <20100724174455.3C9C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sat, 24 Jul 2010 17:46:23 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frank Mayhar <fmayhar@google.com>, John Stultz <johnstul@us.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Now, no caller use the return value of shrink_slab(). Thus we can change
it with void.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index bfa1975..89b593e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -277,24 +277,23 @@ EXPORT_SYMBOL(shrinker_do_scan);
  *
  * Returns the number of slab objects which we shrunk.
  */
-static unsigned long shrink_slab(struct zone *zone, unsigned long scanned, unsigned long total,
+static void shrink_slab(struct zone *zone, unsigned long scanned, unsigned long total,
 			unsigned long global, gfp_t gfp_mask)
 {
 	struct shrinker *shrinker;
-	unsigned long ret = 0;
 
 	if (scanned == 0)
 		scanned = SWAP_CLUSTER_MAX;
 
 	if (!down_read_trylock(&shrinker_rwsem))
-		return 1;	/* Assume we'll be able to shrink next time */
+		return;
 
 	list_for_each_entry(shrinker, &shrinker_list, list) {
 		(*shrinker->shrink)(shrinker, zone, scanned,
 					total, global, gfp_mask);
 	}
 	up_read(&shrinker_rwsem);
-	return ret;
+	return;
 }
 
 void shrink_all_slab(void)
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
