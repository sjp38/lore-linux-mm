Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6616B0292
	for <linux-mm@kvack.org>; Sat,  3 Jun 2017 04:36:52 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id r84so4841640oif.0
        for <linux-mm@kvack.org>; Sat, 03 Jun 2017 01:36:52 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id o126si10689216oih.92.2017.06.03.01.36.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 03 Jun 2017 01:36:51 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170601132808.GD9091@dhcp22.suse.cz>
	<20170601151022.b17716472adbf0e6d51fb011@linux-foundation.org>
	<20170602071818.GA29840@dhcp22.suse.cz>
	<20170602125944.b35575ccb960e467596cf880@linux-foundation.org>
	<20170603073221.GB21524@dhcp22.suse.cz>
In-Reply-To: <20170603073221.GB21524@dhcp22.suse.cz>
Message-Id: <201706031736.DHB82306.QOOHtVFFSJFOLM@I-love.SAKURA.ne.jp>
Date: Sat, 3 Jun 2017 17:36:35 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz, sergey.senozhatsky@gmail.com, pmladek@suse.com

Michal Hocko wrote:
> On Fri 02-06-17 12:59:44, Andrew Morton wrote:
> > On Fri, 2 Jun 2017 09:18:18 +0200 Michal Hocko <mhocko@suse.com> wrote:
> >
> > > On Thu 01-06-17 15:10:22, Andrew Morton wrote:
> > > > On Thu, 1 Jun 2017 15:28:08 +0200 Michal Hocko <mhocko@suse.com> wrote:
> > > >
> > > > > On Thu 01-06-17 22:11:13, Tetsuo Handa wrote:
> > > > > > Michal Hocko wrote:
> > > > > > > On Thu 01-06-17 20:43:47, Tetsuo Handa wrote:
> > > > > > > > Cong Wang has reported a lockup when running LTP memcg_stress test [1].
> > > > > > >
> > > > > > > This seems to be on an old and not pristine kernel. Does it happen also
> > > > > > > on the vanilla up-to-date kernel?
> > > > > >
> > > > > > 4.9 is not an old kernel! It might be close to the kernel version which
> > > > > > enterprise distributions would choose for their next long term supported
> > > > > > version.
> > > > > >
> > > > > > And please stop saying "can you reproduce your problem with latest
> > > > > > linux-next (or at least latest linux)?" Not everybody can use the vanilla
> > > > > > up-to-date kernel!
> > > > >
> > > > > The changelog mentioned that the source of stalls is not clear so this
> > > > > might be out-of-tree patches doing something wrong and dump_stack
> > > > > showing up just because it is called often. This wouldn't be the first
> > > > > time I have seen something like that. I am not really keen on adding
> > > > > heavy lifting for something that is not clearly debugged and based on
> > > > > hand waving and speculations.
> > > >
> > > > I'm thinking we should serialize warn_alloc anyway, to prevent the
> > > > output from concurrent calls getting all jumbled together?
> > >
> > > dump_stack already serializes concurrent calls.
> >
> > Sure.  But warn_alloc() doesn't.
>
> I really do not see why that would be much better, really. warn_alloc is
> more or less one line + dump_stack + warn_alloc_show_mem. Single line
> shouldn't be a big deal even though this is a continuation line
> actually. dump_stack already contains its own synchronization and the
> meminfo stuff is ratelimited to one per second. So why do we exactly
> wantt to put yet another lock on top? Just to stick them together? Well
> is this worth a new lock dependency between memory allocation and the
> whole printk stack or dump_stack? Maybe yes but this needs a much deeper
> consideration.

You are completely ignoring the fact that writing to consoles needs CPU time.
My proposal is intended for not only grouping relevant lines together but also
giving logbuf readers (currently a thread which is inside console_unlock(),
which might be offloaded to a dedicated kernel thread in near future) CPU time
for writing to consoles.

>
> Tetsuo is arguing that the locking will throttle warn_alloc callers and
> that can help other processes to move on. I would call it papering over
> a real issue which might be somewhere else and that is why I push back so
> hard. The initial report is far from complete and seeing 30+ seconds
> stalls without any indication that this is just a repeating stall after
> 10s and 20s suggests that we got stuck somewhere in the reclaim path.

That timestamp jump is caused by the fact that log_buf writers are consuming
more CPU times than log_buf readers can consume. If I leave that situation
more, printk() just starts printing "** %u printk messages dropped ** " line.

There is nothing more to reclaim, allocating threads are looping with
cond_resched() and schedule_timeout_uninterruptible(1) (which effectively becomes
no-op when there are many other threads doing the same thing) only, logbuf
reader cannot use enough CPU time, and the OOM killer remains oom_lock held
(notice that this timestamp jump is between "invoked oom-killer: " line and
"Out of memory: Kill process " line) which prevents reclaiming memory.

>
> Moreover let's assume that the unfair locking in dump_stack has caused
> the stall. How would an warn_alloc lock help when there are other
> sources of dump_stack all over the kernel?

__alloc_pages_slowpath() is insane as a caller of dump_stack().

Basically __alloc_pages_slowpath() allows doing

  while (1) {
    cond_resched();
    dump_stack();
  }

because all stalling treads can call warn_alloc(). Even though we ratelimit
dump_stack() at both time_after() test and __ratelimit() test like

  while (1) {
    cond_resched();
    if (time_after(jiffies, alloc_start + stall_timeout)) {
      if (!(gfp_mask & __GFP_NOWARN) && __ratelimit(&nopage_rs)) {
        dump_stack();
      }
      stall_timeout += 10 * HZ;
    }
  }

ratelimited threads are still doing

  while (1) {
    cond_resched();
  }

which still obviously remains the source of starving CPU time for
writing to consoles.

This problem won't be solved even if logbuf reader is offloaded to
a kernel thread dedicated for printk().

>
> Seriously, this whole discussion is based on hand waving. Like for
> any other patches, the real issue should be debugged, explained and
> discussed based on known facts, not speculations. As things stand now,
> my NACK still holds. I am not going to waste my time repeating same
> points all over again.

It is not a hand waving. Doing unconstrained printk() loops (with
cond_resched() only) inside kernel is seriously broken. We have to be
careful not to allow CPU time consumption by logbuf writers (e.g.
warn_alloc() from __alloc_pages_slowpath()) because logbuf reader needs
CPU time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
