Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id F0E408D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 14:13:28 -0400 (EDT)
Received: by qwa26 with SMTP id 26so1623884qwa.14
        for <linux-mm@kvack.org>; Mon, 25 Apr 2011 11:13:27 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <20110425172914.GB2468@linux.vnet.ibm.com>
References: <20110424202158.45578f31@neptune.home>
	<20110424235928.71af51e0@neptune.home>
	<20110425114429.266A.A69D9226@jp.fujitsu.com>
	<BANLkTinVQtLbmBknBZeY=7w7AOyQk61Pew@mail.gmail.com>
	<20110425111705.786ef0c5@neptune.home>
	<BANLkTi=d0UHrYXyTK0CBZYCSK-ax8+wuWQ@mail.gmail.com>
	<20110425180450.1ede0845@neptune.home>
	<BANLkTikSLA59tdgRL4B=cr5tvP2NbzZ=KA@mail.gmail.com>
	<20110425190032.7904c95d@neptune.home>
	<20110425172914.GB2468@linux.vnet.ibm.com>
Date: Mon, 25 Apr 2011 20:13:27 +0200
Message-ID: <BANLkTim5oKxPT1KT5Zut937H5RVMiyn+Hg@mail.gmail.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning, regression?
From: Sedat Dilek <sedat.dilek@googlemail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com
Cc: =?UTF-8?Q?Bruno_Pr=C3=A9mont?= <bonbons@linux-vserver.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Mon, Apr 25, 2011 at 7:29 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
> On Mon, Apr 25, 2011 at 07:00:32PM +0200, Bruno Pr=C3=A9mont wrote:
>> On Mon, 25 April 2011 Linus Torvalds wrote:
>> > 2011/4/25 Bruno Pr=C3=A9mont <bonbons@linux-vserver.org>:
>> > >
>> > > kmemleak reports 86681 new leaks between shortly after boot and -2 s=
tate.
>> > > (and 2348 additional ones between -2 and -4).
>> >
>> > I wouldn't necessarily trust kmemleak with the whole RCU-freeing
>> > thing. In your slubinfo reports, the kmemleak data itself also tends
>> > to overwhelm everything else - none of it looks unreasonable per se.
>> >
>> > That said, you clearly have a *lot* of filp entries. I wouldn't
>> > consider it unreasonable, though, because depending on load those may
>> > well be fine. Perhaps you really do have some application(s) that hold
>> > thousands of files open. The default file limit is 1024 (I think), but
>> > you can raise it, and some programs do end up opening tens of
>> > thousands of files for filesystem scanning purposes.
>> >
>> > That said, I would suggest simply trying a saner kernel configuration,
>> > and seeing if that makes a difference:
>> >
>> > > Yes, it's uni-processor system, so SMP=3Dn.
>> > > TINY_RCU=3Dy, PREEMPT_VOLUNTARY=3Dy (whole /proc/config.gz attached =
keeping
>> > > compression)
>> >
>> > I'm not at all certain that TINY_RCU is appropriate for
>> > general-purpose loads. I'd call it more of a "embedded low-performance
>> > option".
>>
>> Well, TINY_RCU is the only option when doing PREEMPT_VOLUNTARY on
>> SMP=3Dn...
>
> You can either set SMP=3Dy and NR_CPUS=3D1 or you can handed-edit
> init/Kconfig to remove the dependency on SMP. =C2=A0Just change the
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0depends on !PREEMPT && SMP
>
> to:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0depends on !PREEMPT
>
> This will work fine, especially for experimental purposes.
>
>> > The _real_ RCU implementation ("tree rcu") forces quiescent states
>> > every few jiffies and has logic to handle "I've got tons of RCU
>> > events, I really need to start handling them now". All of which I
>> > think tiny-rcu lacks.
>>
>> Going to try it out (will take some time to compile), kmemleak disabled.
>>
>> > So right now I suspect that you have a situation where you just have a
>> > simple load that just ends up never triggering any RCU cleanup, and
>> > the tiny-rcu thing just keeps on gathering events and delays freeing
>> > stuff almost arbitrarily long.
>>
>> I hope tiny-rcu is not that broken... as it would mean driving any
>> PREEMPT_NONE or PREEMPT_VOLUNTARY system out of memory when compiling
>> packages (and probably also just unpacking larger tarballs or running
>> things like du).
>
> If it is broken, I will fix it. =C2=A0;-)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Thanx, Paul
>
>> And with system doing nothing (except monitoring itself) memory usage
>> goes increasing all the time until it starves (well it seems to keep
>> ~20M free, pushing processes it can to swap). Config is just being
>> make oldconfig from working 2.6.38 kernel (answering default for new
>> options)
>>
>> Memory usage evolution graph in first message of this thread:
>> http://thread.gmane.org/gmane.linux.kernel.mm/61909/focus=3D1130480
>>
>> Attached graph matching numbers of previous mail. (dropping caches was a=
t
>> 17:55, system idle since then)
>>
>> Bruno
>>
>>
>> > So try CONFIG_PREEMPT and CONFIG_TREE_PREEMPT_RCU to see if the
>> > behavior goes away. That would confirm the "it's just tinyrcu being
>> > too dang stupid" hypothesis.
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0Linus
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.html
>

Hi,

I was playing with Debian's kernel-buildsystem for -rc4 with a
self-defined '686-up' so-called flavour.

Here I have a Banias Pentium-M (UP, *no* PAE) and still experimenting
with kernel-config options.

CONFIG_X86_UP_APIC=3Dy
CONFIG_X86_UP_IOAPIC=3Dy

...is not possible with CONFIG_SMP=3Dy

These settings are possible by not hacking existing Kconfigs:

$ egrep 'M486|M686|X86_UP|CONFIG_SMP|NR_CPUS|PREEMPT|_RCU|_HIGHMEM|PAE'
debian/build/build_i386_none_686-up/.config
CONFIG_TREE_PREEMPT_RCU=3Dy
# CONFIG_TINY_RCU is not set
# CONFIG_TINY_PREEMPT_RCU is not set
CONFIG_PREEMPT_RCU=3Dy
# CONFIG_RCU_TRACE is not set
CONFIG_RCU_FANOUT=3D32
# CONFIG_RCU_FANOUT_EXACT is not set
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_PREEMPT_NOTIFIERS=3Dy
# CONFIG_SMP is not set
# CONFIG_M486 is not set
CONFIG_M686=3Dy
CONFIG_NR_CPUS=3D1
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=3Dy
CONFIG_X86_UP_APIC=3Dy
CONFIG_X86_UP_IOAPIC=3Dy
CONFIG_HIGHMEM4G=3Dy
# CONFIG_HIGHMEM64G is not set
CONFIG_HIGHMEM=3Dy
CONFIG_DEBUG_PREEMPT=3Dy
# CONFIG_SPARSE_RCU_POINTER is not set
# CONFIG_DEBUG_HIGHMEM is not set
# CONFIG_RCU_TORTURE_TEST is not set
# CONFIG_RCU_CPU_STALL_DETECTOR is not set
# CONFIG_PREEMPT_TRACER is not set

But I also see these warnings:

.config:2106:warning: override: TREE_PREEMPT_RCU changes choice state
.config:2182:warning: override: PREEMPT changes choice state

Not sure how to interprete them, so I am a bit careful :-).

( Untested - not compiled yet! )

- Sedat -

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
