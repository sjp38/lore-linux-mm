Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 592F86B0259
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 11:25:17 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id c201so81386404wme.0
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 08:25:17 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id br5si26506349wjb.69.2015.12.11.08.25.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 08:25:16 -0800 (PST)
Date: Fri, 11 Dec 2015 11:25:12 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC 2/3] mm: throttle on IO only when there are too many dirty
 and writeback pages
Message-ID: <20151211162512.GB5593@cmpxchg.org>
References: <1448974607-10208-1-git-send-email-mhocko@kernel.org>
 <1448974607-10208-3-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448974607-10208-3-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.com>

On Tue, Dec 01, 2015 at 01:56:46PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> wait_iff_congested has been used to throttle allocator before it retried
> another round of direct reclaim to allow the writeback to make some
> progress and prevent reclaim from looping over dirty/writeback pages
> without making any progress. We used to do congestion_wait before
> 0e093d99763e ("writeback: do not sleep on the congestion queue if
> there are no congested BDIs or if significant congestion is not being
> encountered in the current zone") but that led to undesirable stalls
> and sleeping for the full timeout even when the BDI wasn't congested.
> Hence wait_iff_congested was used instead. But it seems that even
> wait_iff_congested doesn't work as expected. We might have a small file
> LRU list with all pages dirty/writeback and yet the bdi is not congested
> so this is just a cond_resched in the end and can end up triggering pre
> mature OOM.
> 
> This patch replaces the unconditional wait_iff_congested by
> congestion_wait which is executed only if we _know_ that the last round
> of direct reclaim didn't make any progress and dirty+writeback pages are
> more than a half of the reclaimable pages on the zone which might be
> usable for our target allocation. This shouldn't reintroduce stalls
> fixed by 0e093d99763e because congestion_wait is called only when we
> are getting hopeless when sleeping is a better choice than OOM with many
> pages under IO.
> 
> We have to preserve logic introduced by "mm, vmstat: allow WQ concurrency
> to discover memory reclaim doesn't make any progress" into the
> __alloc_pages_slowpath now that wait_iff_congested is not used anymore.
> As the only remaining user of wait_iff_congested is shrink_inactive_list
> we can remove the WQ specific short sleep from wait_iff_congested
> because the sleep is needed to be done only once in the allocation retry
> cycle.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Yep, this looks like the right thing to do. However, the code it adds
to __alloc_pages_slowpath() is putting even more weight behind the
argument that the reclaim retry logic should be in its own function.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
