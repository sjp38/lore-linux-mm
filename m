Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A52C58D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 21:57:32 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id ACACE3EE0BC
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:57:28 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 935D345DE61
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:57:28 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 70DA945DE69
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:57:28 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 62576E08003
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:57:28 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 26B84E18004
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:57:28 +0900 (JST)
Date: Tue, 8 Mar 2011 11:51:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] memcg: add oom killer delay
Message-Id: <20110308115108.36b184c5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1103071721330.25197@chino.kir.corp.google.com>
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
	<20110307171853.c31ec416.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1103071721330.25197@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Mon, 7 Mar 2011 17:33:44 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Mon, 7 Mar 2011, Andrew Morton wrote:
> 
> > > It could be, if users assign the handler to a different memcg; otherwise, 
> > > it's guaranteed.
> > 
> > Putting the handler into the same container would be rather daft.
> > 
> > If userspace is going to elect to take over a kernel function then it
> > should be able to perform that function reliably.  We don't have hacks
> > in the kernel to stop runaway SCHED_FIFO tasks, either.  If the oom
> > handler has put itself into a memcg and then has permitted that memcg
> > to go oom then userspace is busted.
> > 
> 
> We have a container specifically for daemons like this and have struggled 
> for years to accurately predict how much memory it needs and what to do 
> when it is oom.  The problem, in this case, is that when it's oom it's too 
> late: the memcg is livelocked and then no memory limits on the system have 
> a chance of getting increased and nothing in oom memcgs are guaranteed to 
> ever make forward progress again.
> 
> That's why I keep bringing up the point that this patch is not a bugfix: 
> it's an extension of a feature (memory.oom_control) to allow userspace a 
> period of time to respond to memcgs reaching their hard limit before 
> killing something.  For our container with vital system daemons, this is 
> absolutely mandatory if something consumes a large amount of memory and 
> needs to be restarted; we want the logic in userspace to determine what to 
> do without killing vital tasks or panicking.  We want to use the oom 
> killer only as a last resort and that can effectively be done with this 
> patch and not with memory.oom_control (and I think this is why Kame acked 
> it).
> 

I acked just because the code itself seems to work. _And_ I can't convince
you "that function is never necessary". But please note, you don't convice
me "that's necessary".

BTW, why "the memcg is livelocked and then no memory limits on the system have 
a chance of getting increased"

Is there a memcg bug which prevents increasing limit ?

THanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
