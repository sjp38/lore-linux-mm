Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CB8766B01B0
	for <linux-mm@kvack.org>; Sun, 23 May 2010 21:09:38 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4O19abI020182
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 24 May 2010 10:09:36 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5609C45DE57
	for <linux-mm@kvack.org>; Mon, 24 May 2010 10:09:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3611445DE4F
	for <linux-mm@kvack.org>; Mon, 24 May 2010 10:09:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 166AA1DB803C
	for <linux-mm@kvack.org>; Mon, 24 May 2010 10:09:36 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D2B6CE08002
	for <linux-mm@kvack.org>; Mon, 24 May 2010 10:09:34 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: oom killer rewrite
In-Reply-To: <alpine.DEB.2.00.1005191511140.27294@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1005191511140.27294@chino.kir.corp.google.com>
Message-Id: <20100524100840.1E95.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 24 May 2010 10:09:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi

> KOSAKI,
> 
> I've been notified that my entire oom killer rewrite has been dropped from 
> -mm based solely on your feedback.  The problem is that I have absolutely 
> no idea what issues you have with the changes that haven't already been 
> addressed (nobody else does, either, it seems).

That's simple. A regression and an incompatibility are absolutely
unacceptable. They should be removed. Your patches have some funny parts,
but, afaik, nobody said funny requirement itself is wrong. They only said
your requirement don't have to cause any pain to other users.

Zero risk patches are always acceptable.

> 
> The last work I've done on the patches are to ask those involved in the 
> review (including you) and linux-mm whether there were any outstanding 
> issues that anyone has, and I've asked that twice.  I've received no 
> response either time.
> 
> Please respond with a list of your objections to the rewrite (which is 
> available at 
> http://www.kernel.org/pub/linux/kernel/people/rientjes/oom-killer-rewrite
> so we can move forward.

I've reviewed all of your patches. the result is here.

> oom-filter-tasks-not-sharing-the-same-cpuset.patch
	ok, no objection.
	I'm still afraid this patch reinstanciate old bug. but at that time,
	we can drop it solely. this patch is enough bisectable.

> oom-sacrifice-child-with-highest-badness-score-for-parent.patch
	ok, no objection.
	It's good patch.

> oom-select-task-from-tasklist-for-mempolicy-ooms.patch
	ok, no objection.

> oom-remove-special-handling-for-pagefault-ooms.patch
	ok, no objection.

> oom-badness-heuristic-rewrite.patch
	No. All of rewrite is bad idea. Please make separate some
	individual patches.
	All rewrite thing break bisectability. Perhaps it can steal
	a lot of time from MM developers.
	This patch have following parts.
	1) Add oom_score_adj
	2) OOM score normalization
	3) forkbomb detector
	4) oom_forkbomb_thres new knob
 	5) Root user get 3% bonus instead 400%

	all except (2) seems ok. but I'll review them again after separation.
	but you can't insert your copyright. 

> oom-deprecate-oom_adj-tunable.patch
	NAK. you can't change userland use-case at all. This patch
	only makes bug report flood and streal our time.

> oom-replace-sysctls-with-quick-mode.patch
	NAK. To change sysctl makes confusion to userland.
	You have to prove such deprecated sysctl was alread unused.
	But the fact is, there is users. I have hear some times such
	use case and recent bug reporter said that's used.

	https://bugzilla.kernel.org/show_bug.cgi?id=15058

> oom-avoid-oom-killer-for-lowmem-allocations.patch
	I don't like this one. 64bit arch have big (e.g. 2/4G)
	DMA_ZONE/DMA32_ZONE. So, if we create small guest kernel
	on KVM (or Xen), Killing processes may help. IOW, this
	one is conceptually good. but this check way is brutal.

	but even though it's ok. Let's go merge it. this patch is
	enough small.
	If any problem is occur, we can revert this one easily.


> oom-remove-unnecessary-code-and-cleanup.patch
	ok, no objection.

> oom-default-to-killing-current-for-pagefault-ooms.patch
	NAK.
	1) this patch break panic_on_oom
	2) At this merge window, Nick change almost all architecture's
	   page hault handler. now almost all arch use
	   pagefault_out_of_memory. your description has been a bit obsoleted.

> oom-avoid-race-for-oom-killed-tasks-detaching-mm-prior-to-exit.patch
	no objection. but afaik Oleg already pointed out "if (!p->mm)" is bad.
	So, Don't we need push his patch instead?

> oom-hold-tasklist_lock-when-dumping-tasks.patch
	ok, no objection.

> oom-give-current-access-to-memory-reserves-if-it-has-been-killed.patch
	ok, no objection.

> oom-avoid-sending-exiting-tasks-a-sigkill.patch
	ok, no objection

> oom-cleanup-oom_kill_task.patch
	ok, no objection

> oom-cleanup-oom_badness.patch
	ok, no objection

The above "no objection" mean you can feel free to use my reviewed-by tag.


Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
