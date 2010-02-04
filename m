Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 47F9D6B007D
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 19:22:59 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o140Mui1012410
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 4 Feb 2010 09:22:56 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DDCDF45DE57
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 09:22:55 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A9B7945DE51
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 09:22:55 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B557E78003
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 09:22:55 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 368671DB8038
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 09:22:55 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] vmscan: balance local_irq_disable() and  local_irq_enable()
In-Reply-To: <520f0cf11002031212p4f1497e3he82dce3af668e676@mail.gmail.com>
References: <1265227746.24386.15.camel@gandalf.stny.rr.com> <520f0cf11002031212p4f1497e3he82dce3af668e676@mail.gmail.com>
Message-Id: <20100204091938.C2C6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Thu,  4 Feb 2010 09:22:54 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: John Kacur <jkacur@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, rostedt@goodmis.org, lkml <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Wed, Feb 3, 2010 at 9:09 PM, Steven Rostedt <rostedt@goodmis.org> wrot=
e:
> > t On Wed, 2010-02-03 at 20:53 +0100, John Kacur wrote:
> >> Balance local_irq_disable() and local_irq_enable() as well as
> >> spin_lock_irq() and spin_lock_unlock_irq
> >>
> >> Signed-off-by: John Kacur <jkacur@redhat.com>
> >> ---
> >> =A0mm/vmscan.c | =A0 =A03 ++-
> >> =A01 files changed, 2 insertions(+), 1 deletions(-)
> >>
> >> diff --git a/mm/vmscan.c b/mm/vmscan.c
> >> index c26986c..b895025 100644
> >> --- a/mm/vmscan.c
> >> +++ b/mm/vmscan.c
> >> @@ -1200,8 +1200,9 @@ static unsigned long shrink_inactive_list(unsign=
ed long max_scan,
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (current_is_kswapd())
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __count_vm_events(KSWAPD_S=
TEAL, nr_freed);
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __count_zone_vm_events(PGSTEAL, zone, nr_f=
reed);
> >> + =A0 =A0 =A0 =A0 =A0 =A0 local_irq_enable();
> >>
> >> - =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&zone->lru_lock);
> >> + =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irq(&zone->lru_lock);
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Put back any unfreeable pages.
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> >
> >
> > The above looks wrong. I don't know the code, but just by looking at
> > where the locking and interrupts are, I can take a guess.
> >
> > Lets add a little more of the code:
> >
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0local_irq_disable();
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (current_is_kswapd())
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__count_vm_events(KSWAPD=
_STEAL, nr_freed);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__count_zone_vm_events(PGSTEAL, zone, nr=
_freed);
> >
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock(&zone->lru_lock);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> >
> > I'm guessing the __count_zone_vm_events and friends need interrupts
> > disabled here, probably due to per cpu stuff. But if you enable
> > interrupts before the spin_lock() you may let an interrupt come in and
> > invalidate what was done above it.
> >
> > So no, I do not think enabling interrupts here is a good thing.
> >
>=20
> okay, and since we have already done local_irq_disable(), then that is
> why we only need the spin_lock() and not the spin_lock_irq() flavour?

Yes, spin_lock_irq() is equivalent to spin_lock() + irq_disable().
Now, we already disabled irq. then, we only need spin_lock().

So, I don't think shrink_inactive_list need any fix.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
