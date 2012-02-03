Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id F22846B13F0
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 04:50:42 -0500 (EST)
Date: Fri, 3 Feb 2012 17:40:36 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] memcg topics.
Message-ID: <20120203094036.GA23537@localhost>
References: <20120201095556.812db19c.kamezawa.hiroyu@jp.fujitsu.com>
 <CAHH2K0bPdqzpuWv82uyvEu4d+cDqJOYoHbw=GeP5OZk4-3gCUg@mail.gmail.com>
 <20120202063345.GA15124@localhost>
 <20120202075234.GA3039@localhost>
 <20120202103953.GE31730@quack.suse.cz>
 <20120202110433.GA24419@localhost>
 <20120202154209.GG31730@quack.suse.cz>
 <20120203012637.GA7438@localhost>
 <CAHH2K0aq=a2LGLhznoLg=jmkLNLGRq1wLM1JE5x_h9moJMy48g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHH2K0aq=a2LGLhznoLg=jmkLNLGRq1wLM1JE5x_h9moJMy48g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Jan Kara <jack@suse.cz>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, lsf-pc@lists.linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Greg,

On Thu, Feb 02, 2012 at 10:21:53PM -0800, Greg Thelen wrote:
> I am looking for a solution that partitions memory and ideally disk
> bandwidth.  This is a large undertaking and I am willing to start
> small and grow into a more sophisticated solution (if needed).  One
> important goal is to enforce per-container memory limits - this
> includes dirty and clean page cache.  Moving memcg dirty pages to root
> is probably not going to work because it would not allow for control
> of job memory usage.

If reserving 20% global memory for dirty/writeback pages from the
memcg allocations, it will do the trick: each job will use at most its
memcg limit, plus some share of the 20% dirty limit. Since the
moved pages are marked PG_reclaim and hence will be freed quickly
after become clean, it's guaranteed that the dirty pages moved out of
the memcgs won't outnumber the 20% global dirty limit at any time.

So it would be some kind of per-job memcg container plus a globally
shared 20% dirty pages container. The job pages won't further leak
and become uncontrollable.

But if this does not fit nicely into Google's usage model, I'm fine
with adding per-memcg dirty limits, bearing in mind that the per-memcg
dirty limits won't be able to work fluently if not large enough.  We
can do some experiments on that once get the minimal patch ready.

> My hunch is that we will thus need per-memcg
> dirty counters, limits, and some writeback changes.  Perhaps the
> initial writeback changes would be small: enough to ensure that
> writeback continues writing until it services any over-limit cgroups.

Yeah, that's a good plan.

> This is complicated by the fact that a memcg can have dirty memory
> spread on different bdi.

That sure sounds complicated. The other problem is the pos_ratio will
no longer be roughly equal to each other for all the tasks writing to
the same bdi, making the bdi dirty_ratelimit less stable. Again, we
can experiment how well the control system behaves.

> If blk bandwidth throttling is sufficient
> here, then let me know because it sounds easier ;)

I'd love to say so, however bandwidth throttling is obviously not the
right solution to the below example ;)

> Here is an example of a memcg OOM seen on a 3.3 kernel:
>         # mkdir /dev/cgroup/memory/x
>         # echo 100M > /dev/cgroup/memory/x/memory.limit_in_bytes
>         # echo $$ > /dev/cgroup/memory/x/tasks
>         # dd if=/dev/zero of=/data/f1 bs=1k count=1M &
>         # dd if=/dev/zero of=/data/f2 bs=1k count=1M &
>         # wait
>         [1]-  Killed                  dd if=/dev/zero of=/data/f1 bs=1M count=1k
>         [2]+  Killed                  dd if=/dev/zero of=/data/f1 bs=1M count=1k
> 
> This is caused from direct reclaim not being able to reliably reclaim
> (write) dirty page cache pages.

If moving dirty pages out of the memcg to the 20% global dirty pages
pool on page reclaim, the above OOM can be avoided. It does change the
meaning of memory.limit_in_bytes in that the memcg tasks can now
actually consume more pages (up to the shared global 20% dirty limit).

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
