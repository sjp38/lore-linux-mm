Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CEE016B0078
	for <linux-mm@kvack.org>; Mon,  8 Feb 2010 20:24:47 -0500 (EST)
Received: by pzk8 with SMTP id 8so5171981pzk.22
        for <linux-mm@kvack.org>; Mon, 08 Feb 2010 17:24:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100209093246.36c50bae.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100205093932.1dcdeb5f.kamezawa.hiroyu@jp.fujitsu.com>
	 <28c262361002050830m7519f1c3y8860540708527fc0@mail.gmail.com>
	 <20100209093246.36c50bae.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 9 Feb 2010 10:24:45 +0900
Message-ID: <28c262361002081724l1b64e316v3141fb4567dbf905@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix oom killer kills a task in other
	cgroup
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Tue, Feb 9, 2010 at 9:32 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Sat, 6 Feb 2010 01:30:49 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> Hi, Kame.
>>
>> On Fri, Feb 5, 2010 at 9:39 AM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > Please take this patch in different context with recent discussion.
>> > This is a quick-fix for a terrible bug.
>> >
>> > This patch itself is against mmotm but can be easily applied to mainli=
ne or
>> > stable tree, I think. (But I don't CC stable tree until I get ack.)
>> >
>> > =3D=3D
>> > Now, oom-killer kills process's chidlren at first. But this means
>> > a child in other cgroup can be killed. But it's not checked now.
>> >
>> > This patch fixes that.
>> >
>> > CC: Balbir Singh <balbir@linux.vnet.ibm.com>
>> > CC: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> > ---
>> > =C2=A0mm/oom_kill.c | =C2=A0 =C2=A03 +++
>> > =C2=A01 file changed, 3 insertions(+)
>> >
>> > Index: mmotm-2.6.33-Feb03/mm/oom_kill.c
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > --- mmotm-2.6.33-Feb03.orig/mm/oom_kill.c
>> > +++ mmotm-2.6.33-Feb03/mm/oom_kill.c
>> > @@ -459,6 +459,9 @@ static int oom_kill_process(struct task_
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0list_for_each_entry(c, &p->children, siblin=
g) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (c->mm =3D=
=3D p->mm)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0continue;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Children may be =
in other cgroup */
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (mem && !task_in=
_mem_cgroup(c, mem))
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 continue;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!oom_kill_t=
ask(c))
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0return 0;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> >
>> > --
>>
>> I am worried about latency of OOM at worst case.
>> I mean that task_in_mem_cgroup calls task_lock of child.
>> We have used task_lock in many place.
>> Some place task_lock hold and then other locks.
>> For example, exit_fs held task_lock and try to hold write_lock of fs->lo=
ck.
>> If child already hold task_lock and wait to write_lock of fs->lock, OOM =
latency
>> is dependent of fs->lock.
>>
>> I am not sure how many usecase is also dependent of other locks.
>> If it is not as is, we can't make sure in future.
>>
>> So How about try_task_in_mem_cgroup?
>> If we can't hold task_lock, let's continue next child.
>>
> It's recommended not to use trylock in unclear case.
>
> Then, I think possible replacement will be not-to-use any lock in
> task_in_mem_cgroup. In my short consideration, I don't think task_lock
> is necessary if we can add some tricks and memory barrier.
>
> Please let this patch to go as it is because this is an obvious bug fix
> and give me time.

I think it's not only a latency problem of OOM but it is also a
problem of deadlock.
We can't expect child's lock state in oom_kill_process.

So if you can remove lock like below your suggestion, I am OKAY.

>
> Now, I think of following.
> This makes use of the fact mm->owner is changed only at _exit() of the ow=
ner.
> If there is a race with _exit() and mm->owner is racy, the oom selection
> itself was racy and bad.

It seems to make sense to me.

> =3D=3D
> int task_in_mem_cgroup_oom(struct task_struct *tsk, struct mem_cgroup *me=
m)
> {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mm_struct *mm;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct task_struct *tsk;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int ret =3D 0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mm =3D tsk->mm;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!mm)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * we are not interested in tasks other than o=
wner. mm->owner is
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * updated when the owner task exits. If the o=
wner is exiting now
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * (and race with us), we may miss.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (rcu_dereference(mm->owner) !=3D tsk)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;

Yes. In this case, OOM killer can wait a few seconds until this task is exi=
ted.
If we don't do that, we could kill other innocent task.

> =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_read_lock();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* while this task is alive, this task is the =
owner */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (mem =3D=3D mem_cgroup_from_task(tsk))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D 1;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_read_unlock();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
> }
> =3D=3D
> Hmm, it seems no memory barrier is necessary.
>
> Does anyone has another idea ?
>
> Thanks,
> -Kame
>
>
>
>
>
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
