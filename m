Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4FD546B0038
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 00:57:35 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id t184so19548673qke.0
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 21:57:35 -0700 (PDT)
Received: from sonic301-29.consmr.mail.bf2.yahoo.com (sonic301-29.consmr.mail.bf2.yahoo.com. [74.6.129.228])
        by mx.google.com with ESMTPS id s29si14304046qtk.103.2017.09.12.21.57.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Sep 2017 21:57:34 -0700 (PDT)
Date: Wed, 13 Sep 2017 04:51:26 +0000 (UTC)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Message-ID: <1969140653.911396.1505278286673@mail.yahoo.com>
In-Reply-To: <80c9060f-bf80-51fb-39c0-b36f273c0c9c@yandex-team.ru>
References: <149570810989.203600.9492483715840752937.stgit@buzz> <20170605085011.GJ9248@dhcp22.suse.cz> <80c9060f-bf80-51fb-39c0-b36f273c0c9c@yandex-team.ru>
Subject: Re: [PATCH v2] mm/oom_kill: count global and memory cgroup oom
 kills
MIME-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_Part_911395_232869749.1505278286671"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Roman Guschin <guroan@gmail.com>, David Rientjes <rientjes@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

------=_Part_911395_232869749.1505278286671
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable



Hi,

I have submitted a similar patch 2 years ago (Oct/2015).
But at that time the patch was rejected.
Here is the history:
https://lkml.org/lkml/2015/10/1/372

Now I see the similar patch got accepted. At least the initial idea and the=
 objective were same.=C2=A0
Even I were not included here.
 On one side I feel happy that my initial idea got accepted now.But on the =
other side it really hurts :(

Thanks,Pintu
=20
 On Monday 5 June 2017, 7:57:57 PM IST, Konstantin Khlebnikov <khlebnikov@y=
andex-team.ru> wrote:=20


On 05.06.2017 11:50, Michal Hocko wrote:
> On Thu 25-05-17 13:28:30, Konstantin Khlebnikov wrote:
>> Show count of oom killer invocations in /proc/vmstat and count of
>> processes killed in memory cgroup in knob "memory.events"
>> (in memory.oom_control for v1 cgroup).
>>
>> Also describe difference between "oom" and "oom_kill" in memory
>> cgroup documentation. Currently oom in memory cgroup kills tasks
>> iff shortage has happened inside page fault.
>>
>> These counters helps in monitoring oom kills - for now
>> the only way is grepping for magic words in kernel log.
>=20
> Yes this is less than optimal and the counter sounds like a good step
> forward. I have 2 comments to the patch though.
>=20
> [...]
>=20
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 899949bbb2f9..42296f7001da 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -556,8 +556,11 @@ static inline void mem_cgroup_count_vm_event(struct=
 mm_struct *mm,
>>=C2=A0=20
>>=C2=A0 =C2=A0=C2=A0=C2=A0 rcu_read_lock();
>>=C2=A0 =C2=A0=C2=A0=C2=A0 memcg =3D mem_cgroup_from_task(rcu_dereference(=
mm->owner));
>> -=C2=A0=C2=A0=C2=A0 if (likely(memcg))
>> +=C2=A0=C2=A0=C2=A0 if (likely(memcg)) {
>>=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 this_cpu_inc(memcg->stat->ev=
ents[idx]);
>> +=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 if (idx =3D=3D OOM_KILL)
>> +=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 cgroup_file_no=
tify(&memcg->events_file);
>> +=C2=A0=C2=A0=C2=A0 }
>>=C2=A0 =C2=A0=C2=A0=C2=A0 rcu_read_unlock();
>=20
> Well, this is ugly. I see how you want to share the global counter and
> the memcg event which needs the notification. But I cannot say this
> would be really easy to follow. Can we have at least a comment in
> memcg_event_item enum definition?

Yep, this is a little bit ugly.
But this funciton is static-inline and idx always constant so resulting cod=
e is fine.

>=20
>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>> index 04c9143a8625..dd30a045ef5b 100644
>> --- a/mm/oom_kill.c
>> +++ b/mm/oom_kill.c
>> @@ -876,6 +876,11 @@ static void oom_kill_process(struct oom_control *oc=
, const char *message)
>>=C2=A0 =C2=A0=C2=A0=C2=A0 /* Get a reference to safely compare mm after t=
ask_unlock(victim) */
>>=C2=A0 =C2=A0=C2=A0=C2=A0 mm =3D victim->mm;
>>=C2=A0 =C2=A0=C2=A0=C2=A0 mmgrab(mm);
>> +
>> +=C2=A0=C2=A0=C2=A0 /* Raise event before sending signal: reaper must se=
e this */
>> +=C2=A0=C2=A0=C2=A0 count_vm_event(OOM_KILL);
>> +=C2=A0=C2=A0=C2=A0 mem_cgroup_count_vm_event(mm, OOM_KILL);
>> +
>>=C2=A0 =C2=A0=C2=A0=C2=A0 /*
>>=C2=A0 =C2=A0=C2=A0=C2=A0 * We should send SIGKILL before setting TIF_MEM=
DIE in order to prevent
>>=C2=A0 =C2=A0=C2=A0=C2=A0 * the OOM victim from depleting the memory rese=
rves from the user
>=20
> Why don't you count tasks which share mm with the oom victim?

Yes, this makes sense. But these kills are not logged thus counter will dif=
fers from logged events.
Also these tasks might live in different cgroups, so counting to mm owner i=
sn't correct.


> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 0e2c925e7826..9a95947a60ba 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -924,6 +924,8 @@ static void oom_kill_process(struct oom_control *oc, =
const char *message)
>=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 */
>=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 if (unlikely(p->flags & PF_KT=
HREAD))
>=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 continue;
> +=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 count_vm_event(OOM_KILL);
> +=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 count_memcg_event_mm(mm, OOM_KILL)=
;
>=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 do_send_sig_info(SIGKILL, SEN=
D_SIG_FORCED, p, true);
>=C2=A0 =C2=A0=C2=A0=C2=A0 }
>=C2=A0 =C2=A0=C2=A0=C2=A0 rcu_read_unlock();
>=20
> Other than that looks good to me.
> Acked-by: Michal Hocko <mhocko@suse.com>
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.=C2=A0 For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>


------=_Part_911395_232869749.1505278286671
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<html xmlns=3D"http://www.w3.org/1999/xhtml" xmlns:v=3D"urn:schemas-microso=
ft-com:vml" xmlns:o=3D"urn:schemas-microsoft-com:office:office"><head><!--[=
if gte mso 9]><xml><o:OfficeDocumentSettings><o:AllowPNG/><o:PixelsPerInch>=
96</o:PixelsPerInch></o:OfficeDocumentSettings></xml><![endif]--></head><bo=
dy><div style=3D"font-family:courier new, courier, monaco, monospace, sans-=
serif;font-size:16px;"><br><br>Hi,<br><br>I have submitted a similar patch =
2 years ago (Oct/2015).<br>But at that time the patch was rejected.<br>Here=
 is the history:<br>https://lkml.org/lkml/2015/10/1/372<br><br>Now I see th=
