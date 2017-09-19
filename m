Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E45836B0033
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 15:53:14 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y29so914197pff.6
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 12:53:14 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t137sor1187851pgb.211.2017.09.19.12.53.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Sep 2017 12:53:13 -0700 (PDT)
From: Jens Axboe <axboe@kernel.dk>
Subject: [PATCH 0/6] More graceful flusher thread memory reclaim wakeup
Date: Tue, 19 Sep 2017 13:53:01 -0600
Message-Id: <1505850787-18311-1-git-send-email-axboe@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: hannes@cmpxchg.org, clm@fb.com, jack@suse.cz

We've had some issues with writeback in presence of memory reclaim
at Facebook, and this patch set attempts to fix it up. The real
functional change is the last patch in the series, the first 5 are
prep and cleanup patches.

The basic idea is that we have callers that call
wakeup_flusher_threads() with nr_pages == 0. This means 'writeback
everything'. For memory reclaim situations, we can end up queuing
a TON of these kinds of writeback units. This can cause softlockups
and further memory issues, since we allocate huge amounts of
struct wb_writeback_work to handle this writeback. Handle this
situation more gracefully.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
