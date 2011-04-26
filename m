Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1A86F900001
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 02:19:07 -0400 (EDT)
Date: Tue, 26 Apr 2011 08:19:04 +0200
From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
Message-ID: <20110426081904.0d2b1494@pluto.restena.lu>
In-Reply-To: <20110425214933.GO2468@linux.vnet.ibm.com>
References: <20110425111705.786ef0c5@neptune.home>
	<BANLkTi=d0UHrYXyTK0CBZYCSK-ax8+wuWQ@mail.gmail.com>
	<20110425180450.1ede0845@neptune.home>
	<BANLkTikSLA59tdgRL4B=cr5tvP2NbzZ=KA@mail.gmail.com>
	<20110425190032.7904c95d@neptune.home>
	<BANLkTi=hQ=HcPLCdbb1pSi+xJByMTah-gw@mail.gmail.com>
	<20110425203606.4e78246c@neptune.home>
	<20110425191607.GL2468@linux.vnet.ibm.com>
	<20110425231016.34b4293e@neptune.home>
	<BANLkTin7wSGi1=E2c2u6Jb5TG_KUpYh=Dw@mail.gmail.com>
	<20110425214933.GO2468@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, Mike Frysinger <vapier.adi@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Mon, 25 Apr 2011 14:49:33 "Paul E. McKenney" wrote:
> On Mon, Apr 25, 2011 at 02:30:02PM -0700, Linus Torvalds wrote:
> > 2011/4/25 Bruno Pr=C3=A9mont <bonbons@linux-vserver.org>:
> > >
> > > Between 1-slabinfo and 2-slabinfo some values increased (a lot) while=
 a few
> > > ones did decrease. Don't know which ones are RCU-affected and which o=
nes are
> > > not.
> >=20
> > It really sounds as if the tiny-rcu kthread somehow just stops
> > handling callbacks. The ones that keep increasing do seem to be all
> > rcu-free'd (but I didn't really check).
> >=20
> > The thing is shown as running:
> >=20
> > root         6  0.0  0.0      0     0 ?        R    22:14   0:00  \_
> > [rcu_kthread]
> >=20
> > but nothing seems to happen and the CPU time hasn't increased at all.
> >=20
> > I dunno. Makes no  sense to me, but yeah, I'm definitely blaming
> > tiny-rcu. Paul, any ideas?
>=20
> So the only ways I know for something to be runnable but not run on
> a uniprocessor are:
>=20
> 1.	The CPU is continually busy with higher-priority work.
> 	This doesn't make sense in this case because the system
> 	is idle much of the time.
>=20
> 2.	The system is hibernating.  This doesn't make sense, otherwise
> 	"ps" wouldn't run either.
>=20
> Any others ideas on how the heck a process can get into this state?
> (I have thus far been completely unable to reproduce it.)
>=20
> The process in question has a loop in rcu_kthread() in kernel/rcutiny.c.
> This loop contains a wait_event_interruptible(), waits for a global flag
> to become non-zero.
>=20
> It is awakened by invoke_rcu_kthread() in that same file, which
> simply sets the flag to 1 and does a wake_up(), all with hardirqs
> disabled.
>=20
> Hmmm...  One "hail mary" patch below.  What it does is make rcu_kthread
> run at normal priority rather than at real-time priority.  This is
> not for inclusion -- it breaks RCU priority boosting.  But well worth
> trying.
>=20
> 							Thanx, Paul
>=20
> ------------------------------------------------------------------------
>=20
> diff --git a/kernel/rcutiny.c b/kernel/rcutiny.c
> index 0c343b9..4551824 100644
> --- a/kernel/rcutiny.c
> +++ b/kernel/rcutiny.c
> @@ -314,11 +314,15 @@ EXPORT_SYMBOL_GPL(rcu_barrier_sched);
>   */
>  static int __init rcu_spawn_kthreads(void)
>  {
> +#if 0
>  	struct sched_param sp;
> +#endif
> =20
>  	rcu_kthread_task =3D kthread_run(rcu_kthread, NULL, "rcu_kthread");
> +#if 0
>  	sp.sched_priority =3D RCU_BOOST_PRIO;
>  	sched_setscheduler_nocheck(rcu_kthread_task, SCHED_FIFO, &sp);
> +#endif
>  	return 0;
>  }
>  early_initcall(rcu_spawn_kthreads);

I will give that patch a shot on Wednesday evening (European time) as I
wont have enough time in front of the affected box until then to do any
deeper testing. (same for trying to out with the other -rc kernels as
suggested by Mike)

Though I will use the few minutes I have this evening to try to fetch
kernel traces of running tasks with sysrq+t which may eventually give
us a hint at where rcu_thread is stuck/waiting.

Bruno

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
