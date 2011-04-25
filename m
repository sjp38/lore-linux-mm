Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6356F8D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 14:28:45 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3PI31AW005470
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 14:03:01 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3PIShuT1110072
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 14:28:43 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3PISfVG026158
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 14:28:43 -0400
Date: Mon, 25 Apr 2011 11:28:40 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
Message-ID: <20110425182840.GK2468@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20110424235928.71af51e0@neptune.home>
 <20110425114429.266A.A69D9226@jp.fujitsu.com>
 <BANLkTinVQtLbmBknBZeY=7w7AOyQk61Pew@mail.gmail.com>
 <20110425111705.786ef0c5@neptune.home>
 <BANLkTi=d0UHrYXyTK0CBZYCSK-ax8+wuWQ@mail.gmail.com>
 <20110425180450.1ede0845@neptune.home>
 <BANLkTikSLA59tdgRL4B=cr5tvP2NbzZ=KA@mail.gmail.com>
 <20110425190032.7904c95d@neptune.home>
 <20110425172914.GB2468@linux.vnet.ibm.com>
 <BANLkTim5oKxPT1KT5Zut937H5RVMiyn+Hg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTim5oKxPT1KT5Zut937H5RVMiyn+Hg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sedat.dilek@gmail.com
Cc: Bruno =?iso-8859-1?Q?Pr=E9mont?= <bonbons@linux-vserver.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Mon, Apr 25, 2011 at 08:13:27PM +0200, Sedat Dilek wrote:
> On Mon, Apr 25, 2011 at 7:29 PM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> > On Mon, Apr 25, 2011 at 07:00:32PM +0200, Bruno Premont wrote:
> >> On Mon, 25 April 2011 Linus Torvalds wrote:
> >> > 2011/4/25 Bruno Premont <bonbons@linux-vserver.org>:
> >> > >
> >> > > kmemleak reports 86681 new leaks between shortly after boot and -2 state.
> >> > > (and 2348 additional ones between -2 and -4).
> >> >
> >> > I wouldn't necessarily trust kmemleak with the whole RCU-freeing
> >> > thing. In your slubinfo reports, the kmemleak data itself also tends
> >> > to overwhelm everything else - none of it looks unreasonable per se.
> >> >
> >> > That said, you clearly have a *lot* of filp entries. I wouldn't
> >> > consider it unreasonable, though, because depending on load those may
> >> > well be fine. Perhaps you really do have some application(s) that hold
> >> > thousands of files open. The default file limit is 1024 (I think), but
> >> > you can raise it, and some programs do end up opening tens of
> >> > thousands of files for filesystem scanning purposes.
> >> >
> >> > That said, I would suggest simply trying a saner kernel configuration,
> >> > and seeing if that makes a difference:
> >> >
> >> > > Yes, it's uni-processor system, so SMP=n.
> >> > > TINY_RCU=y, PREEMPT_VOLUNTARY=y (whole /proc/config.gz attached keeping
> >> > > compression)
> >> >
> >> > I'm not at all certain that TINY_RCU is appropriate for
> >> > general-purpose loads. I'd call it more of a "embedded low-performance
> >> > option".
> >>
> >> Well, TINY_RCU is the only option when doing PREEMPT_VOLUNTARY on
> >> SMP=n...
> >
> > You can either set SMP=y and NR_CPUS=1 or you can handed-edit
> > init/Kconfig to remove the dependency on SMP.  Just change the
> >
> >        depends on !PREEMPT && SMP
> >
> > to:
> >
> >        depends on !PREEMPT
> >
> > This will work fine, especially for experimental purposes.
> >
> >> > The _real_ RCU implementation ("tree rcu") forces quiescent states
> >> > every few jiffies and has logic to handle "I've got tons of RCU
> >> > events, I really need to start handling them now". All of which I
> >> > think tiny-rcu lacks.
> >>
> >> Going to try it out (will take some time to compile), kmemleak disabled.
> >>
> >> > So right now I suspect that you have a situation where you just have a
> >> > simple load that just ends up never triggering any RCU cleanup, and
> >> > the tiny-rcu thing just keeps on gathering events and delays freeing
> >> > stuff almost arbitrarily long.
> >>
> >> I hope tiny-rcu is not that broken... as it would mean driving any
> >> PREEMPT_NONE or PREEMPT_VOLUNTARY system out of memory when compiling
> >> packages (and probably also just unpacking larger tarballs or running
> >> things like du).
> >
> > If it is broken, I will fix it.  ;-)
> >
> >                                                        Thanx, Paul
> >
> >> And with system doing nothing (except monitoring itself) memory usage
> >> goes increasing all the time until it starves (well it seems to keep
> >> ~20M free, pushing processes it can to swap). Config is just being
> >> make oldconfig from working 2.6.38 kernel (answering default for new
> >> options)
> >>
> >> Memory usage evolution graph in first message of this thread:
> >> http://thread.gmane.org/gmane.linux.kernel.mm/61909/focus=1130480
> >>
> >> Attached graph matching numbers of previous mail. (dropping caches was at
> >> 17:55, system idle since then)
> >>
> >> Bruno
> >>
> >>
> >> > So try CONFIG_PREEMPT and CONFIG_TREE_PREEMPT_RCU to see if the
> >> > behavior goes away. That would confirm the "it's just tinyrcu being
> >> > too dang stupid" hypothesis.
> >> >
> >> >                      Linus
> >
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> 
> Hi,
> 
> I was playing with Debian's kernel-buildsystem for -rc4 with a
> self-defined '686-up' so-called flavour.
> 
> Here I have a Banias Pentium-M (UP, *no* PAE) and still experimenting
> with kernel-config options.
> 
> CONFIG_X86_UP_APIC=y
> CONFIG_X86_UP_IOAPIC=y
> 
> ...is not possible with CONFIG_SMP=y

