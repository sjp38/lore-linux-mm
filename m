Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 96BBC6B0253
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 13:41:02 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a4so75144637lfa.1
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 10:41:02 -0700 (PDT)
Received: from mail-lf0-x236.google.com (mail-lf0-x236.google.com. [2a00:1450:4010:c07::236])
        by mx.google.com with ESMTPS id i71si649732lfe.2.2016.07.11.10.40.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jul 2016 10:40:58 -0700 (PDT)
Received: by mail-lf0-x236.google.com with SMTP id f93so27829732lfi.2
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 10:40:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160711064150.GB5284@dhcp22.suse.cz>
References: <CABAubThf6gbi243BqYgoCjqRW36sXJuJ6e_8zAqzkYRiu0GVtQ@mail.gmail.com>
 <20160711064150.GB5284@dhcp22.suse.cz>
From: Shayan Pooya <shayan@liveve.org>
Date: Mon, 11 Jul 2016 10:40:55 -0700
Message-ID: <CABAubThHfngHTQW_AEuW71VCvLyD_9b5Z05tSud5bf8JKjuA9Q@mail.gmail.com>
Subject: Re: bug in memcg oom-killer results in a hung syscall in another
 process in the same cgroup
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: cgroups mailinglist <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

>
> Could you post the stack trace of the hung oom victim? Also could you
> post the full kernel log?

Here is the stack of the process that lives (it is *not* the
oom-victim) in a run with 100 processes and *without* strace:

# cat /proc/7688/stack
[<ffffffff81100292>] futex_wait_queue_me+0xc2/0x120
[<ffffffff811005a6>] futex_wait+0x116/0x280
[<ffffffff81102d90>] do_futex+0x120/0x540
[<ffffffff81103231>] SyS_futex+0x81/0x180
[<ffffffff81825bf2>] entry_SYSCALL_64_fastpath+0x16/0x71
[<ffffffffffffffff>] 0xffffffffffffffff

Also:
# pgrep call-mem-hog | wc -l
30

they are all like:
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root      7570  0.0  0.0   4508   100 pts/9    S    10:14   0:00
/bin/sh ./call-mem-hog /sys/fs/cgroup/memory/1/cgroup.procs

# cat /sys/fs/cgroup/memory/1/cgroup.procs  | wc -l
30

# uname -a
Linux sanblas 4.4.0-24-generic #43-Ubuntu SMP Wed Jun 8 19:27:37 UTC
2016 x86_64 x86_64 x86_64 GNU/Linux

root@sanblas:~/oom_stuff# grep 'Killed process' kern.log  | wc -l
64


The full kern.log and the output of (echo t > /proc/sysrq-trigger) are
available at https://gist.github.com/pooya/da6fce58ce546c7a3631b2eb16152c0c
The kernel log for the oom-kills is pasted here:

-- Logs begin at Mon 2016-07-11 10:00:25 PDT. --
Jul 11 10:05:09 sanblas systemd[1]: Stopping CUPS Scheduler...
Jul 11 10:05:10 sanblas systemd[1]: Stopped CUPS Scheduler.
Jul 11 10:05:10 sanblas systemd[1]: Started CUPS Scheduler.
Jul 11 10:05:35 sanblas anacron[840]: Job `cron.daily' terminated
(mailing output)
Jul 11 10:05:35 sanblas anacron[840]: anacron: Can't find sendmail at
/usr/sbin/sendmail, not mailing output
Jul 11 10:05:35 sanblas anacron[840]: Can't find sendmail at
/usr/sbin/sendmail, not mailing output
Jul 11 10:10:26 sanblas anacron[840]: Job `cron.weekly' started
Jul 11 10:10:26 sanblas anacron[3456]: Updated timestamp for job
`cron.weekly' to 2016-07-11
Jul 11 10:10:48 sanblas anacron[840]: Job `cron.weekly' terminated
Jul 11 10:10:48 sanblas anacron[840]: Normal exit (2 jobs run)
Jul 11 10:14:02 sanblas kernel: mem-hog invoked oom-killer:
gfp_mask=0x24000c0, order=0, oom_score_adj=0
Jul 11 10:14:02 sanblas kernel: mem-hog cpuset=/ mems_allowed=0
Jul 11 10:14:02 sanblas kernel: CPU: 6 PID: 7546 Comm: mem-hog Not
tainted 4.4.0-24-generic #43-Ubuntu
Jul 11 10:14:02 sanblas kernel: Hardware name: Dell Inc. OptiPlex
9020/00V62H, BIOS A10 01/08/2015
Jul 11 10:14:02 sanblas kernel:  0000000000000286 000000002feb37d8
ffff8801da493c88 ffffffff813eab23
Jul 11 10:14:02 sanblas kernel:  ffff8801da493d68 ffff8802134e44c0
ffff8801da493cf8 ffffffff8120906e
Jul 11 10:14:02 sanblas kernel:  ffff8801da493d10 ffff8801da493cc8
ffffffff81190b3b ffff8800c0346e00
Jul 11 10:14:02 sanblas kernel: Call Trace:
Jul 11 10:14:02 sanblas kernel:  [<ffffffff813eab23>] dump_stack+0x63/0x90
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8120906e>] dump_header+0x5a/0x1c5
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81190b3b>] ?
find_lock_task_mm+0x3b/0x80
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81191102>]
oom_kill_process+0x202/0x3c0
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811fce94>] ?
mem_cgroup_iter+0x204/0x390
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811feef3>]
mem_cgroup_out_of_memory+0x2b3/0x300
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811ffcc8>]
mem_cgroup_oom_synchronize+0x338/0x350
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811fb1f0>] ?
kzalloc_node.constprop.48+0x20/0x20
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811917b4>]
pagefault_out_of_memory+0x44/0xc0
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b2c2>] mm_fault_error+0x82/0x160
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b778>]
__do_page_fault+0x3d8/0x400
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b7c2>] do_page_fault+0x22/0x30
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81827d78>] page_fault+0x28/0x30
Jul 11 10:14:02 sanblas kernel: Task in /1 killed as a result of limit of /1
Jul 11 10:14:02 sanblas kernel: memory: usage 1048576kB, limit
1048576kB, failcnt 92
Jul 11 10:14:02 sanblas kernel: memory+swap: usage 0kB, limit
9007199254740988kB, failcnt 0
Jul 11 10:14:02 sanblas kernel: kmem: usage 0kB, limit
9007199254740988kB, failcnt 0
Jul 11 10:14:02 sanblas kernel: Memory cgroup stats for /1: cache:0KB
rss:1048576KB rss_huge:0KB mapped_file:0KB dirty:0KB writeback:0KB
inactive_anon:362496KB active_anon:684160KB inactive_file:0KB
active_file:0KB unevictable:0KB
Jul 11 10:14:02 sanblas kernel: [ pid ]   uid  tgid total_vm      rss
nr_ptes nr_pmds swapents oom_score_adj name
Jul 11 10:14:02 sanblas kernel: [ 7536]     0  7536    35261    32488
    75       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7538]     0  7538    26483    23679
    58       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7540]     0  7540    32852    30110
    70       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7542]     0  7542    25229    22435
    56       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7544]     0  7544    21896    19089
    46       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7546]     0  7546    31235    28465
    64       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7548]     0  7548    25163    22380
    55       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7550]     0  7550    16187    13404
    37       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7552]     0  7552    16121    13346
    37       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7554]     0  7554    24206    21392
    52       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7556]     0  7556    18431    15621
    41       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7558]     0  7558    11864     9037
    26       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7560]     0  7560    11006     8249
    28       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7562]     0  7562     8894     6100
    21       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7564]     0  7564     6221     3427
    16       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7566]     0  7566     1127       24
     8       3        0             0 call-mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7567]     0  7567     1127      198
     8       3        0             0 call-mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7568]     0  7568     1127       25
     5       3        0             0 call-mem-hog
