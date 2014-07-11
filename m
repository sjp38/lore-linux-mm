Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 06DF9900002
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 04:18:35 -0400 (EDT)
Received: by mail-lb0-f181.google.com with SMTP id p9so582839lbv.40
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 01:18:35 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id ml6si3715380lbc.20.2014.07.11.01.18.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jul 2014 01:18:34 -0700 (PDT)
Subject: [PATCH] mm/page-writeback.c: fix divide by zero in bdi_dirty_limits
From: Maxim Patlasov <MPatlasov@parallels.com>
Date: Fri, 11 Jul 2014 12:18:27 +0400
Message-ID: <20140711081656.15654.19946.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: riel@redhat.com, linux-kernel@vger.kernel.org, mhocko@suse.cz, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, fengguang.wu@intel.com, jweiner@redhat.com

Under memory pressure, it is possible for dirty_thresh, calculated by
global_dirty_limits() in balance_dirty_pages(), to equal zero. Then, if
strictlimit is true, bdi_dirty_limits() tries to resolve the proportion:

  bdi_bg_thresh : bdi_thresh = background_thresh : dirty_thresh

by dividing by zero.

Signed-off-by: Maxim Patlasov <mpatlasov@parallels.com>
---
 mm/page-writeback.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 518e2c3..e0c9430 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1306,9 +1306,9 @@ static inline void bdi_dirty_limits(struct backing_dev_info *bdi,
 	*bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh);
 
 	if (bdi_bg_thresh)
-		*bdi_bg_thresh = div_u64((u64)*bdi_thresh *
-					 background_thresh,
-					 dirty_thresh);
+		*bdi_bg_thresh = dirty_thresh ? div_u64((u64)*bdi_thresh *
+							background_thresh,
+							dirty_thresh) : 0;
 
 	/*
 	 * In order to avoid the stacked BDI deadlock we need

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
