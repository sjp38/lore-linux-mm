Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8E1196B0343
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 04:55:19 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t143so141404241pgb.1
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 01:55:19 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id d198si979665pga.192.2017.03.22.01.55.17
        for <linux-mm@kvack.org>;
        Wed, 22 Mar 2017 01:55:18 -0700 (PDT)
Date: Wed, 22 Mar 2017 17:55:12 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 3/5] mm: use a dedicated workqueue for the free workers
Message-ID: <20170322085512.GA32359@bbox>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
 <1489568404-7817-4-git-send-email-aaron.lu@intel.com>
 <20170322063335.GF30149@bbox>
 <20170322084103.GC2360@aaronlu.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170322084103.GC2360@aaronlu.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>

On Wed, Mar 22, 2017 at 04:41:04PM +0800, Aaron Lu wrote:
> On Wed, Mar 22, 2017 at 03:33:35PM +0900, Minchan Kim wrote:
> > Hi,
> > 
> > On Wed, Mar 15, 2017 at 05:00:02PM +0800, Aaron Lu wrote:
> > > Introduce a workqueue for all the free workers so that user can fine
> > > tune how many workers can be active through sysfs interface: max_active.
> > > More workers will normally lead to better performance, but too many can
> > > cause severe lock contention.
> > 
> > Let me ask a question.
> > 
> > How well can workqueue distribute the jobs in multiple CPU?
> 
> I would say it's good enough for my needs.
> After all, it doesn't need many kworkers to achieve the 50% time
> decrease: 2-4 kworkers for EP and 4-8 kworkers for EX are enough from
> previous attched data.
> 
> > I don't ask about currency but parallelism.
> > I guess benefit you are seeing comes from the parallelism and
> > for your goal, unbound wq should spawn a thread per cpu and
> > doing the work in every each CPU. does it work?
> 
> I don't think a unbound workqueue will spawn a thread per CPU, that
> seems too much a cost to have a unbound workqueue.
> 
> My understanding of the unbound workqueue is that it will create a
> thread pool for each node, versus each CPU as in the bound workqueue
> case, and use threads from the thread pool(create threads if not enough)
> to do the work.

Yes, that was my understand so I read code and found that

insert_work:
        ..
        if (__need_more_worker(pool))
                wake_up_worker(pool); 

so I thought if there is a running thread in that node, workqueue
will not wake any other threads so parallelism should be max 2.
AFAIK, if the work goes sleep, scheduler will spawn new worker
thread so the active worker could be a lot but I cannot see any
significant sleepable point in that work(ie, batch_free_work).
        
> 
> I guess you want to ask if the unbound workqueue can spawn enough
> threads to do the job? From the output of 'vmstat 1' during the free()
> test, I can see some 70+ processes in runnable state when I didn't
> set an upper limit for max_active of the workqueue.

Hmm, it seems I was wrong. I am really curious how we can have
70+ active workers in that. Could you explain what I am missing?

Thanks.

> 
> Thanks,
> Aaron
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
