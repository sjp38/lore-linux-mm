Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 146E16B0032
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 11:56:05 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id n3so28545168wiv.7
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 08:56:04 -0800 (PST)
Received: from mail-wg0-x233.google.com (mail-wg0-x233.google.com. [2a00:1450:400c:c00::233])
        by mx.google.com with ESMTPS id bw9si13990436wjc.94.2014.12.04.08.56.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 04 Dec 2014 08:56:04 -0800 (PST)
Received: by mail-wg0-f51.google.com with SMTP id k14so22993827wgh.38
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 08:56:03 -0800 (PST)
Date: Thu, 4 Dec 2014 17:56:01 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 2/2] OOM, PM: make OOM detection in the freezer path
 raceless
Message-ID: <20141204165601.GD25001@dhcp22.suse.cz>
References: <20141118210833.GE23640@dhcp22.suse.cz>
 <1416345006-8284-1-git-send-email-mhocko@suse.cz>
 <1416345006-8284-2-git-send-email-mhocko@suse.cz>
 <20141202220804.GS10918@htj.dyndns.org>
 <20141204141623.GA25001@dhcp22.suse.cz>
 <20141204144454.GB15219@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141204144454.GB15219@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-pm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>

On Thu 04-12-14 09:44:54, Tejun Heo wrote:
> On Thu, Dec 04, 2014 at 03:16:23PM +0100, Michal Hocko wrote:
> > > A delta but shouldn't it be pr_cont()?
> > 
> > kernel/power/process.c doesn't use pr_* so I've stayed with what the
> > rest of the file is using. I can add a patch which transforms all of
> > them.
> 
> The console output becomes wrong when printk() is used on
> continuation.  So, yeah, it'd be great to fix it.
> 
> > > > +extern bool oom_killer_disabled;
> > > 
> > > Ugh... don't we wanna put this in a header file?
> > 
> > Who else would need the declaration? This is not something random code
> > should look at.
> 
> Let's say, somebody changes the type to ulong for whatever reason
> later and forgets to update this declaration.  What happens then on a
> big endian machine?

OK, see your point. Although this is unlikely...
 
> Jesus, this is basic C programming.  You don't sprinkle external
> declarations which the compiler can't verify against the actual
> definitions.  There's absolutely no compelling reason to do that here.
> Why would you take out compiler verification for no reason?
> 
> > > > +void mark_tsk_oom_victim(struct task_struct *tsk)
> > > >  {
> > > > -	return atomic_read(&oom_kills);
> > > > +	BUG_ON(oom_killer_disabled);
> > > 
> > > WARN_ON_ONCE() is prolly a better option here?
> > 
> > Well, something fishy is going on when oom_killer_disabled is set and we
> > mark new OOM victim. This is a clear bug. Why would be warning and a
> > allow the follow up breakage?
> 
> Because the system is more likely to be able to go on and we don't BUG
> when we can WARN as a general rule.  Working systems is almost always
> better than a dead system even for debugging.
> 
> > > > +	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
> > > 
> > > Can a task actually be selected as an OOM victim multiple times?
> > 
> > AFAICS nothing prevents from global OOM and memcg OOM killers racing.
> 
> Maybe it'd be a good idea to note that in the comment?

ok

> > > > -void note_oom_kill(void)
> > > > +void unmark_tsk_oom_victim(struct task_struct *tsk)
> > > >  {
> > > > -	atomic_inc(&oom_kills);
> > > > +	int count;
> > > > +
> > > > +	if (!test_and_clear_tsk_thread_flag(tsk, TIF_MEMDIE))
> > > > +		return;
> > > 
> > > Maybe test this inline in exit_mm()?  e.g.
> > > 
> > > 	if (test_thread_flag(TIF_MEMDIE))
> > > 		unmark_tsk_oom_victim(current);
> > 
> > Why do you think testing TIF_MEMDIE in exit_mm is better? I would like
> > to reduce the usage of the flag as much as possible.
> 
> Because it's adding a function call/return to hot path for everybody.
> It sure is a miniscule cost but we're adding that for no good reason.

ok. 
 
> > > So, each complete() increments the done count and wait decs.  The
> > > above code works iff the complete()'s and wait()'s are always balanced
> > > which usually isn't true in this type of wait code.  Either use
> > > reinit_completion() / complete_all() combos or wait_event().
> > 
> > Hmm, I thought that only a single instance of freeze_kernel_threads
> > (which calls oom_killer_disable) can run at a time. But I am currently
> > not sure that all paths are called under lock_system_sleep.
> > I am not familiar with reinit_completion API. Is the following correct?
> 
> Hmmm... wouldn't wait_event() easier to read in this case?

OK, it looks easier. I thought it would require some additional
synchronization between wake up and wait but everything necessary seems
to be done in wait_event already so we cannot miss a wake up AFAICS:

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1d55ab12792f..032be9d2a239 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -408,7 +408,7 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
  * Number of OOM victims in flight
  */
 static atomic_t oom_victims = ATOMIC_INIT(0);
-static DECLARE_COMPLETION(oom_victims_wait);
+static DECLARE_WAIT_QUEUE_HEAD(oom_victims_wait);
 
 bool oom_killer_disabled __read_mostly;
 static DECLARE_RWSEM(oom_sem);
@@ -435,7 +435,7 @@ void unmark_tsk_oom_victim(void)
 	 * is nobody who cares.
 	 */
 	if (!atomic_dec_return(&oom_victims) && oom_killer_disabled)
-		complete_all(&oom_victims_wait);
+		wake_up_all(&oom_victims_wait);
 	up_read(&oom_sem);
 }
 
@@ -464,16 +464,11 @@ bool oom_killer_disable(void)
 		return false;
 	}
 
