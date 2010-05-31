Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D78CD6B01C1
	for <linux-mm@kvack.org>; Mon, 31 May 2010 03:05:50 -0400 (EDT)
Received: by iwn39 with SMTP id 39so435388iwn.14
        for <linux-mm@kvack.org>; Mon, 31 May 2010 00:05:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100531152424.739D.A69D9226@jp.fujitsu.com>
References: <20100529125136.62CA.A69D9226@jp.fujitsu.com>
	<AANLkTimg3PuUAmUUib2pdXNyEeniccLSCEvAm9jtKNji@mail.gmail.com>
	<20100531152424.739D.A69D9226@jp.fujitsu.com>
Date: Mon, 31 May 2010 16:05:48 +0900
Message-ID: <AANLkTilYtODW-8Ey2IUTT2lRR3sy0kgSOO7rN32rjvux@mail.gmail.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, balbir@linux.vnet.ibm.com, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, May 31, 2010 at 3:35 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi
>
>> Hi, Kosaki.
>>
>> On Sat, May 29, 2010 at 12:59 PM, KOSAKI Motohiro
>> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> > Hi
>> >
>> >> oom-killer: give the dying task rt priority (v3)
>> >>
>> >> Give the dying task RT priority so that it can be scheduled quickly a=
nd die,
>> >> freeing needed memory.
>> >>
>> >> Signed-off-by: Luis Claudio R. Gon=C3=A7alves <lgoncalv@redhat.com>
>> >
>> > Almostly acceptable to me. but I have two requests,
>> >
>> > - need 1) force_sig() 2)sched_setscheduler() order as Oleg mentioned
>> > - don't boost priority if it's in mem_cgroup_out_of_memory()
>>
>> Why do you want to not boost priority if it's path of memcontrol?
>>
>> If it's path of memcontrol and CONFIG_CGROUP_MEM_RES_CTLR is enabled,
>> mem_cgroup_out_of_memory will select victim task in memcg.
>> So __oom_kill_task's target task would be in memcg, I think.
>
> Yep.
> But priority boost naturally makes CPU starvation for out of the group
> processes.
> It seems to break cgroup's isolation concept.
>
>> As you and memcg guys don't complain this, I would be missing something.
>> Could you explain it? :)
>
> So, My points are,
>
> 1) Usually priority boost is wrong idea. It have various side effect, but
> =C2=A0 system wide OOM is one of exception. In such case, all tasks aren'=
t
> =C2=A0 runnable, then, the downside is acceptable.
> 2) memcg have OOM notification mechanism. If the admin need priority boos=
t,
> =C2=A0 they can do it by their OOM-daemon.

Is it possible kill the hogging task immediately when the daemon send
kill signal?
I mean we can make OOM daemon higher priority than others and it can
send signal to normal process. but when is normal process exited after
receiving kill signal from OOM daemon? Maybe it's when killed task is
executed by scheduler. It's same problem again, I think.

Kame, Do you have an idea?

> Thanks.
>
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
