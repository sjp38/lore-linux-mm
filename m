Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 540B56B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 01:20:06 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2V5KIK6030336
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 31 Mar 2009 14:20:19 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DC0245DE5A
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 14:20:18 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id F388B45DE51
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 14:20:17 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D6F0C1DB8060
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 14:20:17 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CF851DB803C
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 14:20:17 +0900 (JST)
Date: Tue, 31 Mar 2009 14:18:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg soft limit (yet another new design) v1
Message-Id: <20090331141850.88473e2a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090331140502.813993cc.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
	<20090328181100.GB26686@balbir.in.ibm.com>
	<20090328182747.GA8339@balbir.in.ibm.com>
	<20090331085538.2aaa5e2b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090331050055.GF16497@balbir.in.ibm.com>
	<20090331140502.813993cc.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 31 Mar 2009 14:05:02 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

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
> Nothing special boot options. My test was on VMware 2cpus/1.6GB memory.
> 
More precise.

the host equips 1576444kB of memory not 1700MB.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
