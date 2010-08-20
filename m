Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 259D36B0209
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 20:31:11 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7K0V9dP006884
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 20 Aug 2010 09:31:09 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0998745DE4F
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 09:31:09 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DF2D745DE4E
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 09:31:08 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B52D31DB804F
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 09:31:08 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E2ED1DB804C
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 09:31:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch v2 2/2] oom: kill all threads sharing oom killed task's mm
In-Reply-To: <alpine.DEB.2.00.1008191340580.18994@chino.kir.corp.google.com>
References: <20100819170642.5FAE.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1008191340580.18994@chino.kir.corp.google.com>
Message-Id: <20100820091004.5FE4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 20 Aug 2010 09:31:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Thu, 19 Aug 2010, KOSAKI Motohiro wrote:
> 
> > > No, I'm talking about threads with CLONE_VM and not CLONE_THREAD (or 
> > > CLONE_VFORK, in your example).  They share the same address space but are 
> > > in different tgid's and may sit holding mm->mmap_sem looping in the page 
> > > allocator while we know we're oom and there's no chance of freeing any 
> > > more memory since the oom killer doesn't kill will other tasks have yet to 
> > > exit.
> > 
> > Why don't you use pthread library? Is there any good reason? That said,
> > If you are trying to optimize neither thread nor vfork case, I'm not charmed
> > this because 99.99% user don't use it. but even though every user will get 
> > performance degression. Can you please consider typical use case optimization?
> > 
> 
> Non-NPTL threaded applications exist in the wild, and I can't change that.  

Which application? If it is major opensource application, I think this one
makes end user happy.


> This mm->mmap_sem livelock is a problem for them, we've hit it internally 
> (we're forced to carry this patch internally), and we aren't the only ones 
> running at least some non-NPTL apps.  That's why this code existed in the 
> oom killer for over eight years since the 2.4 kernel before you removed it 
> based on the mempolicy policy of killing current, which has since been 
> obsoleted.  Until CLONE_VM without CLONE_THREAD is prohibited entirely on 
> Linux, this livelock can exist.

Or, can you eliminate O(n^2) thing? The cost is enough low, I don't oppose 
this.



> Users who do not want the tasklist scan here, which only iterates over 
> thread group leaders and not threads, can enable 
> /proc/sys/vm/oom_kill_allocating_task.  That's its whole purpose.  Other 
> than that, the oom killer will never be the most efficient part of the 
> kernel and doing for_each_process() is much less expensive than all the 
> task_lock()s we take already.

No.
Please don't forget typical end user don't use any kernel knob. kernel knob
is not a way for developer excuse.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
