Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5AA77600429
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 20:37:37 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o730evra032294
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 3 Aug 2010 09:40:58 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A9A9C45DE57
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 09:40:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8535A45DE51
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 09:40:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C9241DB803E
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 09:40:57 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 05FB11DB803C
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 09:40:57 +0900 (JST)
Date: Tue, 3 Aug 2010 09:36:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm 1/2] oom: badness heuristic rewrite
Message-Id: <20100803093610.f4d30ca7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1008021713310.9569@chino.kir.corp.google.com>
References: <20100730091125.4AC3.A69D9226@jp.fujitsu.com>
	<20100729183809.ca4ed8be.akpm@linux-foundation.org>
	<20100730195338.4AF6.A69D9226@jp.fujitsu.com>
	<20100802134312.c0f48615.akpm@linux-foundation.org>
	<20100803090058.48c0a0c9.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008021713310.9569@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@in.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2 Aug 2010 17:27:13 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 3 Aug 2010, KAMEZAWA Hiroyuki wrote:
> 
> > One reason I poitned out is that this new parameter is hard to use for admins and
> > library writers. 
> >   old oom_adj was defined as an parameter works as 
> > 		(memory usage of app)/oom_adj.
> 
> Where are you getting this definition from?
> 
> Disregarding all the other small adjustments in the old heuristic, a 
> reduced version of the formula was mm->total_vm << oom_adj.  It's a 
> shift, not a divide.  That has no sensible meaning.
> 
yes. that was quite useless.



> >   new oom_score_adj was define as
> > 		(memory usage of app * oom_score_adj)/ system_memory
> > 
> 
> No, it's (rss + swap + oom_score_adj) / bound memory.  It's an addition, 
> not a multiplication, and it's a proportion of memory the application is 
> bound to, not the entire system (it could be constrained by cpuset, 
> mempolicy, or memcg).
> 
sorry.

> > Then, an applications' oom_score on a host is quite different from on the other
> > host. This operation is very new rather than a simple interface updates.
> > This opinion was rejected.
> > 
> 
> It wasn't rejected, I responded to your comment and you never wrote back.  
> The idea 
> 
I just got tired to write the same thing in many times. And I don't have
strong opinions. I _know_ your patch fixes X-server problem. That was enough
for me.


> > Anyway, I believe the value other than OOM_DISABLE is useless,
> 
> You're right in that OOM_DISABLE fulfills may typical use cases to simply 
> protect a task by making it immune to the oom killer.  But there are other 
> use cases for the oom killer that you're perhaps not using where a 
> sensible userspace tunable does make a difference: the goal of the 
> heuristic is always to kill the task consuming the most amount of memory 
> to avoid killing tons of applications for subsequent page allocations.  We 
> do run important tasks that consume lots of memory, though, and the kernel 
> can't possibly know about that importance.  So although you may never use 
> a positive oom_score_adj, although others will, you probably can find a 
> use case for subtracting a memory quantity from a known memory hogging 
> task that you consider to be vital in an effort to disregard that quantity 
> from the score.  I'm sure you'll agree it's a much more powerful (and 
> fine-grained) interface than oom_adj.
> 
Yes, I agree if we can assume the admins are very clever.

> > I have no concerns. I'll use memcg if I want to control this kind of things.
> > 
> 
> That would work if you want to setup individual memcgs for every 
> application on your system, know what sane limits are for each one, and 
> want to incur the significant memory expense of enabling 
> CONFIG_CGROUP_MEM_RES_CTLR for its metadata.
> 
Usual disto alreay enables it.

Simply puts all applications to a group and disable oom and set oom_notifier. 
Then,
 - a "pop-up window" of task list will ask the user "which one do you want to kill ?"
 - send a packet to ask a administlation server system "which one is killable ?"
   or "increase memory limit" or "memory hot-add ?" 

Possible case will be
   - send SIGSTOP to all apps at OOM.
   - rise limit to some extent. or move a killable one to a special group.
   - wake up a killable one with SIGCONT.
   - send SIGHUP to stop it safely.

"My application is killed by the system!!, without running safe emeregency code!"
is the fundamental seeds of disconent.


Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
