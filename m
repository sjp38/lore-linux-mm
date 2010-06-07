Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 715676B0071
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 09:49:31 -0400 (EDT)
Received: by iwn2 with SMTP id 2so1520408iwn.14
        for <linux-mm@kvack.org>; Mon, 07 Jun 2010 06:49:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100607125828.GW4603@balbir.in.ibm.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006061521310.32225@chino.kir.corp.google.com>
	<20100607125828.GW4603@balbir.in.ibm.com>
Date: Mon, 7 Jun 2010 22:49:29 +0900
Message-ID: <AANLkTilNvqKqjiKUdKRjILBiTxy5L7-IpS4dTSzjzPDJ@mail.gmail.com>
Subject: Re: [patch 02/18] oom: introduce find_lock_task_mm() to fix !mm false
	positives
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Balbir.

On Mon, Jun 7, 2010 at 9:58 PM, Balbir Singh <balbir@linux.vnet.ibm.com> wr=
ote:
> * David Rientjes <rientjes@google.com> [2010-06-06 15:34:03]:
>
>> From: Oleg Nesterov <oleg@redhat.com>
>>
>> Almost all ->mm =3D=3D NUL checks in oom_kill.c are wrong.
>
> typo should be NULL
>
>>
>> The current code assumes that the task without ->mm has already
>> released its memory and ignores the process. However this is not
>> necessarily true when this process is multithreaded, other live
>> sub-threads can use this ->mm.
>>
>> - Remove the "if (!p->mm)" check in select_bad_process(), it is
>> =C2=A0 just wrong.
>>
>> - Add the new helper, find_lock_task_mm(), which finds the live
>> =C2=A0 thread which uses the memory and takes task_lock() to pin ->mm
>>
>> - change oom_badness() to use this helper instead of just checking
>> =C2=A0 ->mm !=3D NULL.
>>
>> - As David pointed out, select_bad_process() must never choose the
>> =C2=A0 task without ->mm, but no matter what oom_badness() returns the
>> =C2=A0 task can be chosen if nothing else has been found yet.
>>
>> =C2=A0 Change oom_badness() to return int, change it to return -1 if
>> =C2=A0 find_lock_task_mm() fails, and change select_bad_process() to
>> =C2=A0 check points >=3D 0.
>>
>> Note! This patch is not enough, we need more changes.
>>
>> =C2=A0 =C2=A0 =C2=A0 - oom_badness() was fixed, but oom_kill_task() stil=
l ignores
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 the task without ->mm
>>
>> =C2=A0 =C2=A0 =C2=A0 - oom_forkbomb_penalty() should use find_lock_task_=
mm() too,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 and it also needs other changes to actually =
find the first
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 first-descendant children
>>
>> This will be addressed later.
>>
>> [kosaki.motohiro@jp.fujitsu.com: use in badness(), __oom_kill_task()]
>> Signed-off-by: Oleg Nesterov <oleg@redhat.com>
>> Signed-off-by: David Rientjes <rientjes@google.com>
>> ---
>> =C2=A0mm/oom_kill.c | =C2=A0 74 +++++++++++++++++++++++++++++++++-------=
-----------------
>> =C2=A01 files changed, 43 insertions(+), 31 deletions(-)
>>
>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>> --- a/mm/oom_kill.c
>> +++ b/mm/oom_kill.c
>> @@ -52,6 +52,20 @@ static int has_intersects_mems_allowed(struct task_st=
ruct *tsk)
>> =C2=A0 =C2=A0 =C2=A0 return 0;
>> =C2=A0}
>>
>> +static struct task_struct *find_lock_task_mm(struct task_struct *p)
>> +{
>> + =C2=A0 =C2=A0 struct task_struct *t =3D p;
>> +
>> + =C2=A0 =C2=A0 do {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 task_lock(t);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (likely(t->mm))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
return t;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 task_unlock(t);
>> + =C2=A0 =C2=A0 } while_each_thread(p, t);
>> +
>> + =C2=A0 =C2=A0 return NULL;
>> +}
>> +
>
> Even if we miss this mm via p->mm, won't for_each_process actually
> catch it? Are you suggesting that the main thread could have detached
> the mm and a thread might still have it mapped?

Yes.  Although main thread detach mm, sub-thread still may have the mm.
As you have confused, I think this function name isn't good.
So I suggested following as.

http://lkml.org/lkml/2010/6/2/325

Anyway, It does make sense to me.
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
