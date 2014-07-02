Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id B39546B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 20:12:34 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id u10so7279639lbd.8
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 17:12:33 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id p6si42141638lbw.8.2014.07.01.17.12.31
        for <linux-mm@kvack.org>;
        Tue, 01 Jul 2014 17:12:32 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 0/3] free reclaimed pages by paging out instantly
Date: Wed,  2 Jul 2014 09:13:46 +0900
Message-Id: <1404260029-11525-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>

Normally, I/O completed pages for reclaim would be rotated into
inactive LRU tail without freeing. The why it works is we can't free
page from atomic context(ie, end_page_writeback) due to vaious locks
isn't aware of atomic context.

So for reclaiming the I/O completed pages, we need one more iteration
of reclaim and it could make unnecessary aging as well as CPU overhead.

Long time ago, at the first trial, most concern was memcg locking
but recently, Johnannes tried amazing effort to make memcg lock simple
and got merged into mmotm so I coded up based on mmotm tree.
(Kudos to Johannes)

On 1G, 12 CPU kvm guest, build kernel 5 times and result was

allocstall
vanilla: records: 5 avg: 4733.80 std: 913.55(19.30%) max: 6442.00 min: 3719.00
improve: records: 5 avg: 1514.20 std: 441.69(29.17%) max: 1974.00 min: 863.00

pgrotated
vanilla: records: 5 avg: 873313.80 std: 40999.20(4.69%) max: 954722.00 min: 845903.00
improve: records: 5 avg: 28406.40 std: 3296.02(11.60%) max: 34552.00 min: 25047.00

Most of field in vmstat are not changed too much but things I can notice
is allocstall and pgrotated. We could save allocstall(ie, direct relcaim)
and pgrotated very much.

Welcome testing, review and any feedback!

* from v2 - 2014.06.20
  * Rebased on v3.16-rc2-mmotm-2014-06-25-16-44
  * Remove RFC tag

Minchan Kim (3):
  mm: Don't hide spin_lock in swap_info_get internal
  mm: Introduce atomic_remove_mapping
  mm: Free reclaimed pages indepdent of next reclaim

 include/linux/swap.h |  4 ++++
 mm/filemap.c         | 17 +++++++++-----
 mm/swap.c            | 21 ++++++++++++++++++
 mm/swapfile.c        | 17 ++++++++++++--
 mm/vmscan.c          | 63 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 114 insertions(+), 8 deletions(-)

-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
