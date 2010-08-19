Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6D2716B0207
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 16:55:29 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id o7JKtSI1014952
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 13:55:28 -0700
Received: from pzk6 (pzk6.prod.google.com [10.243.19.134])
	by hpaq5.eem.corp.google.com with ESMTP id o7JKtQE7029870
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 13:55:26 -0700
Received: by pzk6 with SMTP id 6so946151pzk.3
        for <linux-mm@kvack.org>; Thu, 19 Aug 2010 13:55:25 -0700 (PDT)
Date: Thu, 19 Aug 2010 13:48:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2 2/2] oom: kill all threads sharing oom killed task's
 mm
In-Reply-To: <20100819170642.5FAE.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1008191340580.18994@chino.kir.corp.google.com>
References: <20100819142444.5F91.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1008190057450.3737@chino.kir.corp.google.com> <20100819170642.5FAE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Aug 2010, KOSAKI Motohiro wrote:

> > No, I'm talking about threads with CLONE_VM and not CLONE_THREAD (or 
> > CLONE_VFORK, in your example).  They share the same address space but are 
> > in different tgid's and may sit holding mm->mmap_sem looping in the page 
> > allocator while we know we're oom and there's no chance of freeing any 
> > more memory since the oom killer doesn't kill will other tasks have yet to 
> > exit.
> 
> Why don't you use pthread library? Is there any good reason? That said,
> If you are trying to optimize neither thread nor vfork case, I'm not charmed
> this because 99.99% user don't use it. but even though every user will get 
> performance degression. Can you please consider typical use case optimization?
> 

Non-NPTL threaded applications exist in the wild, and I can't change that.  
This mm->mmap_sem livelock is a problem for them, we've hit it internally 
(we're forced to carry this patch internally), and we aren't the only ones 
running at least some non-NPTL apps.  That's why this code existed in the 
oom killer for over eight years since the 2.4 kernel before you removed it 
based on the mempolicy policy of killing current, which has since been 
obsoleted.  Until CLONE_VM without CLONE_THREAD is prohibited entirely on 
Linux, this livelock can exist.

Users who do not want the tasklist scan here, which only iterates over 
thread group leaders and not threads, can enable 
/proc/sys/vm/oom_kill_allocating_task.  That's its whole purpose.  Other 
than that, the oom killer will never be the most efficient part of the 
kernel and doing for_each_process() is much less expensive than all the 
task_lock()s we take already.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
