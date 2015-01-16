Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id E3F946B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 07:33:49 -0500 (EST)
Received: by mail-la0-f52.google.com with SMTP id hs14so18682820lab.11
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 04:33:49 -0800 (PST)
Received: from mail-la0-x22e.google.com (mail-la0-x22e.google.com. [2a00:1450:4010:c03::22e])
        by mx.google.com with ESMTPS id l10si4287090lam.87.2015.01.16.04.33.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 16 Jan 2015 04:33:48 -0800 (PST)
Received: by mail-la0-f46.google.com with SMTP id ge10so8875289lab.5
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 04:33:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150116093734.GD25884@quack.suse.cz>
References: <20150115180242.10450.92.stgit@buzz>
	<20150116093734.GD25884@quack.suse.cz>
Date: Fri, 16 Jan 2015 15:33:48 +0300
Message-ID: <CALYGNiPrA1D+i+8gvMXZwAR++h7z5QLg2LkDr+zJiYNwoXkGbg@mail.gmail.com>
Subject: Re: [PATCHSET RFC 0/6] memcg: inode-based dirty-set controller
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Konstantin Khebnikov <khlebnikov@yandex-team.ru>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org, Roman Gushchin <klamm@yandex-team.ru>, Dave Chinner <david@fromorbit.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Fri, Jan 16, 2015 at 12:37 PM, Jan Kara <jack@suse.cz> wrote:
>   Hello,
>
> On Thu 15-01-15 21:49:10, Konstantin Khebnikov wrote:
>> This is ressurection of my old RFC patch for dirty-set accounting cgroup [1]
>> Now it's merged into memory cgroup and got bandwidth controller as a bonus.
>>
>> That shows alternative solution: less accurate but much less monstrous than
>> accurate page-based dirty-set controller from Tejun Heo.
>>
>> Memory overhead: +1 pointer into struct address_space.
>> Perfomance overhead is almost zero, no new locks added.
>>
>> Idea is stright forward: link each inode to some cgroup when first dirty
>> page appers and account all dirty pages to it. Writeback is implemented
>> as single per-bdi writeback work which writes only inodes which belong
>> to memory cgroups where amount of dirty memory is beyond thresholds.
>>
>> Third patch adds trick for handling shared inodes which have dirty pages
>> from several cgroups: it marks whole inode as shared and alters writeback
>> filter for it.
>>
>> The rest is an example of bandwith and iops controller build on top of that.
>> Design is completely original, I bet nobody ever used task-works for that =)
>   So I like the simplicity of your code but there are a few downsides too
> (please correct me if I've got something wrong - btw the documentation of
> high-level design would be welcome so that one doesn't have to understand
> that from the patches):

Rate-limiting design uses per-task delay injection when controller
sees that this
task or cgroup have done too much IO. This is similar to balance_dirty_pages
but this approach extends this logic to any kind of IO and doesn't
require special
point where task checks balance because delay ejected in task-work which
runs when task returns into userspace.

> 1) The bandwidth controller simply accounts number of bytes submitted for
> IO in submit_bio().  This doesn't reflect HW capabilities in any way. There
> a huge difference between a process submitting single block random IO and a
> process doing the same amount of sequential IO. This could be somewhat
> dealt with by not accounting number of bytes but rather time it took to
> complete a bio (but that somewhat complicates the code and block layer
> already does similar counting so it would be good you used that).

Yes, it is. But completion time works accurately only for simple disks
with single
depth queue. For disk with NCQ completion time often have no relation to actual
complexity of requests.

We could use it as third metric in addition to bandwidth and iops or combine all
of them into some abstract disk utilization, anyway splitting accounting and
scheduling phases gives more flexibility.

>
> 2) The controller accounts bio to current task - that makes the limiting
> useless for background writeback. You need to somehow propagate i_memcg
> into submit_bio() so that IO is properly accounted.

It would be nice to get information about randomness of issued writeback
but I think propagation disk bandwidth limit and especially iops limit
into writeback
is almost useless, we must ratelimit task which generates data flow before
it generations next bunch of dirty memory.

In some cases it's possible to slowdown writeback but journalled filesystems
often require write everything to close transaction.

>
> 3) The controller doesn't seem to guarantee any quality of service at the
> IO level like blkcg does. The controller limits amount of IO userspace is
> able to submit to kernel but only after we decide to submit the IO to disk.
> So at that time cgroup may have generated lots of IO - e.g. by dirtying lots
> of pages - and there's nothing to protect other cgroups from starvation
> because of writeback of these pages.
>
> Especially the last point seems to be essential to your approach (although
> you could somewhat mitigate the issue by accounting the IO already when
> it is entering the kernel) and I'm not sure whether that's really
> acceptable for potential users of this feature.

I try to limit amount of dirty memory and speed of generation new dirty pages
after crossing threshold. Probably it's also possible to limit speed
of switching
pages from "dirty" to "towrite" state. Thus memcg could have a lot of
dirty pages
but couldn't trigger immediate writeback for all of them.

I think it's possible to build solid io scheduler using that approach:
this controller proves only single static limits for bandwidth and
iops, but they
might be balanced automatically depending on disk speed and estimated load.

>
>                                                                 Honza
>> [1] [PATCH RFC] fsio: filesystem io accounting cgroup
>> http://marc.info/?l=linux-kernel&m=137331569501655&w=2
>>
>> Patches also available here:
>> https://github.com/koct9i/linux.git branch memcg_dirty_control
>>
>> ---
>>
>> Konstantin Khebnikov (6):
>>       memcg: inode-based dirty and writeback pages accounting
>>       memcg: dirty-set limiting and filtered writeback
>>       memcg: track shared inodes with dirty pages
>>       percpu_ratelimit: high-performance ratelimiting counter
>>       delay-injection: resource management via procrastination
>>       memcg: filesystem bandwidth controller
>>
>>
>>  block/blk-core.c                 |    2
>>  fs/direct-io.c                   |    2
>>  fs/fs-writeback.c                |   22 ++
>>  fs/inode.c                       |    1
>>  include/linux/backing-dev.h      |    1
>>  include/linux/fs.h               |   14 +
>>  include/linux/memcontrol.h       |   27 +++
>>  include/linux/percpu_ratelimit.h |   45 ++++
>>  include/linux/sched.h            |    7 +
>>  include/linux/writeback.h        |    1
>>  include/trace/events/sched.h     |    7 +
>>  include/trace/events/writeback.h |    1
>>  kernel/sched/core.c              |   66 +++++++
>>  kernel/sched/fair.c              |   12 +
>>  lib/Makefile                     |    1
>>  lib/percpu_ratelimit.c           |  168 +++++++++++++++++
>>  mm/memcontrol.c                  |  381 ++++++++++++++++++++++++++++++++++++++
>>  mm/page-writeback.c              |   32 +++
>>  mm/readahead.c                   |    2
>>  mm/truncate.c                    |    1
>>  mm/vmscan.c                      |    4
>>  21 files changed, 787 insertions(+), 10 deletions(-)
>>  create mode 100644 include/linux/percpu_ratelimit.h
>>  create mode 100644 lib/percpu_ratelimit.c
>>
>> --
>> Signature
> --
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
