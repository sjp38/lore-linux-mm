Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A85F68D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 02:22:50 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 11AF23EE0B6
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 16:22:48 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E881F45DE57
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 16:22:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C3C5545DE5B
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 16:22:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B634BE08001
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 16:22:47 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F047E18002
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 16:22:47 +0900 (JST)
Date: Wed, 9 Mar 2011 16:16:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] memcg: add oom killer delay
Message-Id: <20110309161621.f890c148.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1103082239340.15665@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com>
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
	<20110309150452.29883939.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1103082239340.15665@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Tue, 8 Mar 2011 22:44:11 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 9 Mar 2011, KAMEZAWA Hiroyuki wrote:
 > > Aside from my specific usecase for this tunable, let me pose a question: 
> > > do you believe that the memory controller would benefit from allowing 
> > > users to have a grace period in which to take one of the actions listed 
> > > above instead of killing something itself?  Yes, this would be possible by 
> > > setting and then unsetting memory.oom_control, but that requires userspace 
> > > to always be responsive (which, at our scale, we can unequivocally say 
> > > isn't always possible) and doesn't effectively deal with spikes in memory 
> > > that may only be temporary and doesn't require any intervention of the 
> > > user at all.
> > > 
> > 
> > Please add 'notifier' in kernel space and handle the event by kernel module.
> > It is much better than 'timeout and allow oom-kill again'.
> > 
> 
> A kernel-space notifier would certainly be helpful, but at what point does 
> the kernel choose to oom kill something?  If there's an oom notifier in 
> place, do we always defer killing or for a set period of time? 

For google, as you like.

For me, I want an oom-killall module Or oom-SIGSTOP-all module.
oom-killall will be useful for killing fork-bombs and very quick recovery.

For me, the 1st motivation of oom-disable is to taking core-dump of
memory leaking process and look into it for checking memory leak.
(panic_on_oom -> kdump is used for supporting my customer.)

Maybe my example of notifier user doesn't sounds good to you, 
please find a good one.


> If it's  the latter then we'll still want the timeout, otherwise there's no
> way to  guarantee we haven't killed something by the time userspace has a chance 
> to react to the notification.
> 

You can get a list of tasks in the cgroup and send SIGNALs with filters you like.
List of thread-IDs can be got easily with cgroup_iter_xxx functions.

Anyway, if you add notifier, please give us a user of it. If possible,
it should be a function which can never be implemented in userland even
with sane programmers, admins, and users.

For example, if all process's oom_score_adj was set to -1000 and oom-killer
doesn't work, do you implement a timeout ? I think you'll say it's a
wrong configuration. memcg's oom_disable timeout is the same thing.

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
