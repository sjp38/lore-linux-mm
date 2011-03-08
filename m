Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CEEE98D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 20:33:55 -0500 (EST)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p281XpqW023794
	for <linux-mm@kvack.org>; Mon, 7 Mar 2011 17:33:51 -0800
Received: from pzk3 (pzk3.prod.google.com [10.243.19.131])
	by hpaq11.eem.corp.google.com with ESMTP id p281XmJj012743
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 7 Mar 2011 17:33:50 -0800
Received: by pzk3 with SMTP id 3so896734pzk.32
        for <linux-mm@kvack.org>; Mon, 07 Mar 2011 17:33:48 -0800 (PST)
Date: Mon, 7 Mar 2011 17:33:44 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] memcg: add oom killer delay
In-Reply-To: <20110307171853.c31ec416.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1103071721330.25197@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com> <alpine.DEB.2.00.1102091417410.5697@chino.kir.corp.google.com> <20110223150850.8b52f244.akpm@linux-foundation.org> <alpine.DEB.2.00.1102231636260.21906@chino.kir.corp.google.com>
 <20110303135223.0a415e69.akpm@linux-foundation.org> <alpine.DEB.2.00.1103071602080.23035@chino.kir.corp.google.com> <20110307162912.2d8c70c1.akpm@linux-foundation.org> <alpine.DEB.2.00.1103071631080.23844@chino.kir.corp.google.com>
 <20110307165119.436f5d21.akpm@linux-foundation.org> <alpine.DEB.2.00.1103071657090.24549@chino.kir.corp.google.com> <20110307171853.c31ec416.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Mon, 7 Mar 2011, Andrew Morton wrote:

> > It could be, if users assign the handler to a different memcg; otherwise, 
> > it's guaranteed.
> 
> Putting the handler into the same container would be rather daft.
> 
> If userspace is going to elect to take over a kernel function then it
> should be able to perform that function reliably.  We don't have hacks
> in the kernel to stop runaway SCHED_FIFO tasks, either.  If the oom
> handler has put itself into a memcg and then has permitted that memcg
> to go oom then userspace is busted.
> 

We have a container specifically for daemons like this and have struggled 
for years to accurately predict how much memory it needs and what to do 
when it is oom.  The problem, in this case, is that when it's oom it's too 
late: the memcg is livelocked and then no memory limits on the system have 
a chance of getting increased and nothing in oom memcgs are guaranteed to 
ever make forward progress again.

That's why I keep bringing up the point that this patch is not a bugfix: 
it's an extension of a feature (memory.oom_control) to allow userspace a 
period of time to respond to memcgs reaching their hard limit before 
killing something.  For our container with vital system daemons, this is 
absolutely mandatory if something consumes a large amount of memory and 
needs to be restarted; we want the logic in userspace to determine what to 
do without killing vital tasks or panicking.  We want to use the oom 
killer only as a last resort and that can effectively be done with this 
patch and not with memory.oom_control (and I think this is why Kame acked 
it).

> My issue with this patch is that it extends the userspace API.  This
> means we're committed to maintaining that interface *and its behaviour*
> for evermore.  But the oom-killer and memcg are both areas of intense
> development and the former has a habit of getting ripped out and
> rewritten.  Committing ourselves to maintaining an extension to the
> userspace interface is a big thing, especially as that extension is
> somewhat tied to internal implementation details and is most definitely
> tied to short-term inadequacies in userspace and in the kernel
> implementation.
> 

The same could have been said for memory.oom_control to disable the oom 
killer entirely which no seems to be solidified as the only way to 
influence oom killer behavior from the kernel and now we're locked into 
that limitation because we don't want dual interfaces.  I think this patch 
would have been received much better prior to memory.oom_control since it 
allows for the same behavior with an infinite timeout.  memory.oom_control 
is not an option for us since we can't guarantee that any userspace daemon 
at our scale will ever be responsive 100% of the time.

I don't think the idea of a userspace grace period when a memcg is oom is 
that abstract, though.  I think applications should have the opportunity 
to free some of their own memory first when oom instead of abruptly 
killing something and restarting it.

So, in the end, we may have to carry this patch internally forever but I 
think as memcg becomes more popular we'll have a higher demand for such a 
grace period.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
