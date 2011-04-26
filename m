Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 69EE5900001
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 03:19:53 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p3Q7JmDg021178
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 00:19:49 -0700
Received: from qyj19 (qyj19.prod.google.com [10.241.83.83])
	by hpaq2.eem.corp.google.com with ESMTP id p3Q7JIva018308
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 00:19:47 -0700
Received: by qyj19 with SMTP id 19so1175993qyj.2
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 00:19:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110426103859.05eb7a35.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110425191437.d881ee68.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikYeV8JpMHd1Lvh7kRXXpLyQEOw4w@mail.gmail.com>
	<20110426103859.05eb7a35.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 26 Apr 2011 00:19:46 -0700
Message-ID: <BANLkTi=aoRhgu3SOKZ8OLRqTew67ciquFg@mail.gmail.com>
Subject: Re: [PATCH 0/7] memcg background reclaim , yet another one.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>

On Mon, Apr 25, 2011 at 6:38 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 25 Apr 2011 15:21:21 -0700
> Ying Han <yinghan@google.com> wrote:
>
>> Kame:
>>
>> Thank you for putting time on implementing the patch. I think it is
>> definitely a good idea to have the two alternatives on the table since
>> people has asked the questions. Before going down to the track, i have
>> thought about the two approaches and also discussed with Greg and Hugh
>> (cc-ed), =A0i would like to clarify some of the pros and cons on both
>> approaches. =A0In general, I think the workqueue is not the right answer
>> for this purpose.
>>
>> The thread-pool model
>> Pros:
>> 1. there is no isolation between memcg background reclaim, since the
>> memcg threads are shared. That isolation including all the resources
>> that the per-memcg background reclaim will need to access, like cpu
>> time. One thing we are missing for the shared worker model is the
>> individual cpu scheduling ability. We need the ability to isolate and
>> count the resource assumption per memcg, and including how much
>> cputime and where to run the per-memcg kswapd thread.
>>
>
> IIUC, new threads for workqueue will be created if necessary in automatic=
.
>
I read your patches today, but i might missed some details while I was
reading it. I will read them through
tomorrow.

The question I was wondering here is
1. how to do cpu cgroup limit per-memcg including the kswapd time.
2. how to do numa awareness cpu scheduling if i want to do cpumask on
the memcg-kswapd close to the numa node where all the pages of the
memcg allocated.

I guess the second one should have been covered. If not, it shouldn't
be a big effort to fix that. And any suggestions on the first one.

>
>> 2. it is hard for visibility and debugability. We have been
>> experiencing a lot when some kswapds running creazy and we need a
>> stright-forward way to identify which cgroup causing the reclaim. yes,
>> we can add more stats per-memcg to sort of giving that visibility, but
>> I can tell they are involved w/ more overhead of the change. Why
>> introduce the over-head if the per-memcg kswapd thread can offer that
>> maturely.
>>
>
> I added counters and time comsumption statistics with low overhead.

I looked at the patch and the stats looks good to me. Thanks.

>
>
>> 3. potential priority inversion for some memcgs. Let's say we have two
>> memcgs A and B on a single core machine, and A has big chuck of work
>> and B has small chuck of work. Now B's work is queued up after A. In
>> the workqueue model, we won't process B unless we finish A's work
>> since we only have one worker on the single core host. However, in the
>> per-memcg kswapd model, B got chance to run when A calls
>> cond_resched(). Well, we might not having the exact problem if we
>> don't constrain the workers number, and the worst case we'll have the
>> same number of workers as the number of memcgs. If so, it would be the
>> same model as per-memcg kswapd.
>>
>
> I implemented static scan rate round-robin. I think you didn't read patch=
es.
> And, The fact per-memcg thread model switches when it calls cond_resched(=
),
> means it will not reched until it cousumes enough vruntme. I guess static
> scan rate round-robin wins at duscussing fairness.
>
> And IIUC, workqueue invokes enough amount of threads to do service.

So, instead of having dedicated thread hitting the wmark based on
priority, we just do a little bit amount
of work per-memcg and round robin across them. This sounds might help
on the counter example I gave
above and also shares similar logic as calling cond_resched().


>
>> 4. the kswapd threads are created and destroyed dynamically. are we
>> talking about allocating 8k of stack for kswapd when we are under
>> memory pressure? In the other case, all the memory are preallocated.
>>
>
> I think workqueue is there for avoiding 'making kthread dynamically'.
> We can save much codes.

So right now, the workqueue is configured as unbounded. which means
the worse case we might create
the same number of workers as the number of memcgs. ( if each memcg
takes long time to do the reclaim). So this might not be a problem,
but I would like to confirm.

