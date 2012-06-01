Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 549B86B004D
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 06:14:08 -0400 (EDT)
Message-ID: <1338545638.28384.137.camel@twins>
Subject: Re: [PATCH 2/2] block: Convert BDI proportion calculations to
 flexible proportions
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 01 Jun 2012 12:13:58 +0200
In-Reply-To: <20120531224206.GC19050@quack.suse.cz>
References: <1337878751-22942-1-git-send-email-jack@suse.cz>
	 <1337878751-22942-3-git-send-email-jack@suse.cz>
	 <1338220185.4284.19.camel@lappy> <20120529123408.GA23991@quack.suse.cz>
	 <1338295111.26856.57.camel@twins> <20120529125452.GB23991@quack.suse.cz>
	 <20120531221146.GA19050@quack.suse.cz> <1338503165.28384.134.camel@twins>
	 <20120531224206.GC19050@quack.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Sasha Levin <levinsasha928@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, 2012-06-01 at 00:42 +0200, Jan Kara wrote:
> On Fri 01-06-12 00:26:05, Peter Zijlstra wrote:
> > On Fri, 2012-06-01 at 00:11 +0200, Jan Kara wrote:
> > >  bool fprop_new_period(struct fprop_global *p, int periods)
> > >  {
> > > -       u64 events =3D percpu_counter_sum(&p->events);
> > > +       u64 events;
> > > +       unsigned long flags;
> > > =20
> > > +       local_irq_save(flags);
> > > +       events =3D percpu_counter_sum(&p->events);
> > > +       local_irq_restore(flags);
> > >         /*
> > >          * Don't do anything if there are no events.
> > >          */
> > > @@ -73,7 +77,9 @@ bool fprop_new_period(struct fprop_global *p, int p=
eriods)
> > >         if (periods < 64)
> > >                 events -=3D events >> periods;
> > >         /* Use addition to avoid losing events happening between sum =
and set */
> > > +       local_irq_save(flags);
> > >         percpu_counter_add(&p->events, -events);
> > > +       local_irq_restore(flags);
> > >         p->period +=3D periods;
> > >         write_seqcount_end(&p->sequence);=20
> >=20
> > Uhm, why bother enabling it in between? Just wrap the whole function in
> > a single IRQ disable.
>   I wanted to have interrupts disabled for as short as possible but if yo=
u
> think it doesn't matter, I'll take your advice. The result is attached.

Thing is, disabling interrupts is quite expensive and the extra few
instructions covered isn't much.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
