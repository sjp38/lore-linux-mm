Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f46.google.com (mail-oa0-f46.google.com [209.85.219.46])
	by kanga.kvack.org (Postfix) with ESMTP id ED20A6B0081
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 20:41:26 -0500 (EST)
Received: by mail-oa0-f46.google.com with SMTP id i7so388959oag.5
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 17:41:26 -0800 (PST)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id e6si711685oen.36.2014.03.04.17.41.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Mar 2014 17:41:25 -0800 (PST)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 4 Mar 2014 18:41:25 -0700
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 0B97F3E40040
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 18:41:24 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08026.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s251euEZ917872
	for <linux-mm@kvack.org>; Wed, 5 Mar 2014 02:40:56 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s251irnv021883
	for <linux-mm@kvack.org>; Tue, 4 Mar 2014 18:44:54 -0700
Date: Tue, 4 Mar 2014 17:41:22 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: RCU stalls when running out of memory on 3.14-rc4 w/ NFS and
 kernel threads priorities changed
Message-ID: <20140305014122.GB3334@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <CAGVrzcbsSV7h3qA3KuCTwKNFEeww_kSNcfUkfw3PPjeXQXBo6g@mail.gmail.com>
 <1393980534.26794.147.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAGVrzcaekM51hme_tquaT6e22fV1_cocpn1kDUsYfFce=F+o4g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGVrzcaekM51hme_tquaT6e22fV1_cocpn1kDUsYfFce=F+o4g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-nfs <linux-nfs@vger.kernel.org>, "trond.myklebust" <trond.myklebust@primarydata.com>, netdev <netdev@vger.kernel.org>

On Tue, Mar 04, 2014 at 05:03:24PM -0800, Florian Fainelli wrote:
> 2014-03-04 16:48 GMT-08:00 Eric Dumazet <eric.dumazet@gmail.com>:
> > On Tue, 2014-03-04 at 15:55 -0800, Florian Fainelli wrote:
> >> Hi all,
> >>
> >> I am seeing the following RCU stalls messages appearing on an ARMv7
> >> 4xCPUs system running 3.14-rc4:
> >>
> >> [   42.974327] INFO: rcu_sched detected stalls on CPUs/tasks:
> >> [   42.979839]  (detected by 0, t=2102 jiffies, g=4294967082,
> >> c=4294967081, q=516)
> >> [   42.987169] INFO: Stall ended before state dump start
> >>
> >> this is happening under the following conditions:
> >>
> >> - the attached bumper.c binary alters various kernel thread priorities
> >> based on the contents of bumpup.cfg and
> >> - malloc_crazy is running from a NFS share
> >> - malloc_crazy.c is running in a loop allocating chunks of memory but
> >> never freeing it
> >>
> >> when the priorities are altered, instead of getting the OOM killer to
> >> be invoked, the RCU stalls are happening. Taking NFS out of the
> >> equation does not allow me to reproduce the problem even with the
> >> priorities altered.
> >>
> >> This "problem" seems to have been there for quite a while now since I
> >> was able to get 3.8.13 to trigger that bug as well, with a slightly
> >> more detailed RCU debugging trace which points the finger at kswapd0.

The 3.8 kernel was where RCU grace-period processing moved to kthreads.
Does 3.7 or earlier trigger?

In any case, if you starve RCU's grace-period kthreads (rcu_bh and
rcu_sched in your kernel configuration), then RCU CPU stall-warning
messages are expected behavior.  In 3.7 and earlier, you could get the
same effect by starving ksoftirqd.

> >> You should be able to get that reproduced under QEMU with the
> >> Versatile Express platform emulating a Cortex A15 CPU and the attached
> >> files.
> >>
> >> Any help or suggestions would be greatly appreciated. Thanks!
> >
> > Do you have a more complete trace, including stack traces ?
>
> Attatched is what I get out of SysRq-t, which is the only thing I have
> (note that the kernel is built with CONFIG_RCU_CPU_STALL_INFO=y):
>
> Thanks!
> --
> Florian

> [ 3474.417333] INFO: Stall ended before state dump start

This was running on 3.14-rc4?

							Thanx, Paul

