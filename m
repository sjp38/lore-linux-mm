Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 681046B01CC
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 14:57:01 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id o51IuugW030657
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 11:56:57 -0700
Received: from pwi8 (pwi8.prod.google.com [10.241.219.8])
	by kpbe15.cbf.corp.google.com with ESMTP id o51IutcW006226
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 11:56:55 -0700
Received: by pwi8 with SMTP id 8so2624941pwi.17
        for <linux-mm@kvack.org>; Tue, 01 Jun 2010 11:56:55 -0700 (PDT)
Date: Tue, 1 Jun 2010 11:56:48 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 08/18] oom: badness heuristic rewrite
In-Reply-To: <20100601074620.GR9453@laptop>
Message-ID: <alpine.DEB.2.00.1006011144340.32024@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com> <alpine.DEB.2.00.1006010015030.29202@chino.kir.corp.google.com> <20100601074620.GR9453@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 1 Jun 2010, Nick Piggin wrote:

> > This a complete rewrite of the oom killer's badness() heuristic which is
> > used to determine which task to kill in oom conditions.  The goal is to
> > make it as simple and predictable as possible so the results are better
> > understood and we end up killing the task which will lead to the most
> > memory freeing while still respecting the fine-tuning from userspace.
> 
> Do you have particular ways of testing this (and other heuristics
> changes such as the forkbomb detector)?
> 

Yes, the patch prior to this one in the series, "oom: enable oom tasklist 
dump by default", allows you to examine the oom_score_adj of all eligible 
tasks.  Used in combination with /proc/pid/oom_score, which reports the 
result of the badness heuristic to userspace, I tested the result of the 
change by ensuring that it worked as intended.  Since we'll now see a 
tasklist dump of all eligible tasks whenever someone reports an oom 
problem (hopefully fewer reports as a result of this rewrite than 
currently!), it's much easier to determine (i) why the oom killer was 
called, and (ii) why a particular task was chosen for kill.  That's been 
my testing philosophy.

The forkbomb detector does add a minimal bias to tasks that have a large 
number of execve children, just as the current oom killer does (although 
the bias is much smaller with my heursitic).  Rik and I had a lengthy 
conversation on linux-mm about that when it was first proposed.  The key 
to that particular bias is that you must remember that even though a task 
is selected for oom kill that the oom killer still attempts to kill an 
execve child first.  So the end result is that an important system daemon, 
such as a webserver, doesn't actually get oom killed when it's selected as 
a result of this, but it's more of a bias toward the children to be killed 
(a client) instead.  We're guaranteed that a child will be killed if a 
task is chosen as the result of a tiebreaker because of the forkbomb 
detector because it surely has a child with a different mm that is 
eligible.  This isn't meant to be enforce a kernel-wide forkbomb policy, 
which would obviously be better implemented elsewhere, but rather bias the 
children when a parent is forking an egregiously large number of tasks.  
"Egregious" in this case is defined as whatever the user uses for 
oom_forkbomb_thres, which I believe defaults to a sane value of 1000.

> Such that you can look at your test case or workload and see that
> it is really improved?
> 

I'm glad you asked that because some recent conversation has been 
slightly confusing to me about how this affects the desktop; this rewrite 
significantly improves the oom killer's response for desktop users.  The 
core ideas were developed in the thread from this mailing list back in 
February called "Improving OOM killer" at 
http://marc.info/?t=126506191200004&r=4&w=2 -- users constantly report 
that vital system tasks such as kdeinit are killed whenever a memory 
hogging task is forked either intentionally or unintentionally.  I argued 
for a while that KDE should be taking proper precautions by adjusting its 
own oom_adj score and that of its forked children as it's an inherited 
value, but I was eventually convinced that an overall improvement to the 
heuristic must be made to kill a task that was known to free a large 
amount of memory that is resident in RAM and that we have a consistent way 
of defining oom priorities when a task is run uncontained and when it is a 
member of a memcg or cpuset (or even mempolicy now), even in the case when 
it's contained out from under the task's knowledge.  When faced with 
memory pressure from an out of control or memory hogging task on the 
desktop, the oom killer now kills it instead of a vital task such as an X 
server (and oracle, webserver, etc on server platforms) because of the use 
of the task's rss instead of total_vm statistic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
