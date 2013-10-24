Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 61D5C6B00DD
	for <linux-mm@kvack.org>; Thu, 24 Oct 2013 18:43:35 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id v10so3104882pde.15
        for <linux-mm@kvack.org>; Thu, 24 Oct 2013 15:43:35 -0700 (PDT)
Received: from psmtp.com ([74.125.245.181])
        by mx.google.com with SMTP id dj3si2182253pbc.70.2013.10.24.15.43.30
        for <linux-mm@kvack.org>;
        Thu, 24 Oct 2013 15:43:31 -0700 (PDT)
Date: Thu, 24 Oct 2013 23:43:26 +0100
From: Richard Davies <richard@arachsys.com>
Subject: Unnecessary mass OOM kills on Linux 3.11 virtualization host
Message-ID: <20131024224326.GA19654@alpha.arachsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi,

We are running many virtualization hosts with Linux 3.11.3, qemu 1.6.1 + kvm
and ksm. The hosts have 128GB RAM, 10GB swap and 24x AMD Opteron 6238 cores.

Several times this week, we have seen the OOM killer come to life and
quickly kill a large number of VMs on a host, even when there appears to be
free memory on that host at the start of this.


For example:

# grep 'Killed process' /var/log/kern/2013-10-24
19:18:22 kernel: Killed process 1824 (qemu-system-x86) total-vm:10417620kB, anon-rss:9435368kB, file-rss:3012kB
19:18:26 kernel: Killed process 29892 (qemu-system-x86) total-vm:16895784kB, anon-rss:9253524kB, file-rss:2416kB
19:18:26 kernel: Killed process 25418 (qemu-system-x86) total-vm:8561392kB, anon-rss:7796932kB, file-rss:2552kB
19:18:27 kernel: Killed process 27794 (qemu-system-x86) total-vm:18702776kB, anon-rss:7108036kB, file-rss:2524kB
19:18:28 kernel: Killed process 5922 (qemu-system-x86) total-vm:6393736kB, anon-rss:6290912kB, file-rss:2436kB
19:18:30 kernel: Killed process 6363 (qemu-system-x86) total-vm:6065932kB, anon-rss:5770064kB, file-rss:2228kB
19:18:33 kernel: Killed process 964 (qemu-system-x86) total-vm:5954852kB, anon-rss:4986616kB, file-rss:2540kB
19:18:34 kernel: Killed process 31367 (qemu-system-x86) total-vm:4443984kB, anon-rss:3881224kB, file-rss:2400kB
19:18:35 kernel: Killed process 25207 (qemu-system-x86) total-vm:4786756kB, anon-rss:3921788kB, file-rss:2368kB
19:18:37 kernel: Killed process 29024 (qemu-system-x86) total-vm:3249764kB, anon-rss:2808412kB, file-rss:2472kB
19:18:38 kernel: Killed process 27380 (qemu-system-x86) total-vm:2344416kB, anon-rss:2081600kB, file-rss:2264kB
19:18:39 kernel: Killed process 24362 (qemu-system-x86) total-vm:2341508kB, anon-rss:1859184kB, file-rss:2232kB
19:18:40 kernel: Killed process 5551 (qemu-system-x86) total-vm:2400080kB, anon-rss:1730048kB, file-rss:2392kB
19:18:41 kernel: Killed process 18889 (qemu-system-x86) total-vm:2406016kB, anon-rss:1813644kB, file-rss:2424kB
19:18:43 kernel: Killed process 15553 (qemu-system-x86) total-vm:2324520kB, anon-rss:1881016kB, file-rss:3108kB
19:18:44 kernel: Killed process 26173 (qemu-system-x86) total-vm:2337456kB, anon-rss:1623380kB, file-rss:2544kB
19:18:45 kernel: Killed process 5293 (qemu-system-x86) total-vm:1293128kB, anon-rss:1125492kB, file-rss:2444kB
19:18:46 kernel: Killed process 6816 (qemu-system-x86) total-vm:1499568kB, anon-rss:973440kB, file-rss:2404kB
19:18:47 kernel: Killed process 4468 (qemu-system-x86) total-vm:1290248kB, anon-rss:975768kB, file-rss:2428kB
19:18:48 kernel: Killed process 26271 (qemu-system-x86) total-vm:2195584kB, anon-rss:905812kB, file-rss:2392kB
19:18:50 kernel: Killed process 4779 (qemu-system-x86) total-vm:1272584kB, anon-rss:1017664kB, file-rss:2380kB
19:18:51 kernel: Killed process 22385 (qemu-system-x86) total-vm:1340900kB, anon-rss:1065772kB, file-rss:3896kB
19:18:52 kernel: Killed process 32123 (qemu-system-x86) total-vm:1217280kB, anon-rss:969744kB, file-rss:2492kB
19:18:53 kernel: Killed process 28574 (qemu-system-x86) total-vm:1145508kB, anon-rss:880176kB, file-rss:2392kB
19:18:53 kernel: Killed process 26649 (qemu-system-x86) total-vm:1214336kB, anon-rss:1065488kB, file-rss:2480kB
19:18:54 kernel: Killed process 24762 (qemu-system-x86) total-vm:1142740kB, anon-rss:1066412kB, file-rss:2236kB
19:18:55 kernel: Killed process 7340 (qemu-system-x86) total-vm:1177260kB, anon-rss:1063824kB, file-rss:2280kB
19:18:57 kernel: Killed process 16439 (qemu-system-x86) total-vm:1214816kB, anon-rss:1033752kB, file-rss:3152kB
19:18:58 kernel: Killed process 3855 (qemu-system-x86) total-vm:1138184kB, anon-rss:889420kB, file-rss:2384kB
19:18:59 kernel: Killed process 7750 (qemu-system-x86) total-vm:1140932kB, anon-rss:954632kB, file-rss:2224kB

I attach below the detailed kernel log for the first and last of these OOM
kills and the kernel build config.

As you can see in the first log section, "Free swap = 2239440kB" before the
first OOM kill, so there was memory available. This number has increased
substantially to "Free swap  = 10073924kB" by the last OOM kill, but that
kill still happened.

Please can someone help me understand why the OOM killer was initially
triggered (I believe there was free memory at the start), and also why it
killed 30 VMs rather than just one (surely killing the first would free some
memory?)

I am happy to send extra log files or run extra diagnostics.

Thank you very much for any help,

Richard.



This is the first OOM kill:

