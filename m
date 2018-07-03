Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5190F6B000A
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 17:15:02 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id l6-v6so1419117otj.3
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 14:15:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p133-v6sor1431482oih.28.2018.07.03.14.15.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Jul 2018 14:15:01 -0700 (PDT)
MIME-Version: 1.0
From: Petros Angelatos <petrosagg@resin.io>
Date: Wed, 4 Jul 2018 00:14:39 +0300
Message-ID: <CAM1WBjLv4tBm2nJTVo_aUrf3BkpkHrH3UpJv=C8r3V9-RO94vQ@mail.gmail.com>
Subject: Memory cgroup invokes OOM killer when there are a lot of dirty pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, lstoakes@gmail.com

Hello,

I'm facing a strange problem when I constrain an IO intensive
application that generates a lot of dirty pages inside a v1 cgroup
with a memory controller. After a while the OOM killer kicks in and
kills the processes instead of throttling the allocations while dirty
pages are being flushed. Here is a test program that reproduces the
issue:

  cd /sys/fs/cgroup/memory/
  mkdir dirty-test
  echo 10485760 > dirty-test/memory.limit_in_bytes

  echo $$ > dirty-test/cgroup.procs

  rm /mnt/file_*
  for i in $(seq 500); do
    dd if=/dev/urandom count=2048 of="/mnt/file_$i"
  done

When a process gets killed I get the following trace in dmesg:

> foo.sh invoked oom-killer: gfp_mask=0x14000c0(GFP_KERNEL), nodemask=(null), order=0, oom_score_adj=0
> foo.sh cpuset=/ mems_allowed=0
> CPU: 0 PID: 18415 Comm: foo.sh Tainted: P           O      4.17.2-1-ARCH #1
> Hardware name: LENOVO 20F9CTO1WW/20F9CTO1WW, BIOS N1CET52W (1.20 ) 11/30/2016
> Call Trace:
>  dump_stack+0x5c/0x80
>  dump_header+0x6b/0x2a1
>  ? preempt_count_add+0x68/0xa0
>  ? _raw_spin_trylock+0x13/0x50
>  oom_kill_process.cold.5+0xb/0x43b
>  out_of_memory+0x1a1/0x470
>  mem_cgroup_out_of_memory+0x49/0x80
>  mem_cgroup_oom_synchronize+0x329/0x360
>  ? __mem_cgroup_insert_exceeded+0x90/0x90
>  pagefault_out_of_memory+0x32/0x77
>  __do_page_fault+0x518/0x570
>  ? __se_sys_rt_sigaction+0x9f/0xd0
>  do_page_fault+0x32/0x130
>  ? page_fault+0x8/0x30
>  page_fault+0x1e/0x30
> RIP: 0033:0x56079824e134
> RSP: 002b:00007ffeac088fd0 EFLAGS: 00010246
> RAX: 0000000000000000 RBX: 0000000000000001 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: 00007ffeac088be0 RDI: 000056079824e720
> RBP: 00005607984ce5e0 R08: 00007ffeac088dd0 R09: 0000000000000001
> R10: 0000000000000008 R11: 0000000000000202 R12: 00005607984c9040
> R13: 000056079824e720 R14: 00005607984ce3c0 R15: 0000000000000000
> Task in /dirty-test killed as a result of limit of /dirty-test
> memory: usage 10240kB, limit 10240kB, failcnt 13073
> memory+swap: usage 10240kB, limit 9007199254740988kB, failcnt 0
> kmem: usage 1308kB, limit 9007199254740988kB, failcnt 0
> Memory cgroup stats for /dirty-test: cache:8848KB rss:180KB rss_huge:0KB shmem:0KB mapped_file:0KB dirty:8580KB writeback:0KB swap:0KB inactive_anon:0KB active_anon:200KB inactive_file:4364KB active_file:4364KB unevictable:0KB
> [ pid ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name
> [18160]     0 18160     3468      652    73728        0             0 foo.sh
> [18415]     0 18415     3468      118    61440        0             0 foo.sh
> Memory cgroup out of memory: Kill process 18160 (foo.sh) score 261 or sacrifice child
> Killed process 18415 (foo.sh) total-vm:13872kB, anon-rss:472kB, file-rss:0kB, shmem-rss:0kB
> oom_reaper: reaped process 18415 (foo.sh), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB

The cgroup v2 documentation mentions that the OOM killer will be only
be invoked when the out of memory situation happens inside a page
fault, and this problem is always happening during a page fault so
that's not surprising but I'm not sure why the process ends up in a
fatal page fault.

This is an old problem and from searching online I found that an
initial solution was implemented by Michal Hocko and Hugh Dickins in
e62e384 ("memcg:prevent OOM with too many dirty pages") and c3b94f4
("memcg: further prevent OOM with too many dirty pages") respectively
and then further tweaked by Michal to avoid possible deadlocks in
ecf5fc6 ("mm, vmscan: Do not wait for page writeback for GFP_NOFS
allocations").

This initial ad-hoc implementation was later improved by Tejun Heo in
c2aa723 ("writeback: implement memcg writeback domain based
throttling") and 97c9341 ("mm: vmscan: disable memcg direct reclaim
stalling if cgroup writeback support is in use"). According to the
commit log that change "makes the dirty throttling mechanism
operational for memcg domains including
writeback-bandwidth-proportional dirty page distribution inside them".

I verified that my kernel has cgroup writeback support enabled but
it's unclear if this is used for legacy hierarchies. But even if it's
not according to Tejun's commit the old ad-hoc method should still be
activated to throttle the process. The reason I'm using the legacy
hierarchy is because I'm running the workload in a container and
docker doesn't yet support cgroups v2
(https://github.com/moby/moby/issues/25868).

So my question is, is there a way with the current state of affairs to
constrain an IO intensive process with the goal of preventing page
cache eviction of useful pages using a memory cgroup or is the only
solution altering the application to use fsync() and
posix_fadvise(POSIX_FADV_DONTNEED)?

Best,

-- 
Petros Angelatos
CTO & Founder, Resin.io
BA81 DC1C D900 9B24 2F88  6FDD 4404 DDEE 92BF 1079