Jul 11 10:14:02 sanblas kernel: Memory cgroup out of memory: Kill
process 7536 (mem-hog) score 120 or sacrifice child
Jul 11 10:14:02 sanblas kernel: Killed process 7536 (mem-hog)
total-vm:141044kB, anon-rss:127864kB, file-rss:2088kB
Jul 11 10:14:02 sanblas kernel: mem-hog invoked oom-killer:
gfp_mask=0x24000c0, order=0, oom_score_adj=0
Jul 11 10:14:02 sanblas kernel: mem-hog cpuset=/ mems_allowed=0
Jul 11 10:14:02 sanblas kernel: CPU: 5 PID: 7540 Comm: mem-hog Not
tainted 4.4.0-24-generic #43-Ubuntu
Jul 11 10:14:02 sanblas kernel: Hardware name: Dell Inc. OptiPlex
9020/00V62H, BIOS A10 01/08/2015
Jul 11 10:14:02 sanblas kernel:  0000000000000286 000000009c7c8bd0
ffff8800c00a7c88 ffffffff813eab23
Jul 11 10:14:02 sanblas kernel:  ffff8800c00a7d68 ffff8801efbab700
ffff8800c00a7cf8 ffffffff8120906e
Jul 11 10:14:02 sanblas kernel:  ffff88021eb56d00 ffff8800c00a7cc8
ffffffff81190b3b ffff8801f8806e00
Jul 11 10:14:02 sanblas kernel: Call Trace:
Jul 11 10:14:02 sanblas kernel:  [<ffffffff813eab23>] dump_stack+0x63/0x90
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8120906e>] dump_header+0x5a/0x1c5
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81190b3b>] ?
find_lock_task_mm+0x3b/0x80
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81191102>]
oom_kill_process+0x202/0x3c0
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811fce94>] ?
mem_cgroup_iter+0x204/0x390
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811feef3>]
mem_cgroup_out_of_memory+0x2b3/0x300
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811ffcc8>]
mem_cgroup_oom_synchronize+0x338/0x350
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811fb1f0>] ?
kzalloc_node.constprop.48+0x20/0x20
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811917b4>]
pagefault_out_of_memory+0x44/0xc0
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b2c2>] mm_fault_error+0x82/0x160
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b778>]
__do_page_fault+0x3d8/0x400
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b7c2>] do_page_fault+0x22/0x30
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81827d78>] page_fault+0x28/0x30
Jul 11 10:14:02 sanblas kernel: Task in /1 killed as a result of limit of /1
Jul 11 10:14:02 sanblas kernel: memory: usage 1048576kB, limit
1048576kB, failcnt 207
Jul 11 10:14:02 sanblas kernel: memory+swap: usage 0kB, limit
9007199254740988kB, failcnt 0
Jul 11 10:14:02 sanblas kernel: kmem: usage 0kB, limit
9007199254740988kB, failcnt 0
Jul 11 10:14:02 sanblas kernel: Memory cgroup stats for /1: cache:0KB
rss:1048576KB rss_huge:0KB mapped_file:0KB dirty:0KB writeback:0KB
inactive_anon:524908KB active_anon:523284KB inactive_file:0KB
active_file:0KB unevictable:0KB
Jul 11 10:14:02 sanblas kernel: [ pid ]   uid  tgid total_vm      rss
nr_ptes nr_pmds swapents oom_score_adj name
Jul 11 10:14:02 sanblas kernel: [ 7538]     0  7538    27869    25065
    60       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7540]     0  7540    34238    31496
    72       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7542]     0  7542    26648    23821
    58       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7544]     0  7544    24602    21861
    51       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7546]     0  7546    34007    31236
    69       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7548]     0  7548    27143    24360
    59       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7550]     0  7550    18893    16110
    42       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7552]     0  7552    17507    14731
    40       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7554]     0  7554    25559    22777
    54       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7556]     0  7556    19784    17007
    43       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7558]     0  7558    13943    11148
    30       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7560]     0  7560    15197    12407
    36       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7562]     0  7562    11633     8871
    26       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7564]     0  7564     9554     6793
    22       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7566]     0  7566     4439     1640
    14       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7568]     0  7568     1127       25
     6       3        0             0 call-mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7569]     0  7569     1127      177
     8       3        0             0 call-mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7570]     0  7570     1127       25
     5       3        0             0 call-mem-hog
Jul 11 10:14:02 sanblas kernel: Memory cgroup out of memory: Kill
process 7540 (mem-hog) score 116 or sacrifice child
Jul 11 10:14:02 sanblas kernel: Killed process 7540 (mem-hog)
total-vm:136952kB, anon-rss:123912kB, file-rss:2072kB
Jul 11 10:14:02 sanblas kernel: mem-hog invoked oom-killer:
gfp_mask=0x24000c0, order=0, oom_score_adj=0
Jul 11 10:14:02 sanblas kernel: mem-hog cpuset=/ mems_allowed=0
Jul 11 10:14:02 sanblas kernel: CPU: 7 PID: 7560 Comm: mem-hog Not
tainted 4.4.0-24-generic #43-Ubuntu
Jul 11 10:14:02 sanblas kernel: Hardware name: Dell Inc. OptiPlex
9020/00V62H, BIOS A10 01/08/2015
Jul 11 10:14:02 sanblas kernel:  0000000000000286 00000000d75ee657
ffff8800c29cbc88 ffffffff813eab23
Jul 11 10:14:02 sanblas kernel:  ffff8800c29cbd68 ffff8801ef8a1b80
ffff8800c29cbcf8 ffffffff8120906e
Jul 11 10:14:02 sanblas kernel:  ffff88021ebd6d00 ffff8800c29cbcc8
ffffffff81190b3b ffff8801f8806e00
Jul 11 10:14:02 sanblas kernel: Call Trace:
Jul 11 10:14:02 sanblas kernel:  [<ffffffff813eab23>] dump_stack+0x63/0x90
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8120906e>] dump_header+0x5a/0x1c5
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81190b3b>] ?
find_lock_task_mm+0x3b/0x80
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81191102>]
oom_kill_process+0x202/0x3c0
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811fce94>] ?
mem_cgroup_iter+0x204/0x390
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811feef3>]
mem_cgroup_out_of_memory+0x2b3/0x300
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811ffcc8>]
mem_cgroup_oom_synchronize+0x338/0x350
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811fb1f0>] ?
kzalloc_node.constprop.48+0x20/0x20
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811917b4>]
pagefault_out_of_memory+0x44/0xc0
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b2c2>] mm_fault_error+0x82/0x160
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b778>]
__do_page_fault+0x3d8/0x400
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b7c2>] do_page_fault+0x22/0x30
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81827d78>] page_fault+0x28/0x30
Jul 11 10:14:02 sanblas kernel: Task in /1 killed as a result of limit of /1
Jul 11 10:14:02 sanblas kernel: memory: usage 1048576kB, limit
1048576kB, failcnt 685
Jul 11 10:14:02 sanblas kernel: memory+swap: usage 0kB, limit
9007199254740988kB, failcnt 0
Jul 11 10:14:02 sanblas kernel: kmem: usage 0kB, limit
9007199254740988kB, failcnt 0
Jul 11 10:14:02 sanblas kernel: Memory cgroup stats for /1: cache:0KB
rss:1048576KB rss_huge:0KB mapped_file:0KB dirty:0KB writeback:0KB
inactive_anon:525500KB active_anon:523076KB inactive_file:0KB
active_file:0KB unevictable:0KB
Jul 11 10:14:02 sanblas kernel: [ pid ]   uid  tgid total_vm      rss
nr_ptes nr_pmds swapents oom_score_adj name
Jul 11 10:14:02 sanblas kernel: [ 7538]     0  7538    29354    26581
    63       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7542]     0  7542    29156    26393
    63       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7544]     0  7544    24635    21861
    52       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7546]     0  7546    35261    32488
    72       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7548]     0  7548    29024    26271
    62       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7550]     0  7550    20378    17624
    45       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7552]     0  7552    21500    18688
    47       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7554]     0  7554    28067    25283
    59       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7556]     0  7556    23777    20964
    51       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7558]     0  7558    16154    13324
    35       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7560]     0  7560    16187    13396
    38       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7562]     0  7562    15527    12762
    34       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7564]     0  7564    11138     8308
    26       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7566]     0  7566     6353     3553
    18       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7568]     0  7568     4538     1797
    14       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7570]     0  7570     1127       25
     8       3        0             0 call-mem-hog