Right, hence my advice to hand-edit init/Kconfig for experimental
purposes.  Once that is done, you can select CONFIG_TREE_RCU with
CONFIG_SMP=n.

						Thanx, Paul

> These settings are possible by not hacking existing Kconfigs:
> 
> $ egrep 'M486|M686|X86_UP|CONFIG_SMP|NR_CPUS|PREEMPT|_RCU|_HIGHMEM|PAE'
> debian/build/build_i386_none_686-up/.config
> CONFIG_TREE_PREEMPT_RCU=y
> # CONFIG_TINY_RCU is not set
> # CONFIG_TINY_PREEMPT_RCU is not set
> CONFIG_PREEMPT_RCU=y
> # CONFIG_RCU_TRACE is not set
> CONFIG_RCU_FANOUT=32
> # CONFIG_RCU_FANOUT_EXACT is not set
> # CONFIG_TREE_RCU_TRACE is not set
> CONFIG_PREEMPT_NOTIFIERS=y
> # CONFIG_SMP is not set
> # CONFIG_M486 is not set
> CONFIG_M686=y
> CONFIG_NR_CPUS=1
> # CONFIG_PREEMPT_NONE is not set
> # CONFIG_PREEMPT_VOLUNTARY is not set
> CONFIG_PREEMPT=y
> CONFIG_X86_UP_APIC=y
> CONFIG_X86_UP_IOAPIC=y
> CONFIG_HIGHMEM4G=y
> # CONFIG_HIGHMEM64G is not set
> CONFIG_HIGHMEM=y
> CONFIG_DEBUG_PREEMPT=y
> # CONFIG_SPARSE_RCU_POINTER is not set
> # CONFIG_DEBUG_HIGHMEM is not set
> # CONFIG_RCU_TORTURE_TEST is not set
> # CONFIG_RCU_CPU_STALL_DETECTOR is not set
> # CONFIG_PREEMPT_TRACER is not set
> 
> But I also see these warnings:
> 
> .config:2106:warning: override: TREE_PREEMPT_RCU changes choice state
> .config:2182:warning: override: PREEMPT changes choice state
> 
> Not sure how to interprete them, so I am a bit careful :-).
> 
> ( Untested - not compiled yet! )
> 
> - Sedat -

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
