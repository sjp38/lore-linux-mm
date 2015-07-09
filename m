Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 554106B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 17:27:19 -0400 (EDT)
Received: by iggp10 with SMTP id p10so23082892igg.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 14:27:19 -0700 (PDT)
Received: from mail-ie0-x22e.google.com (mail-ie0-x22e.google.com. [2607:f8b0:4001:c03::22e])
        by mx.google.com with ESMTPS id qf9si6525483icb.62.2015.07.09.14.27.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 14:27:18 -0700 (PDT)
Received: by iecuq6 with SMTP id uq6so185164277iec.2
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 14:27:18 -0700 (PDT)
Date: Thu, 9 Jul 2015 14:27:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] oom: split out forced OOM killer
In-Reply-To: <20150709100541.GD13872@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1507091409400.17177@chino.kir.corp.google.com>
References: <1436360661-31928-1-git-send-email-mhocko@suse.com> <1436360661-31928-5-git-send-email-mhocko@suse.com> <alpine.DEB.2.10.1507081638290.16585@chino.kir.corp.google.com> <20150709100541.GD13872@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jakob Unterwurzacher <jakobunt@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 9 Jul 2015, Michal Hocko wrote:

> > > The forced OOM killing is currently wired into out_of_memory() call
> > > even though their objective is different which makes the code ugly
> > > and harder to follow. Generic out_of_memory path has to deal with
> > > configuration settings and heuristics which are completely irrelevant
> > > to the forced OOM killer (e.g. sysctl_oom_kill_allocating_task or
> > > OOM killer prevention for already dying tasks). All of them are
> > > either relying on explicit force_kill check or indirectly by checking
> > > current->mm which is always NULL for sysrq+f. This is not nice, hard
> > > to follow and error prone.
> > > 
> > > Let's pull forced OOM killer code out into a separate function
> > > (force_out_of_memory) which is really trivial now.
> > > As a bonus we can clearly state that this is a forced OOM killer
> > > in the OOM message which is helpful to distinguish it from the
> > > regular OOM killer.
> > > 
> > > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > 
> > It's really absurd that we have to go through this over and over and that 
> > your patches are actually being merged into -mm just because you don't get 
> > the point.
> > 
> > We have no need for a force_out_of_memory() function.  None whatsoever.  
> 
> The reasons are explained in the changelog and I do not see a single
> argument against any of them.
> 

We have a large number of checks in the oom killer to handle various 
circumstances.  Those include different sysctl behaviors, different oom 
contexts (system, mempolicy, cpuset, memcg) to handle, behavior on 
concurrent exiting or killed processes, different calling context, etc.  
That doesn't mean they are deserving of individual functions that 
duplicate logic that add more and more lines of code.

> > Keeping oc->force_kill around is just more pointless space on a very deep 
> > stack and I'm tired of fixing stack overflows.
> 
> This just doesn't make any sense. oc->force_kill vs oc->order =
> -1 replacement is completely independent on this patch and can be
> implemented on top of it if you really insist.
> 

You are introducing a separate function that duplicates logic to avoid 
adding two checks to existing conditionals.  That's what I disagree with.

> > I'm certainly not going to 
> > introduce others because you think it looks cleaner in the code when 
> > memory compaction does the exact same thing by using cc->order == -1 to 
> > mean explicit compaction.
> > 
> > This is turning into a complete waste of time.
> 
> You know what? I am tired of your complete immunity to any arguments and
> the way how you are pushing more hacks into an already cluttered code.
> 

I'm going to make one final comment on these constant reiterations of the 
same patchset and then move on.  I simply don't have the time to continue 
to discuss stylistic differences: in this case, I disagree with you 
introducing a new function that duplicates logic elsewhere to avoid adding 
two checks in existing conditions.

If we look at memory compaction, I see cc->order == -1 checks in four 
places.  cc->order == -1 means compaction was triggered explicitly from 
the command line, just as oc->order == -1 in my patchset means the oom 
killer was triggered explicitly from sysrq.

__compact_finished():
	/*
	 * order == -1 is expected when compacting via
	 * /proc/sys/vm/compact_memory
	 */
	if (cc->order == -1)
		return COMPACT_CONTINUE;

__compaction_suitable():
	/*
	 * order == -1 is expected when compacting via
	 * /proc/sys/vm/compact_memory
	 */
	if (order == -1)
		return COMPACT_CONTINUE;

__compact_pgdat():
		/*
		 * When called via /proc/sys/vm/compact_memory
		 * this makes sure we compact the whole zone regardless of
		 * cached scanner positions.
		 */
		if (cc->order == -1)
			__reset_isolation_suitable(zone);

		if (cc->order == -1 || !compaction_deferred(zone, cc->order))
			compact_zone(zone, cc);

We don't implement separate memory compaction scanners when triggered by 
the command line.  We simply check, where appropriate, if this is a full 
compaction scan or not.  In that case, cc->order doesn't matter since we 
aren't trying to allocate a page; this is the exact same as in my patchset 
since oc->order doesn't matter since we aren't concerned with the order of 
the failed page allocation.

I have never had trouble following Mel's code when it comes to the Linux 
VM.

I recognized this as an opportunity to remove data on the stack, which is 
always important for the page allocator and oom killer because it can be 
very deep, by doing the exact same thing.

check_panic_on_oom():
	/* Do not panic for oom kills triggered by sysrq */
	if (oc->order == -1)
		return;

and two changes to existing conditions to determine if we should panic or 
if we have an eligible victim.

What we don't do is what your patch does:

bool force_out_of_memory(void)
{
	struct task_struct *p;
	unsigned long totalpages;
	unsigned int points;
	const gfp_t gfp_mask = GFP_KERNEL;
	struct oom_context oc = {
		.zonelist = node_zonelist(first_memory_node, gfp_mask),
		.gfp_mask = gfp_mask,
		.force_kill = true,
	};

	if (oom_killer_disabled)
		return false;

	constrained_alloc(&oc, &totalpages);
	p = select_bad_process(&oc, &points, totalpages);
	if (p != (void *)-1UL)
		oom_kill_process(&oc, p, points, totalpages, NULL,
				"Forced out of memory killer");
	else
		pr_warn("Sysrq triggered out of memory. No killable task found...\n");

	return true;
}

which duplicates _all_ that logic that appears elsewhere.

I can also see that it changes the oom_kill_process() message which would 
break anybody who is parsing the kernel log, which is the only 
notification mechanism we have that the kernel killed a process, for what 
has always been printed on oom kill.

I think I've reviewed this same patch three times and I'm not going to 
respond further in regards to it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
