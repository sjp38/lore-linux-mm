Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E54BE6B0047
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 02:48:43 -0400 (EDT)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2V6lQjh029233
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 17:47:26 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2V6nPMu1134662
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 17:49:25 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2V6nPZm024056
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 17:49:25 +1100
Date: Tue, 31 Mar 2009 12:19:02 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH] memcg soft limit (yet another new design) v1
Message-ID: <20090331064901.GK16497@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com> <20090328181100.GB26686@balbir.in.ibm.com> <20090328182747.GA8339@balbir.in.ibm.com> <20090331085538.2aaa5e2b.kamezawa.hiroyu@jp.fujitsu.com> <20090331050055.GF16497@balbir.in.ibm.com> <20090331140502.813993cc.kamezawa.hiroyu@jp.fujitsu.com> <20090331061010.GJ16497@balbir.in.ibm.com> <20090331152843.e1db942b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090331152843.e1db942b.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-31 15:28:43]:

> On Tue, 31 Mar 2009 11:40:10 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > > > Swapout for A? For A it is expected, but for B it is not. How many
> > > > nodes do you have on your machine? Any fake numa nodes?
> > > > 
> > > Of course, from B.
> > >
> > 
> > I asked because I see A have a swapout of 350 MB, which is expected
> > since it is way over its soft limit.
> >  
> gcc doesn't use so much RSS..ld ?

Yes, the ld step consumes a lot of memory, depending on file size and
number of parallel tasks, memory consumption does go up.

> 
> > > Nothing special boot options. My test was on VMware 2cpus/1.6GB memory.
> > > 
> > > I wonder why swapout can be 0 on your test. Do you add some extra hooks to
> > > kswapd ?
> > >
> > 
> > Nope.. no special hooks to kswapd. B never enters the RB-Tree and thus
> > never hits the memcg soft limit reclaim path. kswapd can reclaim from
> > it, but it grows back quickly.
> Why grows back ? tasks in B sleeps ?

Since B continuously consumes memory

> 
> >  At some point, memcg soft limit reclaim
> > hits A and reclaims memory from it, allowing B to run without any
> > problems. I am talking about the state at the end of the experiment.
> > 
> Considering LRU rotation (ACTIVE->INACTIVE), pages in group B never goes back
> to ACTIVE list and can be the first candidates for swap-out via kswapd.
> 
> Hmm....kswapd doesn't work at all ?
> 
> (or 1700MB was too much.)
>

No 1700MB is not too much, since we reclaim from A towards the end
when ld runs. I need to investigate more and look at the watermarks,
may be soft limit reclaim reclaims enough and/or the watermarks are
not very high. I use fake NUMA nodes as well.
 
> Thanks,
> -Kame
> 
> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
