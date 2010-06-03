Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 335A16B01AF
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 20:47:26 -0400 (EDT)
Received: by iwn39 with SMTP id 39so1639281iwn.14
        for <linux-mm@kvack.org>; Wed, 02 Jun 2010 17:46:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100603093548.7237.A69D9226@jp.fujitsu.com>
References: <20100603084829.7234.A69D9226@jp.fujitsu.com>
	<AANLkTilBq_dRXW1u56gbqc3Z5fU1I66UiFiQbbRU_2Ur@mail.gmail.com>
	<20100603093548.7237.A69D9226@jp.fujitsu.com>
Date: Thu, 3 Jun 2010 09:46:24 +0900
Message-ID: <AANLkTinez8RX4rADp42f03AocWe2c0zimLQ7aT65nM1d@mail.gmail.com>
Subject: Re: [PATCH 5/5] oom: dump_tasks() use find_lock_task_mm() too
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 3, 2010 at 9:41 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Thu, Jun 3, 2010 at 9:06 AM, KOSAKI Motohiro
>> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> >> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mm =3D p->mm;
>> >> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!mm) {
>> >> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> >> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0* total_vm and rss sizes do not exist for tasks with no
>> >> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0* mm so there's no need to report them; they can't be
>> >> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0* oom killed anyway.
>> >> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0*/
>> >>
>> >> Please, do not remove the comment for mm newbies unless you think it'=
s useless.
>> >
>> > How is this?
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 task =3D find_lock_ta=
sk_mm(p);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!task)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0/*
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 * Probably oom vs task-exiting race was happen and ->mm
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 * have been detached. thus there's no need to report them;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 * they can't be oom killed anyway.
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 */
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0continue;
>> >
>>
>> Looks good to adding story about racing. but my point was "total_vm
>> and rss sizes do not exist for tasks with no mm". But I don't want to
>> bother you due to trivial.
>> It depends on you. :)
>
>
> old ->mm check have two intention.
>
> =C2=A0 a) the task is kernel thread?
> =C2=A0 b) the task have alredy detached ->mm
> but a) is not strictly correct check because we should think use_mm().
> therefore we appended PF_KTHREAD check. then, here find_lock_task_mm()
> focus exiting race, I think.
>

No objection.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
