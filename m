Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id E86856B025F
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 11:33:17 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id f72so4787003ioj.7
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 08:33:17 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b10sor2013963itc.5.2017.09.20.08.33.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 08:33:15 -0700 (PDT)
From: Jens Axboe <axboe@kernel.dk>
Subject: [PATCH 0/7 v2] More graceful flusher thread memory reclaim wakeup
Date: Wed, 20 Sep 2017 09:32:55 -0600
Message-Id: <1505921582-26709-1-git-send-email-axboe@kernel.dk>
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

Changes since v1:

- Rename WB_zero_pages to WB_start_all (Amir).
- Remove a test_bit() for a condition where we always expect the bit
  to be set.
- Remove 'nr_pages' from the wakeup flusher threads helpers, since
  everybody now passes in zero. Enables further cleanups in later
  patches too (Jan).
- Fix a case where I forgot to clear WB_start_all if 'work' allocation
  failed.
- Get rid of cond_resched() in the wb_do_writeback() loop.

-- 
Jens Axboe


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
