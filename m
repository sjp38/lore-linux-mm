Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 038C0440860
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 08:41:50 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 77so5297277wrb.11
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 05:41:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k44si1742635wrc.19.2017.07.12.05.41.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Jul 2017 05:41:48 -0700 (PDT)
Date: Wed, 12 Jul 2017 14:41:45 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
Message-ID: <20170712124145.GI28912@dhcp22.suse.cz>
References: <20170710141428.GL19185@dhcp22.suse.cz>
 <201707112210.AEG17105.tFVOOLQFFMOHJS@I-love.SAKURA.ne.jp>
 <20170711134900.GD11936@dhcp22.suse.cz>
 <201707120706.FHC86458.FLFOHtQVJSFMOO@I-love.SAKURA.ne.jp>
 <20170712085431.GD28912@dhcp22.suse.cz>
 <201707122123.CDD21817.FOQSFJtOHOVLFM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201707122123.CDD21817.FOQSFJtOHOVLFM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz, sergey.senozhatsky.work@gmail.com, pmladek@suse.com

On Wed 12-07-17 21:23:05, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 12-07-17 07:06:11, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > On Tue 11-07-17 22:10:36, Tetsuo Handa wrote:
> > > > > Michal Hocko wrote:
> > [...]
> > > > > > warn_alloc is just yet-another-user of printk. We might have many
> > > > > > others...
> > > > >
> > > > > warn_alloc() is different from other users of printk() that printk() is called
> > > > > as long as oom_lock is already held by somebody else processing console_unlock().
> > > >
> > > > So what exactly prevents any other caller of printk interfering while
> > > > the oom is ongoing?
> > >
> > > Other callers of printk() are not doing silly things like "while(1) printk();".
> >
> > They can still print a lot. There have been reports of one printk source
> > pushing an unrelated context to print way too much.
> 
> Which source is that?
> 
> Legitimate printk() users might do
> 
>   for (i = 0; i < 1000; i++)
>     printk();
> 
> but they do not do
> 
>   while (1)
>     for (i = 0; i < 1000; i++)
>       printk();
> 
> .
> 
> >
> > > They don't call printk() until something completes (e.g. some operation returned
> > > an error code) or they do throttling. Only watchdog calls printk() without waiting
> > > for something to complete (because watchdog is there in order to warn that something
> > > might be wrong). But watchdog is calling printk() carefully not to cause flooding
> > > (e.g. khungtaskd sleeps enough) and not to cause lockups (e.g. khungtaskd calls
> > > rcu_lock_break()).
> >
> > Look at hard/soft lockup detector and how it can cause flood of printks.
> 
> Lockup detector is legitimate because it is there to warn that somebody is
> continuously consuming CPU time. Lockup detector might do

Sigh. What I've tried to convey is that the lockup detector can print _a
lot_ (just consider a large machine with hundreds of CPUs and trying to
dump stack trace on each of them....) and that might mimic a herd of
printks from allocation stalls...
[...]
> > warn_alloc prints a single line + dump_stack for each stalling allocation and
> > show_mem once per second. That doesn't sound overly crazy to me.
> > Sure we can have many stalling tasks under certain conditions (most of
> > them quite unrealistic) and then we can print a lot. I do not see an
> > easy way out of it without losing information about stalls and I guess
> > we want to know about them otherwise we will have much harder time to
> > debug stalls.
> 
> Printing just one line per every second can lead to lockup, for
> the condition to escape the "for (;;)" loop in console_unlock() is
> 
>                 if (console_seq == log_next_seq)
>                         break;

Then something is really broken in that condition, don't you think?
Peter has already mentioned that offloading to a different context seems
like the way to go here.

> when cond_resched() in that loop slept for more than one second due to
> SCHED_IDLE priority.
> 
> Currently preempt_disable()/preempt_enable_no_resched() (or equivalent)
> is the only available countermeasure for minimizing interference like
> 
>     for (i = 0; i < 1000; i++)
>       printk();
> 
> . If prink() allows per printk context (shown below) flag which allows printk()
> users to force printk() not to try to print immediately (i.e. declare that
> use deferred printing (maybe offloaded to the printk-kthread)), lockups by
> cond_resched() from console_unlock() from printk() from out_of_memory() will be
> avoided.

As I've said earlier, if there is no other way to make printk work without all
these nasty side effected then I would be OK to add a printk context
specific calls into the oom killer.

Removing the rest because this is again getting largely tangent. The
primary problem you are seeing is that we stumble over printk here.
Unless I can see a sound argument this is not the case it doesn't make
any sense to discuss allocator changes.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
