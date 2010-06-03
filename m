Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2BB286B01AF
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 20:52:53 -0400 (EDT)
Received: by gyg4 with SMTP id 4so5669998gyg.14
        for <linux-mm@kvack.org>; Wed, 02 Jun 2010 17:52:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100603083259.7231.A69D9226@jp.fujitsu.com>
References: <20100602220429.F51E.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1006021410300.32666@chino.kir.corp.google.com>
	<20100603083259.7231.A69D9226@jp.fujitsu.com>
Date: Thu, 3 Jun 2010 09:52:49 +0900
Message-ID: <AANLkTinxHv6VfaG-RXymfPwOMQi-cJTX3Tj0x6ROkZzo@mail.gmail.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, Jun 3, 2010 at 8:36 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Wed, 2 Jun 2010, KOSAKI Motohiro wrote:
>>
>> > > > @@ -291,9 +309,10 @@ static struct task_struct *select_bad_process=
(unsigned long *ppoints,
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Ot=
herwise we could get an easy OOM deadlock.
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (p->fla=
gs & PF_EXITING) {
>> > > > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 if (p !=3D current)
>> > > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 if (p !=3D current) {
>> > > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 boost_dying_task_prio(p, mem);
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ERR_PTR(-1UL);
>> > > > -
>> > > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 }
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 chosen =3D p;
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 *ppoints =3D ULONG_MAX;
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> > >
>> > > This has the potential to actually make it harder to free memory if =
p is
>> > > waiting to acquire a writelock on mm->mmap_sem in the exit path whil=
e the
>> > > thread holding mm->mmap_sem is trying to run.
>> >
>> > if p is waiting, changing prio have no effect. It continue tol wait to=
 release mmap_sem.
>> >
>>
>> And that can reduce the runtime of the thread holding a writelock on
>> mm->mmap_sem, making the exit actually take longer than without the patc=
h
>> if its priority is significantly higher, especially on smaller machines.
>
> If p need mmap_sem, p is going to sleep to wait mmap_sem. if p doesn't,
> quickly exit is good thing. In other word, task fairness is not our goal
> when oom occur.
>

Tend to agree. I didn't agree boosting of whole threads' priority.

Task fairness VS system hang is trade off. task fairness is best
effort but system hang is critical.
Also, we have tried to it.

        /*
         * We give our sacrificial lamb high priority and access to
         * all the memory it needs. That way it should be able to
         * exit() and clear out its resources quickly...
         */
        p->rt.time_slice =3D HZ;
        set_tsk_thread_flag(p, TIF_MEMDIE);

But I think above code is meaningless unless p use SCHED_RR.
So boosting of lowest RT priority with FIFO is to meet above comment's
goal, I think.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
