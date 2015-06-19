Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2CB9B6B0096
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 14:54:34 -0400 (EDT)
Received: by padev16 with SMTP id ev16so90688348pad.0
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 11:54:33 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id kd9si17611083pbc.109.2015.06.19.11.54.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 19 Jun 2015 11:54:33 -0700 (PDT)
Subject: Re: [RFC -v2] panic_on_oom_timeout
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150617125127.GF25056@dhcp22.suse.cz>
	<201506172259.EAI00575.OFQtVFFSHMOLJO@I-love.SAKURA.ne.jp>
	<20150617154159.GJ25056@dhcp22.suse.cz>
	<201506192030.CAH00597.FQVOtFFLOJMHOS@I-love.SAKURA.ne.jp>
	<20150619153620.GI4913@dhcp22.suse.cz>
In-Reply-To: <20150619153620.GI4913@dhcp22.suse.cz>
Message-Id: <201506200354.ABC87533.OFFMtSLOFHJVQO@I-love.SAKURA.ne.jp>
Date: Sat, 20 Jun 2015 03:54:25 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> Yes I was thinking about this as well because the primary assumption
> of the OOM killer is that the victim will release some memory. And it
> doesn't matter whether the OOM killer was constrained or the global
> one. So the above looks good at first sight, I am just afraid it is too
> relaxed for cases where many tasks are sharing mm.

Excuse me for again exceeding the scope of your patch (only trying to handle
sysctl_panic_on_oom == 1 case), but I think my patch (trying to also handle
sysctl_panic_on_oom == 0 case) will not be too relaxed for cases where many
tasks are sharing mm, for my approach can set task_struct->memdie_start
to jiffies for all tasks sharing mm.

> The primary problem that we have is that we do not have any reliable
> under_oom() check and we simply try to approximate it by heuristics
> which work well enough in most cases. I admit that oom_victims is not
> the ideal one and there might be better. As mentioned above we can check
> watermarks on all zones and cancel the timer if at least one allows for
> an allocation. But there are surely downsides of that approach as well
> because the OOM killer could have been triggered for a higher order
> allocation and we might be still under OOM for those requests.

In my approach, threads calling out_of_memory() is considered as somewhat
reliable under_oom() check. I think this is more reliable than checking
watermarks because the caller of out_of_memory() declared that watermark
is still low for that caller.

> > We need to keep track of per global OOM victim's timeout (e.g. "struct
> > task_struct"->memdie_start ) ?
> 
> I do not think this will help anything. It will just lead to a different
> set of corner cases. E.g.
> 
> 1) mark_oom_victim(T1) memdie_start = jiffies
> 2) fatal_signal_pending(T2) memdie_start = jiffies + delta
> 3) T2 releases memory - No OOM anymore
> 4) out_of_memory - check_memdie_timeout(T1) - KABOOM

Two possible corner cases for my approach are shown below.

One case is that the system can not panic of threads are unable to call
out_of_memory() for some reason.

The other case is that the system will panic if a sequence shown below
occurred.

  (1) First round of OOM state begins.
  (2) Somebody calls out_of_memory().
  (3) OOM victim threads assign jiffies to their memdie_start.
  (4) Somebody else releases memory before timeout expires.
  (5) There comes a moment where nobody needs to call out_of_memory()
      because watermark is no longer low.
  (6) First round of OOM state ends.
  (7) Some of OOM victim threads remain stuck for some reason.
  (8) There comes a moment where somebody needs to call out_of_memory()
      because watermark is again low.
  (9) Second round of OOM state begins.
  (10) Somebody calls out_of_memory().
  (11) The caller of out_of_memory() finds memdie_start which was
       assigned by first round of OOM state. But since the caller of
       out_of_memory() cannot tell whether memdie_start is assigned by
       first round of OOM state or not, the caller will use memdie_start
       as if assigned by second round of OOM state.
  (12) The timeout comes earlier than it should be.

If (7) does not last till (12), we will not hit this case.

If we can distinguish round number of OOM state (e.g. srcu_read_lock() at
memory allocation entry and srcu_read_unlock() at memory allocation return,
while synchronize_srcu() from kernel thread for OOM-killer), we will not hit
this case because (11) will not occur. Well, maybe just comparing
current->oom_start (assigned before calling out_of_memory() for the first
time of this memory allocation request) and victim->memdie_start can do it?

  if (time_after(current->oom_start, victim->memdie_start)) {
    if (time_after(jiffies, current->oom_start + timeout))
      panic();
  } else {
    if (time_after(jiffies, victim->memdie_start + timeout))
      panic();
  }

Well, if without analysis purpose,

  if (time_after(jiffies, oom_start + sysctl_panic_on_oom_timeout * HZ))
    panic();

(that is, pass the jiffies as of calling out_of_memory() for the first time
of this memory allocation request as an argument to out_of_memory(), and
compare at check_panic_on_oom()) is sufficient? Very simple implementation
because we do not use mod_timer()/del_timer().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
