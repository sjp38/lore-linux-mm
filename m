Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id BBE1A6B028E
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 13:13:57 -0400 (EDT)
Received: by mail-lb0-f171.google.com with SMTP id u8so170699732lbk.0
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 10:13:57 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id g130si14397990wma.19.2016.04.04.10.13.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Apr 2016 10:13:56 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 0/3] mm: support bigger cache workingsets and protect against writes
Date: Mon,  4 Apr 2016 13:13:35 -0400
Message-Id: <1459790018-6630-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Freund <andres@anarazel.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Hi,

this is a follow-up to http://www.spinics.net/lists/linux-mm/msg101739.html
where Andres reported his database workingset being pushed out by the
minimum size enforcement of the inactive file list - currently 50% of cache
- as well as repeatedly written file pages that are never actually read.

Two changes fell out of the discussions. The first change observes that
pages that are only ever written don't benefit from caching beyond what the
writeback cache does for partial page writes, and so we shouldn't promote
them to the active file list where they compete with pages whose cached data
is actually accessed repeatedly. This change comes in two patches - one for
in-cache write accesses and one for refaults triggered by writes, neither of
which should promote a cache page.

Second, with the refault detection we don't need to set 50% of the cache
aside for used-once cache anymore since we can detect frequently used pages
even when they are evicted between accesses. We can allow the active list to
be bigger and thus protect a bigger workingset that isn't challenged by
streamers. Depending on the access patterns, this can increase major faults
during workingset transitions for better performance during stable phases.

Andres, I tried reproducing your postgres scenario, but I could never get
the WAL to interfere even with wal_log = hot_standby mode. It's a 8G
machine, I set shared_buffers = 2GB, ran pgbench -i -s 290, and then -c 32
-j 32 -M prepared -t 150000. Any input on how to trigger the thrashing you
observed would be appreciated. But it would be great if you could test these
patches on your known-problematic setup as well.

Thanks!

 include/linux/memcontrol.h |  25 -----------
 mm/filemap.c               |   8 +++-
 mm/page_alloc.c            |  44 ------------------
 mm/vmscan.c                | 104 +++++++++++++++++--------------------------
 4 files changed, 48 insertions(+), 133 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
