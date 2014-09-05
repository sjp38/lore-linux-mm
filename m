Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id A57CB6B0036
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 12:00:47 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id rd3so22468862pab.38
        for <linux-mm@kvack.org>; Fri, 05 Sep 2014 09:00:46 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id sn3si4984838pab.106.2014.09.05.09.00.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Sep 2014 09:00:46 -0700 (PDT)
Date: Fri, 5 Sep 2014 20:00:29 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [RFC] memory cgroup: my thoughts on memsw
Message-ID: <20140905160029.GF25641@esperanza>
References: <20140904143055.GA20099@esperanza>
 <5408E1CD.3090004@jp.fujitsu.com>
 <20140905082846.GA25641@esperanza>
 <5409C6BB.7060009@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <5409C6BB.7060009@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Glauber Costa <glommer@gmail.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@parallels.com>, Konstantin Khorenko <khorenko@parallels.com>, LKML-MM <linux-mm@kvack.org>, LKML-cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Sep 05, 2014 at 11:20:43PM +0900, Kamezawa Hiroyuki wrote:
> Basically, I don't like OOM Kill. Anyone don't like it, I think.
> 
> In recent container use, application may be build as "stateless" and
> kill-and-respawn may not be problematic, but I think killing "a" process
> by oom-kill is too naive.
> 
> If your proposal is triggering notification to user space at hitting
> anon+swap limit, it may be useful.
> ...Some container-cluster management software can handle it.
> For example, container may be restarted.
> 
> Memcg has threshold notifier and vmpressure notifier.
> I think you can enhance it.
[...]
> My point is that "killing a process" tend not to be able to fix the situation.
> For example, fork-bomb by "make -j" cannot be handled by it.
> 
> So, I don't want to think about enhancing OOM-Kill. Please think of better
> way to survive. With the help of countainer-management-softwares, I think
> we can have several choices.
> 
> Restart contantainer (killall) may be the best if container app is stateless.
> Or container-management can provide some failover.

The problem I'm trying to set out is not about OOM actually (sorry if
the way I explain is confusing). We could probably configure OOM to kill
a whole cgroup (not just a process) and/or improve user-notification so
that the userspace could react somehow. I'm sure it must and will be
discussed one day.

The problem is that *before* invoking OOM on *global* pressure we're
trying to reclaim containers' memory and if there's progress we won't
invoke OOM. This can result in a huge slow down of the whole system (due
to swap out).

And if we want to fully make use of soft limits, we currently have no
means to limit anon memory at all. It's just impossible, because
memsw.limit must be > soft limit, otherwise it makes no sense. So we
will be trying to swap out under global pressure until we finally
realize there's no point in it and call OOM. If we don't, we'll be
suffering until the load goes away by itself.

> The 1st reason we added memsw.limit was for avoiding that the whole swap
> is used up by a cgroup where memory-leak of forkbomb running and not for
> some intellegent controls.
> 
> From your opinion, I feel what you want is avoiding charging against page-caches.
> But thiking docker at el, page-cache is not shared between containers any more.
> I think "including cache" makes sense.

Not exactly. It's not about sharing caches among containers. The point
is (1) it's difficult to estimate the size of file caches that will max
out the performance of a container, and (2) a typical workload will
perform better and put less pressure on disk if it has more caches.

Now imagine a big host running a small number of containers and
therefore having a lot of free memory most of time, but still
experiencing load spikes once an hour/day/whatever when memory usage
raises up drastically. It'd be unwise to set hard limits for those
containers that are running regularly, because they'd probably perform
much better if they had more file caches. So the admin decides to use
soft limits instead. He is forced to use memsw.limit > the soft limit,
but this is unsafe, because the container may eat anon memory up to
memsw.limit then, and anon memory isn't easy to get rid of when it comes
to the global pressure. If the admin had a mean to limit swappable
memory, he could avoid it. This is what I was trying to illustrate by
the example in the first e-mail of this thread.

Note if there were no soft limits, the current setup would be just fine,
otherwise it fails. And soft limits are proved to be useful AFAIK.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
