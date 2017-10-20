Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id B750F6B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 06:20:44 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id p186so10514103ioe.9
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 03:20:44 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w142si799051itc.87.2017.10.20.03.20.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Oct 2017 03:20:42 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: Serialize out_of_memory() and allocation stall messages.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1508410262-4797-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171019114424.4db2hohyyogpjq5f@dhcp22.suse.cz>
In-Reply-To: <20171019114424.4db2hohyyogpjq5f@dhcp22.suse.cz>
Message-Id: <201710201920.FCE43223.FQMVJOtOOSFFLH@I-love.SAKURA.ne.jp>
Date: Fri, 20 Oct 2017 19:20:26 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xiyou.wangcong@gmail.com, hannes@cmpxchg.org, pmladek@suse.com, sergey.senozhatsky@gmail.com, yuwang.yuwang@alibaba-inc.com

Michal Hocko wrote:
> On Thu 19-10-17 19:51:02, Tetsuo Handa wrote:
> > The printk() flooding problem caused by concurrent warn_alloc() calls was
> > already pointed out by me, and there are reports of soft lockups caused by
> > warn_alloc(). But this problem is left unhandled because Michal does not
> > like serialization from allocation path because he is worrying about
> > unexpected side effects and is asking to identify the root cause of soft
> > lockups and fix it. But at least consuming CPU resource by not serializing
> > concurrent printk() plays some role in the soft lockups, for currently
> > printk() can consume CPU resource forever as long as somebody is appending
> > to printk() buffer, and writing to consoles also needs CPU resource. That
> > is, needlessly consuming CPU resource when calling printk() has unexpected
> > side effects.
> > 
> > Although a proposal for offloading writing to consoles to a dedicated
> > kernel thread is in progress, it is not yet accepted. And, even after
> > the proposal is accepted, writing to printk() buffer faster than the
> > kernel thread can write to consoles will result in loss of messages.
> > We should refrain from "appending to printk() buffer" and "consuming CPU
> > resource" at the same time if possible. We should try to (and we can)
> > avoid appending to printk() buffer when printk() is concurrently called
> > for reporting the OOM killer and allocation stalls, in order to reduce
> > possibility of hitting soft lockups and getting unreadably-jumbled
> > messages.
> > 
> > Although avoid mixing both memory allocation stall/failure messages and
> > the OOM killer messages would be nice, oom_lock mutex should not be used
> > for this purpose, for waiting for oom_lock mutex at warn_alloc() can
> > prevent anybody from calling out_of_memory() from __alloc_pages_may_oom()
> > because currently __alloc_pages_may_oom() does not wait for oom_lock
> > (i.e. causes OOM lockups after all). Therefore, this patch adds a mutex
> > named "oom_printk_lock". Although using mutex_lock() in order to allow
> > printk() to use CPU resource for writing to consoles is better from the
> > point of view of flushing printk(), this patch uses mutex_trylock() for
> > allocation stall messages because Michal does not like serialization.
> 
> Hell no! I've tried to be patient with you but it seems that is just
> pointless waste of time. Such an approach is absolutely not acceptable.
> You are adding an additional lock dependency into the picture. Say that
> there is somebody stuck in warn_alloc path and cannot make a further
> progress because printk got stuck. Now you are blocking oom_kill_process
> as well. So the cure might be even worse than the problem.

Sigh... printk() can't get stuck unless somebody continues appending to
printk() buffer. Otherwise, printk() cannot be used from arbitrary context.

You had better stop calling printk() with oom_lock held if you consider that
printk() can get stuck.

I will say "Say that there is somebody stuck in oom_kill_process() path and
cannot make a further progress because printk() got stuck. Now you are keeping
the mutex_trylock(&oom_lock) thread who invoked the OOM killer defunctional by
forcing the !mutex_trylock(&oom_lock) threads to keep calling warn_alloc().
So calling warn_alloc() might be even worse than not calling warn_alloc()."
This is known as what we call printk() v.s. oom_lock deadlock which I can
observe with my stress tests.

If somebody continues appending to printk() buffer, such user has to be fixed.
And it is warn_alloc() who continues appending to printk() buffer. This patch
is for breaking the printk() continuation dependency by isolating each thread's
transaction. Despite this patch introduces a lock dependency, this patch is for
mitigating printk() v.s. oom_lock deadlock described above. (I said "mitigate"
rather than "remove", for other printk() sources if any could still preserve
printk() v.s. oom_lock deadlock.)

