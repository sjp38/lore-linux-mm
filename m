Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id F23456B02E0
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 05:05:25 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id o7K95MAI031264
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 02:05:22 -0700
Received: from pvg7 (pvg7.prod.google.com [10.241.210.135])
	by wpaz1.hot.corp.google.com with ESMTP id o7K956WZ030529
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 02:05:12 -0700
Received: by pvg7 with SMTP id 7so1335065pvg.17
        for <linux-mm@kvack.org>; Fri, 20 Aug 2010 02:05:06 -0700 (PDT)
Date: Fri, 20 Aug 2010 02:05:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2 2/2] oom: kill all threads sharing oom killed task's
 mm
In-Reply-To: <20100820091004.5FE4.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1008200159530.24154@chino.kir.corp.google.com>
References: <20100819170642.5FAE.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1008191340580.18994@chino.kir.corp.google.com> <20100820091004.5FE4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 20 Aug 2010, KOSAKI Motohiro wrote:

> > > Why don't you use pthread library? Is there any good reason? That said,
> > > If you are trying to optimize neither thread nor vfork case, I'm not charmed
> > > this because 99.99% user don't use it. but even though every user will get 
> > > performance degression. Can you please consider typical use case optimization?
> > > 
> > 
> > Non-NPTL threaded applications exist in the wild, and I can't change that.  
> 
> Which application? If it is major opensource application, I think this one
> makes end user happy.
> 

Being a "major opensource application" is not the requirement to prevent a 
livelock in the kernel.  The livelock exists, we hit it all the time, and 
your change to remove this code from the oom killer caused a regression.

Unless you can guarantee that a thread holding mm->mmap_sem cannot loop in 
the page allocator, then we need a way for that allocation to succeed.

> > This mm->mmap_sem livelock is a problem for them, we've hit it internally 
> > (we're forced to carry this patch internally), and we aren't the only ones 
> > running at least some non-NPTL apps.  That's why this code existed in the 
> > oom killer for over eight years since the 2.4 kernel before you removed it 
> > based on the mempolicy policy of killing current, which has since been 
> > obsoleted.  Until CLONE_VM without CLONE_THREAD is prohibited entirely on 
> > Linux, this livelock can exist.
> 
> Or, can you eliminate O(n^2) thing? The cost is enough low, I don't oppose 
> this.
> 

Suggestions on improvements are welcome in the form of a patch.

> > Users who do not want the tasklist scan here, which only iterates over 
> > thread group leaders and not threads, can enable 
> > /proc/sys/vm/oom_kill_allocating_task.  That's its whole purpose.  Other 
> > than that, the oom killer will never be the most efficient part of the 
> > kernel and doing for_each_process() is much less expensive than all the 
> > task_lock()s we take already.
> 
> No.
> Please don't forget typical end user don't use any kernel knob. kernel knob
> is not a way for developer excuse.
> 

Users who find tasklist scans with for_each_process() in the oom killer 
are a very, very special case and is typically only SGI.  They requested 
that the sysctl be added years ago to prevent the lengthy scan, so they 
are already protected.

Unless you can propose a different fix for the regression that you 
introduced with 8c5cd6f3 and fix the livelock, this type of check is 
mandatory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
