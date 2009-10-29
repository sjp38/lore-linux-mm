Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A23716B004D
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 05:44:54 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id n9T9io87031878
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 02:44:50 -0700
Received: from pwj10 (pwj10.prod.google.com [10.241.219.74])
	by wpaz9.hot.corp.google.com with ESMTP id n9T9ieju031816
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 02:44:47 -0700
Received: by pwj10 with SMTP id 10so1593690pwj.6
        for <linux-mm@kvack.org>; Thu, 29 Oct 2009 02:44:47 -0700 (PDT)
Date: Thu, 29 Oct 2009 02:44:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom_kill: use rss value instead of vm size for badness
In-Reply-To: <20091029181650.979bf95c.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0910290232000.21298@chino.kir.corp.google.com>
References: <20091028175846.49a1d29c.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910280206430.7122@chino.kir.corp.google.com> <abbed627532b26d8d96990e2f95c02fc.squirrel@webmail-b.css.fujitsu.com> <20091029100042.973328d3.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.0910290125390.11476@chino.kir.corp.google.com> <20091029174632.8110976c.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910290156560.16347@chino.kir.corp.google.com> <20091029181650.979bf95c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>, vedran.furac@gmail.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 29 Oct 2009, KAMEZAWA Hiroyuki wrote:

> > > yes, then I wrote "as start point". There are many environments.
> > 
> > And this environment has a particularly bad result.
> > yes, then I wrote "as start point". There are many environments.
> 
> In my understanding, 2nd, 3rd candidates are not important. If both of
> total_vm and RSS catches the same process as 1st candidate, it's ok.
> (i.e. If killed, oom situation will go away.)
> 

The ordering would matter on a machine with smaller capacity or if Vedran 
was using mem=, theoretically at the size of its current capacity minus 
the amount of anonymous memory being mlocked by the "test" program.  When 
the oom occurs (and notice it's not triggered by "test" each time), it 
would have killed Xorg in what would otherwise be the same conditions.

> > I'm surprised you still don't see a value in using the peak VM and RSS 
> > sizes, though, as part of your formula as it would indicate the proportion 
> > of memory resident in RAM at the time of oom.
> > 
> I'll use swap_usage instead of peak VM size as bonus.
> 
>   anon_rss + swap_usage/2 ? or some.
> 
> My first purpose is not to kill not-guilty process at random.
> If memory eater is killed, it's reasnoable.
> 

We again arrive at the distinction I made earlier where there're two 
approaches: kill a task that is consuming the majority of resident RAM, or 
kill a thread that is using much more memory than expected such as a 
memory leaker.  I know that you've argued that the kernel can never know 
the latter, which I agree, but it does have the benefit of allowing the 
user to have more input and determine when an actual task is using much 
more RAM than expected; the anon_rss and swap_usage in your formula is 
highly dynamic, so you've have to expect the user to dynamically alter 
oom_adj to specify a preference in the case of the memory leaker.

> In my consideration
> 
>   - "Killing a process because of OOM" is something bad, but not avoidable.
> 
>   - We don't need to do compliated/too-wise calculation for killing a process.
>     "The worst one is memory-eater!" is easy to understand to users and admins.
> 

Is this a proposal to remove the remainder of the heuristics as well such 
as considering superuser tasks and those with longer uptimes?  I'd agree 
with removing most of it other than the oom_adj and current->mems_allowed 
intersection penalty.  We're probably going to need rewrite the badness 
heuristic from scratch instead of simply changing the baseline.

>   - We have oom_adj, now. User can customize it if he run _important_ memory eater.
> 

If he runs an important memory eater, he can always polarize it by 
disabling oom killing completely for that task.  However, oom_adj is also 
used to identify memory leakers when the amount of memory that it uses is 
roughly known.  Most people don't know how much memory their applications 
use, but there are systems where users have tuned oom_adj specifically 
based on comparative /proc/pid/oom_score results.  Simply using anon_rss 
and swap_usage will make that vary much more than previously.

>   - But fork-bomb doesn't seem memory eater if we see each process.
>     We need some cares.
> 

The forkbomb can be addressed in multiple ways, the most simple of which 
is simply counting the number of children and their runtime.  It'd 
probably even be better to isolate the forkbomb case away from the badness 
score and simply kill the parent by returning ULONG_MAX when it's 
recognized.

>   Then,
>   - I'd like to drop file_rss.
>   - I'd like to take swap_usage into acccount.
>   - I'd like to remove cpu_time bonus. runtime bonus is much more important.
>   - I'd like to remove penalty from children. To do that, fork-bomb detector
>     is necessary.
>   - nice bonus is bad. (We have oom_adj instead of this.) It should be
>     if (task_nice(p) < 0)
> 	points /= 2;
>     But we have "root user" bonus already. We can remove this line.
> 
> After above, much more simple selection, easy-to-understand,  will be done.
> 

Agreed, I think we'll need to rewrite most of the heuristic from scratch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
