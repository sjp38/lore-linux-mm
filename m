Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 104F16B0071
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 10:37:48 -0500 (EST)
Received: by qgaj5 with SMTP id j5so124302qga.12
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 07:37:47 -0800 (PST)
Received: from mail-qc0-x22f.google.com (mail-qc0-x22f.google.com. [2607:f8b0:400d:c01::22f])
        by mx.google.com with ESMTPS id w1si3726869qap.45.2015.03.04.07.37.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Mar 2015 07:37:47 -0800 (PST)
Received: by qcvs11 with SMTP id s11so3774765qcv.6
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 07:37:46 -0800 (PST)
Date: Wed, 4 Mar 2015 10:37:43 -0500
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH block/for-4.0-fixes] writeback: add missing INITIAL_JIFFIES
 init in global_update_bandwidth()
Message-ID: <20150304153743.GH3122@htj.duckdns.org>
References: <20150304152243.GG3122@htj.duckdns.org>
 <20150304153050.GA1249@quack.suse.cz>
 <54F72567.3060406@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54F72567.3060406@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

Subject: writeback: add missing INITIAL_JIFFIES init in global_update_bandwidth()

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

Fixes: c42843f2f0bb ("writeback: introduce smoothed global dirty limit")
Signed-off-by: Tejun Heo <tj@kernel.org>
Acked-by: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: stable@vger.kernel.org
---
Added the "fixes" tag.  Jens, can you please route this one?

Thanks.

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
