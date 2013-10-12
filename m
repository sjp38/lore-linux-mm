Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9FFF66B0031
	for <linux-mm@kvack.org>; Fri, 11 Oct 2013 20:44:19 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so4958594pbb.27
        for <linux-mm@kvack.org>; Fri, 11 Oct 2013 17:44:19 -0700 (PDT)
Date: Sat, 12 Oct 2013 08:43:55 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH] writeback: fix negative bdi max pause
Message-ID: <20131012004355.GB7520@localhost>
References: <CAMuHMdWs6Y7y12STJ+YXKJjxRF0k5yU9C9+0fiPPmq-GgeW-6Q@mail.gmail.com>
 <525591AD.4060401@gmx.de>
 <5255A3E6.6020100@nod.at>
 <20131009214733.GB25608@quack.suse.cz>
 <5255D9A6.3010208@nod.at>
 <5256DA9A.5060904@gmx.de>
 <20131011011649.GA11191@localhost>
 <5257B9EB.7080503@gmx.de>
 <20131011085701.GA27382@localhost>
 <52580767.6090604@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <52580767.6090604@gmx.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>, Richard Weinberger <richard@nod.at>, Jan Kara <jack@suse.cz>, Geert Uytterhoeven <geert@linux-m68k.org>, UML devel <user-mode-linux-devel@lists.sourceforge.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, hannes@cmpxchg.org, darrick.wong@oracle.com, Michal Hocko <mhocko@suse.cz>

Toralf runs trinity on UML/i386.
After some time it hangs and the last message line is

	BUG: soft lockup - CPU#0 stuck for 22s! [trinity-child0:1521]

It's found that pages_dirtied becomes very large.
More than 1000000000 pages in this case:

	period = HZ * pages_dirtied / task_ratelimit;
	BUG_ON(pages_dirtied > 2000000000);
	BUG_ON(pages_dirtied > 1000000000);      <---------

UML debug printf shows that we got negative pause here:

	ick: pause : -984
	ick: pages_dirtied : 0
	ick: task_ratelimit: 0

	 pause:
	+       if (pause < 0)  {
	+               extern int printf(char *, ...);
	+               printf("ick : pause : %li\n", pause);
	+               printf("ick: pages_dirtied : %lu\n", pages_dirtied);
	+               printf("ick: task_ratelimit: %lu\n", task_ratelimit);
	+               BUG_ON(1);
	+       }
	        trace_balance_dirty_pages(bdi,

Since pause is bounded by [min_pause, max_pause] where min_pause is also
bounded by max_pause. It's suspected and demonstrated that the max_pause
calculation goes wrong:

	ick: pause : -717
	ick: min_pause : -177
	ick: max_pause : -717
	ick: pages_dirtied : 14
	ick: task_ratelimit: 0

The problem lies in the two "long = unsigned long" assignments in
bdi_max_pause() which might go negative if the highest bit is 1, and
the min_t(long, ...) check failed to protect it falling under 0. Fix
all of them by using "unsigned long" throughout the function.

Reported-by: Toralf FA?rster <toralf.foerster@gmx.de>
Tested-by: Toralf FA?rster <toralf.foerster@gmx.de>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   10 +++++-----
 mm/readahead.c      |    2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 3f0c895..241a746 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1104,11 +1104,11 @@ static unsigned long dirty_poll_interval(unsigned long dirty,
 	return 1;
 }
 
-static long bdi_max_pause(struct backing_dev_info *bdi,
-			  unsigned long bdi_dirty)
+static unsigned long bdi_max_pause(struct backing_dev_info *bdi,
+				   unsigned long bdi_dirty)
 {
-	long bw = bdi->avg_write_bandwidth;
-	long t;
+	unsigned long bw = bdi->avg_write_bandwidth;
+	unsigned long t;
 
 	/*
 	 * Limit pause time for small memory systems. If sleeping for too long
@@ -1120,7 +1120,7 @@ static long bdi_max_pause(struct backing_dev_info *bdi,
 	t = bdi_dirty / (1 + bw / roundup_pow_of_two(1 + HZ / 8));
 	t++;
 
-	return min_t(long, t, MAX_PAUSE);
+	return min_t(unsigned long, t, MAX_PAUSE);
 }
 
 static long bdi_min_pause(struct backing_dev_info *bdi,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
