Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id 93FC66B0035
	for <linux-mm@kvack.org>; Wed,  5 Mar 2014 20:42:25 -0500 (EST)
Received: by mail-qa0-f45.google.com with SMTP id hw13so1838529qab.4
        for <linux-mm@kvack.org>; Wed, 05 Mar 2014 17:42:25 -0800 (PST)
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com. [32.97.110.151])
        by mx.google.com with ESMTPS id e61si1814481qgf.76.2014.03.05.17.42.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 05 Mar 2014 17:42:24 -0800 (PST)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 5 Mar 2014 18:42:23 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 38EA3C40001
	for <linux-mm@kvack.org>; Wed,  5 Mar 2014 18:42:22 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s261fj4D2884018
	for <linux-mm@kvack.org>; Thu, 6 Mar 2014 02:41:46 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s261jqOT010340
	for <linux-mm@kvack.org>; Wed, 5 Mar 2014 18:45:52 -0700
Date: Wed, 5 Mar 2014 17:42:20 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: RCU stalls when running out of memory on 3.14-rc4 w/ NFS and
 kernel threads priorities changed
Message-ID: <20140306014220.GB3334@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <CAGVrzcbsSV7h3qA3KuCTwKNFEeww_kSNcfUkfw3PPjeXQXBo6g@mail.gmail.com>
 <1393980534.26794.147.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAGVrzcaekM51hme_tquaT6e22fV1_cocpn1kDUsYfFce=F+o4g@mail.gmail.com>
 <CAGVrzcbRycBy0w64R9pV=JG6M3aJeARbOnh-xRrumYzzVDgWGQ@mail.gmail.com>
 <20140305014310.GC3334@linux.vnet.ibm.com>
 <CAGVrzcae0XPXpue_+n-O+EBzK92JqXHNftTPGt+5SRzroTSF3Q@mail.gmail.com>
 <20140305053440.GD3334@linux.vnet.ibm.com>
 <CAGVrzcYBtR14-XkPjDiC+JnQ422d8T8j+3Qg6b5OUQLC7eRgXg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGVrzcYBtR14-XkPjDiC+JnQ422d8T8j+3Qg6b5OUQLC7eRgXg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-nfs <linux-nfs@vger.kernel.org>, "trond.myklebust" <trond.myklebust@primarydata.com>, netdev <netdev@vger.kernel.org>

