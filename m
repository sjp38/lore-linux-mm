Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8BA406B0253
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 07:37:55 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v78so16843410pgb.18
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 04:37:55 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i22si1504517pll.767.2017.10.25.04.37.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Oct 2017 04:37:53 -0700 (PDT)
Subject: Re: [RFC PATCH 2/2] mm,oom: Try last second allocation after selecting an OOM victim.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171020124009.joie5neol3gbdmxe@dhcp22.suse.cz>
	<201710202318.IJE26050.SFVFMOLHQJOOtF@I-love.SAKURA.ne.jp>
	<20171023113057.bdfte7ihtklhjbdy@dhcp22.suse.cz>
	<201710242024.EDH13579.VQLFtFFMOOHSOJ@I-love.SAKURA.ne.jp>
	<20171024114104.twg73jvyjevovkjm@dhcp22.suse.cz>
In-Reply-To: <20171024114104.twg73jvyjevovkjm@dhcp22.suse.cz>
Message-Id: <201710251948.EJH00500.MOOStFLFQOHFJV@I-love.SAKURA.ne.jp>
Date: Wed, 25 Oct 2017 19:48:09 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: aarcange@redhat.com, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, mjaggi@caviumnetworks.com, mgorman@suse.de, oleg@redhat.com, vdavydov.dev@gmail.com, vbabka@suse.cz

Michal Hocko wrote:
> On Tue 24-10-17 20:24:46, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> [...]
> > > > So, I think that worrying about high priority threads preventing the low
> > > > priority thread with oom_lock held is too much. Preventing high priority
> > > > threads waiting for oom_lock from disturbing the low priority thread with
> > > > oom_lock held by wasting CPU resource will be sufficient.
> > > 
> > > In other words this is just to paper over an overloaded allocation path
> > > close to OOM. Your changelog is really misleading in that direction
> > > IMHO. I have to think some more about using the full lock rather than
> > > the trylock, because taking the try lock is somehow easier.
> > 
> > Somehow easier to what? Please don't omit.
> 
> To back off on the oom races.
> 

But that choice is breaking the

        /*
         * Acquire the oom lock.  If that fails, somebody else is
         * making progress for us.
         */

assumption due to warn_alloc() since Linux 4.9 unless at least
below patch is applied.

--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4002,7 +4002,8 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 		goto nopage;
 
 	/* Make sure we know about allocations which stall for too long */
