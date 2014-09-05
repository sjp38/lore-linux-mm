Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8D5686B0036
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 19:33:16 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id eu11so23292838pac.33
        for <linux-mm@kvack.org>; Fri, 05 Sep 2014 16:33:15 -0700 (PDT)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id uq4si6212867pbc.190.2014.09.05.16.33.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 05 Sep 2014 16:33:15 -0700 (PDT)
Received: from kw-mxoi1.gw.nic.fujitsu.com (unknown [10.0.237.133])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B8CB53EE1D6
	for <linux-mm@kvack.org>; Sat,  6 Sep 2014 08:33:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id BF5D2AC022A
	for <linux-mm@kvack.org>; Sat,  6 Sep 2014 08:33:11 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6401E1DB8038
	for <linux-mm@kvack.org>; Sat,  6 Sep 2014 08:33:11 +0900 (JST)
Message-ID: <540A4420.2030504@jp.fujitsu.com>
Date: Sat, 06 Sep 2014 08:15:44 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC] memory cgroup: my thoughts on memsw
References: <20140904143055.GA20099@esperanza> <5408E1CD.3090004@jp.fujitsu.com> <20140905082846.GA25641@esperanza> <5409C6BB.7060009@jp.fujitsu.com> <20140905160029.GF25641@esperanza>
In-Reply-To: <20140905160029.GF25641@esperanza>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Glauber Costa <glommer@gmail.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@parallels.com>, Konstantin Khorenko <khorenko@parallels.com>, LKML-MM <linux-mm@kvack.org>, LKML-cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

(2014/09/06 1:00), Vladimir Davydov wrote:
> On Fri, Sep 05, 2014 at 11:20:43PM +0900, Kamezawa Hiroyuki wrote:
>> Basically, I don't like OOM Kill. Anyone don't like it, I think.
>>
>> In recent container use, application may be build as "stateless" and
>> kill-and-respawn may not be problematic, but I think killing "a" process
>> by oom-kill is too naive.
>>
>> If your proposal is triggering notification to user space at hitting
>> anon+swap limit, it may be useful.
>> ...Some container-cluster management software can handle it.
>> For example, container may be restarted.
>>
>> Memcg has threshold notifier and vmpressure notifier.
>> I think you can enhance it.
> [...]
>> My point is that "killing a process" tend not to be able to fix the situation.
>> For example, fork-bomb by "make -j" cannot be handled by it.
>>
>> So, I don't want to think about enhancing OOM-Kill. Please think of better
>> way to survive. With the help of countainer-management-softwares, I think
>> we can have several choices.
>>
>> Restart contantainer (killall) may be the best if container app is stateless.
>> Or container-management can provide some failover.
>
> The problem I'm trying to set out is not about OOM actually (sorry if
> the way I explain is confusing). We could probably configure OOM to kill
> a whole cgroup (not just a process) and/or improve user-notification so
> that the userspace could react somehow. I'm sure it must and will be
> discussed one day.
>
> The problem is that *before* invoking OOM on *global* pressure we're
> trying to reclaim containers' memory and if there's progress we won't
> invoke OOM. This can result in a huge slow down of the whole system (due
> to swap out).
>
use SSD or zram for swap device.


>> The 1st reason we added memsw.limit was for avoiding that the whole swap
>> is used up by a cgroup where memory-leak of forkbomb running and not for
>> some intellegent controls.
>>
>>  From your opinion, I feel what you want is avoiding charging against page-caches.
>> But thiking docker at el, page-cache is not shared between containers any more.
>> I think "including cache" makes sense.
>
> Not exactly. It's not about sharing caches among containers. The point
> is (1) it's difficult to estimate the size of file caches that will max
> out the performance of a container, and (2) a typical workload will
> perform better and put less pressure on disk if it has more caches.
>
> Now imagine a big host running a small number of containers and
> therefore having a lot of free memory most of time, but still
> experiencing load spikes once an hour/day/whatever when memory usage
> raises up drastically. It'd be unwise to set hard limits for those
> containers that are running regularly, because they'd probably perform
> much better if they had more file caches. So the admin decides to use
> soft limits instead. He is forced to use memsw.limit > the soft limit,
> but this is unsafe, because the container may eat anon memory up to
> memsw.limit then, and anon memory isn't easy to get rid of when it comes
> to the global pressure. If the admin had a mean to limit swappable
> memory, he could avoid it. This is what I was trying to illustrate by
> the example in the first e-mail of this thread.
>
> Note if there were no soft limits, the current setup would be just fine,
> otherwise it fails. And soft limits are proved to be useful AFAIK.
>  

As you noticed, hitting anon+swap limit just means oom-kill.
My point is that using oom-killer for "server management" just seems crazy.

Let my clarify things. your proposal was.
  1. soft-limit will be a main feature for server management.
  2. Because of soft-limit, global memory reclaim runs.
  3. Using swap at global memory reclaim can cause poor performance.
  4. So, making use of OOM-Killer for avoiding swap.

I can't agree "4". I think

  - don't configure swap.
  - use zram
  - use SSD for swap
Or
  - provide a way to notify usage of "anon+swap" to container management software.

    Now we have "vmpressure". Container management software can kill or respawn container
    with using user-defined policy for avoidng swap.

    If you don't want to run kswapd at all, threshold notifier enhancement may be required.

/proc/meminfo provides total number of ANON/CACHE pages.
Many things can be done in userland.

And your idea can't help swap-out caused by memory pressure comes from "zones".
I guess vmpressure will be a total win. The kernel may need some enhancement
but I don't like to make use of oom-killer as a part of feature for avoiding swap.

Thanks,
-Kame







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