On Wed, Mar 05, 2014 at 04:42:55PM -0800, Florian Fainelli wrote:
> 2014-03-04 21:34 GMT-08:00 Paul E. McKenney <paulmck@linux.vnet.ibm.com>:
> > On Tue, Mar 04, 2014 at 07:55:03PM -0800, Florian Fainelli wrote:
> >> 2014-03-04 17:43 GMT-08:00 Paul E. McKenney <paulmck@linux.vnet.ibm.com>:
> >> > On Tue, Mar 04, 2014 at 05:16:27PM -0800, Florian Fainelli wrote:
> >> >> 2014-03-04 17:03 GMT-08:00 Florian Fainelli <f.fainelli@gmail.com>:
> >> >> > 2014-03-04 16:48 GMT-08:00 Eric Dumazet <eric.dumazet@gmail.com>:
> >> >> >> On Tue, 2014-03-04 at 15:55 -0800, Florian Fainelli wrote:
> >> >> >>> Hi all,
> >> >> >>>
> >> >> >>> I am seeing the following RCU stalls messages appearing on an ARMv7
> >> >> >>> 4xCPUs system running 3.14-rc4:
> >> >> >>>
> >> >> >>> [   42.974327] INFO: rcu_sched detected stalls on CPUs/tasks:
> >> >> >>> [   42.979839]  (detected by 0, t=2102 jiffies, g=4294967082,
> >> >> >>> c=4294967081, q=516)
> >> >> >>> [   42.987169] INFO: Stall ended before state dump start
> >> >> >>>
> >> >> >>> this is happening under the following conditions:
> >> >> >>>
> >> >> >>> - the attached bumper.c binary alters various kernel thread priorities
> >> >> >>> based on the contents of bumpup.cfg and
> >> >> >>> - malloc_crazy is running from a NFS share
> >> >> >>> - malloc_crazy.c is running in a loop allocating chunks of memory but
> >> >> >>> never freeing it
> >> >> >>>
> >> >> >>> when the priorities are altered, instead of getting the OOM killer to
> >> >> >>> be invoked, the RCU stalls are happening. Taking NFS out of the
> >> >> >>> equation does not allow me to reproduce the problem even with the
> >> >> >>> priorities altered.
> >> >> >>>
> >> >> >>> This "problem" seems to have been there for quite a while now since I
> >> >> >>> was able to get 3.8.13 to trigger that bug as well, with a slightly
> >> >> >>> more detailed RCU debugging trace which points the finger at kswapd0.
> >> >> >>>
> >> >> >>> You should be able to get that reproduced under QEMU with the
> >> >> >>> Versatile Express platform emulating a Cortex A15 CPU and the attached
> >> >> >>> files.
> >> >> >>>
> >> >> >>> Any help or suggestions would be greatly appreciated. Thanks!
> >> >> >>
> >> >> >> Do you have a more complete trace, including stack traces ?
> >> >> >
> >> >> > Attatched is what I get out of SysRq-t, which is the only thing I have
> >> >> > (note that the kernel is built with CONFIG_RCU_CPU_STALL_INFO=y):
> >> >>
> >> >> QEMU for Versatile Express w/ 2 CPUs yields something slightly
> >> >> different than the real HW platform this is happening with, but it
> >> >> does produce the RCU stall anyway:
> >> >>
> >> >> [  125.762946] BUG: soft lockup - CPU#1 stuck for 53s! [malloc_crazy:91]
> >> >
> >> > This soft-lockup condition can result in RCU CPU stall warnings.  Fix
> >> > the problem causing the soft lockup, and I bet that your RCU CPU stall
> >> > warnings go away.
> >>
> >> I definitively agree, which is why I was asking for help, as I think
> >> the kernel thread priority change is what is causing the soft lockup
> >> to appear, but nothing obvious jumps to mind when looking at the
> >> trace.
> >
> > Is your hardware able to make the malloc_crazy CPU periodically dump
> > its stack, perhaps in response to an NMI?  If not, another approach is
> > to use ftrace -- though this will require a very high-priority task to
> > turn tracing on and off reasonably quickly, unless you happen to have
> > a very large amount of storage to hold the trace.
> >
> > What happens if you malloc() less intensively?  Does that avoid this
> > problem?
> 
> It does yes, putting some arbitrary delays between the malloc() calls
> does definitively help.

OK, good.  This might be helping because it if freeing up enough CPU
time that all the critical kthreads actually get to run (for but one
example, the OOM killer, of course assuming that you are delaying via
sleeping rather than via spinning), or it might be helping by placing
less pressure on the VM system.  Or by keeping the VM system out of a
CPU-bound mode, for that matter.

So one useful diagnostic approach would be to look at the CPU consumption
and the VM statistics as a function of the amount of delay between
malloc() calls.

> >The reason I ask is that you mentioned that avoiding NFS helped,
> > and it is possible that NFS is increasing storage-access latencies and
> > thus triggering another problem.  It is quite possible that slowing
> > down the malloc()s would also help, and might allow you to observe what
> > is happening more easily than when the system is driven fully to the
> > lockup condition.
> >
> > Finally, what are you trying to achieve with this workload?  Does your
> > production workload behave in this way?  Or is this an experimental
> > investigation of some sort?
> 
> This is an experimental investigation, part of the problem being that
> there were some expectations that altering priority of essential
> kernel threads would "just work".

It might "just work" -- but only if you used extreme care in choosing
the altered set of priorities, especially when running a CPU-bound
workload!  ;-)

> It seemed to me like even if we moved kthreadd to SCHED_RR, with
> priority 2 (as shown by /proc/*/sched), we should still be at a more
> favorable scheduling class than 'rcu_bh' and 'rcu_sched' which are on
> SCHED_NORMAL. Interestingly, the issue only appears with 1 or 2 CPUs
> online, as soon as the 4 are online I am no longer able to reproduce
> it...

Interesting!  That hints that the problem is that your system is unable
to supply the needed CPU time for some critical kthread.

On a 2-CPU system, one approach would be to put all the normal-priority
non-per-CPU kthreads onto CPU 1 and the rest onto CPU 0.  Don't try
moving the per-CPU kthreads!  (One exception to this rule being the
rcuo* no-CB CPU kthreads.)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
