Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C5F0E600309
	for <linux-mm@kvack.org>; Sun, 29 Nov 2009 23:16:27 -0500 (EST)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp09.au.ibm.com (8.14.3/8.13.1) with ESMTP id nAUFGNXC014369
	for <linux-mm@kvack.org>; Tue, 1 Dec 2009 02:16:23 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAU4Cjgc1667316
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 15:12:46 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nAU4GM4m016096
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 15:16:22 +1100
Date: Mon, 30 Nov 2009 09:46:17 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] ksm: hold anon_vma in rmap_item fix
Message-ID: <20091130041617.GJ2970@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <Pine.LNX.4.64.0911291544140.14991@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0911291544140.14991@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Hugh Dickins <hugh.dickins@tiscali.co.uk> [2009-11-29 15:50:32]:

> KSM mem_cgroup testing oopsed on NULL pointer in mem_cgroup_from_task(),
> called from the mm_match_cgroup() in page_referenced_ksm().
> 
> Right, it is inappropriate to use mm_match_cgroup() on rmap_item->mm
> there: that mm could be waiting for ksmd's final mmdrop(), with its
> mm->owner task long gone.
> 
> Move the mm_match_cgroup() test down into the anon_vma loop, which is
> where it now should be to match page_referenced_anon().  The anon_vma
> guarantees its vmas are valid, which guarantee their mms are valid.
> 
> However... although this moves the oops from easy-to-reproduce to
> never-seen, I think we shall want to do more later: so far as I can
> see, with or without KSM, the use of mm->owner from page_referenced()
> is unsafe.  No problem when NULL, but it may have been left pointing
> to a task_struct freed by now, with nonsense in mm->owner->cgroups.
>

Ideally we should not be left pointing to a stale task struct, unless
our assumption about mm_users is incorrect (discussed below).

 
> But let's put this patch in while we discuss that separately: perhaps
> mm_need_new_owner() should not short-circuit when mm_users <= 1, or
> perhaps it should then set mm->owner to NULL, or perhaps we abandon
> mm->owner as more trouble than it's worth, or... perhaps I'm wrong.
> 

We short circuit, since the task is exiting and mm_users <= 1 and we
are shorting going to do a mmput(). I suspect what you are seeing is
mm_count >= 1 and mm_users == 0. With users == 0, we should set
owner to NULL

We could look for the above condition in mmput() and clear the owner
when users become 0.


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