>
>> 5. the workqueue is scary and might introduce issues sooner or later.
>> Also, why we think the background reclaim fits into the workqueue
>> model, and be more specific, how that share the same logic of other
>> parts of the system using workqueue.
>>
>
> Ok, with using workqueue.
>
> =A01. The number of threads can be changed dynamically with regard to sys=
tem
> =A0 =A0 workload without adding any codes. workqueue is for this kind of
> =A0 =A0 background jobs. gcwq has a hooks to scheduler and it works well.
> =A0 =A0 With per-memcg thread model, we'll never be able to do such.
>
> =A02. We can avoid having unncessary threads.
> =A0 =A0 If it sleeps most of time, why we need to keep it ? No, it's unne=
cessary.
> =A0 =A0 It should be on-demand. freezer() etc need to stop all threads an=
d
> =A0 =A0 thousands of sleeping threads will be harmful.
> =A0 =A0 You can see how 'ps -elf' gets slow when the number of threads in=
creases.

In general, i am not strongly against the workqueue but trying to
understand the procs and cons between the two approaches. The first
one is definitely simpler and more straight-forward, and I was
suggesting to start with something simple and improve it later if we
see problems. But I will read your path through tomorrow and also
willing to see comments from others.

Thank you for the efforts!

--Ying

>
>
> =3D=3D=3D When we have small threads =3D=3D
> [root@rhel6-test hilow]# time ps -elf | wc -l
> 128
>
> real =A0 =A00m0.058s
> user =A0 =A00m0.010s
> sys =A0 =A0 0m0.051s
>
> =3D=3D When we have 2000 'sleeping' tasks. =3D=3D
> [root@rhel6-test hilow]# time ps -elf | wc -l
> 2128
>
> real =A0 =A00m0.881s
> user =A0 =A00m0.055s
> sys =A0 =A0 0m0.972s
>
> Awesome, it costs nearly 1sec.
> We should keep the number of threads as small as possible. Having threads=
 is cost.
>
>
> =A03. We need to refine reclaim codes for memcg to make it consuming less=
 time.
> =A0 =A0 With per-memcg-thread model, we'll use cut-n-paste codes and pass=
 all job
> =A0 =A0 to scheduler and consuming more time, reclaim slowly.
>
> =A0 =A0 BTW, Static scan rate round robin implemented in this patch is a =
fair routine.
>
>
> On 4cpu KVM, creating 100M-limit 90M-hiwat cgroups 1,2,3,4,5, and run 'ca=
t 400M >/dev/null'
> a size of file(400M) on each cgroup for 60secs in loop.
> =3D=3D
> [kamezawa@rhel6-test ~]$ cat /cgroup/memory/[1-5]/memory.stat | grep elap=
se | grep -v total
> direct_elapsed_ns 0
> soft_elapsed_ns 0
> wmark_elapsed_ns 792377873
> direct_elapsed_ns 0
> soft_elapsed_ns 0
> wmark_elapsed_ns 811053756
> direct_elapsed_ns 0
> soft_elapsed_ns 0
> wmark_elapsed_ns 799196613
> direct_elapsed_ns 0
> soft_elapsed_ns 0
> wmark_elapsed_ns 806502820
> direct_elapsed_ns 0
> soft_elapsed_ns 0
> wmark_elapsed_ns 790071307
> =3D=3D
>
> No one dives into direct reclaim. and time consumption for background rec=
laim is fair
> for the same jobs.
>
> =3D=3D
> [kamezawa@rhel6-test ~]$ cat /cgroup/memory/[1-5]/memory.stat | grep wmar=
k_scanned | grep -v total
> wmark_scanned 225881
> wmark_scanned 225563
> wmark_scanned 226848
> wmark_scanned 225458
> wmark_scanned 226137
> =3D=3D
> Ah, yes. scan rate is fair. Even when we had 5 active cat + 5 works.
>
> BTW, without bgreclaim,
> =3D=3D
> [kamezawa@rhel6-test ~]$ cat /cgroup/memory/[1-5]/memory.stat | grep dire=
ct_elapsed | grep -v total
> direct_elapsed_ns 786049957
> direct_elapsed_ns 782150545
> direct_elapsed_ns 805222327
> direct_elapsed_ns 782563391
> direct_elapsed_ns 782431424
> =3D=3D
>
> direct reclaim uses the same amount of time.
>
> =3D=3D
> [kamezawa@rhel6-test ~]$ cat /cgroup/memory/[1-5]/memory.stat | grep dire=
ct_scan | grep -v total
> direct_scanned 224501
> direct_scanned 224448
> direct_scanned 224448
> direct_scanned 224448
> direct_scanned 224448
> =3D=3D
>
> CFS seems to work fair ;) (Note: there is 10M difference between bgreclai=
m/direct).
>
> with 10 groups. 10threads + 10works.
> =3D=3D
> [kamezawa@rhel6-test hilow]$ cat /cgroup/memory/[0-9]/memory.stat | grep =
elapsed_ns | grep -v total | grep -v soft
> direct_elapsed_ns 0
> soft_elapsed_ns 0
> wmark_elapsed_ns 81856013
> direct_elapsed_ns 0
> soft_elapsed_ns 0
> wmark_elapsed_ns 350538700
> direct_elapsed_ns 0
> soft_elapsed_ns 0
> wmark_elapsed_ns 340384072
> direct_elapsed_ns 0
> soft_elapsed_ns 0
> wmark_elapsed_ns 344776087
> direct_elapsed_ns 0
> soft_elapsed_ns 0
> wmark_elapsed_ns 322237832
> direct_elapsed_ns 0
> soft_elapsed_ns 0
> wmark_elapsed_ns 337741658
> direct_elapsed_ns 0
> soft_elapsed_ns 0
> wmark_elapsed_ns 261018174
> direct_elapsed_ns 0
> soft_elapsed_ns 0
> wmark_elapsed_ns 316675784
> direct_elapsed_ns 0
> soft_elapsed_ns 0
> wmark_elapsed_ns 257009865
> direct_elapsed_ns 0
> soft_elapsed_ns 0
> wmark_elapsed_ns 154339039
>
> =3D=3D
> No one dives into direct reclaim. (But 'cat' iself slow...because of read=
() ?)
> From bgreclaim point's of view, this is fair because no direct reclaim ha=
ppens.
> Maybe I need to use blkio cgroup for more tests of this kind.
>
> I attaches the test script below.
>
> =A04. We can see how round-robin works and see what we need to modify.
> =A0 =A0 Maybe good for future work and we'll have good chance to reuse co=
des.
>
> =A05. With per-memcg-thread, at bad case, we'll see thousands of threads =
trying
> =A0 =A0 to reclai memory at once. It's never good.
> =A0 =A0 In this patch, I left max_active of workqueue as default. If we n=
eed fix/tune,
> =A0 =A0 we just fix max_active.
>
> =A06. If it seems that it's better to have thread pool for memcg,
> =A0 =A0 we can switch to thread-pool model seamlessly. But delayd_work im=
plemenation
> =A0 =A0 will be difficult ;) And management of the number of active works=
 will be
