Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 75AF16B0038
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 21:39:05 -0400 (EDT)
Received: by iodv82 with SMTP id v82so6512328iod.0
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 18:39:05 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id c18si16240513igr.28.2015.10.19.18.39.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Oct 2015 18:39:04 -0700 (PDT)
Received: by pabrc13 with SMTP id rc13so3891502pab.0
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 18:39:04 -0700 (PDT)
Date: Tue, 20 Oct 2015 10:38:54 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/5] MADV_FREE refactoring and fix KSM page
Message-ID: <20151020013834.GA2941@bbox>
References: <1445236307-895-1-git-send-email-minchan@kernel.org>
 <20151019100150.GA5194@bbox>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="f+W+jCU1fRNres8c"
Content-Disposition: inline
In-Reply-To: <20151019100150.GA5194@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>


--f+W+jCU1fRNres8c
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Oct 19, 2015 at 07:01:50PM +0900, Minchan Kim wrote:
> On Mon, Oct 19, 2015 at 03:31:42PM +0900, Minchan Kim wrote:
> > Hello, it's too late since I sent previos patch.
> > https://lkml.org/lkml/2015/6/3/37
> > 
> > This patch is alomost new compared to previos approach.
> > I think this is more simple, clear and easy to review.
> > 
> > One thing I should notice is that I have tested this patch
> > and couldn't find any critical problem so I rebased patchset
> > onto recent mmotm(ie, mmotm-2015-10-15-15-20) to send formal
> > patchset. Unfortunately, I start to see sudden discarding of
> > the page we shouldn't do. IOW, application's valid anonymous page
> > was disappeared suddenly.
> > 
> > When I look through THP changes, I think we could lose
> > dirty bit of pte between freeze_page and unfreeze_page
> > when we mark it as migration entry and restore it.
> > So, I added below simple code without enough considering
> > and cannot see the problem any more.
> > I hope it's good hint to find right fix this problem.
> > 
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index d5ea516ffb54..e881c04f5950 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -3138,6 +3138,9 @@ static void unfreeze_page_vma(struct vm_area_struct *vma, struct page *page,
> >  		if (is_write_migration_entry(swp_entry))
> >  			entry = maybe_mkwrite(entry, vma);
> >  
> > +		if (PageDirty(page))
> > +			SetPageDirty(page);
> 
> The condition of PageDirty was typo. I didn't add the condition.
> Just added.
> 
>                 SetPageDirty(page);

For the first step to find this bug, I removed all MADV_FREE related
code in mmotm-2015-10-15-15-20. IOW, git checkout 54bad5da4834
(arm64: add pmd_[dirty|mkclean] for THP) so the tree doesn't have
any core code of MADV_FREE.

I tested following workloads in my KVM machine.

0. make memcg
1. limit memcg
2. fork several processes
3. each process allocates THP page and fill
4. increase limit of the memcg to swapoff successfully
5. swapoff
6. kill all of processes
7. goto 1

Within a few hours, I encounter following bug.
Attached detailed boot log and dmesg result.


Initializing cgroup subsys cpu
Command line: hung_task_panic=1 earlyprintk=ttyS0,115200 debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=100 panic=-1 softlockup_panic=1 nmi_watchdog=panic oops=panic console=ttyS0,115200 console=tty0 earlyprintk=ttyS0 ignore_loglevel ftrace_dump_on_oops vga=normal root=/dev/vda1 rw
KERNEL supported cpus:
  Intel GenuineIntel
x86/fpu: Legacy x87 FPU detected.
x86/fpu: Using 'lazy' FPU context switches.
e820: BIOS-provided physical RAM map:
BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
BIOS-e820: [mem 0x0000000000100000-0x00000000bfffbfff] usable
BIOS-e820: [mem 0x00000000bfffc000-0x00000000bfffffff] reserved
BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved

<snip>

Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
IP: [<ffffffff810782a9>] down_read_trylock+0x9/0x30
PGD 0 
Oops: 0000 [#1] SMP 
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 1 PID: 26445 Comm: sh Not tainted 4.3.0-rc5-mm1-diet-meta+ #1545
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff8800b9af3480 ti: ffff88007fea0000 task.ti: ffff88007fea0000
RIP: 0010:[<ffffffff810782a9>]  [<ffffffff810782a9>] down_read_trylock+0x9/0x30
RSP: 0018:ffff88007fea3648  EFLAGS: 00010202
RAX: 0000000000000001 RBX: ffffea0002324900 RCX: ffff88007fea37e8
RDX: 0000000000000000 RSI: ffff88007fea36e8 RDI: 0000000000000008
RBP: ffff88007fea3648 R08: ffffffff818446a0 R09: ffff8800b9af4c80
R10: 0000000000000216 R11: 0000000000000001 R12: ffff88007f58d6e1
R13: ffff88007f58d6e0 R14: 0000000000000008 R15: 0000000000000001
FS:  00007f0993e78740(0000) GS:ffff8800bfa20000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000008 CR3: 000000007edee000 CR4: 00000000000006a0
Stack:
 ffff88007fea3678 ffffffff81124ff0 ffffea0002324900 ffff88007fea36e8
 ffff88009ffe8400 0000000000000000 ffff88007fea36c0 ffffffff81125733
 ffff8800bfa34540 ffffffff8105dc9d ffffea0002324900 ffff88007fea37e8
Call Trace:
 [<ffffffff81124ff0>] page_lock_anon_vma_read+0x60/0x180
 [<ffffffff81125733>] rmap_walk+0x1b3/0x3f0
 [<ffffffff8105dc9d>] ? finish_task_switch+0x5d/0x1f0
 [<ffffffff81125b13>] page_referenced+0x1a3/0x220
 [<ffffffff81123e30>] ? __page_check_address+0x1a0/0x1a0
 [<ffffffff81124f90>] ? page_get_anon_vma+0xd0/0xd0
 [<ffffffff81123820>] ? anon_vma_ctor+0x40/0x40
 [<ffffffff8110087b>] shrink_page_list+0x5ab/0xde0
 [<ffffffff8110174c>] shrink_inactive_list+0x18c/0x4b0
 [<ffffffff811023bd>] shrink_lruvec+0x59d/0x740
 [<ffffffff811025f0>] shrink_zone+0x90/0x250
 [<ffffffff811028dd>] do_try_to_free_pages+0x12d/0x3b0
 [<ffffffff81102d3d>] try_to_free_mem_cgroup_pages+0x9d/0x120
 [<ffffffff811496c3>] try_charge+0x163/0x700
 [<ffffffff81149cb4>] mem_cgroup_do_precharge+0x54/0x70
 [<ffffffff81149e45>] mem_cgroup_can_attach+0x175/0x1b0
 [<ffffffff811b2c57>] ? kernfs_iattrs.isra.6+0x37/0xd0
 [<ffffffff81148e70>] ? get_mctgt_type+0x320/0x320
 [<ffffffff810a9d29>] cgroup_migrate+0x149/0x440
 [<ffffffff810aa60c>] cgroup_attach_task+0x7c/0xe0
 [<ffffffff810aa904>] __cgroup_procs_write.isra.33+0x1d4/0x2b0
 [<ffffffff810aaa10>] cgroup_tasks_write+0x10/0x20
 [<ffffffff810a6238>] cgroup_file_write+0x38/0xf0
 [<ffffffff811b54ad>] kernfs_fop_write+0x11d/0x170
 [<ffffffff81153918>] __vfs_write+0x28/0xe0
 [<ffffffff8116e614>] ? __fd_install+0x24/0xc0
 [<ffffffff810784a1>] ? percpu_down_read+0x21/0x50
 [<ffffffff81153e91>] vfs_write+0xa1/0x170
 [<ffffffff81154716>] SyS_write+0x46/0xa0
 [<ffffffff81420a17>] entry_SYSCALL_64_fastpath+0x12/0x6a
Code: 5e 82 3a 00 48 83 c4 08 5b 5d c3 48 89 45 f0 e8 9b 6a 3a 00 48 8b 45 f0 eb df 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 55 48 89 e5 <48> 8b 07 48 89 c2 48 83 c2 01 7e 07 f0 48 0f b1 17 75 f0 48 f7 
RIP  [<ffffffff810782a9>] down_read_trylock+0x9/0x30
 RSP <ffff88007fea3648>
CR2: 0000000000000008
BUG: unable to handle kernel ---[ end trace e81a82c8122b447d ]---
Kernel panic - not syncing: Fatal exception

NULL pointer dereference at 0000000000000008
IP: [<ffffffff810782a9>] down_read_trylock+0x9/0x30
PGD 0 
Oops: 0000 [#2] SMP 
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 10 PID: 59 Comm: khugepaged Tainted: G      D         4.3.0-rc5-mm1-diet-meta+ #1545
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff8800b9851a40 ti: ffff8800b985c000 task.ti: ffff8800b985c000
RIP: 0010:[<ffffffff810782a9>]  [<ffffffff810782a9>] down_read_trylock+0x9/0x30
RSP: 0018:ffff8800b985f778  EFLAGS: 00010202
RAX: 0000000000000001 RBX: ffffea0002321800 RCX: ffff8800b985f918
RDX: 0000000000000000 RSI: ffff8800b985f818 RDI: 0000000000000008
RBP: ffff8800b985f778 R08: ffffffff818446a0 R09: ffff8800b9853240
R10: 000000000000ba03 R11: 0000000000000001 R12: ffff88007f58d6e1
R13: ffff88007f58d6e0 R14: 0000000000000008 R15: 0000000000000001
FS:  0000000000000000(0000) GS:ffff8800bfb40000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000008 CR3: 0000000001808000 CR4: 00000000000006a0
Stack:
 ffff8800b985f7a8 ffffffff81124ff0 ffffea0002321800 ffff8800b985f818
 ffff88009ffe8400 0000000000000000 ffff8800b985f7f0 ffffffff81125733
 ffff8800bfb54540 ffffffff8105dc9d ffffea0002321800 ffff8800b985f918
Call Trace:
 [<ffffffff81124ff0>] page_lock_anon_vma_read+0x60/0x180
 [<ffffffff81125733>] rmap_walk+0x1b3/0x3f0
 [<ffffffff8105dc9d>] ? finish_task_switch+0x5d/0x1f0
 [<ffffffff81125b13>] page_referenced+0x1a3/0x220
 [<ffffffff81123e30>] ? __page_check_address+0x1a0/0x1a0
 [<ffffffff81124f90>] ? page_get_anon_vma+0xd0/0xd0
 [<ffffffff81123820>] ? anon_vma_ctor+0x40/0x40
 [<ffffffff8110087b>] shrink_page_list+0x5ab/0xde0
 [<ffffffff8110174c>] shrink_inactive_list+0x18c/0x4b0
 [<ffffffff811023bd>] shrink_lruvec+0x59d/0x740
 [<ffffffff811025f0>] shrink_zone+0x90/0x250
 [<ffffffff811028dd>] do_try_to_free_pages+0x12d/0x3b0
 [<ffffffff81102d3d>] try_to_free_mem_cgroup_pages+0x9d/0x120
 [<ffffffff811496c3>] try_charge+0x163/0x700
 [<ffffffff8141d1f3>] ? schedule+0x33/0x80
 [<ffffffff8114d45f>] mem_cgroup_try_charge+0x9f/0x1d0
 [<ffffffff811434bc>] khugepaged+0x7cc/0x1ac0
 [<ffffffff81066e01>] ? hrtick_update+0x1/0x70
 [<ffffffff81072430>] ? prepare_to_wait_event+0xf0/0xf0
 [<ffffffff81142cf0>] ? total_mapcount+0x70/0x70
 [<ffffffff81056cd9>] kthread+0xc9/0xe0
 [<ffffffff81056c10>] ? kthread_park+0x60/0x60
 [<ffffffff81420d6f>] ret_from_fork+0x3f/0x70
 [<ffffffff81056c10>] ? kthread_park+0x60/0x60
Code: 5e 82 3a 00 48 83 c4 08 5b 5d c3 48 89 45 f0 e8 9b 6a 3a 00 48 8b 45 f0 eb df 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 55 48 89 e5 <48> 8b 07 48 89 c2 48 83 c2 01 7e 07 f0 48 0f b1 17 75 f0 48 f7 
RIP  [<ffffffff810782a9>] down_read_trylock+0x9/0x30
 RSP <ffff8800b985f778>
CR2: 0000000000000008
---[ end trace e81a82c8122b447e ]---
Shutting down cpus with NMI
Dumping ftrace buffer:
   (ftrace buffer empty)
Kernel Offset: disabled


--f+W+jCU1fRNres8c
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="test_bug.log"
Content-Transfer-Encoding: quoted-printable

QEMU 2.0.0 monitor - type 'help' for more information=0D
(qemu) s=1B[Kearly console in setup code=0D
Initializing cgroup subsys cpu=0D
Linux version 4.3.0-rc5-mm1-diet-meta+ (barrios@bbox) (gcc version 4.8.4 (U=
buntu 4.8.4-2ubuntu1~14.04) ) #1545 SMP Tue Oct 20 08:55:45 KST 2015=0D
Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200 debug apic=3Dd=
ebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D100 panic=3D-1 s=
oftlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic console=3DttyS0,11520=
0 console=3Dtty0 earlyprintk=3DttyS0 ignore_loglevel ftrace_dump_on_oops vg=
a=3Dnormal root=3D/dev/vda1 rw=0D
KERNEL supported cpus:=0D
  Intel GenuineIntel=0D
x86/fpu: Legacy x87 FPU detected.=0D
x86/fpu: Using 'lazy' FPU context switches.=0D
e820: BIOS-provided physical RAM map:=0D
BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable=0D
BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved=0D
BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved=0D
BIOS-e820: [mem 0x0000000000100000-0x00000000bfffbfff] usable=0D
BIOS-e820: [mem 0x00000000bfffc000-0x00000000bfffffff] reserved=0D
BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved=0D
BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved=0D
bootconsole [earlyser0] enabled=0D
debug: ignoring loglevel setting.=0D
NX (Execute Disable) protection: active=0D
SMBIOS 2.4 present.=0D
DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011=0D
e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> reserved=0D
e820: remove [mem 0x000a0000-0x000fffff] usable=0D
e820: last_pfn =3D 0xbfffc max_arch_pfn =3D 0x400000000=0D
MTRR default type: write-back=0D
MTRR fixed ranges enabled:=0D
  00000-9FFFF write-back=0D
  A0000-BFFFF uncachable=0D
  C0000-FFFFF write-protect=0D
MTRR variable ranges enabled:=0D
  0 base 00C0000000 mask FFC0000000 uncachable=0D
  1 disabled=0D
  2 disabled=0D
  3 disabled=0D
  4 disabled=0D
  5 disabled=0D
  6 disabled=0D
  7 disabled=0D
x86/PAT: PAT not supported by CPU.=0D
Scan for SMP in [mem 0x00000000-0x000003ff]=0D
Scan for SMP in [mem 0x0009fc00-0x0009ffff]=0D
Scan for SMP in [mem 0x000f0000-0x000fffff]=0D
found SMP MP-table at [mem 0x000f0a70-0x000f0a7f] mapped at [ffff8800000f0a=
70]=0D
  mpc: f0a80-f0c44=0D
Scanning 1 areas for low memory corruption=0D
Base memory trampoline at [ffff880000099000] 99000 size 24576=0D
init_memory_mapping: [mem 0x00000000-0x000fffff]=0D
 [mem 0x00000000-0x000fffff] page 4k=0D
BRK [0x0220e000, 0x0220efff] PGTABLE=0D
BRK [0x0220f000, 0x0220ffff] PGTABLE=0D
BRK [0x02210000, 0x02210fff] PGTABLE=0D
init_memory_mapping: [mem 0xbfc00000-0xbfdfffff]=0D
 [mem 0xbfc00000-0xbfdfffff] page 2M=0D
BRK [0x02211000, 0x02211fff] PGTABLE=0D
init_memory_mapping: [mem 0xa0000000-0xbfbfffff]=0D
 [mem 0xa0000000-0xbfbfffff] page 2M=0D
init_memory_mapping: [mem 0x80000000-0x9fffffff]=0D
 [mem 0x80000000-0x9fffffff] page 2M=0D
init_memory_mapping: [mem 0x00100000-0x7fffffff]=0D
 [mem 0x00100000-0x001fffff] page 4k=0D
 [mem 0x00200000-0x7fffffff] page 2M=0D
init_memory_mapping: [mem 0xbfe00000-0xbfffbfff]=0D
 [mem 0xbfe00000-0xbfffbfff] page 4k=0D
BRK [0x02212000, 0x02212fff] PGTABLE=0D
RAMDISK: [mem 0x7851a000-0x7fffffff]=0D
 [ffffea0000000000-ffffea0002ffffff] PMD -> [ffff8800bc400000-ffff8800bf3ff=
fff] on node 0=0D
Zone ranges:=0D
  DMA      [mem 0x0000000000001000-0x0000000000ffffff]=0D
  DMA32    [mem 0x0000000001000000-0x00000000bfffbfff]=0D
  Normal   empty=0D
Movable zone start for each node=0D
Early memory node ranges=0D
  node   0: [mem 0x0000000000001000-0x000000000009efff]=0D
  node   0: [mem 0x0000000000100000-0x00000000bfffbfff]=0D
Initmem setup node 0 [mem 0x0000000000001000-0x00000000bfffbfff]=0D
On node 0 totalpages: 786330=0D
  DMA zone: 64 pages used for memmap=0D
  DMA zone: 21 pages reserved=0D
  DMA zone: 3998 pages, LIFO batch:0=0D
  DMA32 zone: 12224 pages used for memmap=0D
  DMA32 zone: 782332 pages, LIFO batch:31=0D
Intel MultiProcessor Specification v1.4=0D
  mpc: f0a80-f0c44=0D
MPTABLE: OEM ID: BOCHSCPU=0D
MPTABLE: Product ID: 0.1         =0D
MPTABLE: APIC at: 0xFEE00000=0D
mapped APIC to ffffffffff5fd000 (        fee00000)=0D
Processor #0 (Bootup-CPU)=0D
Processor #1=0D
Processor #2=0D
Processor #3=0D
Processor #4=0D
Processor #5=0D
Processor #6=0D
Processor #7=0D
Processor #8=0D
Processor #9=0D
Processor #10=0D
Processor #11=0D
Bus #0 is PCI   =0D
Bus #1 is ISA   =0D
IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-23=0D
Int: type 0, pol 1, trig 0, bus 00, IRQ 04, APIC ID 0, APIC INT 09=0D
Int: type 0, pol 1, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC INT 0b=0D
Int: type 0, pol 1, trig 0, bus 00, IRQ 10, APIC ID 0, APIC INT 0b=0D
Int: type 0, pol 1, trig 0, bus 00, IRQ 14, APIC ID 0, APIC INT 0a=0D
Int: type 0, pol 1, trig 0, bus 00, IRQ 18, APIC ID 0, APIC INT 0a=0D
Int: type 0, pol 0, trig 0, bus 01, IRQ 00, APIC ID 0, APIC INT 02=0D
Int: type 0, pol 0, trig 0, bus 01, IRQ 01, APIC ID 0, APIC INT 01=0D
Int: type 0, pol 0, trig 0, bus 01, IRQ 03, APIC ID 0, APIC INT 03=0D
Int: type 0, pol 0, trig 0, bus 01, IRQ 04, APIC ID 0, APIC INT 04=0D
Int: type 0, pol 0, trig 0, bus 01, IRQ 06, APIC ID 0, APIC INT 06=0D
Int: type 0, pol 0, trig 0, bus 01, IRQ 07, APIC ID 0, APIC INT 07=0D
Int: type 0, pol 0, trig 0, bus 01, IRQ 08, APIC ID 0, APIC INT 08=0D
Int: type 0, pol 0, trig 0, bus 01, IRQ 0c, APIC ID 0, APIC INT 0c=0D
Int: type 0, pol 0, trig 0, bus 01, IRQ 0d, APIC ID 0, APIC INT 0d=0D
Int: type 0, pol 0, trig 0, bus 01, IRQ 0e, APIC ID 0, APIC INT 0e=0D
Int: type 0, pol 0, trig 0, bus 01, IRQ 0f, APIC ID 0, APIC INT 0f=0D
Lint: type 3, pol 0, trig 0, bus 01, IRQ 00, APIC ID 0, APIC LINT 00=0D
Lint: type 1, pol 0, trig 0, bus 01, IRQ 00, APIC ID ff, APIC LINT 01=0D
Processors: 12=0D
smpboot: Allowing 12 CPUs, 0 hotplug CPUs=0D
mapped IOAPIC to ffffffffff5fc000 (fec00000)=0D
e820: [mem 0xc0000000-0xfeffbfff] available for PCI devices=0D
clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_=
idle_ns: 7645519600211568 ns=0D
setup_percpu: NR_CPUS:16 nr_cpumask_bits:16 nr_cpu_ids:12 nr_node_ids:1=0D
PERCPU: Embedded 31 pages/cpu @ffff8800bfa00000 s87640 r8192 d31144 u131072=
=0D
pcpu-alloc: s87640 r8192 d31144 u131072 alloc=3D1*2097152=0D
pcpu-alloc: [0] 00 01 02 03 04 05 06 07 08 09 10 11 -- -- -- -- =0D
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 774021=
=0D
Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200 debug a=
pic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D100 panic=
=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic console=3DttyS=
0,115200 console=3Dtty0 earlyprintk=3DttyS0 ignore_loglevel ftrace_dump_on_=
oops vga=3Dnormal root=3D/dev/vda1 rw=0D
sysrq: sysrq always enabled.=0D
log_buf_len individual max cpu contribution: 2097152 bytes=0D
log_buf_len total cpu_extra contributions: 23068672 bytes=0D
log_buf_len min size: 8388608 bytes=0D
log_buf_len: 33554432 bytes=0D
early log buf free: 8380096(99%)=0D
PID hash table entries: 4096 (order: 3, 32768 bytes)=0D
Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)=0D
Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)=0D
Memory: 2911172K/3145320K available (4237K kernel code, 721K rwdata, 1988K =
rodata, 936K init, 8608K bss, 234148K reserved, 0K cma-reserved)=0D
SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D12, Nodes=3D1=0D
Hierarchical RCU implementation.=0D
	Build-time adjustment of leaf fanout to 64.=0D
	RCU restricting CPUs from NR_CPUS=3D16 to nr_cpu_ids=3D12.=0D
RCU: Adjusting geometry for rcu_fanout_leaf=3D64, nr_cpu_ids=3D12=0D
NR_IRQS:4352 nr_irqs:136 16=0D
Console: colour VGA+ 80x25=0D
console [tty0] enabled=0D
bootconsole [earlyser0] disabled=0D
Initializing cgroup subsys cpu=0D
Linux version 4.3.0-rc5-mm1-diet-meta+ (barrios@bbox) (gcc version 4.8.4 (U=
buntu 4.8.4-2ubuntu1~14.04) ) #1545 SMP Tue Oct 20 08:55:45 KST 2015=0D
Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200 debug apic=3Dd=
ebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D100 panic=3D-1 s=
oftlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic console=3DttyS0,11520=
0 console=3Dtty0 earlyprintk=3DttyS0 ignore_loglevel ftrace_dump_on_oops vg=
a=3Dnormal root=3D/dev/vda1 rw=0D
KERNEL supported cpus:=0D
  Intel GenuineIntel=0D
x86/fpu: Legacy x87 FPU detected.=0D
x86/fpu: Using 'lazy' FPU context switches.=0D
e820: BIOS-provided physical RAM map:=0D
BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable=0D
BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved=0D
BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved=0D
BIOS-e820: [mem 0x0000000000100000-0x00000000bfffbfff] usable=0D
BIOS-e820: [mem 0x00000000bfffc000-0x00000000bfffffff] reserved=0D
BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved=0D
BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved=0D
bootconsole [earlyser0] enabled=0D
debug: ignoring loglevel setting.=0D
NX (Execute Disable) protection: active=0D
SMBIOS 2.4 present.=0D
DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011=0D
e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> reserved=0D
e820: remove [mem 0x000a0000-0x000fffff] usable=0D
e820: last_pfn =3D 0xbfffc max_arch_pfn =3D 0x400000000=0D
MTRR default type: write-back=0D
MTRR fixed ranges enabled:=0D
  00000-9FFFF write-back=0D
  A0000-BFFFF uncachable=0D
  C0000-FFFFF write-protect=0D
MTRR variable ranges enabled:=0D
  0 base 00C0000000 mask FFC0000000 uncachable=0D
  1 disabled=0D
  2 disabled=0D
  3 disabled=0D
  4 disabled=0D
  5 disabled=0D
  6 disabled=0D
  7 disabled=0D
x86/PAT: PAT not supported by CPU.=0D
Scan for SMP in [mem 0x00000000-0x000003ff]=0D
Scan for SMP in [mem 0x0009fc00-0x0009ffff]=0D
Scan for SMP in [mem 0x000f0000-0x000fffff]=0D
found SMP MP-table at [mem 0x000f0a70-0x000f0a7f] mapped at [ffff8800000f0a=
70]=0D
  mpc: f0a80-f0c44=0D
Scanning 1 areas for low memory corruption=0D
Base memory trampoline at [ffff880000099000] 99000 size 24576=0D
init_memory_mapping: [mem 0x00000000-0x000fffff]=0D
 [mem 0x00000000-0x000fffff] page 4k=0D
BRK [0x0220e000, 0x0220efff] PGTABLE=0D
BRK [0x0220f000, 0x0220ffff] PGTABLE=0D
BRK [0x02210000, 0x02210fff] PGTABLE=0D
init_memory_mapping: [mem 0xbfc00000-0xbfdfffff]=0D
 [mem 0xbfc00000-0xbfdfffff] page 2M=0D
BRK [0x02211000, 0x02211fff] PGTABLE=0D
init_memory_mapping: [mem 0xa0000000-0xbfbfffff]=0D
 [mem 0xa0000000-0xbfbfffff] page 2M=0D
init_memory_mapping: [mem 0x80000000-0x9fffffff]=0D
 [mem 0x80000000-0x9fffffff] page 2M=0D
init_memory_mapping: [mem 0x00100000-0x7fffffff]=0D
 [mem 0x00100000-0x001fffff] page 4k=0D
 [mem 0x00200000-0x7fffffff] page 2M=0D
init_memory_mapping: [mem 0xbfe00000-0xbfffbfff]=0D
 [mem 0xbfe00000-0xbfffbfff] page 4k=0D
BRK [0x02212000, 0x02212fff] PGTABLE=0D
RAMDISK: [mem 0x7851a000-0x7fffffff]=0D
 [ffffea0000000000-ffffea0002ffffff] PMD -> [ffff8800bc400000-ffff8800bf3ff=
fff] on node 0=0D
Zone ranges:=0D
  DMA      [mem 0x0000000000001000-0x0000000000ffffff]=0D
  DMA32    [mem 0x0000000001000000-0x00000000bfffbfff]=0D
  Normal   empty=0D
Movable zone start for each node=0D
Early memory node ranges=0D
  node   0: [mem 0x0000000000001000-0x000000000009efff]=0D
  node   0: [mem 0x0000000000100000-0x00000000bfffbfff]=0D
Initmem setup node 0 [mem 0x0000000000001000-0x00000000bfffbfff]=0D
On node 0 totalpages: 786330=0D
  DMA zone: 64 pages used for memmap=0D
  DMA zone: 21 pages reserved=0D
  DMA zone: 3998 pages, LIFO batch:0=0D
  DMA32 zone: 12224 pages used for memmap=0D
  DMA32 zone: 782332 pages, LIFO batch:31=0D
Intel MultiProcessor Specification v1.4=0D
  mpc: f0a80-f0c44=0D
MPTABLE: OEM ID: BOCHSCPU=0D
MPTABLE: Product ID: 0.1         =0D
MPTABLE: APIC at: 0xFEE00000=0D
mapped APIC to ffffffffff5fd000 (        fee00000)=0D
Processor #0 (Bootup-CPU)=0D
Processor #1=0D
Processor #2=0D
Processor #3=0D
Processor #4=0D
Processor #5=0D
Processor #6=0D
Processor #7=0D
Processor #8=0D
Processor #9=0D
Processor #10=0D
Processor #11=0D
Bus #0 is PCI   =0D
Bus #1 is ISA   =0D
IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-23=0D
Int: type 0, pol 1, trig 0, bus 00, IRQ 04, APIC ID 0, APIC INT 09=0D
Int: type 0, pol 1, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC INT 0b=0D
Int: type 0, pol 1, trig 0, bus 00, IRQ 10, APIC ID 0, APIC INT 0b=0D
Int: type 0, pol 1, trig 0, bus 00, IRQ 14, APIC ID 0, APIC INT 0a=0D
Int: type 0, pol 1, trig 0, bus 00, IRQ 18, APIC ID 0, APIC INT 0a=0D
Int: type 0, pol 0, trig 0, bus 01, IRQ 00, APIC ID 0, APIC INT 02=0D
Int: type 0, pol 0, trig 0, bus 01, IRQ 01, APIC ID 0, APIC INT 01=0D
Int: type 0, pol 0, trig 0, bus 01, IRQ 03, APIC ID 0, APIC INT 03=0D
Int: type 0, pol 0, trig 0, bus 01, IRQ 04, APIC ID 0, APIC INT 04=0D
Int: type 0, pol 0, trig 0, bus 01, IRQ 06, APIC ID 0, APIC INT 06=0D
Int: type 0, pol 0, trig 0, bus 01, IRQ 07, APIC ID 0, APIC INT 07=0D
Int: type 0, pol 0, trig 0, bus 01, IRQ 08, APIC ID 0, APIC INT 08=0D
Int: type 0, pol 0, trig 0, bus 01, IRQ 0c, APIC ID 0, APIC INT 0c=0D
Int: type 0, pol 0, trig 0, bus 01, IRQ 0d, APIC ID 0, APIC INT 0d=0D
Int: type 0, pol 0, trig 0, bus 01, IRQ 0e, APIC ID 0, APIC INT 0e=0D
Int: type 0, pol 0, trig 0, bus 01, IRQ 0f, APIC ID 0, APIC INT 0f=0D
Lint: type 3, pol 0, trig 0, bus 01, IRQ 00, APIC ID 0, APIC LINT 00=0D
Lint: type 1, pol 0, trig 0, bus 01, IRQ 00, APIC ID ff, APIC LINT 01=0D
Processors: 12=0D
smpboot: Allowing 12 CPUs, 0 hotplug CPUs=0D
mapped IOAPIC to ffffffffff5fc000 (fec00000)=0D
e820: [mem 0xc0000000-0xfeffbfff] available for PCI devices=0D
clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_=
idle_ns: 7645519600211568 ns=0D
setup_percpu: NR_CPUS:16 nr_cpumask_bits:16 nr_cpu_ids:12 nr_node_ids:1=0D
PERCPU: Embedded 31 pages/cpu @ffff8800bfa00000 s87640 r8192 d31144 u131072=
=0D
pcpu-alloc: s87640 r8192 d31144 u131072 alloc=3D1*2097152=0D
pcpu-alloc: [0] 00 01 02 03 04 05 06 07 08 09 10 11 -- -- -- -- =0D
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 774021=
=0D
Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200 debug a=
pic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D100 panic=
=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic console=3DttyS=
0,115200 console=3Dtty0 earlyprintk=3DttyS0 ignore_loglevel ftrace_dump_on_=
oops vga=3Dnormal root=3D/dev/vda1 rw=0D
sysrq: sysrq always enabled.=0D
log_buf_len individual max cpu contribution: 2097152 bytes=0D
log_buf_len total cpu_extra contributions: 23068672 bytes=0D
log_buf_len min size: 8388608 bytes=0D
log_buf_len: 33554432 bytes=0D
early log buf free: 8380096(99%)=0D
PID hash table entries: 4096 (order: 3, 32768 bytes)=0D
Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)=0D
Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)=0D
Memory: 2911172K/3145320K available (4237K kernel code, 721K rwdata, 1988K =
rodata, 936K init, 8608K bss, 234148K reserved, 0K cma-reserved)=0D
SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D12, Nodes=3D1=0D
Hierarchical RCU implementation.=0D
	Build-time adjustment of leaf fanout to 64.=0D
	RCU restricting CPUs from NR_CPUS=3D16 to nr_cpu_ids=3D12.=0D
