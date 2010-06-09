Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DB2AF6B01DF
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:14:48 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o590Ekmu024643
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 17:14:47 -0700
Received: from pzk7 (pzk7.prod.google.com [10.243.19.135])
	by wpaz5.hot.corp.google.com with ESMTP id o590EiHp012507
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 17:14:45 -0700
Received: by pzk7 with SMTP id 7so2938428pzk.30
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 17:14:44 -0700 (PDT)
Date: Tue, 8 Jun 2010 17:14:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 05/18] oom: give current access to memory reserves if it
 has been killed
In-Reply-To: <20100608130804.8794d029.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1006081707540.19582@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061524080.32225@chino.kir.corp.google.com> <20100608130804.8794d029.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, Andrew Morton wrote:

> > It's possible to livelock the page allocator if a thread has mm->mmap_sem
> 
> What is the state of this thread?  Trying to allocate memory, I assume.  
> 

Right, which I agree is a bad scenario to be in but indeed does happen 
(and we have a workaround at Google that identifies these particular cases 
and kills the holder of the writelock on mm->mmap_sem).  We have one 
thread holding a readlock on mm->mmap_sem while trying to allocate memory 
so the oom killer becomes a no-op to prevent needless task killing while 
waiting for the killed task to exit, but that killed task can't exit 
because it requires a writelock on the same semaphore.

> > and fails to make forward progress because the oom killer selects another
> > thread sharing the same ->mm to kill that cannot exit until the semaphore
> > is dropped.
> > 
> > The oom killer will not kill multiple tasks at the same time; each oom
> > killed task must exit before another task may be killed.
> 
> This sounds like a quite risky design.  The possibility that we'll
> cause other dead/livelocks similar to this one seems pretty high.  It
> applies to all sleeping locks in the entire kernel, doesn't it?
> 

It applies to any writelock that is taken during the exitpath of an oom 
killed task if a thread holding a readlock is trying to allocate memory 
itself.  This is how it's always been done at least within the past few 
years and we haven't had a problem other than with mm->mmap_sem.  At one 
point we used an oom killer timeout to kill other tasks after a period of 
time had elapsed, but that hasn't been required since we've been killing 
the thread holding the writelock on mm->mmap_sem.

> >  Thus, if one
> > thread is holding mm->mmap_sem and cannot allocate memory, all threads
> > sharing the same ->mm are blocked from exiting as well.  In the oom kill
> > case, that means the thread holding mm->mmap_sem will never free
> > additional memory since it cannot get access to memory reserves and the
> > thread that depends on it with access to memory reserves cannot exit
> > because it cannot acquire the semaphore.  Thus, the page allocators
> > livelocks.
> > 
> > When the oom killer is called and current happens to have a pending
> > SIGKILL, this patch automatically gives it access to memory reserves and
> > returns.  Upon returning to the page allocator, its allocation will
> > hopefully succeed so it can quickly exit and free its memory.  If not, the
> > page allocator will fail the allocation if it is not __GFP_NOFAIL.
> 
> You said "hopefully".
> 

"hopefully" in this case means that the allocation better succeed or we've 
depleted all memory reserves and we're deadlocked, it doesn't mean that 
this is a speculative change that may or may not work.

> Does it actually work?  Any real-world testing results?  If so, they'd
> be a useful addition to the changelog.
> 

It certain does, and prevents needlessly killing another task when we know 
current is exiting.  The nice thing about that is that we don't need to do 
anything like checking if a child should be sacrified or if current is 
OOM_DISABLE: we already know it's dying so it should simply get access to 
memory reserves either to return and handle its pending SIGKILL or 
continue down the exitpath.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
