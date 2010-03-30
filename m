Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A7EFF6B01F9
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 03:31:19 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2U7VgKg031849
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 30 Mar 2010 16:31:43 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2CEF545DE51
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 16:31:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0AF7945DE4F
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 16:31:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E8576E38007
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 16:31:41 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9ADEDE38001
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 16:31:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
In-Reply-To: <20100330065358.GA24828@sli10-desk.sh.intel.com>
References: <20100330153750.8EA2.A69D9226@jp.fujitsu.com> <20100330065358.GA24828@sli10-desk.sh.intel.com>
Message-Id: <20100330160820.8EA8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 30 Mar 2010 16:31:40 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Wu, Fengguang" <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

> > > > Very unfortunately, this patch isn't acceptable. In past time, vmscan 
> > > > had similar logic, but 1% swap-out made lots bug reports. 
> > > can you elaborate this?
> > > Completely restore previous behavior (do full scan with priority 0) is
> > > ok too.
> > 
> > This is a option. but we need to know the root cause anyway.
> I thought I mentioned the root cause in first mail. My debug shows
> recent_rotated[0] is big, but recent_rotated[1] is almost zero, which makes
> percent[0] 0. But you can double check too.

To revert can save percent[0]==0 && priority==0 case. but it shouldn't
happen, I think. It mean to happen big latency issue.

Can you please try following patch? Also, I'll prepare reproduce environment soon.



---
 mm/vmscan.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 79c8098..abf7f79 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1571,15 +1571,19 @@ static void get_scan_ratio(struct zone *zone, struct scan_control *sc,
 	 */
 	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
 		spin_lock_irq(&zone->lru_lock);
-		reclaim_stat->recent_scanned[0] /= 2;
-		reclaim_stat->recent_rotated[0] /= 2;
+		while (reclaim_stat->recent_scanned[0] > anon / 4) {
+			reclaim_stat->recent_scanned[0] /= 2;
+			reclaim_stat->recent_rotated[0] /= 2;
+		}
 		spin_unlock_irq(&zone->lru_lock);
 	}
 
 	if (unlikely(reclaim_stat->recent_scanned[1] > file / 4)) {
 		spin_lock_irq(&zone->lru_lock);
-		reclaim_stat->recent_scanned[1] /= 2;
-		reclaim_stat->recent_rotated[1] /= 2;
+		while (reclaim_stat->recent_scanned[1] > file / 4) {
+			reclaim_stat->recent_scanned[1] /= 2;
+			reclaim_stat->recent_rotated[1] /= 2;
+		}
 		spin_unlock_irq(&zone->lru_lock);
 	}
 
-- 
1.6.5.2





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