RCU: Adjusting geometry for rcu_fanout_leaf=3D64, nr_cpu_ids=3D12=0D
NR_IRQS:4352 nr_irqs:136 16=0D
Console: colour VGA+ 80x25=0D
console [tty0] enabled=0D
bootconsole [earlyser0] disabled=0D
console [ttyS0] enabled=0D
tsc: Fast TSC calibration using PIT=0D
tsc: Detected 3199.926 MHz processor=0D
Calibrating delay loop (skipped), value calculated using timer frequency.. =
6399.85 BogoMIPS (lpj=3D12799704)=0D
pid_max: default: 32768 minimum: 301=0D
Mount-cache hash table entries: 8192 (order: 4, 65536 bytes)=0D
Mountpoint-cache hash table entries: 8192 (order: 4, 65536 bytes)=0D
Initializing cgroup subsys memory=0D
Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0=0D
Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0=0D
Freeing SMP alternatives memory: 20K (ffffffff819a0000 - ffffffff819a5000)=
=0D
ftrace: allocating 16664 entries in 66 pages=0D
Switched APIC routing to physical flat.=0D
enabled ExtINT on CPU#0=0D
ENABLING IO-APIC IRQs=0D
init IO_APIC IRQs=0D
 apic 0 pin 0 not connected=0D
IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:0)=
=0D
IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Active:0 Dest:0)=
=0D
IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest:0)=
=0D
IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:0)=
=0D
 apic 0 pin 5 not connected=0D
IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:0)=
=0D
IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:0)=
=0D
IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:0)=
=0D
IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Active:0 Dest:0)=
=0D
IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 Active:0 Dest:0=
)=0D
IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 Active:0 Dest:0=
)=0D
IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:0=
)=0D
IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 Dest:0=
)=0D
IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 Active:0 Dest:0=
)=0D
IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 Active:0 Dest:0=
)=0D
 apic 0 pin 16 not connected=0D
 apic 0 pin 17 not connected=0D
 apic 0 pin 18 not connected=0D
 apic 0 pin 19 not connected=0D
 apic 0 pin 20 not connected=0D
 apic 0 pin 21 not connected=0D
 apic 0 pin 22 not connected=0D
 apic 0 pin 23 not connected=0D
=2E.TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D-1=0D
Using local APIC timer interrupts.=0D
calibrating APIC timer ...=0D
=2E.. lapic delta =3D 6251755=0D
=2E.... delta 6251755=0D
=2E.... mult: 268510832=0D
=2E.... calibration result: 4001123=0D
=2E.... CPU clock speed is 3200.3592 MHz.=0D
=2E.... host bus clock speed is 1000.1123 MHz.=0D
=2E.. verify APIC timer=0D
=2E.. jiffies delta =3D 25=0D
=2E.. jiffies result ok=0D
smpboot: CPU0: Intel QEMU Virtual CPU version 2.0.0 (family: 0x6, model: 0x=
6, stepping: 0x3)=0D
Performance Events: Broken PMU hardware detected, using software events onl=
y.=0D
Failed to access perfctr msr (MSR c2 is 0)=0D
x86: Booting SMP configuration:=0D
=2E... node  #0, CPUs:        #1=0D
masked ExtINT on CPU#1=0D
  #2=0D
