Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 75DC58D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 21:27:12 -0400 (EDT)
Received: by iwg8 with SMTP id 8so5174160iwg.14
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 18:27:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110329101234.54d5d45a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110324182240.5fe56de2.kamezawa.hiroyu@jp.fujitsu.com>
	<20110324105222.GA2625@barrios-desktop>
	<20110325090411.56c5e5b2.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=f3gu7-8uNiT4qz6s=BOhto5s=7g@mail.gmail.com>
	<20110325115453.82a9736d.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTim3fFe3VzvaWRwzaCT6aRd-yeyfiQ@mail.gmail.com>
	<20110326023452.GA8140@google.com>
	<AANLkTi=ng9vwoMJ=tseWwTsXMf9XZkMKUexcpEmQ45M_@mail.gmail.com>
	<20110328162137.GA2904@barrios-desktop>
	<20110329085033.6e20868e.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTimFJ_kSkrVc9ZsNfUJTioqrvFQQpA@mail.gmail.com>
	<20110329093257.73357bbc.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTin_fE2qZ2yZ9DRo2W_Bj8P+CGWC=A@mail.gmail.com>
	<20110329101234.54d5d45a.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 29 Mar 2011 10:27:08 +0900
Message-ID: <BANLkTi=pMapbVoUO6+7nUEg1bY4fb844-A@mail.gmail.com>
Subject: Re: [PATCH 0/4] forkbomb killer
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rientjes@google.com" <rientjes@google.com>, Andrey Vagin <avagin@openvz.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On Tue, Mar 29, 2011 at 10:12 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 29 Mar 2011 10:12:31 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> On Tue, Mar 29, 2011 at 9:32 AM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > On Tue, 29 Mar 2011 09:24:30 +0900
>> > Minchan Kim <minchan.kim@gmail.com> wrote:
>> >
>> >> On Tue, Mar 29, 2011 at 8:50 AM, KAMEZAWA Hiroyuki
>> >> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> >> > On Tue, 29 Mar 2011 01:21:37 +0900
>> >> > Minchan Kim <minchan.kim@gmail.com> wrote:
>> >> >
>> >> >> On Sat, Mar 26, 2011 at 05:48:45PM +0900, Hiroyuki Kamezawa wrote:
>> >> >> > 2011/3/26 Michel Lespinasse <walken@google.com>:
>> >> >> > > On Fri, Mar 25, 2011 at 01:05:50PM +0900, Minchan Kim wrote:
>> >> >> > >> Okay. Each approach has a pros and cons and at least, now any=
one
>> >> >> > >> doesn't provide any method and comments but I agree it is nee=
ded(ex,
>> >> >> > >> careless and lazy admin could need it strongly). Let us wait =
a little
>> >> >> > >> bit more. Maybe google guys or redhat/suse guys would have a =
opinion.
>> >> >> > >
>> >> >> > > I haven't heard of fork bombs being an issue for us (and it's =
not been
>> >> >> > > for me on my desktop, either).
>> >> >> > >
>> >> >> > > Also, I want to point out that there is a classical userspace =
solution
>> >> >> > > for this, as implemented by killall5 for example. One can do
>> >> >> > > kill(-1, SIGSTOP) to stop all processes that they can send
>> >> >> > > signals to (except for init and itself). Target processes
>> >> >> > > can never catch or ignore the SIGSTOP. This stops the fork bom=
b
>> >> >> > > from causing further damage. Then, one can look at the process
>> >> >> > > tree and do whatever is appropriate - including killing by uid=
,
>> >> >> > > by cgroup or whatever policies one wants to implement in users=
pace.
>> >> >> > > Finally, the remaining processes can be restarted using SIGCON=
T.
>> >> >> > >
>> >> >> >
>> >> >> > Can that solution work even under OOM situation without new logi=
n/commands ?
>> >> >> > Please show us your solution, how to avoid Andrey's Bomb =C2=A0w=
ith your way.
>> >> >> > Then, we can add Documentation, at least. Or you can show us you=
r tool.
>> >> >> >
>> >> >> > Maybe it is....
>> >> >> > - running as a daemon. (because it has to lock its work memory b=
efore OOM.)
>> >> >> > - mlockall its own memory to work under OOM.
>> >> >> > - It can show process tree of users/admin or do all in automatic=
 way
