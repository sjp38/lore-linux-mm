Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 297406B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 05:53:38 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id c85so30113659wmi.6
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 02:53:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k91si8685562wrc.221.2017.02.08.02.53.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 02:53:37 -0800 (PST)
Date: Wed, 8 Feb 2017 10:53:34 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH] mm: move pcp and lru-pcp drainging into vmstat_wq
Message-ID: <20170208105334.zbjuaaqwmp5rgpui@suse.de>
References: <20170207210908.530-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170207210908.530-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, Feb 07, 2017 at 10:09:08PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> We currently have 2 specific WQ_RECLAIM workqueues. One for updating
> pcp stats vmstat_wq and one dedicated to drain per cpu lru caches. This
> seems more than necessary because both can run on a single WQ. Both
> do not block on locks requiring a memory allocation nor perform any
> allocations themselves. We will save one rescuer thread this way.
> 

True.

> On the other hand drain_all_pages queues work on the system wq which
> doesn't have rescuer and so this depend on memory allocation (when all
> workers are stuck allocating and new ones cannot be created). This is
> not critical as there should be somebody invoking the OOM killer (e.g.
> the forking worker) and get the situation unstuck and eventually
> performs the draining. Quite annoying though. This worker should be
> using WQ_RECLAIM as well. We can reuse the same one as for lru draining
> and vmstat.
> 

That was still debatable which is why I didn't go that route. The drain
itself is unlikely to fix anything with the possible exception of high-order
pages. There are just too many reasons why direct reclaim can return 0
reclaimed pages making the drain is redundant but I couldn't decide what
a better alternative would be and more importantly, how to measure it.
The fact it allocates in that path is currently unfortunate but I couldn't
convince myself it deserved a dedicated rescuer.

I don't object to it being actually moved. I have a slight concern that
it could somehow starve a vmstat update while frequent drains happen
during reclaim though which potentially compounds the problem. It could
be offset by a variety of other factors but if it ever is an issue,
it'll show up and the paths that really matter check the vmstats
directly instead of waiting for an update.

> Suggested-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
> 
> Hi,
> Tetsuo has noted that drain_all_pages doesn't use WQ_RECLAIM [1]
> and asked whether we can move the worker to the vmstat_wq which is
> WQ_RECLAIM. I think the deadlock he has described shouldn't happen but
> it would be really better to have the rescuer. I also think that we do
> not really need 2 or more workqueues and also pull lru draining in.
> 
> What do you think? Please note I haven't tested it yet.
> 

As an aside, the LRU drain could also avoid a get_online_cpus() which is
surprisingly heavy handed for an operation that can happen quite
frequently during compaction or migration. Maybe not enough to make a
big deal of but it's relatively low hanging fruit.

The altering of the return value in setup_vmstat was mildly surprising as
it increases the severity of registering the vmstat callback for memory
hotplug so maybe split that out and appears unrelated.

It also feels like vmstat is now a misleading name for something that
handles vmstat, lru drains and per-cpu drains but that's cosmetic.

Fundamentally I have nothing against the patch.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
