Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 962796B005D
	for <linux-mm@kvack.org>; Sun,  2 Aug 2009 21:28:39 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n731iUWd000971
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 3 Aug 2009 10:44:31 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B409B45DE4F
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 10:44:30 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 87E6645DE4E
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 10:44:30 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6050D1DB803E
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 10:44:30 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 07EF8E08004
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 10:44:30 +0900 (JST)
Date: Mon, 3 Aug 2009 10:42:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm v2] mm: introduce oom_adj_child
Message-Id: <20090803104244.b58220ba.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0908011303050.22174@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.0907282125260.554@chino.kir.corp.google.com>
	<20090730180029.c4edcc09.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0907300219580.13674@chino.kir.corp.google.com>
	<20090730190216.5aae685a.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0907301157100.9652@chino.kir.corp.google.com>
	<20090731093305.50bcc58d.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0907310231370.25447@chino.kir.corp.google.com>
	<7f54310137837631f2526d4e335287fc.squirrel@webmail-b.css.fujitsu.com>
	<alpine.DEB.2.00.0907311212240.22732@chino.kir.corp.google.com>
	<77df8765230d9f83859fde3119a2d60a.squirrel@webmail-b.css.fujitsu.com>
	<alpine.DEB.2.00.0908011303050.22174@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Paul Menage <menage@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 1 Aug 2009 13:26:52 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Sat, 1 Aug 2009, KAMEZAWA Hiroyuki wrote:
> 
> > Summarizing I think now .....
> >   - rename mm->oom_adj as mm->effective_oom_adj
> >   - re-add per-thread oom_adj
> >   - update mm->effective_oom_adj based on per-thread oom_adj
> >   - if necessary, plz add read-only /proc/pid/effective_oom_adj file.
> >     or show 2 values in /proc/pid/oom_adj
> >   - rewrite documentation about oom_score.
> >    " it's calclulated from  _process's_ memory usage and oom_adj of
> >     all threads which shares a memor  context".
> >    This behavior is not changed from old implemtation, anyway.
> >  - If necessary, rewrite oom_kill itself to scan only thread group
> >    leader. It's a way to go regardless of  vfork problem.
> > 
> 
> Ok, so you've abandoned the signal_struct proposal and now want to add it 
per-signal is also ok, just I didn't write.

> back to task_struct with an effective member in mm_struct by changing the 
> documentation.  Hmm.
> 
> This solves the livelock problem by adding additional tunables, but 
> doesn't match how the documentation describes the use case for 
> /proc/pid/oom_adj.  Your argument is that the behavior of that value can't 
> change: that it must be per-thread.  And that allowance leads to one of 
> two inconsistent scenarios:
> 
>  - /proc/pid/oom_score is inconsistent when tuning /proc/pid/oom_adj if it
>    relies on the per-thread oom_adj; it now really represents nothing but
>    an incorrect value if other threads share that memory and misleads the
>    user on how the oom killer chooses victims, or

What's why I said to show effective_oom_adj if necessary..

> 
>  - /proc/pid/oom_score is inconsistent when the thread that set the
>    effective per-mm oom_adj exits and it is now obsolete since you have
>    no way to determine what the next effective oom_adj value shall be.
> 
plz re-caluculate it. it's not a big job if done in lazy way.


> Determining the next effective per-mm oom_adj isn't possible when the only 
> threads sharing the mm remaining have different per-thread oom_adj values.  
> That's a horribly inconsistent state to be getting into because it allows 
> oom_score to change when a thread exits, which is completely unknown to 
> userspace, OR is allows the effective per-mm oom_adj to be different from 
> all threads sharing the same memory (and, thus, /proc/pid/oom_score not 
> being representative of any thread's /proc/pid/oom_adj).
> 
A _sane_ user will just set oom_adj to thread-group-leader.
Do you think users are too fool to set per-thread oom_adj independently ?
No problems in real world.


> > I think documentation is wrong. It should say "you should think of
> > multi-thread effect to oom_adj/oom_score".
> > 
> 
> It's more likely than not that applications were probably written to the 
> way the documentation described the two files: that is, adjust 
> /proc/pid/oom_score by tuning /proc/pid/oom_adj instead of relying on an 
> undocumented implementation detail concerning the tuning of oom_adj for a 
> vfork'd child prior to exec().  The user is probably unaware of the oom 
> killer's implementation and simply interprets a higher oom_score as a more 
> likely candidate for oom kill.  My patches preserve that in all scenarios 
> without altering the documentation or adding additional files that would 
> be required to leave the oom_adj value itself in an inconsistent state as 
> you propose.
> 
No.  My understanding is this.

 - oom_adj is designed considering vfork(), of course. then. per-thread.
 - oom_score has been incorrect in multi-threaded system. The user will not
   be affected.
 - you fixed livelock but breaks the feature.


Thanks,
-Kame
  




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
