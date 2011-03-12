Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 205128D003A
	for <linux-mm@kvack.org>; Sat, 12 Mar 2011 14:40:17 -0500 (EST)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id p2CJeCA1015976
	for <linux-mm@kvack.org>; Sat, 12 Mar 2011 11:40:14 -0800
Received: from vxd2 (vxd2.prod.google.com [10.241.33.194])
	by kpbe16.cbf.corp.google.com with ESMTP id p2CJe1DV019194
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 12 Mar 2011 11:40:11 -0800
Received: by vxd2 with SMTP id 2so3905354vxd.8
        for <linux-mm@kvack.org>; Sat, 12 Mar 2011 11:40:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110312134341.GA27275@redhat.com>
References: <alpine.DEB.2.00.1103011108400.28110@chino.kir.corp.google.com>
	<20110303100030.B936.A69D9226@jp.fujitsu.com>
	<20110308134233.GA26884@redhat.com>
	<alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com>
	<20110309151946.dea51cde.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1103111142260.30699@chino.kir.corp.google.com>
	<20110312123413.GA18351@redhat.com>
	<20110312134341.GA27275@redhat.com>
Date: Sat, 12 Mar 2011 11:40:11 -0800
Message-ID: <AANLkTinHGSb2_jfkwx=Wjv96phzPCjBROfCTFCKi4Wey@mail.gmail.com>
Subject: Re: [PATCH 0/3] oom: TIF_MEMDIE/PF_EXITING fixes
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Andrey Vagin <avagin@openvz.org>, David Rientjes <rientjes@google.com>

Hi Oleg,

On Sat, Mar 12, 2011 at 5:43 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> On 03/12, Oleg Nesterov wrote:
>>
>> On 03/11, David Rientjes wrote:
>> >
>> > On Wed, 9 Mar 2011, Andrew Morton wrote:
>> >
>> > > If Oleg's test program cause a hang with
>> > > oom-prevent-unnecessary-oom-kills-or-kernel-panics.patch and doesn't
>> > > cause a hang without
>> > > oom-prevent-unnecessary-oom-kills-or-kernel-panics.patch then that's=
 a
>> > > big problem for
>> > > oom-prevent-unnecessary-oom-kills-or-kernel-panics.patch, no?
>> > >
>> >
>> > It's a problem, but not because of
>> > oom-prevent-unnecessary-oom-kills-or-kernel-panics.patch.
>>
>> It is, afaics. oom-killer can't ussume that a single PF_EXITING && p->mm
>> thread is going to free the memory.
>>
>> > If we don't
>> > have this patch, then we have a trivial panic when an oom kill occurs =
in a
>> > cpuset with no other eligible processes, the oom killed thread group
>> > leader exits
>>
>> It is not clear what "leader exits" actually mean. OK, perhaps you mean
>> its ->mm =3D=3D NULL.
>>
>> > but its other threads do not and they trigger oom kills
>> > themselves. =C2=A0for_each_process() does not iterate over these threa=
ds and so
>> > it finds no eligible threads to kill and then panics
>>
>> Could you explain what do you mean? No need to kill these threads, they
>> are already killed, we should wait until they all exit.
>>
>> > I'll look at Oleg's test case
>> > and see what can be done to fix that condition, but the answer isn't t=
o
>> > ignore eligible threads that can be killed.
>>
>> Once again, they are already killed. Or I do not understand what you mea=
nt.
>>
>> Could you please explain the problem in more details?
>>
>>
>> Also. Could you please look at the patches I sent?
>>
>> =C2=A0 =C2=A0 =C2=A0 [PATCH 1/1] oom_kill_task: mark every thread as TIF=
_MEMDIE
>> =C2=A0 =C2=A0 =C2=A0 [PATCH v2 1/1] select_bad_process: improve the PF_E=
XITING check
>
> Cough. And both were not right, while_each_thread(p, t) needs the properl=
y
> initialized "t". At least I warned they were not tested ;)
>
>> Note also the note about "p =3D=3D current" check. it should be fixed to=
o.
>
> I am resending the fixes above plus the new one.

I've spent much of the week building up to join in, but the more I
look around, the more I find to say or investigate, and therefore
never quite get to write the mail.  Let this be a placeholder, that I
probably disagree (in an amicable way!) with all of you, and maybe
I'll finally manage to collect my thoughts into mail later today.

I guess my main point will be that TIF_MEMDIE serves a number of
slightly different, even conflicting, purposes; and one of those
purposes, which present company seems to ignore repeatedly, is to
serialize access to final reserves of memory - as a comment by Nick in
select_bad_process() makes clear. (This is distinct from the
serialization to avoid OOM-killing rampage.)

We _might_ choose to abandon that, but if so, it should be a decision,
not an oversight.  So I cannot blindly agree with just setting
TIF_MEMDIE on more and more tasks, even if they share the same mm.  I
wonder if use of your find_lock_task_mm() in   select_bad_process()
might bring together my wish to continue serialization, David's wish
to avoid stupid panics, and your wish to avoid deadlocks.

Though any serialization has a risk of deadlock: we probably need to
weigh up how realistic different cases are.   Which brings me neatly
to your little pthread_create, ptrace proggy... I dare say you and
Kosaki and David know exactly what it's doing and why it's a problem,
but even after repeated skims of the ptrace manpage,  I'll admit to
not having a clue, nor the inclination to run and then debug it to
find out the answer.  Please, Oleg, would you mind very much
explaining it to me? I don't even know if the double pthread_create is
a vital part of the scheme, or just a typo.  I see it doesn't even
allocate any special memory, so I assume it leaves a PF_EXITING around
forever, but I couldn't quite see how (with PF_EXITING being set after
the tracehook_report_exit).  And I wonder if a similar case can be
constructed to deadlock the for_each_process version of
select_bad_process().

I worry more about someone holding a reference to the mm via /proc (I
see memory allocations after getting the mm).

Thanks; until later,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
