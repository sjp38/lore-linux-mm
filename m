Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4D54C8D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 01:44:20 -0500 (EST)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id p296iG66019400
	for <linux-mm@kvack.org>; Tue, 8 Mar 2011 22:44:16 -0800
Received: from iyb26 (iyb26.prod.google.com [10.241.49.90])
	by kpbe16.cbf.corp.google.com with ESMTP id p296iErT004473
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 8 Mar 2011 22:44:15 -0800
Received: by iyb26 with SMTP id 26so255862iyb.12
        for <linux-mm@kvack.org>; Tue, 08 Mar 2011 22:44:14 -0800 (PST)
Date: Tue, 8 Mar 2011 22:44:11 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] memcg: add oom killer delay
In-Reply-To: <20110309150452.29883939.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1103082239340.15665@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com> <20110307162912.2d8c70c1.akpm@linux-foundation.org> <alpine.DEB.2.00.1103071631080.23844@chino.kir.corp.google.com> <20110307165119.436f5d21.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1103071657090.24549@chino.kir.corp.google.com> <20110307171853.c31ec416.akpm@linux-foundation.org> <alpine.DEB.2.00.1103071721330.25197@chino.kir.corp.google.com> <20110308115108.36b184c5.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1103071905400.1640@chino.kir.corp.google.com> <20110308121332.de003f81.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103071954550.2883@chino.kir.corp.google.com> <20110308131723.e434cb89.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1103072126590.4593@chino.kir.corp.google.com> <20110308144901.fe34abd0.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103081540320.27910@chino.kir.corp.google.com> <20110309150452.29883939.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Wed, 9 Mar 2011, KAMEZAWA Hiroyuki wrote:

> > Not exactly sure what you mean, but you're saying disabling the oom killer 
> > with memory.oom_control is not the recommended way to allow userspace to 
> > fix the issue itself?  That seems like it's the entire usecase: we'd 
> > rarely want to let a memcg stall when it needs memory without trying to 
> > address the problem (elevating the limit, killing a lower priority job, 
> > sending a signal to free memory).  We have a memcg oom notifier to handle 
> > the situation but there's no guarantee that the kernel won't kill 
> > something first and that's a bad result if we chose to address it with one 
> > of the ways mentioned above.
> > 
> 
> Why memcg's oom and system's oom happens at the same time ?
> 

Again, I'm not sure what you mean: there's no system oom in what I 
describe above.  I'm saying that userspace may not have sufficient time to 
react to an oom notification unless the oom killer is disabled via 
memory.oom_control and re-enabled iff userspace chooses to defer to the 
kernel.

> > Aside from my specific usecase for this tunable, let me pose a question: 
> > do you believe that the memory controller would benefit from allowing 
> > users to have a grace period in which to take one of the actions listed 
> > above instead of killing something itself?  Yes, this would be possible by 
> > setting and then unsetting memory.oom_control, but that requires userspace 
> > to always be responsive (which, at our scale, we can unequivocally say 
> > isn't always possible) and doesn't effectively deal with spikes in memory 
> > that may only be temporary and doesn't require any intervention of the 
> > user at all.
> > 
> 
> Please add 'notifier' in kernel space and handle the event by kernel module.
> It is much better than 'timeout and allow oom-kill again'.
> 

A kernel-space notifier would certainly be helpful, but at what point does 
the kernel choose to oom kill something?  If there's an oom notifier in 
place, do we always defer killing or for a set period of time?  If it's 
the latter then we'll still want the timeout, otherwise there's no way to 
guarantee we haven't killed something by the time userspace has a chance 
to react to the notification.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