---------- Pseudo code start ----------
Before warn_alloc() was introduced:

  retry:
    if (mutex_trylock(&oom_lock)) {
      while (atomic_read(&printk_pending_logs) > 0) {
        atomic_dec(&printk_pending_logs);
        print_one_log();
      }
      // Send SIGKILL here.
      mutex_unlock(&oom_lock)
    }
    goto retry;

After warn_alloc() was introduced:

  retry:
    if (mutex_trylock(&oom_lock)) {
      while (atomic_read(&printk_pending_logs) > 0) {
        atomic_dec(&printk_pending_logs);
        print_one_log();
      }
      // Send SIGKILL here.
      mutex_unlock(&oom_lock)
    } else if (waited_for_10seconds()) {
      atomic_inc(&printk_pending_logs);
    }
    goto retry;

Note that although waited_for_10seconds() becomes true once for 10 seconds,
unbounded number of threads can call waited_for_10seconds() at the same time.
Also, since threads doing waited_for_10seconds() keep doing almost busy loop,
the thread doing print_one_log() can use little CPU resource. As a result,
it is possible to keep the thread doing print_one_log() looping forever.

After this patch is applied:

  retry:
    if (mutex_trylock(&oom_lock)) {
      mutex_lock(&oom_printk_lock);
      while (atomic_read(&printk_pending_logs) > 0) {
        atomic_dec(&printk_pending_logs);
        print_one_log();
      }
      // Send SIGKILL here.
      mutex_unlock(&oom_printk_lock);
      mutex_unlock(&oom_lock)
    } else if (waited_for_10seconds()) {
      if (mutex_trylock(&oom_printk_lock)) {
        atomic_inc(&printk_pending_logs);
        mutex_unlock(&oom_printk_lock);
      }
    }
    goto retry;

---------- Pseudo code end ----------

> 
> If the warn_alloc is really causing issues and you do not want to spend
> energy into identifying _what_ is the actual problem then I would rather
> remove the stall warning than add a fishy code.

That's limitation of synchronous watchdog. Synchronous watchdog is prone to
unexpected results (e.g. too late or frequent reports) and overlooks (e.g.
now-fixed infinite too_many_isolated() loop in shrink_inactive_list() and
now-triaged deadlock at virtballoon_oom_notify() inside out_of_memory()).
I do welcome removing warn_alloc() if it is replaced with a better approach.

As far as I know, warn_alloc() never helped with providing information other
than "something is going wrong".
For example, warn_alloc() was called after 30+ minutes of stall
( https://bugzilla.kernel.org/show_bug.cgi?id=192981 ) though watchdog
should provide information during stalling rather than post stalling.
For another example, Cong Wang's case was just ignored without investigation
( https://bugzilla.redhat.com/show_bug.cgi?id=1492664 ) though Johannes
Weiner's case was not during stress testing. This example is guessed as
"In this case it seems the cgroup operations are being abused.", but I believe
that there is a possibility that system-wide OOM was in progress and cgroup
was irrelevant. That is, oom_lock was held at __alloc_pages_may_oom() by
somebody, and printk() was in progress inside oom_kill_process(). But since
concurrent printk() from warn_alloc() kept appending to printk() buffer,
printk() from oom_kill_process() was not able to make the further progress
unless somebody releases memory. But it is impossible to confirm it because
OOM killer messages were not found within partially written output.

I'm happy to spend energy into identifying _what_ is the actual problem is, but
the actual problem cannot be identified without a lot of trial and error (e.g.
reporting more information including other threads such as the owner of oom_lock
and kswapd-like threads). But infrastructure for doing such trial and error is
so far ignored because it needs serialization in order to get useful information
(basically SysRq-t + SysRq-m, and possibly more depending on the output) where
asynchronous watchdog can do better.

> 
> > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Reported-by: Cong Wang <xiyou.wangcong@gmail.com>
> > Reported-by: yuwang.yuwang <yuwang.yuwang@alibaba-inc.com>
> > Reported-by: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > Cc: Petr Mladek <pmladek@suse.com>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > ---
> >  include/linux/oom.h | 1 +
> >  mm/oom_kill.c       | 5 +++++
> >  mm/page_alloc.c     | 4 +++-
> >  3 files changed, 9 insertions(+), 1 deletion(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
