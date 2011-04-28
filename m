Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6079A6B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 06:12:10 -0400 (EDT)
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
From: Mike Galbraith <efault@gmx.de>
In-Reply-To: <alpine.LFD.2.02.1104281139340.19095@ionos>
References: <20110425180450.1ede0845@neptune.home>
	 <BANLkTikSLA59tdgRL4B=cr5tvP2NbzZ=KA@mail.gmail.com>
	 <20110425190032.7904c95d@neptune.home>
	 <BANLkTi=hQ=HcPLCdbb1pSi+xJByMTah-gw@mail.gmail.com>
	 <20110425203606.4e78246c@neptune.home>
	 <20110425191607.GL2468@linux.vnet.ibm.com>
	 <20110425231016.34b4293e@neptune.home>
	 <BANLkTin7wSGi1=E2c2u6Jb5TG_KUpYh=Dw@mail.gmail.com>
	 <20110425214933.GO2468@linux.vnet.ibm.com>
	 <20110426081904.0d2b1494@pluto.restena.lu>
	 <20110426112756.GF4308@linux.vnet.ibm.com>
	 <20110426183859.6ff6279b@neptune.home>
	 <20110426190918.01660ccf@neptune.home>
	 <BANLkTikjuqWP+PAsObJH4EAOyzgr2RbYNA@mail.gmail.com>
	 <alpine.LFD.2.02.1104262314110.3323@ionos>
	 <20110427081501.5ba28155@pluto.restena.lu>
	 <20110427204139.1b0ea23b@neptune.home>
	 <alpine.LFD.2.02.1104272351290.3323@ionos>
	 <alpine.LFD.2.02.1104281051090.19095@ionos>
	 <BANLkTikRyHX2=d+RJAHTSzDQrexsfZZnuQ@mail.gmail.com>
	 <alpine.LFD.2.02.1104281139340.19095@ionos>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Apr 2011 12:12:02 +0200
Message-ID: <1303985522.7460.23.camel@marge.simson.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: sedat.dilek@gmail.com, Bruno =?ISO-8859-1?Q?Pr=E9mont?= <bonbons@linux-vserver.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Thu, 2011-04-28 at 11:40 +0200, Thomas Gleixner wrote:
> On Thu, 28 Apr 2011, Sedat Dilek wrote:
> > On Thu, Apr 28, 2011 at 11:09 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > > Bruno,
> > >
> > > On Thu, 28 Apr 2011, Thomas Gleixner wrote:
> > >> On Wed, 27 Apr 2011, Bruno PrA(C)mont wrote:
> > >> I need some sleep now, but I will try to come up with sensible
> > >> debugging tomorrow unless Paul or someone else beats me to it.
> > >
> > > can you please add the patch below and provide the /proc/sched_debug
> > > output when the problem shows up again?
> > >
> > > Thanks,
> > >
> > >        tglx
> > >
> > > ---
> > >  kernel/sched.c |    3 ---
> > >  1 file changed, 3 deletions(-)
> > >
> > > Index: linux-2.6/kernel/sched.c
> > > ===================================================================
> > > --- linux-2.6.orig/kernel/sched.c
> > > +++ linux-2.6/kernel/sched.c
> > > @@ -642,9 +642,6 @@ static void update_rq_clock(struct rq *r
> > >  {
> > >        s64 delta;
> > >
> > > -       if (rq->skip_clock_update)
> > > -               return;
> > > -
> > >        delta = sched_clock_cpu(cpu_of(rq)) - rq->clock;
> > >        rq->clock += delta;
> > >        update_rq_clock_task(rq, delta);
> > 
> > Referring to [1]?
> > 
> > - Sedat -
> > 
> > [1] http://lkml.org/lkml/2011/4/22/35
> 
> Kinda, but I suspect there is more wrong with that optimization thing
> for yet unknown reasons.

It's definitely getting in the way in the throttled to unthrottled RT
when otherwise idle case.  Removing it to test is a good idea.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
