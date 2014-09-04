Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6751F6B0036
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 18:05:48 -0400 (EDT)
Received: by mail-ie0-f172.google.com with SMTP id rd18so12558086iec.31
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 15:05:48 -0700 (PDT)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id td1si245950pbc.140.2014.09.04.15.05.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 04 Sep 2014 15:05:47 -0700 (PDT)
Received: from kw-mxoi2.gw.nic.fujitsu.com (unknown [10.0.237.143])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 140A33EE181
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 07:05:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 4AFAAAC08E4
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 07:05:44 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DAE95E08001
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 07:05:43 +0900 (JST)
Message-ID: <5408E1CD.3090004@jp.fujitsu.com>
Date: Fri, 05 Sep 2014 07:03:57 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC] memory cgroup: my thoughts on memsw
References: <20140904143055.GA20099@esperanza>
In-Reply-To: <20140904143055.GA20099@esperanza>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>
Cc: Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Glauber Costa <glommer@gmail.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@parallels.com>, Konstantin Khorenko <khorenko@parallels.com>, LKML-MM <linux-mm@kvack.org>, LKML-cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

(2014/09/04 23:30), Vladimir Davydov wrote:
> Hi,
>
> Over its long history the memory cgroup has been developed rapidly, but
> rather in a disordered manner. As a result, today we have a bunch of
> features that are practically unusable and wants redesign (soft limits)
> or even not working (kmem accounting), not talking about the messy user
> interface we have (the _in_bytes suffix is driving me mad :-).
>
> Fortunately, thanks to Tejun's unified cgroup hierarchy, we have a great
> chance to drop or redesign some of the old features and their
> interfaces. We should use this opportunity to examine every aspect of
> the memory cgroup design, because we will probably not be granted such a
> present in future.
>
> That's why I'm starting a series of RFC's with *my thoughts* not only on
> kmem accounting, which I've been trying to fix for a while, but also on
> other parts of the memory cgroup. I'll be happy if anybody reads this to
> the end, but please don't kick me too hard if something will look stupid
> to you :-)
>
>
> Today's topic is (surprisingly!) the memsw resource counter and where it
> fails to satisfy user requests.
>
> Let's start from the very beginning. The memory cgroup has basically two
> resource counters (not counting kmem, which is unusable anyway):
> mem_cgroup->res (configured by memory.limit), which counts the total
> amount of user pages charged to the cgroup, and mem_cgroup->memsw
> (memory.memsw.limit), which is basically res + the cgroup's swap usage.
> Obviously, memsw always has both the value and limit less than the value
> and limit of res. That said, we have three options:
>
>   - memory.limit=inf, memory.memsw.limit=inf
>     No limits, only accounting.
>
>   - memory.limit=L<inf, memory.memsw.limit=inf
>     Not allowed to use more than L bytes of user pages, but use as much
>     swap as you want.
>
>   - memory.limit=L<inf, memory.memsw.limit=S<inf, L<=S
>     Not allowed to use more than L bytes of user memory. Swap *plus*
>     memory usage is limited by S.
>
> When it comes to *hard* limits everything looks fine, but hard limits
> are not efficient for partitioning a large system among lots of
> containers, because it's hard to predict the right value for the limit,
> besides many workloads will do better when they are granted more file
> caches. There we need a kind of soft limit that is only used on global
> memory pressure to shrink containers exceeding it.
>
>
> Obviously the soft limit must be less than memory.limit and therefore
> memory.memsw.limit. And here comes a problem. Suppose admin sets a
> relatively high memsw.limit (say half of RAM) and a low soft limit for a
> container hoping it will use it for file caches when there's free
> memory, but when hard times come it will be shrunk back to the soft
> limit quickly. Suppose the container, instead of using the granted
> memory for caches, creates a lot of anonymous data filling up to its
> memsw limit (i.e. half of RAM). Then, when admin starts other
> containers, he might find out that they are effectively using only half
> of RAM. Why can this happen? See below.
>
> For example, if there's no or a little swap. It's pretty common for
> customers not to bother about creating TBs of swap to back TBs of RAM
> they have. One might propose to issue OOM if we can't reclaim anything
> from a container exceeding its soft limit. OK, let it be so, although
> it's still not agreed upon AFAIK.
>
> Another case. There's plenty of swap space out there so that we can swap
> out the guilty container completely. However, it will take us some
> reasonable amount of time especially if the container isn't standing
> still, but keeps touching its data. If other containers are mostly using
> file caches, they will experience heavy pressure for a long time, not
> saying about the slowdown caused by high disk usage. Unfair. One might
> object that we can set a limit on IO operations for the culprit (more
> limits and dependencies among them, I doubt admins will be happy!). This
> will slow it down and guarantee it won't be swapping back in pages that
> are being swapped out due to high memory pressure. However, disks have
> limited speed. That means, it doesn't solve the problem with unfair
> slowdown of other containers. What is worse, if we impose IO limit we
> will slow down swap out by ourselves! Because we shouldn't ignore IO
> limit for swap out, otherwise the system will be prune to DOS attacks
> targeted on disk from inside containers, which is what IO limit (as well
> as any other limit) is to protect against.
>
> Or perhaps, I'm missing something and malicious behaviour isn't
> considered when developing cgroups?!
>
>
> To sum it up, the current mem + memsw configuration scheme doesn't allow
> us to limit swap usage if we want to partition the system dynamically
> using soft limits. Actually, it also looks rather confusing to me. We
> have mem limit and mem+swap limit. I bet that from the first glance, an
> average admin will think it's possible to limit swap usage by setting
> the limits so that the difference between memory.memsw.limit and
> memory.limit equals the maximal swap usage, but (surprise!) it isn't
> really so. It holds if there's no global memory pressure, but otherwise
> swap usage is only limited by memory.memsw.limit! IMHO, it isn't
> something obvious.
>
>
> Finally, my understanding (may be crazy!) how the things should be
> configured. Just like now, there should be mem_cgroup->res accounting
> and limiting total user memory (cache+anon) usage for processes inside
> cgroups. This is where there's nothing to do. However, mem_cgroup->memsw
> should be reworked to account *only* memory that may be swapped out plus
> memory that has been swapped out (i.e. swap usage).
>
> This way, by setting memsw.limit (or how it should be called) less than
> memory soft limit we would solve the problem I described above. The
> container would be then allowed to use only file caches above its
> memsw.limit, which are usually easily shrinkable, and get OOM-kill while
> trying to eat too much swappable memory.
>
> The configuration will also be less confusing then IMO:
>
>   - memory.limit - container can't use memory above this
>   - memory.memsw.limit - container can't use swappable memory above this
>
>  From this it clearly follows maximal swap usage is limited by
> memory.memsw.limit.
>
> One more thought. Anon memory and file caches are different and should
> be handled differently, so mixing them both under the same counter looks
> strange to me. Moreover, they are *already* handled differently
> throughout the kernel - just look at mm/vmscan.c. Here are the
> differences between them I see:
>
>   - Anon memory is handled by the user application, while file caches are
>     all on the kernel. That means the application will *definitely* die
>     w/o anon memory. W/o file caches it usually can survive, but the more
>     caches it has the better it feels.
>
>   - Anon memory is not that easy to reclaim. Swap out is a really slow
>     process, because data are usually read/written w/o any specific
>     order. Dropping file caches is much easier. Typically we have lots of
>     clean pages there.
>
>   - Swap space is limited. And today, it's OK to have TBs of RAM and only
>     several GBs of swap. Customers simply don't want to waste their disk
>     space on that.
>
> IMO, these lead us to the need for limiting swap/swappable memory usage,
> but not swap+mem usage.
>
>
> Now, a bad thing about such a change (if it were ever considered).
> There's no way to convert old settings to new, i.e. if we currently have
>
>    mem <= L,
>    mem + swap <= S,
>    L <= S,
>
> we can set
>
>    mem <= L1,
>    swappable_mem <= S1,
>
> where either
>
> L1 = L, S1 = S
>
> or
>
> L1 = L, S1 = S - L,
>
> but both configurations won't be exactly the same. In the first case
> memory+swap usage will be limited by L+S, not by S. In the second case,
> although memory+swap<S, the container won't be able to use more than S-L
> anonymous memory. This is the price we would have to pay if we decided
> to go with this change...
>
>
> Questions, comments, complains, threats?
>

If one hits anon+swap limit, it just means OOM. Hitting limit means process's death.
Is it useful ?

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
