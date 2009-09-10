Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 251ED6B004D
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 01:18:10 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp04.au.ibm.com (8.14.3/8.13.1) with ESMTP id n8A5FNDJ024270
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 15:15:23 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8A5IBCl1458354
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 15:18:12 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n8A5IBjA011365
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 15:18:11 +1000
Date: Thu, 10 Sep 2009 10:48:07 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 0/4][mmotm] memcg: reduce lock contention v3
Message-ID: <20090910051807.GB4473@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090909173903.afc86d85.kamezawa.hiroyu@jp.fujitsu.com>
 <20090909203042.GA4473@balbir.in.ibm.com>
 <20090910092017.3d550d5a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090910092017.3d550d5a.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-09-10 09:20:17]:

> On Thu, 10 Sep 2009 02:00:42 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-09-09 17:39:03]:
> > 
> > > This patch series is for reducing memcg's lock contention on res_counter, v3.
> > > (sending today just for reporting current status in my stack.)
> > > 
> > > It's reported that memcg's res_counter can cause heavy false sharing / lock
> > > conention and scalability is not good. This is for relaxing that.
> > > No terrible bugs are found, I'll maintain/update this until the end of next
> > > merge window. Tests on big-smp and new-good-idea are welcome.
> > > 
> > > This patch is on to mmotm+Nishimura's fix + Hugh's get_user_pages() patch.
> > > But can be applied directly against mmotm, I think.
> > > 
> > > numbers:
> > > 
> > > I used 8cpu x86-64 box and run make -j 12 kernel.
> > > Before make, make clean and drop_caches.
> > >
> > 
> > Kamezawa-San
> > 
> > I was able to test on a 24 way using my parallel page fault test
> > program and here is what I see
> > 
> thank you.
> 
> >  Performance counter stats for '/home/balbir/parallel_pagefault' (3
> > runs):
> > 
> >  7191673.834385  task-clock-msecs         #     23.953 CPUs    ( +- 0.001% )
> >          427765  context-switches         #      0.000 M/sec   ( +- 0.106% )
> >             234  CPU-migrations           #      0.000 M/sec   ( +- 20.851% )
> >        87975343  page-faults              #      0.012 M/sec   ( +- 0.347% )
> >   5962193345280  cycles                   #    829.041 M/sec   ( +- 0.012% )
> >   1009132401195  instructions             #      0.169 IPC     ( +- 0.059% )
> >     10068652670  cache-references         #      1.400 M/sec   ( +- 2.581% )
> >      2053688394  cache-misses             #      0.286 M/sec   ( +- 0.481% )
> > 
> >   300.238748326  seconds time elapsed   ( +-   0.001% )
> > 
> > Without the patch I saw
> > 
> >  Performance counter stats for '/home/balbir/parallel_pagefault' (3
> > runs):
> > 
> >  7198364.596593  task-clock-msecs         #     23.959 CPUs    ( +- 0.004% )
> >          425104  context-switches         #      0.000 M/sec   ( +- 0.244% )
> >             157  CPU-migrations           #      0.000 M/sec   ( +- 13.291% )
> >        28964117  page-faults              #      0.004 M/sec   ( +- 0.106% )
> >   5786854402292  cycles                   #    803.912 M/sec   ( +- 0.013% )
> >    835828892399  instructions             #      0.144 IPC     ( +- 0.073% )
> >      6240606753  cache-references         #      0.867 M/sec   ( +- 1.058% )
> >      2068445332  cache-misses             #      0.287 M/sec   ( +- 1.844% )
> > 
> >   300.443366784  seconds time elapsed   ( +-   0.005% )
> > 
> > 
> > This does look like a very good improvement.
> > 
> Seems good.
> BTW, why the number of page-faults after patch is 3 times bigger than
> one before patch ? The difference in the number of instructions  meets it ?
>

This is a page fault program, whose sole goal is to keep page faulting
parallely. In the case before patch, we find that resource counter
gets in the way, in the second, resource counters allow more page
faults in the same time. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