Jul 11 10:14:02 sanblas kernel: Memory cgroup out of memory: Kill
process 7546 (mem-hog) score 120 or sacrifice child
Jul 11 10:14:02 sanblas kernel: Killed process 7546 (mem-hog)
total-vm:141044kB, anon-rss:127848kB, file-rss:2104kB
Jul 11 10:14:02 sanblas kernel: mem-hog invoked oom-killer:
gfp_mask=0x24000c0, order=0, oom_score_adj=0
Jul 11 10:14:02 sanblas kernel: mem-hog cpuset=/ mems_allowed=0
Jul 11 10:14:02 sanblas kernel: CPU: 6 PID: 7554 Comm: mem-hog Not
tainted 4.4.0-24-generic #43-Ubuntu
Jul 11 10:14:02 sanblas kernel: Hardware name: Dell Inc. OptiPlex
9020/00V62H, BIOS A10 01/08/2015
Jul 11 10:14:02 sanblas kernel:  0000000000000286 000000001c5a024f
ffff8801f8b63c88 ffffffff813eab23
Jul 11 10:14:02 sanblas kernel:  ffff8801f8b63d68 ffff8802130c8000
ffff8801f8b63cf8 ffffffff8120906e
Jul 11 10:14:02 sanblas kernel:  ffff88021eb96d00 ffff8801f8b63cc8
ffffffff81190b3b ffff8800c0345280
Jul 11 10:14:02 sanblas kernel: Call Trace:
Jul 11 10:14:02 sanblas kernel:  [<ffffffff813eab23>] dump_stack+0x63/0x90
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8120906e>] dump_header+0x5a/0x1c5
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81190b3b>] ?
find_lock_task_mm+0x3b/0x80
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81191102>]
oom_kill_process+0x202/0x3c0
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811fce94>] ?
mem_cgroup_iter+0x204/0x390
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811feef3>]
mem_cgroup_out_of_memory+0x2b3/0x300
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811ffcc8>]
mem_cgroup_oom_synchronize+0x338/0x350
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811fb1f0>] ?
kzalloc_node.constprop.48+0x20/0x20
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811917b4>]
pagefault_out_of_memory+0x44/0xc0
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b2c2>] mm_fault_error+0x82/0x160
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b778>]
__do_page_fault+0x3d8/0x400
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b7c2>] do_page_fault+0x22/0x30
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81827d78>] page_fault+0x28/0x30
Jul 11 10:14:02 sanblas kernel: Task in /1 killed as a result of limit of /1
Jul 11 10:14:02 sanblas kernel: memory: usage 1048576kB, limit
1048576kB, failcnt 1170
Jul 11 10:14:02 sanblas kernel: memory+swap: usage 0kB, limit
9007199254740988kB, failcnt 0
Jul 11 10:14:02 sanblas kernel: kmem: usage 0kB, limit
9007199254740988kB, failcnt 0
Jul 11 10:14:02 sanblas kernel: Memory cgroup stats for /1: cache:0KB
rss:1048576KB rss_huge:0KB mapped_file:0KB dirty:0KB writeback:0KB
inactive_anon:525444KB active_anon:523132KB inactive_file:0KB
active_file:0KB unevictable:0KB
Jul 11 10:14:02 sanblas kernel: [ pid ]   uid  tgid total_vm      rss
nr_ptes nr_pmds swapents oom_score_adj name
Jul 11 10:14:02 sanblas kernel: [ 7538]     0  7538    31037    28227
    66       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7542]     0  7542    31598    28833
    68       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7544]     0  7544    27374    24626
    57       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7548]     0  7548    30806    27985
    66       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7550]     0  7550    20378    17624
    45       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7552]     0  7552    23942    21194
    52       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7554]     0  7554    30542    27787
    64       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7556]     0  7556    26087    23273
    56       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7558]     0  7558    19157    16357
    41       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7560]     0  7560    17870    15108
    41       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7562]     0  7562    19421    16655
    42       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7564]     0  7564    14042    11274
    31       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7566]     0  7566     8036     5198
    21       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7568]     0  7568     7475     4698
    20       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7570]     0  7570     1127       25
     8       3        0             0 call-mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7572]     0  7572     1127       24
     6       3        0             0 call-mem-hog
