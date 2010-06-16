Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4AB556B01AF
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 00:42:27 -0400 (EDT)
Received: by iwn35 with SMTP id 35so340845iwn.14
        for <linux-mm@kvack.org>; Tue, 15 Jun 2010 21:42:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100616090334.d27e0c4e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100615152450.f82c1f8c.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTinEEYWULLICKqBr4yX7GL01E4cq0jQSfuN8J6Jq@mail.gmail.com>
	<20100616090334.d27e0c4e.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 16 Jun 2010 10:12:20 +0530
Message-ID: <AANLkTikGcl8l8TvSWx2Ij7I5E-TVjGplRU5YfX0mTAG0@mail.gmail.com>
Subject: Re: [PATCH] use find_lock_task_mm in memory cgroups oom v2
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Oleg Nesterov <oleg@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 16, 2010 at 5:33 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 15 Jun 2010 18:59:25 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> > -/*
>> > +/**
>> > + * find_lock_task_mm - Checking a process which a task belongs to has=
 valid mm
>> > + * and return a locked task which has a valid pointer to mm.
>> > + *
>>
>> This comment should have been another patch.
>> BTW, below comment uses "subthread" word.
>> Personally it's easy to understand function's goal to me. :)
>>
>> How about following as?
>> Checking a process which has any subthread with vaild mm
>> ....
>>
> Sure. thank you. v2 is here. I removed unnecessary parts.
>
> =3D=3D
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> When the OOM killer scans task, it check a task is under memcg or
> not when it's called via memcg's context.
>
> But, as Oleg pointed out, a thread group leader may have NULL ->mm
> and task_in_mem_cgroup() may do wrong decision. We have to use
> find_lock_task_mm() in memcg as generic OOM-Killer does.
>
> Changelog:
> =A0- removed unnecessary changes in comments.
>

mm->owner solves the same problem, but unfortunately we have task
based selection in OOM killer, so we need this patch. It is quite
ironic that we find the mm from the task and then eventually the task
back from mm->owner and then the mem cgroup. If we already know the mm
from oom_kill.c, I think we can change the function to work off of
that. mm->owner->cgroup..no?

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
