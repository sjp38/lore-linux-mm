Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6EFB56B0007
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 03:50:23 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id f81-v6so2326863pfd.7
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 00:50:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n34-v6si2828476pgm.28.2018.07.04.00.50.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 00:50:22 -0700 (PDT)
Date: Wed, 4 Jul 2018 09:50:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Memory cgroup invokes OOM killer when there are a lot of dirty
 pages
Message-ID: <20180704075018.GE22503@dhcp22.suse.cz>
References: <CAM1WBjLv4tBm2nJTVo_aUrf3BkpkHrH3UpJv=C8r3V9-RO94vQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAM1WBjLv4tBm2nJTVo_aUrf3BkpkHrH3UpJv=C8r3V9-RO94vQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petros Angelatos <petrosagg@resin.io>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, lstoakes@gmail.com

On Wed 04-07-18 00:14:39, Petros Angelatos wrote:
> Hello,
> 
> I'm facing a strange problem when I constrain an IO intensive
> application that generates a lot of dirty pages inside a v1 cgroup
> with a memory controller. After a while the OOM killer kicks in and
> kills the processes instead of throttling the allocations while dirty
> pages are being flushed. Here is a test program that reproduces the
> issue:
> 
>   cd /sys/fs/cgroup/memory/
>   mkdir dirty-test
>   echo 10485760 > dirty-test/memory.limit_in_bytes
> 
>   echo $$ > dirty-test/cgroup.procs
> 
>   rm /mnt/file_*
>   for i in $(seq 500); do
>     dd if=/dev/urandom count=2048 of="/mnt/file_$i"
>   done
> 
> When a process gets killed I get the following trace in dmesg:
> 
> > foo.sh invoked oom-killer: gfp_mask=0x14000c0(GFP_KERNEL), nodemask=(null), order=0, oom_score_adj=0
> > foo.sh cpuset=/ mems_allowed=0
> > CPU: 0 PID: 18415 Comm: foo.sh Tainted: P           O      4.17.2-1-ARCH #1
> > Hardware name: LENOVO 20F9CTO1WW/20F9CTO1WW, BIOS N1CET52W (1.20 ) 11/30/2016
[...]
> > Task in /dirty-test killed as a result of limit of /dirty-test
> > memory: usage 10240kB, limit 10240kB, failcnt 13073
> > memory+swap: usage 10240kB, limit 9007199254740988kB, failcnt 0
> > kmem: usage 1308kB, limit 9007199254740988kB, failcnt 0
> > Memory cgroup stats for /dirty-test: cache:8848KB rss:180KB rss_huge:0KB shmem:0KB mapped_file:0KB dirty:8580KB writeback:0KB swap:0KB inactive_anon:0KB active_anon:200KB inactive_file:4364KB active_file:4364KB unevictable:0KB
> > [ pid ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name
> > [18160]     0 18160     3468      652    73728        0             0 foo.sh
> > [18415]     0 18415     3468      118    61440        0             0 foo.sh
> > Memory cgroup out of memory: Kill process 18160 (foo.sh) score 261 or sacrifice child
> > Killed process 18415 (foo.sh) total-vm:13872kB, anon-rss:472kB, file-rss:0kB, shmem-rss:0kB
> > oom_reaper: reaped process 18415 (foo.sh), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> 
> The cgroup v2 documentation mentions that the OOM killer will be only
> be invoked when the out of memory situation happens inside a page
> fault, and this problem is always happening during a page fault so
> that's not surprising but I'm not sure why the process ends up in a
> fatal page fault.

I assume dd just tried to fault a code page in and that failed due to
the hard limit and unreclaimable memory. The reason why the memcg v1
oom throttling heuristic hasn't kicked in is that there are no pages
under writeback. This would match symptoms of the bug fixed by
1c610d5f93c7 ("mm/vmscan: wake up flushers for legacy cgroups too") in
4.16 but there might be more. You should have that fix already so there
must be something more in the game. You've said that you are using blkio
cgroup, right? What is the configuration? I strongly suspect that none
of the writeback has started because of the throttling.

-- 
Michal Hocko
SUSE Labs
