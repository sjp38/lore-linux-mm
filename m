Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7F8266B007B
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 08:14:54 -0500 (EST)
Received: by ywh7 with SMTP id 7so1620880ywh.11
        for <linux-mm@kvack.org>; Tue, 16 Feb 2010 05:14:53 -0800 (PST)
Subject: Re: [patch 4/7 -mm] oom: badness heuristic rewrite
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1002151347470.26927@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com>
	 <alpine.DEB.2.00.1002100228540.8001@chino.kir.corp.google.com>
	 <4B73833D.5070008@redhat.com>
	 <alpine.DEB.2.00.1002102332200.22152@chino.kir.corp.google.com>
	 <1265982984.6207.29.camel@barrios-desktop>
	 <alpine.DEB.2.00.1002121251130.7972@chino.kir.corp.google.com>
	 <28c262361002121845w459d0fa0l55a58552c3a6081e@mail.gmail.com>
	 <alpine.DEB.2.00.1002151347470.26927@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 16 Feb 2010 22:14:46 +0900
Message-ID: <1266326086.1709.50.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2010-02-15 at 13:54 -0800, David Rientjes wrote:
> We're not enforcing a global, system-wide forkbomb policy in the oom 
> killer, but we do need to identify tasks that fork a very large number of 
> tasks to break ties with other tasks: in other words, it would not be 
> helpful to kill an application that has been running for weeks because 
> another application with the same or less memory usage has forked 1000 
> children and has caused an oom condition.  That unfairly penalizes the 
> former application that is actually doing work.
> 
> Again, I'd encourage you to look at this as only a slight penalization 
> rather than a policy that strictly needs to be enforced.  If it were 
> strictly enforced, it would be a prerequisite for selection if such a task 
> were to exist; in my implementation, it is part of the heuristic.

Okay. I can think it of slight penalization in this patch. 
But in current OOM logic, we try to kill child instead of forkbomb
itself. My concern was that.
Of course, It's not a part of your patch[2/7] which is good. 
It has been in there during long time. I hope we could solve that in
this chance. Pz, look at below my example. 

> 
> > > That doesn't work with Rik's example of a webserver that forks a large
> > > number of threads to handle client connections.  It is _always_ better to
> > > kill a child instead of making the entire webserver unresponsive.
> > 
> > In such case, admin have to handle it by oom_forkbom_thres.
> > Isn't it your goal?
> > 
> 
> oom_forkbomb_thres has a default value, which is 1000, so it should be 
> enabled by default.
> 
> > My suggestion is how handle buggy forkbomb processes which make
> > system almost hang by user's mistake. :)
> > 
> 
> I don't think you've given a clear description (or, even better, a patch) 
> of your suggestion.

I write down my suggestion, again. 
My concern is following as. 


1. Forkbomb A task makes 2000 children in a second.
2. 2000 children has almost same memory usage. I know another factors
affect oom_score. but in here, I assume all of children have almost same
badness score. 
3. Your heuristic penalizes A task so it would be detected as forkbomb. 
4. So OOM killer select A task as bad task. 
5. oom_kill_process kills high badness one of children, _NOT_ task A
itself. Unfortunately high badness child doesn't has big memory usage
compared to sibling. It means sooner or later we would need OOM again. 


My point was 5.

1. oom_kill_process have to take a long time to scan tasklist for
selecting just one high badness task. Okay. It's right since OOM system
hang is much bad and it would be better to kill just first task(ie,
random one) in tasklist. 

2. But in above scenario, sibling have almost same memory. So we would
need OOM again sooner or later and OOM logic could do above scenario
repeatably. 

Yes. Our system is already unresponsible since time slice is spread out
many child tasks. Then in here, it would be better to kill dumb child
instead of BUGGY forkbomb task A? How long time do we have to wait
system responsible? 

I said _BUGGY_ forkbomb task. That's because Rik's example isn't buggy
task. Administrator already knows apache can make many task in a second.
So he can handle it by your oom_forkbomb_thres knob. It's goal of your
knob. 

So my suggestion is following as. 

I assume normal forkbomb tasks are handled well by admin who use your
oom_forkbom_thres. The remained problem is just BUGGY forkbomb process. 
So if your logic selects same victim task as forkbomb by your heuristic
and it's 5th time continuously in 10 second, let's kill forkbomb instead
of child.

tsk = select_victim_task(&cause);
if (tsk == last_victim_tsk && cause == BUGGY_FORKBOMB)
	if (++count == 5 && time_since_first_detect_forkbomb <= 10*HZ)
		kill(tsk);
else {
   last_victim_tsk = NULL; count = 0; time_since... = 0;
   kill(tsk's child);
}

It's just example of my concern. It might never good solution.
What I mean is just whether we have to care this.



-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
