Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2BB9A6B0047
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 02:07:45 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp09.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2V5cp09014219
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 11:08:51 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2V647EA1036456
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 11:34:07 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2V67kC0031560
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 17:07:46 +1100
Date: Tue, 31 Mar 2009 11:37:25 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH] memcg soft limit (yet another new design) v1
Message-ID: <20090331060725.GI16497@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com> <20090328181100.GB26686@balbir.in.ibm.com> <20090328182747.GA8339@balbir.in.ibm.com> <20090331090607.7ebc44c5.kamezawa.hiroyu@jp.fujitsu.com> <20090331050143.GG16497@balbir.in.ibm.com> <20090331141140.9acd9b85.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090331141140.9acd9b85.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-31 14:11:40]:

> On Tue, 31 Mar 2009 10:31:43 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-31 09:06:07]:
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
> > > 
> > > your malloc program is like this ?
> > > 
> > > int main(int argc, char *argv[])
> > > {
> > >     c = malloc(1G);
> > >     memset(c, 0, 1G);
> > >     getc();
> > > }
> > >
> > 
> > Very similar, instead of memset, we go integer by integer and set it
> > to 0, do two loops of touching and wait for user input before exiting.
> >  
> Why two loops of touching ? has special meanings ?

The number of loops are configurable and can be used to keep pages
active. The default loops is two. It has no special meaning in the
test scenario described.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