19:18:21 kernel: qemu-system-x86 invoked oom-killer: gfp_mask=0x0, order=0, oom_score_adj=0
19:18:21 kernel: qemu-system-x86 cpuset=7f350737-f9d6-44ea-965a-5d220dd391d1 mems_allowed=0-3
19:18:21 kernel: CPU: 8 PID: 11072 Comm: qemu-system-x86 Tainted: G    B        3.11.2-elastic #2
19:18:21 kernel: Hardware name: Supermicro H8DG6/H8DGi/H8DG6/H8DGi, BIOS 2.0b       03/01/2012
19:18:21 kernel: 0000000000000000 ffff8816c7eabc18 ffffffff817ee7a6 0000000000000005
19:18:21 kernel: ffff8805eb33db00 ffff8816c7eabcb8 ffffffff817eaf8d 000200da000000d0
19:18:21 kernel: 0000000000000000 ffff8816c7eaa000 0000000000001b88 0800000000001b80
19:18:21 kernel: Call Trace:
19:18:21 kernel: [<ffffffff817ee7a6>] dump_stack+0x55/0x86
19:18:21 kernel: [<ffffffff817eaf8d>] dump_header+0x7a/0x204
19:18:21 kernel: [<ffffffff8139a7af>] ? ___ratelimit+0xb7/0xd4
19:18:21 kernel: [<ffffffff8111e390>] oom_kill_process+0x75/0x311
19:18:21 kernel: [<ffffffff8111eb61>] out_of_memory+0x3c1/0x3f4
19:18:21 kernel: [<ffffffff8111ebe9>] pagefault_out_of_memory+0x55/0x68
19:18:21 kernel: [<ffffffff817ea207>] mm_fault_error+0xa2/0x199
19:18:21 kernel: [<ffffffff8105bbda>] __do_page_fault+0x246/0x3f3
19:18:21 kernel: [<ffffffff810ea23f>] ? cpuacct_account_field+0x52/0x5b
19:18:21 kernel: [<ffffffff810e0ff4>] ? account_user_time+0x6a/0x95
19:18:21 kernel: [<ffffffff810e13b6>] ? vtime_account_user+0x5d/0x65
19:18:21 kernel: [<ffffffff8105bdd1>] do_page_fault+0x2b/0x3e
19:18:21 kernel: [<ffffffff817f5c22>] page_fault+0x22/0x30
19:18:21 kernel: Mem-Info:
19:18:21 kernel: Node 0 DMA per-cpu:
19:18:21 kernel: CPU    0: hi:    0, btch:   1 usd:   0
19:18:21 kernel: CPU    1: hi:    0, btch:   1 usd:   0
19:18:21 kernel: CPU    2: hi:    0, btch:   1 usd:   0
19:18:21 kernel: CPU    3: hi:    0, btch:   1 usd:   0
19:18:21 kernel: CPU    4: hi:    0, btch:   1 usd:   0
19:18:21 kernel: CPU    5: hi:    0, btch:   1 usd:   0
19:18:21 kernel: CPU    6: hi:    0, btch:   1 usd:   0
19:18:21 kernel: CPU    7: hi:    0, btch:   1 usd:   0
19:18:21 kernel: CPU    8: hi:    0, btch:   1 usd:   0
19:18:21 kernel: CPU    9: hi:    0, btch:   1 usd:   0
19:18:21 kernel: CPU   10: hi:    0, btch:   1 usd:   0
19:18:21 kernel: CPU   11: hi:    0, btch:   1 usd:   0
19:18:21 kernel: CPU   12: hi:    0, btch:   1 usd:   0
19:18:21 kernel: CPU   13: hi:    0, btch:   1 usd:   0
19:18:21 kernel: CPU   14: hi:    0, btch:   1 usd:   0
19:18:21 kernel: CPU   15: hi:    0, btch:   1 usd:   0
19:18:21 kernel: CPU   16: hi:    0, btch:   1 usd:   0
19:18:21 kernel: CPU   17: hi:    0, btch:   1 usd:   0
19:18:21 kernel: CPU   18: hi:    0, btch:   1 usd:   0
19:18:21 kernel: CPU   19: hi:    0, btch:   1 usd:   0
19:18:21 kernel: CPU   20: hi:    0, btch:   1 usd:   0
19:18:21 kernel: CPU   21: hi:    0, btch:   1 usd:   0
19:18:21 kernel: CPU   22: hi:    0, btch:   1 usd:   0
19:18:21 kernel: CPU   23: hi:    0, btch:   1 usd:   0
19:18:21 kernel: Node 0 DMA32 per-cpu:
19:18:21 kernel: CPU    0: hi:  186, btch:  31 usd: 174
19:18:21 kernel: CPU    1: hi:  186, btch:  31 usd: 182
19:18:21 kernel: CPU    2: hi:  186, btch:  31 usd: 157
19:18:21 kernel: CPU    3: hi:  186, btch:  31 usd: 102
19:18:21 kernel: CPU    4: hi:  186, btch:  31 usd: 173
19:18:21 kernel: CPU    5: hi:  186, btch:  31 usd: 137
19:18:21 kernel: CPU    6: hi:  186, btch:  31 usd:   2
19:18:21 kernel: CPU    7: hi:  186, btch:  31 usd:  19
19:18:21 kernel: CPU    8: hi:  186, btch:  31 usd:   0
19:18:21 kernel: CPU    9: hi:  186, btch:  31 usd:   0
19:18:21 kernel: CPU   10: hi:  186, btch:  31 usd:   5
19:18:21 kernel: CPU   11: hi:  186, btch:  31 usd:  82
19:18:21 kernel: CPU   12: hi:  186, btch:  31 usd:  32
19:18:21 kernel: CPU   13: hi:  186, btch:  31 usd:  20
19:18:21 kernel: CPU   14: hi:  186, btch:  31 usd:   3
19:18:21 kernel: CPU   15: hi:  186, btch:  31 usd:  34
19:18:21 kernel: CPU   16: hi:  186, btch:  31 usd:   9
19:18:21 kernel: CPU   17: hi:  186, btch:  31 usd:   0
19:18:21 kernel: CPU   18: hi:  186, btch:  31 usd: 100
19:18:21 kernel: CPU   19: hi:  186, btch:  31 usd:   1
19:18:21 kernel: CPU   20: hi:  186, btch:  31 usd: 130
19:18:21 kernel: CPU   21: hi:  186, btch:  31 usd:   0
19:18:21 kernel: CPU   22: hi:  186, btch:  31 usd: 105
19:18:21 kernel: CPU   23: hi:  186, btch:  31 usd:   3
19:18:21 kernel: Node 0 Normal per-cpu:
19:18:21 kernel: CPU    0: hi:  186, btch:  31 usd: 179
19:18:21 kernel: CPU    1: hi:  186, btch:  31 usd:  20
19:18:21 kernel: CPU    2: hi:  186, btch:  31 usd: 160
19:18:21 kernel: CPU    3: hi:  186, btch:  31 usd: 164
19:18:21 kernel: CPU    4: hi:  186, btch:  31 usd: 155
19:18:21 kernel: CPU    5: hi:  186, btch:  31 usd:   0
19:18:21 kernel: CPU    6: hi:  186, btch:  31 usd: 185
19:18:21 kernel: CPU    7: hi:  186, btch:  31 usd: 180
19:18:21 kernel: CPU    8: hi:  186, btch:  31 usd: 158
19:18:21 kernel: CPU    9: hi:  186, btch:  31 usd: 167
19:18:21 kernel: CPU   10: hi:  186, btch:  31 usd: 166
19:18:21 kernel: CPU   11: hi:  186, btch:  31 usd: 178
19:18:21 kernel: CPU   12: hi:  186, btch:  31 usd: 168
19:18:21 kernel: CPU   13: hi:  186, btch:  31 usd: 178
19:18:21 kernel: CPU   14: hi:  186, btch:  31 usd: 158
19:18:21 kernel: CPU   15: hi:  186, btch:  31 usd: 185
19:18:21 kernel: CPU   16: hi:  186, btch:  31 usd: 162
19:18:21 kernel: CPU   17: hi:  186, btch:  31 usd: 185
19:18:21 kernel: CPU   18: hi:  186, btch:  31 usd: 184
19:18:21 kernel: CPU   19: hi:  186, btch:  31 usd: 115
19:18:21 kernel: CPU   20: hi:  186, btch:  31 usd: 100
19:18:21 kernel: CPU   21: hi:  186, btch:  31 usd: 111
19:18:21 kernel: CPU   22: hi:  186, btch:  31 usd: 177
19:18:21 kernel: CPU   23: hi:  186, btch:  31 usd: 171
19:18:21 kernel: Node 1 Normal per-cpu:
19:18:21 kernel: CPU    0: hi:  186, btch:  31 usd: 176
19:18:21 kernel: CPU    1: hi:  186, btch:  31 usd: 155
19:18:21 kernel: CPU    2: hi:  186, btch:  31 usd: 178
19:18:21 kernel: CPU    3: hi:  186, btch:  31 usd: 184
19:18:21 kernel: CPU    4: hi:  186, btch:  31 usd: 176
19:18:21 kernel: CPU    5: hi:  186, btch:  31 usd: 167
19:18:21 kernel: CPU    6: hi:  186, btch:  31 usd:  10
19:18:21 kernel: CPU    7: hi:  186, btch:  31 usd:  39
19:18:21 kernel: CPU    8: hi:  186, btch:  31 usd:  71
19:18:21 kernel: CPU    9: hi:  186, btch:  31 usd:  14
19:18:21 kernel: CPU   10: hi:  186, btch:  31 usd: 181
19:18:21 kernel: CPU   11: hi:  186, btch:  31 usd:  30
19:18:21 kernel: CPU   12: hi:  186, btch:  31 usd: 157
19:18:21 kernel: CPU   13: hi:  186, btch:  31 usd: 164
19:18:21 kernel: CPU   14: hi:  186, btch:  31 usd: 175
19:18:21 kernel: CPU   15: hi:  186, btch:  31 usd: 170
19:18:21 kernel: CPU   16: hi:  186, btch:  31 usd: 180
19:18:21 kernel: CPU   17: hi:  186, btch:  31 usd: 182
19:18:21 kernel: CPU   18: hi:  186, btch:  31 usd: 156
19:18:21 kernel: CPU   19: hi:  186, btch:  31 usd: 110
19:18:21 kernel: CPU   20: hi:  186, btch:  31 usd: 173
19:18:21 kernel: CPU   21: hi:  186, btch:  31 usd: 162
19:18:21 kernel: CPU   22: hi:  186, btch:  31 usd: 167
19:18:21 kernel: CPU   23: hi:  186, btch:  31 usd: 179
19:18:21 kernel: Node 2 Normal per-cpu:
19:18:21 kernel: CPU    0: hi:  186, btch:  31 usd: 180
19:18:21 kernel: CPU    1: hi:  186, btch:  31 usd: 170
19:18:21 kernel: CPU    2: hi:  186, btch:  31 usd: 110
19:18:21 kernel: CPU    3: hi:  186, btch:  31 usd:  82
19:18:21 kernel: CPU    4: hi:  186, btch:  31 usd: 147
19:18:21 kernel: CPU    5: hi:  186, btch:  31 usd: 165
19:18:21 kernel: CPU    6: hi:  186, btch:  31 usd: 164
19:18:21 kernel: CPU    7: hi:  186, btch:  31 usd: 183
19:18:21 kernel: CPU    8: hi:  186, btch:  31 usd: 157
19:18:21 kernel: CPU    9: hi:  186, btch:  31 usd: 168
19:18:21 kernel: CPU   10: hi:  186, btch:  31 usd: 167
19:18:21 kernel: CPU   11: hi:  186, btch:  31 usd: 180
19:18:21 kernel: CPU   12: hi:  186, btch:  31 usd:  41
19:18:21 kernel: CPU   13: hi:  186, btch:  31 usd:  60
19:18:21 kernel: CPU   14: hi:  186, btch:  31 usd:  31
19:18:21 kernel: CPU   15: hi:  186, btch:  31 usd: 196
19:18:21 kernel: CPU   16: hi:  186, btch:  31 usd:  27
19:18:21 kernel: CPU   17: hi:  186, btch:  31 usd: 123
19:18:21 kernel: CPU   18: hi:  186, btch:  31 usd: 169
19:18:21 kernel: CPU   19: hi:  186, btch:  31 usd: 152
19:18:21 kernel: CPU   20: hi:  186, btch:  31 usd: 168
19:18:21 kernel: CPU   21: hi:  186, btch:  31 usd: 104
19:18:21 kernel: CPU   22: hi:  186, btch:  31 usd: 178
19:18:21 kernel: CPU   23: hi:  186, btch:  31 usd: 183
19:18:21 kernel: Node 3 Normal per-cpu:
19:18:21 kernel: CPU    0: hi:  186, btch:  31 usd: 176
19:18:21 kernel: CPU    1: hi:  186, btch:  31 usd: 157
19:18:21 kernel: CPU    2: hi:  186, btch:  31 usd: 157
19:18:21 kernel: CPU    3: hi:  186, btch:  31 usd: 183
19:18:21 kernel: CPU    4: hi:  186, btch:  31 usd: 184
19:18:21 kernel: CPU    5: hi:  186, btch:  31 usd: 184
19:18:21 kernel: CPU    6: hi:  186, btch:  31 usd: 172
19:18:21 kernel: CPU    7: hi:  186, btch:  31 usd: 169
19:18:21 kernel: CPU    8: hi:  186, btch:  31 usd: 171
19:18:21 kernel: CPU    9: hi:  186, btch:  31 usd: 162
19:18:21 kernel: CPU   10: hi:  186, btch:  31 usd: 185
19:18:21 kernel: CPU   11: hi:  186, btch:  31 usd: 161
19:18:21 kernel: CPU   12: hi:  186, btch:  31 usd: 146
19:18:21 kernel: CPU   13: hi:  186, btch:  31 usd:  77
19:18:21 kernel: CPU   14: hi:  186, btch:  31 usd: 159
19:18:21 kernel: CPU   15: hi:  186, btch:  31 usd: 156
19:18:21 kernel: CPU   16: hi:  186, btch:  31 usd: 179
19:18:21 kernel: CPU   17: hi:  186, btch:  31 usd: 177
19:18:21 kernel: CPU   18: hi:  186, btch:  31 usd:  72
19:18:21 kernel: CPU   19: hi:  186, btch:  31 usd:   8
19:18:21 kernel: CPU   20: hi:  186, btch:  31 usd:  11
19:18:21 kernel: CPU   21: hi:  186, btch:  31 usd:  29
19:18:21 kernel: CPU   22: hi:  186, btch:  31 usd: 163
19:18:21 kernel: CPU   23: hi:  186, btch:  31 usd:  32
19:18:21 kernel: active_anon:9439668 inactive_anon:7330197 isolated_anon:48
19:18:21 kernel: active_file:6075432 inactive_file:8685245 isolated_file:0
19:18:21 kernel: unevictable:692 dirty:2863 writeback:0 unstable:0
19:18:21 kernel: free:121590 slab_reclaimable:479973 slab_unreclaimable:443031
19:18:21 kernel: mapped:2423 shmem:77 pagetables:56059 bounce:0
19:18:21 kernel: free_cma:0
19:18:21 kernel: Node 0 DMA free:15424kB min:16kB low:20kB high:24kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15956kB managed:15872kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
19:18:21 kernel: lowmem_reserve[]: 0 3297 32096 32096
19:18:21 kernel: Node 0 DMA32 free:119844kB min:3456kB low:4320kB high:5184kB active_anon:1672788kB inactive_anon:1437860kB active_file:16196kB inactive_file:40208kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3521024kB managed:3377352kB mlocked:0kB dirty:8kB writeback:0kB mapped:44kB shmem:0kB slab_reclaimable:34220kB slab_unreclaimable:16412kB kernel_stack:224kB pagetables:2204kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:1413 all_unreclaimable? no
19:18:21 kernel: lowmem_reserve[]: 0 0 28799 28799
19:18:21 kernel: Node 0 Normal free:66292kB min:30208kB low:37760kB high:45312kB active_anon:13822672kB inactive_anon:8018824kB active_file:3101444kB inactive_file:3629472kB unevictable:864kB isolated(anon):88kB isolated(file):0kB present:30015488kB managed:29490340kB mlocked:864kB dirty:2656kB writeback:0kB mapped:696kB shmem:20kB slab_reclaimable:243812kB slab_unreclaimable:144668kB kernel_stack:16968kB pagetables:77824kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:105 all_unreclaimable? no
19:18:21 kernel: lowmem_reserve[]: 0 0 0 0
19:18:21 kernel: Node 1 Normal free:95120kB min:33832kB low:42288kB high:50748kB active_anon:7659236kB inactive_anon:6911376kB active_file:6483428kB inactive_file:10352696kB unevictable:1304kB isolated(anon):104kB isolated(file):0kB present:33554432kB managed:33029392kB mlocked:1304kB dirty:2164kB writeback:64kB mapped:3132kB shmem:28kB slab_reclaimable:558308kB slab_unreclaimable:562180kB kernel_stack:5760kB pagetables:56152kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
19:18:21 kernel: lowmem_reserve[]: 0 0 0 0
19:18:21 kernel: Node 2 Normal free:94364kB min:33832kB low:42288kB high:50748kB active_anon:7351460kB inactive_anon:6578128kB active_file:7192548kB inactive_file:10409060kB unevictable:4kB isolated(anon):0kB isolated(file):0kB present:33554432kB managed:33029396kB mlocked:4kB dirty:3524kB writeback:0kB mapped:2856kB shmem:260kB slab_reclaimable:550612kB slab_unreclaimable:464192kB kernel_stack:2960kB pagetables:46320kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
19:18:21 kernel: lowmem_reserve[]: 0 0 0 0
19:18:21 kernel: Node 3 Normal free:95316kB min:33816kB low:42268kB high:50724kB active_anon:7252516kB inactive_anon:6374600kB active_file:7508112kB inactive_file:10309544kB unevictable:596kB isolated(anon):0kB isolated(file):0kB present:33538048kB managed:33012572kB mlocked:596kB dirty:3100kB writeback:4kB mapped:2964kB shmem:0kB slab_reclaimable:532940kB slab_unreclaimable:584672kB kernel_stack:4104kB pagetables:41736kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:1248 all_unreclaimable? no
19:18:21 kernel: lowmem_reserve[]: 0 0 0 0
19:18:21 kernel: Node 0 DMA: 0*4kB 0*8kB 0*16kB 12*32kB (U) 13*64kB (U) 13*128kB (U) 3*256kB (U) 3*512kB (U) 2*1024kB (U) 2*2048kB (UR) 1*4096kB (M) = 15424kB
19:18:21 kernel: Node 0 DMA32: 10796*4kB (UEMR) 8978*8kB (UEMR) 268*16kB (UEMR) 16*32kB (R) 2*64kB (R) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 119936kB
19:18:21 kernel: Node 0 Normal: 16591*4kB (UEM) 28*8kB (U) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 66588kB
19:18:21 kernel: Node 1 Normal: 2964*4kB (UEM) 10415*8kB (UM) 2*16kB (U) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 95208kB
19:18:21 kernel: Node 2 Normal: 14629*4kB (UEM) 3197*8kB (UEM) 74*16kB (UEM) 265*32kB (UEMR) 1*64kB (R) 3*128kB (R) 1*256kB (R) 1*512kB (R) 0*1024kB 0*2048kB 0*4096kB = 94972kB
19:18:21 kernel: Node 3 Normal: 3834*4kB (UEM) 9698*8kB (UEM) 149*16kB (U) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 95304kB
19:18:21 kernel: Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
19:18:21 kernel: Node 1 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
19:18:21 kernel: Node 2 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
19:18:21 kernel: Node 3 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
19:18:21 kernel: 15464237 total pagecache pages
19:18:21 kernel: 703196 pages in swap cache
19:18:21 kernel: Swap cache stats: add 76178649, delete 75475895, find 106821813/1083705949
19:18:21 kernel: Free swap  = 2239440kB
19:18:21 kernel: Total swap = 11184368kB
19:18:22 kernel: 33550335 pages RAM
19:18:22 kernel: 561604 pages reserved
19:18:22 kernel: 22118815 pages shared
19:18:22 kernel: 17429589 pages non-shared
19:18:22 kernel: [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
19:18:22 kernel: [ 2025]     0  2025      985      133       8        0         -1000 udevd
19:18:22 kernel: [ 2973]     0  2973     4925      122      14        0             0 rc.startup
19:18:22 kernel: [ 2974]     0  2974     4925      122      14        0             0 rc.startup
19:18:22 kernel: [ 2975]     0  2975     4925      122      14        0             0 rc.startup
19:18:22 kernel: [ 2976]     0  2976      962       93       8        0             0 agetty
19:18:22 kernel: [ 2977]     0  2977     4925      120      14        0             0 rc.startup
19:18:22 kernel: [ 2978]     0  2978      962       96       9        0             0 agetty
19:18:22 kernel: [ 2979]     0  2979     4925      122      14        0             0 rc.startup
19:18:22 kernel: [ 2981]     0  2981      962       95       7        0             0 agetty
19:18:22 kernel: [ 2982]     0  2982     4925      122      14        0             0 rc.startup
19:18:22 kernel: [ 2983]     0  2983      962       95       8        0             0 agetty
19:18:22 kernel: [ 2984]     0  2984      962       96       8        0             0 agetty
19:18:22 kernel: [ 2985]     0  2985     4925      122      14        0             0 rc.startup
19:18:22 kernel: [ 2986]     0  2986      962       95       8        0             0 agetty
19:18:22 kernel: [ 2987]     0  2987     4925      122      14        0             0 rc.startup
19:18:22 kernel: [ 2988]     0  2988      962       96       7        0             0 agetty
19:18:22 kernel: [ 2989]     0  2989     4925      122      14        0             0 rc.startup
19:18:22 kernel: [ 2990]     0  2990      962       95       8        0             0 agetty
19:18:22 kernel: [ 2991]     0  2991     6229     1462      17        0             0 rc.startup
19:18:22 kernel: [ 2992]     0  2992      962       95       8        0             0 agetty
19:18:22 kernel: [ 3033]     0  3033    45751      347      23        0             0 rsyslogd
19:18:22 kernel: [ 3038]     0  3038     6751      288      18        0             0 sshd
19:18:22 kernel: [ 3041]     0  3041    23587      218      16        0             0 automount
19:18:22 kernel: [ 3051]     0  3051     1009      113       8        0             0 iscsid
19:18:22 kernel: [ 3052]     0  3052     3245      693      13        0         -1000 iscsid
19:18:22 kernel: [ 3057] 65534  3057     3210      278      11        0             0 dnsmasq
19:18:22 kernel: [ 3059]     0  3059     3354      258      12        0             0 ntpd
19:18:22 kernel: [16042]     0 16042    36377       85      25        0             0 diod
19:18:22 kernel: [16067]     0 16067     8142      638      19        0             0 httpd
19:18:22 kernel: [16069]     0 16069     4918      370      16        0             0 elastic-poolio
19:18:22 kernel: [16072]     0 16072     5798     1098      15        0             0 elastic-floodwa
19:18:22 kernel: [16085]     0 16085    66136      526      53        0             0 httpd
19:18:22 kernel: [16086]     0 16086    66136      668      53        0             0 httpd
19:18:22 kernel: [16087]     0 16087    66136      594      53        0             0 httpd
19:18:22 kernel: [24164]     0 24164     5277      546      15       17             0 elastic
19:18:22 kernel: [24362] 65537 24362   585377   465354    1138   100684             0 qemu-system-x86
19:18:22 kernel: [24569]     0 24569     5283      575      15        0             0 elastic
19:18:22 kernel: [24762] 65538 24762   285685   267162     554        6             0 qemu-system-x86
19:18:22 kernel: [25306]     0 25306     5277      558      15        5             0 elastic
19:18:22 kernel: [25518] 65540 25518   300162   121929     364    33810             0 qemu-system-x86
19:18:22 kernel: [25736]     0 25736     5283      554      16       18             0 elastic
19:18:22 kernel: [25918] 65541 25918   360308   152319     484    26939             0 qemu-system-x86
19:18:22 kernel: [26098]     0 26098     5277      562      16        1             0 elastic
19:18:22 kernel: [26271] 65542 26271   548896   227047     603    62233             0 qemu-system-x86
19:18:22 kernel: [26469]     0 26469     5283      571      15        2             0 elastic
19:18:22 kernel: [26649] 65543 26649   303584   266992     560      742             0 qemu-system-x86
19:18:22 kernel: [27186]     0 27186     5277      560      14        3             0 elastic
19:18:22 kernel: [27380] 65545 27380   586104   520966    1142    45820             0 qemu-system-x86
19:18:22 kernel: [27586]     0 27586     5277      538      15       25             0 elastic
19:18:22 kernel: [27794] 65546 27794  4675694  1777640    4010   253662             0 qemu-system-x86
19:18:22 kernel: [28376]     0 28376     5277      541      14       24             0 elastic
19:18:22 kernel: [28574] 65548 28574   286377   220641     559    47206             0 qemu-system-x86
19:18:22 kernel: [28792]     0 28792     5278      561      16        5             0 elastic
19:18:22 kernel: [29024] 65549 29024   812441   702721    1553    73377             0 qemu-system-x86
19:18:22 kernel: [31148]     0 31148     5277      529      15       35             0 elastic
19:18:22 kernel: [31367] 65554 31367  1110996   970906    2155   110220             0 qemu-system-x86
19:18:22 kernel: [31550]     0 31550     5277      615      16        2             0 elastic
19:18:22 kernel: [31937]     0 31937     5278      529      16       36             0 elastic
19:18:22 kernel: [32123] 65556 32123   304320   243058     561    24903             0 qemu-system-x86
19:18:22 kernel: [32304]     0 32304     5277      551      14       13             0 elastic
19:18:22 kernel: [32497] 65557 32497   284361    80540     219    13424             0 qemu-system-x86
19:18:22 kernel: [  728]     0   728     5277      564      14        0             0 elastic
19:18:22 kernel: [  964] 65559   964  1488713  1247289    2871   202772             0 qemu-system-x86
19:18:22 kernel: [ 1127]     0  1127     5277      561      15        3             0 elastic
19:18:22 kernel: [ 1748] 65560  1748   113153    70173     222    15026             0 qemu-system-x86
19:18:22 kernel: [ 1993]     0  1993     5277      540      14       24             0 elastic
19:18:22 kernel: [ 2210] 65562  2210   308845   144090     404    23956             0 qemu-system-x86
19:18:22 kernel: [ 2366]     0  2366     5283      555      14       17             0 elastic
19:18:22 kernel: [ 2781]     0  2781     5277      558      14        5             0 elastic
19:18:22 kernel: [ 3197] 65563  3197   304254   208272     485    21858             0 qemu-system-x86
19:18:22 kernel: [ 3291]     0  3291     5277      540      14       24             0 elastic
19:18:22 kernel: [ 3596] 65564  3596   153526    71586     214    19712             0 qemu-system-x86
19:18:22 kernel: [ 3855] 65565  3855   284546   222951     555    42521             0 qemu-system-x86
19:18:22 kernel: [ 4106]     0  4106     5277      558      14        5             0 elastic
19:18:22 kernel: [ 4468] 65566  4468   322562   244549     624    45985             0 qemu-system-x86
19:18:22 kernel: [ 4472]     0  4472     5277      537      15       28             0 elastic
19:18:22 kernel: [ 4779] 65567  4779   318146   255011     612    28275             0 qemu-system-x86
19:18:22 kernel: [ 4928]     0  4928     5277      541      13       23             0 elastic
19:18:22 kernel: [ 5293] 65568  5293   323026   281980     626    18747             0 qemu-system-x86
19:18:22 kernel: [ 5299]     0  5299     5278      581      15       36             0 elastic
19:18:22 kernel: [ 5658]     0  5658     5277      532      15       32             0 elastic
19:18:22 kernel: [ 5877] 65570  5877   284444   186799     485    43208             0 qemu-system-x86
19:18:22 kernel: [ 6085]     0  6085     5283      559      15       14             0 elastic
19:18:22 kernel: [ 6363] 65571  6363  1516483  1443073    2925    35940             0 qemu-system-x86
19:18:22 kernel: [ 6634]     0  6634     5283      536      15       36             0 elastic
19:18:22 kernel: [ 6816] 65572  6816   374892   243961     719    55804             0 qemu-system-x86
19:18:22 kernel: [ 7054]     0  7054     5283      571      14        2             0 elastic
19:18:22 kernel: [ 7340] 65573  7340   294315   266526     558       96             0 qemu-system-x86
19:18:22 kernel: [ 7548]     0  7548     5283      561      14       13             0 elastic
19:18:22 kernel: [ 7750] 65574  7750   285233   239201     541    20572             0 qemu-system-x86
19:18:22 kernel: [ 8409]     0  8409     5283      566      14        7             0 elastic
19:18:22 kernel: [ 8766]     0  8766     5283      563      15       11             0 elastic
19:18:22 kernel: [ 9072] 65576  9072   285357   101128     261    14826             0 qemu-system-x86
19:18:22 kernel: [ 9093] 65577  9093   172968   128163     297     6109             0 qemu-system-x86
19:18:22 kernel: [ 9249]     0  9249     5283      555      15       18             0 elastic
19:18:22 kernel: [ 9529] 65578  9529   604341   107074     344    15520             0 qemu-system-x86
19:18:22 kernel: [24828]     0 24828     5277      559      14        6             0 elastic
19:18:22 kernel: [25039] 65558 25039   566213    62407     186    12219             0 qemu-system-x86
19:18:22 kernel: [ 5339]     0  5339     5277      544      16       20             0 elastic
19:18:22 kernel: [ 5551] 65553  5551   600020   433108    1142   130047             0 qemu-system-x86
19:18:22 kernel: [ 7688]     0  7688    66136      557      53        0             0 httpd
19:18:22 kernel: [18693]     0 18693     5277      549      14       15             0 elastic
19:18:22 kernel: [18889] 65579 18889   601504   454017    1132    99546             0 qemu-system-x86
19:18:22 kernel: [29652]     0 29652     5277      556      16        8             0 elastic
19:18:22 kernel: [29892] 65547 29892  4223946  2313985    5024   211605             0 qemu-system-x86
19:18:22 kernel: [25226]     0 25226     5298      581      14        3             0 elastic
19:18:22 kernel: [25418] 65536 25418  2140348  1949871    4039    99305             0 qemu-system-x86
19:18:22 kernel: [25968]     0 25968     5298      571      15       13             0 elastic
19:18:22 kernel: [26173] 65550 26173   584364   406481    1045   107148             0 qemu-system-x86
19:18:22 kernel: [24964]     0 24964     5303      586      15        7             0 elastic
19:18:22 kernel: [25207] 65552 25207  1196689   981039    2226    56383             0 qemu-system-x86
19:18:22 kernel: [21929]     0 21929     5298      556      14       28             0 elastic
19:18:22 kernel: [22106] 65544 22106   293706    43616     161    11841             0 qemu-system-x86
19:18:22 kernel: [20921]     0 20921      984      111       8        0         -1000 udevd
19:18:22 kernel: [20925]     0 20925      984      116       8        0         -1000 udevd
19:18:22 kernel: [ 5693]     0  5693     5303      593      15        0             0 elastic
19:18:22 kernel: [ 5922] 65575  5922  1598434  1573337    3112      814             0 qemu-system-x86
19:18:22 kernel: [ 1824] 65569  1824  2604405  2359595    5016   184476             0 qemu-system-x86
19:18:22 kernel: [15378]     0 15378     5298      584      14        0             0 elastic
19:18:22 kernel: [15553] 65561 15553   581130   471031    1129    54321             0 qemu-system-x86
19:18:22 kernel: [16177]     0 16177     5303      561      15       33             0 elastic
19:18:22 kernel: [16439] 65580 16439   303704   259226     560     6827             0 qemu-system-x86
19:18:22 kernel: [16978]     0 16978     5303      558      13       35             0 elastic
19:18:22 kernel: [20134] 65581 20134   547551    43378     129     3136             0 qemu-system-x86
19:18:22 kernel: [16674] 65555 16674   324070    57979     220     1345             0 qemu-system-x86
19:18:22 kernel: [25345]     0 25345     7892      411      20        0             0 lighttpd
19:18:22 kernel: [25494]     0 25494  4103458     3096    2019        0         -1000 tgtd
19:18:22 kernel: [25496]     0 25496     1565       85       9        0         -1000 tgtd
19:18:22 kernel: [22183]     0 22183     5297      548      15       35             0 elastic
19:18:22 kernel: [22385] 65539 22385   335225   267417     627    11156             0 qemu-system-x86
19:18:22 kernel: [ 9136]     0  9136     5297      582      16        0             0 elastic
19:18:22 kernel: [ 9357] 65582  9357   289351    56231     162     2705             0 qemu-system-x86
19:18:22 kernel: [ 9358]     0  9358     5297      554      14       29             0 elastic
19:18:22 kernel: [ 9568] 65551  9568    88036    39041     114      371             0 qemu-system-x86
19:18:22 kernel: [11329]     0 11329     1992      104       9        0             0 sleep
19:18:22 kernel: [11509]     0 11509      962      154       9        0             0 agetty
19:18:22 kernel: Out of memory: Kill process 1824 (qemu-system-x86) score 71 or sacrifice child
19:18:22 kernel: Killed process 1824 (qemu-system-x86) total-vm:10417620kB, anon-rss:9435368kB, file-rss:3012kB


This is the last OOM kill:

19:18:58 kernel: qemu-system-x86 invoked oom-killer: gfp_mask=0x0, order=0, oom_score_adj=0
19:18:58 kernel: qemu-system-x86 cpuset=7f350737-f9d6-44ea-965a-5d220dd391d1 mems_allowed=0-3
19:18:58 kernel: CPU: 10 PID: 11072 Comm: qemu-system-x86 Tainted: G    B        3.11.2-elastic #2
19:18:58 kernel: Hardware name: Supermicro H8DG6/H8DGi/H8DG6/H8DGi, BIOS 2.0b       03/01/2012
19:18:58 kernel: 0000000000000000 ffff8816c7eabc18 ffffffff817ee7a6 0000000000000048
19:18:58 kernel: ffff8805eb33db00 ffff8816c7eabcb8 ffffffff817eaf8d 000200da000000d0
19:18:58 kernel: 0000000000000000 ffff8816c7eaa000 0000000000001b88 0800000000001b80
19:18:58 kernel: Call Trace:
19:18:58 kernel: [<ffffffff817ee7a6>] dump_stack+0x55/0x86
19:18:58 kernel: [<ffffffff817eaf8d>] dump_header+0x7a/0x204
19:18:58 kernel: [<ffffffff8139a7af>] ? ___ratelimit+0xb7/0xd4
19:18:58 kernel: [<ffffffff8111e390>] oom_kill_process+0x75/0x311
19:18:58 kernel: [<ffffffff810c4697>] ? has_capability_noaudit+0x12/0x14
19:18:58 kernel: [<ffffffff8111eb61>] out_of_memory+0x3c1/0x3f4
19:18:58 kernel: [<ffffffff8111ebe9>] pagefault_out_of_memory+0x55/0x68
19:18:58 kernel: [<ffffffff817ea207>] mm_fault_error+0xa2/0x199
19:18:58 kernel: [<ffffffff8105bbda>] __do_page_fault+0x246/0x3f3
19:18:58 kernel: [<ffffffff810ea23f>] ? cpuacct_account_field+0x52/0x5b
19:18:58 kernel: [<ffffffff810ea23f>] ? cpuacct_account_field+0x52/0x5b
19:18:58 kernel: [<ffffffff810e0ff4>] ? account_user_time+0x6a/0x95
19:18:58 kernel: [<ffffffff810e13b6>] ? vtime_account_user+0x5d/0x65
19:18:58 kernel: [<ffffffff8105bdd1>] do_page_fault+0x2b/0x3e
19:18:58 kernel: [<ffffffff817f5c22>] page_fault+0x22/0x30
19:18:58 kernel: Mem-Info:
19:18:58 kernel: Node 0 DMA per-cpu:
19:18:58 kernel: CPU    0: hi:    0, btch:   1 usd:   0
19:18:58 kernel: CPU    1: hi:    0, btch:   1 usd:   0
19:18:58 kernel: CPU    2: hi:    0, btch:   1 usd:   0
19:18:58 kernel: CPU    3: hi:    0, btch:   1 usd:   0
19:18:58 kernel: CPU    4: hi:    0, btch:   1 usd:   0
19:18:58 kernel: CPU    5: hi:    0, btch:   1 usd:   0
19:18:58 kernel: CPU    6: hi:    0, btch:   1 usd:   0
19:18:58 kernel: CPU    7: hi:    0, btch:   1 usd:   0
19:18:58 kernel: CPU    8: hi:    0, btch:   1 usd:   0
19:18:58 kernel: CPU    9: hi:    0, btch:   1 usd:   0
19:18:58 kernel: CPU   10: hi:    0, btch:   1 usd:   0
19:18:58 kernel: CPU   11: hi:    0, btch:   1 usd:   0
19:18:58 kernel: CPU   12: hi:    0, btch:   1 usd:   0
19:18:58 kernel: CPU   13: hi:    0, btch:   1 usd:   0
19:18:58 kernel: CPU   14: hi:    0, btch:   1 usd:   0
19:18:58 kernel: CPU   15: hi:    0, btch:   1 usd:   0
19:18:58 kernel: CPU   16: hi:    0, btch:   1 usd:   0
19:18:58 kernel: CPU   17: hi:    0, btch:   1 usd:   0
19:18:58 kernel: CPU   18: hi:    0, btch:   1 usd:   0
19:18:58 kernel: CPU   19: hi:    0, btch:   1 usd:   0
19:18:58 kernel: CPU   20: hi:    0, btch:   1 usd:   0
19:18:58 kernel: CPU   21: hi:    0, btch:   1 usd:   0
19:18:58 kernel: CPU   22: hi:    0, btch:   1 usd:   0
19:18:58 kernel: CPU   23: hi:    0, btch:   1 usd:   0
19:18:58 kernel: Node 0 DMA32 per-cpu:
19:18:58 kernel: CPU    0: hi:  186, btch:  31 usd: 174
19:18:58 kernel: CPU    1: hi:  186, btch:  31 usd: 172
19:18:58 kernel: CPU    2: hi:  186, btch:  31 usd: 181
19:18:58 kernel: CPU    3: hi:  186, btch:  31 usd: 169
19:18:58 kernel: CPU    4: hi:  186, btch:  31 usd: 164
19:18:58 kernel: CPU    5: hi:  186, btch:  31 usd: 155
19:18:58 kernel: CPU    6: hi:  186, btch:  31 usd: 154
19:18:58 kernel: CPU    7: hi:  186, btch:  31 usd: 138
19:18:58 kernel: CPU    8: hi:  186, btch:  31 usd:  35
19:18:58 kernel: CPU    9: hi:  186, btch:  31 usd:   0
19:18:58 kernel: CPU   10: hi:  186, btch:  31 usd:  50
19:18:58 kernel: CPU   11: hi:  186, btch:  31 usd:   0
19:18:58 kernel: CPU   12: hi:  186, btch:  31 usd: 152
19:18:58 kernel: CPU   13: hi:  186, btch:  31 usd:   0
19:18:58 kernel: CPU   14: hi:  186, btch:  31 usd: 150
19:18:58 kernel: CPU   15: hi:  186, btch:  31 usd:   0
19:18:58 kernel: CPU   16: hi:  186, btch:  31 usd: 165
19:18:58 kernel: CPU   17: hi:  186, btch:  31 usd: 184
19:18:58 kernel: CPU   18: hi:  186, btch:  31 usd:   0
19:18:58 kernel: CPU   19: hi:  186, btch:  31 usd:  67
19:18:58 kernel: CPU   20: hi:  186, btch:  31 usd: 117
19:18:58 kernel: CPU   21: hi:  186, btch:  31 usd:   0
19:18:58 kernel: CPU   22: hi:  186, btch:  31 usd: 184
19:18:58 kernel: CPU   23: hi:  186, btch:  31 usd:   0
19:18:58 kernel: Node 0 Normal per-cpu:
19:18:58 kernel: CPU    0: hi:  186, btch:  31 usd: 179
19:18:58 kernel: CPU    1: hi:  186, btch:  31 usd:  42
19:18:58 kernel: CPU    2: hi:  186, btch:  31 usd:  27
19:18:58 kernel: CPU    3: hi:  186, btch:  31 usd:  86
19:18:58 kernel: CPU    4: hi:  186, btch:  31 usd:  59
19:18:58 kernel: CPU    5: hi:  186, btch:  31 usd:  24
19:18:58 kernel: CPU    6: hi:  186, btch:  31 usd: 160
19:18:58 kernel: CPU    7: hi:  186, btch:  31 usd: 175
19:18:58 kernel: CPU    8: hi:  186, btch:  31 usd: 166
19:18:58 kernel: CPU    9: hi:  186, btch:  31 usd: 166
19:18:58 kernel: CPU   10: hi:  186, btch:  31 usd: 103
19:18:58 kernel: CPU   11: hi:  186, btch:  31 usd: 172
19:18:58 kernel: CPU   12: hi:  186, btch:  31 usd: 178
19:18:58 kernel: CPU   13: hi:  186, btch:  31 usd: 183
19:18:58 kernel: CPU   14: hi:  186, btch:  31 usd: 178
19:18:58 kernel: CPU   15: hi:  186, btch:  31 usd: 177
19:18:58 kernel: CPU   16: hi:  186, btch:  31 usd: 157
19:18:58 kernel: CPU   17: hi:  186, btch:  31 usd: 180
19:18:58 kernel: CPU   18: hi:  186, btch:  31 usd: 172
19:18:58 kernel: CPU   19: hi:  186, btch:  31 usd: 171
19:18:58 kernel: CPU   20: hi:  186, btch:  31 usd: 174
19:18:58 kernel: CPU   21: hi:  186, btch:  31 usd: 159
19:18:58 kernel: CPU   22: hi:  186, btch:  31 usd: 166
19:18:58 kernel: CPU   23: hi:  186, btch:  31 usd: 181
19:18:58 kernel: Node 1 Normal per-cpu:
19:18:58 kernel: CPU    0: hi:  186, btch:  31 usd: 181
19:18:58 kernel: CPU    1: hi:  186, btch:  31 usd: 175
19:18:58 kernel: CPU    2: hi:  186, btch:  31 usd: 177
19:18:58 kernel: CPU    3: hi:  186, btch:  31 usd: 165
19:18:58 kernel: CPU    4: hi:  186, btch:  31 usd: 177
19:18:58 kernel: CPU    5: hi:  186, btch:  31 usd: 166
19:18:58 kernel: CPU    6: hi:  186, btch:  31 usd:  63
19:18:58 kernel: CPU    7: hi:  186, btch:  31 usd: 144
19:18:58 kernel: CPU    8: hi:  186, btch:  31 usd:  49
19:18:58 kernel: CPU    9: hi:  186, btch:  31 usd:  53
19:18:58 kernel: CPU   10: hi:  186, btch:  31 usd:  81
19:18:58 kernel: CPU   11: hi:  186, btch:  31 usd:  45
19:18:58 kernel: CPU   12: hi:  186, btch:  31 usd: 164
19:18:58 kernel: CPU   13: hi:  186, btch:  31 usd: 160
19:18:58 kernel: CPU   14: hi:  186, btch:  31 usd: 167
19:18:58 kernel: CPU   15: hi:  186, btch:  31 usd: 183
19:18:58 kernel: CPU   16: hi:  186, btch:  31 usd: 178
19:18:58 kernel: CPU   17: hi:  186, btch:  31 usd: 163
19:18:58 kernel: CPU   18: hi:  186, btch:  31 usd: 163
19:18:58 kernel: CPU   19: hi:  186, btch:  31 usd: 179
19:18:58 kernel: CPU   20: hi:  186, btch:  31 usd: 182
19:18:58 kernel: CPU   21: hi:  186, btch:  31 usd: 172
19:18:58 kernel: CPU   22: hi:  186, btch:  31 usd: 167
19:18:58 kernel: CPU   23: hi:  186, btch:  31 usd: 167
19:18:58 kernel: Node 2 Normal per-cpu:
19:18:58 kernel: CPU    0: hi:  186, btch:  31 usd: 176
19:18:58 kernel: CPU    1: hi:  186, btch:  31 usd: 173
19:18:58 kernel: CPU    2: hi:  186, btch:  31 usd: 169
19:18:58 kernel: CPU    3: hi:  186, btch:  31 usd: 175
19:18:58 kernel: CPU    4: hi:  186, btch:  31 usd: 168
19:18:58 kernel: CPU    5: hi:  186, btch:  31 usd: 165
19:18:58 kernel: CPU    6: hi:  186, btch:  31 usd: 167
19:18:58 kernel: CPU    7: hi:  186, btch:  31 usd: 170
19:18:58 kernel: CPU    8: hi:  186, btch:  31 usd: 174
19:18:58 kernel: CPU    9: hi:  186, btch:  31 usd: 182
19:18:58 kernel: CPU   10: hi:  186, btch:  31 usd: 102
19:18:58 kernel: CPU   11: hi:  186, btch:  31 usd: 183
19:18:58 kernel: CPU   12: hi:  186, btch:  31 usd:  56
19:18:58 kernel: CPU   13: hi:  186, btch:  31 usd:   8
19:18:58 kernel: CPU   14: hi:  186, btch:  31 usd:  29
19:18:58 kernel: CPU   15: hi:  186, btch:  31 usd: 129
19:18:58 kernel: CPU   16: hi:  186, btch:  31 usd: 106
19:18:58 kernel: CPU   17: hi:  186, btch:  31 usd: 167
19:18:58 kernel: CPU   18: hi:  186, btch:  31 usd: 177
19:18:58 kernel: CPU   19: hi:  186, btch:  31 usd: 182
19:18:58 kernel: CPU   20: hi:  186, btch:  31 usd: 185
19:18:58 kernel: CPU   21: hi:  186, btch:  31 usd: 180
19:18:58 kernel: CPU   22: hi:  186, btch:  31 usd: 170
19:18:58 kernel: CPU   23: hi:  186, btch:  31 usd: 158
19:18:58 kernel: Node 3 Normal per-cpu:
19:18:58 kernel: CPU    0: hi:  186, btch:  31 usd: 163
19:18:58 kernel: CPU    1: hi:  186, btch:  31 usd: 180
19:18:58 kernel: CPU    2: hi:  186, btch:  31 usd: 163
19:18:58 kernel: CPU    3: hi:  186, btch:  31 usd: 168
19:18:58 kernel: CPU    4: hi:  186, btch:  31 usd: 157
19:18:58 kernel: CPU    5: hi:  186, btch:  31 usd: 173
19:18:58 kernel: CPU    6: hi:  186, btch:  31 usd: 185
19:18:58 kernel: CPU    7: hi:  186, btch:  31 usd: 181
19:18:58 kernel: CPU    8: hi:  186, btch:  31 usd: 183
19:18:58 kernel: CPU    9: hi:  186, btch:  31 usd: 162
19:18:58 kernel: CPU   10: hi:  186, btch:  31 usd:  93
19:18:58 kernel: CPU   11: hi:  186, btch:  31 usd: 172
19:18:58 kernel: CPU   12: hi:  186, btch:  31 usd: 159
19:18:58 kernel: CPU   13: hi:  186, btch:  31 usd: 184
19:18:58 kernel: CPU   14: hi:  186, btch:  31 usd: 183
19:18:58 kernel: CPU   15: hi:  186, btch:  31 usd: 173
19:18:58 kernel: CPU   16: hi:  186, btch:  31 usd: 157
19:18:58 kernel: CPU   17: hi:  186, btch:  31 usd: 179
19:18:58 kernel: CPU   18: hi:  186, btch:  31 usd:  41
19:18:58 kernel: CPU   19: hi:  186, btch:  31 usd: 126
19:18:58 kernel: CPU   20: hi:  186, btch:  31 usd:  71
19:18:58 kernel: CPU   21: hi:  186, btch:  31 usd: 132
19:18:58 kernel: CPU   22: hi:  186, btch:  31 usd:  48
19:18:58 kernel: CPU   23: hi:  186, btch:  31 usd: 168
19:18:58 kernel: active_anon:785541 inactive_anon:913249 isolated_anon:0
19:18:58 kernel: active_file:5954471 inactive_file:8543210 isolated_file:0
19:18:58 kernel: unevictable:692 dirty:2350 writeback:29 unstable:0
19:18:58 kernel: free:15723008 slab_reclaimable:479688 slab_unreclaimable:335247
19:18:58 kernel: mapped:2130 shmem:77 pagetables:8584 bounce:0
19:18:58 kernel: free_cma:0
19:18:58 kernel: Node 0 DMA free:15872kB min:16kB low:20kB high:24kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15956kB managed:15872kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
19:18:58 kernel: lowmem_reserve[]: 0 3297 32096 32096
19:18:58 kernel: Node 0 DMA32 free:2945436kB min:3456kB low:4320kB high:5184kB active_anon:158764kB inactive_anon:175428kB active_file:7932kB inactive_file:25404kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3521024kB managed:3377352kB mlocked:0kB dirty:0kB writeback:0kB mapped:40kB shmem:0kB slab_reclaimable:34144kB slab_unreclaimable:14960kB kernel_stack:112kB pagetables:16kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
19:18:58 kernel: lowmem_reserve[]: 0 0 28799 28799
19:18:58 kernel: Node 0 Normal free:20550776kB min:30208kB low:37760kB high:45312kB active_anon:845284kB inactive_anon:978044kB active_file:2999684kB inactive_file:3491092kB unevictable:864kB isolated(anon):0kB isolated(file):0kB present:30015488kB managed:29490340kB mlocked:864kB dirty:2012kB writeback:0kB mapped:656kB shmem:20kB slab_reclaimable:243612kB slab_unreclaimable:112216kB kernel_stack:16360kB pagetables:16144kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
19:18:58 kernel: lowmem_reserve[]: 0 0 0 0
19:18:58 kernel: Node 1 Normal free:13633704kB min:33832kB low:42288kB high:50748kB active_anon:734132kB inactive_anon:865612kB active_file:6367144kB inactive_file:10216976kB unevictable:1304kB isolated(anon):0kB isolated(file):0kB present:33554432kB managed:33029392kB mlocked:1304kB dirty:2276kB writeback:0kB mapped:2560kB shmem:24kB slab_reclaimable:558032kB slab_unreclaimable:417212kB kernel_stack:5464kB pagetables:6268kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
19:18:58 kernel: lowmem_reserve[]: 0 0 0 0
19:18:58 kernel: Node 2 Normal free:13038632kB min:33832kB low:42288kB high:50748kB active_anon:703252kB inactive_anon:822104kB active_file:7046744kB inactive_file:10255204kB unevictable:4kB isolated(anon):0kB isolated(file):0kB present:33554432kB managed:33029396kB mlocked:4kB dirty:2276kB writeback:232kB mapped:2492kB shmem:260kB slab_reclaimable:550432kB slab_unreclaimable:360548kB kernel_stack:2880kB pagetables:5476kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
19:18:58 kernel: lowmem_reserve[]: 0 0 0 0
19:18:58 kernel: Node 3 Normal free:12707612kB min:33816kB low:42268kB high:50724kB active_anon:700732kB inactive_anon:811808kB active_file:7396380kB inactive_file:10184164kB unevictable:596kB isolated(anon):0kB isolated(file):0kB present:33538048kB managed:33012572kB mlocked:596kB dirty:2836kB writeback:124kB mapped:2772kB shmem:4kB slab_reclaimable:532532kB slab_unreclaimable:436052kB kernel_stack:4016kB pagetables:6432kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
19:18:58 kernel: lowmem_reserve[]: 0 0 0 0
19:18:58 kernel: Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (UM) = 15872kB
19:18:58 kernel: Node 0 DMA32: 59117*4kB (UEM) 50427*8kB (UEM) 39093*16kB (UEMR) 23485*32kB (UEMR) 9080*64kB (UEMR) 1644*128kB (EMR) 93*256kB (MR) 2*512kB (M) 2*1024kB (M) 44*2048kB (M) 5*4096kB (M) = 2945916kB
19:18:58 kernel: Node 0 Normal: 1220562*4kB (UEM) 644708*8kB (UEM) 247660*16kB (UEM) 99571*32kB (UEM) 35224*64kB (UEM) 5635*128kB (UM) 224*256kB (UM) 8*512kB (UM) 4*1024kB (UM) 125*2048kB (UM) 16*4096kB (UMR) = 20551432kB
19:18:58 kernel: Node 1 Normal: 1057969*4kB (UEM) 524494*8kB (UEM) 193734*16kB (UEM) 51273*32kB (UEM) 5324*64kB (UM) 182*128kB (UEM) 27*256kB (UM) 9*512kB (UM) 4*1024kB (U) 38*2048kB (MR) 2*4096kB (M) = 13633972kB
19:18:58 kernel: Node 2 Normal: 974011*4kB (UEM) 468174*8kB (UEM) 205943*16kB (UEM) 48968*32kB (UEMR) 5261*64kB (UMR) 163*128kB (UM) 36*256kB (UMR) 17*512kB (UMR) 7*1024kB (UMR) 57*2048kB (UMR) 9*4096kB (M) = 13039756kB
19:18:58 kernel: Node 3 Normal: 936699*4kB (UEM) 460684*8kB (UEM) 185256*16kB (UEM) 53027*32kB (UEM) 6969*64kB (UM) 232*128kB (UM) 20*256kB (UM) 9*512kB (UM) 3*1024kB (UM) 42*2048kB (UMR) 10*4096kB (M) = 12708716kB
19:18:58 kernel: Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
19:18:58 kernel: Node 1 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
19:18:58 kernel: Node 2 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
19:18:58 kernel: Node 3 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
19:18:58 kernel: 14631550 total pagecache pages
19:18:58 kernel: 133292 pages in swap cache
19:18:58 kernel: Swap cache stats: add 76179491, delete 76046592, find 106822519/1083908176
19:18:58 kernel: Free swap  = 10073924kB
19:18:58 kernel: Total swap = 11184368kB
19:18:58 kernel: device vnet29.0 left promiscuous mode
19:18:58 kernel: br0: port 31(vnet29.0) entered disabled state
19:18:59 kernel: 33550335 pages RAM
19:18:59 kernel: 561604 pages reserved
19:18:59 kernel: 15009897 pages shared
19:18:59 kernel: 2741480 pages non-shared
19:18:59 kernel: [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
19:18:59 kernel: [ 2025]     0  2025      985      134       8        0         -1000 udevd
19:18:59 kernel: [ 2973]     0  2973     4925      122      14        0             0 rc.startup
19:18:59 kernel: [ 2974]     0  2974     4925      122      14        0             0 rc.startup
19:18:59 kernel: [ 2975]     0  2975     4925      122      14        0             0 rc.startup
19:18:59 kernel: [ 2976]     0  2976      962       93       8        0             0 agetty
19:18:59 kernel: [ 2977]     0  2977     4925      120      14        0             0 rc.startup
19:18:59 kernel: [ 2978]     0  2978      962       96       9        0             0 agetty
19:18:59 kernel: [ 2979]     0  2979     4925      122      14        0             0 rc.startup
19:18:59 kernel: [ 2981]     0  2981      962       95       7        0             0 agetty
19:18:59 kernel: [ 2982]     0  2982     4925      122      14        0             0 rc.startup
19:18:59 kernel: [ 2983]     0  2983      962       95       8        0             0 agetty
19:18:59 kernel: [ 2984]     0  2984      962       96       8        0             0 agetty
19:18:59 kernel: [ 2985]     0  2985     4925      122      14        0             0 rc.startup
19:18:59 kernel: [ 2986]     0  2986      962       95       8        0             0 agetty
19:18:59 kernel: [ 2987]     0  2987     4925      122      14        0             0 rc.startup
19:18:59 kernel: [ 2988]     0  2988      962       96       7        0             0 agetty
19:18:59 kernel: [ 2989]     0  2989     4925      122      14        0             0 rc.startup
19:18:59 kernel: [ 2990]     0  2990      962       95       8        0             0 agetty
19:18:59 kernel: [ 2991]     0  2991     6229     1462      17        0             0 rc.startup
19:18:59 kernel: [ 2992]     0  2992      962       95       8        0             0 agetty
19:18:59 kernel: [ 3033]     0  3033    45785      373      23        0             0 rsyslogd
19:18:59 kernel: [ 3038]     0  3038     6751      288      18        0             0 sshd
19:18:59 kernel: [ 3041]     0  3041    23587      218      16        0             0 automount
19:18:59 kernel: [ 3051]     0  3051     1009      113       8        0             0 iscsid
19:18:59 kernel: [ 3052]     0  3052     3245      693      13        0         -1000 iscsid
19:18:59 kernel: [ 3057] 65534  3057     3210      282      11        0             0 dnsmasq
19:18:59 kernel: [ 3059]     0  3059     3354      258      12        0             0 ntpd
19:18:59 kernel: [16042]     0 16042    36377       85      25        0             0 diod
19:18:59 kernel: [16067]     0 16067     8142      638      19        0             0 httpd
19:18:59 kernel: [16069]     0 16069     4918      370      16        0             0 elastic-poolio
19:18:59 kernel: [16072]     0 16072     5798     1098      15        0             0 elastic-floodwa
19:18:59 kernel: [16085]     0 16085    66136      526      53        0             0 httpd
19:18:59 kernel: [16086]     0 16086    66136      668      53        0             0 httpd
19:18:59 kernel: [16087]     0 16087    66136      594      53        0             0 httpd
19:18:59 kernel: [25306]     0 25306     5277      558      15        5             0 elastic
19:18:59 kernel: [25518] 65540 25518   300162   121929     364    33810             0 qemu-system-x86
19:18:59 kernel: [25736]     0 25736     5283      554      16       18             0 elastic
19:18:59 kernel: [25918] 65541 25918   360308   152319     483    26939             0 qemu-system-x86
19:18:59 kernel: [31550]     0 31550     5277      615      16        2             0 elastic
19:18:59 kernel: [32304]     0 32304     5277      551      14       13             0 elastic
19:18:59 kernel: [32497] 65557 32497   284361    80540     219    13424             0 qemu-system-x86
19:18:59 kernel: [ 1127]     0  1127     5277      561      15        3             0 elastic
19:18:59 kernel: [ 1748] 65560  1748   113153    70173     222    15026             0 qemu-system-x86
19:18:59 kernel: [ 1993]     0  1993     5277      540      14       24             0 elastic
19:18:59 kernel: [ 2210] 65562  2210   308845   144092     404    23954             0 qemu-system-x86
19:18:59 kernel: [ 2366]     0  2366     5283      555      14       17             0 elastic
19:18:59 kernel: [ 2781]     0  2781     5277      558      14        5             0 elastic
19:18:59 kernel: [ 3197] 65563  3197   304254   208272     485    21858             0 qemu-system-x86
19:18:59 kernel: [ 3291]     0  3291     5279      622      15        1             0 elastic
19:18:59 kernel: [ 3596] 65564  3596   153526    71587     214    19711             0 qemu-system-x86
19:18:59 kernel: [ 5658]     0  5658     5277      532      15       32             0 elastic
19:18:59 kernel: [ 5877] 65570  5877   284444   186817     485    43190             0 qemu-system-x86
19:18:59 kernel: [ 7548]     0  7548     5283      561      14       13             0 elastic
19:18:59 kernel: [ 7750] 65574  7750   285233   239214     541    20559             0 qemu-system-x86
19:18:59 kernel: [ 8409]     0  8409     5283      566      14        7             0 elastic
19:18:59 kernel: [ 8766]     0  8766     5283      563      15       11             0 elastic
19:18:59 kernel: [ 9072] 65576  9072   285357   101128     261    14826             0 qemu-system-x86
19:18:59 kernel: [ 9093] 65577  9093   172968   128163     297     6109             0 qemu-system-x86
19:18:59 kernel: [ 9249]     0  9249     5283      555      15       18             0 elastic
19:18:59 kernel: [ 9529] 65578  9529   604341   107074     344    15520             0 qemu-system-x86
19:18:59 kernel: [24828]     0 24828     5277      559      14        6             0 elastic
19:18:59 kernel: [25039] 65558 25039   566213    62407     186    12219             0 qemu-system-x86
19:18:59 kernel: [ 7688]     0  7688    66136      557      53        0             0 httpd
19:18:59 kernel: [21929]     0 21929     5298      556      14       28             0 elastic
19:18:59 kernel: [22106] 65544 22106   293706    43619     161    11838             0 qemu-system-x86
19:18:59 kernel: [20921]     0 20921      984      111       8        0         -1000 udevd
19:18:59 kernel: [20925]     0 20925      984      116       8        0         -1000 udevd
19:18:59 kernel: [16177]     0 16177     5303      661      15        1             0 elastic
19:18:59 kernel: [16978]     0 16978     5303      558      13       35             0 elastic
19:18:59 kernel: [20134] 65581 20134   547551    43378     129     3136             0 qemu-system-x86
19:18:59 kernel: [16674] 65555 16674   324070    57979     220     1345             0 qemu-system-x86
19:18:59 kernel: [25345]     0 25345     7892      411      20        0             0 lighttpd
19:18:59 kernel: [25494]     0 25494  4103458     3096    2019        0         -1000 tgtd
19:18:59 kernel: [25496]     0 25496     1565       85       9        0         -1000 tgtd
19:18:59 kernel: [ 9136]     0  9136     5297      582      16        0             0 elastic
19:18:59 kernel: [ 9357] 65582  9357   289351    56231     162     2705             0 qemu-system-x86
19:18:59 kernel: [ 9358]     0  9358     5297      554      14       29             0 elastic
19:18:59 kernel: [ 9568] 65551  9568    88036    39041     114      371             0 qemu-system-x86
19:18:59 kernel: [14997]     0 14997      962      153       8        0             0 agetty
19:18:59 kernel: [15520]     0 15520     1992      105       8        0             0 sleep
19:18:59 kernel: [16479]     0 16479      984       46       8        0         -1000 udevd
19:18:59 kernel: [16639]     0 16639     8427      577      21        0             0 curl
19:18:59 kernel: [16663]     0 16663     5279      532      13        1             0 elastic
19:18:59 kernel: [16664]     0 16664     5280      531      13        1             0 elastic
19:18:59 kernel: [16665]     0 16665        2        1       1        0             0 elastic
19:18:59 kernel: Out of memory: Kill process 7750 (qemu-system-x86) score 7 or sacrifice child
19:18:59 kernel: Killed process 7750 (qemu-system-x86) total-vm:1140932kB, anon-rss:954632kB, file-rss:2224kB


This is the kernel build config:

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86 3.11.3 Kernel Configuration
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_CPU_AUTOPROBE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_HAVE_INTEL_TXT=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION="-elastic"
# CONFIG_LOCALVERSION_AUTO is not set
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
CONFIG_KERNEL_XZ=y
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
CONFIG_FHANDLE=y
# CONFIG_AUDIT is not set
CONFIG_HAVE_GENERIC_HARDIRQS=y

#
# IRQ subsystem
#
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
# CONFIG_NO_HZ_IDLE is not set
CONFIG_NO_HZ_FULL=y
CONFIG_NO_HZ_FULL_ALL=y
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_VIRT_CPU_ACCOUNTING=y
CONFIG_VIRT_CPU_ACCOUNTING_GEN=y
# CONFIG_BSD_PROCESS_ACCT is not set
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
# CONFIG_TASK_XACCT is not set

#
# RCU Subsystem
#
CONFIG_TREE_PREEMPT_RCU=y
CONFIG_PREEMPT_RCU=y
CONFIG_RCU_STALL_COMMON=y
CONFIG_CONTEXT_TRACKING=y
CONFIG_RCU_USER_QS=y
CONFIG_CONTEXT_TRACKING_FORCE=y
CONFIG_RCU_FANOUT=64
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_FANOUT_EXACT is not set
# CONFIG_RCU_FAST_NO_HZ is not set
# CONFIG_TREE_RCU_TRACE is not set
# CONFIG_RCU_BOOST is not set
CONFIG_RCU_NOCB_CPU=y
CONFIG_RCU_NOCB_CPU_ALL=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=18
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
CONFIG_ARCH_USES_NUMA_PROT_NONE=y
CONFIG_NUMA_BALANCING_DEFAULT_ENABLED=y
CONFIG_NUMA_BALANCING=y
CONFIG_CGROUPS=y
# CONFIG_CGROUP_DEBUG is not set
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_DEVICE=y
CONFIG_CPUSETS=y
# CONFIG_PROC_PID_CPUSET is not set
CONFIG_CGROUP_CPUACCT=y
CONFIG_RESOURCE_COUNTERS=y
CONFIG_MEMCG=y
CONFIG_MEMCG_SWAP=y
CONFIG_MEMCG_SWAP_ENABLED=y
CONFIG_MEMCG_KMEM=y
CONFIG_CGROUP_HUGETLB=y
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
CONFIG_RT_GROUP_SCHED=y
CONFIG_BLK_CGROUP=y
# CONFIG_DEBUG_BLK_CGROUP is not set
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
CONFIG_USER_NS=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y
CONFIG_UIDGID_CONVERTED=y
CONFIG_UIDGID_STRICT_TYPE_CHECKS=y
# CONFIG_SCHED_AUTOGROUP is not set
CONFIG_MM_OWNER=y
# CONFIG_SYSFS_DEPRECATED is not set
# CONFIG_RELAY is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
# CONFIG_EXPERT is not set
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_KALLSYMS=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_PCI_QUIRKS=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=y
CONFIG_SLUB_CPU_PARTIAL=y
# CONFIG_PROFILING is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_KPROBES is not set
# CONFIG_JUMP_LABEL is not set
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_USE_GENERIC_SMP_HELPERS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MODULES_USE_ELF_RELA=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
# CONFIG_MODULE_FORCE_LOAD is not set
CONFIG_MODULE_UNLOAD=y
# CONFIG_MODULE_FORCE_UNLOAD is not set
CONFIG_MODVERSIONS=y
# CONFIG_MODULE_SRCVERSION_ALL is not set
# CONFIG_MODULE_SIG is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
# CONFIG_BLK_DEV_INTEGRITY is not set
# CONFIG_BLK_DEV_THROTTLING is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
# CONFIG_AIX_PARTITION is not set
# CONFIG_OSF_PARTITION is not set
# CONFIG_AMIGA_PARTITION is not set
# CONFIG_ATARI_PARTITION is not set
# CONFIG_MAC_PARTITION is not set
CONFIG_MSDOS_PARTITION=y
CONFIG_BSD_DISKLABEL=y
# CONFIG_MINIX_SUBPARTITION is not set
CONFIG_SOLARIS_X86_PARTITION=y
# CONFIG_UNIXWARE_DISKLABEL is not set
CONFIG_LDM_PARTITION=y
# CONFIG_LDM_DEBUG is not set
# CONFIG_SGI_PARTITION is not set
# CONFIG_ULTRIX_PARTITION is not set
# CONFIG_SUN_PARTITION is not set
# CONFIG_KARMA_PARTITION is not set
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
# CONFIG_CFQ_GROUP_IOSCHED is not set
CONFIG_DEFAULT_DEADLINE=y
# CONFIG_DEFAULT_CFQ is not set
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="deadline"
CONFIG_PREEMPT_NOTIFIERS=y
CONFIG_PADATA=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_MUTEX_SPIN_ON_OWNER=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_X2APIC=y
CONFIG_X86_MPPARSE=y
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_VSMP is not set
# CONFIG_X86_UV is not set
# CONFIG_X86_INTEL_LPSS is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
CONFIG_SCHED_OMIT_FRAME_POINTER=y
# CONFIG_HYPERVISOR_GUEST is not set
CONFIG_NO_BOOTMEM=y
CONFIG_MEMTEST=y
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_NR_CPUS=64
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=y
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
CONFIG_X86_MCE_AMD=y
CONFIG_X86_MCE_THRESHOLD=y
# CONFIG_X86_MCE_INJECT is not set
CONFIG_X86_THERMAL_VECTOR=y
# CONFIG_I8K is not set
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_MICROCODE_INTEL_LIB=y
CONFIG_MICROCODE_INTEL_EARLY=y
CONFIG_MICROCODE_AMD_EARLY=y
CONFIG_MICROCODE_EARLY=y
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DIRECT_GBPAGES=y
CONFIG_NUMA=y
CONFIG_AMD_NUMA=y
CONFIG_X86_64_ACPI_NUMA=y
CONFIG_NODES_SPAN_OTHER_NODES=y
# CONFIG_NUMA_EMU is not set
CONFIG_NODES_SHIFT=4
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_PROC_KCORE_TEXT=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_MOVABLE_NODE is not set
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
# CONFIG_MEMORY_HOTPLUG is not set
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_CLEANCACHE=y
CONFIG_FRONTSWAP=y
CONFIG_ZBUD=y
CONFIG_ZSWAP=y
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
CONFIG_CC_STACKPROTECTOR=y
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
CONFIG_HZ_1000=y
CONFIG_HZ=1000
CONFIG_SCHED_HRTICK=y
# CONFIG_KEXEC is not set
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x1000000
# CONFIG_HOTPLUG_CPU is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_USE_PERCPU_NUMA_NODE_ID=y

#
# Power management and ACPI options
#
# CONFIG_SUSPEND is not set
# CONFIG_HIBERNATION is not set
CONFIG_PM_RUNTIME=y
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ACPI=y
# CONFIG_ACPI_PROCFS is not set
# CONFIG_ACPI_PROCFS_POWER is not set
# CONFIG_ACPI_EC_DEBUGFS is not set
# CONFIG_ACPI_PROC_EVENT is not set
# CONFIG_ACPI_AC is not set
# CONFIG_ACPI_BATTERY is not set
# CONFIG_ACPI_BUTTON is not set
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_I2C=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_IPMI=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=y
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_NUMA=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
# CONFIG_ACPI_CONTAINER is not set
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_APEI is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_MULTIPLE_DRIVERS is not set
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
CONFIG_INTEL_IDLE=y

#
# Memory power savings
#
CONFIG_I7300_IDLE_IOAT_CHANNEL=y
CONFIG_I7300_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
# CONFIG_PCI_MMCONFIG is not set
CONFIG_PCI_DOMAINS=y
CONFIG_PCIEPORTBUS=y
CONFIG_PCIEAER=y
# CONFIG_PCIE_ECRC is not set
# CONFIG_PCIEAER_INJECT is not set
CONFIG_PCIEASPM=y
# CONFIG_PCIEASPM_DEBUG is not set
CONFIG_PCIEASPM_DEFAULT=y
# CONFIG_PCIEASPM_POWERSAVE is not set
# CONFIG_PCIEASPM_PERFORMANCE is not set
CONFIG_PCIE_PME=y
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
CONFIG_PCI_STUB=y
CONFIG_HT_IRQ=y
CONFIG_PCI_ATS=y
CONFIG_PCI_IOV=y
CONFIG_PCI_PRI=y
CONFIG_PCI_PASID=y
CONFIG_PCI_IOAPIC=y
CONFIG_PCI_LABEL=y

#
# PCI host controller drivers
#
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
# CONFIG_PCCARD is not set
# CONFIG_HOTPLUG_PCI is not set
# CONFIG_RAPIDIO is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
# CONFIG_BINFMT_MISC is not set
CONFIG_COREDUMP=y
# CONFIG_IA32_EMULATION is not set
CONFIG_HAVE_TEXT_POKE_SMP=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_PACKET_DIAG=y
CONFIG_UNIX=y
CONFIG_UNIX_DIAG=y
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
CONFIG_XFRM_SUB_POLICY=y
CONFIG_XFRM_MIGRATE=y
CONFIG_XFRM_STATISTICS=y
CONFIG_XFRM_IPCOMP=y
# CONFIG_NET_KEY is not set
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_ROUTE_CLASSID=y
# CONFIG_IP_PNP is not set
# CONFIG_NET_IPIP is not set
CONFIG_NET_IPGRE_DEMUX=y
CONFIG_NET_IP_TUNNEL=y
# CONFIG_NET_IPGRE is not set
# CONFIG_IP_MROUTE is not set
# CONFIG_ARPD is not set
CONFIG_SYN_COOKIES=y
CONFIG_NET_IPVTI=y
CONFIG_INET_AH=y
CONFIG_INET_ESP=y
CONFIG_INET_IPCOMP=y
CONFIG_INET_XFRM_TUNNEL=y
CONFIG_INET_TUNNEL=y
CONFIG_INET_XFRM_MODE_TRANSPORT=y
CONFIG_INET_XFRM_MODE_TUNNEL=y
CONFIG_INET_XFRM_MODE_BEET=y
CONFIG_INET_LRO=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
CONFIG_INET_UDP_DIAG=y
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
CONFIG_TCP_MD5SIG=y
CONFIG_IPV6=y
CONFIG_IPV6_PRIVACY=y
CONFIG_IPV6_ROUTER_PREF=y
CONFIG_IPV6_ROUTE_INFO=y
CONFIG_IPV6_OPTIMISTIC_DAD=y
CONFIG_INET6_AH=y
CONFIG_INET6_ESP=y
CONFIG_INET6_IPCOMP=y
CONFIG_IPV6_MIP6=y
CONFIG_INET6_XFRM_TUNNEL=y
CONFIG_INET6_TUNNEL=y
CONFIG_INET6_XFRM_MODE_TRANSPORT=y
CONFIG_INET6_XFRM_MODE_TUNNEL=y
CONFIG_INET6_XFRM_MODE_BEET=y
CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=y
CONFIG_IPV6_SIT=y
CONFIG_IPV6_SIT_6RD=y
CONFIG_IPV6_NDISC_NODETYPE=y
CONFIG_IPV6_TUNNEL=y
CONFIG_IPV6_GRE=y
CONFIG_IPV6_MULTIPLE_TABLES=y
CONFIG_IPV6_SUBTREES=y
CONFIG_IPV6_MROUTE=y
CONFIG_IPV6_MROUTE_MULTIPLE_TABLES=y
CONFIG_IPV6_PIMSM_V2=y
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_DEBUG is not set
CONFIG_NETFILTER_ADVANCED=y
CONFIG_BRIDGE_NETFILTER=y

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_NETLINK=y
CONFIG_NETFILTER_NETLINK_ACCT=y
CONFIG_NETFILTER_NETLINK_QUEUE=y
CONFIG_NETFILTER_NETLINK_LOG=y
CONFIG_NF_CONNTRACK=y
CONFIG_NF_CONNTRACK_MARK=y
# CONFIG_NF_CONNTRACK_ZONES is not set
CONFIG_NF_CONNTRACK_PROCFS=y
CONFIG_NF_CONNTRACK_EVENTS=y
CONFIG_NF_CONNTRACK_TIMEOUT=y
CONFIG_NF_CONNTRACK_TIMESTAMP=y
CONFIG_NF_CONNTRACK_LABELS=y
CONFIG_NF_CT_PROTO_DCCP=y
CONFIG_NF_CT_PROTO_GRE=y
CONFIG_NF_CT_PROTO_SCTP=y
CONFIG_NF_CT_PROTO_UDPLITE=y
CONFIG_NF_CONNTRACK_AMANDA=y
CONFIG_NF_CONNTRACK_FTP=y
CONFIG_NF_CONNTRACK_H323=y
CONFIG_NF_CONNTRACK_IRC=y
CONFIG_NF_CONNTRACK_BROADCAST=y
CONFIG_NF_CONNTRACK_NETBIOS_NS=y
CONFIG_NF_CONNTRACK_SNMP=y
CONFIG_NF_CONNTRACK_PPTP=y
CONFIG_NF_CONNTRACK_SANE=y
CONFIG_NF_CONNTRACK_SIP=y
CONFIG_NF_CONNTRACK_TFTP=y
CONFIG_NF_CT_NETLINK=y
CONFIG_NF_CT_NETLINK_TIMEOUT=y
CONFIG_NF_CT_NETLINK_HELPER=y
CONFIG_NETFILTER_NETLINK_QUEUE_CT=y
CONFIG_NF_NAT=y
CONFIG_NF_NAT_NEEDED=y
CONFIG_NF_NAT_PROTO_DCCP=y
CONFIG_NF_NAT_PROTO_UDPLITE=y
CONFIG_NF_NAT_PROTO_SCTP=y
CONFIG_NF_NAT_AMANDA=y
CONFIG_NF_NAT_FTP=y
CONFIG_NF_NAT_IRC=y
CONFIG_NF_NAT_SIP=y
CONFIG_NF_NAT_TFTP=y
CONFIG_NETFILTER_TPROXY=y
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=y
CONFIG_NETFILTER_XT_CONNMARK=y
CONFIG_NETFILTER_XT_SET=y

#
# Xtables targets
#
CONFIG_NETFILTER_XT_TARGET_CHECKSUM=y
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=y
CONFIG_NETFILTER_XT_TARGET_CONNMARK=y
CONFIG_NETFILTER_XT_TARGET_CT=y
CONFIG_NETFILTER_XT_TARGET_DSCP=y
CONFIG_NETFILTER_XT_TARGET_HL=y
CONFIG_NETFILTER_XT_TARGET_HMARK=y
CONFIG_NETFILTER_XT_TARGET_IDLETIMER=y
CONFIG_NETFILTER_XT_TARGET_LOG=y
CONFIG_NETFILTER_XT_TARGET_MARK=y
CONFIG_NETFILTER_XT_TARGET_NETMAP=y
CONFIG_NETFILTER_XT_TARGET_NFLOG=y
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=y
CONFIG_NETFILTER_XT_TARGET_NOTRACK=y
CONFIG_NETFILTER_XT_TARGET_RATEEST=y
CONFIG_NETFILTER_XT_TARGET_REDIRECT=y
CONFIG_NETFILTER_XT_TARGET_TEE=y
CONFIG_NETFILTER_XT_TARGET_TPROXY=y
CONFIG_NETFILTER_XT_TARGET_TRACE=y
CONFIG_NETFILTER_XT_TARGET_TCPMSS=y
CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=y

#
# Xtables matches
#
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y
CONFIG_NETFILTER_XT_MATCH_BPF=y
CONFIG_NETFILTER_XT_MATCH_CLUSTER=y
CONFIG_NETFILTER_XT_MATCH_COMMENT=y
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=y
CONFIG_NETFILTER_XT_MATCH_CONNLABEL=y
CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=y
CONFIG_NETFILTER_XT_MATCH_CONNMARK=y
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y
CONFIG_NETFILTER_XT_MATCH_CPU=y
CONFIG_NETFILTER_XT_MATCH_DCCP=y
CONFIG_NETFILTER_XT_MATCH_DEVGROUP=y
CONFIG_NETFILTER_XT_MATCH_DSCP=y
CONFIG_NETFILTER_XT_MATCH_ECN=y
CONFIG_NETFILTER_XT_MATCH_ESP=y
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=y
CONFIG_NETFILTER_XT_MATCH_HELPER=y
CONFIG_NETFILTER_XT_MATCH_HL=y
CONFIG_NETFILTER_XT_MATCH_IPRANGE=y
CONFIG_NETFILTER_XT_MATCH_LENGTH=y
CONFIG_NETFILTER_XT_MATCH_LIMIT=y
CONFIG_NETFILTER_XT_MATCH_MAC=y
CONFIG_NETFILTER_XT_MATCH_MARK=y
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=y
CONFIG_NETFILTER_XT_MATCH_NFACCT=y
CONFIG_NETFILTER_XT_MATCH_OSF=y
CONFIG_NETFILTER_XT_MATCH_OWNER=y
CONFIG_NETFILTER_XT_MATCH_POLICY=y
CONFIG_NETFILTER_XT_MATCH_PHYSDEV=y
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=y
CONFIG_NETFILTER_XT_MATCH_QUOTA=y
CONFIG_NETFILTER_XT_MATCH_RATEEST=y
CONFIG_NETFILTER_XT_MATCH_REALM=y
CONFIG_NETFILTER_XT_MATCH_RECENT=y
CONFIG_NETFILTER_XT_MATCH_SCTP=y
CONFIG_NETFILTER_XT_MATCH_SOCKET=y
CONFIG_NETFILTER_XT_MATCH_STATE=y
CONFIG_NETFILTER_XT_MATCH_STATISTIC=y
CONFIG_NETFILTER_XT_MATCH_STRING=y
CONFIG_NETFILTER_XT_MATCH_TCPMSS=y
CONFIG_NETFILTER_XT_MATCH_TIME=y
CONFIG_NETFILTER_XT_MATCH_U32=y
CONFIG_IP_SET=y
CONFIG_IP_SET_MAX=256
CONFIG_IP_SET_BITMAP_IP=y
CONFIG_IP_SET_BITMAP_IPMAC=y
CONFIG_IP_SET_BITMAP_PORT=y
CONFIG_IP_SET_HASH_IP=y
CONFIG_IP_SET_HASH_IPPORT=y
CONFIG_IP_SET_HASH_IPPORTIP=y
CONFIG_IP_SET_HASH_IPPORTNET=y
CONFIG_IP_SET_HASH_NET=y
CONFIG_IP_SET_HASH_NETPORT=y
CONFIG_IP_SET_HASH_NETIFACE=y
CONFIG_IP_SET_LIST_SET=y
# CONFIG_IP_VS is not set

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=y
CONFIG_NF_CONNTRACK_IPV4=y
CONFIG_NF_CONNTRACK_PROC_COMPAT=y
CONFIG_IP_NF_IPTABLES=y
CONFIG_IP_NF_MATCH_AH=y
CONFIG_IP_NF_MATCH_ECN=y
CONFIG_IP_NF_MATCH_RPFILTER=y
CONFIG_IP_NF_MATCH_TTL=y
CONFIG_IP_NF_FILTER=y
CONFIG_IP_NF_TARGET_REJECT=y
CONFIG_IP_NF_TARGET_ULOG=y
CONFIG_NF_NAT_IPV4=y
CONFIG_IP_NF_TARGET_MASQUERADE=y
CONFIG_IP_NF_TARGET_NETMAP=y
CONFIG_IP_NF_TARGET_REDIRECT=y
CONFIG_NF_NAT_SNMP_BASIC=y
CONFIG_NF_NAT_PROTO_GRE=y
CONFIG_NF_NAT_PPTP=y
CONFIG_NF_NAT_H323=y
CONFIG_IP_NF_MANGLE=y
CONFIG_IP_NF_TARGET_CLUSTERIP=y
CONFIG_IP_NF_TARGET_ECN=y
CONFIG_IP_NF_TARGET_TTL=y
CONFIG_IP_NF_RAW=y
CONFIG_IP_NF_ARPTABLES=y
CONFIG_IP_NF_ARPFILTER=y
CONFIG_IP_NF_ARP_MANGLE=y

#
# IPv6: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV6=y
CONFIG_NF_CONNTRACK_IPV6=y
CONFIG_IP6_NF_IPTABLES=y
CONFIG_IP6_NF_MATCH_AH=y
CONFIG_IP6_NF_MATCH_EUI64=y
CONFIG_IP6_NF_MATCH_FRAG=y
CONFIG_IP6_NF_MATCH_OPTS=y
CONFIG_IP6_NF_MATCH_HL=y
CONFIG_IP6_NF_MATCH_IPV6HEADER=y
CONFIG_IP6_NF_MATCH_MH=y
CONFIG_IP6_NF_MATCH_RPFILTER=y
CONFIG_IP6_NF_MATCH_RT=y
CONFIG_IP6_NF_TARGET_HL=y
CONFIG_IP6_NF_FILTER=y
CONFIG_IP6_NF_TARGET_REJECT=y
CONFIG_IP6_NF_MANGLE=y
CONFIG_IP6_NF_RAW=y
CONFIG_NF_NAT_IPV6=y
CONFIG_IP6_NF_TARGET_MASQUERADE=y
CONFIG_IP6_NF_TARGET_NPT=y
CONFIG_BRIDGE_NF_EBTABLES=y
CONFIG_BRIDGE_EBT_BROUTE=y
CONFIG_BRIDGE_EBT_T_FILTER=y
CONFIG_BRIDGE_EBT_T_NAT=y
CONFIG_BRIDGE_EBT_802_3=y
CONFIG_BRIDGE_EBT_AMONG=y
CONFIG_BRIDGE_EBT_ARP=y
CONFIG_BRIDGE_EBT_IP=y
CONFIG_BRIDGE_EBT_IP6=y
CONFIG_BRIDGE_EBT_LIMIT=y
CONFIG_BRIDGE_EBT_MARK=y
CONFIG_BRIDGE_EBT_PKTTYPE=y
CONFIG_BRIDGE_EBT_STP=y
CONFIG_BRIDGE_EBT_VLAN=y
CONFIG_BRIDGE_EBT_ARPREPLY=y
CONFIG_BRIDGE_EBT_DNAT=y
CONFIG_BRIDGE_EBT_MARK_T=y
CONFIG_BRIDGE_EBT_REDIRECT=y
CONFIG_BRIDGE_EBT_SNAT=y
CONFIG_BRIDGE_EBT_LOG=y
# CONFIG_BRIDGE_EBT_ULOG is not set
CONFIG_BRIDGE_EBT_NFLOG=y
# CONFIG_IP_DCCP is not set
# CONFIG_IP_SCTP is not set
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_L2TP is not set
CONFIG_STP=y
CONFIG_GARP=y
CONFIG_MRP=y
CONFIG_BRIDGE=y
CONFIG_BRIDGE_IGMP_SNOOPING=y
CONFIG_BRIDGE_VLAN_FILTERING=y
CONFIG_HAVE_NET_DSA=y
CONFIG_VLAN_8021Q=y
CONFIG_VLAN_8021Q_GVRP=y
CONFIG_VLAN_8021Q_MVRP=y
# CONFIG_DECNET is not set
CONFIG_LLC=y
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=y
CONFIG_NET_SCH_HTB=y
CONFIG_NET_SCH_HFSC=y
CONFIG_NET_SCH_PRIO=y
CONFIG_NET_SCH_MULTIQ=y
CONFIG_NET_SCH_RED=y
CONFIG_NET_SCH_SFB=y
CONFIG_NET_SCH_SFQ=y
CONFIG_NET_SCH_TEQL=y
CONFIG_NET_SCH_TBF=y
CONFIG_NET_SCH_GRED=y
CONFIG_NET_SCH_DSMARK=y
CONFIG_NET_SCH_NETEM=y
CONFIG_NET_SCH_DRR=y
CONFIG_NET_SCH_MQPRIO=y
CONFIG_NET_SCH_CHOKE=y
CONFIG_NET_SCH_QFQ=y
CONFIG_NET_SCH_CODEL=y
CONFIG_NET_SCH_FQ_CODEL=y
CONFIG_NET_SCH_INGRESS=y
CONFIG_NET_SCH_PLUG=y

#
# Classification
#
CONFIG_NET_CLS=y
CONFIG_NET_CLS_BASIC=y
CONFIG_NET_CLS_TCINDEX=y
CONFIG_NET_CLS_ROUTE4=y
CONFIG_NET_CLS_FW=y
CONFIG_NET_CLS_U32=y
CONFIG_CLS_U32_PERF=y
CONFIG_CLS_U32_MARK=y
CONFIG_NET_CLS_RSVP=y
CONFIG_NET_CLS_RSVP6=y
CONFIG_NET_CLS_FLOW=y
# CONFIG_NET_CLS_CGROUP is not set
CONFIG_NET_EMATCH=y
CONFIG_NET_EMATCH_STACK=32
CONFIG_NET_EMATCH_CMP=y
CONFIG_NET_EMATCH_NBYTE=y
CONFIG_NET_EMATCH_U32=y
CONFIG_NET_EMATCH_META=y
CONFIG_NET_EMATCH_TEXT=y
CONFIG_NET_EMATCH_IPSET=y
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_POLICE=y
CONFIG_NET_ACT_GACT=y
CONFIG_GACT_PROB=y
CONFIG_NET_ACT_MIRRED=y
CONFIG_NET_ACT_IPT=y
CONFIG_NET_ACT_NAT=y
CONFIG_NET_ACT_PEDIT=y
CONFIG_NET_ACT_SIMP=y
CONFIG_NET_ACT_SKBEDIT=y
CONFIG_NET_ACT_CSUM=y
CONFIG_NET_CLS_IND=y
CONFIG_NET_SCH_FIFO=y
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=y
# CONFIG_BATMAN_ADV is not set
CONFIG_OPENVSWITCH=y
CONFIG_OPENVSWITCH_GRE=y
# CONFIG_VSOCKETS is not set
CONFIG_NETLINK_MMAP=y
CONFIG_NETLINK_DIAG=y
# CONFIG_NET_MPLS_GSO is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_NETPRIO_CGROUP is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
CONFIG_BPF_JIT=y
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set
CONFIG_FIB_RULES=y
# CONFIG_WIRELESS is not set
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
CONFIG_NET_9P=y
# CONFIG_NET_9P_DEBUG is not set
# CONFIG_CAIF is not set
CONFIG_CEPH_LIB=y
# CONFIG_CEPH_LIB_PRETTYDEBUG is not set
# CONFIG_CEPH_LIB_USE_DNS_RESOLVER is not set
# CONFIG_NFC is not set
CONFIG_HAVE_BPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH="\"\""
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE="bnx2/bnx2-mips-09-6.2.1b.fw"
CONFIG_EXTRA_FIRMWARE_DIR="../linux-firmware"
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
# CONFIG_DMA_SHARED_BUFFER is not set

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
# CONFIG_MTD is not set
# CONFIG_PARPORT is not set
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_FD is not set
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
# CONFIG_BLK_CPQ_DA is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_LOOP_MIN_COUNT=0
# CONFIG_BLK_DEV_CRYPTOLOOP is not set
# CONFIG_BLK_DEV_DRBD is not set
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_NVME is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RBD is not set
# CONFIG_BLK_DEV_RSXX is not set

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
# CONFIG_AD525X_DPOT is not set
# CONFIG_DUMMY_IRQ is not set
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
# CONFIG_ICS932S401 is not set
# CONFIG_ATMEL_SSC is not set
# CONFIG_ENCLOSURE_SERVICES is not set
# CONFIG_HP_ILO is not set
# CONFIG_APDS9802ALS is not set
# CONFIG_ISL29003 is not set
# CONFIG_ISL29020 is not set
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_SENSORS_BH1780 is not set
# CONFIG_SENSORS_BH1770 is not set
# CONFIG_SENSORS_APDS990X is not set
# CONFIG_HMC6352 is not set
# CONFIG_DS1682 is not set
# CONFIG_BMP085_I2C is not set
# CONFIG_PCH_PHUB is not set
# CONFIG_USB_SWITCH_FSA9480 is not set
# CONFIG_SRAM is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
# CONFIG_EEPROM_LEGACY is not set
# CONFIG_EEPROM_MAX6875 is not set
# CONFIG_EEPROM_93CX6 is not set
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
# CONFIG_ALTERA_STAPL is not set
# CONFIG_VMWARE_VMCI is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_TGT=y
CONFIG_SCSI_NETLINK=y
# CONFIG_SCSI_PROC_FS is not set

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
# CONFIG_CHR_DEV_ST is not set
# CONFIG_CHR_DEV_OSST is not set
CONFIG_BLK_DEV_SR=y
# CONFIG_BLK_DEV_SR_VENDOR is not set
CONFIG_CHR_DEV_SG=y
# CONFIG_CHR_DEV_SCH is not set
CONFIG_SCSI_MULTI_LUN=y
# CONFIG_SCSI_CONSTANTS is not set
# CONFIG_SCSI_LOGGING is not set
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=y
# CONFIG_SCSI_FC_TGT_ATTRS is not set
CONFIG_SCSI_ISCSI_ATTRS=y
CONFIG_SCSI_SAS_ATTRS=y
# CONFIG_SCSI_SAS_LIBSAS is not set
CONFIG_SCSI_SRP_ATTRS=y
# CONFIG_SCSI_SRP_TGT_ATTRS is not set
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_TCP=y
# CONFIG_ISCSI_BOOT_SYSFS is not set
# CONFIG_SCSI_CXGB3_ISCSI is not set
# CONFIG_SCSI_CXGB4_ISCSI is not set
# CONFIG_SCSI_BNX2_ISCSI is not set
# CONFIG_SCSI_BNX2X_FCOE is not set
# CONFIG_BE2ISCSI is not set
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_HPSA is not set
CONFIG_SCSI_3W_9XXX=y
# CONFIG_SCSI_3W_SAS is not set
# CONFIG_SCSI_ACARD is not set
# CONFIG_SCSI_AACRAID is not set
# CONFIG_SCSI_AIC7XXX is not set
# CONFIG_SCSI_AIC7XXX_OLD is not set
# CONFIG_SCSI_AIC79XX is not set
# CONFIG_SCSI_AIC94XX is not set
# CONFIG_SCSI_MVSAS is not set
# CONFIG_SCSI_MVUMI is not set
# CONFIG_SCSI_DPT_I2O is not set
# CONFIG_SCSI_ADVANSYS is not set
# CONFIG_SCSI_ARCMSR is not set
CONFIG_MEGARAID_NEWGEN=y
CONFIG_MEGARAID_MM=y
CONFIG_MEGARAID_MAILBOX=y
# CONFIG_MEGARAID_LEGACY is not set
CONFIG_MEGARAID_SAS=y
CONFIG_SCSI_MPT2SAS=y
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
# CONFIG_SCSI_MPT2SAS_LOGGING is not set
# CONFIG_SCSI_MPT3SAS is not set
# CONFIG_SCSI_UFSHCD is not set
# CONFIG_SCSI_HPTIOP is not set
# CONFIG_SCSI_BUSLOGIC is not set
# CONFIG_VMWARE_PVSCSI is not set
# CONFIG_LIBFC is not set
# CONFIG_LIBFCOE is not set
# CONFIG_FCOE is not set
# CONFIG_FCOE_FNIC is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_EATA is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
# CONFIG_SCSI_GDTH is not set
# CONFIG_SCSI_ISCI is not set
# CONFIG_SCSI_IPS is not set
# CONFIG_SCSI_INITIO is not set
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_STEX is not set
# CONFIG_SCSI_SYM53C8XX_2 is not set
# CONFIG_SCSI_IPR is not set
# CONFIG_SCSI_QLOGIC_1280 is not set
# CONFIG_SCSI_QLA_FC is not set
# CONFIG_SCSI_QLA_ISCSI is not set
# CONFIG_SCSI_LPFC is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_DC390T is not set
# CONFIG_SCSI_DEBUG is not set
# CONFIG_SCSI_PMCRAID is not set
# CONFIG_SCSI_PM8001 is not set
# CONFIG_SCSI_SRP is not set
# CONFIG_SCSI_BFA_FC is not set
# CONFIG_SCSI_CHELSIO_FCOE is not set
CONFIG_SCSI_DH=y
CONFIG_SCSI_DH_RDAC=y
# CONFIG_SCSI_DH_HP_SW is not set
# CONFIG_SCSI_DH_EMC is not set
# CONFIG_SCSI_DH_ALUA is not set
# CONFIG_SCSI_OSD_INITIATOR is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_ACPI=y
# CONFIG_SATA_ZPODD is not set
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=y
# CONFIG_SATA_AHCI_PLATFORM is not set
# CONFIG_SATA_INIC162X is not set
# CONFIG_SATA_ACARD_AHCI is not set
# CONFIG_SATA_SIL24 is not set
CONFIG_ATA_SFF=y

#
# SFF controllers with custom DMA interface
#
# CONFIG_PDC_ADMA is not set
# CONFIG_SATA_QSTOR is not set
# CONFIG_SATA_SX4 is not set
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
CONFIG_ATA_PIIX=y
# CONFIG_SATA_HIGHBANK is not set
# CONFIG_SATA_MV is not set
CONFIG_SATA_NV=y
# CONFIG_SATA_PROMISE is not set
# CONFIG_SATA_RCAR is not set
# CONFIG_SATA_SIL is not set
# CONFIG_SATA_SIS is not set
# CONFIG_SATA_SVW is not set
# CONFIG_SATA_ULI is not set
# CONFIG_SATA_VIA is not set
# CONFIG_SATA_VITESSE is not set

#
# PATA SFF controllers with BMDMA
#
# CONFIG_PATA_ALI is not set
# CONFIG_PATA_AMD is not set
# CONFIG_PATA_ARTOP is not set
# CONFIG_PATA_ATIIXP is not set
# CONFIG_PATA_ATP867X is not set
# CONFIG_PATA_CMD64X is not set
# CONFIG_PATA_CS5520 is not set
# CONFIG_PATA_CS5530 is not set
# CONFIG_PATA_CS5536 is not set
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT8213 is not set
# CONFIG_PATA_IT821X is not set
# CONFIG_PATA_JMICRON is not set
# CONFIG_PATA_MARVELL is not set
# CONFIG_PATA_NETCELL is not set
# CONFIG_PATA_NINJA32 is not set
# CONFIG_PATA_NS87415 is not set
CONFIG_PATA_OLDPIIX=y
# CONFIG_PATA_OPTIDMA is not set
# CONFIG_PATA_PDC2027X is not set
# CONFIG_PATA_PDC_OLD is not set
# CONFIG_PATA_RADISYS is not set
# CONFIG_PATA_RDC is not set
# CONFIG_PATA_SC1200 is not set
# CONFIG_PATA_SCH is not set
# CONFIG_PATA_SERVERWORKS is not set
# CONFIG_PATA_SIL680 is not set
# CONFIG_PATA_SIS is not set
# CONFIG_PATA_TOSHIBA is not set
# CONFIG_PATA_TRIFLEX is not set
# CONFIG_PATA_VIA is not set
# CONFIG_PATA_WINBOND is not set

#
# PIO-only SFF controllers
#
# CONFIG_PATA_CMD640_PCI is not set
CONFIG_PATA_MPIIX=y
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_OPTI is not set
# CONFIG_PATA_RZ1000 is not set

#
# Generic fallback / legacy drivers
#
# CONFIG_PATA_ACPI is not set
CONFIG_ATA_GENERIC=y
# CONFIG_PATA_LEGACY is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_AUTODETECT=y
CONFIG_MD_LINEAR=y
CONFIG_MD_RAID0=y
CONFIG_MD_RAID1=y
CONFIG_MD_RAID10=y
CONFIG_MD_RAID456=y
CONFIG_MD_MULTIPATH=y
# CONFIG_MD_FAULTY is not set
CONFIG_BCACHE=y
# CONFIG_BCACHE_DEBUG is not set
# CONFIG_BCACHE_EDEBUG is not set
# CONFIG_BCACHE_CLOSURES_DEBUG is not set
CONFIG_BLK_DEV_DM=y
# CONFIG_DM_DEBUG is not set
CONFIG_DM_BUFIO=y
CONFIG_DM_BIO_PRISON=y
CONFIG_DM_PERSISTENT_DATA=y
CONFIG_DM_CRYPT=y
CONFIG_DM_SNAPSHOT=y
CONFIG_DM_THIN_PROVISIONING=y
# CONFIG_DM_DEBUG_BLOCK_STACK_TRACING is not set
CONFIG_DM_CACHE=y
CONFIG_DM_CACHE_MQ=y
CONFIG_DM_CACHE_CLEANER=y
CONFIG_DM_MIRROR=y
CONFIG_DM_RAID=y
# CONFIG_DM_LOG_USERSPACE is not set
CONFIG_DM_ZERO=y
CONFIG_DM_MULTIPATH=y
CONFIG_DM_MULTIPATH_QL=y
CONFIG_DM_MULTIPATH_ST=y
# CONFIG_DM_DELAY is not set
CONFIG_DM_UEVENT=y
# CONFIG_DM_FLAKEY is not set
CONFIG_DM_VERITY=y
CONFIG_DM_SWITCH=y
# CONFIG_TARGET_CORE is not set
CONFIG_FUSION=y
CONFIG_FUSION_SPI=y
CONFIG_FUSION_FC=y
CONFIG_FUSION_SAS=y
CONFIG_FUSION_MAX_SGE=128
CONFIG_FUSION_CTL=y
CONFIG_FUSION_LOGGING=y

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_I2O is not set
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
CONFIG_MII=y
CONFIG_NET_CORE=y
# CONFIG_BONDING is not set
# CONFIG_DUMMY is not set
# CONFIG_EQUALIZER is not set
# CONFIG_NET_FC is not set
# CONFIG_IFB is not set
CONFIG_NET_TEAM=y
CONFIG_NET_TEAM_MODE_BROADCAST=y
CONFIG_NET_TEAM_MODE_ROUNDROBIN=y
CONFIG_NET_TEAM_MODE_RANDOM=y
CONFIG_NET_TEAM_MODE_ACTIVEBACKUP=y
CONFIG_NET_TEAM_MODE_LOADBALANCE=y
CONFIG_MACVLAN=y
CONFIG_MACVTAP=y
CONFIG_VXLAN=y
# CONFIG_NETCONSOLE is not set
# CONFIG_NETPOLL is not set
# CONFIG_NET_POLL_CONTROLLER is not set
CONFIG_TUN=y
CONFIG_VETH=y
CONFIG_NLMON=y
# CONFIG_ARCNET is not set

#
# CAIF transport drivers
#
CONFIG_VHOST_NET=y
CONFIG_VHOST_RING=y
CONFIG_VHOST=y

#
# Distributed Switch Architecture drivers
#
# CONFIG_NET_DSA_MV88E6XXX is not set
# CONFIG_NET_DSA_MV88E6060 is not set
# CONFIG_NET_DSA_MV88E6XXX_NEED_PPU is not set
# CONFIG_NET_DSA_MV88E6131 is not set
# CONFIG_NET_DSA_MV88E6123_61_65 is not set
CONFIG_ETHERNET=y
CONFIG_MDIO=y
# CONFIG_NET_VENDOR_3COM is not set
# CONFIG_NET_VENDOR_ADAPTEC is not set
# CONFIG_NET_VENDOR_ALTEON is not set
# CONFIG_NET_VENDOR_AMD is not set
CONFIG_NET_VENDOR_ARC=y
# CONFIG_NET_VENDOR_ATHEROS is not set
CONFIG_NET_CADENCE=y
# CONFIG_ARM_AT91_ETHER is not set
# CONFIG_MACB is not set
CONFIG_NET_VENDOR_BROADCOM=y
# CONFIG_B44 is not set
CONFIG_BNX2=y
CONFIG_CNIC=y
CONFIG_TIGON3=y
# CONFIG_BNX2X is not set
# CONFIG_NET_VENDOR_BROCADE is not set
# CONFIG_NET_CALXEDA_XGMAC is not set
# CONFIG_NET_VENDOR_CHELSIO is not set
# CONFIG_NET_VENDOR_CISCO is not set
# CONFIG_DNET is not set
# CONFIG_NET_VENDOR_DEC is not set
# CONFIG_NET_VENDOR_DLINK is not set
# CONFIG_NET_VENDOR_EMULEX is not set
# CONFIG_NET_VENDOR_EXAR is not set
# CONFIG_NET_VENDOR_HP is not set
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
CONFIG_E1000=y
CONFIG_E1000E=y
CONFIG_IGB=y
CONFIG_IGB_HWMON=y
CONFIG_IGBVF=y
CONFIG_IXGB=y
CONFIG_IXGBE=y
CONFIG_IXGBE_HWMON=y
CONFIG_IXGBEVF=y
CONFIG_NET_VENDOR_I825XX=y
# CONFIG_IP1000 is not set
# CONFIG_JME is not set
# CONFIG_NET_VENDOR_MARVELL is not set
# CONFIG_NET_VENDOR_MELLANOX is not set
# CONFIG_NET_VENDOR_MICREL is not set
# CONFIG_NET_VENDOR_MYRI is not set
# CONFIG_FEALNX is not set
CONFIG_NET_VENDOR_NATSEMI=y
# CONFIG_NATSEMI is not set
# CONFIG_NS83820 is not set
CONFIG_NET_VENDOR_8390=y
# CONFIG_NE2K_PCI is not set
CONFIG_NET_VENDOR_NVIDIA=y
CONFIG_FORCEDETH=y
# CONFIG_NET_VENDOR_OKI is not set
# CONFIG_ETHOC is not set
# CONFIG_NET_PACKET_ENGINE is not set
# CONFIG_NET_VENDOR_QLOGIC is not set
CONFIG_NET_VENDOR_REALTEK=y
CONFIG_8139CP=y
CONFIG_8139TOO=y
# CONFIG_8139TOO_PIO is not set
CONFIG_8139TOO_TUNE_TWISTER=y
CONFIG_8139TOO_8129=y
# CONFIG_8139_OLD_RX_RESET is not set
# CONFIG_R8169 is not set
# CONFIG_SH_ETH is not set
# CONFIG_NET_VENDOR_RDC is not set
# CONFIG_NET_VENDOR_SEEQ is not set
# CONFIG_NET_VENDOR_SILAN is not set
# CONFIG_NET_VENDOR_SIS is not set
# CONFIG_SFC is not set
# CONFIG_NET_VENDOR_SMSC is not set
# CONFIG_NET_VENDOR_STMICRO is not set
# CONFIG_NET_VENDOR_SUN is not set
# CONFIG_NET_VENDOR_TEHUTI is not set
# CONFIG_NET_VENDOR_TI is not set
# CONFIG_NET_VENDOR_VIA is not set
# CONFIG_NET_VENDOR_WIZNET is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
CONFIG_PHYLIB=y

#
# MII PHY device drivers
#
# CONFIG_AT803X_PHY is not set
# CONFIG_AMD_PHY is not set
# CONFIG_MARVELL_PHY is not set
# CONFIG_DAVICOM_PHY is not set
# CONFIG_QSEMI_PHY is not set
# CONFIG_LXT_PHY is not set
# CONFIG_CICADA_PHY is not set
# CONFIG_VITESSE_PHY is not set
# CONFIG_SMSC_PHY is not set
# CONFIG_BROADCOM_PHY is not set
# CONFIG_BCM87XX_PHY is not set
# CONFIG_ICPLUS_PHY is not set
# CONFIG_REALTEK_PHY is not set
# CONFIG_NATIONAL_PHY is not set
# CONFIG_STE10XP is not set
# CONFIG_LSI_ET1011C_PHY is not set
# CONFIG_MICREL_PHY is not set
# CONFIG_FIXED_PHY is not set
# CONFIG_MDIO_BITBANG is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set

#
# USB Network Adapters
#
# CONFIG_USB_CATC is not set
# CONFIG_USB_KAWETH is not set
# CONFIG_USB_PEGASUS is not set
# CONFIG_USB_RTL8150 is not set
# CONFIG_USB_RTL8152 is not set
# CONFIG_USB_USBNET is not set
# CONFIG_USB_IPHETH is not set
# CONFIG_WLAN is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
# CONFIG_WAN is not set
# CONFIG_VMXNET3 is not set
# CONFIG_ISDN is not set

#
# Input device support
#
CONFIG_INPUT=y
# CONFIG_INPUT_FF_MEMLESS is not set
# CONFIG_INPUT_POLLDEV is not set
# CONFIG_INPUT_SPARSEKMAP is not set
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1280
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=1024
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_XTKBD is not set
CONFIG_INPUT_MOUSE=y
# CONFIG_MOUSE_PS2 is not set
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_CYAPA is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_MOUSE_SYNAPTICS_I2C is not set
# CONFIG_MOUSE_SYNAPTICS_USB is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_AD714X is not set
# CONFIG_INPUT_BMA150 is not set
CONFIG_INPUT_PCSPKR=y
# CONFIG_INPUT_MMA8450 is not set
# CONFIG_INPUT_MPU3050 is not set
# CONFIG_INPUT_ATLAS_BTNS is not set
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
# CONFIG_INPUT_KXTJ9 is not set
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
# CONFIG_INPUT_UINPUT is not set
# CONFIG_INPUT_PCF8574 is not set
# CONFIG_INPUT_ADXL34X is not set
# CONFIG_INPUT_CMA3000 is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
# CONFIG_SERIO_SERPORT is not set
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
# CONFIG_SERIO_ALTERA_PS2 is not set
# CONFIG_SERIO_PS2MULT is not set
# CONFIG_SERIO_ARC_PS2 is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_TTY=y
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
# CONFIG_VT_HW_CONSOLE_BINDING is not set
CONFIG_UNIX98_PTYS=y
CONFIG_DEVPTS_MULTIPLE_INSTANCES=y
# CONFIG_LEGACY_PTYS is not set
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set
# CONFIG_N_GSM is not set
# CONFIG_TRACE_SINK is not set
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
# CONFIG_SERIAL_8250_DEPRECATED_OPTIONS is not set
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_DW is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
CONFIG_IPMI_HANDLER=y
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=y
CONFIG_IPMI_SI=y
CONFIG_IPMI_WATCHDOG=y
CONFIG_IPMI_POWEROFF=y
# CONFIG_HW_RANDOM is not set
# CONFIG_NVRAM is not set
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_MWAVE is not set
# CONFIG_RAW_DRIVER is not set
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
# CONFIG_TCG_TPM is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
# CONFIG_I2C_CHARDEV is not set
# CONFIG_I2C_MUX is not set
# CONFIG_I2C_HELPER_AUTO is not set
# CONFIG_I2C_SMBUS is not set

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=y
# CONFIG_I2C_ALGOPCF is not set
# CONFIG_I2C_ALGOPCA is not set

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_ISMT is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EG20T is not set
# CONFIG_I2C_OCORES is not set
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_PXA_PCI is not set
# CONFIG_I2C_SIMTEC is not set
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_DIOLAN_U2C is not set
# CONFIG_I2C_PARPORT_LIGHT is not set
# CONFIG_I2C_TAOS_EVM is not set
# CONFIG_I2C_TINY_USB is not set

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_STUB is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
# CONFIG_HSI is not set

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
# CONFIG_PPS_CLIENT_LDISC is not set
# CONFIG_PPS_CLIENT_GPIO is not set

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
# CONFIG_PTP_1588_CLOCK_PCH is not set
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
# CONFIG_GPIOLIB is not set
# CONFIG_W1 is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_SBS is not set
# CONFIG_BATTERY_BQ27x00 is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_SMB347 is not set
# CONFIG_BATTERY_GOLDFISH is not set
# CONFIG_POWER_RESET is not set
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=y
# CONFIG_HWMON_VID is not set
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
# CONFIG_SENSORS_ABITUGURU is not set
# CONFIG_SENSORS_ABITUGURU3 is not set
# CONFIG_SENSORS_AD7414 is not set
# CONFIG_SENSORS_AD7418 is not set
# CONFIG_SENSORS_ADM1021 is not set
# CONFIG_SENSORS_ADM1025 is not set
# CONFIG_SENSORS_ADM1026 is not set
# CONFIG_SENSORS_ADM1029 is not set
# CONFIG_SENSORS_ADM1031 is not set
# CONFIG_SENSORS_ADM9240 is not set
# CONFIG_SENSORS_ADT7410 is not set
# CONFIG_SENSORS_ADT7411 is not set
# CONFIG_SENSORS_ADT7462 is not set
# CONFIG_SENSORS_ADT7470 is not set
# CONFIG_SENSORS_ADT7475 is not set
# CONFIG_SENSORS_ASC7621 is not set
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
# CONFIG_SENSORS_ASB100 is not set
# CONFIG_SENSORS_ATXP1 is not set
# CONFIG_SENSORS_DS620 is not set
# CONFIG_SENSORS_DS1621 is not set
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
# CONFIG_SENSORS_F71882FG is not set
# CONFIG_SENSORS_F75375S is not set
# CONFIG_SENSORS_FSCHMD is not set
# CONFIG_SENSORS_G760A is not set
# CONFIG_SENSORS_G762 is not set
# CONFIG_SENSORS_GL518SM is not set
# CONFIG_SENSORS_GL520SM is not set
# CONFIG_SENSORS_HIH6130 is not set
# CONFIG_SENSORS_CORETEMP is not set
# CONFIG_SENSORS_IBMAEM is not set
# CONFIG_SENSORS_IBMPEX is not set
# CONFIG_SENSORS_IT87 is not set
# CONFIG_SENSORS_JC42 is not set
# CONFIG_SENSORS_LINEAGE is not set
# CONFIG_SENSORS_LM63 is not set
# CONFIG_SENSORS_LM73 is not set
# CONFIG_SENSORS_LM75 is not set
# CONFIG_SENSORS_LM77 is not set
# CONFIG_SENSORS_LM78 is not set
# CONFIG_SENSORS_LM80 is not set
# CONFIG_SENSORS_LM83 is not set
# CONFIG_SENSORS_LM85 is not set
# CONFIG_SENSORS_LM87 is not set
# CONFIG_SENSORS_LM90 is not set
# CONFIG_SENSORS_LM92 is not set
# CONFIG_SENSORS_LM93 is not set
# CONFIG_SENSORS_LTC4151 is not set
# CONFIG_SENSORS_LTC4215 is not set
# CONFIG_SENSORS_LTC4245 is not set
# CONFIG_SENSORS_LTC4261 is not set
# CONFIG_SENSORS_LM95234 is not set
# CONFIG_SENSORS_LM95241 is not set
# CONFIG_SENSORS_LM95245 is not set
# CONFIG_SENSORS_MAX16065 is not set
# CONFIG_SENSORS_MAX1619 is not set
# CONFIG_SENSORS_MAX1668 is not set
# CONFIG_SENSORS_MAX197 is not set
# CONFIG_SENSORS_MAX6639 is not set
# CONFIG_SENSORS_MAX6642 is not set
# CONFIG_SENSORS_MAX6650 is not set
# CONFIG_SENSORS_MAX6697 is not set
# CONFIG_SENSORS_MCP3021 is not set
# CONFIG_SENSORS_NCT6775 is not set
# CONFIG_SENSORS_NTC_THERMISTOR is not set
# CONFIG_SENSORS_PC87360 is not set
# CONFIG_SENSORS_PC87427 is not set
# CONFIG_SENSORS_PCF8591 is not set
# CONFIG_PMBUS is not set
# CONFIG_SENSORS_SHT21 is not set
# CONFIG_SENSORS_SIS5595 is not set
# CONFIG_SENSORS_SMM665 is not set
# CONFIG_SENSORS_DME1737 is not set
# CONFIG_SENSORS_EMC1403 is not set
# CONFIG_SENSORS_EMC2103 is not set
# CONFIG_SENSORS_EMC6W201 is not set
# CONFIG_SENSORS_SMSC47M1 is not set
# CONFIG_SENSORS_SMSC47M192 is not set
# CONFIG_SENSORS_SMSC47B397 is not set
# CONFIG_SENSORS_SCH56XX_COMMON is not set
# CONFIG_SENSORS_ADS1015 is not set
# CONFIG_SENSORS_ADS7828 is not set
# CONFIG_SENSORS_AMC6821 is not set
# CONFIG_SENSORS_INA209 is not set
# CONFIG_SENSORS_INA2XX is not set
# CONFIG_SENSORS_THMC50 is not set
# CONFIG_SENSORS_TMP102 is not set
# CONFIG_SENSORS_TMP401 is not set
# CONFIG_SENSORS_TMP421 is not set
# CONFIG_SENSORS_VIA_CPUTEMP is not set
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83781D is not set
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
# CONFIG_SENSORS_W83793 is not set
# CONFIG_SENSORS_W83795 is not set
# CONFIG_SENSORS_W83L785TS is not set
# CONFIG_SENSORS_W83L786NG is not set
# CONFIG_SENSORS_W83627HF is not set
# CONFIG_SENSORS_W83627EHF is not set
# CONFIG_SENSORS_APPLESMC is not set

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
CONFIG_THERMAL_GOV_USER_SPACE=y
# CONFIG_THERMAL_EMULATION is not set
# CONFIG_INTEL_POWERCLAMP is not set
CONFIG_X86_PKG_TEMP_THERMAL=m

#
# Texas Instruments thermal drivers
#
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
# CONFIG_SSB is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
# CONFIG_MFD_CORE is not set
# CONFIG_MFD_CS5535 is not set
# CONFIG_MFD_AS3711 is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_CROS_EC is not set
# CONFIG_PMIC_DA903X is not set
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
# CONFIG_MFD_MC13XXX_I2C is not set
# CONFIG_HTC_PASIC3 is not set
# CONFIG_LPC_ICH is not set
# CONFIG_LPC_SCH is not set
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_KEMPLD is not set
# CONFIG_MFD_88PM800 is not set
# CONFIG_MFD_88PM805 is not set
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_MAX77686 is not set
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX8907 is not set
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_VIPERBOARD is not set
# CONFIG_MFD_RETU is not set
# CONFIG_MFD_PCF50633 is not set
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_SI476X_CORE is not set
# CONFIG_MFD_SM501 is not set
# CONFIG_MFD_SMSC is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_STMPE is not set
# CONFIG_MFD_SYSCON is not set
# CONFIG_MFD_TI_AM335X_TSCADC is not set
# CONFIG_MFD_LP8788 is not set
# CONFIG_MFD_PALMAS is not set
# CONFIG_TPS6105X is not set
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_TPS65217 is not set
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
# CONFIG_MFD_WL1273_CORE is not set
# CONFIG_MFD_LM3533 is not set
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
# CONFIG_MFD_ARIZONA_I2C is not set
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_WM8994 is not set
# CONFIG_REGULATOR is not set
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
# CONFIG_DRM is not set
# CONFIG_VGASTATE is not set
# CONFIG_VIDEO_OUTPUT_CONTROL is not set
# CONFIG_FB is not set
# CONFIG_EXYNOS_VIDEO is not set
# CONFIG_BACKLIGHT_LCD_SUPPORT is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
# CONFIG_VGACON_SOFT_SCROLLBACK is not set
CONFIG_DUMMY_CONSOLE=y
# CONFIG_SOUND is not set

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
# CONFIG_HID_ACRUX is not set
CONFIG_HID_APPLE=y
# CONFIG_HID_APPLEIR is not set
# CONFIG_HID_AUREAL is not set
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
# CONFIG_DRAGONRISE_FF is not set
# CONFIG_HID_EMS_FF is not set
# CONFIG_HID_ELECOM is not set
# CONFIG_HID_ELO is not set
CONFIG_HID_EZKEY=y
# CONFIG_HID_HOLTEK is not set
# CONFIG_HID_HUION is not set
# CONFIG_HID_KEYTOUCH is not set
CONFIG_HID_KYE=y
# CONFIG_HID_UCLOGIC is not set
# CONFIG_HID_WALTOP is not set
CONFIG_HID_GYRATION=y
# CONFIG_HID_ICADE is not set
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
# CONFIG_HID_LCPOWER is not set
# CONFIG_HID_LENOVO_TPKBD is not set
CONFIG_HID_LOGITECH=y
# CONFIG_HID_LOGITECH_DJ is not set
# CONFIG_LOGITECH_FF is not set
# CONFIG_LOGIRUMBLEPAD2_FF is not set
# CONFIG_LOGIG940_FF is not set
# CONFIG_LOGIWHEELS_FF is not set
# CONFIG_HID_MAGICMOUSE is not set
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
# CONFIG_HID_MULTITOUCH is not set
CONFIG_HID_NTRIG=y
# CONFIG_HID_ORTEK is not set
CONFIG_HID_PANTHERLORD=y
# CONFIG_PANTHERLORD_FF is not set
CONFIG_HID_PETALYNX=y
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_PRIMAX is not set
# CONFIG_HID_ROCCAT is not set
# CONFIG_HID_SAITEK is not set
CONFIG_HID_SAMSUNG=y
# CONFIG_HID_SPEEDLINK is not set
# CONFIG_HID_STEELSERIES is not set
CONFIG_HID_SUNPLUS=y
CONFIG_HID_GREENASIA=y
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_SMARTJOYPLUS=y
# CONFIG_SMARTJOYPLUS_FF is not set
# CONFIG_HID_TIVO is not set
CONFIG_HID_TOPSEED=y
CONFIG_HID_THRUSTMASTER=y
# CONFIG_THRUSTMASTER_FF is not set
CONFIG_HID_ZEROPLUS=y
# CONFIG_ZEROPLUS_FF is not set
# CONFIG_HID_ZYDACRON is not set
# CONFIG_HID_SENSOR_HUB is not set

#
# USB HID support
#
CONFIG_USB_HID=y
# CONFIG_HID_PID is not set
# CONFIG_USB_HIDDEV is not set

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
CONFIG_USB_DEFAULT_PERSIST=y
CONFIG_USB_DYNAMIC_MINORS=y
# CONFIG_USB_OTG is not set
# CONFIG_USB_MON is not set
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
# CONFIG_USB_XHCI_HCD is not set
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
CONFIG_USB_EHCI_PCI=y
# CONFIG_USB_EHCI_HCD_PLATFORM is not set
# CONFIG_USB_OXU210HP_HCD is not set
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_ISP1760_HCD is not set
# CONFIG_USB_ISP1362_HCD is not set
# CONFIG_USB_FUSBH200_HCD is not set
# CONFIG_USB_OHCI_HCD is not set
CONFIG_USB_UHCI_HCD=y
# CONFIG_USB_SL811_HCD is not set
# CONFIG_USB_R8A66597_HCD is not set

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
# CONFIG_USB_PRINTER is not set
# CONFIG_USB_WDM is not set
# CONFIG_USB_TMC is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=y
# CONFIG_USB_STORAGE_DEBUG is not set
# CONFIG_USB_STORAGE_REALTEK is not set
# CONFIG_USB_STORAGE_DATAFAB is not set
# CONFIG_USB_STORAGE_FREECOM is not set
# CONFIG_USB_STORAGE_ISD200 is not set
CONFIG_USB_STORAGE_USBAT=y
# CONFIG_USB_STORAGE_SDDR09 is not set
# CONFIG_USB_STORAGE_SDDR55 is not set
# CONFIG_USB_STORAGE_JUMPSHOT is not set
# CONFIG_USB_STORAGE_ALAUDA is not set
# CONFIG_USB_STORAGE_ONETOUCH is not set
# CONFIG_USB_STORAGE_KARMA is not set
# CONFIG_USB_STORAGE_CYPRESS_ATACB is not set
# CONFIG_USB_STORAGE_ENE_UB6250 is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_MICROTEK is not set
# CONFIG_USB_DWC3 is not set
# CONFIG_USB_CHIPIDEA is not set

#
# USB port drivers
#
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
# CONFIG_USB_SEVSEG is not set
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_LEGOTOWER is not set
# CONFIG_USB_LCD is not set
# CONFIG_USB_LED is not set
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
# CONFIG_USB_IDMOUSE is not set
# CONFIG_USB_FTDI_ELAN is not set
# CONFIG_USB_APPLEDISPLAY is not set
# CONFIG_USB_SISUSBVGA is not set
# CONFIG_USB_LD is not set
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
# CONFIG_USB_TEST is not set
# CONFIG_USB_ISIGHTFW is not set
# CONFIG_USB_YUREX is not set
# CONFIG_USB_EZUSB_FX2 is not set
# CONFIG_USB_HSIC_USB3503 is not set
# CONFIG_USB_PHY is not set
# CONFIG_USB_GADGET is not set
# CONFIG_UWB is not set
# CONFIG_MMC is not set
# CONFIG_MEMSTICK is not set
# CONFIG_NEW_LEDS is not set
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
# CONFIG_RTC_CLASS is not set
# CONFIG_DMADEVICES is not set
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=y
# CONFIG_UIO_CIF is not set
# CONFIG_UIO_PDRV is not set
# CONFIG_UIO_PDRV_GENIRQ is not set
# CONFIG_UIO_DMEM_GENIRQ is not set
# CONFIG_UIO_AEC is not set
# CONFIG_UIO_SERCOS3 is not set
# CONFIG_UIO_PCI_GENERIC is not set
# CONFIG_UIO_NETX is not set
# CONFIG_VFIO is not set
CONFIG_VIRT_DRIVERS=y

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
# CONFIG_VIRTIO_MMIO is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACERHDF is not set
# CONFIG_ASUS_LAPTOP is not set
# CONFIG_CHROMEOS_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_THINKPAD_ACPI is not set
# CONFIG_SENSORS_HDAPS is not set
# CONFIG_INTEL_MENLOW is not set
# CONFIG_ACPI_WMI is not set
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_IPS is not set
# CONFIG_IBM_RTL is not set
# CONFIG_XO15_EBOOK is not set
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
# CONFIG_PVPANIC is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_MAILBOX is not set
CONFIG_IOMMU_API=y
CONFIG_IOMMU_SUPPORT=y
CONFIG_AMD_IOMMU=y
# CONFIG_AMD_IOMMU_STATS is not set
CONFIG_DMAR_TABLE=y
CONFIG_INTEL_IOMMU=y
CONFIG_INTEL_IOMMU_DEFAULT_ON=y
CONFIG_INTEL_IOMMU_FLOPPY_WA=y
CONFIG_IRQ_REMAP=y

#
# Remoteproc drivers
#
# CONFIG_STE_MODEM_RPROC is not set

#
# Rpmsg drivers
#
# CONFIG_PM_DEVFREQ is not set
# CONFIG_EXTCON is not set
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set
# CONFIG_IPACK_BUS is not set
# CONFIG_RESET_CONTROLLER is not set
# CONFIG_FMC is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
# CONFIG_DELL_RBU is not set
# CONFIG_DCDBAS is not set
CONFIG_DMIID=y
CONFIG_DMI_SYSFS=y
# CONFIG_ISCSI_IBFT_FIND is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
# CONFIG_EXT2_FS is not set
# CONFIG_EXT3_FS is not set
CONFIG_EXT4_FS=y
CONFIG_EXT4_USE_FOR_EXT23=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
# CONFIG_XFS_FS is not set
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
CONFIG_BTRFS_FS=y
CONFIG_BTRFS_FS_POSIX_ACL=y
# CONFIG_BTRFS_FS_CHECK_INTEGRITY is not set
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
# CONFIG_BTRFS_DEBUG is not set
# CONFIG_NILFS2_FS is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
# CONFIG_QUOTA is not set
# CONFIG_QUOTACTL is not set
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=y
CONFIG_CUSE=y
CONFIG_GENERIC_ACL=y

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
CONFIG_UDF_FS=y
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
CONFIG_NTFS_FS=y
# CONFIG_NTFS_DEBUG is not set
CONFIG_NTFS_RW=y

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_ECRYPT_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
# CONFIG_LOGFS is not set
# CONFIG_CRAMFS is not set
CONFIG_SQUASHFS=y
CONFIG_SQUASHFS_XATTR=y
CONFIG_SQUASHFS_ZLIB=y
CONFIG_SQUASHFS_LZO=y
CONFIG_SQUASHFS_XZ=y
# CONFIG_SQUASHFS_4K_DEVBLK_SIZE is not set
# CONFIG_SQUASHFS_EMBEDDED is not set
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
# CONFIG_VXFS_FS is not set
# CONFIG_MINIX_FS is not set
# CONFIG_OMFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_QNX6FS_FS is not set
# CONFIG_ROMFS_FS is not set
CONFIG_PSTORE=y
# CONFIG_PSTORE_CONSOLE is not set
# CONFIG_PSTORE_RAM is not set
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set
# CONFIG_F2FS_FS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
CONFIG_NFS_V2=y
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=y
# CONFIG_NFS_SWAP is not set
CONFIG_NFS_V4_1=y
CONFIG_NFS_V4_2=y
CONFIG_PNFS_FILE_LAYOUT=m
CONFIG_PNFS_BLOCK=m
CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN="kernel.org"
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
CONFIG_NFSD=y
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V4=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_ACL_SUPPORT=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=y
CONFIG_SUNRPC_BACKCHANNEL=y
CONFIG_RPCSEC_GSS_KRB5=y
# CONFIG_SUNRPC_DEBUG is not set
CONFIG_CEPH_FS=y
# CONFIG_CIFS is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set
CONFIG_9P_FS=y
CONFIG_9P_FS_POSIX_ACL=y
# CONFIG_9P_FS_SECURITY is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="utf-8"
CONFIG_NLS_CODEPAGE_437=y
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
CONFIG_NLS_CODEPAGE_850=y
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
# CONFIG_NLS_CODEPAGE_866 is not set
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
# CONFIG_NLS_MAC_ROMAN is not set
# CONFIG_NLS_MAC_CELTIC is not set
# CONFIG_NLS_MAC_CENTEURO is not set
# CONFIG_NLS_MAC_CROATIAN is not set
# CONFIG_NLS_MAC_CYRILLIC is not set
# CONFIG_NLS_MAC_GAELIC is not set
# CONFIG_NLS_MAC_GREEK is not set
# CONFIG_NLS_MAC_ICELAND is not set
# CONFIG_NLS_MAC_INUIT is not set
# CONFIG_NLS_MAC_ROMANIAN is not set
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=y
# CONFIG_DLM is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
# CONFIG_PRINTK_TIME is not set
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=1024
CONFIG_STRIP_ASM_SYMS=y
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_MAGIC_SYSRQ is not set
# CONFIG_DEBUG_KERNEL is not set

#
# Memory Debugging
#
# CONFIG_SLUB_DEBUG_ON is not set
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KMEMCHECK=y

#
# Debug Lockups and Hangs
#
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_DEBUG_BUGVERBOSE=y

#
# RCU Debugging
#
# CONFIG_SPARSE_RCU_POINTER is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=60
CONFIG_RCU_CPU_STALL_VERBOSE=y
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set

#
# Runtime Testing
#
# CONFIG_LKDTM is not set
# CONFIG_ATOMIC64_SELFTEST is not set
# CONFIG_ASYNC_RAID6_TEST is not set
# CONFIG_TEST_STRING_HELPERS is not set
# CONFIG_TEST_KSTRTOX is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
CONFIG_STRICT_DEVMEM=y
# CONFIG_X86_VERBOSE_BOOTUP is not set
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_DEBUG_SET_MODULE_RONX is not set
CONFIG_DOUBLEFAULT=y
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
# CONFIG_OPTIMIZE_INLINING is not set

#
# Security options
#
CONFIG_KEYS=y
CONFIG_ENCRYPTED_KEYS=y
CONFIG_KEYS_DEBUG_PROC_KEYS=y
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
# CONFIG_SECURITYFS is not set
# CONFIG_INTEL_TXT is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=y
CONFIG_ASYNC_CORE=y
CONFIG_ASYNC_MEMCPY=y
CONFIG_ASYNC_XOR=y
CONFIG_ASYNC_PQ=y
CONFIG_ASYNC_RAID6_RECOV=y
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_PCOMP=y
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_PCRYPT=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
# CONFIG_CRYPTO_TEST is not set
CONFIG_CRYPTO_ABLK_HELPER_X86=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_SEQIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_CRC32=y
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
CONFIG_CRYPTO_SHA256_SSSE3=y
CONFIG_CRYPTO_SHA512_SSSE3=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=y
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=y
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=y
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST5_AVX_X86_64=y
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_CAST6_AVX_X86_64=y
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_SALSA20_X86_64=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=y
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_ZLIB=y
CONFIG_CRYPTO_LZO=y
CONFIG_CRYPTO_LZ4=y
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
# CONFIG_CRYPTO_HW is not set
# CONFIG_ASYMMETRIC_KEY_TYPE is not set
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_IRQ_ROUTING=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_APIC_ARCHITECTURE=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_HAVE_KVM_MSI=y
CONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=y
CONFIG_KVM_INTEL=y
CONFIG_KVM_AMD=y
CONFIG_KVM_DEVICE_ASSIGNMENT=y
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
CONFIG_RAID6_PQ=y
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=y
CONFIG_TEXTSEARCH_BM=y
CONFIG_TEXTSEARCH_FSM=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
# CONFIG_AVERAGE is not set
CONFIG_CORDIC=y
# CONFIG_DDR is not set
CONFIG_OID_REGISTRY=y

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
