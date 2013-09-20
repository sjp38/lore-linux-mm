Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1DF646B0031
	for <linux-mm@kvack.org>; Fri, 20 Sep 2013 12:42:09 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id r10so598111pdi.0
        for <linux-mm@kvack.org>; Fri, 20 Sep 2013 09:42:08 -0700 (PDT)
Received: by mail-ye0-f171.google.com with SMTP id q3so208493yen.16
        for <linux-mm@kvack.org>; Fri, 20 Sep 2013 09:42:06 -0700 (PDT)
Date: Fri, 20 Sep 2013 11:42:03 -0500
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: RFC vmstat: On demand vmstat threads
Message-ID: <20130920164201.GB30381@localhost.localdomain>
References: <00000140e9dfd6bd-40db3d4f-c1be-434f-8132-7820f81bb586-000000@email.amazonses.com>
 <CAOtvUMdfqyg80_9J8AnOaAdahuRYGC-bpemdo_oucDBPguXbVA@mail.gmail.com>
 <0000014109b8e5db-4b0f577e-c3b4-47fe-b7f2-0e5febbcc948-000000@email.amazonses.com>
 <20130918150659.5091a2c3ca94b99304427ec5@linux-foundation.org>
 <alpine.DEB.2.02.1309190033440.4089@ionos.tec.linutronix.de>
 <000001413796641f-017482d3-1194-499b-8f2a-d7686c1ae61f-000000@email.amazonses.com>
 <alpine.DEB.2.02.1309201238560.4089@ionos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1309201238560.4089@ionos.tec.linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>

On Fri, Sep 20, 2013 at 12:41:02PM +0200, Thomas Gleixner wrote:
> On Thu, 19 Sep 2013, Christoph Lameter wrote:
> > On Thu, 19 Sep 2013, Thomas Gleixner wrote:
> > 
> > > The vmstat accounting is not the only thing which we want to delegate
> > > to dedicated core(s) for the full NOHZ mode.
> > >
> > > So instead of playing broken games with explicitly not exposed core
> > > code variables, we should implement a core code facility which is
> > > aware of the NOHZ details and provides a sane way to delegate stuff to
> > > a certain subset of CPUs.
> > 
> > I would be happy to use such a facility. Otherwise I would just be adding
> > yet another kernel option or boot parameter I guess.
> 
> Uuurgh, no.
> 
> The whole delegation stuff is necessary not just for vmstat. We have
> the same issue for scheduler stats and other parts of the kernel, so
> we are better off in having a core facility to schedule such functions
> in consistency with the current full NOHZ state.

Agreed.

So we have the choice between having this performed from callers in the
kernel with functions that enforce the affinity of some asynchronous tasks,
like "schedule_on_timekeeper()" or "schedule_on_housekeeers()" with workqueues for example.

Or we can add interface to define the affinity of such things from userspace, at the
risk of exposing some kernel details like workqueues or timers internal callback names.

Oh and may be this must stay flexible enough to handle dispatched housekeeping in the future.
Like on big NUMA machines that want to dispatch some part of the housekeeping on each
NUMA nodes for close running CPU. Although I don't have any detail in mind for that.

I've also been thinking of some flag for defferable timers to be also user defferable.
But I expect too much overhead to maintain that on kernel/user boundaries. And eventually
the issues we have go beyond just user/kernel ring conditions.

Just random thoughts.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
