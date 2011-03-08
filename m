Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4CAEF8D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 18:49:39 -0500 (EST)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p28NnbbU016166
	for <linux-mm@kvack.org>; Tue, 8 Mar 2011 15:49:37 -0800
Received: from yxm8 (yxm8.prod.google.com [10.190.4.8])
	by wpaz1.hot.corp.google.com with ESMTP id p28NnHxc030185
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 8 Mar 2011 15:49:35 -0800
Received: by yxm8 with SMTP id 8so2616852yxm.12
        for <linux-mm@kvack.org>; Tue, 08 Mar 2011 15:49:17 -0800 (PST)
Date: Tue, 8 Mar 2011 15:49:10 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] memcg: add oom killer delay
In-Reply-To: <20110308144901.fe34abd0.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1103081540320.27910@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com> <20110303135223.0a415e69.akpm@linux-foundation.org> <alpine.DEB.2.00.1103071602080.23035@chino.kir.corp.google.com> <20110307162912.2d8c70c1.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1103071631080.23844@chino.kir.corp.google.com> <20110307165119.436f5d21.akpm@linux-foundation.org> <alpine.DEB.2.00.1103071657090.24549@chino.kir.corp.google.com> <20110307171853.c31ec416.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1103071721330.25197@chino.kir.corp.google.com> <20110308115108.36b184c5.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103071905400.1640@chino.kir.corp.google.com> <20110308121332.de003f81.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1103071954550.2883@chino.kir.corp.google.com> <20110308131723.e434cb89.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1103072126590.4593@chino.kir.corp.google.com> <20110308144901.fe34abd0.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Tue, 8 Mar 2011, KAMEZAWA Hiroyuki wrote:

> > That's aside from the general purpose of the new 
> > memory.oom_delay_millisecs: users may want a grace period for userspace to 
> > increase the hard limit or kill a task before deferring to the kernel.  
> > That seems exponentially more useful than simply disabling the oom killer 
> > entirely with memory.oom_control.  I think it's unfortunate 
> > memory.oom_control was merged frst and seems to have tainted this entire 
> > discussion.
> > 
> 
> That sounds like a mis-usage problem....what kind of workaround is offerred
> if the user doesn't configure oom_delay_millisecs , a yet another mis-usage ?
> 

Not exactly sure what you mean, but you're saying disabling the oom killer 
with memory.oom_control is not the recommended way to allow userspace to 
fix the issue itself?  That seems like it's the entire usecase: we'd 
rarely want to let a memcg stall when it needs memory without trying to 
address the problem (elevating the limit, killing a lower priority job, 
sending a signal to free memory).  We have a memcg oom notifier to handle 
the situation but there's no guarantee that the kernel won't kill 
something first and that's a bad result if we chose to address it with one 
of the ways mentioned above.

To answer your question: if the admin doesn't configure a 
memory.oom_delay_millisecs, then the oom killer will obviously kill 
something off (if memory.oom_control is also not set) when reclaim fails 
to free memory just as before.

Aside from my specific usecase for this tunable, let me pose a question: 
do you believe that the memory controller would benefit from allowing 
users to have a grace period in which to take one of the actions listed 
above instead of killing something itself?  Yes, this would be possible by 
setting and then unsetting memory.oom_control, but that requires userspace 
to always be responsive (which, at our scale, we can unequivocally say 
isn't always possible) and doesn't effectively deal with spikes in memory 
that may only be temporary and doesn't require any intervention of the 
user at all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
