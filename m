Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6AE4E6B0292
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 09:15:29 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id 6so33550521oik.11
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 06:15:29 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id x186si13814881oix.139.2017.07.04.06.15.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Jul 2017 06:15:28 -0700 (PDT)
Subject: Re: mm/slab: What is cache_reap work for?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201706271935.DJJ18719.OMFLFFHJSOVtQO@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.20.1706300856530.3291@east.gentwo.org>
In-Reply-To: <alpine.DEB.2.20.1706300856530.3291@east.gentwo.org>
Message-Id: <201707042215.ICG90672.FStFMFQOHLOOJV@I-love.SAKURA.ne.jp>
Date: Tue, 4 Jul 2017 22:15:21 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com
Cc: linux-mm@kvack.org

Christoph Lameter wrote:
> On Tue, 27 Jun 2017, Tetsuo Handa wrote:
> 
> > I hit an unable to invoke the OOM killer lockup shown below. According to
> > "cpus=2 node=0 flags=0x0 nice=0" part, it seems that cache_reap (in mm/slab.c)
> > work stuck waiting for disk_events_workfn (in block/genhd.c) work to complete.
> 
> Cache reaping in SLAB is the expiration of objects since they are deemed
> to be cache cold after while. Reaping is a tick driven worker thread that
> calls other functions that are used during regular slab allocation and
> freeing. Maybe someone added code that can cause deadlocks if invoked from
> the tick?

Thank you for explanation. What I observed is that it seems that
cache_reap work was not able to run because it used system_wq when
the system was unable to allocate memory for new worker thread due to
infinite too_many_isolated() loop in shrink_inactive_list().

I wondered whether cache_reap work qualifies as an mm_percpu_wq user
if cache_reap work does something like what vmstat_work work does (e.g.
update statistic counters which affect progress of memory allocation).
But "calls other functions that are used during regular slab allocation"
means cache_reap work cannot qualify as an mm_percpu_wq user...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
