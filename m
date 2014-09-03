Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 61D1A6B0038
	for <linux-mm@kvack.org>; Wed,  3 Sep 2014 03:49:03 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fb1so16730891pad.27
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 00:48:59 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id kf7si9484851pbc.153.2014.09.03.00.48.32
        for <linux-mm@kvack.org>;
        Wed, 03 Sep 2014 00:48:33 -0700 (PDT)
From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] mm: Use min3/max3 macros to avoid shadow warnings
Date: Wed,  3 Sep 2014 00:48:17 -0700
Message-Id: <1409730497-25438-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Mark Rustad <mark.d.rustad@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>

From: Mark Rustad <mark.d.rustad@intel.com>

Nested calls to min/max functions result in shadow warnings in
W=2 builds. Avoid the warning by using the min3 and max3 macros
to get the min/max of 3 values instead of nested calls.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 mm/page-writeback.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 91d73ef..35ca710 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1075,13 +1075,13 @@ static void bdi_update_dirty_ratelimit(struct backing_dev_info *bdi,
 	}
 
 	if (dirty < setpoint) {
-		x = min(bdi->balanced_dirty_ratelimit,
-			 min(balanced_dirty_ratelimit, task_ratelimit));
+		x = min3(bdi->balanced_dirty_ratelimit,
+			 balanced_dirty_ratelimit, task_ratelimit);
 		if (dirty_ratelimit < x)
 			step = x - dirty_ratelimit;
 	} else {
-		x = max(bdi->balanced_dirty_ratelimit,
-			 max(balanced_dirty_ratelimit, task_ratelimit));
+		x = max3(bdi->balanced_dirty_ratelimit,
+			 balanced_dirty_ratelimit, task_ratelimit);
 		if (dirty_ratelimit > x)
 			step = dirty_ratelimit - x;
 	}
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
