Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id AE4276B0005
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 07:25:05 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id o12-v6so3173968pls.20
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 04:25:05 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id z13-v6si5131001pfc.118.2018.08.03.04.25.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 04:25:04 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH] mm/vmscan: adjust shrinkctl->nr_scanned after invoking scan_objects
Date: Fri,  3 Aug 2018 18:56:49 +0800
Message-Id: <1533293809-34354-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, mst@redhat.com
Cc: wei.w.wang@intel.com

Some shrinkers may free more than the requested nr_to_scan of pages
in one invocation of scan_objects, and some may free less than that.

Currently shrinkers can either return the actual number of pages that
have been freed via the return value of scan_objects or track that
actual number in shrinkctl->nr_scanned. But do_shrink_slab works on an
assumption that the actual number is always tracked via
shrinkctl->nr_scanned, which is not true. Having checked the shrinkers
used in the kernel, they basically return the actual number of freed
pages via the return value of scan_objects, and most of them leave
shrinkctl->nr_scanned unchanged after scan_objects is called.

So this patch adjusts shrinkctl->nr_scanned to the actual freed number
after scan_objects is called.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Michael S. Tsirkin <mst@redhat.com>
---
 mm/vmscan.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 03822f8..78a75b9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -447,9 +447,13 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 		if (ret == SHRINK_STOP)
 			break;
 		freed += ret;
+		shrinkctl->nr_scanned = ret;
 
 		count_vm_events(SLABS_SCANNED, shrinkctl->nr_scanned);
-		total_scan -= shrinkctl->nr_scanned;
+		if (total_scan > shrinkctl->nr_scanned)
+			total_scan -= shrinkctl->nr_scanned;
+		else
+			total_scan = 0;
 		scanned += shrinkctl->nr_scanned;
 
 		cond_resched();
-- 
2.7.4
