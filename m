Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3B89A6B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 10:22:47 -0500 (EST)
Received: by mail-qa0-f45.google.com with SMTP id x12so2731264qac.4
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 07:22:46 -0800 (PST)
Received: from mail-qg0-x236.google.com (mail-qg0-x236.google.com. [2607:f8b0:400d:c04::236])
        by mx.google.com with ESMTPS id e65si1950945qkh.30.2015.03.04.07.22.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Mar 2015 07:22:46 -0800 (PST)
Received: by qgaj5 with SMTP id j5so38352qga.12
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 07:22:46 -0800 (PST)
Date: Wed, 4 Mar 2015 10:22:43 -0500
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH block/for-4.0-fixes] writeback: add missing INITIAL_JIFFIES
 init in global_update_bandwidth()
Message-ID: <20150304152243.GG3122@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

global_update_bandwidth() uses static variable update_time as the
timestamp for the last update but forgets to initialize it to
INITIALIZE_JIFFIES.

This means that global_dirty_limit will be 5 mins into the future on
32bit and some large amount jiffies into the past on 64bit.  This
isn't critical as the only effect is that global_dirty_limit won't be
updated for the first 5 mins after booting on 32bit machines,
especially given the auxiliary nature of global_dirty_limit's role -
protecting against global dirty threshold's sudden dips; however, it
does lead to unintended suboptimal behavior.  Fix it.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: stable@vger.kernel.org
---
 mm/page-writeback.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -922,7 +922,7 @@ static void global_update_bandwidth(unsi
 				    unsigned long now)
 {
 	static DEFINE_SPINLOCK(dirty_lock);
-	static unsigned long update_time;
+	static unsigned long update_time = INITIAL_JIFFIES;
 
 	/*
 	 * check locklessly first to optimize away locking for the most time

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
