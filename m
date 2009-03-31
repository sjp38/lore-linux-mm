Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6B0BE6B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 02:10:52 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2V6AmCe008648
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 11:40:48 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2V66rPG3309600
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 11:36:53 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2V6AVE1030018
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 17:10:32 +1100
Date: Tue, 31 Mar 2009 11:40:10 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH] memcg soft limit (yet another new design) v1
Message-ID: <20090331061010.GJ16497@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com> <20090328181100.GB26686@balbir.in.ibm.com> <20090328182747.GA8339@balbir.in.ibm.com> <20090331085538.2aaa5e2b.kamezawa.hiroyu@jp.fujitsu.com> <20090331050055.GF16497@balbir.in.ibm.com> <20090331140502.813993cc.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090331140502.813993cc.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-31 14:05:02]:

> On Tue, 31 Mar 2009 10:30:55 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-31 08:55:38]:
> > 
> > > On Sat, 28 Mar 2009 23:57:47 +0530
> > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > 
> > > > * Balbir Singh <balbir@linux.vnet.ibm.com> [2009-03-28 23:41:00]:
> > > > 
> > > > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-27 13:59:33]:
> > > > > 
> > > > > > ==brief test result==
> > > > > > On 2CPU/1.6GB bytes machine. create group A and B
> > > > > >   A.  soft limit=300M
> > > > > >   B.  no soft limit
> > > > > > 
> > > > > >   Run a malloc() program on B and allcoate 1G of memory. The program just
> > > > > >   sleeps after allocating memory and no memory refernce after it.
> > > > > >   Run make -j 6 and compile the kernel.
> > > > > > 
> > > > > >   When vm.swappiness = 60  => 60MB of memory are swapped out from B.
> > > > > >   When vm.swappiness = 10  => 1MB of memory are swapped out from B    
> > > > > > 
> > > > > >   If no soft limit, 350MB of swap out will happen from B.(swapiness=60)
> > > > > >
> > > > > 
> > > > > I ran the same tests, booted the machine with mem=1700M and maxcpus=2
> > > > > 
> > > > > Here is what I see with
> > > > 
> > > > I meant to say, Here is what I see with my patches (v7)
> > > > 
> > > Hmm, I saw 250MB of swap out ;) As I reported before.
> > 
> > Swapout for A? For A it is expected, but for B it is not. How many
> > nodes do you have on your machine? Any fake numa nodes?
> > 
> Of course, from B.
>

I asked because I see A have a swapout of 350 MB, which is expected
since it is way over its soft limit.
 
> Nothing special boot options. My test was on VMware 2cpus/1.6GB memory.
> 
> I wonder why swapout can be 0 on your test. Do you add some extra hooks to
> kswapd ?
>

Nope.. no special hooks to kswapd. B never enters the RB-Tree and thus
never hits the memcg soft limit reclaim path. kswapd can reclaim from
it, but it grows back quickly. At some point, memcg soft limit reclaim
hits A and reclaims memory from it, allowing B to run without any
problems. I am talking about the state at the end of the experiment.

 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
