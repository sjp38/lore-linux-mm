Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 773F16B02A2
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 08:11:48 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id kq3so8441715wjc.1
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 05:11:48 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l66si6481352wma.43.2017.01.19.05.11.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Jan 2017 05:11:47 -0800 (PST)
Date: Thu, 19 Jan 2017 13:11:43 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages
 per zone
Message-ID: <20170119131143.2ze5l5fwheoqdpne@suse.de>
References: <20170118134453.11725-1-mhocko@kernel.org>
 <20170118134453.11725-2-mhocko@kernel.org>
 <20170118144655.3lra7xgdcl2awgjd@suse.de>
 <20170118151530.GR7015@dhcp22.suse.cz>
 <20170118155430.kimzqkur5c3te2at@suse.de>
 <20170118161731.GT7015@dhcp22.suse.cz>
 <20170118170010.agpd4njpv5log3xe@suse.de>
 <20170118172944.GA17135@dhcp22.suse.cz>
 <20170119100755.rs6erdiz5u5by2pu@suse.de>
 <20170119112336.GN30786@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170119112336.GN30786@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jan 19, 2017 at 12:23:36PM +0100, Michal Hocko wrote:
> On Thu 19-01-17 10:07:55, Mel Gorman wrote:
> [...]
> > mm, vmscan: Wait on a waitqueue when too many pages are isolated
> > 
> > When too many pages are isolated, direct reclaim waits on congestion to clear
> > for up to a tenth of a second. There is no reason to believe that too many
> > pages are isolated due to dirty pages, reclaim efficiency or congestion.
> > It may simply be because an extremely large number of processes have entered
> > direct reclaim at the same time. However, it is possible for the situation
> > to persist forever and never reach OOM.
> > 
> > This patch queues processes a waitqueue when too many pages are isolated.
> > When parallel reclaimers finish shrink_page_list, they wake the waiters
> > to recheck whether too many pages are isolated.
> > 
> > The wait on the queue has a timeout as not all sites that isolate pages
> > will do the wakeup. Depending on every isolation of LRU pages to be perfect
> > forever is potentially fragile. The specific wakeups occur for page reclaim
> > and compaction. If too many pages are isolated due to memory failure,
> > hotplug or directly calling migration from a syscall then the waiting
> > processes may wait the full timeout.
> > 
> > Note that the timeout allows the use of waitqueue_active() on the basis
> > that a race will cause the full timeout to be reached due to a missed
> > wakeup. This is relatively harmless and still a massive improvement over
> > unconditionally calling congestion_wait.
> > 
> > Direct reclaimers that cannot isolate pages within the timeout will consider
> > return to the caller. This is somewhat clunky as it won't return immediately
> > and make go through the other priorities and slab shrinking. Eventually,
> > it'll go through a few iterations of should_reclaim_retry and reach the
> > MAX_RECLAIM_RETRIES limit and consider going OOM.
> 
> I cannot really say I would like this. It's just much more complex than
> necessary.

I guess it's a difference in opinion. Miximg per-zone and per-node
information for me is complex. I liked the workqueue because it was an
example of waiting on a specific event instead of relying completely on
time.

> I definitely agree that congestion_wait while waiting for
> too_many_isolated is a crude hack. This patch doesn't really resolve
> my biggest worry, though, that we go OOM with too many pages isolated
> as your patch doesn't alter zone_reclaimable_pages to reflect those
> numbers.
> 

Indeed, but such cases are also caught by the no_progress_loop logic to
avoid a premature OOM.

> Anyway, I think both of us are probably overcomplicating things a bit.
> Your waitqueue approach is definitely better semantically than the
> congestion_wait because we are waiting for a different event than the
> API is intended for. On the other hand a mere
> schedule_timeout_interruptible might work equally well in the real life.
> On the other side I might really over emphasise the role of NR_ISOLATED*
> counts. It might really turn out that we can safely ignore them and it
> won't be the end of the world. So what do you think about the following
> as a starting point. If we ever see oom reports with high number of
> NR_ISOLATED* which are part of the oom report then we know we have to do
> something about that. Those changes would at least be driven by a real
> usecase rather than theoretical scenarios.
> 
> So what do you think about the following? Tetsuo, would you be willing
> to run this patch through your torture testing please?

I'm fine with treating this as a starting point.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
