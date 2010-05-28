Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0490B6B01B6
	for <linux-mm@kvack.org>; Fri, 28 May 2010 03:52:25 -0400 (EDT)
Received: by ywh33 with SMTP id 33so558704ywh.11
        for <linux-mm@kvack.org>; Fri, 28 May 2010 00:52:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100528145329.7E2D.A69D9226@jp.fujitsu.com>
References: <20100528143605.7E2A.A69D9226@jp.fujitsu.com>
	<AANLkTikB-8Qu03VrA5Z0LMXM_alSV7SLqzl-MmiLmFGv@mail.gmail.com>
	<20100528145329.7E2D.A69D9226@jp.fujitsu.com>
Date: Fri, 28 May 2010 16:52:23 +0900
Message-ID: <AANLkTinLN0ex0uvwA_tohv7MSLHv8i8Mcr96va1C4Md-@mail.gmail.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, May 28, 2010 at 2:59 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> RT Task
>>
>> void non-RT-function()
>> {
>> =C2=A0 =C2=A0system call();
>> =C2=A0 =C2=A0buffer =3D malloc();
>> =C2=A0 =C2=A0memset(buffer);
>> }
>> /*
>> =C2=A0* We make sure this function must be executed in some millisecond
>> =C2=A0*/
>> void RT-function()
>> {
>> =C2=A0 =C2=A0some calculation(); <- This doesn't have no dynamic charact=
eristic
>> }
>> int main()
>> {
>> =C2=A0 =C2=A0non-RT-function();
>> =C2=A0 =C2=A0/* This function make sure RT-function cannot preempt by ot=
hers */
>> =C2=A0 =C2=A0set_RT_max_high_priority();
>> =C2=A0 =C2=A0RT-function A();
>> =C2=A0 =C2=A0set_normal_priority();
>> =C2=A0 =C2=A0non-RT-function();
>> }
>>
>> We don't want realtime in whole function of the task. What we want is
>> just RT-function A.
>> Of course, current Linux cannot make perfectly sure RT-functionA can
>> not preempt by others.
>> That's because some interrupt or exception happen. But RT-function A
>> doesn't related to any dynamic characteristic. What can justify to
>> preempt RT-function A by other processes?
>
> As far as my observation, RT-function always have some syscall. because p=
ure
> calculation doesn't need deterministic guarantee. But _if_ you are really
> using such priority design. I'm ok maximum NonRT priority instead maximum
> RT priority too.

Hmm. It's just example. but it would be not good exmaple.
Let's change it with this.

void RT-function()
{
     int result =3D some calculation(); <- This doesn't have no dynamic
characteristic
     *mmap_base =3D result; <-- mmap_base is mapped by GPIO device.
}

Could we allow preemption of this RT function due to other task's
memory pressure?
Of course, Linux is not Hard RT featured OS, I think. So I thinks it
is a policy problem.
If we think system memory pressure is more important than RT task and
we _all_ agree such policy, we can allow it.

But I don't hope it.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
