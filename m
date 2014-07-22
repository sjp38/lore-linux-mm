Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 9E80F6B008A
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 16:07:44 -0400 (EDT)
Received: by mail-ig0-f176.google.com with SMTP id hn18so4436479igb.3
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 13:07:44 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g8si197675ica.90.2014.07.22.13.07.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jul 2014 13:07:43 -0700 (PDT)
Date: Tue, 22 Jul 2014 13:07:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 80881] New: Memory cgroup OOM leads to BUG: unable to
 handle kernel paging request at ffffffffffffffd8
Message-Id: <20140722130741.ca2f6c24d06fffc7d7549e95@linux-foundation.org>
In-Reply-To: <bug-80881-27@https.bugzilla.kernel.org/>
References: <bug-80881-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Paul Furtado <paulfurtado91@gmail.com>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

oops in mem_cgroup_oom_synchronize() after an oom.


On Tue, 22 Jul 2014 06:45:25 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=80881
> 
>             Bug ID: 80881
>            Summary: Memory cgroup OOM leads to BUG: unable to handle
>                     kernel paging request at ffffffffffffffd8
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 3.16.0-rc5
>           Hardware: x86-64
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: akpm@linux-foundation.org
>           Reporter: paulfurtado91@gmail.com
>         Regression: No
> 
> Created attachment 143841
>   --> https://bugzilla.kernel.org/attachment.cgi?id=143841&action=edit
> 3.16.0-rc5_console_output
> 
> I was testing the stability of the memory cgroup OOM handler on kernel
> 3.16.0-rc5 by running hundreds of tasks in Apache Mesos which were using memory
> cgroups to limit their memory usage and were guaranteed to run out of memory
> (running a process which intentionally attempted to allocate more than the
> limit). After testing for a few days on several servers, I hit:
> 
> [162006.001086] kernel tried to execute NX-protected page - exploit attempt?
> (uid: 0)
> [162006.001100] BUG: unable to handle kernel paging request at ffff8801d2ec7e90
> 
> Note that this was running on a paravirtualized xen instance in EC2 running
> CentOS 6.5 and the kernel was version 3.16.0-rc5 compiled directly from the
> source archive on kernel.org. We're testing on many kernel versions and this is
> one of many failures, but the only one I've reproduced on 3.16.0-rc5 thus far.
> I also have at least on reproduction of this exact same error on kernel
> 3.12.24.
> 
> 
> The full log is attached, but here is the part I believe is relevant from the
> 3.16.0-rc5 error:
> [162005.262545] memory: usage 131072kB, limit 131072kB, failcnt 1314
> [162005.262550] memory+swap: usage 0kB, limit 18014398509481983kB, failcnt 0
> [162005.262554] kmem: usage 0kB, limit 18014398509481983kB, failcnt 0
> [162005.262558] Memory cgroup stats for
> /mesos/c206ce2a-9f11-4340-a3c9-c59b405690a7: cache:8KB rss:131064KB
> rss_huge:0KB mapped_file:0KB writeback:0KB inactive_anon:0KB
> active_anon:131064KB inactive_file:0KB active_file:0KB unevictable:0KB
> [162005.262581] [ pid ]   uid  tgid total_vm      rss nr_ptes swapents
> oom_score_adj name
> [162005.262602] [ 3002]     0  3002   544153    22244     151        0         
>    0 java7
> [162005.262609] [ 3061]     0  3061   424397    20423      88        0         
>    0 java
> [162005.262615] Memory cgroup out of memory: Kill process 3002 (java7) score
> 662 or sacrifice child
> [162005.262623] Killed process 3002 (java7) total-vm:2176612kB,
> anon-rss:60400kB, file-rss:28576kB
> [162005.263453] general protection fault: 0000 [#1] SMP
> [162005.263463] Modules linked in: ipv6 dm_mod xen_netfront coretemp hwmon
> x86_pkg_temp_thermal crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel
> ablk_helper cryptd lrw gf128mul glue_helper aes_x86_64 microcode pcspkr ext4
> jbd2 mbcache raid0 xen_blkfront
> [162005.264060] CPU: 3 PID: 3062 Comm: java Not tainted 3.16.0-rc5 #1
> [162005.264060] task: ffff8801cfe8f170 ti: ffff8801d2ec4000 task.ti:
> ffff8801d2ec4000
> [162005.264060] RIP: e030:[<ffffffff811c0b80>]  [<ffffffff811c0b80>]
> mem_cgroup_oom_synchronize+0x140/0x240
> [162005.264060] RSP: e02b:ffff8801d2ec7d48  EFLAGS: 00010283
> [162005.264060] RAX: 0000000000000001 RBX: ffff88009d633800 RCX:
> 000000000000000e
> [162005.264060] RDX: fffffffffffffffe RSI: ffff88009d630200 RDI:
> ffff88009d630200
> [162005.264060] RBP: ffff8801d2ec7da8 R08: 0000000000000012 R09:
> 00000000fffffffe
> [162005.264060] R10: 0000000000000000 R11: 0000000000000000 R12:
> ffff88009d633800
> [162005.264060] R13: ffff8801d2ec7d48 R14: dead000000100100 R15:
> ffff88009d633a30
> [162005.264060] FS:  00007f1748bb4700(0000) GS:ffff8801def80000(0000)
> knlGS:0000000000000000
> [162005.264060] CS:  e033 DS: 0000 ES: 0000 CR0: 000000008005003b
> [162005.264060] CR2: 00007f4110300308 CR3: 00000000c05f7000 CR4:
> 0000000000002660
> [162005.264060] Stack:
> [162005.264060]  ffff88009d633800 0000000000000000 ffff8801cfe8f170
> ffffffff811bae10
> [162005.264060]  ffffffff81ca73f8 ffffffff81ca73f8 ffff8801d2ec7dc8
> 0000000000000006
> [162005.264060]  00000000e3b30000 00000000e3b30000 ffff8801d2ec7f58
> 0000000000000001
> [162005.264060] Call Trace:
> [162005.264060]  [<ffffffff811bae10>] ? mem_cgroup_wait_acct_move+0x110/0x110
> [162005.264060]  [<ffffffff81159628>] pagefault_out_of_memory+0x18/0x90
> [162005.264060]  [<ffffffff8105cee9>] mm_fault_error+0xa9/0x1a0
> [162005.264060]  [<ffffffff8105d488>] __do_page_fault+0x478/0x4c0
> [162005.264060]  [<ffffffff81004f00>] ? xen_mc_flush+0xb0/0x1b0
> [162005.264060]  [<ffffffff81003ab3>] ? xen_write_msr_safe+0xa3/0xd0
> [162005.264060]  [<ffffffff81012a40>] ? __switch_to+0x2d0/0x600
> [162005.264060]  [<ffffffff8109e273>] ? finish_task_switch+0x53/0xf0
> [162005.264060]  [<ffffffff81643b0a>] ? __schedule+0x37a/0x6d0
> [162005.264060]  [<ffffffff8105d5dc>] do_page_fault+0x2c/0x40
> [162005.264060]  [<ffffffff81649858>] page_fault+0x28/0x30
> [162005.264060] Code: 44 00 00 48 89 df e8 40 ca ff ff 48 85 c0 49 89 c4 74 35
> 4c 8b b0 30 02 00 00 4c 8d b8 30 02 00 00 4d 39 fe 74 1b 0f 1f 44 00 00 <49> 8b
> 7e 10 be 01 00 00 00 e8 42 d2 04 00 4d 8b 36 4d 39 fe 75
> [162005.264060] RIP  [<ffffffff811c0b80>]
> mem_cgroup_oom_synchronize+0x140/0x240
> [162005.264060]  RSP <ffff8801d2ec7d48>
> [162005.458051] ---[ end trace 050b00c5503ce96a ]---
> [162006.001086] kernel tried to execute NX-protected page - exploit attempt?
> (uid: 0)
> [162006.001100] BUG: unable to handle kernel paging request at ffff8801d2ec7e90
> [162006.001108] IP: [<ffff8801d2ec7e90>] 0xffff8801d2ec7e90
> [162006.001115] PGD 1c12067 PUD 2133067 PMD 1dfd4c067 PTE 80100001d2ec7067
> [162006.001123] Oops: 0011 [#2] SMP
> [162006.001128] Modules linked in: ipv6 dm_mod xen_netfront coretemp hwmon
> x86_pkg_temp_thermal crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel
> ablk_helper cryptd lrw gf128mul glue_helper aes_x86_64 microcode pcspkr ext4
> jbd2 mbcache raid0 xen_blkfront
> [162006.001161] CPU: 3 PID: 30835 Comm: kworker/3:2 Tainted: G      D      
> 3.16.0-rc5 #1
> [162006.001172] Workqueue: cgroup_destroy css_killed_work_fn
> [162006.001178] task: ffff8800797fc090 ti: ffff8801d17b4000 task.ti:
> ffff8801d17b4000
> [162006.001184] RIP: e030:[<ffff8801d2ec7e90>]  [<ffff8801d2ec7e90>]
> 0xffff8801d2ec7e90
> [162006.001192] RSP: e02b:ffff8801d17b7c90  EFLAGS: 00010082
> [162006.001197] RAX: ffff8801d2ec7d50 RBX: ffff8801d2ec7eb0 RCX:
> ffff88009d633800
> [162006.001203] RDX: 0000000000000000 RSI: 0000000000000003 RDI:
> ffff8801d2ec7d50
> [162006.001209] RBP: ffff8801d17b7cd8 R08: ffff88009d633800 R09:
> 0000000000000400
> [162006.001214] R10: dead000000200200 R11: dead000000100100 R12:
> 000000007e10d030
> [162006.001220] R13: ffffffff81ca73f8 R14: ffff88009d633800 R15:
> 0000000000000000
> [162006.001230] FS:  00007f9cf413b700(0000) GS:ffff8801def80000(0000)
> knlGS:0000000000000000
> [162006.001236] CS:  e033 DS: 0000 ES: 0000 CR0: 000000008005003b
> [162006.001241] CR2: ffff8801d2ec7e90 CR3: 000000005ab6b000 CR4:
> 0000000000002660
> [162006.001247] Stack:
> [162006.001251]  ffffffff810b51e9 dead000000200200 0000000300000000
> ffff8801d1667b40
> [162006.001259]  ffffffff81ca73f0 0000000000000201 0000000000000003
> 0000000000000000
> [162006.001266]  ffff88009d633800 ffff8801d17b7d18 ffffffff810b56a8
> ffff88009d633800
> [162006.001274] Call Trace:
> [162006.001281]  [<ffffffff810b51e9>] ? __wake_up_common+0x59/0x90
> [162006.001288]  [<ffffffff810b56a8>] __wake_up+0x48/0x70
> [162006.001297]  [<ffffffff811b92dd>] memcg_oom_recover+0x3d/0x40
> [162006.001303]  [<ffffffff811bea90>] mem_cgroup_reparent_charges+0x110/0x150
> [162006.001310]  [<ffffffff811bec38>] mem_cgroup_css_offline+0x138/0x250
> [162006.001316]  [<ffffffff810f79f9>] css_killed_work_fn+0x49/0xd0
> [162006.001324]  [<ffffffff8108c91c>] process_one_work+0x17c/0x420
> [162006.001331]  [<ffffffff8108dab3>] worker_thread+0x123/0x420
> [162006.001337]  [<ffffffff8108d990>] ? maybe_create_worker+0x180/0x180
> [162006.001344]  [<ffffffff8109369e>] kthread+0xce/0xf0
> [162006.001352]  [<ffffffff810039fe>] ? xen_end_context_switch+0x1e/0x30
> [162006.001358]  [<ffffffff810935d0>] ? kthread_freezable_should_stop+0x70/0x70
> [162006.001368]  [<ffffffff816477fc>] ret_from_fork+0x7c/0xb0
> [162006.001374]  [<ffffffff810935d0>] ? kthread_freezable_should_stop+0x70/0x70
> [162006.001379] Code: ff ff ff c8 60 c7 00 00 c9 ff ff c0 60 c7 00 00 c9 ff ff
> 00 d0 4f 38 45 7f 00 00 c0 e7 ba a9 00 88 ff ff c0 07 00 00 00 00 00 00 <00> 2a
> c7 00 00 c9 ff ff 60 4e 0a 81 ff ff ff ff ec d7 4f 38 45
> [162006.001426] RIP  [<ffff8801d2ec7e90>] 0xffff8801d2ec7e90
> [162006.001433]  RSP <ffff8801d17b7c90>
> [162006.001437] CR2: ffff8801d2ec7e90
> [162006.001441] ---[ end trace 050b00c5503ce96b ]---
> [162006.001505] BUG: unable to handle kernel paging request at ffffffffffffffd8
> [162006.001514] IP: [<ffffffff81092f80>] kthread_data+0x10/0x20
> [162006.001521] PGD 1c14067 PUD 1c16067 PMD 0
> [162006.001528] Oops: 0000 [#3] SMP
> [162006.001532] Modules linked in: ipv6 dm_mod xen_netfront coretemp hwmon
> x86_pkg_temp_thermal crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel
> ablk_helper cryptd lrw gf128mul glue_helper aes_x86_64 microcode pcspkr ext4
> jbd2 mbcache raid0 xen_blkfront
> [162006.001562] CPU: 3 PID: 30835 Comm: kworker/3:2 Tainted: G      D      
> 3.16.0-rc5 #1
> [162006.001581] task: ffff8800797fc090 ti: ffff8801d17b4000 task.ti:
> ffff8801d17b4000
> [162006.001587] RIP: e030:[<ffffffff81092f80>]  [<ffffffff81092f80>]
> kthread_data+0x10/0x20
> [162006.001595] RSP: e02b:ffff8801d17b78d8  EFLAGS: 00010096
> [162006.001600] RAX: 0000000000000000 RBX: 0000000000000003 RCX:
> ffffffff81fc5160
> [162006.001605] RDX: ffff8800797fc090 RSI: 0000000000000003 RDI:
> ffff8800797fc090
> [162006.001611] RBP: ffff8801d17b78d8 R08: 0000000000000000 R09:
> dead000000200200
> [162006.001617] R10: 0000000000000000 R11: 0000000000000007 R12:
> 0000000000000003
> [162006.001623] R13: ffff8800797fc998 R14: 0000000000000001 R15:
> 0000000000000000
> [162006.001631] FS:  00007f9cf413b700(0000) GS:ffff8801def80000(0000)
> knlGS:0000000000000000
> [162006.001637] CS:  e033 DS: 0000 ES: 0000 CR0: 000000008005003b
> [162006.001642] CR2: 0000000000000028 CR3: 000000005ab6b000 CR4:
> 0000000000002660
> [162006.001647] Stack:
> [162006.001650]  ffff8801d17b78f8 ffffffff8108a2f5 ffff8801d17b78f8
> ffff8801def94380
> [162006.001658]  ffff8801d17b7968 ffffffff81643ce2 ffff8800797fc090
> ffff8801d17b4010
> [162006.001665]  0000000000014380 0000000000014380 ffff8800797fc090
> ffffffff812b1232
> [162006.001673] Call Trace:
> [162006.001679]  [<ffffffff8108a2f5>] wq_worker_sleeping+0x15/0xa0
> [162006.001685]  [<ffffffff81643ce2>] __schedule+0x552/0x6d0
> [162006.001692]  [<ffffffff812b1232>] ? put_io_context_active+0xd2/0x100
> [162006.001698]  [<ffffffff81643ff9>] schedule+0x29/0x70
> [162006.001705]  [<ffffffff81073ecd>] do_exit+0x2bd/0x470
> [162006.001711]  [<ffffffff810174c9>] oops_end+0xa9/0xf0
> [162006.001718]  [<ffffffff8105ca5e>] no_context+0x12e/0x200
> [162006.001724]  [<ffffffff81006e4f>] ? pte_mfn_to_pfn+0x7f/0x110
> [162006.002056]  [<ffffffff8105cc5d>] __bad_area_nosemaphore+0x12d/0x230
> [162006.002056]  [<ffffffff81005449>] ? __raw_callee_save_xen_pmd_val+0x11/0x1e
> [162006.002056]  [<ffffffff8105cd73>] bad_area_nosemaphore+0x13/0x20
> [162006.002056]  [<ffffffff8105d342>] __do_page_fault+0x332/0x4c0
> [162006.002056]  [<ffffffff81012885>] ? __switch_to+0x115/0x600
> [162006.002056]  [<ffffffff8109e273>] ? finish_task_switch+0x53/0xf0
> [162006.002056]  [<ffffffff81643b0a>] ? __schedule+0x37a/0x6d0
> [162006.002056]  [<ffffffff8105d5dc>] do_page_fault+0x2c/0x40
> [162006.002056]  [<ffffffff81649858>] page_fault+0x28/0x30
> [162006.002056]  [<ffffffff810b51e9>] ? __wake_up_common+0x59/0x90
> [162006.002056]  [<ffffffff810b56a8>] __wake_up+0x48/0x70
> [162006.002056]  [<ffffffff811b92dd>] memcg_oom_recover+0x3d/0x40
> [162006.002056]  [<ffffffff811bea90>] mem_cgroup_reparent_charges+0x110/0x150
> [162006.002056]  [<ffffffff811bec38>] mem_cgroup_css_offline+0x138/0x250
> [162006.002056]  [<ffffffff810f79f9>] css_killed_work_fn+0x49/0xd0
> [162006.002056]  [<ffffffff8108c91c>] process_one_work+0x17c/0x420
> [162006.002056]  [<ffffffff8108dab3>] worker_thread+0x123/0x420
> [162006.002056]  [<ffffffff8108d990>] ? maybe_create_worker+0x180/0x180
> [162006.002056]  [<ffffffff8109369e>] kthread+0xce/0xf0
> [162006.002056]  [<ffffffff810039fe>] ? xen_end_context_switch+0x1e/0x30
> [162006.002056]  [<ffffffff810935d0>] ? kthread_freezable_should_stop+0x70/0x70
> [162006.002056]  [<ffffffff816477fc>] ret_from_fork+0x7c/0xb0
> [162006.002056]  [<ffffffff810935d0>] ? kthread_freezable_should_stop+0x70/0x70
> [162006.002056] Code: b0 08 00 00 48 8b 40 c8 c9 48 c1 e8 02 83 e0 01 c3 66 2e
> 0f 1f 84 00 00 00 00 00 55 48 89 e5 0f 1f 44 00 00 48 8b 87 b0 08 00 00 <48> 8b
> 40 d8 c9 c3 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 0f
> [162006.002056] RIP  [<ffffffff81092f80>] kthread_data+0x10/0x20
> [162006.002056]  RSP <ffff8801d17b78d8>
> [162006.002056] CR2: ffffffffffffffd8
> [162006.002056] ---[ end trace 050b00c5503ce96c ]---
> [162006.002056] Fixing recursive fault but reboot is needed!
> 
> 
> 
> 
> And here is the similar output which was produced on 3.12.24:
> [118601.599452] memory: usage 131072kB, limit 131072kB, failcnt 130
> [118601.599458] memory+swap: usage 0kB, limit 18014398509481983kB, failcnt 0
> [118601.599462] kmem: usage 0kB, limit 18014398509481983kB, failcnt 0
> [118601.599466] Memory cgroup stats for
> /mesos/b9ef1fd7-e1e4-42d4-9760-caf41b13dcf9: cache:4KB rss:131068KB
> rss_huge:0KB mapped_file:0KB writeback:0KB inactive_anon:0KB
> active_anon:131068KB inactive_file:4KB active_file:0KB unevictable:0KB
> [118601.599490] [ pid ]   uid  tgid total_vm      rss nr_ptes swapents
> oom_score_adj name
> [118601.599533] [27602]     0 27602   511383    19982     148        0         
>    0 java7
> [118601.599541] [27734]     0 27734    47198     1433      50        0         
>    0 sudo
> [118601.599548] [27747]     0 27747   424395    18630      88        0         
>    0 java
> [118601.599554] Memory cgroup out of memory: Kill process 27602 (java7) score
> 595 or sacrifice child
> [118601.599564] Killed process 27734 (sudo) total-vm:188792kB, anon-rss:1548kB,
> file-rss:4184kB
> [118601.603075] general protection fault: 0000 [#1] SMP
> [118601.603084] Modules linked in: ipv6 dm_mod xen_netfront coretemp hwmon
> x86_pkg_temp_thermal crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel
> ablk_helper cryptd lrw gf128mul glue_helper aes_x86_64 microcode pcspkr ext4
> jbd2 mbcache raid0 xen_blkfront
> [118601.603116] CPU: 1 PID: 27748 Comm: java Not tainted 3.12.24 #1
> [118601.603122] task: ffff8800a5c3e940 ti: ffff8801d1b64000 task.ti:
> ffff8801d1b64000
> [118601.603128] RIP: e030:[<ffffffff811a73e0>]  [<ffffffff811a73e0>]
> mem_cgroup_oom_synchronize+0x140/0x230
> [118601.604055] RSP: e02b:ffff8801d1b65d58  EFLAGS: 00010287
> [118601.604055] RAX: 0000000000000001 RBX: ffff880004742000 RCX:
> 0000000000000021
> [118601.604055] RDX: ffffffffffffffea RSI: ffff880004740200 RDI:
> ffff880004740200
> [118601.604055] RBP: ffff8801d1b65db8 R08: 000000000000002c R09:
> 0000000000000000
> [118601.604055] R10: 0000000000000001 R11: 0000000000000000 R12:
> ffff880004742000
> [118601.604055] R13: ffff8801d1b65d58 R14: dead000000100100 R15:
> ffff880004742210
> [118601.604055] FS:  00007f8bf500a700(0000) GS:ffff8801dee80000(0000)
> knlGS:0000000000000000
> [118601.604055] CS:  e033 DS: 0000 ES: 0000 CR0: 000000008005003b
> [118601.604055] CR2: 00000000e3935000 CR3: 00000000ecf19000 CR4:
> 0000000000002660
> [118601.604055] Stack:
> [118601.604055]  ffff880004742000 0000000000000000 ffff8800a5c3e940
> ffffffff811a22e0
> [118601.604055]  ffffffff81c7e098 ffffffff81c7e098 ffff8801d1b65dd8
> 0000000000000006
> [118601.604055]  00000000000000a9 00000000e3935000 ffff8801d1b65f58
> 0000000000000001
> [118601.604055] Call Trace:
> [118601.604055]  [<ffffffff811a22e0>] ? mem_cgroup_wait_acct_move+0x110/0x110
> [118601.604055]  [<ffffffff81143e68>] pagefault_out_of_memory+0x18/0x90
> [118601.604055]  [<ffffffff81057b19>] mm_fault_error+0xa9/0x1a0
> [118601.604055]  [<ffffffff8160eb83>] __do_page_fault+0x4a3/0x4f0
> [118601.604055]  [<ffffffff81003a03>] ? xen_write_msr_safe+0xa3/0xd0
> [118601.604055]  [<ffffffff81012907>] ? __switch_to+0x1a7/0x500
> [118601.604055]  [<ffffffff810996a3>] ? finish_task_switch+0x53/0xe0
> [118601.604055]  [<ffffffff816088ca>] ? __schedule+0x3fa/0x710
> [118601.604055]  [<ffffffff8160ebde>] do_page_fault+0xe/0x10
> [118601.604055]  [<ffffffff8160b098>] page_fault+0x28/0x30
> [118601.604055] Code: 44 00 00 48 89 df e8 f0 d1 ff ff 48 85 c0 49 89 c4 74 35
> 4c 8b b0 10 02 00 00 4c 8d b8 10 02 00 00 4d 39 fe 74 1b 0f 1f 44 00 00 <49> 8b
> 7e 10 be 01 00 00 00 e8 12 15 05 00 4d 8b 36 4d 39 fe 75
> [118601.604055] RIP  [<ffffffff811a73e0>]
> mem_cgroup_oom_synchronize+0x140/0x230
> [118601.604055]  RSP <ffff8801d1b65d58>
> [118601.727935] ---[ end trace f02b14838d14e1af ]---
> [118601.902071] kernel tried to execute NX-protected page - exploit attempt?
> (uid: 0)
> [118601.902081] BUG: unable to handle kernel paging request at ffff8800051400c0
> [118601.902086] IP: [<ffff8800051400c0>] 0xffff8800051400c0
> [118601.902091] PGD 1c0d067 PUD 1c0e067 PMD 654a067 PTE 8010000005140067
> [118601.902097] Oops: 0011 [#2] SMP
> [118601.902100] Modules linked in: ipv6 dm_mod xen_netfront coretemp hwmon
> x86_pkg_temp_thermal crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel
> ablk_helper cryptd lrw gf128mul glue_helper aes_x86_64 microcode pcspkr ext4
> jbd2 mbcache raid0 xen_blkfront
> [118601.902120] CPU: 1 PID: 19577 Comm: kworker/1:2 Tainted: G      D     
> 3.12.24 #1
> [118601.902127] Workqueue: cgroup_destroy css_killed_work_fn
> [118601.902130] task: ffff8800a5d1a740 ti: ffff8801d0ac2000 task.ti:
> ffff8801d0ac2000
> [118601.902134] RIP: e030:[<ffff8800051400c0>]  [<ffff8800051400c0>]
> 0xffff8800051400c0
> [118601.902139] RSP: e02b:ffff8801d0ac3ca0  EFLAGS: 00010096
> [118601.902141] RAX: ffff8801d1b65d60 RBX: ffff8800ecebebe8 RCX:
> ffff880004742000
> [118601.902145] RDX: 0000000000000000 RSI: 0000000000000003 RDI:
> ffff8801d1b65d60
> [118601.902148] RBP: ffff8801d0ac3ce8 R08: ffff880004742000 R09:
> 0000000000000400
> [118601.902152] R10: 0000000000007ff0 R11: 0000000000000000 R12:
> 00000000b004d000
> [118601.902155] R13: ffffffff81c7e098 R14: ffff880004742000 R15:
> 0000000000000000
> [118601.902162] FS:  00007f7336da1700(0000) GS:ffff8801dee80000(0000)
> knlGS:0000000000000000
> [118601.902166] CS:  e033 DS: 0000 ES: 0000 CR0: 000000008005003b
> [118601.902169] CR2: ffff8800051400c0 CR3: 00000001d26e4000 CR4:
> 0000000000002660
> [118601.902173] Stack:
> [118601.902175]  ffffffff81094969 dead000000200200 0000000300000000
> ffff8801d0ac3ce8
> [118601.902180]  ffffffff81c7e090 0000000000000201 0000000000000003
> 0000000000000000
> [118601.902185]  ffff880004742000 ffff8801d0ac3d28 ffffffff81096ad8
> ffff88004e733660
> [118601.902190] Call Trace:
> [118601.902197]  [<ffffffff81094969>] ? __wake_up_common+0x59/0x90
> [118601.902201]  [<ffffffff81096ad8>] __wake_up+0x48/0x70
> [118601.902207]  [<ffffffff811a0f0d>] memcg_oom_recover+0x3d/0x40
> [118601.902211]  [<ffffffff811a53b0>] mem_cgroup_reparent_charges+0x110/0x150
> [118601.902215]  [<ffffffff811a55e8>] mem_cgroup_css_offline+0xb8/0x1b0
> [118601.902218]  [<ffffffff810e5c32>] css_killed_work_fn+0x52/0xf0
> [118601.902223]  [<ffffffff8108450c>] process_one_work+0x17c/0x420
> [118601.902226]  [<ffffffff81085a43>] worker_thread+0x123/0x400
> [118601.902230]  [<ffffffff81085920>] ? manage_workers+0x170/0x170
> [118601.902234]  [<ffffffff8108b9ce>] kthread+0xce/0xe0
> [118601.902239]  [<ffffffff8100394e>] ? xen_end_context_switch+0x1e/0x30
> [118601.902244]  [<ffffffff8108b900>] ? kthread_freezable_should_stop+0x70/0x70
> [118601.902250]  [<ffffffff816134bc>] ret_from_fork+0x7c/0xb0
> [118601.902254]  [<ffffffff8108b900>] ? kthread_freezable_should_stop+0x70/0x70
> [118601.902257] Code: cc cc cc cc cc cc cc cc cc cc cc cc cc cc cc cc cc cc cc
> cc cc cc cc cc cc cc cc cc cc cc cc cc cc cc cc cc cc cc cc cc cc cc cc <e0> 29
> 3d fd 00 88 ff ff 48 39 0e fd 00 88 ff ff c0 0c 2a fd 00
> [118601.902288] RIP  [<ffff8800051400c0>] 0xffff8800051400c0
> [118601.902291]  RSP <ffff8801d0ac3ca0>
> [118601.902293] CR2: ffff8800051400c0
> [118601.902296] ---[ end trace f02b14838d14e1b0 ]---
> [118601.902349] BUG: unable to handle kernel paging request at ffffffffffffffd8
> [118601.902353] IP: [<ffffffff8108b2a0>] kthread_data+0x10/0x20
> [118601.902358] PGD 1c0f067 PUD 1c11067 PMD 0
> [118601.902362] Oops: 0000 [#3] SMP
> [118601.902364] Modules linked in: ipv6 dm_mod xen_netfront coretemp hwmon
> x86_pkg_temp_thermal crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel
> ablk_helper cryptd lrw gf128mul glue_helper aes_x86_64 microcode pcspkr ext4
> jbd2 mbcache raid0 xen_blkfront
> [118601.902381] CPU: 1 PID: 19577 Comm: kworker/1:2 Tainted: G      D     
> 3.12.24 #1
> [118601.903052] task: ffff8800a5d1a740 ti: ffff8801d0ac2000 task.ti:
> ffff8801d0ac2000
> [118601.903052] RIP: e030:[<ffffffff8108b2a0>]  [<ffffffff8108b2a0>]
> kthread_data+0x10/0x20
> [118601.903052] RSP: e02b:ffff8801d0ac38d8  EFLAGS: 00010096
> [118601.903052] RAX: 0000000000000000 RBX: 0000000000000001 RCX:
> ffffffff81f790a0
> [118601.903052] RDX: 0000000000000004 RSI: 0000000000000001 RDI:
> ffff8800a5d1a740
> [118601.903052] RBP: ffff8801d0ac38d8 R08: 0000000000000000 R09:
> dead000000200200
> [118601.903052] R10: 00000000da3336c3 R11: 0000000000000000 R12:
> 0000000000000001
> [118601.903052] R13: ffff8800a5d1ad48 R14: 0000000000000001 R15:
> 0000000000000011
> [118601.903052] FS:  00007f7336da1700(0000) GS:ffff8801dee80000(0000)
> knlGS:0000000000000000
> [118601.903052] CS:  e033 DS: 0000 ES: 0000 CR0: 000000008005003b
> [118601.903052] CR2: 0000000000000028 CR3: 00000001d26e4000 CR4:
> 0000000000002660
> [118601.903052] Stack:
> [118601.903052]  ffff8801d0ac38f8 ffffffff81082685 ffff8801d0ac38f8
> ffff8801dee94480
> [118601.903052]  ffff8801d0ac3988 ffffffff81608a93 ffff8801d0ac3fd8
> 0000000000014480
> [118601.903052]  ffff8801d0ac2010 0000000000014480 0000000000014480
> 0000000000014480
> [118601.903052] Call Trace:
> [118601.903052]  [<ffffffff81082685>] wq_worker_sleeping+0x15/0xa0
> [118601.903052]  [<ffffffff81608a93>] __schedule+0x5c3/0x710
> [118601.903052]  [<ffffffff81298252>] ? put_io_context_active+0xc2/0xf0
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
