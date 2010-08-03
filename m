Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 68FBB600429
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 21:25:36 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o731TEMX021261
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 3 Aug 2010 10:29:14 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B7B7D45DE53
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 10:29:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8842745DE50
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 10:29:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 64F731DB8044
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 10:29:13 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 10BE51DB803C
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 10:29:13 +0900 (JST)
Date: Tue, 3 Aug 2010 10:24:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm 1/2] oom: badness heuristic rewrite
Message-Id: <20100803102423.82415a17.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100803100815.11d10519.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100730091125.4AC3.A69D9226@jp.fujitsu.com>
	<20100729183809.ca4ed8be.akpm@linux-foundation.org>
	<20100730195338.4AF6.A69D9226@jp.fujitsu.com>
	<20100802134312.c0f48615.akpm@linux-foundation.org>
	<20100803090058.48c0a0c9.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008021713310.9569@chino.kir.corp.google.com>
	<20100803093610.f4d30ca7.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008021742440.9569@chino.kir.corp.google.com>
	<20100803100815.11d10519.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@in.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 3 Aug 2010 10:08:15 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Mon, 2 Aug 2010 18:02:48 -0700 (PDT)
> David Rientjes <rientjes@google.com> wrote:
> 
> > On Tue, 3 Aug 2010, KAMEZAWA Hiroyuki wrote:
> > 
> > > > > Then, an applications' oom_score on a host is quite different from on the other
> > > > > host. This operation is very new rather than a simple interface updates.
> > > > > This opinion was rejected.
> > > > > 
> > > > 
> > > > It wasn't rejected, I responded to your comment and you never wrote back.  
> > > > The idea 
> > > > 
> > > I just got tired to write the same thing in many times. And I don't have
> > > strong opinions. I _know_ your patch fixes X-server problem. That was enough
> > > for me.
> > > 
> > 
> > There're a couple of reasons why I disagree that oom_score_adj should have 
> > memory quantity units.
> > 
> > First, individual oom scores that come out of oom_badness() don't mean 
> > anything in isolation, they only mean something when compared to other 
> > candidate tasks.  All applications, whether attached to a cpuset, a 
> > mempolicy, a memcg, or not, have an allowed set of memory and applications 
> > that are competing for those shared resources.  When defining what 
> > application happens to be the most memory hogging, which is the one we 
> > want to kill, they are ranked amongst themselves.  Using oom_score_adj as 
> > a proportion, we can say a particular application should be allowed 25% of 
> > resources, other applications should be allowed 5%, and others should be 
> > penalized 10%, for example.  This makes prioritization for oom kill rather 
> > simple.
> > 
> > Second, we don't want to adjust oom_score_adj anytime a task is attached 
> > to a cpuset, a mempolicy, or a memcg, or whenever those cpuset's mems 
> > changes, the bound mempolicy nodemask changes, or the memcg limit changes.  
> > The application need not know what that set of allowed memory is and the 
> > kernel should operate seemlessly regardless of what the attachment is.  
> > These are, in a sense, "virtualized" systems unto themselves: if a task is 
> > moved from a child cpuset to the root cpuset, it's set of allowed memory 
> > may become much larger.  That action shouldn't need to have an equivalent 
> > change to /proc/pid/oom_score_adj: the priority of the task relative to 
> > its other competing tasks is the same.  That set of allowed memory may 
> > change, but its priority does not unless explicitly changed by the admin.
> > 
> 
> Hmm, then, oom_score shows the values for all limitations in array ?
> 
Anyway, the fact "oom_score can be changed by the context of OOM" may
confuse admins. "OMG, why low oom_score application is killed! Shit!"

Please add additional cares for users if we go this way or remove
user visible oom_score file from /proc.

Thanks,
-kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
