Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9B5ED6B0253
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 03:51:04 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a69so224920060pfa.1
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 00:51:04 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id n188si30860980pfn.2.2016.06.13.00.51.03
        for <linux-mm@kvack.org>;
        Mon, 13 Jun 2016 00:51:03 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 0/3] per-process reclaim
Date: Mon, 13 Jun 2016 16:50:55 +0900
Message-Id: <1465804259-29345-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Redmond <u93410091@gmail.com>, "ZhaoJunmin Zhao(Junmin)" <zhaojunmin@huawei.com>, Vinayak Menon <vinmenon@codeaurora.org>, Juneho Choi <juno.choi@lge.com>, Sangwoo Park <sangwoo2.park@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>

Hi all,

http://thread.gmane.org/gmane.linux.kernel/1480728

I sent per-process reclaim patchset three years ago. Then, last
feedback from akpm was that he want to know real usecase scenario.

Since then, I got question from several embedded people of various
company "why it's not merged into mainline" and heard they have used
the feature as in-house patch and recenlty, I noticed android from
Qualcomm started to use it.

Of course, our product have used it and released it in real procuct.

Quote from Sangwoo Park <angwoo2.park@lge.com>
Thanks for the data, Sangwoo!
"
- Test scenaro
  - platform: android
  - target: MSM8952, 2G DDR, 16G eMMC
  - scenario
    retry app launch and Back Home with 16 apps and 16 turns
    (total app launch count is 256)
  - result:
			  resume count   |  cold launching count
-----------------------------------------------------------------
 vanilla           |           85        |          171
 perproc reclaim   |           184       |           72
"

Higher resume count is better because cold launching needs loading
lots of resource data which takes above 15 ~ 20 seconds for some
games while successful resume just takes 1~5 second.

As perproc reclaim way with new management policy, we could reduce
cold launching a lot(i.e., 171-72) so that it reduces app startup
a lot.

Another useful function from this feature is to make swapout easily
which is useful for testing swapout stress and workloads.

Thanks.

Cc: Redmond <u93410091@gmail.com>
Cc: ZhaoJunmin Zhao(Junmin) <zhaojunmin@huawei.com>
Cc: Vinayak Menon <vinmenon@codeaurora.org>
Cc: Juneho Choi <juno.choi@lge.com>
Cc: Sangwoo Park <sangwoo2.park@lge.com>
Cc: Chan Gyun Jeong <chan.jeong@lge.com>

Minchan Kim (3):
  mm: vmscan: refactoring force_reclaim
  mm: vmscan: shrink_page_list with multiple zones
  mm: per-process reclaim

 Documentation/filesystems/proc.txt |  15 ++++
 fs/proc/base.c                     |   1 +
 fs/proc/internal.h                 |   1 +
 fs/proc/task_mmu.c                 | 149 +++++++++++++++++++++++++++++++++++++
 include/linux/rmap.h               |   4 +
 mm/vmscan.c                        |  85 ++++++++++++++++-----
 6 files changed, 235 insertions(+), 20 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
