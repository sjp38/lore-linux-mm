Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 60BE16B006A
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 04:50:25 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0K9oMrg010938
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 20 Jan 2010 18:50:23 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CFC645DE52
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 18:50:22 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 75CB245DE55
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 18:50:22 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F20D1DB8038
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 18:50:22 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 572CE1DB803F
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 18:50:21 +0900 (JST)
Date: Wed, 20 Jan 2010 18:47:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH mmotm] memcg use generic percpu allocator instead of
 private one
Message-Id: <20100120184707.ed99b540.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4B56CEF0.2040406@linux.vnet.ibm.com>
References: <20100120161825.15c372ac.kamezawa.hiroyu@jp.fujitsu.com>
	<4B56CEF0.2040406@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, kirill@shutemov.name
List-ID: <linux-mm.kvack.org>

On Wed, 20 Jan 2010 15:07:52 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> On Wednesday 20 January 2010 12:48 PM, KAMEZAWA Hiroyuki wrote:
> > This patch is onto mmotm Jan/15.
> > =
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > When per-cpu counter for memcg was implemneted, dynamic percpu allocator
> > was not very good. But now, we have good one and useful macros.
> > This patch replaces memcg's private percpu counter implementation with
> > generic dynamic percpu allocator and macros.
> > 
> > The benefits are
> > 	- We can remove private implementation.
> > 	- The counters will be NUMA-aware. (Current one is not...)
> > 	- This patch reduces sizeof(struct mem_cgroup). Then,
> > 	  struct mem_cgroup may be fit in page size on small config.
> > 
> > By this, size of text is reduced.
> >  [Before]
> >  [kamezawa@bluextal mmotm-2.6.33-Jan15]$ size mm/memcontrol.o
> >    text    data     bss     dec     hex filename
> >   24373    2528    4132   31033    7939 mm/memcontrol.o
> >  [After]
> >  [kamezawa@bluextal mmotm-2.6.33-Jan15]$ size mm/memcontrol.o
> >    text    data     bss     dec     hex filename
> >   23913    2528    4132   30573    776d mm/memcontrol.o
> > 
> > This includes no functional changes.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> 
> Before review, could you please post parallel pagefault data on a large
> system, since root now uses these per cpu counters and its overhead is
> now dependent on these counters. Also the data read from root cgroup is
> also dependent on these, could you make sure that is not broken.
> 
No number difference before/after patch on my SMP quick test.
But I don't have NUMA. Could you test on NUMA ?

I'll measure again tomorrow if I have machine time.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