Jul 11 10:14:02 sanblas kernel: Memory cgroup out of memory: Kill
process 7542 (mem-hog) score 106 or sacrifice child
Jul 11 10:14:02 sanblas kernel: Killed process 7542 (mem-hog)
total-vm:126392kB, anon-rss:113328kB, file-rss:2004kB
Jul 11 10:14:02 sanblas kernel: mem-hog invoked oom-killer:
gfp_mask=0x24000c0, order=0, oom_score_adj=0
Jul 11 10:14:02 sanblas kernel: mem-hog cpuset=/ mems_allowed=0
Jul 11 10:14:02 sanblas kernel: CPU: 0 PID: 7538 Comm: mem-hog Not
tainted 4.4.0-24-generic #43-Ubuntu
Jul 11 10:14:02 sanblas kernel: Hardware name: Dell Inc. OptiPlex
9020/00V62H, BIOS A10 01/08/2015
Jul 11 10:14:02 sanblas kernel:  0000000000000286 000000004f1b33e0
ffff8800c2827c88 ffffffff813eab23
Jul 11 10:14:02 sanblas kernel:  ffff8800c2827d68 ffff8801f8975280
ffff8800c2827cf8 ffffffff8120906e
Jul 11 10:14:02 sanblas kernel:  ffff88021ea16d00 ffff8800c2827cc8
ffffffff81190b3b ffff8801ef8a5280
Jul 11 10:14:02 sanblas kernel: Call Trace:
Jul 11 10:14:02 sanblas kernel:  [<ffffffff813eab23>] dump_stack+0x63/0x90
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8120906e>] dump_header+0x5a/0x1c5
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81190b3b>] ?
find_lock_task_mm+0x3b/0x80
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81191102>]
oom_kill_process+0x202/0x3c0
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811fce94>] ?
mem_cgroup_iter+0x204/0x390
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811feef3>]
mem_cgroup_out_of_memory+0x2b3/0x300
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811ffcc8>]
mem_cgroup_oom_synchronize+0x338/0x350
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811fb1f0>] ?
kzalloc_node.constprop.48+0x20/0x20
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811917b4>]
pagefault_out_of_memory+0x44/0xc0
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b2c2>] mm_fault_error+0x82/0x160
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b778>]
__do_page_fault+0x3d8/0x400
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b7c2>] do_page_fault+0x22/0x30
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81827d78>] page_fault+0x28/0x30
Jul 11 10:14:02 sanblas kernel: Task in /1 killed as a result of limit of /1
Jul 11 10:14:02 sanblas kernel: memory: usage 1048576kB, limit
1048576kB, failcnt 1419
Jul 11 10:14:02 sanblas kernel: memory+swap: usage 0kB, limit
9007199254740988kB, failcnt 0
Jul 11 10:14:02 sanblas kernel: kmem: usage 0kB, limit
9007199254740988kB, failcnt 0
Jul 11 10:14:02 sanblas kernel: Memory cgroup stats for /1: cache:0KB
rss:1048576KB rss_huge:0KB mapped_file:0KB dirty:0KB writeback:0KB
inactive_anon:525388KB active_anon:523188KB inactive_file:0KB
active_file:0KB unevictable:0KB
Jul 11 10:14:02 sanblas kernel: [ pid ]   uid  tgid total_vm      rss
nr_ptes nr_pmds swapents oom_score_adj name
Jul 11 10:14:02 sanblas kernel: [ 7538]     0  7538    34799    31987
    74       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7544]     0  7544    31070    28320
    64       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7548]     0  7548    32324    29501
    69       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7550]     0  7550    22391    19596
    49       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7552]     0  7552    25493    22711
    55       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7554]     0  7554    30542    27787
    64       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7556]     0  7556    26912    24129
    57       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7558]     0  7558    20741    17940
    44       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7560]     0  7560    20774    17944
    47       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7562]     0  7562    21434    18634
    45       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7564]     0  7564    17045    14243
    37       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7566]     0  7566    10049     7243
    25       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7568]     0  7568     9653     6874
    24       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7570]     0  7570     1127       25
     8       3        0             0 call-mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7572]     0  7572     4571     1788
    15       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7574]     0  7574     1127       25
     6       3        0             0 call-mem-hog
Jul 11 10:14:02 sanblas kernel: Memory cgroup out of memory: Kill
process 7538 (mem-hog) score 118 or sacrifice child
Jul 11 10:14:02 sanblas kernel: Killed process 7538 (mem-hog)
total-vm:139196kB, anon-rss:125988kB, file-rss:1960kB
Jul 11 10:14:02 sanblas kernel: mem-hog invoked oom-killer:
gfp_mask=0x24000c0, order=0, oom_score_adj=0
Jul 11 10:14:02 sanblas kernel: mem-hog cpuset=/ mems_allowed=0
Jul 11 10:14:02 sanblas kernel: CPU: 0 PID: 7572 Comm: mem-hog Not
tainted 4.4.0-24-generic #43-Ubuntu
Jul 11 10:14:02 sanblas kernel: Hardware name: Dell Inc. OptiPlex
9020/00V62H, BIOS A10 01/08/2015
Jul 11 10:14:02 sanblas kernel:  0000000000000286 00000000f67c0969
ffff8800d325bc88 ffffffff813eab23
Jul 11 10:14:02 sanblas kernel:  ffff8800d325bd68 ffff8801f8800000
ffff8800d325bcf8 ffffffff8120906e
Jul 11 10:14:02 sanblas kernel:  ffff88021ea16d00 ffff8800d325bcc8
ffffffff81190b3b ffff8801f8800dc0
Jul 11 10:14:02 sanblas kernel: Call Trace:
Jul 11 10:14:02 sanblas kernel:  [<ffffffff813eab23>] dump_stack+0x63/0x90
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8120906e>] dump_header+0x5a/0x1c5
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81190b3b>] ?
find_lock_task_mm+0x3b/0x80
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81191102>]
oom_kill_process+0x202/0x3c0
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811fce94>] ?
mem_cgroup_iter+0x204/0x390
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811feef3>]
mem_cgroup_out_of_memory+0x2b3/0x300
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811ffcc8>]
mem_cgroup_oom_synchronize+0x338/0x350
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811fb1f0>] ?
kzalloc_node.constprop.48+0x20/0x20
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811917b4>]
pagefault_out_of_memory+0x44/0xc0
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b2c2>] mm_fault_error+0x82/0x160
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b778>]
__do_page_fault+0x3d8/0x400
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b7c2>] do_page_fault+0x22/0x30
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81827d78>] page_fault+0x28/0x30
Jul 11 10:14:02 sanblas kernel: Task in /1 killed as a result of limit of /1
Jul 11 10:14:02 sanblas kernel: memory: usage 1048576kB, limit
1048576kB, failcnt 1973
Jul 11 10:14:02 sanblas kernel: memory+swap: usage 0kB, limit
9007199254740988kB, failcnt 0
Jul 11 10:14:02 sanblas kernel: kmem: usage 0kB, limit
9007199254740988kB, failcnt 0
Jul 11 10:14:02 sanblas kernel: Memory cgroup stats for /1: cache:0KB
rss:1048576KB rss_huge:0KB mapped_file:0KB dirty:0KB writeback:0KB
inactive_anon:525248KB active_anon:523328KB inactive_file:0KB
active_file:0KB unevictable:0KB
Jul 11 10:14:02 sanblas kernel: [ pid ]   uid  tgid total_vm      rss
nr_ptes nr_pmds swapents oom_score_adj name
Jul 11 10:14:02 sanblas kernel: [ 7544]     0  7544    32786    30030
    68       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7548]     0  7548    34238    31480
    73       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7550]     0  7550    23777    20978
    52       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7552]     0  7552    25526    22776
    55       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7554]     0  7554    34304    31544
    71       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7556]     0  7556    29387    26568
    62       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7558]     0  7558    24866    22093
    52       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7560]     0  7560    23579    20778
    52       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7562]     0  7562    23117    20345
    49       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7564]     0  7564    19058    16288
    41       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7566]     0  7566    12557     9749
    30       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7568]     0  7568    11336     8586
    28       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7570]     0  7570     1127       25
     8       3        0             0 call-mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7572]     0  7572     6914     4096
    20       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7574]     0  7574     5231     2433
    15       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7576]     0  7576     4373     1600
    14       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7578]     0  7578     1127       25
     4       3        0             0 call-mem-hog
