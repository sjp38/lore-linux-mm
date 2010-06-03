Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5B5C06B01AC
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 20:32:50 -0400 (EDT)
Received: by ywh17 with SMTP id 17so2565182ywh.1
        for <linux-mm@kvack.org>; Wed, 02 Jun 2010 17:32:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100603084829.7234.A69D9226@jp.fujitsu.com>
References: <20100601145033.2446.A69D9226@jp.fujitsu.com>
	<20100602150304.GA5326@barrios-desktop>
	<20100603084829.7234.A69D9226@jp.fujitsu.com>
Date: Thu, 3 Jun 2010 09:32:47 +0900
Message-ID: <AANLkTilBq_dRXW1u56gbqc3Z5fU1I66UiFiQbbRU_2Ur@mail.gmail.com>
Subject: Re: [PATCH 5/5] oom: dump_tasks() use find_lock_task_mm() too
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 3, 2010 at 9:06 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi
>
>> > @@ -344,35 +344,30 @@ static struct task_struct *select_bad_process(un=
signed long *ppoints,
>> > =C2=A0 */
>> > =C2=A0static void dump_tasks(const struct mem_cgroup *mem)
>> > =C2=A0{
>> > - =C2=A0 struct task_struct *g, *p;
>> > + =C2=A0 struct task_struct *p;
>> > + =C2=A0 struct task_struct *task;
>> >
>> > =C2=A0 =C2=A0 printk(KERN_INFO "[ pid ] =C2=A0 uid =C2=A0tgid total_vm=
 =C2=A0 =C2=A0 =C2=A0rss cpu oom_adj "
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0"name\n");
>> > - =C2=A0 do_each_thread(g, p) {
>> > +
>> > + =C2=A0 for_each_process(p) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct mm_struct *mm;
>> >
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (mem && !task_in_mem_cgroup(p,=
 mem))
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (is_global_init(p) || (p->flag=
s & PF_KTHREAD))
>>
>> select_bad_process needs is_global_init check to not select init as vict=
im.
>> But in this case, it is just for dumping information of tasks.
>
> But dumping oom unrelated process is useless and making confusion.
> Do you have any suggestion? Instead, adding unkillable field?

I think it's not unrelated. Of course, init process doesn't consume
lots of memory but might consume more memory than old as time goes by
or some BUG although it is unlikely.

I think whether we print information of init or not isn't a big deal.
But we have been done it until now and you are trying to change it.
At least, we need some description why you want to remove it.
Making confusion? Hmm.. I don't think it make many people confusion.

>
>
>>
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
continue;
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!thread_group_leader(p))
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (mem && !task_in_mem_cgroup(p,=
 mem))
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
continue;
>> >
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 task_lock(p);
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mm =3D p->mm;
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!mm) {
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0* total_vm and rss sizes do not exist for tasks with no
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0* mm so there's no need to report them; they can't be
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0* oom killed anyway.
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0*/
>>
>> Please, do not remove the comment for mm newbies unless you think it's u=
seless.
>
> How is this?
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 task =3D find_lock_task_=
mm(p);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!task)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 * Probably oom vs task-exiting race was happen and ->mm
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 * have been detached. thus there's no need to report them;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 * they can't be oom killed anyway.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0continue;
>

Looks good to adding story about racing. but my point was "total_vm
and rss sizes do not exist for tasks with no mm". But I don't want to
bother you due to trivial.
It depends on you. :)

Thanks, Kosaki.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
