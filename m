Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B60728D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 01:11:15 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 649073EE0BC
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:11:12 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B1C245DE5F
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:11:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 31FD445DE5B
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:11:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EE6E1DB8048
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:11:12 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D8580E38001
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 15:11:11 +0900 (JST)
Date: Wed, 9 Mar 2011 15:04:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] memcg: add oom killer delay
Message-Id: <20110309150452.29883939.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1103081540320.27910@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1103071602080.23035@chino.kir.corp.google.com>
	<20110307162912.2d8c70c1.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1103071631080.23844@chino.kir.corp.google.com>
	<20110307165119.436f5d21.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1103071657090.24549@chino.kir.corp.google.com>
	<20110307171853.c31ec416.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1103071721330.25197@chino.kir.corp.google.com>
	<20110308115108.36b184c5.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1103071905400.1640@chino.kir.corp.google.com>
	<20110308121332.de003f81.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1103071954550.2883@chino.kir.corp.google.com>
	<20110308131723.e434cb89.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1103072126590.4593@chino.kir.corp.google.com>
	<20110308144901.fe34abd0.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1103081540320.27910@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Tue, 8 Mar 2011 15:49:10 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 8 Mar 2011, KAMEZAWA Hiroyuki wrote:
> 
> > > That's aside from the general purpose of the new 
> > > memory.oom_delay_millisecs: users may want a grace period for userspace to 
> > > increase the hard limit or kill a task before deferring to the kernel.  
> > > That seems exponentially more useful than simply disabling the oom killer 
> > > entirely with memory.oom_control.  I think it's unfortunate 
> > > memory.oom_control was merged frst and seems to have tainted this entire 
> > > discussion.
> > > 
> > 
> > That sounds like a mis-usage problem....what kind of workaround is offerred
> > if the user doesn't configure oom_delay_millisecs , a yet another mis-usage ?
> > 
> 
> Not exactly sure what you mean, but you're saying disabling the oom killer 
> with memory.oom_control is not the recommended way to allow userspace to 
> fix the issue itself?  That seems like it's the entire usecase: we'd 
> rarely want to let a memcg stall when it needs memory without trying to 
> address the problem (elevating the limit, killing a lower priority job, 
> sending a signal to free memory).  We have a memcg oom notifier to handle 
> the situation but there's no guarantee that the kernel won't kill 
> something first and that's a bad result if we chose to address it with one 
> of the ways mentioned above.
> 

Why memcg's oom and system's oom happens at the same time ?



> To answer your question: if the admin doesn't configure a 
> memory.oom_delay_millisecs, then the oom killer will obviously kill 
> something off (if memory.oom_control is also not set) when reclaim fails 
> to free memory just as before.
> 
> Aside from my specific usecase for this tunable, let me pose a question: 
> do you believe that the memory controller would benefit from allowing 
> users to have a grace period in which to take one of the actions listed 
> above instead of killing something itself?  Yes, this would be possible by 
> setting and then unsetting memory.oom_control, but that requires userspace 
> to always be responsive (which, at our scale, we can unequivocally say 
> isn't always possible) and doesn't effectively deal with spikes in memory 
> that may only be temporary and doesn't require any intervention of the 
> user at all.
> 

Please add 'notifier' in kernel space and handle the event by kernel module.
It is much better than 'timeout and allow oom-kill again'.

If you add a notifier_chain in memcg's oom path, I have no obstruction.
Implementing custom oom handler for it in kernel module sounds better
than timeout. If necessary, please export some functionailty of memcg.

IIUC, system's oom-killer has notifier chain of oom-kill. There is no reason
it's bad to have one for memcg.

Isn't it ok ? I think you can do what you want with it.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