Jul 11 10:14:02 sanblas kernel: Memory cgroup out of memory: Kill
process 7554 (mem-hog) score 116 or sacrifice child
Jul 11 10:14:02 sanblas kernel: Killed process 7554 (mem-hog)
total-vm:137216kB, anon-rss:124116kB, file-rss:2060kB
Jul 11 10:14:02 sanblas kernel: mem-hog invoked oom-killer:
gfp_mask=0x24000c0, order=0, oom_score_adj=0
Jul 11 10:14:02 sanblas kernel: mem-hog cpuset=/ mems_allowed=0
Jul 11 10:14:02 sanblas kernel: CPU: 7 PID: 7576 Comm: mem-hog Not
tainted 4.4.0-24-generic #43-Ubuntu
Jul 11 10:14:02 sanblas kernel: Hardware name: Dell Inc. OptiPlex
9020/00V62H, BIOS A10 01/08/2015
Jul 11 10:14:02 sanblas kernel:  0000000000000286 000000000d66bd99
ffff8800d983fc88 ffffffff813eab23
Jul 11 10:14:02 sanblas kernel:  ffff8800d983fd68 ffff8801ef8a0dc0
ffff8800d983fcf8 ffffffff8120906e
Jul 11 10:14:02 sanblas kernel:  ffff8800d983fd10 ffff8800d983fcc8
ffffffff81190b3b ffff8801ef8a6e00
Jul 11 10:14:02 sanblas kernel: Call Trace:
Jul 11 10:14:02 sanblas kernel:  [<ffffffff813eab23>] dump_stack+0x63/0x90
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8120906e>] dump_header+0x5a/0x1c5
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81190b3b>] ?
find_lock_task_mm+0x3b/0x80
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81191102>]
oom_kill_process+0x202/0x3c0
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811fce94>] ?
mem_cgroup_iter+0x204/0x390
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811feef3>]
mem_cgroup_out_of_memory+0x2b3/0x300
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811ffcc8>]
mem_cgroup_oom_synchronize+0x338/0x350
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811fb1f0>] ?
kzalloc_node.constprop.48+0x20/0x20
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811917b4>]
pagefault_out_of_memory+0x44/0xc0
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b2c2>] mm_fault_error+0x82/0x160
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b778>]
__do_page_fault+0x3d8/0x400
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b7c2>] do_page_fault+0x22/0x30
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81827d78>] page_fault+0x28/0x30
Jul 11 10:14:02 sanblas kernel: Task in /1 killed as a result of limit of /1
Jul 11 10:14:02 sanblas kernel: memory: usage 1048576kB, limit
1048576kB, failcnt 2218
Jul 11 10:14:02 sanblas kernel: memory+swap: usage 0kB, limit
9007199254740988kB, failcnt 0
Jul 11 10:14:02 sanblas kernel: kmem: usage 0kB, limit
9007199254740988kB, failcnt 0
Jul 11 10:14:02 sanblas kernel: Memory cgroup stats for /1: cache:0KB
rss:1048576KB rss_huge:0KB mapped_file:0KB dirty:0KB writeback:0KB
inactive_anon:525320KB active_anon:523128KB inactive_file:0KB
active_file:0KB unevictable:0KB
Jul 11 10:14:02 sanblas kernel: [ pid ]   uid  tgid total_vm      rss
nr_ptes nr_pmds swapents oom_score_adj name
Jul 11 10:14:02 sanblas kernel: [ 7544]     0  7544    36878    34120
    75       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7548]     0  7548    36119    33327
    76       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7550]     0  7550    24767    22033
    54       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7552]     0  7552    27704    24949
    60       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7556]     0  7556    32225    29403
    68       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7558]     0  7558    26912    24138
    56       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7560]     0  7560    23579    20778
    52       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7562]     0  7562    26054    23312
    54       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7564]     0  7564    21203    18399
    45       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7566]     0  7566    14537    11727
    34       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7568]     0  7568    13250    10499
    31       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7570]     0  7570     1127       25
     8       3        0             0 call-mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7572]     0  7572     7343     4556
    21       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7574]     0  7574     7970     5204
    21       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7576]     0  7576     5627     2853
    17       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7578]     0  7578     6023     3240
    17       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7580]     0  7580     4109     1348
    13       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7581]     0  7581     1127      174
     8       3        0             0 call-mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7582]     0  7582     1127       24
     6       3        0             0 call-mem-hog
Jul 11 10:14:02 sanblas kernel: Memory cgroup out of memory: Kill
process 7544 (mem-hog) score 126 or sacrifice child
Jul 11 10:14:02 sanblas kernel: Killed process 7544 (mem-hog)
total-vm:147512kB, anon-rss:134392kB, file-rss:2088kB
Jul 11 10:14:02 sanblas kernel: mem-hog invoked oom-killer:
gfp_mask=0x24000c0, order=0, oom_score_adj=0
Jul 11 10:14:02 sanblas kernel: mem-hog cpuset=/ mems_allowed=0
Jul 11 10:14:02 sanblas kernel: CPU: 7 PID: 7576 Comm: mem-hog Not
tainted 4.4.0-24-generic #43-Ubuntu
Jul 11 10:14:02 sanblas kernel: Hardware name: Dell Inc. OptiPlex
9020/00V62H, BIOS A10 01/08/2015
Jul 11 10:14:02 sanblas kernel:  0000000000000286 000000000d66bd99
ffff8800d983fc88 ffffffff813eab23
Jul 11 10:14:02 sanblas kernel:  ffff8800d983fd68 ffff8801ef8a0000
ffff8800d983fcf8 ffffffff8120906e
Jul 11 10:14:02 sanblas kernel:  ffff8800d983fd10 ffff8800d983fcc8
ffffffff81190b3b ffff88021480b700
Jul 11 10:14:02 sanblas kernel: Call Trace:
Jul 11 10:14:02 sanblas kernel:  [<ffffffff813eab23>] dump_stack+0x63/0x90
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8120906e>] dump_header+0x5a/0x1c5
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81190b3b>] ?
find_lock_task_mm+0x3b/0x80
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81191102>]
oom_kill_process+0x202/0x3c0
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811fce94>] ?
mem_cgroup_iter+0x204/0x390
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811feef3>]
mem_cgroup_out_of_memory+0x2b3/0x300
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811ffcc8>]
mem_cgroup_oom_synchronize+0x338/0x350
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811fb1f0>] ?
kzalloc_node.constprop.48+0x20/0x20
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811917b4>]
pagefault_out_of_memory+0x44/0xc0
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b2c2>] mm_fault_error+0x82/0x160
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b778>]
__do_page_fault+0x3d8/0x400
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b7c2>] do_page_fault+0x22/0x30
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81827d78>] page_fault+0x28/0x30
Jul 11 10:14:02 sanblas kernel: Task in /1 killed as a result of limit of /1
Jul 11 10:14:02 sanblas kernel: memory: usage 1048576kB, limit
1048576kB, failcnt 2505
Jul 11 10:14:02 sanblas kernel: memory+swap: usage 0kB, limit
9007199254740988kB, failcnt 0
Jul 11 10:14:02 sanblas kernel: kmem: usage 0kB, limit
9007199254740988kB, failcnt 0
Jul 11 10:14:02 sanblas kernel: Memory cgroup stats for /1: cache:0KB
rss:1048576KB rss_huge:0KB mapped_file:0KB dirty:0KB writeback:0KB
inactive_anon:525084KB active_anon:523364KB inactive_file:0KB
active_file:0KB unevictable:0KB
Jul 11 10:14:02 sanblas kernel: [ pid ]   uid  tgid total_vm      rss
nr_ptes nr_pmds swapents oom_score_adj name
Jul 11 10:14:02 sanblas kernel: [ 7548]     0  7548    38297    35503
    81       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7550]     0  7550    25592    22823
    55       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7552]     0  7552    30146    27389
    64       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7556]     0  7556    32885    30062
    69       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7558]     0  7558    29717    26909
    61       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7560]     0  7560    25658    22887
    56       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7562]     0  7562    28793    26016
    60       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7564]     0  7564    22886    20114
    49       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7566]     0  7566    17705    14893
    40       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7568]     0  7568    15461    12675
    36       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7570]     0  7570     1127       25
     8       3        0             0 call-mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7572]     0  7572     9455     6666
    25       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7574]     0  7574     8135     5334
    21       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7576]     0  7576     7277     4501
    20       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7578]     0  7578     7673     4889
    20       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7580]     0  7580     8366     5637
    21       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7582]     0  7582     1127       24
     8       3        0             0 call-mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7584]     0  7584     6221     3431
    17       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7586]     0  7586     3317      412
    11       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7587]     0  7587     1127      200
     8       3        0             0 call-mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7588]     0  7588     1127       25
     5       3        0             0 call-mem-hog
