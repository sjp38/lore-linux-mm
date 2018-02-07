Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 496C16B02CB
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 02:00:46 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id t64so2592772pfi.13
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 23:00:46 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id s66si563044pgc.481.2018.02.06.23.00.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Feb 2018 23:00:45 -0800 (PST)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v2] mm, swap, frontswap: Fix THP swap if frontswap enabled
Date: Wed,  7 Feb 2018 15:00:35 +0800
Message-Id: <20180207070035.30302-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <huang.ying.caritas@gmail.com>, "Huang, Ying" <ying.huang@intel.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Minchan Kim <minchan@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Shakeel Butt <shakeelb@google.com>, stable@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

From: Huang Ying <huang.ying.caritas@gmail.com>

It was reported by Sergey Senozhatsky that if THP (Transparent Huge
Page) and frontswap (via zswap) are both enabled, when memory goes low
so that swap is triggered, segfault and memory corruption will occur
in random user space applications as follow,

kernel: urxvt[338]: segfault at 20 ip 00007fc08889ae0d sp 00007ffc73a7fc40 error 6 in libc-2.26.so[7fc08881a000+1ae000]
 #0  0x00007fc08889ae0d _int_malloc (libc.so.6)
 #1  0x00007fc08889c2f3 malloc (libc.so.6)
 #2  0x0000560e6004bff7 _Z14rxvt_wcstoutf8PKwi (urxvt)
 #3  0x0000560e6005e75c n/a (urxvt)
 #4  0x0000560e6007d9f1 _ZN16rxvt_perl_interp6invokeEP9rxvt_term9hook_typez (urxvt)
 #5  0x0000560e6003d988 _ZN9rxvt_term9cmd_parseEv (urxvt)
 #6  0x0000560e60042804 _ZN9rxvt_term6pty_cbERN2ev2ioEi (urxvt)
 #7  0x0000560e6005c10f _Z17ev_invoke_pendingv (urxvt)
 #8  0x0000560e6005cb55 ev_run (urxvt)
 #9  0x0000560e6003b9b9 main (urxvt)
 #10 0x00007fc08883af4a __libc_start_main (libc.so.6)
 #11 0x0000560e6003f9da _start (urxvt)

After bisection, it was found the first bad commit is
bd4c82c22c367e068 ("mm, THP, swap: delay splitting THP after swapped
out").

The root cause is as follow.

When the pages are written to swap device during swapping out in
swap_writepage(), zswap (fontswap) is tried to compress the pages
instead to improve the performance.  But zswap (frontswap) will treat
THP as normal page, so only the head page is saved.  After swapping
in, tail pages will not be restored to its original contents, so cause
the memory corruption in the applications.

This is fixed via splitting THP before writing the page to swap device
if frontswap is enabled.  To deal with the situation where frontswap
is enabled at runtime, whether the page is THP is checked before using
frontswap during swapping out too.

Reported-and-tested-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjenning@redhat.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Shaohua Li <shli@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: stable@vger.kernel.org # 4.14
Fixes: bd4c82c22c367e068 ("mm, THP, swap: delay splitting THP after swapped out")

Changelog:

v2:

- Move frontswap check into swapfile.c to avoid to make vmscan.c
  depends on frontswap.
---
 mm/page_io.c  | 2 +-
 mm/swapfile.c | 3 +++
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/page_io.c b/mm/page_io.c
index b41cf9644585..6dca817ae7a0 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -250,7 +250,7 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
 		unlock_page(page);
 		goto out;
 	}
-	if (frontswap_store(page) == 0) {
+	if (!PageTransHuge(page) && frontswap_store(page) == 0) {
 		set_page_writeback(page);
 		unlock_page(page);
 		end_page_writeback(page);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 006047b16814..0b7c7883ce64 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -934,6 +934,9 @@ int get_swap_pages(int n_goal, bool cluster, swp_entry_t swp_entries[])
 
 	/* Only single cluster request supported */
 	WARN_ON_ONCE(n_goal > 1 && cluster);
+	/* Frontswap doesn't support THP */
+	if (frontswap_enabled() && cluster)
+		goto noswap;
 
 	avail_pgs = atomic_long_read(&nr_swap_pages) / nr_pages;
 	if (avail_pgs <= 0)
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
