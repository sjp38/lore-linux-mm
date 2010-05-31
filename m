Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 377C76B01C1
	for <linux-mm@kvack.org>; Mon, 31 May 2010 02:09:45 -0400 (EDT)
Received: by gyg4 with SMTP id 4so2682135gyg.14
        for <linux-mm@kvack.org>; Sun, 30 May 2010 23:09:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100531145415.5e53f837.kamezawa.hiroyu@jp.fujitsu.com>
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
	<AANLkTikFk_HnZWPG0s_VrRkro2rruEc8OBX5KfKp_QdX@mail.gmail.com>
	<20100531140443.b36a4f02.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTil75ziCd6bivhpmwojvhaJ2LVxwEaEaBEmZf2yN@mail.gmail.com>
	<20100531145415.5e53f837.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 31 May 2010 15:09:41 +0900
Message-ID: <AANLkTilcuY5e1DNmLhUWfXtiQgPUafz2zRTUuTVl-88l@mail.gmail.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

On Mon, May 31, 2010 at 2:54 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 31 May 2010 14:46:05 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> On Mon, May 31, 2010 at 2:04 PM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > On Mon, 31 May 2010 14:01:03 +0900
>> > Minchan Kim <minchan.kim@gmail.com> wrote:
>> >
>> >> Hi, Kame.
>> >>
>> >> On Mon, May 31, 2010 at 9:21 AM, KAMEZAWA Hiroyuki
>> >> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> >> > On Fri, 28 May 2010 13:48:26 -0300
>> >> > "Luis Claudio R. Goncalves" <lclaudio@uudg.org> wrote:
>> >> >>
>> >> >> oom-killer: give the dying task rt priority (v3)
>> >> >>
>> >> >> Give the dying task RT priority so that it can be scheduled quickl=
y and die,
>> >> >> freeing needed memory.
>> >> >>
>> >> >> Signed-off-by: Luis Claudio R. Gon=C3=A7alves <lgoncalv@redhat.com=
>
>> >> >>
>> >> >> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>> >> >> index 84bbba2..2b0204f 100644
>> >> >> --- a/mm/oom_kill.c
>> >> >> +++ b/mm/oom_kill.c
>> >> >> @@ -266,6 +266,8 @@ static struct task_struct *select_bad_process(=
unsigned long *ppoints)
>> >> >> =C2=A0 */
>> >> >> =C2=A0static void __oom_kill_task(struct task_struct *p, int verbo=
se)
>> >> >> =C2=A0{
>> >> >> + =C2=A0 =C2=A0 struct sched_param param;
>> >> >> +
>> >> >> =C2=A0 =C2=A0 =C2=A0 if (is_global_init(p)) {
>> >> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 WARN_ON(1);
>> >> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 printk(KERN_WARNI=
NG "tried to kill init!\n");
>> >> >> @@ -288,6 +290,8 @@ static void __oom_kill_task(struct task_struct=
 *p, int verbose)
>> >> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0* exit() and clear out its resources qu=
ickly...
>> >> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> >> >> =C2=A0 =C2=A0 =C2=A0 p->time_slice =3D HZ;
>> >> >> + =C2=A0 =C2=A0 param.sched_priority =3D MAX_RT_PRIO-10;
>> >> >> + =C2=A0 =C2=A0 sched_setscheduler(p, SCHED_FIFO, &param);
>> >> >> =C2=A0 =C2=A0 =C2=A0 set_tsk_thread_flag(p, TIF_MEMDIE);
>> >> >>
>> >> >
>> >> > BTW, how about the other threads which share mm_struct ?
>> >>
>> >> Could you elaborate your intention? :)
>> >>
>> >
>> > IIUC, the purpose of rising priority is to accerate dying thread to ex=
it()
>> > for freeing memory AFAP. But to free memory, exit, all threads which s=
hare
>> > mm_struct should exit, too. I'm sorry if I miss something.
>>
>> How do we kill only some thread and what's the benefit of it?
>> I think when if some thread receives =C2=A0KILL signal, the process incl=
ude
>> the thread will be killed.
>>
> yes, so, if you want a _process_ die quickly, you have to acceralte the w=
hole
> threads on a process. Acceralating a thread in a process is not big help.

Yes.

I see the code.
oom_kill_process is called by

1. mem_cgroup_out_of_memory
2. __out_of_memory
3. out_of_memory


(1,2) calls select_bad_process which select victim task in processes
by do_each_process.
But 3 isn't In case of  CONSTRAINT_MEMORY_POLICY, it kills current.
In only the case, couldn't we pass task of process, not one of thread?

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
