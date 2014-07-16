Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 44F2C6B0081
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 15:57:28 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id n12so1457145wgh.9
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 12:57:27 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id 18si423946wjt.144.2014.07.16.12.57.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 12:57:26 -0700 (PDT)
Date: Wed, 16 Jul 2014 15:57:21 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: memcg swap doesn't work in mmotm-2014-07-09-17-08?
Message-ID: <20140716195721.GC29639@cmpxchg.org>
References: <20140716181007.GA8524@nhori.redhat.com>
 <20140716183727.GB29639@cmpxchg.org>
 <20140716193129.GB8524@nhori.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140716193129.GB8524@nhori.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed, Jul 16, 2014 at 03:31:29PM -0400, Naoya Horiguchi wrote:
> On Wed, Jul 16, 2014 at 02:37:27PM -0400, Johannes Weiner wrote:
> > On Wed, Jul 16, 2014 at 02:10:07PM -0400, Naoya Horiguchi wrote:
> > > Hi,
> > >
> > > It seems that when a process in some memcg tries to allocate more than
> > > memcg.limit_in_bytes, oom happens instead of swaping out in
> > > mmotm-2014-07-09-17-08 (memcg.memsw.limit_in_bytes is large enough).
> > > It does work in v3.16-rc3, so I think latest patches changed something.
> > > I'm not familiar with memcg internally, so no idea about what caused it.
> > > Could you see the problem?
> >
> > There are a lot of changes in memory and swap accounting, but I can
> > not reproduce what you are describing: I set up a cgroup with a 100MB
> > memory limit and an unlimited memory+swap, then start a task in there
> > that faults 200MB worth of anonymous pages.  The result is 100MB in
> > memory, 100MB in swap:
> 
> Hmm, this is almost the same test condition.
> 
> > cache 0
> > rss 104267776
> > rss_huge 0
> > mapped_file 0
> > writeback 0
> > swap 105545728
> > pgpgin 26367
> > pgpgout 25950
> > pgfault 26695
> > pgmajfault 32
> > inactive_anon 52285440
> > active_anon 51982336
> > inactive_file 0
> > active_file 0
> > unevictable 0
> > hierarchical_memory_limit 104857600
> > hierarchical_memsw_limit 18446744073709551615
> >
> > Filename                                Type            Size    Used    Priority
> > /swapfile                               file            8388604 109800  -1
> >
> > Could you provide more detail on your configuration and test case?
> 
> What I did is like this:
> 
>   [root@test_140715-0036 ~]# cat tmp_memcg_swap.sh
>   cgcreate -g memory:test1
>   cgset -r memory.limit_in_bytes=0x1000000 test1        # 16 MB
>   cgset -r memory.memsw.limit_in_bytes=0x4000000 test1  # 64 MB
>   cgget -g memory:test1
>   swapon -s
>   cgexec -g memory:test1 memhog -r1 20m                 # alloc 20 MB

Okay, I tried with the smaller parameters that you use, but still
couldn't reproduce it:

cache 32768
rss 15867904
rss_huge 0
mapped_file 0
writeback 0
swap 5222400
pgpgin 1725
pgpgout 1420
pgfault 2015
pgmajfault 7
inactive_anon 10133504
active_anon 5726208
inactive_file 32768
active_file 0
unevictable 0
hierarchical_memory_limit 16777216
hierarchical_memsw_limit 67108864

16M in memory, 5M in swap, no OOM kills.

> then output is like this:
> 
>   [root@test_140715-0036 ~]# bash tmp_memcg_swap.sh
>   test1:
>   memory.pressure_level:
>   memory.kmem.max_usage_in_bytes: 0
>   memory.use_hierarchy: 1
>   memory.swappiness: 60
>   memory.memsw.failcnt: 0
>   memory.limit_in_bytes: 16777216
>   memory.memsw.max_usage_in_bytes: 0
>   memory.usage_in_bytes: 0
>   memory.memsw.limit_in_bytes: 67108864
>   memory.failcnt: 0
>   memory.kmem.limit_in_bytes: 18446744073709551615
>   memory.force_empty:
>   memory.kmem.slabinfo:
>   memory.memsw.usage_in_bytes: 0
>   memory.max_usage_in_bytes: 0
>   memory.numa_stat: total=0 N0=0 N1=0 N2=0 N3=0
>           file=0 N0=0 N1=0 N2=0 N3=0
>           anon=0 N0=0 N1=0 N2=0 N3=0
>           unevictable=0 N0=0 N1=0 N2=0 N3=0  
>           hierarchical_total=0 N0=0 N1=0 N2=0 N3=0
>           hierarchical_file=0 N0=0 N1=0 N2=0 N3=0
>           hierarchical_anon=0 N0=0 N1=0 N2=0 N3=0
>           hierarchical_unevictable=0 N0=0 N1=0 N2=0 N3=0
>   memory.kmem.tcp.limit_in_bytes: 18446744073709551615
>   memory.oom_control: oom_kill_disable 0
>           under_oom 0
>   memory.kmem.tcp.max_usage_in_bytes: 0
>   memory.kmem.failcnt: 0
>   memory.kmem.usage_in_bytes: 0
>   memory.stat: cache 0
>           rss 0
>           rss_huge 0
>           mapped_file 0
>           writeback 0
>           swap 0
>           pgpgin 0
>           pgpgout 0
>           pgfault 0
>           pgmajfault 0
>           inactive_anon 0
>           active_anon 0
>           inactive_file 0
>           active_file 0
>           unevictable 0
>           hierarchical_memory_limit 16777216
>           hierarchical_memsw_limit 67108864
>           total_cache 0
>           total_rss 0
>           total_rss_huge 0
>           total_mapped_file 0
>           total_writeback 0
>           total_swap 0
>           total_pgpgin 0
>           total_pgpgout 0
>           total_pgfault 0
>           total_pgmajfault 0
>           total_inactive_anon 0
>           total_active_anon 0
>           total_inactive_file 0
>           total_active_file 0
>           total_unevictable 0
>           recent_rotated_anon 0
>           recent_rotated_file 0
>           recent_scanned_anon 0
>           recent_scanned_file 0
>   memory.kmem.tcp.usage_in_bytes: 0
>   memory.move_charge_at_immigrate: 0
>   memory.soft_limit_in_bytes: 18446744073709551615
>   memory.kmem.tcp.failcnt: 0
>   
>   Filename                                Type            Size    Used    Priority
>   /root/page_table_walker/swapfile        file    40956   0       -1
>   ..tmp_memcg_swap.sh: line 7:  1250 Killed                  cgexec -g memory:test1 memhog -r1 20m
> 
> Kernel message is like this:
> 
>   [  425.290261] memhog invoked oom-killer: gfp_mask=0xd0, order=0, oom_score_adj=0
>   [  425.291356] memhog cpuset=/ mems_allowed=0-3
>   [  425.291992] CPU: 2 PID: 1234 Comm: memhog Not tainted 3.15.0-140716-1501-00003-gcb8370a1d76e #268

That's not mmotm-2014-07-09-17-08, though, is it?

I was running on 3.16.0-rc5-mm1-00480-gab7ca1e1e407 (latest mmots).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
