Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5AE406008F9
	for <linux-mm@kvack.org>; Tue, 25 May 2010 05:55:48 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id o4P9tjqt026698
	for <linux-mm@kvack.org>; Tue, 25 May 2010 02:55:46 -0700
Received: from pzk8 (pzk8.prod.google.com [10.243.19.136])
	by kpbe20.cbf.corp.google.com with ESMTP id o4P9tiQK009588
	for <linux-mm@kvack.org>; Tue, 25 May 2010 02:55:44 -0700
Received: by pzk8 with SMTP id 8so1705252pzk.18
        for <linux-mm@kvack.org>; Tue, 25 May 2010 02:55:44 -0700 (PDT)
Date: Tue, 25 May 2010 02:55:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: oom killer rewrite
In-Reply-To: <20100524100840.1E95.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1005250246170.8045@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1005191511140.27294@chino.kir.corp.google.com> <20100524100840.1E95.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 24 May 2010, KOSAKI Motohiro wrote:

> > I've been notified that my entire oom killer rewrite has been dropped from 
> > -mm based solely on your feedback.  The problem is that I have absolutely 
> > no idea what issues you have with the changes that haven't already been 
> > addressed (nobody else does, either, it seems).
> 
> That's simple. A regression and an incompatibility are absolutely
> unacceptable. They should be removed. Your patches have some funny parts,
> but, afaik, nobody said funny requirement itself is wrong. They only said
> your requirement don't have to cause any pain to other users.
> 
> Zero risk patches are always acceptable.
> 

When you see these "funny parts," please let me know what they are.  The 
were was no incompatibility issue after 
oom-reintroduce-and-deprecate-oom_kill_allocating_task.patch was merged, 
the interface was simply deprecated.  Arguing against the deprecation is 
understandable and quite frankly something I'd like to avoid since it's 
apparently hanging up the larger importance of the work, so I've dropped 
the consolidation (and subsequent deprecation of oom_kill_allocating_task) 
of the sysctls from my latest patch series.

> I've reviewed all of your patches. the result is here.
> 
> > oom-filter-tasks-not-sharing-the-same-cpuset.patch
> 	ok, no objection.
> 	I'm still afraid this patch reinstanciate old bug. but at that time,
> 	we can drop it solely. this patch is enough bisectable.
> 
> > oom-sacrifice-child-with-highest-badness-score-for-parent.patch
> 	ok, no objection.
> 	It's good patch.
> 
> > oom-select-task-from-tasklist-for-mempolicy-ooms.patch
> 	ok, no objection.
> 
> > oom-remove-special-handling-for-pagefault-ooms.patch
> 	ok, no objection.
> 
> > oom-badness-heuristic-rewrite.patch
> 	No. All of rewrite is bad idea. Please make separate some
> 	individual patches.
> 	All rewrite thing break bisectability. Perhaps it can steal
> 	a lot of time from MM developers.

We've talked about that before, and I remember specifically addressing why 
it couldn't be broken apart with any coherent understanding of what was 
happening.  I think the patchset itself was fairly well divided, but this 
specific patch touches many different areas and function signatures but 
are mainly localized to the oom killer.

> 	This patch have following parts.
> 	1) Add oom_score_adj

A patch that only adds oom_score_adj but doesn't do anything else?  It 
can't be used with the current badness function, it requires the rewrite 
of oom_badness().

> 	2) OOM score normalization

I prefer to do that with the addition of oom_score_adj since that tunable 
is meaninless until the score uses it.

> 	3) forkbomb detector

Ok, I can seperate that out but that's only a small part of the overall 
code.  Are there specific issues you'd like to address with that now 
instead of later?

> 	4) oom_forkbomb_thres new knob

I'd prefer to keep the introduction of the sysctl, again, with the 
addition of the functional code that uses it.

>  	5) Root user get 3% bonus instead 400%
> 

I don't understand this.

> 	all except (2) seems ok. but I'll review them again after separation.
> 	but you can't insert your copyright. 
> 

I can't add a copyright under the GPL for the new heuristic?  Why?

> > oom-deprecate-oom_adj-tunable.patch
> 	NAK. you can't change userland use-case at all. This patch
> 	only makes bug report flood and streal our time.
> 

It was Andrew's idea to deprecate this since the tunable works on a much 
higher granularity than oom_score_adj.  Andrew?

> > oom-replace-sysctls-with-quick-mode.patch
> 	NAK. To change sysctl makes confusion to userland.
> 	You have to prove such deprecated sysctl was alread unused.
> 	But the fact is, there is users. I have hear some times such
> 	use case and recent bug reporter said that's used.
> 
> 	https://bugzilla.kernel.org/show_bug.cgi?id=15058
> 

Already dropped.

> > oom-avoid-oom-killer-for-lowmem-allocations.patch
> 	I don't like this one. 64bit arch have big (e.g. 2/4G)
> 	DMA_ZONE/DMA32_ZONE. So, if we create small guest kernel
> 	on KVM (or Xen), Killing processes may help. IOW, this
> 	one is conceptually good. but this check way is brutal.
> 

It "may" help but has a significant probability of unnecessarily killing a 
task that won't free any lowmem, so how would you suggest we modify the 
oom killer to handle the allocation failure for GFP_DMA without negatively 
impacting the system?

> 	but even though it's ok. Let's go merge it. this patch is
> 	enough small.
> 	If any problem is occur, we can revert this one easily.
> 

Ok.

> > oom-remove-unnecessary-code-and-cleanup.patch
> 	ok, no objection.
> 
> > oom-default-to-killing-current-for-pagefault-ooms.patch
> 	NAK.
> 	1) this patch break panic_on_oom
> 	2) At this merge window, Nick change almost all architecture's
> 	   page hault handler. now almost all arch use
> 	   pagefault_out_of_memory. your description has been a bit obsoleted.
> 

Already changed, as previously mentioned in earlier posts.

> > oom-avoid-race-for-oom-killed-tasks-detaching-mm-prior-to-exit.patch
> 	no objection. but afaik Oleg already pointed out "if (!p->mm)" is bad.
> 	So, Don't we need push his patch instead?
> 

I think it all depends on the order in which this work is merged.

> > oom-hold-tasklist_lock-when-dumping-tasks.patch
> 	ok, no objection.
> 
> > oom-give-current-access-to-memory-reserves-if-it-has-been-killed.patch
> 	ok, no objection.
> 
> > oom-avoid-sending-exiting-tasks-a-sigkill.patch
> 	ok, no objection
> 
> > oom-cleanup-oom_kill_task.patch
> 	ok, no objection
> 
> > oom-cleanup-oom_badness.patch
> 	ok, no objection
> 
> The above "no objection" mean you can feel free to use my reviewed-by tag.
> 

Thanks for the detailed review, I look forward to your feedback when I 
post the updated series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