Jul 11 10:14:02 sanblas kernel: Memory cgroup out of memory: Kill
process 7548 (mem-hog) score 131 or sacrifice child
Jul 11 10:14:02 sanblas kernel: Killed process 7548 (mem-hog)
total-vm:153188kB, anon-rss:139964kB, file-rss:2048kB
Jul 11 10:14:02 sanblas kernel: mem-hog invoked oom-killer:
gfp_mask=0x24000c0, order=0, oom_score_adj=0
Jul 11 10:14:02 sanblas kernel: mem-hog cpuset=/ mems_allowed=0
Jul 11 10:14:02 sanblas kernel: CPU: 7 PID: 7580 Comm: mem-hog Not
tainted 4.4.0-24-generic #43-Ubuntu
Jul 11 10:14:02 sanblas kernel: Hardware name: Dell Inc. OptiPlex
9020/00V62H, BIOS A10 01/08/2015
Jul 11 10:14:02 sanblas kernel:  0000000000000286 00000000f5ff64c5
ffff8800d326bc88 ffffffff813eab23
Jul 11 10:14:02 sanblas kernel:  ffff8800d326bd68 ffff8801f8801b80
ffff8800d326bcf8 ffffffff8120906e
Jul 11 10:14:02 sanblas kernel:  ffff8800d326bd10 ffff8800d326bcc8
ffffffff81190b3b ffff8801f8970000
Jul 11 10:14:02 sanblas kernel: Call Trace:
Jul 11 10:14:02 sanblas kernel:  [<ffffffff813eab23>] dump_stack+0x63/0x90
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8120906e>] dump_header+0x5a/0x1c5
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81190b3b>] ?
find_lock_task_mm+0x3b/0x80
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81191102>]
oom_kill_process+0x202/0x3c0
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811fce94>] ?
mem_cgroup_iter+0x204/0x390
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811feef3>]
mem_cgroup_out_of_memory+0x2b3/0x300
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811ffcc8>]
mem_cgroup_oom_synchronize+0x338/0x350
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811fb1f0>] ?
kzalloc_node.constprop.48+0x20/0x20
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811917b4>]
pagefault_out_of_memory+0x44/0xc0
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b2c2>] mm_fault_error+0x82/0x160
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b778>]
__do_page_fault+0x3d8/0x400
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b7c2>] do_page_fault+0x22/0x30
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81827d78>] page_fault+0x28/0x30
Jul 11 10:14:02 sanblas kernel: Task in /1 killed as a result of limit of /1
Jul 11 10:14:02 sanblas kernel: memory: usage 1048576kB, limit
1048576kB, failcnt 3648
Jul 11 10:14:02 sanblas kernel: memory+swap: usage 0kB, limit
9007199254740988kB, failcnt 0
Jul 11 10:14:02 sanblas kernel: kmem: usage 0kB, limit
9007199254740988kB, failcnt 0
Jul 11 10:14:02 sanblas kernel: Memory cgroup stats for /1: cache:0KB
rss:1048576KB rss_huge:0KB mapped_file:0KB dirty:0KB writeback:0KB
inactive_anon:525232KB active_anon:523216KB inactive_file:0KB
active_file:0KB unevictable:0KB
Jul 11 10:14:02 sanblas kernel: [ pid ]   uid  tgid total_vm      rss
nr_ptes nr_pmds swapents oom_score_adj name
Jul 11 10:14:02 sanblas kernel: [ 7550]     0  7550    26813    24070
    58       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7552]     0  7552    34535    31739
    73       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7556]     0  7556    34106    31312
    71       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7558]     0  7558    31103    28287
    64       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7560]     0  7560    28694    25912
    62       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7562]     0  7562    31367    28579
    65       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7564]     0  7564    23744    20967
    50       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7566]     0  7566    19949    17130
    44       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7568]     0  7568    18167    15375
    41       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7570]     0  7570     1127       25
     8       3        0             0 call-mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7572]     0  7572    13547    10753
    33       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7574]     0  7574     8960     6185
    23       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7576]     0  7576     9158     6409
    24       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7578]     0  7578     9719     6927
    24       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7580]     0  7580    10412     7679
    25       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7582]     0  7582     1127       24
     8       3        0             0 call-mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7584]     0  7584     8630     5863
    22       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7586]     0  7586     4868     2031
    14       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7588]     0  7588     3812     1017
    13       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7590]     0  7590     1127       25
     6       3        0             0 call-mem-hog
Jul 11 10:14:02 sanblas kernel: Memory cgroup out of memory: Kill
process 7552 (mem-hog) score 117 or sacrifice child
Jul 11 10:14:02 sanblas kernel: Killed process 7552 (mem-hog)
total-vm:138140kB, anon-rss:124884kB, file-rss:2072kB
Jul 11 10:14:02 sanblas kernel: mem-hog invoked oom-killer:
gfp_mask=0x24000c0, order=0, oom_score_adj=0
Jul 11 10:14:02 sanblas kernel: mem-hog cpuset=/ mems_allowed=0
Jul 11 10:14:02 sanblas kernel: CPU: 2 PID: 7564 Comm: mem-hog Not
tainted 4.4.0-24-generic #43-Ubuntu
Jul 11 10:14:02 sanblas kernel: Hardware name: Dell Inc. OptiPlex
9020/00V62H, BIOS A10 01/08/2015
Jul 11 10:14:02 sanblas kernel:  0000000000000286 00000000233744d1
ffff880213fa3c88 ffffffff813eab23
Jul 11 10:14:02 sanblas kernel:  ffff880213fa3d68 ffff8802134e3700
ffff880213fa3cf8 ffffffff8120906e
Jul 11 10:14:02 sanblas kernel:  ffff880213fa3d10 ffff880213fa3cc8
ffffffff81190b3b ffff8802134e5280
Jul 11 10:14:02 sanblas kernel: Call Trace:
Jul 11 10:14:02 sanblas kernel:  [<ffffffff813eab23>] dump_stack+0x63/0x90
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8120906e>] dump_header+0x5a/0x1c5
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81190b3b>] ?
find_lock_task_mm+0x3b/0x80
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81191102>]
oom_kill_process+0x202/0x3c0
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811fce94>] ?
mem_cgroup_iter+0x204/0x390
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811feef3>]
mem_cgroup_out_of_memory+0x2b3/0x300
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811ffcc8>]
mem_cgroup_oom_synchronize+0x338/0x350
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811fb1f0>] ?
kzalloc_node.constprop.48+0x20/0x20
Jul 11 10:14:02 sanblas kernel:  [<ffffffff811917b4>]
pagefault_out_of_memory+0x44/0xc0
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b2c2>] mm_fault_error+0x82/0x160
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b778>]
__do_page_fault+0x3d8/0x400
Jul 11 10:14:02 sanblas kernel:  [<ffffffff8106b7c2>] do_page_fault+0x22/0x30
Jul 11 10:14:02 sanblas kernel:  [<ffffffff81827d78>] page_fault+0x28/0x30
Jul 11 10:14:02 sanblas kernel: Task in /1 killed as a result of limit of /1
Jul 11 10:14:02 sanblas kernel: memory: usage 1048576kB, limit
1048576kB, failcnt 3884
Jul 11 10:14:02 sanblas kernel: memory+swap: usage 0kB, limit
9007199254740988kB, failcnt 0
Jul 11 10:14:02 sanblas kernel: kmem: usage 0kB, limit
9007199254740988kB, failcnt 0
Jul 11 10:14:02 sanblas kernel: Memory cgroup stats for /1: cache:0KB
rss:1048576KB rss_huge:0KB mapped_file:0KB dirty:0KB writeback:0KB
inactive_anon:525132KB active_anon:523188KB inactive_file:0KB
active_file:0KB unevictable:0KB
Jul 11 10:14:02 sanblas kernel: [ pid ]   uid  tgid total_vm      rss
nr_ptes nr_pmds swapents oom_score_adj name
Jul 11 10:14:02 sanblas kernel: [ 7550]     0  7550    28991    26246
    62       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7556]     0  7556    36878    34082
    77       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7558]     0  7558    32456    29673
    67       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7560]     0  7560    31334    28550
    68       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7562]     0  7562    33512    30755
    69       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7564]     0  7564    28199    25388
    59       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7566]     0  7566    20576    17789
    46       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7568]     0  7568    20939    18146
    46       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7570]     0  7570     1127       25
     8       3        0             0 call-mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7572]     0  7572    16253    13457
    38       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7574]     0  7574    10247     7437
    25       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7576]     0  7576    11171     8388
    28       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7578]     0  7578    11072     8312
    27       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7580]     0  7580    11798     9063
    28       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7582]     0  7582     1127       24
     8       3        0             0 call-mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7584]     0  7584     9191     6390
    23       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7586]     0  7586     6221     3416
    17       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7588]     0  7588     4373     1610
    14       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7590]     0  7590     4307     1513
    15       3        0             0 mem-hog