> [ 3500.312946] SysRq : Show State
> [ 3500.316015]   task                PC stack   pid father
> [ 3500.321244] init            S c04bda98     0     1      0 0x00000000
> [ 3500.327640] [<c04bda98>] (__schedule) from [<c0022c2c>] (do_wait+0x220/0x244)
> [ 3500.334786] [<c0022c2c>] (do_wait) from [<c0022ff0>] (SyS_wait4+0x60/0xc4)
> [ 3500.341672] [<c0022ff0>] (SyS_wait4) from [<c000e2a0>] (ret_fast_syscall+0x0/0x30)
> [ 3500.349247] kthreadd        S c04bda98     0     2      0 0x00000000
> [ 3500.355635] [<c04bda98>] (__schedule) from [<c003c084>] (kthreadd+0x168/0x16c)
> [ 3500.362866] [<c003c084>] (kthreadd) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3500.370181] ksoftirqd/0     S c04bda98     0     3      2 0x00000000
> [ 3500.376567] [<c04bda98>] (__schedule) from [<c0041ffc>] (smpboot_thread_fn+0xc4/0x17c)
> [ 3500.384494] [<c0041ffc>] (smpboot_thread_fn) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3500.392072] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3500.399300] kworker/0:0     S c04bda98     0     4      2 0x00000000
> [ 3500.405691] [<c04bda98>] (__schedule) from [<c003626c>] (worker_thread+0x210/0x404)
> [ 3500.413357] [<c003626c>] (worker_thread) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3500.420588] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3500.427817] kworker/0:0H    S c04bda98     0     5      2 0x00000000
> [ 3500.434205] [<c04bda98>] (__schedule) from [<c003626c>] (worker_thread+0x210/0x404)
> [ 3500.441871] [<c003626c>] (worker_thread) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3500.449102] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3500.456329] kworker/u8:0    S c04bda98     0     6      2 0x00000000
> [ 3500.462718] [<c04bda98>] (__schedule) from [<c003626c>] (worker_thread+0x210/0x404)
> [ 3500.470384] [<c003626c>] (worker_thread) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3500.477615] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3500.484843] rcu_sched       R running      0     7      2 0x00000000
> [ 3500.491230] [<c04bda98>] (__schedule) from [<c04bd378>] (schedule_timeout+0x130/0x1ac)
> [ 3500.499157] [<c04bd378>] (schedule_timeout) from [<c006553c>] (rcu_gp_kthread+0x26c/0x5f8)
> [ 3500.507431] [<c006553c>] (rcu_gp_kthread) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3500.514749] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3500.521977] rcu_bh          S c04bda98     0     8      2 0x00000000
> [ 3500.528363] [<c04bda98>] (__schedule) from [<c0065350>] (rcu_gp_kthread+0x80/0x5f8)
> [ 3500.536028] [<c0065350>] (rcu_gp_kthread) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3500.543346] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3500.550573] migration/0     S c04bda98     0     9      2 0x00000000
> [ 3500.556959] [<c04bda98>] (__schedule) from [<c0041ffc>] (smpboot_thread_fn+0xc4/0x17c)
> [ 3500.564885] [<c0041ffc>] (smpboot_thread_fn) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3500.572465] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3500.579692] watchdog/0      S c04bda98     0    10      2 0x00000000
> [ 3500.586076] [<c04bda98>] (__schedule) from [<c0041ffc>] (smpboot_thread_fn+0xc4/0x17c)
> [ 3500.594001] [<c0041ffc>] (smpboot_thread_fn) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3500.601581] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3500.608808] watchdog/1      P c04bda98     0    11      2 0x00000000
> [ 3500.615195] [<c04bda98>] (__schedule) from [<c003b5d8>] (__kthread_parkme+0x38/0x8c)
> [ 3500.622948] [<c003b5d8>] (__kthread_parkme) from [<c003b874>] (kthread+0xcc/0xec)
> [ 3500.630439] [<c003b874>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3500.637667] migration/1     P c04bda98     0    12      2 0x00000000
> [ 3500.644055] [<c04bda98>] (__schedule) from [<c003b5d8>] (__kthread_parkme+0x38/0x8c)
> [ 3500.651807] [<c003b5d8>] (__kthread_parkme) from [<c003b874>] (kthread+0xcc/0xec)
> [ 3500.659299] [<c003b874>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3500.666527] ksoftirqd/1     P c04bda98     0    13      2 0x00000000
> [ 3500.672912] [<c04bda98>] (__schedule) from [<c003b5d8>] (__kthread_parkme+0x38/0x8c)
> [ 3500.680665] [<c003b5d8>] (__kthread_parkme) from [<c003b874>] (kthread+0xcc/0xec)
> [ 3500.688156] [<c003b874>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3500.695384] kworker/1:0     S c04bda98     0    14      2 0x00000000
> [ 3500.701772] [<c04bda98>] (__schedule) from [<c003626c>] (worker_thread+0x210/0x404)
> [ 3500.709438] [<c003626c>] (worker_thread) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3500.716669] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3500.723896] kworker/1:0H    S c04bda98     0    15      2 0x00000000
> [ 3500.730284] [<c04bda98>] (__schedule) from [<c003626c>] (worker_thread+0x210/0x404)
> [ 3500.737950] [<c003626c>] (worker_thread) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3500.745181] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3500.752408] watchdog/2      P c04bda98     0    16      2 0x00000000
> [ 3500.758794] [<c04bda98>] (__schedule) from [<c003b5d8>] (__kthread_parkme+0x38/0x8c)
> [ 3500.766546] [<c003b5d8>] (__kthread_parkme) from [<c003b874>] (kthread+0xcc/0xec)
> [ 3500.774038] [<c003b874>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3500.781266] migration/2     P c04bda98     0    17      2 0x00000000
> [ 3500.787652] [<c04bda98>] (__schedule) from [<c003b5d8>] (__kthread_parkme+0x38/0x8c)
> [ 3500.795403] [<c003b5d8>] (__kthread_parkme) from [<c003b874>] (kthread+0xcc/0xec)
> [ 3500.802894] [<c003b874>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3500.810121] ksoftirqd/2     P c04bda98     0    18      2 0x00000000
> [ 3500.816508] [<c04bda98>] (__schedule) from [<c003b5d8>] (__kthread_parkme+0x38/0x8c)
> [ 3500.824259] [<c003b5d8>] (__kthread_parkme) from [<c003b874>] (kthread+0xcc/0xec)
> [ 3500.831751] [<c003b874>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3500.838979] kworker/2:0     S c04bda98     0    19      2 0x00000000
> [ 3500.845367] [<c04bda98>] (__schedule) from [<c003626c>] (worker_thread+0x210/0x404)
> [ 3500.853033] [<c003626c>] (worker_thread) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3500.860264] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3500.867491] kworker/2:0H    S c04bda98     0    20      2 0x00000000
> [ 3500.873880] [<c04bda98>] (__schedule) from [<c003626c>] (worker_thread+0x210/0x404)
> [ 3500.881545] [<c003626c>] (worker_thread) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3500.888776] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3500.896003] watchdog/3      P c04bda98     0    21      2 0x00000000
> [ 3500.902389] [<c04bda98>] (__schedule) from [<c003b5d8>] (__kthread_parkme+0x38/0x8c)
> [ 3500.910142] [<c003b5d8>] (__kthread_parkme) from [<c003b874>] (kthread+0xcc/0xec)
> [ 3500.917633] [<c003b874>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3500.924860] migration/3     P c04bda98     0    22      2 0x00000000
> [ 3500.931246] [<c04bda98>] (__schedule) from [<c003b5d8>] (__kthread_parkme+0x38/0x8c)
> [ 3500.938998] [<c003b5d8>] (__kthread_parkme) from [<c003b874>] (kthread+0xcc/0xec)
> [ 3500.946489] [<c003b874>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3500.953716] ksoftirqd/3     P c04bda98     0    23      2 0x00000000
> [ 3500.960102] [<c04bda98>] (__schedule) from [<c003b5d8>] (__kthread_parkme+0x38/0x8c)
> [ 3500.967855] [<c003b5d8>] (__kthread_parkme) from [<c003b874>] (kthread+0xcc/0xec)
> [ 3500.975338] [<c003b874>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3500.982565] kworker/3:0     S c04bda98     0    24      2 0x00000000
> [ 3500.988954] [<c04bda98>] (__schedule) from [<c003626c>] (worker_thread+0x210/0x404)
> [ 3500.996620] [<c003626c>] (worker_thread) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3501.003851] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3501.011079] kworker/3:0H    S c04bda98     0    25      2 0x00000000
> [ 3501.017466] [<c04bda98>] (__schedule) from [<c003626c>] (worker_thread+0x210/0x404)
> [ 3501.025133] [<c003626c>] (worker_thread) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3501.032364] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3501.039591] khelper         S c04bda98     0    26      2 0x00000000
> [ 3501.045979] [<c04bda98>] (__schedule) from [<c003595c>] (rescuer_thread+0x274/0x324)
> [ 3501.053730] [<c003595c>] (rescuer_thread) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3501.061048] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3501.068276] kdevtmpfs       S c04bda98     0    27      2 0x00000000
> [ 3501.074665] [<c04bda98>] (__schedule) from [<c028ba34>] (devtmpfsd+0x258/0x34c)
> [ 3501.081984] [<c028ba34>] (devtmpfsd) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3501.088867] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3501.096095] writeback       S c04bda98     0    28      2 0x00000000
> [ 3501.102484] [<c04bda98>] (__schedule) from [<c003595c>] (rescuer_thread+0x274/0x324)
> [ 3501.110237] [<c003595c>] (rescuer_thread) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3501.117555] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3501.124783] bioset          S c04bda98     0    29      2 0x00000000
> [ 3501.131170] [<c04bda98>] (__schedule) from [<c003595c>] (rescuer_thread+0x274/0x324)
> [ 3501.138923] [<c003595c>] (rescuer_thread) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3501.146240] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3501.153469] kblockd         S c04bda98     0    30      2 0x00000000
> [ 3501.159857] [<c04bda98>] (__schedule) from [<c003595c>] (rescuer_thread+0x274/0x324)
> [ 3501.167610] [<c003595c>] (rescuer_thread) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3501.174929] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3501.182156] ata_sff         S c04bda98     0    31      2 0x00000000
> [ 3501.188545] [<c04bda98>] (__schedule) from [<c003595c>] (rescuer_thread+0x274/0x324)
> [ 3501.196297] [<c003595c>] (rescuer_thread) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3501.203615] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3501.210843] khubd           S c04bda98     0    32      2 0x00000000
> [ 3501.217230] [<c04bda98>] (__schedule) from [<c0328cb8>] (hub_thread+0xf74/0x119c)
> [ 3501.224722] [<c0328cb8>] (hub_thread) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3501.231692] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3501.238920] edac-poller     S c04bda98     0    33      2 0x00000000
> [ 3501.245308] [<c04bda98>] (__schedule) from [<c003595c>] (rescuer_thread+0x274/0x324)
> [ 3501.253061] [<c003595c>] (rescuer_thread) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3501.260379] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3501.267606] rpciod          S c04bda98     0    34      2 0x00000000
> [ 3501.273995] [<c04bda98>] (__schedule) from [<c003595c>] (rescuer_thread+0x274/0x324)
> [ 3501.281748] [<c003595c>] (rescuer_thread) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3501.289066] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3501.296293] kworker/0:1     R running      0    35      2 0x00000000
> [ 3501.302679] Workqueue: nfsiod rpc_async_release
> [ 3501.307230] [<c04bda98>] (__schedule) from [<c00450c4>] (__cond_resched+0x24/0x34)
> [ 3501.314809] [<c00450c4>] (__cond_resched) from [<c04be150>] (_cond_resched+0x3c/0x44)
> [ 3501.322648] [<c04be150>] (_cond_resched) from [<c0035490>] (process_one_work+0x120/0x378)
> [ 3501.330836] [<c0035490>] (process_one_work) from [<c0036198>] (worker_thread+0x13c/0x404)
> [ 3501.339022] [<c0036198>] (worker_thread) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3501.346253] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3501.353481] khungtaskd      R running      0    36      2 0x00000000
> [ 3501.359868] [<c04bda98>] (__schedule) from [<c04bd378>] (schedule_timeout+0x130/0x1ac)
> [ 3501.367795] [<c04bd378>] (schedule_timeout) from [<c007cf8c>] (watchdog+0x68/0x2e8)
> [ 3501.375461] [<c007cf8c>] (watchdog) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3501.382257] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3501.389485] kswapd0         R running      0    37      2 0x00000000
> [ 3501.395875] [<c001519c>] (unwind_backtrace) from [<c00111a4>] (show_stack+0x10/0x14)
> [ 3501.403630] [<c00111a4>] (show_stack) from [<c0046f68>] (show_state_filter+0x64/0x90)
> [ 3501.411470] [<c0046f68>] (show_state_filter) from [<c0249d90>] (__handle_sysrq+0xb0/0x17c)
> [ 3501.419746] [<c0249d90>] (__handle_sysrq) from [<c025b6fc>] (serial8250_rx_chars+0xf8/0x208)
> [ 3501.428195] [<c025b6fc>] (serial8250_rx_chars) from [<c025d360>] (serial8250_handle_irq.part.18+0x68/0x9c)
> [ 3501.437860] [<c025d360>] (serial8250_handle_irq.part.18) from [<c025c418>] (serial8250_interrupt+0x3c/0xc0)
> [ 3501.447613] [<c025c418>] (serial8250_interrupt) from [<c005e300>] (handle_irq_event_percpu+0x54/0x180)
> [ 3501.456930] [<c005e300>] (handle_irq_event_percpu) from [<c005e46c>] (handle_irq_event+0x40/0x60)
> [ 3501.465814] [<c005e46c>] (handle_irq_event) from [<c0061334>] (handle_fasteoi_irq+0x80/0x158)
> [ 3501.474349] [<c0061334>] (handle_fasteoi_irq) from [<c005dac8>] (generic_handle_irq+0x2c/0x3c)
> [ 3501.482971] [<c005dac8>] (generic_handle_irq) from [<c000eb7c>] (handle_IRQ+0x40/0x90)
> [ 3501.490897] [<c000eb7c>] (handle_IRQ) from [<c0008568>] (gic_handle_irq+0x2c/0x5c)
> [ 3501.498475] [<c0008568>] (gic_handle_irq) from [<c0011d00>] (__irq_svc+0x40/0x50)
> [ 3501.505964] Exception stack(0xcd21bdd8 to 0xcd21be20)
> [ 3501.511021] bdc0:                                                       00000000 00000000
> [ 3501.519207] bde0: 00004451 00004452 00000000 cd0e9940 cd0e9940 cd21bf00 00000000 00000000
> [ 3501.527393] be00: 00000020 00000001 00000000 cd21be20 c009a5b0 c009a5d4 60000113 ffffffff
> [ 3501.535583] [<c0011d00>] (__irq_svc) from [<c009a5d4>] (list_lru_count_node+0x3c/0x74)
> [ 3501.543513] [<c009a5d4>] (list_lru_count_node) from [<c00c00b8>] (super_cache_count+0x60/0xc4)
> [ 3501.552137] [<c00c00b8>] (super_cache_count) from [<c008bbbc>] (shrink_slab_node+0x34/0x1e4)
> [ 3501.560585] [<c008bbbc>] (shrink_slab_node) from [<c008c53c>] (shrink_slab+0xc0/0xec)
> [ 3501.568424] [<c008c53c>] (shrink_slab) from [<c008ef14>] (kswapd+0x57c/0x994)
> [ 3501.575568] [<c008ef14>] (kswapd) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3501.582190] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3501.589418] fsnotify_mark   S c04bda98     0    38      2 0x00000000
> [ 3501.595807] [<c04bda98>] (__schedule) from [<c00f5a40>] (fsnotify_mark_destroy+0xf8/0x12c)
> [ 3501.604081] [<c00f5a40>] (fsnotify_mark_destroy) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3501.612007] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3501.619234] nfsiod          S c04bda98     0    39      2 0x00000000
> [ 3501.625623] [<c04bda98>] (__schedule) from [<c003595c>] (rescuer_thread+0x274/0x324)
> [ 3501.633376] [<c003595c>] (rescuer_thread) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3501.640693] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3501.647921] crypto          S c04bda98     0    40      2 0x00000000
> [ 3501.654309] [<c04bda98>] (__schedule) from [<c003595c>] (rescuer_thread+0x274/0x324)
> [ 3501.662062] [<c003595c>] (rescuer_thread) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3501.669380] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3501.676608] kworker/u8:1    R running      0    44      2 0x00000000
> [ 3501.682994] [<c04bda98>] (__schedule) from [<c003626c>] (worker_thread+0x210/0x404)
> [ 3501.690661] [<c003626c>] (worker_thread) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3501.697892] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3501.705120] kpsmoused       S c04bda98     0    53      2 0x00000000
> [ 3501.711508] [<c04bda98>] (__schedule) from [<c003595c>] (rescuer_thread+0x274/0x324)
> [ 3501.719261] [<c003595c>] (rescuer_thread) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3501.726579] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3501.733807] deferwq         S c04bda98     0    54      2 0x00000000
> [ 3501.740194] [<c04bda98>] (__schedule) from [<c003595c>] (rescuer_thread+0x274/0x324)
> [ 3501.747946] [<c003595c>] (rescuer_thread) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3501.755264] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3501.762492] udhcpc          R running      0    92      1 0x00000000
> [ 3501.768879] [<c04bda98>] (__schedule) from [<c04bd6c8>] (schedule_hrtimeout_range_clock+0xc0/0x150)
> [ 3501.777938] [<c04bd6c8>] (schedule_hrtimeout_range_clock) from [<c00cde68>] (poll_schedule_timeout+0x3c/0x)
> [ 3501.787865] [<c00cde68>] (poll_schedule_timeout) from [<c00ce840>] (do_select+0x5c8/0x638)
> [ 3501.796140] [<c00ce840>] (do_select) from [<c00ce9d0>] (core_sys_select+0x120/0x31c)
> [ 3501.803894] [<c00ce9d0>] (core_sys_select) from [<c00cec90>] (SyS_select+0xc4/0x110)
> [ 3501.811648] [<c00cec90>] (SyS_select) from [<c000e2a0>] (ret_fast_syscall+0x0/0x30)
> [ 3501.819311] telnetd         S c04bda98     0   100      1 0x00000000
> [ 3501.825697] [<c04bda98>] (__schedule) from [<c04bd73c>] (schedule_hrtimeout_range_clock+0x134/0x150)
> [ 3501.834841] [<c04bd73c>] (schedule_hrtimeout_range_clock) from [<c00cde68>] (poll_schedule_timeout+0x3c/0x)
> [ 3501.844768] [<c00cde68>] (poll_schedule_timeout) from [<c00ce840>] (do_select+0x5c8/0x638)
> [ 3501.853043] [<c00ce840>] (do_select) from [<c00ce9d0>] (core_sys_select+0x120/0x31c)
> [ 3501.860797] [<c00ce9d0>] (core_sys_select) from [<c00cec90>] (SyS_select+0xc4/0x110)
> [ 3501.868550] [<c00cec90>] (SyS_select) from [<c000e2a0>] (ret_fast_syscall+0x0/0x30)
> [ 3501.876212] sh              S c04bda98     0   101      1 0x00000000
> [ 3501.882600] [<c04bda98>] (__schedule) from [<c0022c2c>] (do_wait+0x220/0x244)
> [ 3501.889746] [<c0022c2c>] (do_wait) from [<c0022ff0>] (SyS_wait4+0x60/0xc4)
> [ 3501.896631] [<c0022ff0>] (SyS_wait4) from [<c000e2a0>] (ret_fast_syscall+0x0/0x30)
> [ 3501.904206] portmap         S c04bda98     0   102      1 0x00000000
> [ 3501.910593] [<c04bda98>] (__schedule) from [<c04bd73c>] (schedule_hrtimeout_range_clock+0x134/0x150)
> [ 3501.919736] [<c04bd73c>] (schedule_hrtimeout_range_clock) from [<c00cde68>] (poll_schedule_timeout+0x3c/0x)
> [ 3501.929663] [<c00cde68>] (poll_schedule_timeout) from [<c00cf38c>] (do_sys_poll+0x3b8/0x478)
> [ 3501.938112] [<c00cf38c>] (do_sys_poll) from [<c00cf4fc>] (SyS_poll+0x5c/0xd4)
> [ 3501.945258] [<c00cf4fc>] (SyS_poll) from [<c000e2a0>] (ret_fast_syscall+0x0/0x30)
> [ 3501.952746] kworker/0:2     S c04bda98     0   122      2 0x00000000
> [ 3501.959134] [<c04bda98>] (__schedule) from [<c003626c>] (worker_thread+0x210/0x404)
> [ 3501.966799] [<c003626c>] (worker_thread) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3501.974029] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3501.981257] udhcpc          R running      0   132      1 0x00000000
> [ 3501.987643] [<c04bda98>] (__schedule) from [<c04bd6c8>] (schedule_hrtimeout_range_clock+0xc0/0x150)
> [ 3501.996701] [<c04bd6c8>] (schedule_hrtimeout_range_clock) from [<c00cde68>] (poll_schedule_timeout+0x3c/0x)
> [ 3502.006628] [<c00cde68>] (poll_schedule_timeout) from [<c00ce840>] (do_select+0x5c8/0x638)
> [ 3502.014903] [<c00ce840>] (do_select) from [<c00ce9d0>] (core_sys_select+0x120/0x31c)
> [ 3502.022657] [<c00ce9d0>] (core_sys_select) from [<c00cec90>] (SyS_select+0xc4/0x110)
> [ 3502.030411] [<c00cec90>] (SyS_select) from [<c000e2a0>] (ret_fast_syscall+0x0/0x30)
> [ 3502.038072] udhcpc          R running      0   137      1 0x00000000
> [ 3502.044459] [<c04bda98>] (__schedule) from [<c04bd6c8>] (schedule_hrtimeout_range_clock+0xc0/0x150)
> [ 3502.053515] [<c04bd6c8>] (schedule_hrtimeout_range_clock) from [<c00cde68>] (poll_schedule_timeout+0x3c/0x)
> [ 3502.063443] [<c00cde68>] (poll_schedule_timeout) from [<c00ce840>] (do_select+0x5c8/0x638)
> [ 3502.071718] [<c00ce840>] (do_select) from [<c00ce9d0>] (core_sys_select+0x120/0x31c)
> [ 3502.079472] [<c00ce9d0>] (core_sys_select) from [<c00cec90>] (SyS_select+0xc4/0x110)
> [ 3502.087226] [<c00cec90>] (SyS_select) from [<c000e2a0>] (ret_fast_syscall+0x0/0x30)
> [ 3502.094887] lockd           S c04bda98     0   143      2 0x00000000
> [ 3502.101273] [<c04bda98>] (__schedule) from [<c04bd3b4>] (schedule_timeout+0x16c/0x1ac)
> [ 3502.109201] [<c04bd3b4>] (schedule_timeout) from [<c04aad44>] (svc_recv+0x5ac/0x81c)
> [ 3502.116956] [<c04aad44>] (svc_recv) from [<c019e6bc>] (lockd+0x98/0x148)
> [ 3502.123666] [<c019e6bc>] (lockd) from [<c003b87c>] (kthread+0xd4/0xec)
> [ 3502.130201] [<c003b87c>] (kthread) from [<c000e338>] (ret_from_fork+0x14/0x3c)
> [ 3502.137429] rcu.sh          S c04bda98     0   153    101 0x00000000
> [ 3502.143815] [<c04bda98>] (__schedule) from [<c0022c2c>] (do_wait+0x220/0x244)
> [ 3502.150959] [<c0022c2c>] (do_wait) from [<c0022ff0>] (SyS_wait4+0x60/0xc4)
> [ 3502.157843] [<c0022ff0>] (SyS_wait4) from [<c000e2a0>] (ret_fast_syscall+0x0/0x30)
> [ 3502.165418] malloc_test_bcm R running      0   155    153 0x00000000
> [ 3502.171805] [<c04bda98>] (__schedule) from [<c00450c4>] (__cond_resched+0x24/0x34)
> [ 3502.179384] [<c00450c4>] (__cond_resched) from [<c04be150>] (_cond_resched+0x3c/0x44)
> [ 3502.187224] [<c04be150>] (_cond_resched) from [<c008c560>] (shrink_slab+0xe4/0xec)
> [ 3502.194803] [<c008c560>] (shrink_slab) from [<c008e818>] (try_to_free_pages+0x310/0x490)
> [ 3502.202906] [<c008e818>] (try_to_free_pages) from [<c0086184>] (__alloc_pages_nodemask+0x5a4/0x8f4)
> [ 3502.211963] [<c0086184>] (__alloc_pages_nodemask) from [<c009cd60>] (__pte_alloc+0x24/0x168)
> [ 3502.220411] [<c009cd60>] (__pte_alloc) from [<c00a0fdc>] (handle_mm_fault+0xc30/0xcdc)
> [ 3502.228340] [<c00a0fdc>] (handle_mm_fault) from [<c001749c>] (do_page_fault+0x194/0x27c)
> [ 3502.236441] [<c001749c>] (do_page_fault) from [<c000844c>] (do_DataAbort+0x30/0x90)
> [ 3502.244107] [<c000844c>] (do_DataAbort) from [<c0011e34>] (__dabt_usr+0x34/0x40)
> [ 3502.251509] Exception stack(0xcc9c7fb0 to 0xcc9c7ff8)
> [ 3502.256566] 7fa0:                                     76388000 00101000 00101002 000aa280
> [ 3502.264752] 7fc0: 76388008 b6fa9508 00101000 00100008 b6fa9538 00100000 00001000 bed52d24
> [ 3502.272937] 7fe0: 00000000 bed52c80 b6efefa8 b6efefc4 40000010 ffffffff
> [ 3502.279559] Sched Debug Version: v0.11, 3.14.0-rc4 #32
> [ 3502.284702] ktime                                   : 3502275.231136
> [ 3502.291061] sched_clk                               : 3502279.556898
> [ 3502.297420] cpu_clk                                 : 3502279.557268
> [ 3502.303778] jiffies                                 : 320030
> [ 3502.309441]
> [ 3502.310931] sysctl_sched
> [ 3502.313465]   .sysctl_sched_latency                    : 6.000000
> [ 3502.319563]   .sysctl_sched_min_granularity            : 0.750000
> [ 3502.325662]   .sysctl_sched_wakeup_granularity         : 1.000000
> [ 3502.331760]   .sysctl_sched_child_runs_first           : 0
> [ 3502.337250]   .sysctl_sched_features                   : 11899
> [ 3502.343087]   .sysctl_sched_tunable_scaling            : 1 (logaritmic)
> [ 3502.349706]
> [ 3502.351198] cpu#0
> [ 3502.353124]   .nr_running                    : 9
> [ 3502.357745]   .load                          : 7168
> [ 3502.362626]   .nr_switches                   : 41007
> [ 3502.367594]   .nr_load_updates               : 350030
> [ 3502.372649]   .nr_uninterruptible            : 0
> [ 3502.377269]   .next_balance                  : 4294.942188
> [ 3502.382758]   .curr->pid                     : 37
> [ 3502.387466]   .clock                         : 3500304.328054
> [ 3502.393216]   .cpu_load[0]                   : 31
> [ 3502.397922]   .cpu_load[1]                   : 31
> [ 3502.402628]   .cpu_load[2]                   : 31
> [ 3502.407335]   .cpu_load[3]                   : 31
> [ 3502.412043]   .cpu_load[4]                   : 31
> [ 3502.416750]
> [ 3502.416750] cfs_rq[0]:
> [ 3502.420589]   .exec_clock                    : 0.000000
> [ 3502.425818]   .MIN_vruntime                  : 1392.857683
> [ 3502.431308]   .min_vruntime                  : 1395.857683
> [ 3502.436798]   .max_vruntime                  : 1392.895054
> [ 3502.442287]   .spread                        : 0.037371
> [ 3502.447515]   .spread0                       : 0.000000
> [ 3502.452744]   .nr_spread_over                : 0
> [ 3502.457364]   .nr_running                    : 7
> [ 3502.461985]   .load                          : 7168
> [ 3502.466866]   .runnable_load_avg             : 31
> [ 3502.471573]   .blocked_load_avg              : 0
> [ 3502.476193]
> [ 3502.476193] rt_rq[0]:
> [ 3502.479945]   .rt_nr_running                 : 2
> [ 3502.484564]   .rt_throttled                  : 0
> [ 3502.489185]   .rt_time                       : 0.000000
> [ 3502.494414]   .rt_runtime                    : 0.000001
> [ 3502.499643]
> [ 3502.499643] runnable tasks:
> [ 3502.499643]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec     p
> [ 3502.499643] -----------------------------------------------------------------------------------------------
> [ 3502.525299]             init     1      1293.503936       967   120               0               0       0
> [ 3502.540386]         kthreadd     2        -3.000000        47     2               0               0       0
> [ 3502.555474]      ksoftirqd/0     3        -3.000000       411     2               0               0       0
> [ 3502.570562]      kworker/0:0     4      1212.395251         9   120               0               0       0
> [ 3502.585647]     kworker/0:0H     5        76.078793         3   100               0               0       0
> [ 3502.600732]     kworker/u8:0     6       474.674159         9   120               0               0       0
> [ 3502.615820]        rcu_sched     7      1392.871202       202   120               0               0       0
> [ 3502.630906]           rcu_bh     8        15.631059         2   120               0               0       0

