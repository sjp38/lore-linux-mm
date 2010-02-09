Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C67D26001DA
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 04:40:59 -0500 (EST)
Received: by pxi11 with SMTP id 11so4008645pxi.22
        for <linux-mm@kvack.org>; Tue, 09 Feb 2010 01:40:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1002082242180.19744@chino.kir.corp.google.com>
References: <20100205093932.1dcdeb5f.kamezawa.hiroyu@jp.fujitsu.com>
	 <28c262361002050830m7519f1c3y8860540708527fc0@mail.gmail.com>
	 <20100209093246.36c50bae.kamezawa.hiroyu@jp.fujitsu.com>
	 <28c262361002081724l1b64e316v3141fb4567dbf905@mail.gmail.com>
	 <alpine.DEB.2.00.1002082242180.19744@chino.kir.corp.google.com>
Date: Tue, 9 Feb 2010 18:40:58 +0900
Message-ID: <28c262361002090140p37fac1e4q2652e7a4ee3a84d4@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix oom killer kills a task in other
	cgroup
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi, David.

On Tue, Feb 9, 2010 at 3:49 PM, David Rientjes <rientjes@google.com> wrote:
> On Tue, 9 Feb 2010, Minchan Kim wrote:
>
>> I think it's not only a latency problem of OOM but it is also a
>> problem of deadlock.
>> We can't expect child's lock state in oom_kill_process.
>>
>
> task_lock() is a spinlock, it shouldn't be held for any significant lengt=
h
> of time and certainly not during a memory allocation which would be the
> only way we'd block in such a state during the oom killer; if that exists=
,
> we'd deadlock when it was chosen for kill in __oom_kill_task() anyway,
> which negates your point about oom_kill_process() and while scanning for
> tasks to kill and calling badness(). =C2=A0We don't have any special hand=
ling
> for GFP_ATOMIC allocations in the oom killer for locks being held while
> allocating anyway, the only thing we need to be concerned about is a
> writelock on tasklist_lock, but the oom killer only requires a readlock.
> You'd be correct if we help write_lock_irq(&tasklist_lock).

My point was following as.
We try to kill child of OOMed task at first.
But we can't know any locked state of child when OOM happens.
It means at this point child is able to be holding any lock.
So if we can try to hold task_lock of child, it could make new lock
dependency between task_lock and other locks.

Although there isn't such lock dependency now, I though it's not good.
Please correct me if I was wrong.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
