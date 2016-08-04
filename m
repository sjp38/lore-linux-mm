Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5FAB06B025F
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 14:36:12 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id k135so139036955lfb.2
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 11:36:12 -0700 (PDT)
Received: from forwardcorp1j.cmail.yandex.net (forwardcorp1j.cmail.yandex.net. [2a02:6b8:0:1630::180])
        by mx.google.com with ESMTPS id d65si6192509lfg.399.2016.08.04.11.36.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 11:36:10 -0700 (PDT)
Subject: [PATCH RFC] mm,
 writeback: flush plugged IO in wakeup_flusher_threads()
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Thu, 04 Aug 2016 21:36:05 +0300
Message-ID: <147033576532.682609.2277943215598867297.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Jens Axboe <axboe@kernel.dk>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, linux-raid@vger.kernel.org, Dave Chinner <dchinner@redhat.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@kernel.org>

I've found funny live-lock between raid10 barriers during resync and memory
controller hard limits. Inside mpage_readpages() task holds on its plug bio
which blocks barrier in raid10. Its memory cgroup have no free memory thus
task goes into reclaimer but all reclaimable pages are dirty and cannot be
written because raid10 is rebuilding and stuck on barrier.

Common flush of such IO in schedule() never happens because machine where
that happened has a lot of free cpus and task never goes sleep.

Lock is 'live' because changing memory limit or killing tasks which holds
that stuck bio unblock whole progress.

That was happened in 3.18.x but I see no difference in upstream logic.
Theoretically this might happen even without memory cgroup.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 fs/fs-writeback.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 56c8fda436c0..ed58863cdb5d 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1948,6 +1948,12 @@ void wakeup_flusher_threads(long nr_pages, enum wb_reason reason)
 {
 	struct backing_dev_info *bdi;
 
+	/*
+	 * If we are expecting writeback progress we must submit plugged IO.
+	 */
+	if (blk_needs_flush_plug(current))
+		blk_schedule_flush_plug(current);
+
 	if (!nr_pages)
 		nr_pages = get_nr_dirty_pages();
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