masked ExtINT on CPU#2=0D
  #3=0D
masked ExtINT on CPU#3=0D
  #4=0D
masked ExtINT on CPU#4=0D
  #5=0D
masked ExtINT on CPU#5=0D
  #6=0D
masked ExtINT on CPU#6=0D
  #7=0D
masked ExtINT on CPU#7=0D
  #8=0D
masked ExtINT on CPU#8=0D
  #9=0D
masked ExtINT on CPU#9=0D
 #10=0D
masked ExtINT on CPU#10=0D
 #11=0D
masked ExtINT on CPU#11=0D
x86: Booted up 1 node, 12 CPUs=0D
smpboot: Total of 12 processors activated (76818.13 BogoMIPS)=0D
devtmpfs: initialized=0D
clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns:=
 7645041785100000 ns=0D
NET: Registered protocol family 16=0D
PCI: Using configuration type 1 for base access=0D
vgaarb: loaded=0D
SCSI subsystem initialized=0D
libata version 3.00 loaded.=0D
PCI: Probing PCI hardware=0D
PCI: root bus 00: using default resources=0D
PCI: Probing PCI hardware (bus 00)=0D
PCI host bridge to bus 0000:00=0D
pci_bus 0000:00: root bus resource [io  0x0000-0xffff]=0D
pci_bus 0000:00: root bus resource [mem 0x00000000-0xffffffffff]=0D
pci_bus 0000:00: No busn resource found for root bus, will use [bus 00-ff]=
=0D
pci 0000:00:00.0: [8086:1237] type 00 class 0x060000=0D
pci 0000:00:01.0: [8086:7000] type 00 class 0x060100=0D
pci 0000:00:01.1: [8086:7010] type 00 class 0x010180=0D
pci 0000:00:01.1: reg 0x20: [io  0xc0c0-0xc0cf]=0D
pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]=0D
pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]=0D
pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]=0D
pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]=0D
pci 0000:00:01.3: [8086:7113] type 00 class 0x068000=0D
pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000=0D
pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]=0D
pci 0000:00:02.0: reg 0x14: [mem 0xfebd0000-0xfebd0fff]=0D
pci 0000:00:02.0: reg 0x30: [mem 0xfebc0000-0xfebcffff pref]=0D
vgaarb: setting as boot device: PCI:0000:00:02.0=0D
vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=3Dio+mem,locks=
=3Dnone=0D
pci 0000:00:03.0: [1af4:1000] type 00 class 0x020000=0D
pci 0000:00:03.0: reg 0x10: [io  0xc080-0xc09f]=0D
pci 0000:00:03.0: reg 0x14: [mem 0xfebd1000-0xfebd1fff]=0D
pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff pref]=0D
pci 0000:00:04.0: [1af4:1002] type 00 class 0x00ff00=0D
pci 0000:00:04.0: reg 0x10: [io  0xc0a0-0xc0bf]=0D
pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000=0D
pci 0000:00:05.0: reg 0x10: [io  0xc000-0xc03f]=0D
pci 0000:00:05.0: reg 0x14: [mem 0xfebd2000-0xfebd2fff]=0D
pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000=0D
pci 0000:00:06.0: reg 0x10: [io  0xc040-0xc07f]=0D
pci 0000:00:06.0: reg 0x14: [mem 0xfebd3000-0xfebd3fff]=0D
pci 0000:00:07.0: [8086:25ab] type 00 class 0x088000=0D
pci 0000:00:07.0: reg 0x10: [mem 0xfebd4000-0xfebd400f]=0D
pci_bus 0000:00: busn_res: [bus 00-ff] end is updated to 00=0D
pci 0000:00:01.0: PIIX/ICH IRQ router [8086:7000]=0D
PCI: pci_cache_line_size set to 64 bytes=0D
e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]=0D
e820: reserve RAM buffer [mem 0xbfffc000-0xbfffffff]=0D
clocksource: Switched to clocksource refined-jiffies=0D
pci_bus 0000:00: resource 4 [io  0x0000-0xffff]=0D
pci_bus 0000:00: resource 5 [mem 0x00000000-0xffffffffff]=0D
NET: Registered protocol family 2=0D
TCP established hash table entries: 32768 (order: 6, 262144 bytes)=0D
TCP bind hash table entries: 32768 (order: 7, 524288 bytes)=0D
TCP: Hash tables configured (established 32768 bind 32768)=0D
UDP hash table entries: 2048 (order: 4, 65536 bytes)=0D
UDP-Lite hash table entries: 2048 (order: 4, 65536 bytes)=0D
NET: Registered protocol family 1=0D
Trying to unpack rootfs image as initramfs...=0D
Freeing initrd memory: 125848K (ffff88007851a000 - ffff880080000000)=0D
platform rtc_cmos: registered platform RTC device (no PNP device found)=0D
Scanning for low memory corruption every 60 seconds=0D
futex hash table entries: 4096 (order: 6, 262144 bytes)=0D
HugeTLB registered 2 MB page size, pre-allocated 0 pages=0D
fuse init (API version 7.23)=0D
9p: Installing v9fs 9p2000 file system support=0D
cryptomgr_test (74) used greatest stack depth: 15352 bytes left=0D
cryptomgr_test (82) used greatest stack depth: 15136 bytes left=0D
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 251)=0D
io scheduler noop registered=0D
io scheduler deadline registered=0D
io scheduler cfq registered (default)=0D
querying PCI -> IRQ mapping bus:0, slot:3, pin:0.=0D
virtio-pci 0000:00:03.0: PCI->APIC IRQ transform: INT A -> IRQ 11=0D
virtio-pci 0000:00:03.0: virtio_pci: leaving for legacy driver=0D
querying PCI -> IRQ mapping bus:0, slot:4, pin:0.=0D
virtio-pci 0000:00:04.0: PCI->APIC IRQ transform: INT A -> IRQ 11=0D
virtio-pci 0000:00:04.0: virtio_pci: leaving for legacy driver=0D
querying PCI -> IRQ mapping bus:0, slot:5, pin:0.=0D
virtio-pci 0000:00:05.0: PCI->APIC IRQ transform: INT A -> IRQ 10=0D
virtio-pci 0000:00:05.0: virtio_pci: leaving for legacy driver=0D
querying PCI -> IRQ mapping bus:0, slot:6, pin:0.=0D
virtio-pci 0000:00:06.0: PCI->APIC IRQ transform: INT A -> IRQ 10=0D
virtio-pci 0000:00:06.0: virtio_pci: leaving for legacy driver=0D
Serial: 8250/16550 driver, 32 ports, IRQ sharing enabled=0D
serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) is a 16550=
A=0D
Linux agpgart interface v0.103=0D
brd: module loaded=0D
loop: module loaded=0D
 vda: vda1 vda2 < vda5 >=0D