>> >> >> > with user's policy.
>> >> >> > - tell us which process is guilty.
>> >> >> > - wakes up automatically when OOM happens.....IOW, OOM should ha=
ve some notifier
>> >> >> > =C2=A0 to userland.
>> >> >> > - never allocate any memory at running. (maybe it can't use libc=
.)
>> >> >> > - never be blocked by any locks, for example, some other task's =
mmap_sem.
>> >> >> > =C2=A0 One of typical mistakes of admins at OOM is typing 'ps' t=
o see what
>> >> >> > happens.....
>> >> >> > - Can be used even with GUI system, which can't show console.
>> >> >>
>> >> >> Hi Kame,
>> >> >>
>> >> >> I am worried about run-time cost.
>> >> >> Should we care of mistake of users for robustness of OS?
>> >> >> Mostly right but we can't handle all mistakes of user so we need a=
dmin.
>> >> >> For exampe, what happens if admin execute "rm -rf /"?
>> >> >> For avoiding it, we get a solution "backup" about critical data.
>> >> >>
>> >> >
>> >> > Then, my patch is configurable and has control knobs....never invas=
ive for
>> >> > people who don't want it. And simple and very low cost. It will hav=
e
>> >> > no visible performance/resource usage impact for usual guys.
>> >> >
>> >> >
>> >> >
>> >> >> In the same manner, if the system is very critical of forkbomb,
>> >> >> admin should consider it using memcg, virtualization, ulimit and s=
o on.
>> >> >> If he don't want it, he should become a hard worker who have to
>> >> >> cross over other building to reboot it. Although he is a diligent =
man,
>> >> >> Reboot isn't good. So I suggest following patch which is just RFC.
>> >> >> For making formal patch, I have to add more comment and modify sys=
rq.txt.
>> >> >>
>> >> >
>> >> > For me, sysrq is of-no-use as I explained.
>> >>
>> >> Go to other building and new login?
>> >>
>> > I cannot login when the system is near happens.
>>
>> I understand so I said your solution would be a last resort.
>>
>> >
>> >> I think if server is important on such problem, it should have a solu=
tion.
>> >> The solution can be careful admin step or console with serial for
>> >> sysrq step or your forkbomb killer. We have been used sysrq with loca=
l
>> >> solution of last resort. In such context, sysrq solution ins't bad, I
>> >> think.
>> >>
>> >
>> > Mine works with Sysrq-f and this works poorly than mine.
>> >
>> >> If you can't provide 1 and 2, your forkbomb killer would be a last re=
sort.
>> >> But someone can solve the problem in just careful admin or sysrq.
>> >> In that case, the user can disable forkbomb killer then it doesn't
>> >> affect system performance at all.
>> >> So maybe It could be separate topic.
>> >>
>> >> >
>> >> >> From 51bec44086a6b6c0e56ea978a2eb47e995236b47 Mon Sep 17 00:00:00 =
2001
>> >> >> From: Minchan Kim <minchan.kim@gmail.com>
>> >> >> Date: Tue, 29 Mar 2011 00:52:20 +0900
>> >> >> Subject: [PATCH] [RFC] Prevent livelock by forkbomb
>> >> >>
>> >> >> Recently, We discussed how to prevent forkbomb.
>> >> >> The thing is a trade-off between cost VS effect.
>> >> >>
>> >> >> Forkbomb is a _race_ case which happes by someone's mistake
>> >> >> so if we have to pay cost in fast path(ex, fork, exec, exit),
>> >> >> It's a not good.
>> >> >>
>> >> >> Now, sysrq + I kills all processes. When I tested it, I still
>> >> >> need rebooting to work my system really well(ex, x start)
>> >> >> although console works. I don't know why we need such sysrq(kill
>> >> >> all processes and then what we can do?)
>> >> >>
>> >> >> So I decide to change sysrq + I to meet our goal which prevent
>> >> >> forkbomb. The rationale is following as.
>> >> >>
>> >> >> Forkbomb means somethings makes repeately tasks in a short time so
>> >> >> system don't have a free page then it become almost livelock state=
.
>> >> >> This patch uses the characteristc of forkbomb.
>> >> >>
>> >> >> When you push sysrq + I, it kills recent created tasks.
>> >> >> (In this version, 1 minutes). Maybe all processes included
>> >> >> forkbomb tasks are killed. If you can't get normal state of system
>> >> >> after you push sysrq + I, you can try one more. It can kill futher
>> >> >> recent tasks(ex, 2 minutes).
>> >> >>
>> >> >> You can continue to do it until your system becomes normal state.
>> >> >>
>> >> >> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> >> >> ---
>> >> >> =C2=A0drivers/tty/sysrq.c =C2=A0 | =C2=A0 45 +++++++++++++++++++++=
+++++++++++++++++++++---
>> >> >> =C2=A0include/linux/sched.h | =C2=A0 =C2=A06 ++++++
>> >> >> =C2=A02 files changed, 48 insertions(+), 3 deletions(-)
>> >> >>
>> >> >> diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
>> >> >> index 81f1395..6fb7e18 100644
>> >> >> --- a/drivers/tty/sysrq.c
>> >> >> +++ b/drivers/tty/sysrq.c
>> >> >> @@ -329,6 +329,45 @@ static void send_sig_all(int sig)
>> >> >> =C2=A0 =C2=A0 =C2=A0 }
>> >> >> =C2=A0}
>> >> >>
>> >> >> +static void send_sig_recent(int sig)
>> >> >> +{
>> >> >> + =C2=A0 =C2=A0 struct task_struct *p;
>> >> >> + =C2=A0 =C2=A0 unsigned long task_jiffies, last_jiffies =3D 0;
>> >> >> + =C2=A0 =C2=A0 bool kill =3D false;
>> >> >> +
>> >> >> +retry:
>> >> >
>> >> > you need tasklist lock for scanning reverse.
>> >>
>> >> Okay. I will look at it.
>> >>
>> >> >
>> >> >> + =C2=A0 =C2=A0 for_each_process_reverse(p) {
>> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (p->mm && !is_globa=
l_init(p) && !fatal_signal_pending(p)) {
>> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 /* recent created task */
>> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 last_jiffies =3D timeval_to_jiffies(p->real_start_time);
>> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 force_sig(sig, p);
>> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 break;
>> >> >
>> >> > why break ? you need to kill all youngers. And what is the relation=
ship with below ?
>> >>
>> >> It's for selecting recent _youngest_ task which are not kthread, not
>> >> init, not handled by below loop. In below loop, it start to send KILL
>> >> signal processes which are created within 1 minutes from _youngest_
>> >> process creation time.
>> >>
>> >> >
>> >> >
>> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> >> >> + =C2=A0 =C2=A0 }
>> >> >> +
>> >> >> + =C2=A0 =C2=A0 for_each_process_reverse(p) {
>> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (p->mm && !is_globa=
l_init(p)) {
>> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 task_jiffies =3D timeval_to_jiffies(p->real_start_time);
>> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 /*
>> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* Kill all processes which are created recenlty
>> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* (ex, 1 minutes)
>> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0*/
>> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (task_jiffies > (last_jiffies - 60 * HZ)) {
>> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 force_sig(sig, p);
>> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 kill =3D true;
>> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 }
>> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 else
>> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> >> >> + =C2=A0 =C2=A0 }
>> >> >> +
>> >> >> + =C2=A0 =C2=A0 /*
>> >> >> + =C2=A0 =C2=A0 =C2=A0* If we can't kill anything, restart with ne=
xt group.
>> >> >> + =C2=A0 =C2=A0 =C2=A0*/
>> >> >> + =C2=A0 =C2=A0 if (!kill)
>> >> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto retry;
>> >> >> +}
>> >> >
>> >> > This is not useful under OOM situation, we cannot use 'jiffies' to =
find younger tasks
>> >> > because "memory reclaim-> livelock" can take some amount of minutes=
 very easily.
>> >> > So, I used other metrics. I think you do the same mistake I made be=
fore,
>> >> > this doesn't work.
>> >>
>> >> As far as I understand right, p->real_start_time is create time, not =
jiffies.
>> >> What I want is that kill all processes created recently, not all
>> >> process like old sysrq + I.
>> >>
>> >> Am I miss something?
>> >>
>> > When you run 'make -j' or 'Andrey's case' with "swap". You'll see 1min=
utes is too
>> > short and no task will be killed.
>> >
>> > To determine this 60*HZ is diffuclut. I think no one cannot detemine t=
his.
>> > 1 minute is too short, 10 minutes are too long. So, I used a different=
 manner,
>> > which seems to work well.
>>
>> Okay. I can handle it. How about this?
>>
>> retry:
>> old_time =3D yougest_task->start_time;
>> for_each_process_reverse(p) {
>> =C2=A0 =C2=A0 =C2=A0 time =3D p->start_time;
>> =C2=A0 =C2=A0 =C2=A0 if (time > old_time - 60 * HZ)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 kill(p);
>> }
>>
>> /*
>> =C2=A0* If user push sysrq within 1 minutes from last again,
>> =C2=A0* we kill processes more.
>> =C2=A0*/
>> if (call_time < (now - 60 * HZ))
>> =C2=A0 =C2=A0 =C2=A0 goto retry;
>>
>> call_time =3D now;
>> return;
>>
>> So whenever user push sysrq, older tasks would be killed and at last,
>> root forkbomb task would be killed.
>>
>
> Maybe good for a single user system and it can send Sysrq.
> But I myself not very excited with this new feature becasuse I need to
> run to push Sysrq ....
>
> Please do as you like, I think the idea itself is interesting.
> But I love some automatic ones. I do other jobs.

Okay. Thanks for the comment, Kame.

I hope Andrew or someone gives feedback forkbomb problem itself before
diving into this.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
