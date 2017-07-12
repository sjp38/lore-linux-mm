Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E48E7440860
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 04:54:37 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v88so3995156wrb.1
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 01:54:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b4si1635020wmi.83.2017.07.12.01.54.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Jul 2017 01:54:36 -0700 (PDT)
Date: Wed, 12 Jul 2017 10:54:31 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
Message-ID: <20170712085431.GD28912@dhcp22.suse.cz>
References: <20170710132139.GJ19185@dhcp22.suse.cz>
 <201707102254.ADA57090.SOFFOOMJFHQtVL@I-love.SAKURA.ne.jp>
 <20170710141428.GL19185@dhcp22.suse.cz>
 <201707112210.AEG17105.tFVOOLQFFMOHJS@I-love.SAKURA.ne.jp>
 <20170711134900.GD11936@dhcp22.suse.cz>
 <201707120706.FHC86458.FLFOHtQVJSFMOO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201707120706.FHC86458.FLFOHtQVJSFMOO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz, sergey.senozhatsky.work@gmail.com, pmladek@suse.com

On Wed 12-07-17 07:06:11, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 11-07-17 22:10:36, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
[...]
> > > > warn_alloc is just yet-another-user of printk. We might have many
> > > > others...
> > > 
> > > warn_alloc() is different from other users of printk() that printk() is called
> > > as long as oom_lock is already held by somebody else processing console_unlock().
> > 
> > So what exactly prevents any other caller of printk interfering while
> > the oom is ongoing?
> 
> Other callers of printk() are not doing silly things like "while(1) printk();".

They can still print a lot. There have been reports of one printk source
pushing an unrelated context to print way too much.

> They don't call printk() until something completes (e.g. some operation returned
> an error code) or they do throttling. Only watchdog calls printk() without waiting
> for something to complete (because watchdog is there in order to warn that something
> might be wrong). But watchdog is calling printk() carefully not to cause flooding
> (e.g. khungtaskd sleeps enough) and not to cause lockups (e.g. khungtaskd calls
> rcu_lock_break()).

Look at hard/soft lockup detector and how it can cause flood of printks.

> As far as I can observe, only warn_alloc() for watchdog trivially
> causes flooding and lockups.

warn_alloc prints a single line + dump_stack for each stalling allocation and
show_mem once per second. That doesn't sound overly crazy to me.
Sure we can have many stalling tasks under certain conditions (most of
them quite unrealistic) and then we can print a lot. I do not see an
easy way out of it without losing information about stalls and I guess
we want to know about them otherwise we will have much harder time to
debug stalls.

Sure we can tune this a bit and e.g. do not dump stacks of tasks which
have already printed their backtrace as it couldn't have changed.  But
this doesn't change anything in principle.

[...]
> > > The OOM killer is not permitted to wait for __GFP_DIRECT_RECLAIM allocations
> > > directly/indirectly (because it will cause recursion deadlock). Thus, even if
> > > some code path needs to sleep for some reason, that code path is not permitted to
> > > wait for __GFP_DIRECT_RECLAIM allocations directly/indirectly. Anyway, I can
> > > propose scattering preempt_disable()/preempt_enable_no_resched() around printk()
> > > rather than whole oom_kill_process(). You will just reject it as you have rejected
> > > in the past.
> > 
> > because you are trying to address a problem at a wrong layer. If there
> > is absolutely no way around it and printk is unfixable then we really
> > need a printk variant which will make sure that no excessive waiting
> > will be involved. Then we can replace all printk in the oom path with
> > this special printk.
> 
> Writing data faster than readers can read is wrong, especially when
> writers deprive readers of CPU time to read.

Yes this is not good but only printk knows the congestion.

[...]
> > As I've said out_of_memory is an expensive operation and as such it has
> > to be preemptible. Addressing this would require quite some work.
> 
> But calling out_of_memory() with SCHED_IDLE priority makes overall allocations
> far more expensive. If you want to keep out_of_memory() preemptible, you should
> make sure that out_of_memory() is executed with !SCHED_IDLE priority. Offloading to
> a dedicated kernel thread like oom_reaper will do it.

You do realize that the whole page allocator is not priority aware and
a low priority task can starve a higher priority task already in the
reclaim path. Is this ideal? Absolutely no but let's be realistic, this
has never been a priority and it would require a lot of heavy lifting.
The OOM is the most cold path in the whole allocation stack and focusing
solely on it while claiming something take a minute or two longer is
just not going to attract a lot of attention.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
