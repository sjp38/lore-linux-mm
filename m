Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 62AE96B0038
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 09:41:17 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id gt1so5361395wjc.0
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 06:41:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b58si32704062wrb.1.2017.02.03.06.41.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Feb 2017 06:41:15 -0800 (PST)
Date: Fri, 3 Feb 2017 15:41:11 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages
 per zone
Message-ID: <20170203144111.GA19325@dhcp22.suse.cz>
References: <20170125130014.GO32377@dhcp22.suse.cz>
 <20170127144906.GB4148@dhcp22.suse.cz>
 <201701290027.AFB30799.FVtFLOOOJMSHQF@I-love.SAKURA.ne.jp>
 <20170130085546.GF8443@dhcp22.suse.cz>
 <20170202101415.GE22806@dhcp22.suse.cz>
 <201702031957.AGH86961.MLtOQVFOSHJFFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201702031957.AGH86961.MLtOQVFOSHJFFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: david@fromorbit.com, dchinner@redhat.com, hch@lst.de, mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

On Fri 03-02-17 19:57:39, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Mon 30-01-17 09:55:46, Michal Hocko wrote:
> > > On Sun 29-01-17 00:27:27, Tetsuo Handa wrote:
> > [...]
> > > > Regarding [1], it helped avoiding the too_many_isolated() issue. I can't
> > > > tell whether it has any negative effect, but I got on the first trial that
> > > > all allocating threads are blocked on wait_for_completion() from flush_work()
> > > > in drain_all_pages() introduced by "mm, page_alloc: drain per-cpu pages from
> > > > workqueue context". There was no warn_alloc() stall warning message afterwords.
> > > 
> > > That patch is buggy and there is a follow up [1] which is not sitting in the
> > > mmotm (and thus linux-next) yet. I didn't get to review it properly and
> > > I cannot say I would be too happy about using WQ from the page
> > > allocator. I believe even the follow up needs to have WQ_RECLAIM WQ.
> > > 
> > > [1] http://lkml.kernel.org/r/20170125083038.rzb5f43nptmk7aed@techsingularity.net
> > 
> > Did you get chance to test with this follow up patch? It would be
> > interesting to see whether OOM situation can still starve the waiter.
> > The current linux-next should contain this patch.
> 
> So far I can't reproduce problems except two listed below (cond_resched() trap
> in printk() and IDLE priority trap are excluded from the list). But I agree that
> the follow up patch needs to use a WQ_RECLAIM WQ. It is theoretically possible
> that an allocation request which can trigger the OOM killer waits for the
> system_wq while there is already a work which is in system_wq which is looping
> forever inside the page allocator without triggering the OOM killer.

Well, this shouldn't happen AFAICS because a new worker would be
requested and that would certainly require a memory and that allocation
would trigger the OOM killer. On the other hand I agree that it would be
safer to not depend on memory allocation from within the page allocator.

> Maybe the follow up patch can share the vmstat WQ?

Yes, this would be an option.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
