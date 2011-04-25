Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9F1CD8D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 15:16:15 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3PIli6x010461
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 14:47:44 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3PJGBkQ1167560
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 15:16:11 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3PJG9RZ017193
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 15:16:10 -0400
Date: Mon, 25 Apr 2011 12:16:07 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
Message-ID: <20110425191607.GL2468@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20110424235928.71af51e0@neptune.home>
 <20110425114429.266A.A69D9226@jp.fujitsu.com>
 <BANLkTinVQtLbmBknBZeY=7w7AOyQk61Pew@mail.gmail.com>
 <20110425111705.786ef0c5@neptune.home>
 <BANLkTi=d0UHrYXyTK0CBZYCSK-ax8+wuWQ@mail.gmail.com>
 <20110425180450.1ede0845@neptune.home>
 <BANLkTikSLA59tdgRL4B=cr5tvP2NbzZ=KA@mail.gmail.com>
 <20110425190032.7904c95d@neptune.home>
 <BANLkTi=hQ=HcPLCdbb1pSi+xJByMTah-gw@mail.gmail.com>
 <20110425203606.4e78246c@neptune.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20110425203606.4e78246c@neptune.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bruno =?iso-8859-1?Q?Pr=E9mont?= <bonbons@linux-vserver.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Mon, Apr 25, 2011 at 08:36:06PM +0200, Bruno Premont wrote:
> On Mon, 25 April 2011 Linus Torvalds wrote:
> > On Mon, Apr 25, 2011 at 10:00 AM, Bruno Premont wrote:
> > >
> > > I hope tiny-rcu is not that broken... as it would mean driving any
> > > PREEMPT_NONE or PREEMPT_VOLUNTARY system out of memory when compiling
> > > packages (and probably also just unpacking larger tarballs or running
> > > things like du).
> > 
> > I'm sure that TINYRCU can be fixed if it really is the problem.
> > 
> > So I just want to make sure that we know what the root cause of your
> > problem is. It's quite possible that it _is_ a real leak of filp or
> > something, but before possibly wasting time trying to figure that out,
> > let's see if your config is to blame.
> 
> With changed config (PREEMPT=y, TREE_PREEMPT_RCU=y) I haven't reproduced
> yet.
> 
> When I was reproducing with TINYRCU things went normally for some time
> until suddenly slabs stopped being freed.

Hmmm... If the system is responsive during this time, could you please
do the following after the slabs stop being freed?

ps -eo pid,class,sched,rtprio,stat,state,sgi_p,cpu_time,cmd | grep '\[rcu'

							Thanx, Paul

> > > And with system doing nothing (except monitoring itself) memory usage
> > > goes increasing all the time until it starves (well it seems to keep
> > > ~20M free, pushing processes it can to swap). Config is just being
> > > make oldconfig from working 2.6.38 kernel (answering default for new
> > > options)
> > 
> > How sure are you that the system really is idle? Quite frankly, the
> > constant growing doesn't really look idle to me.
> 
> Except the SIGSTOPed build there is not much left, collectd running in
> background (it polls /proc for process counts, fork rate, memory usage,
> ... opening, reading, closing the files -- scanning every 10 seconds),
> slabtop on one terminal.
> 
> CPU activity was near-zero with 10%-20% spikes of system use every 10
> minutes and io-wait when all cache had been pushed out.
> 
> > > Attached graph matching numbers of previous mail. (dropping caches was at
> > > 17:55, system idle since then)
> > 
> > Nothing at all going on in 'ps' during that time? And what does
> > slabinfo say at that point now that kmemleak isn't dominating
> > everything else?
> 
> ps definitely does not show anything special, 30 or so userspace processes.
> Didn't check ls /proc/*/fd though. Will do at next occurrence.
> 
> 
> Going to test further with various PREEMPT and RCU selections. Will report
> back as I progress (but won't have much time tomorrow).
> 
> Bruno

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
