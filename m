Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3B0196B0169
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 14:40:32 -0400 (EDT)
Subject: Re: [PATCH] memcg: remove unneeded preempt_disable
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 25 Aug 2011 20:40:13 +0200
In-Reply-To: <alpine.DEB.2.00.1108251128460.27407@router.home>
References: <1313650253-21794-1-git-send-email-gthelen@google.com>
	  <20110818144025.8e122a67.akpm@linux-foundation.org>
	  <1314284272.27911.32.camel@twins>
	  <alpine.DEB.2.00.1108251009120.27407@router.home>
	 <1314289208.3268.4.camel@mulgrave>
	 <alpine.DEB.2.00.1108251128460.27407@router.home>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1314297613.27911.83.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-arch@vger.kernel.org

On Thu, 2011-08-25 at 11:31 -0500, Christoph Lameter wrote:
> On Thu, 25 Aug 2011, James Bottomley wrote:
>=20
> > On Thu, 2011-08-25 at 10:11 -0500, Christoph Lameter wrote:
> > > On Thu, 25 Aug 2011, Peter Zijlstra wrote:
> > >
> > > > On Thu, 2011-08-18 at 14:40 -0700, Andrew Morton wrote:
> > > > >
> > > > > I think I'll apply it, as the call frequency is low (correct?) an=
d the
> > > > > problem will correct itself as other architectures implement thei=
r
> > > > > atomic this_cpu_foo() operations.
> > > >
> > > > Which leads me to wonder, can anything but x86 implement that this_=
cpu_*
> > > > muck? I doubt any of the risk chips can actually do all this.
> > > > Maybe Itanic, but then that seems to be dying fast.
> > >
> > > The cpu needs to have an RMW instruction that does something to a
> > > variable relative to a register that points to the per cpu base.
> > >
> > > Thats generally possible. The problem is how expensive the RMW is goi=
ng to
> > > be.
> >
> > Risc systems generally don't have a single instruction for this, that's
> > correct.  Obviously we can do it as a non atomic sequence: read
> > variable, compute relative, read, modify, write ... but there's
> > absolutely no point hand crafting that in asm since the compiler can
> > usually work it out nicely.  And, of course, to have this atomic, we
> > have to use locks, which ends up being very expensive.
>=20
> ARM seems to have these LDREX/STREX instructions for that purpose which
> seem to be used for generating atomic instructions without lockes. I gues=
s
> other RISC architectures have similar means of doing it?

Even with LL/SC and the CPU base in a register you need to do something
like:

again:
	LL $target-reg, $cpubase-reg + offset
	<foo>
	SC $ret, $target-reg, $cpubase-reg + offset
	if !$ret goto again

Its the +offset that's problematic, it either doesn't exist or is very
limited (a quick look at the MIPS instruction set gives a limit of 64k).

Without the +offset you need:

again:
	$tmp-reg =3D $cpubase-reg
	$tmp-reg +=3D offset;

	LL $target-reg, $tmp-reg
	<foo>
	SC $ret, $target-reg, $tmp-reg
	if !$ret goto again


Which is wide open to migration races. Also, very often there are
constraints on LL/SC that mandate we use preempt_disable/enable around
its use, which pretty much voids the whole purpose, since if we disable
preemption we might as well just use C (ARM belongs in this class).

It does look POWERPC's lwarx/stwcx is sane enough, although the
instruction reference I found doesn't list what happens if the LL/SC
doesn't use the same effective address or has other loads/stores in
between, if its ok with those and simply fails the SC it should be good.

Still, creating atomic ops for per-cpu ops might be more expensive than
simply doing the preempt-disable/rmw/enable dance, dunno don't know
these archs that well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
