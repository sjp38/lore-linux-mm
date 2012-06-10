Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id F13E06B005C
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 00:20:54 -0400 (EDT)
Received: by dakp5 with SMTP id p5so4884340dak.14
        for <linux-mm@kvack.org>; Sat, 09 Jun 2012 21:20:54 -0700 (PDT)
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: [PATCH] page-writeback.c: fix update bandwidth time judgment error
Date: Sun, 10 Jun 2012 12:20:05 +0800
Message-Id: <1339302005-366-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, Gavin Shan <shangw@linux.vnet.ibm.com>, Wanpeng Li <liwp.linux@gmail.com>, Wanpeng Li <liwp@linux.vnet.ibm.com>

From: Wanpneg Li <liwp@linux.vnet.ibm.com>

Since bdi_update_bandwidth function  should estimate write bandwidth at 200ms intervals,
so the time is bdi->bw_time_stamp + BANDWIDTH_INTERVAL == jiffies, but
if use time_is_after_eq_jiffies intervals will be bdi->bw_time_stamp +
BANDWIDTH_INTERVAL + 1.

Signed-off-by: Wanpeng Li <liwp@linux.vnet.ibm.com>
---
 mm/page-writeback.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index c833bf0..099e225 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1032,7 +1032,7 @@ static void bdi_update_bandwidth(struct backing_dev_info *bdi,
 				 unsigned long bdi_dirty,
 				 unsigned long start_time)
 {
-	if (time_is_after_eq_jiffies(bdi->bw_time_stamp + BANDWIDTH_INTERVAL))
+	if (time_is_after_jiffies(bdi->bw_time_stamp + BANDWIDTH_INTERVAL))
 		return;
 	spin_lock(&bdi->wb.list_lock);
 	__bdi_update_bandwidth(bdi, thresh, bg_thresh, dirty,
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
