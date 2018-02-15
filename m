Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id F27836B0028
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 03:46:18 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id y79so2584545wme.6
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 00:46:18 -0800 (PST)
Received: from smtprelay.restena.lu (smtprelay.restena.lu. [158.64.1.62])
        by mx.google.com with ESMTPS id 10si10943084wrx.209.2018.02.15.00.46.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Feb 2018 00:46:17 -0800 (PST)
Date: Thu, 15 Feb 2018 09:46:16 +0100
From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: CGroup-v2: Memory: current impossibly high for empty cgroup
Message-ID: <20180215094616.0a549840@pluto.restena.lu>
In-Reply-To: <20180215094024.5fc6161a@pluto.restena.lu>
References: <20180215094024.5fc6161a@pluto.restena.lu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 15 Feb 2018 09:40:24 +0100 Bruno Pr=C3=A9mont wrote:
> With 4.15.2 kernel I'm hitting a state where a given leaf v2 cgroup is
> considering itself as permanently over-limit and OOM-kill any process
> I try to move into it (it's currently empty!)
>=20
>=20
> I can't hand out a simple reproducer right now, but it seems during
> accounting the counter went "negative".
>=20
> CGroupv2 is mounted on /sys/fs/cgroup/hosting/ and the leaf-cgroup is
> /sys/fs/cgroup/hosting/websrv/:
> cgroup.controllers:cpu io memory pids
> cgroup.events:populated 0
> cgroup.max.depth:max
> cgroup.max.descendants:max
> cgroup.stat:nr_descendants 0
> cgroup.stat:nr_dying_descendants 0
> cgroup.type:domain
> cpu.max:max 100000
> cpu.stat:usage_usec 48830679
> cpu.stat:user_usec 25448590
> cpu.stat:system_usec 23382088
> cpu.stat:nr_periods 0
> cpu.stat:nr_throttled 0
> cpu.stat:throttled_usec 0
> cpu.weight:100
> cpu.weight.nice:0
> io.bfq.weight:100
> io.stat:8:0 rbytes=3D143360 wbytes=3D32768 rios=3D24 wios=3D7
> io.stat:7:0 rbytes=3D51687424 wbytes=3D0 rios=3D12619 wios=3D0
> io.weight:default 100
> memory.current:18446744073694965760
> memory.events:low 0
> memory.events:high 0
> memory.events:max 114
> memory.events:oom 15
> memory.events:oom_kill 8
> memory.high:8589934592
> memory.low:4294967296
> memory.max:17179869184
> memory.stat:anon 0
> memory.stat:file 0
> memory.stat:kernel_stack 0
> memory.stat:slab 593920
> memory.stat:sock 0
> memory.stat:shmem 0
> memory.stat:file_mapped 0
> memory.stat:file_dirty 0
> memory.stat:file_writeback 0
> memory.stat:inactive_anon 0
> memory.stat:active_anon 0
> memory.stat:inactive_file 0
> memory.stat:active_file 0
> memory.stat:unevictable 0
> memory.stat:slab_reclaimable 204800
> memory.stat:slab_unreclaimable 389120
> memory.stat:pgfault 80983
> memory.stat:pgmajfault 259
> memory.stat:pgrefill 115
> memory.stat:pgscan 384
> memory.stat:pgsteal 263
> memory.stat:pgactivate 100
> memory.stat:pgdeactivate 115
> memory.stat:pglazyfree 0
> memory.stat:pglazyfreed 0
> memory.stat:workingset_refault 0
> memory.stat:workingset_activate 0
> memory.stat:workingset_nodereclaim 3
> pids.current:0
> pids.events:max 0
> pids.max:max
>=20
> cgroup.procs is empty.
>=20
>=20
> Possibly interesting content in kernel log:
> [580391.746367] WARNING: CPU: 1 PID: 24354 at /data/kernel/linux-4.15/mm/=
page_counter.c:27 page_counter_cancel+0x10/0x20
> [580391.746498] Modules linked in: floppy
> [580391.746551] CPU: 1 PID: 24354 Comm: image-starter Not tainted 4.15.2-=
x86_64-vmware #2
> [580391.746612] Hardware name: VMware, Inc. VMware7,1/440BX Desktop Refer=
ence Platform, BIOS VMW71.00V.0.B64.1508272355 08/27/2015
> [580391.746716] RIP: 0010:page_counter_cancel+0x10/0x20
> [580391.746767] RSP: 0018:ffffad4f8475fb08 EFLAGS: 00010293
> [580391.746819] RAX: 0000000000000005 RBX: ffffad4f8475fb38 RCX: 00000000=
0000000e
> [580391.746877] RDX: ffffa058b6a51148 RSI: 000000000000000e RDI: ffffa058=
b6a51148
> [580391.746935] RBP: 000000000000000e R08: 0000000000022b30 R09: 00000000=
00000c4c
> [580391.746993] R10: 0000000000000004 R11: ffffffffffffffff R12: ffffad4f=
8475fb38
> [580391.747051] R13: ffffffffbbc68df8 R14: ffffad4f8475fd30 R15: 00000000=
00000001
> [580391.747117] FS:  00007fd5e3b84740(0000) GS:ffffa058bdd00000(0000) knl=
GS:0000000000000000
> [580391.747178] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [580391.747233] CR2: 00000000016fa3e8 CR3: 0000000005c0a001 CR4: 00000000=
000606a0
> [580391.747344] Call Trace:
> [580391.747400]  page_counter_uncharge+0x16/0x20
> [580391.747450]  uncharge_batch+0x2e/0x150
> [580391.747503]  mem_cgroup_uncharge_list+0x54/0x60
> [580391.747555]  release_pages+0x2f6/0x330
> [580391.747609]  __pagevec_release+0x25/0x30
> [580391.747659]  truncate_inode_pages_range+0x251/0x6e0
> [580391.747712]  ? write_cache_pages+0x311/0x350
> [580391.747763]  __blkdev_put+0x6f/0x1e0
> [580391.747815]  deactivate_locked_super+0x2a/0x60
> [580391.747870]  cleanup_mnt+0x40/0x60
> [580391.747921]  task_work_run+0x7b/0xa0
> [580391.747975]  do_exit+0x38d/0x960
> [580391.749543]  do_group_exit+0x99/0xa0
> [580391.750525]  SyS_exit_group+0xb/0x10
> [580391.751457]  do_syscall_64+0x74/0x120
> [580391.752427]  entry_SYSCALL_64_after_hwframe+0x21/0x86
> [580391.753370] RIP: 0033:0x7fd5e3463529
> [580391.754290] RSP: 002b:00007ffdaad73478 EFLAGS: 00000206 ORIG_RAX: 000=
00000000000e7
> [580391.755205] RAX: ffffffffffffffda RBX: 000000002d220011 RCX: 00007fd5=
e3463529
> [580391.756119] RDX: 0000000000000000 RSI: 00007ffdaad732dc RDI: 00000000=
00000000
> [580391.758421] RBP: 0000000000000000 R08: 000000000000003c R09: 00000000=
000000e7
> [580391.759590] R10: ffffffffffffff80 R11: 0000000000000206 R12: 00007ffd=
aad72480
> [580391.760499] R13: 0000000000001000 R14: 00000000016f8080 R15: 00000000=
00000000
> [580391.761366] Code: eb 07 e8 f4 26 fb ff eb d0 48 c7 c7 00 40 c3 bb e8 =
46 50 44 00 89 d8 5b 5d c3 90 48 89 f0 48 f7 d8 f0 48 0f c1 07 48 39 f0 79 =
02 <0f> ff c3 0f 1f 00 66 2e 0f 1f 84 00 00 00 00 00 eb 19 48 89 f0
> [580391.763136] ---[ end trace 60c773f283acdb6f ]---
> [580393.195186] image-starter invoked oom-killer: gfp_mask=3D0x14000c0(GF=
P_KERNEL), nodemask=3D(null), order=3D0, oom_score_adj=3D0
> [580393.199401] image-starter cpuset=3D/ mems_allowed=3D0
> [580393.201491] CPU: 1 PID: 28447 Comm: image-starter Tainted: G        W=
        4.15.2-x86_64-vmware #2
> [580393.202899] Hardware name: VMware, Inc. VMware7,1/440BX Desktop Refer=
ence Platform, BIOS VMW71.00V.0.B64.1508272355 08/27/2015
> [580393.202901] Call Trace:
> [580393.202918]  dump_stack+0x5c/0x85
> [580393.202927]  dump_header+0x5a/0x233
> [580393.202933]  oom_kill_process+0x91/0x3e0
> [580393.202936]  out_of_memory+0x221/0x240
> [580393.202940]  mem_cgroup_out_of_memory+0x36/0x50
> [580393.202942]  mem_cgroup_oom_synchronize+0x1ff/0x300
> [580393.202945]  ? __mem_cgroup_insert_exceeded+0x90/0x90
> [580393.202947]  pagefault_out_of_memory+0x1f/0x4d
> [580393.202951]  __do_page_fault+0x323/0x390
> [580393.202957]  ? page_fault+0x36/0x60
> [580393.202959]  page_fault+0x4c/0x60
> [580393.202964] RIP: 0033:0x7f9edd31c919
> [580393.202966] RSP: 002b:00007ffd818f4290 EFLAGS: 00010246
> [580393.202968] Task in /websrv killed as a result of limit of /websrv
> [580393.202972] memory: usage 18446744073709537436kB, limit 16777216kB, f=
ailcnt 44
> [580393.202973] memory+swap: usage 0kB, limit 9007199254740988kB, failcnt=
 0
> [580393.202975] kmem: usage 0kB, limit 9007199254740988kB, failcnt 0
> [580393.202976] Memory cgroup stats for /websrv: cache:16KB rss:0KB rss_h=
uge:0KB shmem:0KB mapped_file:0KB dirty:0KB writeback:16KB inactive_anon:0K=
B active_anon:0KB inactive_file:8KB active_file:8KB unevictable:0KB
> [580393.202983] [ pid ]   uid  tgid total_vm      rss pgtables_bytes swap=
ents oom_score_adj name
> [580393.203001] [28447]     0 28447     2143       31    57344        0  =
           0 image-starter
> [580393.203004] [28448]     0 28448     2143       34    57344        0  =
           0 image-starter
> [580393.203006] [28449]     0 28449     2143       34    57344        0  =
           0 image-starter
> [580393.203008] [28450]     0 28450     2143       34    57344        0  =
           0 image-starter
> [580393.203010] [28451]     0 28451     2143       34    57344        0  =
           0 image-starter
> [580393.203012] Memory cgroup out of memory: Kill process 28449 (image-st=
arter) score 0 or sacrifice child
> [580393.203026] Killed process 28449 (image-starter) total-vm:8572kB, ano=
n-rss:136kB, file-rss:0kB, shmem-rss:0kB
> ... (other processes being OOM-killed)

Removing the empty cgroup (rmdir websrv) triggered the following trace:
[582543.290104] ------------[ cut here ]------------
[582543.292875] percpu ref (css_release) <=3D 0 (-3558) after switching to =
atomic
[582543.292891] WARNING: CPU: 0 PID: 7 at /data/kernel/linux-4.15/lib/percp=
u-refcount.c:155 percpu_ref_switch_to_atomic_rcu+0x84/0xe0
[582543.295920] Modules linked in: floppy
[582543.297076] CPU: 0 PID: 7 Comm: ksoftirqd/0 Tainted: G        W        =
4.15.2-x86_64-vmware #2
[582543.298140] Hardware name: VMware, Inc. VMware7,1/440BX Desktop Referen=
ce Platform, BIOS VMW71.00V.0.B64.1508272355 08/27/2015
[582543.300693] RIP: 0010:percpu_ref_switch_to_atomic_rcu+0x84/0xe0
[582543.303211] RSP: 0018:ffffad4f8004be08 EFLAGS: 00010292
[582543.304333] RAX: 000000000000003f RBX: 7ffffffffffff219 RCX: ffffffffbb=
c2c258
[582543.305389] RDX: 0000000000000001 RSI: 0000000000000082 RDI: 0000000000=
000283
[582543.306423] RBP: ffffa058b6a510c0 R08: 00000000000004e5 R09: ffffffffbc=
670740
[582543.307421] R10: 0000000000006400 R11: 0000000000000000 R12: 00002cf6c2=
095658
[582543.308417] R13: ffffffffbbc689f8 R14: 7fffffffffffffff R15: 0000000000=
000202
[582543.309391] FS:  0000000000000000(0000) GS:ffffa058bdc00000(0000) knlGS=
:0000000000000000
[582543.310366] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[582543.314721] CR2: 00007f555727c030 CR3: 0000000005c0a003 CR4: 0000000000=
0606b0
[582543.316476] Call Trace:
[582543.317551]  rcu_process_callbacks+0x250/0x390
[582543.318489]  __do_softirq+0xd0/0x1ee
[582543.319384]  ? sort_range+0x20/0x20
[582543.320259]  run_ksoftirqd+0x17/0x40
[582543.322146]  smpboot_thread_fn+0x144/0x160
[582543.323886]  kthread+0x10d/0x120
[582543.324773]  ? kthread_create_on_node+0x40/0x40
[582543.325666]  ret_from_fork+0x35/0x40
[582543.326536] Code: 45 d8 48 85 c0 7f 26 80 3d 91 f5 9a 00 00 75 1d 48 8b=
 55 d8 48 c7 c7 88 d1 b2 bb c6 05 7d f5 9a 00 01 48 8b 75 e8 e8 ec cf d8 ff=
 <0f> ff 48 8d 5d d8 48 8b 45 f0 48 89 df e8 4a ca 54 00 48 c7 45
[582543.328411] ---[ end trace 60c773f283acdb70 ]---


> image-starter is a small kind of container managing tool that makes use of
> namespaces and assigns namespaced processes to corresponding cgroups (per=
tinent
> cgroup directories are bind-mounted into the mount namespace).
>=20
>=20
> The probable memory-counter-underflow seems to have happened either on st=
op of
> container (likely) or on new start of it.
>=20
> Possibly of interest, some mmaps inside cgroup did fail during previous r=
un of
> container due to RLIMIT_DATA.
>=20
>=20
> As this is a test system I can happily perform debugging and experimentat=
ion on it
> (I'm currently working at moving from v1 cgroups to v2 cgroups).
>=20
> Cheers,
> Bruno

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
