Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 923D46B0038
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 07:49:49 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id b82so134621477iod.10
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 04:49:49 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t7si11125129itd.123.2017.04.18.04.49.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 04:49:48 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: Split stall warning and failure warning.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1491825493-8859-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170410150308.c6e1a0213c32e6d587b33816@linux-foundation.org>
	<alpine.DEB.2.10.1704171539190.46404@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1704171539190.46404@chino.kir.corp.google.com>
Message-Id: <201704182049.BIE34837.FJOFOMFOQSLHVt@I-love.SAKURA.ne.jp>
Date: Tue, 18 Apr 2017 20:49:20 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, mhocko@kernel.org, sgruszka@redhat.com

David Rientjes wrote:
> On Mon, 10 Apr 2017, Andrew Morton wrote:
> > I interpret __GFP_NOWARN to mean "don't warn about this allocation
> > attempt failing", not "don't warn about anything at all".  It's a very
> > minor issue but yes, methinks that stall warning should still come out.
> > 
> 
> Agreed, and we have found this to be helpful in automated memory stress 
> tests.
> 
> I agree that masking off __GFP_NOWARN and then reporting the gfp_mask to 
> the user is only harmful.  If the allocation stalls vs allocation failure 
> warnings are separated such as you have done, it is easily preventable.
> 
> I have a couple of suggestions for Tetsuo about this patch, though:
> 
>  - We now have show_mem_rs, stall_rs, and nopage_rs.  Ugh.  I think it's
>    better to get rid of show_mem_rs and let warn_alloc_common() not 
>    enforce any ratelimiting at all and leave it to the callers.

Commit aa187507ef8bb317 ("mm: throttle show_mem() from warn_alloc()") says
that show_mem_rs was added because a big part of the output is show_mem()
which can generate a lot of output even on a small machines. Thus, I think
ratelimiting at warn_alloc_common() makes sense for users who want to use
warn_alloc_stall() for reporting stalls.

> 
>  - warn_alloc() is probably better off renamed to warn_alloc_failed()
>    since it enforces __GFP_NOWARN and uses an allocation failure ratelimit 
>    regardless of what the passed text is.

I'm OK to rename warn_alloc() back to warn_alloc_failed() for reporting
allocation failures. Maybe we can remove debug_guardpage_minorder() > 0
check from warn_alloc_failed() anyway.

> 
> It may also be slightly off-topic, but I think it would be useful to print 
> current's pid.  I find printing its parent's pid and comm helpful when 
> using shared libraries, but you may not agree.

I think additional actions such as printing more variables can be controlled
using SystemTap (or IO Visor) hooks as long as triggers and relevant
information are available. For example, running

----------
# stap -DSTP_NO_OVERLOAD=1 -F -g -e 'function gfp_str:string(gfp_flags:long) %{ snprintf(STAP_RETVALUE, MAXSTRINGLEN, "%pGg", &STAP_ARG_gfp_flags); %}
probe kernel.function("warn_alloc") { printk(6, sprintf("MemAlloc gfp=%#x(%s) self=%s/%u parent=%s/%u", $gfp_mask, gfp_str($gfp_mask), execname(), pid(), pexecname(), ppid())); }'
----------

will give us output like below.

----------
[  275.848932] MemAlloc gfp=0x142134a(GFP_NOFS|__GFP_HIGHMEM|__GFP_COLD|__GFP_NOWARN|__GFP_NORETRY|__GFP_HARDWALL|__GFP_MOVABLE) self=systemd/1 parent=swapper/0/0
[  276.434211] MemAlloc gfp=0x142134a(GFP_NOFS|__GFP_HIGHMEM|__GFP_COLD|__GFP_NOWARN|__GFP_NORETRY|__GFP_HARDWALL|__GFP_MOVABLE) self=a.out/3339 parent=a.out/2371
[  276.456524] MemAlloc gfp=0x142134a(GFP_NOFS|__GFP_HIGHMEM|__GFP_COLD|__GFP_NOWARN|__GFP_NORETRY|__GFP_HARDWALL|__GFP_MOVABLE) self=systemd-journal/566 parent=systemd/1
[  276.463857] MemAlloc gfp=0x142134a(GFP_NOFS|__GFP_HIGHMEM|__GFP_COLD|__GFP_NOWARN|__GFP_NORETRY|__GFP_HARDWALL|__GFP_MOVABLE) self=gmain/703 parent=systemd/1
[  276.560590] MemAlloc gfp=0x142134a(GFP_NOFS|__GFP_HIGHMEM|__GFP_COLD|__GFP_NOWARN|__GFP_NORETRY|__GFP_HARDWALL|__GFP_MOVABLE) self=rs:main Q:Reg/1013 parent=systemd/1
[  276.643430] MemAlloc gfp=0x142134a(GFP_NOFS|__GFP_HIGHMEM|__GFP_COLD|__GFP_NOWARN|__GFP_NORETRY|__GFP_HARDWALL|__GFP_MOVABLE) self=tuned/1019 parent=systemd/1
[  276.654054] MemAlloc gfp=0x142134a(GFP_NOFS|__GFP_HIGHMEM|__GFP_COLD|__GFP_NOWARN|__GFP_NORETRY|__GFP_HARDWALL|__GFP_MOVABLE) self=postgres/2220 parent=postgres/1561
[  276.668904] postgres invoked oom-killer: gfp_mask=0x14201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), nodemask=(null),  order=0, oom_score_adj=0
[  276.676866] postgres cpuset=/ mems_allowed=0
[  276.679809] CPU: 3 PID: 2220 Comm: postgres Tainted: G           OE   4.11.0-rc7 #217
----------

Thus, passing relevant information as-is

  warn_alloc_stall(gfp_t gfp_mask, nodemask_t *nodemask, unsigned long alloc_start, int order)

rather than via printf() arguments

  warn_alloc(gfp_mask & ~__GFP_NOWARN, ac->nodemask, "page allocation stalls for %ums, order:%u", jiffies_to_msecs(jiffies-alloc_start), order);

will give us a lot of flexibility including e.g. ratelimit calling
show_mem() using timers.

If relevant information were available via off-stack memory (e.g. via
"struct task_struct"), kmallocwd-like behavior which allows us to report
all possibly-relevant threads timely (and take actions including e.g.
taking memory snapshots for analysis via commands sent from KVM host
environment if running as a KVM guest as a reaction to kernel messages
sent via netconsole) becomes possible rather than
needlessly-spammable-and-possibly-unreportable after-the-fact stall reports.

> 
> Otherwise, I think this is a good direction.

So, here we got a conflict. Michal thinks this is a pointless code and
David thinks this is a good direction. Michal, can you accept
warn_alloc_stall()/warn_alloc_failed() separation?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
