Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 651C16B01B9
	for <linux-mm@kvack.org>; Fri, 28 May 2010 01:25:51 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4S5PmdI013092
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 28 May 2010 14:25:48 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CF75045DE55
	for <linux-mm@kvack.org>; Fri, 28 May 2010 14:25:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id ABA9945DE4F
	for <linux-mm@kvack.org>; Fri, 28 May 2010 14:25:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F4381DB8038
	for <linux-mm@kvack.org>; Fri, 28 May 2010 14:25:47 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2EDF1E08004
	for <linux-mm@kvack.org>; Fri, 28 May 2010 14:25:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: oom killer rewrite
In-Reply-To: <alpine.DEB.2.00.1005250246170.8045@chino.kir.corp.google.com>
References: <20100524100840.1E95.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1005250246170.8045@chino.kir.corp.google.com>
Message-Id: <20100528131125.7E1E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 28 May 2010 14:25:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi

> On Mon, 24 May 2010, KOSAKI Motohiro wrote:
> 
> > > I've been notified that my entire oom killer rewrite has been dropped from 
> > > -mm based solely on your feedback.  The problem is that I have absolutely 
> > > no idea what issues you have with the changes that haven't already been 
> > > addressed (nobody else does, either, it seems).
> > 
> > That's simple. A regression and an incompatibility are absolutely
> > unacceptable. They should be removed. Your patches have some funny parts,
> > but, afaik, nobody said funny requirement itself is wrong. They only said
> > your requirement don't have to cause any pain to other users.
> > 
> > Zero risk patches are always acceptable.
> > 
> 
> When you see these "funny parts," please let me know what they are.  The 
> were was no incompatibility issue after 
> oom-reintroduce-and-deprecate-oom_kill_allocating_task.patch was merged, 
> the interface was simply deprecated.  Arguing against the deprecation is 
> understandable and quite frankly something I'd like to avoid since it's 
> apparently hanging up the larger importance of the work, so I've dropped 
> the consolidation (and subsequent deprecation of oom_kill_allocating_task) 
> of the sysctls from my latest patch series.

That's said, don't deprecated current interface. Other MM developers makes
effort to reduce a number of oom bug report. I don't hope you run just opposite
direction.


> > I've reviewed all of your patches. the result is here.
> > 
> > > oom-filter-tasks-not-sharing-the-same-cpuset.patch
> > 	ok, no objection.
> > 	I'm still afraid this patch reinstanciate old bug. but at that time,
> > 	we can drop it solely. this patch is enough bisectable.
> > 
> > > oom-sacrifice-child-with-highest-badness-score-for-parent.patch
> > 	ok, no objection.
> > 	It's good patch.
> > 
> > > oom-select-task-from-tasklist-for-mempolicy-ooms.patch
> > 	ok, no objection.
> > 
> > > oom-remove-special-handling-for-pagefault-ooms.patch
> > 	ok, no objection.
> > 
> > > oom-badness-heuristic-rewrite.patch
> > 	No. All of rewrite is bad idea. Please make separate some
> > 	individual patches.
> > 	All rewrite thing break bisectability. Perhaps it can steal
> > 	a lot of time from MM developers.
> 
> We've talked about that before, and I remember specifically addressing why 
> it couldn't be broken apart with any coherent understanding of what was 
> happening.  I think the patchset itself was fairly well divided, but this 
> specific patch touches many different areas and function signatures but 
> are mainly localized to the oom killer.

Heh, that's ok.
I'll merge apart of this one If you can't. The rule is simple, rewrite 
all patches will never merge. but ok too. you can choice no merge.


> > 	This patch have following parts.
> > 	1) Add oom_score_adj
> 
> A patch that only adds oom_score_adj but doesn't do anything else?  It 
> can't be used with the current badness function, it requires the rewrite 
> of oom_badness().

ok. you can drop oom_score_adj too.

> > 	2) OOM score normalization
> 
> I prefer to do that with the addition of oom_score_adj since that tunable 
> is meaninless until the score uses it.

No. This one have no justification. BAD IDEA.
Any core heuristic change need to prove to improve desktop use case.

That's said, now lkml have one or two oom bug report per month. We have
to make effort to reduce it. Please don't append new confusion source.



