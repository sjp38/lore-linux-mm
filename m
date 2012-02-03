Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 514AB6B13F0
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 01:22:14 -0500 (EST)
Received: by vbip1 with SMTP id p1so3076647vbi.14
        for <linux-mm@kvack.org>; Thu, 02 Feb 2012 22:22:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120203012637.GA7438@localhost>
References: <20120201095556.812db19c.kamezawa.hiroyu@jp.fujitsu.com>
 <CAHH2K0bPdqzpuWv82uyvEu4d+cDqJOYoHbw=GeP5OZk4-3gCUg@mail.gmail.com>
 <20120202063345.GA15124@localhost> <20120202075234.GA3039@localhost>
 <20120202103953.GE31730@quack.suse.cz> <20120202110433.GA24419@localhost>
 <20120202154209.GG31730@quack.suse.cz> <20120203012637.GA7438@localhost>
From: Greg Thelen <gthelen@google.com>
Date: Thu, 2 Feb 2012 22:21:53 -0800
Message-ID: <CAHH2K0aq=a2LGLhznoLg=jmkLNLGRq1wLM1JE5x_h9moJMy48g@mail.gmail.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] memcg topics.
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, lsf-pc@lists.linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Thu, Feb 2, 2012 at 5:26 PM, Wu Fengguang <fengguang.wu@intel.com> wrote=
:
> On Thu, Feb 02, 2012 at 04:42:09PM +0100, Jan Kara wrote:
>> On Thu 02-02-12 19:04:34, Wu Fengguang wrote:
>> > If memcg A's dirty rate is throttled, its dirty pages will naturally
>> > shrink. The flusher will automatically work less on A's dirty pages.
>> I'm not sure about details of requirements Google guys have. So this may
>> or may not be good enough for them. I'd suspect they still wouldn't want
>> one cgroup to fill up available page cache with dirty pages so just
>> limitting bandwidth won't be enough for them. Also limitting dirty
>> bandwidth has a problem that it's not coupled with how much reading the
>> particular cgroup does. Anyway, until we are sure about their exact
>> requirements, this is mostly philosophical talking ;).
>
> Yeah, I'm not sure what exactly Google needs and how big problem the
> partition will be for them. Basically,
>
> - when there are N memcg each dirtying 1 file, each file will be
> =A0flushed on every (N * 0.5) seconds, where 0.5s is the typical time
>
> - if (memcg_dirty_limit > 10 * bdi_bandwidth), the dd tasks should be
> =A0able to progress reasonably smoothly
>
> Thanks,
> Fengguang

I am looking for a solution that partitions memory and ideally disk
bandwidth.  This is a large undertaking and I am willing to start
small and grow into a more sophisticated solution (if needed).  One
important goal is to enforce per-container memory limits - this
includes dirty and clean page cache.  Moving memcg dirty pages to root
is probably not going to work because it would not allow for control
of job memory usage.  My hunch is that we will thus need per-memcg
dirty counters, limits, and some writeback changes.  Perhaps the
initial writeback changes would be small: enough to ensure that
writeback continues writing until it services any over-limit cgroups.
This is complicated by the fact that a memcg can have dirty memory
spread on different bdi.  If blk bandwidth throttling is sufficient
here, then let me know because it sounds easier ;)

Here is an example of a memcg OOM seen on a 3.3 kernel:
        # mkdir /dev/cgroup/memory/x
        # echo 100M > /dev/cgroup/memory/x/memory.limit_in_bytes
        # echo $$ > /dev/cgroup/memory/x/tasks
        # dd if=3D/dev/zero of=3D/data/f1 bs=3D1k count=3D1M &
        # dd if=3D/dev/zero of=3D/data/f2 bs=3D1k count=3D1M &
        # wait
        [1]-  Killed                  dd if=3D/dev/zero of=3D/data/f1 bs=3D=
1M count=3D1k
        [2]+  Killed                  dd if=3D/dev/zero of=3D/data/f1 bs=3D=
1M count=3D1k

This is caused from direct reclaim not being able to reliably reclaim
(write) dirty page cache pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
