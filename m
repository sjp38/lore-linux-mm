Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id E42E36B0009
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 04:33:20 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id b205so64521719wmb.1
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 01:33:20 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id gk3si14891249wjd.195.2016.02.26.01.33.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 01:33:19 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id g62so8057273wme.2
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 01:33:19 -0800 (PST)
Date: Fri, 26 Feb 2016 10:33:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160226093317.GC8940@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160225092315.GD17573@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602252219020.9793@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1602252219020.9793@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Thu 25-02-16 22:32:54, Hugh Dickins wrote:
> On Thu, 25 Feb 2016, Michal Hocko wrote:
[...]
> > From d09de26cee148b4d8c486943b4e8f3bd7ad6f4be Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Thu, 4 Feb 2016 14:56:59 +0100
> > Subject: [PATCH] mm, oom: protect !costly allocations some more
> > 
> > should_reclaim_retry will give up retries for higher order allocations
> > if none of the eligible zones has any requested or higher order pages
> > available even if we pass the watermak check for order-0. This is done
> > because there is no guarantee that the reclaimable and currently free
> > pages will form the required order.
> > 
> > This can, however, lead to situations were the high-order request (e.g.
> > order-2 required for the stack allocation during fork) will trigger
> > OOM too early - e.g. after the first reclaim/compaction round. Such a
> > system would have to be highly fragmented and the OOM killer is just a
> > matter of time but let's stick to our MAX_RECLAIM_RETRIES for the high
> > order and not costly requests to make sure we do not fail prematurely.
> > 
> > This also means that we do not reset no_progress_loops at the
> > __alloc_pages_slowpath for high order allocations to guarantee a bounded
> > number of retries.
> > 
> > Longterm it would be much better to communicate with the compaction
> > and retry only if the compaction considers it meaningfull.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> It didn't really help, I'm afraid: it reduces the actual number of OOM
> kills which occur before the job is terminated, but doesn't stop the
> job from being terminated very soon.

Yeah this is not a magic bullet. I am happy to hear that the patch
actually helped to reduce the number of OOM kills, though, because that is
what it aims to do. I also believe that supports (at least partially) my
suspicious that it is compaction which doesn't try enough.
order-0 reclaim, even when done repeatedly, doesn't have a great
chances to form higher order pages. Especially when there is a lot of
migrateable memory. I have already talked about this with Vlastimil and
he said that compaction can indeed back off too early because it doesn't
care about !costly request much at all. We will have a look into this
more next week.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
