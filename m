Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3CB3F8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 20:19:00 -0500 (EST)
Date: Mon, 7 Mar 2011 17:18:53 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] memcg: add oom killer delay
Message-Id: <20110307171853.c31ec416.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1103071657090.24549@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1102091417410.5697@chino.kir.corp.google.com>
	<20110223150850.8b52f244.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1102231636260.21906@chino.kir.corp.google.com>
	<20110303135223.0a415e69.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1103071602080.23035@chino.kir.corp.google.com>
	<20110307162912.2d8c70c1.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1103071631080.23844@chino.kir.corp.google.com>
	<20110307165119.436f5d21.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1103071657090.24549@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Mon, 7 Mar 2011 17:02:36 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Mon, 7 Mar 2011, Andrew Morton wrote:
> 
> > > > > So the question I'd ask is
> > > > 
> > > > What about my question?  Why is your usersapce oom-handler "unresponsive"?
> > > > 
> > > 
> > > If we have a per-memcg userspace oom handler, then it's absolutely 
> > > required that it either increase the hard limit of the oom memcg or kill a 
> > > task to free memory; anything else risks livelocking that memcg.  At 
> > > the same time, the oom handler's memcg isn't really important: it may be 
> > > in a different memcg but it may be oom at the same time.  If we risk 
> > > livelocking the memcg when it is oom and the oom killer cannot respond 
> > > (the only reason for the oom killer to exist in the first place), then 
> > > there's no guarantee that a userspace oom handler could respond under 
> > > livelock.
> > 
> > So you're saying that your userspace oom-handler is in a memcg which is
> > also oom?
> 
> It could be, if users assign the handler to a different memcg; otherwise, 
> it's guaranteed.

Putting the handler into the same container would be rather daft.

If userspace is going to elect to take over a kernel function then it
should be able to perform that function reliably.  We don't have hacks
in the kernel to stop runaway SCHED_FIFO tasks, either.  If the oom
handler has put itself into a memcg and then has permitted that memcg
to go oom then userspace is busted.

>  Keep in mind that for oom situations we give the killed 
> task access to memory reserves below the min watermark with TIF_MEMDIE so 
> that they can allocate memory to exit as quickly as possible (either to 
> handle the SIGKILL or within the exit path).  That's because we can't 
> guarantee anything within an oom system, cpuset, mempolicy, or memcg is 
> ever responsive without it.  (And, the side effect of it and its threads 
> exiting is the freeing of memory which allows everything else to once 
> again be responsive.)
> 
> > That this is the only situation you've observed in which the
> > userspace oom-handler is "unresponsive"?
> > 
> 
> Personally, yes, but I could imagine other users could get caught if their 
> userspace oom handler requires taking locks (such as mmap_sem) by reading 
> within procfs that a thread within an oom memcg already holds.

If activity in one memcg cause a lockup of processes in a separate
memcg then that's a containment violation and we should fix it.

One could argue that peering into a separate memcg's procfs files was
already a containment violation, but from a practical point of view we
definitely do want processes in a separate memcg to be able to
passively observe activity in another without stepping on lindmines.


My issue with this patch is that it extends the userspace API.  This
means we're committed to maintaining that interface *and its behaviour*
for evermore.  But the oom-killer and memcg are both areas of intense
development and the former has a habit of getting ripped out and
rewritten.  Committing ourselves to maintaining an extension to the
userspace interface is a big thing, especially as that extension is
somewhat tied to internal implementation details and is most definitely
tied to short-term inadequacies in userspace and in the kernel
implementation.

We should not commit the kernel to maintaining this new interface for
all time until all alternatives have been eliminated.  The patch looks
to me like a short-term hack to work around medium-term userspace and
kernel inadequacies, and that's a really bad basis upon which to merge
it.  Expedient hacks do sometimes makes sense, but it's real bad when
they appear in the API.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