Keeping either of the above two kthreads can get you RCU CPU stall warnings.

> [ 3502.645991]      migration/0     9         0.000000         5     0               0               0       0
> [ 3502.661079]       watchdog/0    10        -3.000000       878     0               0               0       0
> [ 3502.676164]       watchdog/1    11        22.645905         2   120               0               0       0
> [ 3502.691250]      migration/1    12         0.000000         2     0               0               0       0
> [ 3502.706336]      ksoftirqd/1    13        28.653864         2   120               0               0       0
> [ 3502.721422]      kworker/1:0    14       395.389726         8   120               0               0       0
> [ 3502.736508]     kworker/1:0H    15        76.078608         3   100               0               0       0
> [ 3502.751595]       watchdog/2    16        36.663186         2   120               0               0       0
> [ 3502.766680]      migration/2    17         0.000000         2     0               0               0       0
> [ 3502.781767]      ksoftirqd/2    18        42.671219         2   120               0               0       0
> [ 3502.796854]      kworker/2:0    19       395.389431         8   120               0               0       0
> [ 3502.811941]     kworker/2:0H    20        76.078598         3   100               0               0       0
> [ 3502.827027]       watchdog/3    21        50.680315         2   120               0               0       0
> [ 3502.842112]      migration/3    22         0.000000         2     0               0               0       0
> [ 3502.857198]      ksoftirqd/3    23        56.688385         2   120               0               0       0
> [ 3502.872286]      kworker/3:0    24       395.389949         8   120               0               0       0
> [ 3502.887372]     kworker/3:0H    25        76.078597         3   100               0               0       0
> [ 3502.902457]          khelper    26        -3.000000         2     2               0               0       0
> [ 3502.917543]        kdevtmpfs    27       980.384584       647   120               0               0       0
> [ 3502.932629]        writeback    28        77.578808         2   100               0               0       0
> [ 3502.947715]           bioset    29        79.080205         2   100               0               0       0
> [ 3502.962804]          kblockd    30        80.583022         2   100               0               0       0
> [ 3502.977890]          ata_sff    31        82.086421         2   100               0               0       0
> [ 3502.992977]            khubd    32        -3.000000        49     3               0               0       0
> [ 3503.008063]      edac-poller    33        85.093351         2   100               0               0       0
> [ 3503.023148]           rpciod    34        88.314163         2   100               0               0       0
> [ 3503.038233]      kworker/0:1    35      1392.895054       589   120               0               0       0
> [ 3503.053319]       khungtaskd    36      1392.857683         2   120               0               0       0
> [ 3503.068405] R        kswapd0    37        -3.000000     17266     2               0               0       0
> [ 3503.083491]    fsnotify_mark    38       396.392655         2   120               0               0       0
> [ 3503.098577]           nfsiod    39       398.390829         2   100               0               0       0
> [ 3503.113663]           crypto    40       400.392267         2   100               0               0       0
> [ 3503.128749]     kworker/u8:1    44      1392.857683        18   120               0               0       0
> [ 3503.143835]        kpsmoused    53       956.219135         2   100               0               0       0
> [ 3503.158921]          deferwq    54       985.352494         2   100               0               0       0
> [ 3503.174006]           udhcpc    92      1392.857683        14   120               0               0       0
> [ 3503.189092]          telnetd   100        -3.000000         1    65               0               0       0
> [ 3503.204178]               sh   101        -3.000000       224     2               0               0       0
> [ 3503.219265]          portmap   102        -3.000000        13     2               0               0       0
> [ 3503.234351]      kworker/0:2   122      1235.968172         3   120               0               0       0
> [ 3503.249436]           udhcpc   132      1392.857683         1   120               0               0       0
> [ 3503.264522]           udhcpc   137      1392.857683         1   120               0               0       0
> [ 3503.279608]            lockd   143      1324.783814         2   120               0               0       0
> [ 3503.294694]           rcu.sh   153        -3.000000         8     2               0               0       0
> [ 3503.309781]     malloc_crazy   155         0.000000     18087     2               0               0       0
> [ 3503.324868]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
