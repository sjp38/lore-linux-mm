Received: by zproxy.gmail.com with SMTP id k1so195653nzf
        for <linux-mm@kvack.org>; Sun, 02 Oct 2005 19:08:37 -0700 (PDT)
Message-ID: <aec7e5c30510021908la86daf9je0584fb0107f833a@mail.gmail.com>
Date: Mon, 3 Oct 2005 11:08:37 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Reply-To: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH 00/07][RFC] i386: NUMA emulation
In-Reply-To: <1128093825.6145.26.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20050930073232.10631.63786.sendpatchset@cherry.local>
	 <1128093825.6145.26.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Magnus Damm <magnus@valinux.co.jp>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 10/1/05, Dave Hansen <haveblue@us.ibm.com> wrote:
> On Fri, 2005-09-30 at 16:33 +0900, Magnus Damm wrote:
> > These patches implement NUMA memory node emulation for regular i386 PC:s.
> >
> > NUMA emulation could be used to provide coarse-grained memory resource control
> > using CPUSETS. Another use is as a test environment for NUMA memory code or
> > CPUSETS using an i386 emulator such as QEMU.
>
> This patch set basically allows the "NUMA depends on SMP" dependency to
> be removed.  I'm not sure this is the right approach.  There will likely
> never be a real-world NUMA system without SMP.  So, this set would seem
> to include some increased (#ifdef) complexity for supporting SMP && !
> NUMA, which will likely never happen in the real world.

Yes, this patch set removes "NUMA depends on SMP". It also adds some
simple NUMA emulation code too, but I am sure you are aware of that!
=)

I agree that it is very unlikely to find a single-processor NUMA
system in the real world. So yes, "[PATCH 02/07] i386: numa on
non-smp" adds _some_ extra complexity. But because SMP is set when
supporting more than one cpu, and NUMA is set when supporting more
than one memory node, I see no reason why they should be dependent on
each other. Except that they depend on each other today and breaking
them loose will increase complexity a bit.

> Also, I worry that simply #ifdef'ing things out like CPUsets' update
> means that CPUsets lacks some kind of abstraction that it should have
> been using in the first place.  An #ifdef just papers over the real
> problem.

Maybe. CPUSETS has two bitmaps, one for cpus and one for mems. So
depending on SMP or NUMA seems logical to me. Regarding the #ifdef, it
was added because partition_sched_domain() is only implemented for
SMP. That symbol has no prototype or implementation when CONFIG_SMP is
not set. Maybe it is better to add an empty inline function in
linux/sched.h for !SMP?

> I think it would likely be cleaner if the approach was to emulate an SMP
> NUMA system where each NUMA node simply doesn't have all of its CPUs
> online.

Absolutely. And that removes the need for some of my patches. QEMU
runs SMP kernels. It is possible to run SMP kernels on UP hardware.
But there is of course a certain performance loss introduced by all
the SMP locks. I'd rather not force !SMP users to run SMP kernels if
they want coarse-grained memory resource control.

Thanks for your input!

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
