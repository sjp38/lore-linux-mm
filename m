Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id BD9436B0062
	for <linux-mm@kvack.org>; Sun, 25 Nov 2012 07:05:28 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so4083865eaa.14
        for <linux-mm@kvack.org>; Sun, 25 Nov 2012 04:05:27 -0800 (PST)
Date: Sun, 25 Nov 2012 13:05:24 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memory-cgroup bug
Message-ID: <20121125120524.GB10623@dhcp22.suse.cz>
References: <20121121200207.01068046@pobox.sk>
 <20121122152441.GA9609@dhcp22.suse.cz>
 <20121122190526.390C7A28@pobox.sk>
 <20121122214249.GA20319@dhcp22.suse.cz>
 <20121122233434.3D5E35E6@pobox.sk>
 <20121123074023.GA24698@dhcp22.suse.cz>
 <20121123102137.10D6D653@pobox.sk>
 <20121123100438.GF24698@dhcp22.suse.cz>
 <20121125011047.7477BB5E@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121125011047.7477BB5E@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

[Adding Kamezawa into CC]

On Sun 25-11-12 01:10:47, azurIt wrote:
> >Could you take few snapshots over time?
> 
> 
> Here it is, now from different server, snapshot was taken every second
> for 10 minutes (hope it's enough):
> www.watchdog.sk/lkml/memcg-bug-2.tar.gz

Hmm, interesting:
$ grep . */memory.failcnt | cut -d: -f2 | awk 'BEGIN{min=666666}{if (prev>0) {diff=$1-prev; if (diff>max) max=diff; if (diff<min) min=diff; sum+=diff; n++} prev=$1}END{printf "min:%d max:%d avg:%f\n", min, max, sum/n}'
min:16281 max:224048 avg:18818.943119

So there is a lot of attempts to allocate which fail, every second!
Will get to that later.

The number of tasks in the group is stable (20):
$ for i in *; do ls -d1 $i/[0-9]* | wc -l; done | sort | uniq -c
    546 20

And no task has been killed or spawned:
$ for i in *; do ls -d1 $i/[0-9]* | cut -d/ -f2; done | sort | uniq
24495
24762
24774
24796
24798
24805
24813
24827
24831
24841
24842
24863
24892
24924
24931
25130
25131
25192
25193
25243

$ for stack in [0-9]*/[0-9]*
do 
	head -n1 $stack/stack
done | sort | uniq -c
   9841 [<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
    546 [<ffffffff811109b8>] do_truncate+0x58/0xa0
    533 [<ffffffffffffffff>] 0xffffffffffffffff

Tells us that the stacks are pretty much stable.
$ grep do_truncate -r [0-9]* | cut -d/ -f2 | sort | uniq -c
    546 24495

So 24495 is stuck in do_truncate
[<ffffffff811109b8>] do_truncate+0x58/0xa0
[<ffffffff81121c90>] do_last+0x250/0xa30
[<ffffffff81122547>] path_openat+0xd7/0x440
[<ffffffff811229c9>] do_filp_open+0x49/0xa0
[<ffffffff8110f7d6>] do_sys_open+0x106/0x240
[<ffffffff8110f950>] sys_open+0x20/0x30
[<ffffffff815b5926>] system_call_fastpath+0x18/0x1d
[<ffffffffffffffff>] 0xffffffffffffffff

I suspect it is waiting for i_mutex. Who is holding that lock?
Other tasks are blocked on the mem_cgroup_handle_oom either coming from
the page fault path so i_mutex can be exluded or vfs_write (24796) and
that one is interesting:
[<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
[<ffffffff8110b5ab>] T.1146+0x5ab/0x5c0
[<ffffffff8110c22e>] mem_cgroup_cache_charge+0xbe/0xe0
[<ffffffff810ca28c>] add_to_page_cache_locked+0x4c/0x140
[<ffffffff810ca3a2>] add_to_page_cache_lru+0x22/0x50
[<ffffffff810ca45b>] grab_cache_page_write_begin+0x8b/0xe0
[<ffffffff81193a18>] ext3_write_begin+0x88/0x270
[<ffffffff810c8fc6>] generic_file_buffered_write+0x116/0x290
[<ffffffff810cb3cc>] __generic_file_aio_write+0x27c/0x480
[<ffffffff810cb646>] generic_file_aio_write+0x76/0xf0		# takes &inode->i_mutex
[<ffffffff8111156a>] do_sync_write+0xea/0x130
[<ffffffff81112183>] vfs_write+0xf3/0x1f0
[<ffffffff81112381>] sys_write+0x51/0x90
[<ffffffff815b5926>] system_call_fastpath+0x18/0x1d
[<ffffffffffffffff>] 0xffffffffffffffff

This smells like a deadlock. But kind strange one. The rapidly
increasing failcnt suggests that somebody still tries to allocate but
who when all of them hung in the mem_cgroup_handle_oom. This can be
explained though.
Memcg OOM killer let's only one process (which is able to lock the
hierarchy by mem_cgroup_oom_lock) call mem_cgroup_out_of_memory and kill
a process, while others are waiting on the wait queue. Once the killer
is done it calls memcg_wakeup_oom which wakes up other tasks waiting on
the queue. Those retry the charge, in a hope there is some memory freed
in the meantime which hasn't happened so they get into OOM again (and
again and again).
This all usually works out except in this particular case I would bet
my hat that the OOM selected task is pid 24495 which is blocked on the
mutex which is held by one of the oom killer task so it cannot finish -
thus free a memory.

It seems that the current Linus' tree is affected as well.

I will have to think about a solution but it sounds really tricky. It is
not just ext3 that is affected.

I guess we need to tell mem_cgroup_cache_charge that it should never
reach OOM from add_to_page_cache_locked. This sounds quite intrusive to
me. On the other hand it is really weird that an excessive writer might
trigger a memcg OOM killer.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
