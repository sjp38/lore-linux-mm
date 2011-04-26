Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2AEEA8D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 21:45:44 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 1AD793EE0BC
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:45:40 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id ED14245DEA2
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:45:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C63E745DE9F
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:45:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B7F2F1DB803C
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:45:39 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C9EA1DB803A
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:45:39 +0900 (JST)
Date: Tue, 26 Apr 2011 10:38:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/7] memcg background reclaim , yet another one.
Message-Id: <20110426103859.05eb7a35.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTikYeV8JpMHd1Lvh7kRXXpLyQEOw4w@mail.gmail.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110425191437.d881ee68.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikYeV8JpMHd1Lvh7kRXXpLyQEOw4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>

On Mon, 25 Apr 2011 15:21:21 -0700
Ying Han <yinghan@google.com> wrote:

> Kame:
> 
> Thank you for putting time on implementing the patch. I think it is
> definitely a good idea to have the two alternatives on the table since
> people has asked the questions. Before going down to the track, i have
> thought about the two approaches and also discussed with Greg and Hugh
> (cc-ed),  i would like to clarify some of the pros and cons on both
> approaches.  In general, I think the workqueue is not the right answer
> for this purpose.
> 
> The thread-pool model
> Pros:
> 1. there is no isolation between memcg background reclaim, since the
> memcg threads are shared. That isolation including all the resources
> that the per-memcg background reclaim will need to access, like cpu
> time. One thing we are missing for the shared worker model is the
> individual cpu scheduling ability. We need the ability to isolate and
> count the resource assumption per memcg, and including how much
> cputime and where to run the per-memcg kswapd thread.
> 

IIUC, new threads for workqueue will be created if necessary in automatic.



> 2. it is hard for visibility and debugability. We have been
> experiencing a lot when some kswapds running creazy and we need a
> stright-forward way to identify which cgroup causing the reclaim. yes,
> we can add more stats per-memcg to sort of giving that visibility, but
> I can tell they are involved w/ more overhead of the change. Why
> introduce the over-head if the per-memcg kswapd thread can offer that
> maturely.
> 

I added counters and time comsumption statistics with low overhead.


> 3. potential priority inversion for some memcgs. Let's say we have two
> memcgs A and B on a single core machine, and A has big chuck of work
> and B has small chuck of work. Now B's work is queued up after A. In
> the workqueue model, we won't process B unless we finish A's work
> since we only have one worker on the single core host. However, in the
> per-memcg kswapd model, B got chance to run when A calls
> cond_resched(). Well, we might not having the exact problem if we
> don't constrain the workers number, and the worst case we'll have the
> same number of workers as the number of memcgs. If so, it would be the
> same model as per-memcg kswapd.
> 

I implemented static scan rate round-robin. I think you didn't read patches.
And, The fact per-memcg thread model switches when it calls cond_resched(),
means it will not reched until it cousumes enough vruntme. I guess static
scan rate round-robin wins at duscussing fairness.
 
And IIUC, workqueue invokes enough amount of threads to do service.

> 4. the kswapd threads are created and destroyed dynamically. are we
> talking about allocating 8k of stack for kswapd when we are under
> memory pressure? In the other case, all the memory are preallocated.
> 

I think workqueue is there for avoiding 'making kthread dynamically'.
We can save much codes.

> 5. the workqueue is scary and might introduce issues sooner or later.
> Also, why we think the background reclaim fits into the workqueue
> model, and be more specific, how that share the same logic of other
> parts of the system using workqueue.
> 

Ok, with using workqueue.

  1. The number of threads can be changed dynamically with regard to system
     workload without adding any codes. workqueue is for this kind of
     background jobs. gcwq has a hooks to scheduler and it works well.
     With per-memcg thread model, we'll never be able to do such.

  2. We can avoid having unncessary threads.
     If it sleeps most of time, why we need to keep it ? No, it's unnecessary.
     It should be on-demand. freezer() etc need to stop all threads and
     thousands of sleeping threads will be harmful.
     You can see how 'ps -elf' gets slow when the number of threads increases.


=== When we have small threads ==
[root@rhel6-test hilow]# time ps -elf | wc -l
128

real    0m0.058s
user    0m0.010s
sys     0m0.051s
  
== When we have 2000 'sleeping' tasks. ==
[root@rhel6-test hilow]# time ps -elf | wc -l
2128

real    0m0.881s
user    0m0.055s
sys     0m0.972s

Awesome, it costs nearly 1sec.
We should keep the number of threads as small as possible. Having threads is cost.


  3. We need to refine reclaim codes for memcg to make it consuming less time.
     With per-memcg-thread model, we'll use cut-n-paste codes and pass all job
     to scheduler and consuming more time, reclaim slowly.

     BTW, Static scan rate round robin implemented in this patch is a fair routine.


On 4cpu KVM, creating 100M-limit 90M-hiwat cgroups 1,2,3,4,5, and run 'cat 400M >/dev/null'
a size of file(400M) on each cgroup for 60secs in loop.
==
[kamezawa@rhel6-test ~]$ cat /cgroup/memory/[1-5]/memory.stat | grep elapse | grep -v total
direct_elapsed_ns 0
soft_elapsed_ns 0
wmark_elapsed_ns 792377873
direct_elapsed_ns 0
soft_elapsed_ns 0
wmark_elapsed_ns 811053756
direct_elapsed_ns 0
soft_elapsed_ns 0
wmark_elapsed_ns 799196613
direct_elapsed_ns 0
soft_elapsed_ns 0
wmark_elapsed_ns 806502820
direct_elapsed_ns 0
soft_elapsed_ns 0
wmark_elapsed_ns 790071307
==

No one dives into direct reclaim. and time consumption for background reclaim is fair
for the same jobs.

