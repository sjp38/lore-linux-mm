Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B185F6B004D
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 20:34:55 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6V0Ys5e010776
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 31 Jul 2009 09:34:54 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 74BCF45DE54
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 09:34:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4190345DE4F
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 09:34:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C59DE08003
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 09:34:54 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C0E6E1DB8038
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 09:34:53 +0900 (JST)
Date: Fri, 31 Jul 2009 09:33:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm v2] mm: introduce oom_adj_child
Message-Id: <20090731093305.50bcc58d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0907301157100.9652@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.0907282125260.554@chino.kir.corp.google.com>
	<20090730180029.c4edcc09.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0907300219580.13674@chino.kir.corp.google.com>
	<20090730190216.5aae685a.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0907301157100.9652@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Paul Menage <menage@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 30 Jul 2009 12:05:30 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Thu, 30 Jul 2009, KAMEZAWA Hiroyuki wrote:
> 
> > > If you have suggestions for a better name, I'd happily ack it.
> > > 
> > 
> > Simply, reset_oom_adj_at_new_mm_context or some.
> > 
> 
> I think it's preferred to keep the name relatively short which is an 
> unfortuante requirement in this case.  I also prefer to start the name 
> with "oom_adj" so it appears alongside /proc/pid/oom_adj when listed 
> alphabetically.
> 
But misleading name is bad.



> > > > 2. More simple plan is like this, IIUC.
> > > > 
> > > >   fix oom-killer's select_bad_process() not to be in deadlock.
> > > > 
> > > 
> > > Alternate ideas?
> > > 
> > At brief thiking.
> > 
> > 1. move oom_adj from mm_struct to signal struct. or somewhere.
> >    (see copy_signal())
> >    Then,
> >     - all threads in a process will have the same oom_adj.
> >     - vfork()'ed thread will inherit its parent's oom_adj.   
> >     - vfork()'ed thread can override oom_adj of its own.
> > 
> >     In other words, oom_adj is shared when CLONE_PARENT is not set.
> > 
> 
> Hmm, didn't we talk about signal_struct already?  The problem with that 
> approach is that oom_adj values represent a killable quantity of memory, 
> so having multiple threads sharing the same mm_struct with one set to 
> OOM_DISABLE and the other at +15 will still livelock because the oom 
> killer can't kill either.
>
> > 2. rename  mm_struct's oom_adj as shadow_oom_adj.
> > 
> >    update this shadow_oom_adj as the highest oom_adj among
> >    the values all threads share this mm_struct have.
> >    This update is done when
> >    - mm_init()
> >    - oom_adj is written.
> > 
> >    User's 
> >    # echo XXXX > /proc/<x>/oom_adj
> >    is not necessary to be very very fast.
> > 
> >    I don't think a process which calls vfork() is multi-threaded.
> > 
> > 3. use shadow_oom_adj in select_bad_process().
> > 
> 
> Ideas 2 & 3 here seem to be a single proposal.  The problem is that it 
> still leaves /proc/pid/oom_score to be inconsistent with the badness 
> scoring that the oom killer will eventually use since if it oom kills one 
> task, it must kill all tasks sharing the same mm_struct to lead to future 
> memory freeing.
> 
yes.

> Additionally, if you were to set one thread to OOM_DISABLE, storing the 
> highest oom_adj value in mm_struct isn't going to help because 
> oom_kill_task() will still require a tasklist scan to ensure no threads 
> sharing the mm_struct are OOM_DISABLE and the livelock persists.
> 

Why don't you think select_bad_process()-> oom_kill_task() implementation is bad ?
IMHO, it's bad manner to fix an os-implementation problem by adding _new_ user
interface which is hard to understand.


> In other words, the issue here is larger than the inheritance of the 
> oom_adj value amongst children, it addresses a livelock that neither of 
> your approaches solve.  The fix actually makes /proc/pid/oom_adj (and 
> /proc/pid/oom_score) consistent with how the oom killer behaves.

This oom_adj_child itself is not related to livelock problem. Don't make
the problem bigger than it is.
oom_adj_child itself is just a problem how to handle vfork().

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
