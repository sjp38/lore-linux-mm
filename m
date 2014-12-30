Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id D23A46B006C
	for <linux-mm@kvack.org>; Tue, 30 Dec 2014 09:22:34 -0500 (EST)
Received: by mail-oi0-f49.google.com with SMTP id a141so31926674oig.8
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 06:22:34 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id u197si23640697oia.139.2014.12.30.06.22.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 30 Dec 2014 06:22:33 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20141220223504.GI15665@dastard>
	<201412211745.ECD69212.LQOFHtFOJMSOFV@I-love.SAKURA.ne.jp>
	<20141229181937.GE32618@dhcp22.suse.cz>
	<201412301542.JEC35987.FFJFOOQtHLSMVO@I-love.SAKURA.ne.jp>
	<20141230112158.GA15546@dhcp22.suse.cz>
In-Reply-To: <20141230112158.GA15546@dhcp22.suse.cz>
Message-Id: <201412302233.HDD82379.FFtOJQVFOOHSML@I-love.SAKURA.ne.jp>
Date: Tue, 30 Dec 2014 22:33:14 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, torvalds@linux-foundation.org

Michal Hocko wrote:
> So the OOM blocked task is sitting in the page fault caused by clearing
> the user buffer. According to your debugging patch this should be
> GFP_HIGHUSER_MOVABLE | __GFP_ZERO allocation which is the case where we
> retry without failing most of the time.

Oops, my debugging patch had a bug. I wanted to print p->gfp_flags but
was printing (p->gfp_flags & __GFP_WAIT). Retested with a fix and result
is http://I-love.SAKURA.ne.jp/tmp/serial-20141230-ab-3.txt.xz .

  static void print_memalloc_info(const struct task_struct *p)
  {
          const gfp_t gfp = p->gfp_flags;
  
          /*
           * __alloc_pages_nodemask() doesn't use smp_wmb() between
           * updating ->gfp_start and ->gfp_flags. But reading stale
           * ->gfp_start value harms nothing but printing bogus duration.
           * Correct duration will be printed when this function is
           * called for the next time.
           */
          if (unlikely(gfp & __GFP_WAIT))
                  printk(KERN_INFO "MemAlloc: %ld jiffies on 0x%x\n",
                         jiffies - p->gfp_start, gfp);
  }

> That being said this doesn't look like a live lock or a lockup. System
> should recover from this state but it might take a lot of time (there
> are hundreds of tasks waiting on the i_mutex lock, each will try to
> allocate and fail and OOM victims will have to get out of the kernel and
> die). I am not sure we can do much about that from the allocator POV. A
> possible way would be refraining from the reclaim efforts when it is
> clear that nothing is really reclaimable. But I suspect this would be
> tricky to get right.

Indeed, this is not a livelock since the task holding the mutex is doing
a !__GFP_FS allocation and is making too-slow-to-wait progress, and the
"waited for" lines are eventually gone.

[  121.017797] b.out           R  running task        0  9999   9982 0x00000088
[  121.019750] MemAlloc: 30542 jiffies on 0x102005a
[  223.486701] b.out           R  running task        0 10008   9982 0x00000080
[  223.488642] MemAlloc: 12242 jiffies on 0x102005a
[  415.695635] b.out           R  running task        0 10013   9982 0x00000080
[  415.697578] MemAlloc: 108210 jiffies on 0x102005a
[  960.228134] b.out           R  running task        0 10013   9982 0x00000080
[  960.230179] MemAlloc: 652090 jiffies on 0x102005a

> > where I think a.out cannot die within reasonable duration due to b.out .
> 
> I am not sure you can have any reasonable time expectation with such a
> huge contention on a single file. Even killing the task manually would
> take quite some time I suspect. Sure, memory pressure makes it all much
> worse.

Not specific to OOM-killer case, but I wish that the stall ends within 10
seconds, for my customers are using watchdog timeout of 11 seconds with
watchdog keep-alive interval of 2 seconds.

I wish that there is a way to record that the process who is supposed to do
watchdog keep-alive operation was unexpectedly blocked for many seconds at
memory allocation. My gfp_start patch works for that purpose.

> > but I think we need to be prepared for cases where sending SIGKILL to
> > all threads sharing the same memory does not help.
> 
> Sure, unkillable tasks are a problem which we have to handle. Having
> GFP_KERNEL allocations looping without way out contributes to this which
> is sad but your current data just show that sometimes it might take ages
> to finish even without that going on.

Can't we replace mutex_lock() / wait_for_completion() with killable versions
where it is safe (in order to reduce locations of unkillable waits)?
I think replacing mutex_lock() in xfs_file_buffered_aio_write() with killable
version is possible because data written by buffered write is not guaranteed
to be flushed until sync() / fsync() / fdatasync() returns.

And can't we detect unkillable TIF_MEMDIE tasks (like checking task's ->state
after a while after TIF_MEMDIE was set)? My sysctl_memdie_timeout_jiffies
patch works for that purpose.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