> =A0 =A0 difficult. I bet we'll never use thread-pool.
>
> =A07. We'll never see cpu cache miss caused by frequent thread-stack-swit=
ch.
>
>
>> Cons:
>> 1. save SOME memory resource.
>>
> and CPU resouce. per-memcg-thread tends to use much cpu time rather than =
workqueue
> which is required to be designed as short-term round robin.
>
>
>> The per-memcg-per-kswapd model
>> Pros:
>> 1. memory overhead per thread, and The memory consumption would be
>> 8k*1000 =3D 8M with 1k cgroup. This is NOT a problem as least we haven't
>> seen it in our production. We have cases that 2k of kernel threads
>> being created, and we haven't noticed it is causing resource
>> consumption problem as well as performance issue. On those systems, we
>> might have ~100 cgroup running at a time.
>>
>> 2. we see lots of threads at 'ps -elf'. well, is that really a problem
>> that we need to change the threading model?
>>
>> Overall, the per-memcg-per-kswapd thread model is simple enough to
>> provide better isolation (predictability & debug ability). The number
>> of threads we might potentially have on the system is not a real
>> problem. We already have systems running that much of threads (even
>> more) and we haven't seen problem of that. Also, i can imagine it will
>> make our life easier for some other extensions on memcg works.
>>
>> For now, I would like to stick on the simple model. At the same time I
>> am willing to looking into changes and fixes whence we have seen
>> problems later.
>>
>> Comments?
>>
>
>
> In 2-3 years ago, I implemetned per-memcg-thread model and got NACK and
> said "you should use workqueue ;) Now, workqueue is renewed and seems eas=
ier to
> use for cpu-intensive workloads. If I need more tweaks for workqueue, I'l=
l add
> patches for workqueue. But, it's unseen now.
>
> And, using per-memcg thread model tend to lead us to brain-dead, as using=
 cut-n-paste
> codes from kswapd which never fits memcg. Later, at removing LRU, we need=
 some kind
> of round-robin again and checking how round-robin works and what is good =
code for
> round robin is an interesting study. For example, I noticed I need patch =
4, soon.
>
>
> I'd like to use workqueue and refine the whole routine to fit short-term =
round-robin.
> Having sleeping threads is cost. round robin can work in fair way.
>
>
> Thanks,
> -Kame
>
> =3D=3D test.sh =3D=3D
> #!/bin/bash -x
>
> for i in `seq 0 9`; do
> =A0 =A0 =A0 =A0mkdir /cgroup/memory/$i
> =A0 =A0 =A0 =A0echo 100M > /cgroup/memory/$i/memory.limit_in_bytes
> =A0 =A0 =A0 =A0echo 10M > /cgroup/memory/$i/memory.high_wmark_distance
> done
>
> for i in `seq 0 9`; do
> =A0 =A0 =A0 =A0cgexec -g memory:$i ./loop.sh ./tmpfile$i &
> done
>
> sleep 60;
>
> pkill loop.sh
>
> =3D=3D loop.sh =3D=3D
> #!/bin/sh
>
> while true; do
> =A0 =A0 =A0 =A0cat $1 > /dev/null
> done
> =3D=3D
>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
