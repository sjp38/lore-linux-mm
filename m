Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id A4DED6B0038
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 10:23:32 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id v10so2287662pde.33
        for <linux-mm@kvack.org>; Fri, 05 Sep 2014 07:23:30 -0700 (PDT)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id rl12si4243456pab.232.2014.09.05.07.23.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 05 Sep 2014 07:23:30 -0700 (PDT)
Received: from kw-mxoi1.gw.nic.fujitsu.com (unknown [10.0.237.133])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E5FF73EE0C2
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 23:23:26 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id ECCE6AC0954
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 23:23:25 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DEBD1DB803F
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 23:23:25 +0900 (JST)
Message-ID: <5409C6BB.7060009@jp.fujitsu.com>
Date: Fri, 05 Sep 2014 23:20:43 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC] memory cgroup: my thoughts on memsw
References: <20140904143055.GA20099@esperanza> <5408E1CD.3090004@jp.fujitsu.com> <20140905082846.GA25641@esperanza>
In-Reply-To: <20140905082846.GA25641@esperanza>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Glauber Costa <glommer@gmail.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@parallels.com>, Konstantin Khorenko <khorenko@parallels.com>, LKML-MM <linux-mm@kvack.org>, LKML-cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

(2014/09/05 17:28), Vladimir Davydov wrote:
> Hi Kamezawa,
>
> Thanks for reading this :-)
>
> On Fri, Sep 05, 2014 at 07:03:57AM +0900, Kamezawa Hiroyuki wrote:
>> (2014/09/04 23:30), Vladimir Davydov wrote:
>>>   - memory.limit - container can't use memory above this
>>>   - memory.memsw.limit - container can't use swappable memory above this
>>
>> If one hits anon+swap limit, it just means OOM. Hitting limit means
>> process's death.
>
> Basically yes. Hitting the memory.limit will result in swap out + cache
> reclaim no matter if it's an anon charge or a page cache one. Hitting
> the swappable memory limit (anon+swap) can only occur on anon charge and
> if it happens we have no choice rather than invoking OOM.
>
> Frankly, I don't see anything wrong in such a behavior. Why is it worse
> than the current behavior where we also kill processes if a cgroup
> reaches memsw.limit and we can't reclaim page caches?
>

IIUC, it's the same behavior with the system without cgroup.

> I admit I may be missing something. So I'd appreciate if you could
> provide me with a use case where we want *only* the current behavior and
> my proposal is a no-go.
>

Basically, I don't like OOM Kill. Anyone don't like it, I think.

In recent container use, application may be build as "stateless" and
kill-and-respawn may not be problematic, but I think killing "a" process
by oom-kill is too naive.

If your proposal is triggering notification to user space at hitting
anon+swap limit, it may be useful.
...Some container-cluster management software can handle it.
For example, container may be restarted.

Memcg has threshold notifier and vmpressure notifier.
I think you can enhance it.


>> Is it useful ?
>
> I think so, at least, if we want to use soft limits. The point is we
> will have to kill a process if it eats too much anon memory *anyway*
> when it comes to global memory pressure, but before finishing it we'll
> be torturing the culprit as well as *innocent* processes by issuing
> massive reclaim, as I tried to point out in the example above. IMO, this
> is no good.
>

My point is that "killing a process" tend not to be able to fix the situation.
For example, fork-bomb by "make -j" cannot be handled by it.

So, I don't want to think about enhancing OOM-Kill. Please think of better
way to survive. With the help of countainer-management-softwares, I think
we can have several choices.

Restart contantainer (killall) may be the best if container app is stateless.
Or container-management can provide some failover.

> Besides, I believe such a distinction between swappable memory and
> caches would look more natural to users. Everyone got used to it
> actually. For example, when an admin or user or any userspace utility
> looks at the output of free(1), it primarily pays attention to free
> memory "-/+ buffers/caches", because almost all memory is usually full
> with file caches. And they know that caches easy come, easy go. IMO, for
> them it'd be more useful to limit this to avoid nasty surprises in the
> future, and only set some hints for page cache reclaim.
>
> The only exception is strict sand-boxing, but AFAIU we can sand-box apps
>perfectly well with this either, because we would still have a strict
> memory limit and a limit on maximal swap usage.
>
> Please sorry if the idea looks to you totally stupid (may be it is!),
> but let's just try to consider every possibility we have in mind.
>

The 1st reason we added memsw.limit was for avoiding that the whole swap
is used up by a cgroup where memory-leak of forkbomb running and not for
some intellegent controls.

 From your opinion, I feel what you want is avoiding charging against page-caches.
But thiking docker at el, page-cache is not shared between containers any more.
I think "including cache" makes sense.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
