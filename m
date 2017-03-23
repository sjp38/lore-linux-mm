Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 206956B0038
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 01:53:14 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q126so420509375pga.0
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 22:53:14 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id m5si4317989pln.98.2017.03.22.22.53.12
        for <linux-mm@kvack.org>;
        Wed, 22 Mar 2017 22:53:13 -0700 (PDT)
Date: Thu, 23 Mar 2017 14:53:09 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 3/5] mm: use a dedicated workqueue for the free workers
Message-ID: <20170323055309.GA6117@bbox>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
 <1489568404-7817-4-git-send-email-aaron.lu@intel.com>
 <20170322063335.GF30149@bbox>
 <20170322084103.GC2360@aaronlu.sh.intel.com>
 <20170322085512.GA32359@bbox>
 <20170322134304.GG2360@aaronlu.sh.intel.com>
MIME-Version: 1.0
In-Reply-To: <20170322134304.GG2360@aaronlu.sh.intel.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>

On Wed, Mar 22, 2017 at 09:43:04PM +0800, Aaron Lu wrote:
> On Wed, Mar 22, 2017 at 05:55:12PM +0900, Minchan Kim wrote:
> > On Wed, Mar 22, 2017 at 04:41:04PM +0800, Aaron Lu wrote:
> > > My understanding of the unbound workqueue is that it will create a
> > > thread pool for each node, versus each CPU as in the bound workqueue
> > > case, and use threads from the thread pool(create threads if not enough)
> > > to do the work.
> > 
> > Yes, that was my understand so I read code and found that
> > 
> > insert_work:
> >         ..
> >         if (__need_more_worker(pool))
> >                 wake_up_worker(pool); 
> > 
> > so I thought if there is a running thread in that node, workqueue
> > will not wake any other threads so parallelism should be max 2.
> > AFAIK, if the work goes sleep, scheduler will spawn new worker
> > thread so the active worker could be a lot but I cannot see any
> > significant sleepable point in that work(ie, batch_free_work).
> 
> Looks like worker_thread() will spawn new worker through manage_worker().
> 
> Note that pool->nr_running will always be zero for an unbound workqueue
> and thus need_more_worker() will return true as long as there are queued
> work items in the pool.

Aha, it solves my wonder. Thanks a lot!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
