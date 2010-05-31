Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id AA5836B01C1
	for <linux-mm@kvack.org>; Mon, 31 May 2010 01:01:05 -0400 (EDT)
Received: by gyg4 with SMTP id 4so2657177gyg.14
        for <linux-mm@kvack.org>; Sun, 30 May 2010 22:01:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100531092133.73705339.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100528143605.7E2A.A69D9226@jp.fujitsu.com>
	<AANLkTikB-8Qu03VrA5Z0LMXM_alSV7SLqzl-MmiLmFGv@mail.gmail.com>
	<20100528145329.7E2D.A69D9226@jp.fujitsu.com>
	<20100528125305.GE11364@uudg.org>
	<20100528140623.GA11041@barrios-desktop>
	<20100528143617.GF11364@uudg.org>
	<20100528151249.GB12035@barrios-desktop>
	<20100528152842.GH11364@uudg.org>
	<20100528154549.GC12035@barrios-desktop>
	<20100528164826.GJ11364@uudg.org>
	<20100531092133.73705339.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 31 May 2010 14:01:03 +0900
Message-ID: <AANLkTikFk_HnZWPG0s_VrRkro2rruEc8OBX5KfKp_QdX@mail.gmail.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

Hi, Kame.

On Mon, May 31, 2010 at 9:21 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 28 May 2010 13:48:26 -0300
> "Luis Claudio R. Goncalves" <lclaudio@uudg.org> wrote:
>>
>> oom-killer: give the dying task rt priority (v3)
>>
>> Give the dying task RT priority so that it can be scheduled quickly and =
die,
>> freeing needed memory.
>>
>> Signed-off-by: Luis Claudio R. Gon=C3=A7alves <lgoncalv@redhat.com>
>>
>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>> index 84bbba2..2b0204f 100644
>> --- a/mm/oom_kill.c
>> +++ b/mm/oom_kill.c
>> @@ -266,6 +266,8 @@ static struct task_struct *select_bad_process(unsign=
ed long *ppoints)
>> =C2=A0 */
>> =C2=A0static void __oom_kill_task(struct task_struct *p, int verbose)
>> =C2=A0{
>> + =C2=A0 =C2=A0 struct sched_param param;
>> +
>> =C2=A0 =C2=A0 =C2=A0 if (is_global_init(p)) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 WARN_ON(1);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 printk(KERN_WARNING "tr=
ied to kill init!\n");
>> @@ -288,6 +290,8 @@ static void __oom_kill_task(struct task_struct *p, i=
nt verbose)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0* exit() and clear out its resources quickly.=
..
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> =C2=A0 =C2=A0 =C2=A0 p->time_slice =3D HZ;
>> + =C2=A0 =C2=A0 param.sched_priority =3D MAX_RT_PRIO-10;
>> + =C2=A0 =C2=A0 sched_setscheduler(p, SCHED_FIFO, &param);
>> =C2=A0 =C2=A0 =C2=A0 set_tsk_thread_flag(p, TIF_MEMDIE);
>>
>
> BTW, how about the other threads which share mm_struct ?

Could you elaborate your intention? :)

>
> Thanks,
> -Kame
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
