Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7C2356B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 10:28:36 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <a2fc3885-b98d-4918-afcc-5eac083c7eb0@default>
Date: Fri, 26 Aug 2011 07:28:05 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Subject: [PATCH V7 2/4] mm: frontswap: core code
References: <20110823145815.GA23190@ca-server1.us.oracle.com>
 <20110825150532.a4d282b1.kamezawa.hiroyu@jp.fujitsu.com>
 <d0b4c414-e90f-4ae0-9b70-fd5b54d2b011@default
 20110826091619.1ad27e9c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110826091619.1ad27e9c.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, Chris Mason <chris.mason@oracle.com>, sjenning@linux.vnet.ibm.com, jackdachef@gmail.com, cyclonusj@gmail.com

> From: KAMEZAWA Hiroyuki [mailto:kamezawa.hiroyu@jp.fujitsu.com]
> Subject: Re: Subject: [PATCH V7 2/4] mm: frontswap: core code
>=20
> On Thu, 25 Aug 2011 10:37:05 -0700 (PDT)
> Dan Magenheimer <dan.magenheimer@oracle.com> wrote:
>=20
> > > From: KAMEZAWA Hiroyuki [mailto:kamezawa.hiroyu@jp.fujitsu.com]
> > > Subject: Re: Subject: [PATCH V7 2/4] mm: frontswap: core code
>=20
> > > BTW, Do I have a chance to implement frontswap accounting per cgroup
> > > (under memcg) ? Or Do I need to enable/disale switch for frontswap pe=
r memcg ?
> > > Do you think it is worth to do ?
> >
> > I'm not very familiar with cgroups or memcg but I think it may be possi=
ble
> > to implement transcendent memory with cgroup as the "guest" and the def=
ault
> > cgroup as the "host" to allow for more memory elasticity for cgroups.
> > (See http://lwn.net/Articles/454795/ for a good overview of all of
> > transcendent memory.)
> >
> Ok, I'll see it.
>=20
> I just wonder following case.
>=20
> Assume 2 memcgs.
> =09memcg X: memory limit =3D 300M.
> =09memcg Y: memory limit =3D 300M.
>=20
> This limitation is done for performance isolation.
> When using frontswap, X and Y can cause resource confliction in frontswap=
 and
> performance of X and Y cannot be predictable.

> > These are informational statistics so do not need to be protected
> > by a lock or an atomic-type.  If an increment is lost due to a cpu
> > race, it is not a problem.
>=20
> Hmm...Personally, I don't like incorrect counters. Could you add comments=
 ?
> Or How anout using percpu_counter ? (see lib/percpu_counter.c)

Since the exact values of these counters is not required
by any code (just information for userland), I think I will
just add a comment.

> > > What lock should be held to guard global variables ? swap_lock ?
> >
> > Which global variables do you mean and in what routines?  I think the
> > page lock is required for put/get (as documented in the comments)
> > but not the swap_lock.
>=20
> My concern was race in counters. Even you allow race in frontswap_succ_pu=
ts++,
>=20
> Don't you need some lock for
> =09sis->frontswap_pages++
> =09sis->frontswap_pages--

Hmmm... OK, you've convinced me.  If this counter should be one and
a race leaves it as zero, I think data corruption could result on
a swapoff or partial swapoff.  And after thinking about it, I
think I also need to check for locking on frontswap_set/clear
as I don't think these bitfield modifiers are atomic.

Thanks for pointing this out.  Good catch!  I will need to
play with this and test it so probably will not submit V8 until
next week as today is a vacation day for me.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