zram: Added device: zram0=0D
libphy: Fixed MDIO Bus: probed=0D
tun: Universal TUN/TAP device driver, 1.6=0D
tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>=0D
serio: i8042 KBD port at 0x60,0x64 irq 1=0D
serio: i8042 AUX port at 0x60,0x64 irq 12=0D
mousedev: PS/2 mouse device common for all mice=0D
rtc_cmos rtc_cmos: rtc core: registered rtc_cmos as rtc0=0D
rtc_cmos rtc_cmos: alarms up to one day, 114 bytes nvram=0D
device-mapper: ioctl: 4.33.0-ioctl (2015-8-18) initialised: dm-devel@redhat=
=2Ecom=0D
device-mapper: cache cleaner: version 1.0.0 loaded=0D
NET: Registered protocol family 17=0D
9pnet: Installing 9P2000 support=0D
=2E.. APIC ID:      00000000 (0)=0D
=2E.. APIC VERSION: 01050014=0D
0000000000000000000000000000000000000000000000000000000000000000=0D
000000000e000000000000000000000000000000000000000000000000000000=0D
0000000000020000000000000000000000000000000000000000000000008000=0D
=0D
number of MP IRQ sources: 16.=0D
number of IO-APIC #0 registers: 24.=0D
testing the IO APIC.......................=0D
IO APIC #0......=0D
=2E... register #00: 00000000=0D
=2E......    : physical APIC id: 00=0D
=2E......    : Delivery Type: 0=0D
=2E......    : LTS          : 0=0D
=2E... register #01: 00170011=0D
=2E......     : max redirection entries: 17=0D
=2E......     : PRQ implemented: 0=0D
=2E......     : IO APIC version: 11=0D
=2E... register #02: 00000000=0D
=2E......     : arbitration: 00=0D
=2E... IRQ redirection table:=0D
IOAPIC 0:=0D
 pin00, disabled, edge , high, V(00), IRR(0), S(0), physical, D(00), M(0)=0D
 pin01, enabled , edge , high, V(31), IRR(0), S(0), physical, D(00), M(0)=0D
 pin02, enabled , edge , high, V(30), IRR(0), S(0), physical, D(00), M(0)=0D
 pin03, enabled , edge , high, V(33), IRR(0), S(0), physical, D(00), M(0)=0D
 pin04, disabled, edge , high, V(34), IRR(0), S(0), physical, D(00), M(0)=0D
 pin05, disabled, edge , high, V(00), IRR(0), S(0), physical, D(00), M(0)=0D
 pin06, enabled , edge , high, V(36), IRR(0), S(0), physical, D(00), M(0)=0D
 pin07, enabled , edge , high, V(37), IRR(0), S(0), physical, D(00), M(0)=0D
 pin08, enabled , edge , high, V(38), IRR(0), S(0), physical, D(00), M(0)=0D
 pin09, disabled, level, high, V(39), IRR(0), S(0), physical, D(00), M(0)=0D
 pin0a, enabled , level, high, V(3A), IRR(0), S(0), physical, D(00), M(0)=0D
 pin0b, enabled , level, high, V(3B), IRR(0), S(0), physical, D(00), M(0)=0D
 pin0c, enabled , edge , high, V(3C), IRR(0), S(0), physical, D(00), M(0)=0D
 pin0d, enabled , edge , high, V(3D), IRR(0), S(0), physical, D(00), M(0)=0D
 pin0e, enabled , edge , high, V(3E), IRR(0), S(0), physical, D(00), M(0)=0D
 pin0f, enabled , edge , high, V(3F), IRR(0), S(0), physical, D(00), M(0)=0D
 pin10, disabled, edge , high, V(00), IRR(0), S(0), physical, D(00), M(0)=0D
 pin11, disabled, edge , high, V(00), IRR(0), S(0), physical, D(00), M(0)=0D
 pin12, disabled, edge , high, V(00), IRR(0), S(0), physical, D(00), M(0)=0D
 pin13, disabled, edge , high, V(00), IRR(0), S(0), physical, D(00), M(0)=0D
 pin14, disabled, edge , high, V(00), IRR(0), S(0), physical, D(00), M(0)=0D
 pin15, disabled, edge , high, V(00), IRR(0), S(0), physical, D(00), M(0)=0D
 pin16, disabled, edge , high, V(00), IRR(0), S(0), physical, D(00), M(0)=0D
 pin17, disabled, edge , high, V(00), IRR(0), S(0), physical, D(00), M(0)=0D