Jul 11 10:14:02 sanblas kernel: [ 7592]     0  7592     1127       24
     6       3        0             0 call-mem-hog
Jul 11 10:14:02 sanblas kernel: Memory cgroup out of memory: Kill
process 7556 (mem-hog) score 126 or sacrifice child
Jul 11 10:14:02 sanblas kernel: Killed process 7556 (mem-hog)
total-vm:147512kB, anon-rss:134396kB, file-rss:1932kB
Jul 11 10:14:02 sanblas kernel: Memory cgroup out of memory: Kill
process 7560 (mem-hog) score 121 or sacrifice child
Jul 11 10:14:02 sanblas kernel: Killed process 7560 (mem-hog)
total-vm:141968kB, anon-rss:128812kB, file-rss:2016kB
Jul 11 10:14:02 sanblas kernel: Memory cgroup out of memory: Kill
process 7562 (mem-hog) score 130 or sacrifice child
Jul 11 10:14:02 sanblas kernel: Killed process 7562 (mem-hog)
total-vm:151736kB, anon-rss:138572kB, file-rss:2124kB
Jul 11 10:14:02 sanblas kernel: Memory cgroup out of memory: Kill
process 7558 (mem-hog) score 133 or sacrifice child
Jul 11 10:14:02 sanblas kernel: Killed process 7558 (mem-hog)
total-vm:155168kB, anon-rss:142012kB, file-rss:2000kB
Jul 11 10:14:02 sanblas kernel: Memory cgroup out of memory: Kill
process 7550 (mem-hog) score 125 or sacrifice child
Jul 11 10:14:02 sanblas kernel: Killed process 7550 (mem-hog)
total-vm:146720kB, anon-rss:133544kB, file-rss:2048kB
Jul 11 10:14:02 sanblas kernel: Memory cgroup out of memory: Kill
process 7564 (mem-hog) score 123 or sacrifice child
Jul 11 10:14:02 sanblas kernel: Killed process 7564 (mem-hog)
total-vm:144740kB, anon-rss:131736kB, file-rss:1992kB
Jul 11 10:14:02 sanblas kernel: Memory cgroup out of memory: Kill
process 7566 (mem-hog) score 107 or sacrifice child
Jul 11 10:14:02 sanblas kernel: Killed process 7566 (mem-hog)
total-vm:126788kB, anon-rss:113500kB, file-rss:1972kB
Jul 11 10:14:02 sanblas kernel: Memory cgroup out of memory: Kill
process 7568 (mem-hog) score 110 or sacrifice child
Jul 11 10:14:02 sanblas kernel: Killed process 7568 (mem-hog)
total-vm:129824kB, anon-rss:116660kB, file-rss:2088kB
Jul 11 10:14:02 sanblas kernel: Memory cgroup out of memory: Kill
process 7574 (mem-hog) score 109 or sacrifice child
Jul 11 10:14:02 sanblas kernel: Killed process 7574 (mem-hog)
total-vm:128900kB, anon-rss:115876kB, file-rss:2004kB
Jul 11 10:14:02 sanblas kernel: Memory cgroup out of memory: Kill
process 7578 (mem-hog) score 111 or sacrifice child
Jul 11 10:14:02 sanblas kernel: Killed process 7578 (mem-hog)
total-vm:131144kB, anon-rss:118016kB, file-rss:2048kB
Jul 11 10:14:02 sanblas kernel: Memory cgroup out of memory: Kill
process 7572 (mem-hog) score 104 or sacrifice child
Jul 11 10:14:02 sanblas kernel: Killed process 7572 (mem-hog)
total-vm:124148kB, anon-rss:110848kB, file-rss:2048kB
Jul 11 10:14:02 sanblas kernel: Memory cgroup out of memory: Kill
process 7576 (mem-hog) score 110 or sacrifice child
Jul 11 10:14:02 sanblas kernel: Killed process 7576 (mem-hog)
total-vm:129956kB, anon-rss:116932kB, file-rss:2088kB
Jul 11 10:14:02 sanblas kernel: Memory cgroup out of memory: Kill
process 7584 (mem-hog) score 100 or sacrifice child
Jul 11 10:14:02 sanblas kernel: Killed process 7584 (mem-hog)
total-vm:120056kB, anon-rss:106876kB, file-rss:2016kB
Jul 11 10:14:02 sanblas kernel: Memory cgroup out of memory: Kill
process 7602 (mem-hog) score 111 or sacrifice child
Jul 11 10:14:02 sanblas kernel: Killed process 7602 (mem-hog)
total-vm:131672kB, anon-rss:118560kB, file-rss:1972kB
Jul 11 10:14:02 sanblas kernel: Memory cgroup out of memory: Kill
process 7580 (mem-hog) score 116 or sacrifice child
Jul 11 10:14:02 sanblas kernel: Killed process 7580 (mem-hog)
total-vm:136292kB, anon-rss:122976kB, file-rss:2124kB
Jul 11 10:14:02 sanblas kernel: Memory cgroup out of memory: Kill
process 7588 (mem-hog) score 119 or sacrifice child
Jul 11 10:14:02 sanblas kernel: Killed process 7588 (mem-hog)
total-vm:139988kB, anon-rss:126904kB, file-rss:2124kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7600 (mem-hog) score 129 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7600 (mem-hog)
total-vm:150680kB, anon-rss:137516kB, file-rss:1960kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7594 (mem-hog) score 119 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7594 (mem-hog)
total-vm:140384kB, anon-rss:127188kB, file-rss:1972kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7592 (mem-hog) score 127 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7592 (mem-hog)
total-vm:148304kB, anon-rss:135112kB, file-rss:1932kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7586 (mem-hog) score 139 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7586 (mem-hog)
total-vm:161900kB, anon-rss:148792kB, file-rss:1972kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7590 (mem-hog) score 155 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7590 (mem-hog)
total-vm:179192kB, anon-rss:165940kB, file-rss:2004kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7596 (mem-hog) score 143 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7596 (mem-hog)
total-vm:165860kB, anon-rss:152748kB, file-rss:1932kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7606 (mem-hog) score 149 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7606 (mem-hog)
total-vm:172064kB, anon-rss:158812kB, file-rss:1972kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7610 (mem-hog) score 145 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7610 (mem-hog)
total-vm:168104kB, anon-rss:154836kB, file-rss:1972kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7622 (mem-hog) score 138 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7622 (mem-hog)
total-vm:160844kB, anon-rss:147708kB, file-rss:2104kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7614 (mem-hog) score 148 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7614 (mem-hog)
total-vm:171272kB, anon-rss:158016kB, file-rss:2088kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7624 (mem-hog) score 152 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7624 (mem-hog)
total-vm:175628kB, anon-rss:162536kB, file-rss:2088kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7620 (mem-hog) score 140 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7620 (mem-hog)
total-vm:163088kB, anon-rss:150080kB, file-rss:1976kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7626 (mem-hog) score 139 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7626 (mem-hog)
total-vm:161504kB, anon-rss:148268kB, file-rss:2088kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7636 (mem-hog) score 137 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7636 (mem-hog)
total-vm:161240kB, anon-rss:148076kB, file-rss:1992kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7640 (mem-hog) score 153 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7640 (mem-hog)
total-vm:177212kB, anon-rss:163888kB, file-rss:1972kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7642 (mem-hog) score 155 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7642 (mem-hog)
total-vm:178928kB, anon-rss:165776kB, file-rss:2104kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7650 (mem-hog) score 160 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7650 (mem-hog)
total-vm:184604kB, anon-rss:171320kB, file-rss:2124kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7644 (mem-hog) score 172 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7644 (mem-hog)
total-vm:197540kB, anon-rss:184480kB, file-rss:1992kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7646 (mem-hog) score 193 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7646 (mem-hog)
total-vm:219980kB, anon-rss:206948kB, file-rss:2004kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7648 (mem-hog) score 183 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7648 (mem-hog)
total-vm:210344kB, anon-rss:197172kB, file-rss:2104kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7656 (mem-hog) score 208 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7656 (mem-hog)
total-vm:235820kB, anon-rss:222804kB, file-rss:2016kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7660 (mem-hog) score 223 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7660 (mem-hog)
total-vm:252188kB, anon-rss:238904kB, file-rss:2048kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7658 (mem-hog) score 230 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7658 (mem-hog)
total-vm:259712kB, anon-rss:246532kB, file-rss:2048kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7672 (mem-hog) score 213 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7672 (mem-hog)
total-vm:241892kB, anon-rss:228608kB, file-rss:1932kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7680 (mem-hog) score 185 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7680 (mem-hog)
total-vm:211268kB, anon-rss:198004kB, file-rss:2048kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7682 (mem-hog) score 181 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7682 (mem-hog)
total-vm:206912kB, anon-rss:193788kB, file-rss:1984kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7684 (mem-hog) score 197 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7684 (mem-hog)
total-vm:224204kB, anon-rss:210924kB, file-rss:2104kB
Jul 11 10:14:03 sanblas kernel: Memory cgroup out of memory: Kill
process 7694 (mem-hog) score 185 or sacrifice child
Jul 11 10:14:03 sanblas kernel: Killed process 7694 (mem-hog)
total-vm:211796kB, anon-rss:198524kB, file-rss:1960kB
Jul 11 10:14:04 sanblas kernel: Memory cgroup out of memory: Kill
process 7692 (mem-hog) score 186 or sacrifice child
Jul 11 10:14:04 sanblas kernel: Killed process 7692 (mem-hog)
total-vm:212060kB, anon-rss:199020kB, file-rss:2016kB
Jul 11 10:14:04 sanblas kernel: Memory cgroup out of memory: Kill
process 7704 (mem-hog) score 165 or sacrifice child
Jul 11 10:14:04 sanblas kernel: Killed process 7704 (mem-hog)
total-vm:189884kB, anon-rss:176616kB, file-rss:1932kB
Jul 11 10:14:04 sanblas kernel: Memory cgroup out of memory: Kill
process 7714 (mem-hog) score 162 or sacrifice child
Jul 11 10:14:04 sanblas kernel: Killed process 7714 (mem-hog)
total-vm:186188kB, anon-rss:172916kB, file-rss:2060kB
Jul 11 10:14:04 sanblas kernel: Memory cgroup out of memory: Kill
process 7706 (mem-hog) score 155 or sacrifice child
Jul 11 10:14:04 sanblas kernel: Killed process 7706 (mem-hog)
total-vm:179456kB, anon-rss:166320kB, file-rss:1932kB
Jul 11 10:14:04 sanblas kernel: Memory cgroup out of memory: Kill
process 7700 (mem-hog) score 184 or sacrifice child
Jul 11 10:14:04 sanblas kernel: Killed process 7700 (mem-hog)
total-vm:209552kB, anon-rss:196392kB, file-rss:2072kB
Jul 11 10:14:04 sanblas kernel: Memory cgroup out of memory: Kill
process 7716 (mem-hog) score 193 or sacrifice child
Jul 11 10:14:04 sanblas kernel: Killed process 7716 (mem-hog)
total-vm:220376kB, anon-rss:207220kB, file-rss:2000kB
Jul 11 10:14:04 sanblas kernel: Memory cgroup out of memory: Kill
process 7708 (mem-hog) score 240 or sacrifice child
Jul 11 10:14:04 sanblas kernel: Killed process 7708 (mem-hog)
total-vm:270140kB, anon-rss:257088kB, file-rss:2000kB
Jul 11 10:14:04 sanblas kernel: Memory cgroup out of memory: Kill
process 7712 (mem-hog) score 292 or sacrifice child
Jul 11 10:14:04 sanblas kernel: Killed process 7712 (mem-hog)
total-vm:326636kB, anon-rss:313560kB, file-rss:2000kB
Jul 11 10:14:04 sanblas kernel: Memory cgroup out of memory: Kill
process 7726 (mem-hog) score 327 or sacrifice child
Jul 11 10:14:04 sanblas kernel: Killed process 7726 (mem-hog)
total-vm:364652kB, anon-rss:351328kB, file-rss:2088kB
Jul 11 10:14:04 sanblas kernel: Memory cgroup out of memory: Kill
process 7722 (mem-hog) score 487 or sacrifice child
Jul 11 10:14:04 sanblas kernel: Killed process 7722 (mem-hog)
total-vm:537044kB, anon-rss:523984kB, file-rss:2072kB
Jul 11 10:14:04 sanblas kernel: Memory cgroup out of memory: Kill
process 7732 (mem-hog) score 973 or sacrifice child
Jul 11 10:14:04 sanblas kernel: Killed process 7732 (mem-hog)
total-vm:1061216kB, anon-rss:1048040kB, file-rss:1976kB
Jul 11 10:15:26 sanblas systemd[1]: Starting Cleanup of Temporary Directories...
Jul 11 10:15:26 sanblas systemd-tmpfiles[7745]:
[/usr/lib/tmpfiles.d/var.conf:14] Duplicate line for path "/var/log",
ignoring.
Jul 11 10:15:26 sanblas systemd[1]: Started Cleanup of Temporary Directories.
Jul 11 10:17:01 sanblas CRON[7755]: pam_unix(cron:session): session
opened for user root by (uid=0)
Jul 11 10:17:01 sanblas CRON[7756]: (root) CMD (   cd / && run-parts
--report /etc/cron.hourly)
Jul 11 10:17:02 sanblas CRON[7755]: pam_unix(cron:session): session
closed for user root

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
