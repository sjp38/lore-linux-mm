Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D0B51600429
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 21:09:34 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o731D6ub019121
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 3 Aug 2010 10:13:06 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D186745DE51
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 10:13:05 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A810D45DE50
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 10:13:05 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 876081DB801F
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 10:13:04 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C27501DB801B
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 10:13:03 +0900 (JST)
Date: Tue, 3 Aug 2010 10:08:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm 1/2] oom: badness heuristic rewrite
Message-Id: <20100803100815.11d10519.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1008021742440.9569@chino.kir.corp.google.com>
References: <20100730091125.4AC3.A69D9226@jp.fujitsu.com>
	<20100729183809.ca4ed8be.akpm@linux-foundation.org>
	<20100730195338.4AF6.A69D9226@jp.fujitsu.com>
	<20100802134312.c0f48615.akpm@linux-foundation.org>
	<20100803090058.48c0a0c9.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008021713310.9569@chino.kir.corp.google.com>
	<20100803093610.f4d30ca7.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008021742440.9569@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@in.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2 Aug 2010 18:02:48 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 3 Aug 2010, KAMEZAWA Hiroyuki wrote:
> 
> > > > Then, an applications' oom_score on a host is quite different from on the other
> > > > host. This operation is very new rather than a simple interface updates.
> > > > This opinion was rejected.
> > > > 
> > > 
> > > It wasn't rejected, I responded to your comment and you never wrote back.  
> > > The idea 
> > > 
> > I just got tired to write the same thing in many times. And I don't have
> > strong opinions. I _know_ your patch fixes X-server problem. That was enough
> > for me.
> > 
> 
> There're a couple of reasons why I disagree that oom_score_adj should have 
> memory quantity units.
> 
> First, individual oom scores that come out of oom_badness() don't mean 
> anything in isolation, they only mean something when compared to other 
> candidate tasks.  All applications, whether attached to a cpuset, a 
> mempolicy, a memcg, or not, have an allowed set of memory and applications 
> that are competing for those shared resources.  When defining what 
> application happens to be the most memory hogging, which is the one we 
> want to kill, they are ranked amongst themselves.  Using oom_score_adj as 
> a proportion, we can say a particular application should be allowed 25% of 
> resources, other applications should be allowed 5%, and others should be 
> penalized 10%, for example.  This makes prioritization for oom kill rather 
> simple.
> 
> Second, we don't want to adjust oom_score_adj anytime a task is attached 
> to a cpuset, a mempolicy, or a memcg, or whenever those cpuset's mems 
> changes, the bound mempolicy nodemask changes, or the memcg limit changes.  
> The application need not know what that set of allowed memory is and the 
> kernel should operate seemlessly regardless of what the attachment is.  
> These are, in a sense, "virtualized" systems unto themselves: if a task is 
> moved from a child cpuset to the root cpuset, it's set of allowed memory 
> may become much larger.  That action shouldn't need to have an equivalent 
> change to /proc/pid/oom_score_adj: the priority of the task relative to 
> its other competing tasks is the same.  That set of allowed memory may 
> change, but its priority does not unless explicitly changed by the admin.
> 

Hmm, then, oom_score shows the values for all limitations in array ?


> > > That would work if you want to setup individual memcgs for every 
> > > application on your system, know what sane limits are for each one, and 
> > > want to incur the significant memory expense of enabling 
> > > CONFIG_CGROUP_MEM_RES_CTLR for its metadata.
> > > 
> > Usual disto alreay enables it.
> > 
> 
> Yes, I'm well aware of my 40MB of lost memory on my laptop :)
> 
Very sorry ;)
But it's required to track memory usage from init...

> > Simply puts all applications to a group and disable oom and set oom_notifier. 
> > Then,
> >  - a "pop-up window" of task list will ask the user "which one do you want to kill ?"
> >  - send a packet to ask a administlation server system "which one is killable ?"
> >    or "increase memory limit" or "memory hot-add ?" 
> > 
> 
> Having user interaction at the time of oom would certainly be nice, but is 
> certainly impractical for us.  So we need some way to state the relative 
> importance of a task to the kernel so that it can act on our behalf when 
> we encounter such a condition.  I believe oom_score_adj does that quite 
> effectively.
> 
I don't disagree we need some way. And please take my words as strong objections.
I repeatedly said "I like the patch". but just had small concerns.
And I already explained why I can ignore my concners.


> > Possible case will be
> >    - send SIGSTOP to all apps at OOM.
> >    - rise limit to some extent. or move a killable one to a special group.
> >    - wake up a killable one with SIGCONT.
> >    - send SIGHUP to stop it safely.
> > 
> 
> We use oom notifiers with cpusets, which in this case can be used 
> identically to how you're imagining memcg can be used.  This particular 
> change, however, only affects the oom killer: that is, it's only scope is 
> that when the kernel can't do anything else, no userspace notifier is 
> attached, and no memory freeing is going to otherwise occur.  I would love 
> to see a per-cgroup oom notifier to allow userspace to respond to these 
> conditions in more effective ways, but I still believe there is a general 
> need for a simple and predictable oom killer heuristic that the user has 
> full power over.
> 


yes. the kernel's oom killer should work as the final back-up.
And your new one works very well for X-server case which was an issue for
long time.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
