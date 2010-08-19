Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 49DCB6B01F1
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 07:17:23 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7JBHJhu022699
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 19 Aug 2010 20:17:19 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7098345DE4E
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 20:17:19 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4BDC745DE55
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 20:17:19 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 29CFBE08005
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 20:17:19 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CBA11E08003
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 20:17:18 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch v2 2/2] oom: kill all threads sharing oom killed task's mm
In-Reply-To: <20100819170642.5FAE.A69D9226@jp.fujitsu.com>
References: <alpine.DEB.2.00.1008190057450.3737@chino.kir.corp.google.com> <20100819170642.5FAE.A69D9226@jp.fujitsu.com>
Message-Id: <20100819201641.5FD0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 19 Aug 2010 20:17:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > On Thu, 19 Aug 2010, KOSAKI Motohiro wrote:
> > 
> > > > This is especially necessary to solve an mm->mmap_sem livelock issue
> > > > whereas an oom killed thread must acquire the lock in the exit path while
> > > > another thread is holding it in the page allocator while trying to
> > > > allocate memory itself (and will preempt the oom killer since a task was
> > > > already killed).  Since tasks with pending fatal signals are now granted
> > > > access to memory reserves, the thread holding the lock may quickly
> > > > allocate and release the lock so that the oom killed task may exit.
> > > 
> > > I can't understand this sentence. mm sharing is happen when vfork, That
> > > said, parent process is always sleeping. why do we need to worry that parent
> > > process is holding mmap_sem?
> > > 
> > 
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

That said, This was NAKed while this patch makes end user unhappy. please
fix it.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
