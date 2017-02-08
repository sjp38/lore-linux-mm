Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D19126B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 07:56:57 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id h7so32694694wjy.6
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 04:56:57 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q62si9029457wrb.280.2017.02.08.04.56.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 04:56:56 -0800 (PST)
Date: Wed, 8 Feb 2017 13:56:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm: move pcp and lru-pcp drainging into vmstat_wq
Message-ID: <20170208125653.GL5686@dhcp22.suse.cz>
References: <20170207210908.530-1-mhocko@kernel.org>
 <20170208105334.zbjuaaqwmp5rgpui@suse.de>
 <20170208120354.GI5686@dhcp22.suse.cz>
 <20170208123113.nq5unzmzpb23zoz5@suse.de>
 <201702082144.BCE17682.SMOFOHJOVQLtFF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201702082144.BCE17682.SMOFOHJOVQLtFF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mgorman@suse.de, linux-mm@kvack.org, vbabka@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Wed 08-02-17 21:44:36, Tetsuo Handa wrote:
> Mel Gorman wrote:
> > > > It also feels like vmstat is now a misleading name for something that
> > > > handles vmstat, lru drains and per-cpu drains but that's cosmetic.
> > > 
> > > yeah a better name sounds like a good thing. mm_nonblock_wq?
> > > 
> > 
> > it's not always non-blocking. Maybe mm_percpu_wq to describev a workqueue
> > that handles a variety of MM-related per-cpu updates?
> > 
> 
> Why not make it global like ones created by workqueue_init_early() ?

I can see alloc_workqueue_attrs in that path so we can hit the page
allocator and if unlucky try to drain_all_pages. We might have more
even before this. So I think we still need a check for the WQ being
initialized already. I do not have a strong preference to when to
allocate it. Moving the initialization out to workqueue_init_early wold
mean that the WQ would have to be visible outside of the mm proper which
is not ideal. We can live with that, though, so I will move it there if
this is a prevalent opinion.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
