Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 097CD6B13F0
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 08:23:17 -0500 (EST)
Received: by dadv6 with SMTP id v6so3396081dad.14
        for <linux-mm@kvack.org>; Fri, 03 Feb 2012 05:23:17 -0800 (PST)
From: Amit Sahrawat <amit.sahrawat83@gmail.com>
Subject: [PATCH 2/2] mm: make do_writepages() use plugging
Date: Fri,  3 Feb 2012 18:57:06 +0530
Message-Id: <1328275626-5322-1-git-send-email-amit.sahrawat83@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Johannes Weiner <jweiner@redhat.com>
Cc: Amit Sahrawat <a.sahrawat@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Amit Sahrawat <amit.sahrawat83@gmail.com>

This will cover all the invocations for writepages to be called with
plugging support.

Signed-off-by: Amit Sahrawat <a.sahrawat@samsung.com>
---
 mm/page-writeback.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 363ba70..2bea32c 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1866,14 +1866,18 @@ EXPORT_SYMBOL(generic_writepages);
 
 int do_writepages(struct address_space *mapping, struct writeback_control *wbc)
 {
+	struct blk_plug plug;
 	int ret;
 
 	if (wbc->nr_to_write <= 0)
 		return 0;
+
+	blk_start_plug(&plug);
 	if (mapping->a_ops->writepages)
 		ret = mapping->a_ops->writepages(mapping, wbc);
 	else
 		ret = generic_writepages(mapping, wbc);
+	blk_finish_plug(&plug);
 	return ret;
 }
 
-- 
1.7.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
