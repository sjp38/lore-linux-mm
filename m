Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 96CC16B0261
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 07:07:03 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id q4so9892997oic.12
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 04:07:03 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a63si5245888oif.469.2017.11.06.04.07.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Nov 2017 04:07:02 -0800 (PST)
Subject: Re: [PATCH v3] printk: Add console owner and waiter logic to load balance console writes
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171102134515.6eef16de@gandalf.local.home>
In-Reply-To: <20171102134515.6eef16de@gandalf.local.home>
Message-Id: <201711062106.ADI34320.JFtOFFHOOQVLSM@I-love.SAKURA.ne.jp>
Date: Mon, 6 Nov 2017 21:06:41 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rostedt@goodmis.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, mhocko@kernel.org, pmladek@suse.com, sergey.senozhatsky@gmail.com, vbabka@suse.cz

I tried your patch with warn_alloc() torture. It did not cause lockups.
But I felt that possibility of failing to flush last second messages (such
as SysRq-c or SysRq-b) to consoles has increased. Is this psychological?

---------- vmcore-dmesg start ----------
[  169.016198] postgres cpuset=
[  169.032544]  filemap_fault+0x311/0x790
[  169.047745] /
[  169.047780]  mems_allowed=0
[  169.050577]  ? xfs_ilock+0x126/0x1a0 [xfs]
[  169.062769]  mems_allowed=0
[  169.065754]  ? down_read_nested+0x3a/0x60
[  169.065783]  ? xfs_ilock+0x126/0x1a0 [xfs]
[  189.700206] sysrq: SysRq :
[  189.700639]  __xfs_filemap_fault.isra.19+0x3f/0xe0 [xfs]
[  189.700799]  xfs_filemap_fault+0xb/0x10 [xfs]
[  189.703981] Trigger a crash
[  189.707032]  __do_fault+0x19/0xa0
[  189.710008] BUG: unable to handle kernel
[  189.713387]  __handle_mm_fault+0xbb3/0xda0
[  189.716473] NULL pointer dereference
[  189.719674]  handle_mm_fault+0x14f/0x300
[  189.722969]  at           (null)
[  189.722974] IP: sysrq_handle_crash+0x3b/0x70
[  189.726156]  ? handle_mm_fault+0x39/0x300
[  189.729537] PGD 1170dc067
[  189.732841]  __do_page_fault+0x23e/0x4f0
[  189.735876] P4D 1170dc067
[  189.739171]  do_page_fault+0x30/0x80
[  189.742323] PUD 1170dd067
[  189.745437]  page_fault+0x22/0x30
[  189.748329] PMD 0
[  189.751106] RIP: 0033:0x650390
[  189.756583] RSP: 002b:00007fffef6b1568 EFLAGS: 00010246
[  189.759574] Oops: 0002 [#1] SMP DEBUG_PAGEALLOC
[  189.762607] RAX: 0000000000000000 RBX: 00007fffef6b1594 RCX: 00007fae949caa20
[  189.765665] Modules linked in:
[  189.768423] RDX: 0000000000000008 RSI: 0000000000000000 RDI: 0000000000000000
[  189.768425] RBP: 00007fffef6b1590 R08: 0000000000000002 R09: 0000000000000010
[  189.771478]  ip6t_rpfilter
[  189.774297] R10: 0000000000000001 R11: 0000000000000246 R12: 0000000000000000
[  189.777016]  ipt_REJECT
[  189.779366] R13: 0000000000000000 R14: 00007fae969787e0 R15: 0000000000000004
[  189.782114]  nf_reject_ipv4
[  189.784839] CPU: 7 PID: 6959 Comm: sleep Not tainted 4.14.0-rc8+ #302
[  189.785113] Mem-Info:
---------- vmcore-dmesg end ----------

---------- serial console start ----------
[  168.975447] Mem-Info:
[  168.975453] active_anon:827953 inactive_anon:3376 isolated_anon:0
[  168.975453]  active_file:55 inactive_file:449 isolated_file:246
[  168.975453]  unevictable:0 dirty:2 writeback:68 unstable:0
[  168.975453]  slab_reclaimable:4344 slab_unreclaimable:36066
[  168.975453]  mapped:2250 shmem:3543 pagetables:9568 bounce:0
[  168.975453]  free:21398 free_pcp:175 free_cma:0
[  168.975458] Node 0 active_anon:3311812kB inactive_anon:13504kB active_file:220kB inactive_file:1796kB unevictable:0kB isolated(anon):0kB isolated(file):984kB mapped:9000kB dirty:8kB writeback:272kB shmem:14172kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 2869248kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[  168.975460] Node 0 DMA free:14756kB min:288kB low:360kB high:432kB active_anon:1088kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:28kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  168.975482] lowmem_reserve[]: 0 2686 3619 3619
[  168.975489] Node 0 DMA32 free:53624kB min:49956kB low:62444kB high:74932kB active_anon:2691088kB inactive_anon:16kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129152kB managed:2751400kB mlocked:0kB kernel_stack:32kB pagetables:4232kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  168.975494] lowmem_reserve[]: 0 0 932 932
[  168.975501] Node 0 Normal free:17212kB min:17336kB low:21668kB high:26000kB active_anon:619636kB inactive_anon:13488kB active_file:220kB inactive_file:2872kB unevictable:0kB writepending:280kB present:1048576kB managed:954828kB mlocked:0kB kernel_stack:22784kB pagetables:34012kB bounce:0kB free_pcp:700kB local_pcp:40kB free_cma:0kB
[  168.975505] lowmem_reserve[]: 0 0 0 0
[  168.975512] Node 0 DMA: 1*4kB (U) 0*8kB 0*16kB 1*32kB (U) 2*64kB (UM) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 3*4096kB (M) = 14756kB
[  168.975536] Node 0 DMA32: 18*4kB (U) 14*8kB (UM) 14*16kB (UE) 37*32kB (UE) 9*64kB (UE) 4*128kB (UME) 1*256kB (M) 3*512kB (UME) 2*1024kB (UE) 3*2048kB (UME) 10*4096kB (M) = 53624kB
[    0.000000] Linux version 4.14.0-rc8+ (root@localhost.localdomain) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-16) (GCC)) #302 SMP Mon Nov 6 12:15:00 JST 2017
[    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-4.14.0-rc8+ root=UUID=98df1583-260a-423a-a193-182dade5d085 ro security=none sysrq_always_enabled console=ttyS0,115200n8 console=tty0 LANG=en_US.UTF-8 irqpoll nr_cpus=1 reset_devices cgroup_disable=memory mce=off numa=off udev.children-max=2 panic=10 rootflags=nofail acpi_no_memhotplug transparent_hugepage=never disable_cpu_apicid=0 elfcorehdr=867704K
---------- serial console end ----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