> > 	3) forkbomb detector
> 
> Ok, I can seperate that out but that's only a small part of the overall 
> code.  Are there specific issues you'd like to address with that now 
> instead of later?

reviewability and bisectability are one of most important issue. that's all.


> > 	4) oom_forkbomb_thres new knob
> 
> I'd prefer to keep the introduction of the sysctl, again, with the 
> addition of the functional code that uses it.

I'm not against new knob. I only request separation.


> >  	5) Root user get 3% bonus instead 400%
> 
> I don't understand this.

Now, our oom have "if (root-user) points /= 4" logic, I wrote it as 400%.


> > 	all except (2) seems ok. but I'll review them again after separation.
> > 	but you can't insert your copyright. 
> > 
> 
> I can't add a copyright under the GPL for the new heuristic?  Why?

1) too small work
2) In this area, almost work had been lead to kamezawa-san. you don't have
   proper right.

(1) mean other people of joining this improvement can't append it too.


> > > oom-deprecate-oom_adj-tunable.patch
> > 	NAK. you can't change userland use-case at all. This patch
> > 	only makes bug report flood and streal our time.
> 
> It was Andrew's idea to deprecate this since the tunable works on a much 
> higher granularity than oom_score_adj.  Andrew?

If we can create really better new knob, the end users naturally migrate
to use new one. thus, we can remove older one without pain.

again, we still have a bit high bug report rate in oom area. Please don't
increase it.


> > > oom-replace-sysctls-with-quick-mode.patch
> > 	NAK. To change sysctl makes confusion to userland.
> > 	You have to prove such deprecated sysctl was alread unused.
> > 	But the fact is, there is users. I have hear some times such
> > 	use case and recent bug reporter said that's used.
> > 
> > 	https://bugzilla.kernel.org/show_bug.cgi?id=15058
> > 
> 
> Already dropped.

thanks.


> > > oom-avoid-oom-killer-for-lowmem-allocations.patch
> > 	I don't like this one. 64bit arch have big (e.g. 2/4G)
> > 	DMA_ZONE/DMA32_ZONE. So, if we create small guest kernel
> > 	on KVM (or Xen), Killing processes may help. IOW, this
> > 	one is conceptually good. but this check way is brutal.
> 
> It "may" help but has a significant probability of unnecessarily killing a 
> task that won't free any lowmem, so how would you suggest we modify the 
> oom killer to handle the allocation failure for GFP_DMA without negatively 
> impacting the system?

I prefer to check numbers of anon pages in the zone. I mean we want
"skip oom if the zone have no freeable memory", thus just do it.

But again, I'm ok yours too.

> 
> > 	but even though it's ok. Let's go merge it. this patch is
> > 	enough small.
> > 	If any problem is occur, we can revert this one easily.
> > 
> 
> Ok.
> 
> > > oom-remove-unnecessary-code-and-cleanup.patch
> > 	ok, no objection.
> > 
> > > oom-default-to-killing-current-for-pagefault-ooms.patch
> > 	NAK.
> > 	1) this patch break panic_on_oom
> > 	2) At this merge window, Nick change almost all architecture's
> > 	   page hault handler. now almost all arch use
> > 	   pagefault_out_of_memory. your description has been a bit obsoleted.
> > 
> 
> Already changed, as previously mentioned in earlier posts.

ok, thanks.

> 
> > > oom-avoid-race-for-oom-killed-tasks-detaching-mm-prior-to-exit.patch
> > 	no objection. but afaik Oleg already pointed out "if (!p->mm)" is bad.
> > 	So, Don't we need push his patch instead?
> > 
> 
> I think it all depends on the order in which this work is merged.
> 
> > > oom-hold-tasklist_lock-when-dumping-tasks.patch
> > 	ok, no objection.
> > 
> > > oom-give-current-access-to-memory-reserves-if-it-has-been-killed.patch
> > 	ok, no objection.
> > 
> > > oom-avoid-sending-exiting-tasks-a-sigkill.patch
> > 	ok, no objection
> > 
> > > oom-cleanup-oom_kill_task.patch
> > 	ok, no objection
> > 
> > > oom-cleanup-oom_badness.patch
> > 	ok, no objection
> > 
> > The above "no objection" mean you can feel free to use my reviewed-by tag.
> > 
> 
> Thanks for the detailed review, I look forward to your feedback when I 
> post the updated series.

I'm thanks too.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
