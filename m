Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1A5DD6B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 09:31:03 -0400 (EDT)
Subject: Re: possible recursive locking detected cache_alloc_refill() +
 cache_flusharray()
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <alpine.DEB.2.00.1107201619540.3528@tiger>
References: <20110716211850.GA23917@breakpoint.cc>
	 <alpine.LFD.2.02.1107172333340.2702@ionos>
	 <alpine.DEB.2.00.1107201619540.3528@tiger>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 20 Jul 2011 15:30:38 +0200
Message-ID: <1311168638.5345.80.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Sebastian Siewior <sebastian@breakpoint.cc>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On Wed, 2011-07-20 at 16:21 +0300, Pekka Enberg wrote:
> On Sat, 16 Jul 2011, Sebastian Siewior wrote:
> >> just hit the following with full debuging turned on:
> >>
> >> | =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >> | [ INFO: possible recursive locking detected ]
> >> | 3.0.0-rc7-00088-g1765a36 #64
> >> | ---------------------------------------------
> >> | udevd/1054 is trying to acquire lock:
> >> |  (&(&parent->list_lock)->rlock){..-...}, at: [<c00bf640>] cache_allo=
c_refill+0xac/0x868
> >> |
> >> | but task is already holding lock:
> >> |  (&(&parent->list_lock)->rlock){..-...}, at: [<c00be47c>] cache_flus=
harray+0x58/0x148
> >> |
> >> | other info that might help us debug this:
> >> |  Possible unsafe locking scenario:
> >> |
> >> |        CPU0
> >> |        ----
> >> |   lock(&(&parent->list_lock)->rlock);
> >> |   lock(&(&parent->list_lock)->rlock);
>=20
> On Sun, 17 Jul 2011, Thomas Gleixner wrote:
> > Known problem. Pekka is looking into it.
>=20
> Actually, I kinda was hoping Peter would make it go away. ;-)
>=20
> Looking at the lockdep report, it's l3->list_lock and I really don't quit=
e=20
> understand why it started to happen now. There hasn't been any major=20
> changes in mm/slab.c for a while. Did lockdep become more strict recently=
?

Not that I know.. :-) I bet -rt just makes it easier to trigger this
weirdness.

Let me try and look at slab.c without my eyes burning out.. I so hate
that code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
