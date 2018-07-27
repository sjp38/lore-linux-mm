Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id BCF756B000A
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 15:56:03 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id d4-v6so3066311ybl.3
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 12:56:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 62-v6sor1338440ybe.127.2018.07.27.12.55.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 27 Jul 2018 12:55:57 -0700 (PDT)
Date: Fri, 27 Jul 2018 15:58:48 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: terminate the reclaim early when direct reclaiming
Message-ID: <20180727195848.GA12399@cmpxchg.org>
References: <1532683165-19416-1-git-send-email-zhaoyang.huang@spreadtrum.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1532683165-19416-1-git-send-email-zhaoyang.huang@spreadtrum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org

Hi Zhaoyang,

On Fri, Jul 27, 2018 at 05:19:25PM +0800, Zhaoyang Huang wrote:
> This patch try to let the direct reclaim finish earlier than it used
> to be. The problem comes from We observing that the direct reclaim
> took a long time to finish when memcg is enabled. By debugging, we
> find that the reason is the softlimit is too low to meet the loop
> end criteria. So we add two barriers to judge if it has reclaimed
> enough memory as same criteria as it is in shrink_lruvec:
> 1. for each memcg softlimit reclaim.
> 2. before starting the global reclaim in shrink_zone.

Yes, the soft limit reclaim cycle is fairly aggressive and can
introduce quite some allocation latency into the system. Let me say
right up front, though, that we've spend hours in conference sessions
and phone calls trying to fix this and could never agree on
anything. You might have better luck trying cgroup2 which implements
memory.low in a more scalable manner. (Due to the default value of 0
instead of infinitity, it can use a smoother 2-pass reclaim cycle.)

On your patch specifically:

should_continue_reclaim() is for compacting higher order pages. It
assumes you have already made a full reclaim cycle and returns false
for most allocations without checking any sort of reclaim progress.

You may end up in a situation where soft limit reclaim finds nothing,
and you still abort without trying a regular reclaim cycle. That can
trigger the OOM killer while there is still plenty of reclaimable
memory in other groups.

So if you want to fix this, you'd have to look for a different
threshold for soft limit reclaim and. Maybe something like this
already works:

diff --git a/mm/vmscan.c b/mm/vmscan.c
index ee91e8cbeb5a..5b2388fa6bc4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2786,7 +2786,8 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 						&nr_soft_scanned);
 			sc->nr_reclaimed += nr_soft_reclaimed;
 			sc->nr_scanned += nr_soft_scanned;
-			/* need some check for avoid more shrink_zone() */
+			if (nr_soft_reclaimed)
+				continue;
 		}
 
 		/* See comment about same check for global reclaim above */
