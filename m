Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D66426B01B9
	for <linux-mm@kvack.org>; Fri, 28 May 2010 01:30:51 -0400 (EDT)
Received: by gyg4 with SMTP id 4so713048gyg.14
        for <linux-mm@kvack.org>; Thu, 27 May 2010 22:30:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100528134133.7E24.A69D9226@jp.fujitsu.com>
References: <20100528035147.GD11364@uudg.org>
	<20100528043339.GZ3519@balbir.in.ibm.com>
	<20100528134133.7E24.A69D9226@jp.fujitsu.com>
Date: Fri, 28 May 2010 14:30:49 +0900
Message-ID: <AANLkTilimqXmhOSEvL7DKW9rmsczkv-u2p4vwAX3aPdd@mail.gmail.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

Hi, Kosaki.

On Fri, May 28, 2010 at 1:46 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> * Luis Claudio R. Goncalves <lclaudio@uudg.org> [2010-05-28 00:51:47]:
>>
>> > @@ -382,6 +382,8 @@ static void dump_header(struct task_struct *p, gfp=
_t gfp_mask, int order,
>> > =C2=A0 */
>> > =C2=A0static void __oom_kill_task(struct task_struct *p, int verbose)
>> > =C2=A0{
>> > + =C2=A0 struct sched_param param;
>> > +
>> > =C2=A0 =C2=A0 if (is_global_init(p)) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 WARN_ON(1);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 printk(KERN_WARNING "tried t=
o kill init!\n");
>> > @@ -413,8 +415,9 @@ static void __oom_kill_task(struct task_struct *p,=
 int verbose)
>> > =C2=A0 =C2=A0 =C2=A0*/
>> > =C2=A0 =C2=A0 p->rt.time_slice =3D HZ;
>> > =C2=A0 =C2=A0 set_tsk_thread_flag(p, TIF_MEMDIE);
>> > -
>> > =C2=A0 =C2=A0 force_sig(SIGKILL, p);
>> > + =C2=A0 param.sched_priority =3D MAX_RT_PRIO-1;
>> > + =C2=A0 sched_setscheduler_nocheck(p, SCHED_FIFO, &param);
>> > =C2=A0}
>> >
>>
>> I would like to understand the visible benefits of this patch. Have
>> you seen an OOM kill tasked really get bogged down. Should this task
>> really be competing with other important tasks for run time?
>
> What you mean important? Until OOM victim task exit completely, the syste=
m have no memory.
> all of important task can't do anything.
>
> In almost kernel subsystems, automatically priority boost is really bad i=
dea because
> it may break RT task's deterministic behavior. but OOM is one of exceptio=
n. The deterministic
> was alread broken by memory starvation.

Yes or No.

IMHO, normally RT tasks shouldn't use dynamic allocation(ie,
non-deterministic functions or system calls) in place which is needed
deterministic. So memory starvation might not break real-time
deterministic.


>
> That's the reason I acked it.

>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
