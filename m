Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DE66D6B004D
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 05:36:24 -0400 (EDT)
Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id n6V9aMP3010490
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 10:36:23 +0100
Received: from pxi3 (pxi3.prod.google.com [10.243.27.3])
	by zps75.corp.google.com with ESMTP id n6V9aJ7L001113
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 02:36:20 -0700
Received: by pxi3 with SMTP id 3so1410204pxi.18
        for <linux-mm@kvack.org>; Fri, 31 Jul 2009 02:36:19 -0700 (PDT)
Date: Fri, 31 Jul 2009 02:36:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm v2] mm: introduce oom_adj_child
In-Reply-To: <20090731093305.50bcc58d.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0907310231370.25447@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.0907282125260.554@chino.kir.corp.google.com> <20090730180029.c4edcc09.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0907300219580.13674@chino.kir.corp.google.com> <20090730190216.5aae685a.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.0907301157100.9652@chino.kir.corp.google.com> <20090731093305.50bcc58d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Paul Menage <menage@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 31 Jul 2009, KAMEZAWA Hiroyuki wrote:

> > > Simply, reset_oom_adj_at_new_mm_context or some.
> > > 
> > 
> > I think it's preferred to keep the name relatively short which is an 
> > unfortuante requirement in this case.  I also prefer to start the name 
> > with "oom_adj" so it appears alongside /proc/pid/oom_adj when listed 
> > alphabetically.
> > 
> But misleading name is bad.
> 

Can you help think of any names that start with oom_adj_* and are 
relatively short?  I'd happily ack it.

> Why don't you think select_bad_process()-> oom_kill_task() implementation is bad ?

It livelocks if a thread is chosen and passed to oom_kill_task() while 
another per-thread oom_adj value is OOM_DISABLE for a thread sharing the 
same memory.

> IMHO, it's bad manner to fix an os-implementation problem by adding _new_ user
> interface which is hard to understand.
> 

How else do you propose the oom killer use oom_adj values on a per-thread 
basis without considering other threads sharing the same memory?  It does 
no good for the oom killer to kill a thread if another one sharing its 
memory is OOM_DISABLE because it can't kill all of them.  That means the 
memory cannot be freed and it must choose another task, but the end result 
is that it needlessly killed others.  That's not a desirable result, 
sorry.

> > In other words, the issue here is larger than the inheritance of the 
> > oom_adj value amongst children, it addresses a livelock that neither of 
> > your approaches solve.  The fix actually makes /proc/pid/oom_adj (and 
> > /proc/pid/oom_score) consistent with how the oom killer behaves.
> 
> This oom_adj_child itself is not related to livelock problem. Don't make
> the problem bigger than it is.
> oom_adj_child itself is just a problem how to handle vfork().
> 

Right, that's why it wasn't part of my original patchset which fixed the 
livelock.  We had seen that others had use cases where they still needed 
to set a newly initialized mm to have a starting oom_adj value different 
from its parent.  That's entirely understandable, and that's why I 
proposed oom_adj_child.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
