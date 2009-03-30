Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8677F6B003D
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 19:55:29 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2UNuJAu005113
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 31 Mar 2009 08:56:19 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B61F45DE51
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 08:56:19 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 497B645DE4F
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 08:56:19 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 574D2E18002
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 08:56:19 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 135F31DB8038
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 08:56:19 +0900 (JST)
Date: Tue, 31 Mar 2009 08:54:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg soft limit (yet another new design) v1
Message-Id: <20090331085451.ce6a5147.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090328181100.GB26686@balbir.in.ibm.com>
References: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
	<20090328181100.GB26686@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sat, 28 Mar 2009 23:41:00 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-27 13:59:33]:
> 
> > ==brief test result==
> > On 2CPU/1.6GB bytes machine. create group A and B
> >   A.  soft limit=300M
> >   B.  no soft limit
> > 
> >   Run a malloc() program on B and allcoate 1G of memory. The program just
> >   sleeps after allocating memory and no memory refernce after it.
> >   Run make -j 6 and compile the kernel.
> > 
> >   When vm.swappiness = 60  => 60MB of memory are swapped out from B.
> >   When vm.swappiness = 10  => 1MB of memory are swapped out from B    
> > 
> >   If no soft limit, 350MB of swap out will happen from B.(swapiness=60)
> >
> 
> I ran the same tests, booted the machine with mem=1700M and maxcpus=2
> 
with your patch ?

> Here is what I see with
> 
> A has a swapout of 344M and B has not swapout at all, since B is
> always under its soft limit. vm.swappiness is set to 60
> 
> I think the above is more along the lines of the expected functional behaviour. 
> 

yes. but it's depend on workload (and fortune?) of A in this implementation.
Follwing is what I think now. We need some changes to vmscanc, later.

explain)
    This patch rotate memcg's page to the top of LRU. But, LRU is divided into
    INACTIVE/ACTIVE. So, sometimes, memcg's INACTIVE LRU can be empty and
    pages from other group can be reclaimed.
    In my test, group A's RSS usage can be 1-2M sometimes.

Thanks,
-Kame
    






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