IRQ to pin mappings:=0D
IRQ0 -> 0:2=0D
IRQ1 -> 0:1=0D
IRQ3 -> 0:3=0D
IRQ4 -> 0:4=0D
IRQ6 -> 0:6=0D
IRQ7 -> 0:7=0D
IRQ8 -> 0:8=0D
IRQ9 -> 0:9=0D
IRQ10 -> 0:10=0D
IRQ11 -> 0:11=0D
IRQ12 -> 0:12=0D
IRQ13 -> 0:13=0D
IRQ14 -> 0:14=0D
IRQ15 -> 0:15=0D
=2E................................... done.=0D
rtc_cmos rtc_cmos: setting system clock to 2015-10-20 08:57:55 UTC (1445331=
475)=0D
input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input=
/input0=0D
Freeing unused kernel memory: 936K (ffffffff818b6000 - ffffffff819a0000)=0D
Write protecting the kernel read-only data: 8192k=0D
Freeing unused kernel memory: 1900K (ffff880001425000 - ffff880001600000)=0D
Freeing unused kernel memory: 60K (ffff8800017f1000 - ffff880001800000)=0D
busybox (117) used greatest stack depth: 14480 bytes left=0D
exe (124) used greatest stack depth: 14024 bytes left=0D
udevd[140]: starting version 175=0D
blkid (151) used greatest stack depth: 13920 bytes left=0D
modprobe (242) used greatest stack depth: 13784 bytes left=0D
clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x2e200418439, max_i=
dle_ns: 440795220848 ns=0D
clocksource: Switched to clocksource tsc=0D
EXT4-fs (vda1): recovery complete=0D
EXT4-fs (vda1): mounted filesystem with ordered data mode. Opts: (null)=0D
exe (262) used greatest stack depth: 13032 bytes left=0D
random: init urandom read with 9 bits of entropy available=0D
init: plymouth-upstart-bridge main process (279) terminated with status 1=0D
init: plymouth-upstart-bridge main process ended, respawning=0D
init: plymouth-upstart-bridge main process (289) terminated with status 1=0D
init: plymouth-upstart-bridge main process ended, respawning=0D
init: plymouth-upstart-bridge main process (293) terminated with status 1=0D
init: plymouth-upstart-bridge main process ended, respawning=0D
init: ureadahead main process (282) terminated with status 5=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
systemd-udevd[423]: starting version 204=0D
EXT4-fs (vdb): mounted filesystem with ordered data mode. Opts: errors=3Dre=
mount-ro=0D
 * Stopping Send an event to indicate plymouth is up=1B[74G[ OK ]=0D=0D
 * Starting Mount filesystems on boot=1B[74G[ OK ]=0D=0D
 * Starting Signal sysvinit that the rootfs is mounted=1B[74G[ OK ]=0D=0D
 * Starting Populate /dev filesystem=1B[74G[ OK ]=0D=0D
 * Starting Populate and link to /run filesystem=1B[74G[ OK ]=0D=0D
 * Stopping Populate /dev filesystem=1B[74G[ OK ]=0D=0D
 * Stopping Populate and link to /run filesystem=1B[74G[ OK ]=0D=0D
 * Starting Clean /tmp directory=1B[74G[ OK ]=0D=0D
 * Stopping Track if upstart is running in a container=1B[74G[ OK ]=0D=0D
 * Stopping Clean /tmp directory=1B[74G[ OK ]=0D=0D
 * Starting Initialize or finalize resolvconf=1B[74G[ OK ]=0D=0D
 * Starting set console keymap=1B[74G[ OK ]=0D=0D
 * Starting Signal sysvinit that virtual filesystems are mounted=1B[74G[ OK=
 ]=0D=0D
 * Starting Signal sysvinit that virtual filesystems are mounted=1B[74G[ OK=
 ]=0D=0D
 * Starting Bridge udev events into upstart=1B[74G[ OK ]=0D=0D
 * Starting Signal sysvinit that remote filesystems are mounted=1B[74G[ OK =
]=0D=0D
 * Stopping set console keymap=1B[74G[ OK ]=0D=0D
 * Starting device node and kernel event manager=1B[74G[ OK ]=0D=0D
 * Starting load modules from /etc/modules=1B[74G[ OK ]=0D=0D
 * Starting cold plug devices=1B[74G[ OK ]=0D=0D
 * Starting log initial device creation=1B[74G[ OK ]=0D=0D
 * Stopping Read required files in advance (for other mountpoints)=1B[74G[ =
OK ]=0D=0D
 * Stopping load modules from /etc/modules=1B[74G[ OK ]=0D=0D
 * Starting Signal sysvinit that local filesystems are mounted=1B[74G[ OK ]=
=0D=0D
 * Starting flush early job output to logs=1B[74G[ OK ]=0D=0D
 * Stopping Mount filesystems on boot=1B[74G[ OK ]=0D=0D
 * Stopping flush early job output to logs=1B[74G[ OK ]=0D=0D
 * Starting D-Bus system message bus=1B[74G[ OK ]=0D=0D
 * Starting SystemD login management service=1B[74G[ OK ]=0D=0D
 * Starting system logging daemon=1B[74G[ OK ]=0D=0D
 * Stopping cold plug devices=1B[74G[ OK ]=0D=0D
 * Starting Uncomplicated firewall=1B[74G[ OK ]=0D=0D
 * Starting configure network device security=1B[74G[ OK ]=0D=0D
 * Stopping log initial device creation=1B[74G[ OK ]=0D=0D
 * Starting configure network device security=1B[74G[ OK ]=0D=0D
 * Starting save udev log and update rules=1B[74G[ OK ]=0D=0D
 * Starting set console font=1B[74G[ OK ]=0D=0D
 * Stopping save udev log and update rules=1B[74G[ OK ]=0D=0D
 * Starting Mount network filesystems=1B[74G[ OK ]=0D=0D
 * Starting Failsafe Boot Delay=1B[74G[ OK ]=0D=0D
 * Starting configure network device security=1B[74G[ OK ]=0D=0D
 * Stopping Mount network filesystems=1B[74G[ OK ]=0D=0D
 * Starting configure network device=1B[74G[ OK ]=0D=0D
 * Starting configure network device=1B[74G[ OK ]=0D=0D
 * Starting Bridge file events into upstart=1B[74G[ OK ]=0D=0D
 * Starting Bridge socket events into upstart=1B[74G[ OK ]=0D=0D
 * Stopping set console font=1B[74G[ OK ]=0D=0D
 * Starting userspace bootsplash=1B[74G[ OK ]=0D=0D
 * Starting Send an event to indicate plymouth is up=1B[74G[ OK ]=0D=0D
 * Stopping userspace bootsplash=1B[74G[ OK ]=0D=0D
 * Stopping Send an event to indicate plymouth is up=1B[74G[ OK ]=0D=0D
 * Starting Mount network filesystems=1B[74G[ OK ]=0D=0D
init: failsafe main process (591) killed by TERM signal=0D
 * Stopping Failsafe Boot Delay=1B[74G[ OK ]=0D=0D
 * Starting System V initialisation compatibility=1B[74G[ OK ]=0D=0D
 * Stopping Mount network filesystems=1B[74G[ OK ]=0D=0D
 * Starting configure virtual network devices=1B[74G[ OK ]=0D=0D
 * Stopping System V initialisation compatibility=1B[74G[ OK ]=0D=0D
 * Starting System V runlevel compatibility=1B[74G[ OK ]=0D=0D
 * Starting deferred execution scheduler=1B[74G[ OK ]=0D=0D
 * Starting regular background program processing daemon=1B[74G[ OK ]=0D=0D
 * Starting ACPI daemon=1B[74G[ OK ]=0D=0D
 * Starting save kernel messages=1B[74G[ OK ]=0D=0D
 * Starting CPU interrupts balancing daemon=1B[74G[ OK ]=0D=0D
 * Stopping save kernel messages=1B[74G[ OK ]=0D=0D
 * Starting OpenSSH server=1B[74G[ OK ]=0D=0D
 * Starting automatic crash report generation=1B[74G[ OK ]=0D=0D
 * Restoring resolver state...       =1B[80G =0D=1B[74G[ OK ]=0D=0D
eth0 Link encap:Ethernet HWaddr 52:54:79:12:34:57 inet addr:192.168.0.21 Bc=
ast:192.168.0.255 Mask:255.255.255.0 UP BROADCAST RUNNING MULTICAST MTU:150=
0 Metric:1 RX packets:34 errors:0 dropped:24 overruns:0 frame:0 TX packets:=
4 errors:0 dropped:0 overruns:0 carrier:0 collisions:0 txqueuelen:1000 RX b=
ytes:5780 (5.7 KB) TX bytes:800 (800.0 B) lo Link encap:Local Loopback inet=
 addr:127.0.0.1 Mask:255.0.0.0 UP LOOPBACK RUNNING MTU:65536 Metric:1 RX pa=
ckets:0 errors:0 dropped:0 overruns:0 frame:0 TX packets:0 errors:0 dropped=
:0 overruns:0 carrier:0 collisions:0 txqueuelen:0 RX bytes:0 (0.0 B) TX byt=
es:0 (0.0 B)=0D
 * Stopping System V runlevel compatibility=1B[74G[ OK ]=0D=0D
init: plymouth-upstart-bridge main process ended, respawning=0D
sh (1429) used greatest stack depth: 11752 bytes left=0D
sh (1454) used greatest stack depth: 11528 bytes left=0D
random: nonblocking pool is initialized=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
sh (2785) used greatest stack depth: 11480 bytes left=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k F=
S=0D
BUG: unable to handle kernel NULL pointer dereference at 0000000000000008=0D
IP: [<ffffffff810782a9>] down_read_trylock+0x9/0x30=0D
PGD 0 =0D
Oops: 0000 [#1] SMP =0D
Dumping ftrace buffer:=0D
   (ftrace buffer empty)=0D
Modules linked in:=0D
CPU: 1 PID: 26445 Comm: sh Not tainted 4.3.0-rc5-mm1-diet-meta+ #1545=0D
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/201=
1=0D
task: ffff8800b9af3480 ti: ffff88007fea0000 task.ti: ffff88007fea0000=0D
RIP: 0010:[<ffffffff810782a9>]  [<ffffffff810782a9>] down_read_trylock+0x9/=
0x30=0D
RSP: 0018:ffff88007fea3648  EFLAGS: 00010202=0D
RAX: 0000000000000001 RBX: ffffea0002324900 RCX: ffff88007fea37e8=0D
RDX: 0000000000000000 RSI: ffff88007fea36e8 RDI: 0000000000000008=0D
RBP: ffff88007fea3648 R08: ffffffff818446a0 R09: ffff8800b9af4c80=0D
R10: 0000000000000216 R11: 0000000000000001 R12: ffff88007f58d6e1=0D
R13: ffff88007f58d6e0 R14: 0000000000000008 R15: 0000000000000001=0D
FS:  00007f0993e78740(0000) GS:ffff8800bfa20000(0000) knlGS:000000000000000=
0=0D
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b=0D
CR2: 0000000000000008 CR3: 000000007edee000 CR4: 00000000000006a0=0D
Stack:=0D
 ffff88007fea3678 ffffffff81124ff0 ffffea0002324900 ffff88007fea36e8=0D
 ffff88009ffe8400 0000000000000000 ffff88007fea36c0 ffffffff81125733=0D
 ffff8800bfa34540 ffffffff8105dc9d ffffea0002324900 ffff88007fea37e8=0D
Call Trace:=0D
 [<ffffffff81124ff0>] page_lock_anon_vma_read+0x60/0x180=0D
 [<ffffffff81125733>] rmap_walk+0x1b3/0x3f0=0D
 [<ffffffff8105dc9d>] ? finish_task_switch+0x5d/0x1f0=0D
 [<ffffffff81125b13>] page_referenced+0x1a3/0x220=0D
 [<ffffffff81123e30>] ? __page_check_address+0x1a0/0x1a0=0D
 [<ffffffff81124f90>] ? page_get_anon_vma+0xd0/0xd0=0D
 [<ffffffff81123820>] ? anon_vma_ctor+0x40/0x40=0D
 [<ffffffff8110087b>] shrink_page_list+0x5ab/0xde0=0D
 [<ffffffff8110174c>] shrink_inactive_list+0x18c/0x4b0=0D
 [<ffffffff811023bd>] shrink_lruvec+0x59d/0x740=0D
 [<ffffffff811025f0>] shrink_zone+0x90/0x250=0D
 [<ffffffff811028dd>] do_try_to_free_pages+0x12d/0x3b0=0D
 [<ffffffff81102d3d>] try_to_free_mem_cgroup_pages+0x9d/0x120=0D
 [<ffffffff811496c3>] try_charge+0x163/0x700=0D
 [<ffffffff81149cb4>] mem_cgroup_do_precharge+0x54/0x70=0D
 [<ffffffff81149e45>] mem_cgroup_can_attach+0x175/0x1b0=0D
 [<ffffffff811b2c57>] ? kernfs_iattrs.isra.6+0x37/0xd0=0D
 [<ffffffff81148e70>] ? get_mctgt_type+0x320/0x320=0D
 [<ffffffff810a9d29>] cgroup_migrate+0x149/0x440=0D
 [<ffffffff810aa60c>] cgroup_attach_task+0x7c/0xe0=0D
 [<ffffffff810aa904>] __cgroup_procs_write.isra.33+0x1d4/0x2b0=0D
 [<ffffffff810aaa10>] cgroup_tasks_write+0x10/0x20=0D
 [<ffffffff810a6238>] cgroup_file_write+0x38/0xf0=0D
 [<ffffffff811b54ad>] kernfs_fop_write+0x11d/0x170=0D
 [<ffffffff81153918>] __vfs_write+0x28/0xe0=0D
 [<ffffffff8116e614>] ? __fd_install+0x24/0xc0=0D
 [<ffffffff810784a1>] ? percpu_down_read+0x21/0x50=0D
 [<ffffffff81153e91>] vfs_write+0xa1/0x170=0D
 [<ffffffff81154716>] SyS_write+0x46/0xa0=0D
 [<ffffffff81420a17>] entry_SYSCALL_64_fastpath+0x12/0x6a=0D
Code: 5e 82 3a 00 48 83 c4 08 5b 5d c3 48 89 45 f0 e8 9b 6a 3a 00 48 8b 45 =
f0 eb df 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 55 48 89 e5 <48> 8b 07 48 8=
9 c2 48 83 c2 01 7e 07 f0 48 0f b1 17 75 f0 48 f7 =0D
RIP  [<ffffffff810782a9>] down_read_trylock+0x9/0x30=0D
 RSP <ffff88007fea3648>=0D
CR2: 0000000000000008=0D
BUG: unable to handle kernel ---[ end trace e81a82c8122b447d ]---=0D
Kernel panic - not syncing: Fatal exception=0D
=0D
NULL pointer dereference at 0000000000000008=0D
IP: [<ffffffff810782a9>] down_read_trylock+0x9/0x30=0D
PGD 0 =0D
Oops: 0000 [#2] SMP =0D
Dumping ftrace buffer:=0D
   (ftrace buffer empty)=0D
Modules linked in:=0D
CPU: 10 PID: 59 Comm: khugepaged Tainted: G      D         4.3.0-rc5-mm1-di=
et-meta+ #1545=0D
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/201=
1=0D
task: ffff8800b9851a40 ti: ffff8800b985c000 task.ti: ffff8800b985c000=0D
RIP: 0010:[<ffffffff810782a9>]  [<ffffffff810782a9>] down_read_trylock+0x9/=
0x30=0D
RSP: 0018:ffff8800b985f778  EFLAGS: 00010202=0D
RAX: 0000000000000001 RBX: ffffea0002321800 RCX: ffff8800b985f918=0D
RDX: 0000000000000000 RSI: ffff8800b985f818 RDI: 0000000000000008=0D
RBP: ffff8800b985f778 R08: ffffffff818446a0 R09: ffff8800b9853240=0D
R10: 000000000000ba03 R11: 0000000000000001 R12: ffff88007f58d6e1=0D
R13: ffff88007f58d6e0 R14: 0000000000000008 R15: 0000000000000001=0D
FS:  0000000000000000(0000) GS:ffff8800bfb40000(0000) knlGS:000000000000000=
0=0D
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b=0D
CR2: 0000000000000008 CR3: 0000000001808000 CR4: 00000000000006a0=0D
Stack:=0D
 ffff8800b985f7a8 ffffffff81124ff0 ffffea0002321800 ffff8800b985f818=0D
 ffff88009ffe8400 0000000000000000 ffff8800b985f7f0 ffffffff81125733=0D
 ffff8800bfb54540 ffffffff8105dc9d ffffea0002321800 ffff8800b985f918=0D
Call Trace:=0D
 [<ffffffff81124ff0>] page_lock_anon_vma_read+0x60/0x180=0D
 [<ffffffff81125733>] rmap_walk+0x1b3/0x3f0=0D
 [<ffffffff8105dc9d>] ? finish_task_switch+0x5d/0x1f0=0D
 [<ffffffff81125b13>] page_referenced+0x1a3/0x220=0D
 [<ffffffff81123e30>] ? __page_check_address+0x1a0/0x1a0=0D
 [<ffffffff81124f90>] ? page_get_anon_vma+0xd0/0xd0=0D
 [<ffffffff81123820>] ? anon_vma_ctor+0x40/0x40=0D
 [<ffffffff8110087b>] shrink_page_list+0x5ab/0xde0=0D
 [<ffffffff8110174c>] shrink_inactive_list+0x18c/0x4b0=0D
 [<ffffffff811023bd>] shrink_lruvec+0x59d/0x740=0D
 [<ffffffff811025f0>] shrink_zone+0x90/0x250=0D
 [<ffffffff811028dd>] do_try_to_free_pages+0x12d/0x3b0=0D
 [<ffffffff81102d3d>] try_to_free_mem_cgroup_pages+0x9d/0x120=0D
 [<ffffffff811496c3>] try_charge+0x163/0x700=0D
 [<ffffffff8141d1f3>] ? schedule+0x33/0x80=0D
 [<ffffffff8114d45f>] mem_cgroup_try_charge+0x9f/0x1d0=0D
 [<ffffffff811434bc>] khugepaged+0x7cc/0x1ac0=0D
 [<ffffffff81066e01>] ? hrtick_update+0x1/0x70=0D
 [<ffffffff81072430>] ? prepare_to_wait_event+0xf0/0xf0=0D
 [<ffffffff81142cf0>] ? total_mapcount+0x70/0x70=0D
 [<ffffffff81056cd9>] kthread+0xc9/0xe0=0D
 [<ffffffff81056c10>] ? kthread_park+0x60/0x60=0D
 [<ffffffff81420d6f>] ret_from_fork+0x3f/0x70=0D
 [<ffffffff81056c10>] ? kthread_park+0x60/0x60=0D
Code: 5e 82 3a 00 48 83 c4 08 5b 5d c3 48 89 45 f0 e8 9b 6a 3a 00 48 8b 45 =
f0 eb df 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 55 48 89 e5 <48> 8b 07 48 8=
9 c2 48 83 c2 01 7e 07 f0 48 0f b1 17 75 f0 48 f7 =0D
RIP  [<ffffffff810782a9>] down_read_trylock+0x9/0x30=0D
 RSP <ffff8800b985f778>=0D
CR2: 0000000000000008=0D
---[ end trace e81a82c8122b447e ]---=0D
Shutting down cpus with NMI=0D
Dumping ftrace buffer:=0D
   (ftrace buffer empty)=0D
Kernel Offset: disabled=0D

--f+W+jCU1fRNres8c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
