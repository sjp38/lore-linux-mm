Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C7CFA6B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 18:05:37 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3RLjDXp012026
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 17:45:13 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3RM5ZXp056528
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 18:05:35 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3RM5TJV014016
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 18:05:35 -0400
Date: Wed, 27 Apr 2011 15:05:24 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
Message-ID: <20110427220524.GQ2135@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20110426081904.0d2b1494@pluto.restena.lu>
 <20110426112756.GF4308@linux.vnet.ibm.com>
 <20110426183859.6ff6279b@neptune.home>
 <20110426190918.01660ccf@neptune.home>
 <BANLkTikjuqWP+PAsObJH4EAOyzgr2RbYNA@mail.gmail.com>
 <alpine.LFD.2.02.1104262314110.3323@ionos>
 <20110427081501.5ba28155@pluto.restena.lu>
 <20110427204139.1b0ea23b@neptune.home>
 <4DB86BA4.8070401@draigBrady.com>
 <20110427213431.236c2a15@neptune.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20110427213431.236c2a15@neptune.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bruno =?iso-8859-1?Q?Pr=E9mont?= <bonbons@linux-vserver.org>
Cc: =?iso-8859-1?Q?P=E1draig?= Brady <P@draigBrady.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Wed, Apr 27, 2011 at 09:34:31PM +0200, Bruno Premont wrote:
> On Wed, 27 April 2011 Padraig Brady wrote:
> > On 27/04/11 19:41, Bruno Premont wrote:
> > > On Wed, 27 April 2011 Bruno Premont wrote:
> > >> On Wed, 27 Apr 2011 00:28:37 +0200 (CEST) Thomas Gleixner wrote:
> > >>> On Tue, 26 Apr 2011, Linus Torvalds wrote:
> > >>>> On Tue, Apr 26, 2011 at 10:09 AM, Bruno Premont wrote:
> > >>>>> Just in case, /proc/$(pidof rcu_kthread)/status shows ~20k voluntary
> > >>>>> context switches and exactly one non-voluntary one.
> > >>>>>
> > >>>>> In addition when rcu_kthread has stopped doing its work
> > >>>>> `swapoff $(swapdevice)` seems to block forever (at least normal shutdown
> > >>>>> blocks on disabling swap device).
> > > 
> > > Apparently it's not swapoff but `umount -a -t tmpfs` that's getting
> > > stuck here. Manual swapoff worked.

Doesn't "umount" wait for an RCU grace period?  If so, then your hang
is just a consequence of RCU grace periods hanging, which in turn appears
to be a consequence of rcu_kthread not being allowed to run.

> > Anything to do with this?
> > http://thread.gmane.org/gmane.linux.kernel.mm/60953/
> 
> I don't think so, if it is, it is only loosely related.
> 
> From the trace you omitted to keep it's visible that it gets hit by
> non-operating RCU kthread.

Yep, makes sense!

							Thanx, Paul

> Maybe existence of RCU barrier in this trace has some relation to
> above thread but I don't see it at first glance.
> 
> [ 1714.960735] umount          D 5a000040  5668 20331  20324 0x00000000
> [ 1714.960735]  c3c99e5c 00000086 dd407900 5a000040 dd25a1a8 dd407900 dd25a120 c3c99e0c
> [ 1714.960735]  c3c99e24 c10c1be2 c14d9f20 c3c99e5c c3c8c680 c3c8c680 000000bb c3c99e24
> [ 1714.960735]  c10c0b88 dd25a120 dd407900 ddfd4b40 c3c99e4c ddfc9d20 dd402380 5a000010
> [ 1714.960735] Call Trace:
> [ 1714.960735]  [<c10c1be2>] ? check_object+0x92/0x210
> [ 1714.960735]  [<c10c0b88>] ? init_object+0x38/0x70
> [ 1714.960735]  [<c10c1be2>] ? check_object+0x92/0x210
> [ 1714.960735]  [<c13cb37d>] schedule_timeout+0x16d/0x280
> [ 1714.960735]  [<c10c0b88>] ? init_object+0x38/0x70
> [ 1714.960735]  [<c10c2122>] ? free_debug_processing+0x112/0x1f0
> [ 1714.960735]  [<c10a3791>] ? shmem_put_super+0x11/0x20
> [ 1714.960735]  [<c13cae9c>] wait_for_common+0x9c/0x150
> [ 1714.960735]  [<c102c890>] ? try_to_wake_up+0x170/0x170
> [ 1714.960735]  [<c13caff2>] wait_for_completion+0x12/0x20
> [ 1714.960735]  [<c1075ad7>] rcu_barrier_sched+0x47/0x50
>                              ^^^^^^^^^^^^^^^^^
> [ 1714.960735]  [<c104d3c0>] ? alloc_pid+0x370/0x370
> [ 1714.960735]  [<c10ce74a>] deactivate_locked_super+0x3a/0x60
> [ 1714.960735]  [<c10ce948>] deactivate_super+0x48/0x70
> [ 1714.960735]  [<c10e7427>] mntput_no_expire+0x87/0xe0
> [ 1714.960735]  [<c10e7800>] sys_umount+0x60/0x320
> [ 1714.960735]  [<c10b231a>] ? remove_vma+0x3a/0x50
> [ 1714.960735]  [<c10b3b22>] ? do_munmap+0x212/0x2f0
> [ 1714.960735]  [<c10e7ad9>] sys_oldumount+0x19/0x20
> [ 1714.960735]  [<c13cce10>] sysenter_do_call+0x12/0x26
> 
> Bruno

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