e similar patch got accepted. At least the initial idea and the objective w=
ere same.&nbsp;<br>Even I were not included here.<br> <div>On one side I fe=
el happy that my initial idea got accepted now.</div><div>But on the other =
side it really hurts :(</div><div><br></div><div><br></div><div>Thanks,</di=
v><div>Pintu</div><div><br></div> <br> On Monday 5 June 2017, 7:57:57 PM IS=
T, Konstantin Khlebnikov &lt;khlebnikov@yandex-team.ru&gt; wrote: <br><br><=
br>On 05.06.2017 11:50, Michal Hocko wrote:<br>&gt; On Thu 25-05-17 13:28:3=
0, Konstantin Khlebnikov wrote:<br>&gt;&gt; Show count of oom killer invoca=
tions in /proc/vmstat and count of<br>&gt;&gt; processes killed in memory c=
group in knob "memory.events"<br>&gt;&gt; (in memory.oom_control for v1 cgr=
oup).<br>&gt;&gt;<br>&gt;&gt; Also describe difference between "oom" and "o=
om_kill" in memory<br>&gt;&gt; cgroup documentation. Currently oom in memor=
y cgroup kills tasks<br>&gt;&gt; iff shortage has happened inside page faul=
t.<br>&gt;&gt;<br>&gt;&gt; These counters helps in monitoring oom kills - f=
or now<br>&gt;&gt; the only way is grepping for magic words in kernel log.<=
br>&gt; <br>&gt; Yes this is less than optimal and the counter sounds like =
a good step<br>&gt; forward. I have 2 comments to the patch though.<br>&gt;=
 <br>&gt; [...]<br>&gt; <br>&gt;&gt; diff --git a/include/linux/memcontrol.=
h b/include/linux/memcontrol.h<br>&gt;&gt; index 899949bbb2f9..42296f7001da=
 100644<br>&gt;&gt; --- a/include/linux/memcontrol.h<br>&gt;&gt; +++ b/incl=
ude/linux/memcontrol.h<br>&gt;&gt; @@ -556,8 +556,11 @@ static inline void =
mem_cgroup_count_vm_event(struct mm_struct *mm,<br>&gt;&gt;&nbsp; <br>&gt;&=
gt;&nbsp; &nbsp;&nbsp;&nbsp; rcu_read_lock();<br>&gt;&gt;&nbsp; &nbsp;&nbsp=
;&nbsp; memcg =3D mem_cgroup_from_task(rcu_dereference(mm-&gt;owner));<br>&=
gt;&gt; -&nbsp;&nbsp;&nbsp; if (likely(memcg))<br>&gt;&gt; +&nbsp;&nbsp;&nb=
sp; if (likely(memcg)) {<br>&gt;&gt;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&=
nbsp; this_cpu_inc(memcg-&gt;stat-&gt;events[idx]);<br>&gt;&gt; +&nbsp;&nbs=
p;&nbsp; &nbsp;&nbsp;&nbsp; if (idx =3D=3D OOM_KILL)<br>&gt;&gt; +&nbsp;&nb=
sp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; cgroup_file_notify(&amp;mem=
cg-&gt;events_file);<br>&gt;&gt; +&nbsp;&nbsp;&nbsp; }<br>&gt;&gt;&nbsp; &n=
bsp;&nbsp;&nbsp; rcu_read_unlock();<br>&gt; <br>&gt; Well, this is ugly. I =
see how you want to share the global counter and<br>&gt; the memcg event wh=
ich needs the notification. But I cannot say this<br>&gt; would be really e=
asy to follow. Can we have at least a comment in<br>&gt; memcg_event_item e=
num definition?<br><br>Yep, this is a little bit ugly.<br>But this funciton=
 is static-inline and idx always constant so resulting code is fine.<br><br=
>&gt; <br>&gt;&gt; diff --git a/mm/oom_kill.c b/mm/oom_kill.c<br>&gt;&gt; i=
ndex 04c9143a8625..dd30a045ef5b 100644<br>&gt;&gt; --- a/mm/oom_kill.c<br>&=
gt;&gt; +++ b/mm/oom_kill.c<br>&gt;&gt; @@ -876,6 +876,11 @@ static void oo=
m_kill_process(struct oom_control *oc, const char *message)<br>&gt;&gt;&nbs=
p; &nbsp;&nbsp;&nbsp; /* Get a reference to safely compare mm after task_un=
lock(victim) */<br>&gt;&gt;&nbsp; &nbsp;&nbsp;&nbsp; mm =3D victim-&gt;mm;<=
br>&gt;&gt;&nbsp; &nbsp;&nbsp;&nbsp; mmgrab(mm);<br>&gt;&gt; +<br>&gt;&gt; =
+&nbsp;&nbsp;&nbsp; /* Raise event before sending signal: reaper must see t=
his */<br>&gt;&gt; +&nbsp;&nbsp;&nbsp; count_vm_event(OOM_KILL);<br>&gt;&gt=
; +&nbsp;&nbsp;&nbsp; mem_cgroup_count_vm_event(mm, OOM_KILL);<br>&gt;&gt; =
+<br>&gt;&gt;&nbsp; &nbsp;&nbsp;&nbsp; /*<br>&gt;&gt;&nbsp; &nbsp;&nbsp;&nb=
sp; * We should send SIGKILL before setting TIF_MEMDIE in order to prevent<=
br>&gt;&gt;&nbsp; &nbsp;&nbsp;&nbsp; * the OOM victim from depleting the me=
mory reserves from the user<br>&gt; <br>&gt; Why don't you count tasks whic=
h share mm with the oom victim?<br><br>Yes, this makes sense. But these kil=
ls are not logged thus counter will differs from logged events.<br>Also the=
se tasks might live in different cgroups, so counting to mm owner isn't cor=
rect.<br><br><br>&gt; diff --git a/mm/oom_kill.c b/mm/oom_kill.c<br>&gt; in=
dex 0e2c925e7826..9a95947a60ba 100644<br>&gt; --- a/mm/oom_kill.c<br>&gt; +=
++ b/mm/oom_kill.c<br>&gt; @@ -924,6 +924,8 @@ static void oom_kill_process=
(struct oom_control *oc, const char *message)<br>&gt;&nbsp; &nbsp;&nbsp;&nb=
sp; &nbsp;&nbsp;&nbsp; */<br>&gt;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbs=
p; if (unlikely(p-&gt;flags &amp; PF_KTHREAD))<br>&gt;&nbsp; &nbsp;&nbsp;&n=
bsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; continue;<br>&gt; +&nbsp;&nbsp;&=
nbsp; &nbsp;&nbsp;&nbsp; count_vm_event(OOM_KILL);<br>&gt; +&nbsp;&nbsp;&nb=
sp; &nbsp;&nbsp;&nbsp; count_memcg_event_mm(mm, OOM_KILL);<br>&gt;&nbsp; &n=
bsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; do_send_sig_info(SIGKILL, SEND_SIG_FORC=
ED, p, true);<br>&gt;&nbsp; &nbsp;&nbsp;&nbsp; }<br>&gt;&nbsp; &nbsp;&nbsp;=
&nbsp; rcu_read_unlock();<br>&gt; <br>&gt; Other than that looks good to me=
.<br>&gt; Acked-by: Michal Hocko &lt;mhocko@suse.com&gt;<br>&gt; <br><br>--=
<br>To unsubscribe, send a message with 'unsubscribe linux-mm' in<br>the bo=
dy to majordomo@kvack.org.&nbsp; For more info on Linux MM,<br>see: http://=
www.linux-mm.org/ .<br>Don't email: &lt;a href=3Dmailto:"dont@kvack.org"&gt=
; email@kvack.org &lt;/a&gt;<br><br></div></body></html>
------=_Part_911395_232869749.1505278286671--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
