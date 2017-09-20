Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8D3486B0033
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 05:01:51 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id a74so1901873oib.7
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 02:01:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g17si896216oth.380.2017.09.20.02.01.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Sep 2017 02:01:50 -0700 (PDT)
Date: Wed, 20 Sep 2017 11:01:47 +0200
From: Artem Savkov <asavkov@redhat.com>
Subject: MADV_FREE is broken
Message-ID: <20170920090147.5iqdkctmw7ujlmt3@shodan.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>, Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jan Stancek <jstancek@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi All,

We recently started noticing madvise09[1] test from ltp failing strangely. The
test does the following: maps 32 pages, sets MADV_FREE for the range it got,
dirties 2 of the pages, creates memory pressure and check that nondirty pages
are free. The test hanged while accessing the last 4 pages(29-32) of madvised
range at line 121 [2]. Any other process (gdb/cat) accessing those pages
would also hang as would rebooting the machine. It doesn't trigger any debug
warnings or kasan.

The issue bisected to "802a3a92ad7a mm: reclaim MADV_FREE pages" (so 4.12 and
up are affected).

I did some poking around and found out that the "bad" pages had SwapBacked flag
set in shrink_page_list() which confused it a lot. It looks like
mark_page_lazyfree() only calls lru_lazyfree_fn() when the pagevec is full
(that is in batches of 14) and never drains the rest (so last four in madvise09
case).

The patch below greatly reduces the failure rate, but doesn't fix it
completely, it still shows up with the same symptoms (hanging trying to access
last 4 pages) after a bunch of retries.

[1] https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/syscalls/madvise/madvise09.c
[2] https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/syscalls/madvise/madvise09.c#L121

diff --git a/mm/madvise.c b/mm/madvise.c
index 21261ff0466f..a0b868e8b7d2 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -453,6 +453,7 @@ static void madvise_free_page_range(struct mmu_gather *tlb,
 
 	tlb_start_vma(tlb, vma);
 	walk_page_range(addr, end, &free_walk);
+	lru_add_drain();
 	tlb_end_vma(tlb, vma);
 }
 

-- 
Regards,
  Artem

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
