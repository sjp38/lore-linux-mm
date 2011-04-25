Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 147BD8D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:21:31 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p3PMLQWu013244
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 15:21:26 -0700
Received: from qwi2 (qwi2.prod.google.com [10.241.195.2])
	by hpaq11.eem.corp.google.com with ESMTP id p3PMLMp6031072
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 15:21:25 -0700
Received: by qwi2 with SMTP id 2so33508qwi.36
        for <linux-mm@kvack.org>; Mon, 25 Apr 2011 15:21:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110425191437.d881ee68.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110425191437.d881ee68.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 25 Apr 2011 15:21:21 -0700
Message-ID: <BANLkTikYeV8JpMHd1Lvh7kRXXpLyQEOw4w@mail.gmail.com>
Subject: Re: [PATCH 0/7] memcg background reclaim , yet another one.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>

Kame:

Thank you for putting time on implementing the patch. I think it is
definitely a good idea to have the two alternatives on the table since
people has asked the questions. Before going down to the track, i have
thought about the two approaches and also discussed with Greg and Hugh
(cc-ed),  i would like to clarify some of the pros and cons on both
approaches.  In general, I think the workqueue is not the right answer
for this purpose.

The thread-pool model
Pros:
1. there is no isolation between memcg background reclaim, since the
memcg threads are shared. That isolation including all the resources
that the per-memcg background reclaim will need to access, like cpu
time. One thing we are missing for the shared worker model is the
individual cpu scheduling ability. We need the ability to isolate and
count the resource assumption per memcg, and including how much
cputime and where to run the per-memcg kswapd thread.

2. it is hard for visibility and debugability. We have been
experiencing a lot when some kswapds running creazy and we need a
stright-forward way to identify which cgroup causing the reclaim. yes,
we can add more stats per-memcg to sort of giving that visibility, but
I can tell they are involved w/ more overhead of the change. Why
introduce the over-head if the per-memcg kswapd thread can offer that
maturely.

3. potential priority inversion for some memcgs. Let's say we have two
memcgs A and B on a single core machine, and A has big chuck of work
and B has small chuck of work. Now B's work is queued up after A. In
the workqueue model, we won't process B unless we finish A's work
since we only have one worker on the single core host. However, in the
per-memcg kswapd model, B got chance to run when A calls
cond_resched(). Well, we might not having the exact problem if we
don't constrain the workers number, and the worst case we'll have the
same number of workers as the number of memcgs. If so, it would be the
same model as per-memcg kswapd.

4. the kswapd threads are created and destroyed dynamically. are we
talking about allocating 8k of stack for kswapd when we are under
memory pressure? In the other case, all the memory are preallocated.

5. the workqueue is scary and might introduce issues sooner or later.
Also, why we think the background reclaim fits into the workqueue
model, and be more specific, how that share the same logic of other
parts of the system using workqueue.

Cons:
1. save SOME memory resource.

The per-memcg-per-kswapd model
Pros:
1. memory overhead per thread, and The memory consumption would be
8k*1000 =3D 8M with 1k cgroup. This is NOT a problem as least we haven't
seen it in our production. We have cases that 2k of kernel threads
being created, and we haven't noticed it is causing resource
consumption problem as well as performance issue. On those systems, we
might have ~100 cgroup running at a time.

2. we see lots of threads at 'ps -elf'. well, is that really a problem
that we need to change the threading model?

Overall, the per-memcg-per-kswapd thread model is simple enough to
provide better isolation (predictability & debug ability). The number
of threads we might potentially have on the system is not a real
problem. We already have systems running that much of threads (even
more) and we haven't seen problem of that. Also, i can imagine it will
make our life easier for some other extensions on memcg works.

For now, I would like to stick on the simple model. At the same time I
am willing to looking into changes and fixes whence we have seen
problems later.

Comments?

Thanks

--Ying

On Mon, Apr 25, 2011 at 3:14 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 25 Apr 2011 18:25:29 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
>
>> 2) =3D=3D hard limit 500M/ hi_watermark =3D 400M =3D=3D
>> [root@rhel6-test hilow]# time cp ./tmpfile xxx
>>
>> real =A0 =A00m6.421s
>> user =A0 =A00m0.059s
>> sys =A0 =A0 0m2.707s
>>
>
> When doing this, we see usage changes as
> (sec) (bytes)
> =A0 0: 401408 =A0 =A0 =A0 =A0<=3D=3D cp start
> =A0 1: 98603008
> =A0 2: 262705152
> =A0 3: 433491968 =A0 =A0 <=3D=3D wmark reclaim triggerd.
> =A0 4: 486502400
> =A0 5: 507748352
> =A0 6: 524189696 =A0 =A0 <=3D=3D cp ends (and hit limits)
> =A0 7: 501231616
> =A0 8: 499511296
> =A0 9: 477118464
> =A010: 417980416 =A0 =A0 <=3D=3D usage goes below watermark.
> =A011: 417980416
> =A0.....
>
> If we have dirty_ratio, this result will be some different.
> (and flusher thread will work sooner...)
>
>
> Thanks,
> -Kame
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
