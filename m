Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id AEAC68D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 20:02:49 -0500 (EST)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p2812hXm029500
	for <linux-mm@kvack.org>; Mon, 7 Mar 2011 17:02:43 -0800
Received: from pxi15 (pxi15.prod.google.com [10.243.27.15])
	by hpaq14.eem.corp.google.com with ESMTP id p28124sT014002
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 7 Mar 2011 17:02:41 -0800
Received: by pxi15 with SMTP id 15so927127pxi.33
        for <linux-mm@kvack.org>; Mon, 07 Mar 2011 17:02:41 -0800 (PST)
Date: Mon, 7 Mar 2011 17:02:36 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] memcg: add oom killer delay
In-Reply-To: <20110307165119.436f5d21.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1103071657090.24549@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com> <alpine.DEB.2.00.1102091417410.5697@chino.kir.corp.google.com> <20110223150850.8b52f244.akpm@linux-foundation.org> <alpine.DEB.2.00.1102231636260.21906@chino.kir.corp.google.com>
 <20110303135223.0a415e69.akpm@linux-foundation.org> <alpine.DEB.2.00.1103071602080.23035@chino.kir.corp.google.com> <20110307162912.2d8c70c1.akpm@linux-foundation.org> <alpine.DEB.2.00.1103071631080.23844@chino.kir.corp.google.com>
 <20110307165119.436f5d21.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Mon, 7 Mar 2011, Andrew Morton wrote:

> > > > So the question I'd ask is
> > > 
> > > What about my question?  Why is your usersapce oom-handler "unresponsive"?
> > > 
> > 
> > If we have a per-memcg userspace oom handler, then it's absolutely 
> > required that it either increase the hard limit of the oom memcg or kill a 
> > task to free memory; anything else risks livelocking that memcg.  At 
> > the same time, the oom handler's memcg isn't really important: it may be 
> > in a different memcg but it may be oom at the same time.  If we risk 
> > livelocking the memcg when it is oom and the oom killer cannot respond 
> > (the only reason for the oom killer to exist in the first place), then 
> > there's no guarantee that a userspace oom handler could respond under 
> > livelock.
> 
> So you're saying that your userspace oom-handler is in a memcg which is
> also oom?

It could be, if users assign the handler to a different memcg; otherwise, 
it's guaranteed.  Keep in mind that for oom situations we give the killed 
task access to memory reserves below the min watermark with TIF_MEMDIE so 
that they can allocate memory to exit as quickly as possible (either to 
handle the SIGKILL or within the exit path).  That's because we can't 
guarantee anything within an oom system, cpuset, mempolicy, or memcg is 
ever responsive without it.  (And, the side effect of it and its threads 
exiting is the freeing of memory which allows everything else to once 
again be responsive.)

> That this is the only situation you've observed in which the
> userspace oom-handler is "unresponsive"?
> 

Personally, yes, but I could imagine other users could get caught if their 
userspace oom handler requires taking locks (such as mmap_sem) by reading 
within procfs that a thread within an oom memcg already holds.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