==
[kamezawa@rhel6-test ~]$ cat /cgroup/memory/[1-5]/memory.stat | grep wmark_scanned | grep -v total
wmark_scanned 225881
wmark_scanned 225563
wmark_scanned 226848
wmark_scanned 225458
wmark_scanned 226137
==
Ah, yes. scan rate is fair. Even when we had 5 active cat + 5 works.

BTW, without bgreclaim,
==
[kamezawa@rhel6-test ~]$ cat /cgroup/memory/[1-5]/memory.stat | grep direct_elapsed | grep -v total
direct_elapsed_ns 786049957
direct_elapsed_ns 782150545
direct_elapsed_ns 805222327
direct_elapsed_ns 782563391
direct_elapsed_ns 782431424
==

direct reclaim uses the same amount of time.

==
[kamezawa@rhel6-test ~]$ cat /cgroup/memory/[1-5]/memory.stat | grep direct_scan | grep -v total
direct_scanned 224501
direct_scanned 224448
direct_scanned 224448
direct_scanned 224448
direct_scanned 224448
==

CFS seems to work fair ;) (Note: there is 10M difference between bgreclaim/direct).

with 10 groups. 10threads + 10works.
==
[kamezawa@rhel6-test hilow]$ cat /cgroup/memory/[0-9]/memory.stat | grep elapsed_ns | grep -v total | grep -v soft
direct_elapsed_ns 0
soft_elapsed_ns 0
wmark_elapsed_ns 81856013
direct_elapsed_ns 0
soft_elapsed_ns 0
wmark_elapsed_ns 350538700
direct_elapsed_ns 0
soft_elapsed_ns 0
wmark_elapsed_ns 340384072
direct_elapsed_ns 0
soft_elapsed_ns 0
wmark_elapsed_ns 344776087
direct_elapsed_ns 0
soft_elapsed_ns 0
wmark_elapsed_ns 322237832
direct_elapsed_ns 0
soft_elapsed_ns 0
wmark_elapsed_ns 337741658
direct_elapsed_ns 0
soft_elapsed_ns 0
wmark_elapsed_ns 261018174
direct_elapsed_ns 0
soft_elapsed_ns 0
wmark_elapsed_ns 316675784
direct_elapsed_ns 0
soft_elapsed_ns 0
wmark_elapsed_ns 257009865
direct_elapsed_ns 0
soft_elapsed_ns 0
wmark_elapsed_ns 154339039

==
No one dives into direct reclaim. (But 'cat' iself slow...because of read() ?)
>From bgreclaim point's of view, this is fair because no direct reclaim happens.
Maybe I need to use blkio cgroup for more tests of this kind.

I attaches the test script below.

  4. We can see how round-robin works and see what we need to modify.
     Maybe good for future work and we'll have good chance to reuse codes.

  5. With per-memcg-thread, at bad case, we'll see thousands of threads trying
     to reclai memory at once. It's never good.
     In this patch, I left max_active of workqueue as default. If we need fix/tune,
     we just fix max_active. 

  6. If it seems that it's better to have thread pool for memcg,
     we can switch to thread-pool model seamlessly. But delayd_work implemenation
     will be difficult ;) And management of the number of active works will be
     difficult. I bet we'll never use thread-pool.

  7. We'll never see cpu cache miss caused by frequent thread-stack-switch. 


> Cons:
> 1. save SOME memory resource.
> 
and CPU resouce. per-memcg-thread tends to use much cpu time rather than workqueue
which is required to be designed as short-term round robin.


> The per-memcg-per-kswapd model
> Pros:
> 1. memory overhead per thread, and The memory consumption would be
> 8k*1000 = 8M with 1k cgroup. This is NOT a problem as least we haven't
> seen it in our production. We have cases that 2k of kernel threads
> being created, and we haven't noticed it is causing resource
> consumption problem as well as performance issue. On those systems, we
> might have ~100 cgroup running at a time.
> 
> 2. we see lots of threads at 'ps -elf'. well, is that really a problem
> that we need to change the threading model?
> 
> Overall, the per-memcg-per-kswapd thread model is simple enough to
> provide better isolation (predictability & debug ability). The number
> of threads we might potentially have on the system is not a real
> problem. We already have systems running that much of threads (even
> more) and we haven't seen problem of that. Also, i can imagine it will
> make our life easier for some other extensions on memcg works.
> 
> For now, I would like to stick on the simple model. At the same time I
> am willing to looking into changes and fixes whence we have seen
> problems later.
> 
> Comments?
> 


In 2-3 years ago, I implemetned per-memcg-thread model and got NACK and
said "you should use workqueue ;) Now, workqueue is renewed and seems easier to
use for cpu-intensive workloads. If I need more tweaks for workqueue, I'll add
patches for workqueue. But, it's unseen now.

And, using per-memcg thread model tend to lead us to brain-dead, as using cut-n-paste
codes from kswapd which never fits memcg. Later, at removing LRU, we need some kind
of round-robin again and checking how round-robin works and what is good code for
round robin is an interesting study. For example, I noticed I need patch 4, soon.


I'd like to use workqueue and refine the whole routine to fit short-term round-robin.
Having sleeping threads is cost. round robin can work in fair way.


Thanks,
-Kame

== test.sh ==
#!/bin/bash -x

for i in `seq 0 9`; do
        mkdir /cgroup/memory/$i
        echo 100M > /cgroup/memory/$i/memory.limit_in_bytes
        echo 10M > /cgroup/memory/$i/memory.high_wmark_distance
done

for i in `seq 0 9`; do
        cgexec -g memory:$i ./loop.sh ./tmpfile$i &
done

sleep 60;

pkill loop.sh

== loop.sh ==
#!/bin/sh

while true; do
        cat $1 > /dev/null
done
==



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