-	if (time_after(jiffies, alloc_start + stall_timeout)) {
+	if (time_after(jiffies, alloc_start + stall_timeout) &&
+	    !mutex_is_locked(&oom_lock)) {
 		warn_alloc(gfp_mask & ~__GFP_NOWARN, ac->nodemask,
 			"page allocation stalls for %ums, order:%u",
 			jiffies_to_msecs(jiffies-alloc_start), order);
--

> > I consider that the OOM killer is a safety mechanism in case a system got
> > overloaded. Therefore, I really hate your comments like "Your system is already
> > DOSed". It is stupid thing that safety mechanism drives the overloaded system
> > worse and defunctional when it should rescue.
> 
> The OOM killer is the last hand break. At the time you hit the OOM
> condition your system is usually hard to use anyway. And that is why I
> do care to make this path deadlock free. I have mentioned multiple times
> that I find real life triggers much more important than artificial DoS
> like workloads which make your system unsuable long before you hit OOM
> killer.

Unable to invoke the OOM killer (i.e. OOM lockup) is worse than hand break injury.

If you do care to make this path deadlock free, you had better stop depending on
mutex_trylock(&oom_lock). Not only printk() from oom_kill_process() can trigger
deadlock due to console_sem versus oom_lock dependency but also
schedule_timeout_killable(1) from out_of_memory() can also trigger deadlock
due to SCHED_IDLE versus !SCHED_IDLE dependency (like I suggested at 
http://lkml.kernel.org/r/201603031941.CBC81272.OtLMSFVOFJHOFQ@I-love.SAKURA.ne.jp ).

> 
> > Current code is somehow easier to OOM lockup due to printk() versus oom_lock
> > dependency, and I'm proposing a patch for mitigating printk() versus oom_lock
> > dependency using oom_printk_lock because I can hardly examine OOM related
> > problems since linux-4.9, and your response was "Hell no!".
> 
> Because you are repeatedly proposing a paper over rather than to attempt
> something resembling a solution. And this is highly annoying. I've
> already said that I am willing to sacrifice the stall warning rather
> than fiddle with random locks put here and there.

I've already said that I do welcome removing the stall warning if it is
replaced with a better approach. If there is no acceptable alternative now,
I do want to avoid "warn_alloc() without oom_lock held" versus
"oom_kill_process() with oom_lock held" dependency. And I'm waiting for your
answer in that thread.

> 
> > > > If you don't like it, the only way will be to offload to a dedicated
> > > > kernel thread (like the OOM reaper) so that allocating threads are
> > > > no longer blocked by oom_lock. That's a big change.
> > > 
> > > This doesn't solve anything as all the tasks would have to somehow wait
> > > for the kernel thread to do its stuff.
> > 
> > Which direction are you looking at?
> 
> I am sorry but I would only repeat something that has been said many
> times already. You keep hammering this particular issue like it was the
> number one problem in the MM code. We have many much more important
> issues to deal with. While it is interesting to make kernel more robust
> under OOM conditions it doesn't make much sense to overcomplicate the
> code for unrealistic workloads. If we have problems with real life
> scenarios then let's fix them, by all means.

You are misunderstanding again. My goal is not to put systems under unrealistic
workloads. My goal is to provide better debugging information when a memory
allocation related problem occurred (such as unexpected infinite loop or too
long waiting). Since there is no asynchronous watchdog, we have to test whether
it is possible to hit corner cases (e.g. infinite too_many_isolated() loop in
shrink_inactive_list()) using a kind of fuzzing approach. Creating hundreds of
processes and let each child to free memory bit by bit is needed for testing
almost OOM situations. What I'm doing is handmade OOM fuzzing.

The warn_alloc() for reporting allocation stalls (which is synchronous mechanism)
is failing to provide information other than "something is going wrong". And so far
nobody (except I) is interested in asynchronous mechanism which would allow
triggering more actions such as turning on vmscan tracepoints at
http://lkml.kernel.org/r/20171024200639.2pyxkw2cucwxrtlb@dhcp22.suse.cz .

Since that system has 32GB memory and 64GB swap, and chrome browser which
might eat a lot of memory is running, and 3.5GB of swap is in use, I suspect
the possibility that disk I/O was not done smoothly because any allocation
which allocates from Node 0 Normal was already hitting min watermark.
But I'm not sure whether vmscan tracepoints can provide enough information, nor
whether it is possible to save the information to files under OOM situation. If
printk() were used for dumping the information using serial console or netconsole,
we would want to avoid mixing the output with the stall warning and/or the OOM
killer messages.

Despite you have said

  So let's agree to disagree about importance of the reliability
  warn_alloc. I see it as an improvement which doesn't really have to be
  perfect.

at https://patchwork.kernel.org/patch/9381891/ , can we agree with killing
the synchronous allocation stall warning messages and start seeking for
asynchronous approach?

--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3868,8 +3868,6 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	enum compact_result compact_result;
 	int compaction_retries;
 	int no_progress_loops;
-	unsigned long alloc_start = jiffies;
-	unsigned int stall_timeout = 10 * HZ;
 	unsigned int cpuset_mems_cookie;
 	int reserve_flags;
 
@@ -4001,14 +3999,6 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	if (!can_direct_reclaim)
 		goto nopage;
 
-	/* Make sure we know about allocations which stall for too long */
-	if (time_after(jiffies, alloc_start + stall_timeout)) {
-		warn_alloc(gfp_mask & ~__GFP_NOWARN, ac->nodemask,
-			"page allocation stalls for %ums, order:%u",
-			jiffies_to_msecs(jiffies-alloc_start), order);
-		stall_timeout += 10 * HZ;
-	}
-
 	/* Avoid recursion of direct reclaim */
 	if (current->flags & PF_MEMALLOC)
 		goto nopage;
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
