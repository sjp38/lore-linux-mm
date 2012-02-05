Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 6AEA36B13F1
	for <linux-mm@kvack.org>; Sun,  5 Feb 2012 07:06:31 -0500 (EST)
Received: by vcbf13 with SMTP id f13so4401884vcb.14
        for <linux-mm@kvack.org>; Sun, 05 Feb 2012 04:06:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1202021124520.6338@router.home>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
	<1327591185.2446.102.camel@twins>
	<CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com>
	<1328117722.2446.262.camel@twins>
	<20120201184045.GG2382@linux.vnet.ibm.com>
	<alpine.DEB.2.00.1202011404500.2074@router.home>
	<20120201201336.GI2382@linux.vnet.ibm.com>
	<4F2A58A1.90800@redhat.com>
	<20120202153437.GD2518@linux.vnet.ibm.com>
	<4F2AB66C.2030309@redhat.com>
	<20120202170134.GM2518@linux.vnet.ibm.com>
	<alpine.DEB.2.00.1202021124520.6338@router.home>
Date: Sun, 5 Feb 2012 14:06:29 +0200
Message-ID: <CAOtvUMdCZpQuSvutKHpMxthktTm_VkA1R99yxpNhxpsYN9wTRQ@mail.gmail.com>
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Avi Kivity <avi@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Thu, Feb 2, 2012 at 7:25 PM, Christoph Lameter <cl@linux.com> wrote:
> On Thu, 2 Feb 2012, Paul E. McKenney wrote:
>
>> Frederic's work checks to see if there is only one runnable user task
>> on a given CPU. =A0If there is only one, then the scheduling-clock inter=
rupt
>> is turned off for that CPU, and RCU is told to ignore it while it is
>> executing in user space. =A0Not sure whether this covers KVM guests.
>>
>> In any case, this is not yet in mainline.
>
> Sounds great. Is there any plan on when to merge it? Where are the most u=
p
> to date patches vs mainstream?
>


Frederic has the latest version in a git tree here:

git://github.com/fweisbec/linux-dynticks.git
       nohz/cpuset-v2-pre-20120117

It's on top latest rcu/core.

I've been playing with it for some time now. It works very well, considerin=
g the
early  state - there are  a couple of TODO items listed here:
https://tglx.de/~fweisbec/TODO-nohz-cpusets and I've seen an assert from
the  RCU code once.

Also, there is some system stuff "in the way" so to speak, of getting the f=
ull
benefits:

I had to disable the clock source watchdog (I'm testing in a KVM VM, so I g=
uess
the TSC is not stable), the vmstat_stats work on that CPU and to (try
to) fix what
looks like a bug in  the NOHZ timer code.

But the good news is that with these hacks applied I managed to run a 100%
CPU task  with  zero interrupts  (ticks or  otherwise) on an isolated cpu.

Disregarding TLB overhead, you get bare metal performance with Linux user
space manageability and  debug capabilities.  Pretty magical really: It's l=
ike
eating your cake and having it too :-)

Gilad

--=20
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
http://benyossef.com

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
=A0-- Jean-Baptiste Queru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
