Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 45A906B0293
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 06:23:42 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id p192so8659376wme.1
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 03:23:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b6si6159012wmh.15.2017.01.19.03.23.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Jan 2017 03:23:40 -0800 (PST)
Date: Thu, 19 Jan 2017 12:23:36 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages
 per zone
Message-ID: <20170119112336.GN30786@dhcp22.suse.cz>
References: <20170118134453.11725-1-mhocko@kernel.org>
 <20170118134453.11725-2-mhocko@kernel.org>
 <20170118144655.3lra7xgdcl2awgjd@suse.de>
 <20170118151530.GR7015@dhcp22.suse.cz>
 <20170118155430.kimzqkur5c3te2at@suse.de>
 <20170118161731.GT7015@dhcp22.suse.cz>
 <20170118170010.agpd4njpv5log3xe@suse.de>
 <20170118172944.GA17135@dhcp22.suse.cz>
 <20170119100755.rs6erdiz5u5by2pu@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170119100755.rs6erdiz5u5by2pu@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On Thu 19-01-17 10:07:55, Mel Gorman wrote:
[...]
> mm, vmscan: Wait on a waitqueue when too many pages are isolated
> 
> When too many pages are isolated, direct reclaim waits on congestion to clear
> for up to a tenth of a second. There is no reason to believe that too many
> pages are isolated due to dirty pages, reclaim efficiency or congestion.
> It may simply be because an extremely large number of processes have entered
> direct reclaim at the same time. However, it is possible for the situation
> to persist forever and never reach OOM.
> 
> This patch queues processes a waitqueue when too many pages are isolated.
> When parallel reclaimers finish shrink_page_list, they wake the waiters
> to recheck whether too many pages are isolated.
> 
> The wait on the queue has a timeout as not all sites that isolate pages
> will do the wakeup. Depending on every isolation of LRU pages to be perfect
> forever is potentially fragile. The specific wakeups occur for page reclaim
> and compaction. If too many pages are isolated due to memory failure,
> hotplug or directly calling migration from a syscall then the waiting
> processes may wait the full timeout.
> 
> Note that the timeout allows the use of waitqueue_active() on the basis
> that a race will cause the full timeout to be reached due to a missed
> wakeup. This is relatively harmless and still a massive improvement over
> unconditionally calling congestion_wait.
> 
> Direct reclaimers that cannot isolate pages within the timeout will consider
> return to the caller. This is somewhat clunky as it won't return immediately
> and make go through the other priorities and slab shrinking. Eventually,
> it'll go through a few iterations of should_reclaim_retry and reach the
> MAX_RECLAIM_RETRIES limit and consider going OOM.

I cannot really say I would like this. It's just much more complex than
necessary. I definitely agree that congestion_wait while waiting for
too_many_isolated is a crude hack. This patch doesn't really resolve
my biggest worry, though, that we go OOM with too many pages isolated
as your patch doesn't alter zone_reclaimable_pages to reflect those
numbers.

Anyway, I think both of us are probably overcomplicating things a bit.
Your waitqueue approach is definitely better semantically than the
congestion_wait because we are waiting for a different event than the
API is intended for. On the other hand a mere
schedule_timeout_interruptible might work equally well in the real life.
On the other side I might really over emphasise the role of NR_ISOLATED*
counts. It might really turn out that we can safely ignore them and it
won't be the end of the world. So what do you think about the following
as a starting point. If we ever see oom reports with high number of
NR_ISOLATED* which are part of the oom report then we know we have to do
something about that. Those changes would at least be driven by a real
usecase rather than theoretical scenarios.

So what do you think about the following? Tetsuo, would you be willing
to run this patch through your torture testing please?
---
