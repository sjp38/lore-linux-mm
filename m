Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 116FC6B0032
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 09:16:27 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id h11so34909303wiw.7
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 06:16:26 -0800 (PST)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com. [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id bw20si60012263wib.86.2014.12.04.06.16.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 04 Dec 2014 06:16:26 -0800 (PST)
Received: by mail-wi0-f178.google.com with SMTP id em10so8542666wid.11
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 06:16:26 -0800 (PST)
Date: Thu, 4 Dec 2014 15:16:23 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 2/2] OOM, PM: make OOM detection in the freezer path
 raceless
Message-ID: <20141204141623.GA25001@dhcp22.suse.cz>
References: <20141118210833.GE23640@dhcp22.suse.cz>
 <1416345006-8284-1-git-send-email-mhocko@suse.cz>
 <1416345006-8284-2-git-send-email-mhocko@suse.cz>
 <20141202220804.GS10918@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141202220804.GS10918@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-pm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>

On Tue 02-12-14 17:08:04, Tejun Heo wrote:
> Hello, sorry about the delay.  Was on vacation.
> 
> Generally looks good to me.  Some comments below.
> 
> > @@ -355,8 +355,10 @@ static struct sysrq_key_op sysrq_term_op = {
> >  
> >  static void moom_callback(struct work_struct *ignored)
> >  {
> > -	out_of_memory(node_zonelist(first_memory_node, GFP_KERNEL), GFP_KERNEL,
> > -		      0, NULL, true);
> > +	if (!out_of_memory(node_zonelist(first_memory_node, GFP_KERNEL),
> > +			   GFP_KERNEL, 0, NULL, true)) {
> > +		printk(KERN_INFO "OOM request ignored because killer is disabled\n");
> > +	}
> >  }
> 
> CodingStyle line 157 says "Do not unnecessarily use braces where a
> single statement will do.".

Sure. Fixed

> > +/**
> > + * oom_killer_disable - disable OOM killer
> > + *
> > + * Forces all page allocations to fail rather than trigger OOM killer.
> > + * Will block and wait until all OOM victims are dead.
> > + *
> > + * Returns true if successfull and false if the OOM killer cannot be
> > + * disabled.
> > + */
> > +extern bool oom_killer_disable(void);
> 
> And function comments usually go where the function body is, not where
> the function is declared, no?

Fixed

> > @@ -157,27 +132,11 @@ int freeze_processes(void)
> >  	pm_wakeup_clear();
> >  	printk("Freezing user space processes ... ");
> >  	pm_freezing = true;
> > -	oom_kills_saved = oom_kills_count();
> >  	error = try_to_freeze_tasks(true);
> >  	if (!error) {
> >  		__usermodehelper_set_disable_depth(UMH_DISABLED);
> > -		oom_killer_disable();
> > -
> > -		/*
> > -		 * There might have been an OOM kill while we were
> > -		 * freezing tasks and the killed task might be still
> > -		 * on the way out so we have to double check for race.
> > -		 */
> > -		if (oom_kills_count() != oom_kills_saved &&
> > -		    !check_frozen_processes()) {
> > -			__usermodehelper_set_disable_depth(UMH_ENABLED);
> > -			printk("OOM in progress.");
> > -			error = -EBUSY;
> > -		} else {
> > -			printk("done.");
> > -		}
> > +		printk("done.\n");
> 
> A delta but shouldn't it be pr_cont()?

kernel/power/process.c doesn't use pr_* so I've stayed with what the
rest of the file is using. I can add a patch which transforms all of
them.

> ...
> > @@ -206,6 +165,18 @@ int freeze_kernel_threads(void)
> >  	printk("\n");
> >  	BUG_ON(in_atomic());
> >  
> > +	/*
> > +	 * Now that everything freezable is handled we need to disbale
> > +	 * the OOM killer to disallow any further interference with
> > +	 * killable tasks.
> > +	 */
> > +	printk("Disabling OOM killer ... ");
> > +	if (!oom_killer_disable()) {
> > +		printk("failed.\n");
> > +		error = -EAGAIN;
> > +	} else
> > +		printk("done.\n");
> 
> Ditto on pr_cont() and
>
> CodingStyle line 169 says "This does not apply
> if only one branch of a conditional statement is a single statement;
> in the latter case use braces in both branches:"

Fixed

> > @@ -251,6 +220,9 @@ void thaw_kernel_threads(void)
> >  {
> >  	struct task_struct *g, *p;
> >  
> > +	printk("Enabling OOM killer again.\n");
> 
> Do we really need this printk?  The same goes for Disabling OOM
> killer.  For freezing it makes some sense because freezing may take a
> considerable amount of time and even occassionally fail due to
> timeout.  We aren't really expecting those to happen for OOM victims.

I just considered them useful if there are follow up allocation failure
messages to know that they are due to OOM killer.
I can remove them. 

> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 302e0fc6d121..34bcbb053132 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2128,6 +2128,8 @@ static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
> >  	current->memcg_oom.order = order;
> >  }
> >  
> > +extern bool oom_killer_disabled;
> 
> Ugh... don't we wanna put this in a header file?

Who else would need the declaration? This is not something random code
should look at.

> > +void mark_tsk_oom_victim(struct task_struct *tsk)
> >  {
> > -	return atomic_read(&oom_kills);
> > +	BUG_ON(oom_killer_disabled);
> 
> WARN_ON_ONCE() is prolly a better option here?

Well, something fishy is going on when oom_killer_disabled is set and we
mark new OOM victim. This is a clear bug. Why would be warning and a
allow the follow up breakage?

> > +	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
> 
> Can a task actually be selected as an OOM victim multiple times?

AFAICS nothing prevents from global OOM and memcg OOM killers racing.
 
> > +		return;
> > +	atomic_inc(&oom_victims);
> >  }
> >  
> > -void note_oom_kill(void)
> > +void unmark_tsk_oom_victim(struct task_struct *tsk)
> >  {
> > -	atomic_inc(&oom_kills);
> > +	int count;
> > +
> > +	if (!test_and_clear_tsk_thread_flag(tsk, TIF_MEMDIE))
> > +		return;
> 
> Maybe test this inline in exit_mm()?  e.g.
> 
> 	if (test_thread_flag(TIF_MEMDIE))
> 		unmark_tsk_oom_victim(current);

Why do you think testing TIF_MEMDIE in exit_mm is better? I would like
to reduce the usage of the flag as much as possible.

> Also, can the function ever be called by someone other than current?
> If not, why would it take @task?

Changed to use current only. If there is anybody who needs that we can
change that later. I wanted to have it symmetric to mark_tsk_oom_victim
but that is not that important.

> > +
> > +	down_read(&oom_sem);
> > +	/*
> > +	 * There is no need to signal the lasst oom_victim if there
> > +	 * is nobody who cares.
> > +	 */
> > +	if (!atomic_dec_return(&oom_victims) && oom_killer_disabled)
> > +		complete(&oom_victims_wait);
> 
> I don't think using completion this way is safe.  Please read on.
> 
> > +	up_read(&oom_sem);
> >  }
> >  
> > -void mark_tsk_oom_victim(struct task_struct *tsk)
> > +bool oom_killer_disable(void)
> >  {
> > -	set_tsk_thread_flag(tsk, TIF_MEMDIE);
> > +	/*
> > +	 * Make sure to not race with an ongoing OOM killer
> > +	 * and that the current is not the victim.
> > +	 */
> > +	down_write(&oom_sem);
> > +	if (!test_tsk_thread_flag(current, TIF_MEMDIE))
> > +		oom_killer_disabled = true;
> 
> Prolly "if (TIF_MEMDIE) { unlock; return; }" is easier to follow.

OK

> > +
> > +	count = atomic_read(&oom_victims);
> > +	up_write(&oom_sem);
> > +
> > +	if (count && oom_killer_disabled)
> > +		wait_for_completion(&oom_victims_wait);
> 
> So, each complete() increments the done count and wait decs.  The
> above code works iff the complete()'s and wait()'s are always balanced
> which usually isn't true in this type of wait code.  Either use
> reinit_completion() / complete_all() combos or wait_event().

Hmm, I thought that only a single instance of freeze_kernel_threads
(which calls oom_killer_disable) can run at a time. But I am currently
not sure that all paths are called under lock_system_sleep.
I am not familiar with reinit_completion API. Is the following correct?
[...]
@@ -434,10 +434,23 @@ void unmark_tsk_oom_victim(struct task_struct *tsk)
 	 * is nobody who cares.
 	 */
 	if (!atomic_dec_return(&oom_victims) && oom_killer_disabled)
-		complete(&oom_victims_wait);
+		complete_all(&oom_victims_wait);
 	up_read(&oom_sem);
 }
[...]
@@ -445,16 +458,23 @@ bool oom_killer_disable(void)
 	 * and that the current is not the victim.
 	 */
 	down_write(&oom_sem);
-	if (!test_tsk_thread_flag(current, TIF_MEMDIE))
-		oom_killer_disabled = true;
+	if (test_thread_flag(TIF_MEMDIE)) {
+		up_write(&oom_sem);
+		return false;
+	}
+
+	/* unmark_tsk_oom_victim is calling complete_all */
+	if (!oom_killer_disable)
+		reinit_completion(&oom_victims_wait);
 
+	oom_killer_disabled = true;
 	count = atomic_read(&oom_victims);
 	up_write(&oom_sem);
 
-	if (count && oom_killer_disabled)
+	if (count)
 		wait_for_completion(&oom_victims_wait);
 
-	return oom_killer_disabled;
+	return true;
 }

> > +
> > +	return oom_killer_disabled;
> 
> Maybe 0 / -errno is better choice as return values?

I do not have problem to change this if you feel strong about it but
true/false sounds easier to me and it allows the caller to decide what to
report. If there were multiple reasons to fail then sure but that is not
the case.
 
> > +/** out_of_memory -  tries to invoke OOM killer.
> 
> Formatting?

fixed

> > + * @zonelist: zonelist pointer
> > + * @gfp_mask: memory allocation flags
> > + * @order: amount of memory being requested as a power of 2
> > + * @nodemask: nodemask passed to page allocator
> > + * @force_kill: true if a task must be killed, even if others are exiting
> > + *
> > + * invokes __out_of_memory if the OOM is not disabled by oom_killer_disable()
> > + * when it returns false. Otherwise returns true.
> > + */
> > +bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
> > +		int order, nodemask_t *nodemask, bool force_kill)
> > +{
> > +	bool ret = false;
> > +
> > +	down_read(&oom_sem);
> > +	if (!oom_killer_disabled) {
> > +		__out_of_memory(zonelist, gfp_mask, order, nodemask, force_kill);
> > +		ret = true;
> > +	}
> > +	up_read(&oom_sem);
> > +
> > +	return ret;
> 
> Ditto on return value.  0 / -EBUSY seem like a better choice to me.
> 
> > @@ -712,12 +770,16 @@ void pagefault_out_of_memory(void)
> >  {
> >  	struct zonelist *zonelist;
> >  
> > +	down_read(&oom_sem);
> >  	if (mem_cgroup_oom_synchronize(true))
> > -		return;
> > +		goto unlock;
> >  
> >  	zonelist = node_zonelist(first_memory_node, GFP_KERNEL);
> >  	if (oom_zonelist_trylock(zonelist, GFP_KERNEL)) {
> > -		out_of_memory(NULL, 0, 0, NULL, false);
> > +		if (!oom_killer_disabled)
> > +			__out_of_memory(NULL, 0, 0, NULL, false);
> >  		oom_zonelist_unlock(zonelist, GFP_KERNEL);
> 
> Is this a condition which can happen and we can deal with? With
> userland fully frozen, there shouldn't be page faults which lead to
> memory allocation, right?

Except for racing OOM victims which were missed by try_to_freeze_tasks
because they didn't get cpu slice to wake up from the freezer. The task
would die on the way out from the page fault exception. I have updated
the changelog to be more verbose about this.

> Shouldn't we document how oom disable/enable is supposed to be used

Well the API shouldn't be used outside of the PM freezer IMO. This is not a
general API that other part of the kernel should be using. I can surely
add more documentation for the PM usage though. I have rewritten the
changelog:
"
    As oom_killer_disable() is a full OOM barrier now we can postpone it in
    the PM freezer to later after all freezable user tasks are considered
    frozen (to freeze_kernel_threads).

    Normally there wouldn't be any unfrozen user tasks at this moment so
    the function will not block. But if there was an OOM killer racing with
    try_to_freeze_tasks and the OOM victim didn't finish yet then we have to
    wait for it. This should complete in a finite time, though, because
        - the victim cannot loop in the page fault handler (it would die
          on the way out from the exception)
        - it cannot loop in the page allocator because all the further\
          allocation would fail
        - it shouldn't be blocked on any locks held by frozen tasks
          (try_to_freeze expects lockless context) and kernel threads and
          work queues are not frozen yet
"

And I've added:
+/**
+ * oom_killer_disable - disable OOM killer
+ *
+ * Forces all page allocations to fail rather than trigger OOM killer.
+ * Will block and wait until all OOM victims are dead.
+ *
+ * The function cannot be called when there are runnable user tasks because
+ * the userspace would see unexpected allocation failures as a result. Any
+ * new usage of this function should be consulted with MM people.
+ *
+ * Returns true if successful and false if the OOM killer cannot be
+ * disabled.
+ */
 bool oom_killer_disable(void)

> (it only makes sense while the whole system is in quiescent state)
> and at least trigger WARN_ON_ONCE() if the above code path gets
> triggered while oom killer is disabled?

I can add a WARN_ON(!test_thread_flag(tsk, TIF_MEMDIE)).

Thanks for the review!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