-	/* unmark_tsk_oom_victim is calling complete_all */
-	if (!oom_killer_disable)
-		reinit_completion(&oom_victims_wait);
-
 	oom_killer_disabled = true;
-	count = atomic_read(&oom_victims);
 	up_write(&oom_sem);
 
 	if (count)
-		wait_for_completion(&oom_victims_wait);
+		wait_event(oom_victims_wait, atomic_read(&oom_victims));
 
 	return true;
 }

> ...
> > > Maybe 0 / -errno is better choice as return values?
> > 
> > I do not have problem to change this if you feel strong about it but
> > true/false sounds easier to me and it allows the caller to decide what to
> > report. If there were multiple reasons to fail then sure but that is not
> > the case.
> 
> It's not a big deal but except for functions which have clear boolean
> behavior - functions which try/attempt something or query or decide

this is basically try_lock which might fail due to whatever internal
reasons.

> certain things - randomly thrown in bool returns tend to become
> confusing especially because its bool fail value is the opposite of
> 0/-errno fail value.  So, "this function only fails with one reason"
> is usually a bad and arbitrary reason for choosing bool return which
> causes confusion on callsites and headaches when the function develops
> more reasons to fail.
> 
> ...
> > > > @@ -712,12 +770,16 @@ void pagefault_out_of_memory(void)
> > > >  {
> > > >  	struct zonelist *zonelist;
> > > >  
> > > > +	down_read(&oom_sem);
> > > >  	if (mem_cgroup_oom_synchronize(true))
> > > > -		return;
> > > > +		goto unlock;
> > > >  
> > > >  	zonelist = node_zonelist(first_memory_node, GFP_KERNEL);
> > > >  	if (oom_zonelist_trylock(zonelist, GFP_KERNEL)) {
> > > > -		out_of_memory(NULL, 0, 0, NULL, false);
> > > > +		if (!oom_killer_disabled)
> > > > +			__out_of_memory(NULL, 0, 0, NULL, false);
> > > >  		oom_zonelist_unlock(zonelist, GFP_KERNEL);
> > > 
> > > Is this a condition which can happen and we can deal with? With
> > > userland fully frozen, there shouldn't be page faults which lead to
> > > memory allocation, right?
> > 
> > Except for racing OOM victims which were missed by try_to_freeze_tasks
> > because they didn't get cpu slice to wake up from the freezer. The task
> > would die on the way out from the page fault exception. I have updated
> > the changelog to be more verbose about this.
> 
> That's something very not obvious.  Let's please add a comment
> explaining that.

@@ -778,6 +795,15 @@ void pagefault_out_of_memory(void)
 	if (oom_zonelist_trylock(zonelist, GFP_KERNEL)) {
 		if (!oom_killer_disabled)
 			__out_of_memory(NULL, 0, 0, NULL, false);
+		else
+			/*
+			 * There shouldn't be any user tasks runable while the
+			 * OOM killer is disabled so the current task has to
+			 * be a racing OOM victim for which oom_killer_disable()
+			 * is waiting for.
+			 */
+			WARN_ON(test_thread_flag(TIF_MEMDIE));
+
 		oom_zonelist_unlock(zonelist, GFP_KERNEL);
 	}
 unlock:

> 
> > > (it only makes sense while the whole system is in quiescent state)
> > > and at least trigger WARN_ON_ONCE() if the above code path gets
> > > triggered while oom killer is disabled?
> > 
> > I can add a WARN_ON(!test_thread_flag(tsk, TIF_MEMDIE)).
> 
> Yeah, that makes sense to me.
> 
> Thanks.
> 
> -- 
> tejun

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
