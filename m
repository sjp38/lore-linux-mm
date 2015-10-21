Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 60D8B6B0038
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 07:07:28 -0400 (EDT)
Received: by wijp11 with SMTP id p11so89227740wij.0
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 04:07:27 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com. [209.85.212.178])
        by mx.google.com with ESMTPS id bq7si17075402wib.122.2015.10.21.04.07.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 04:07:26 -0700 (PDT)
Received: by wicll6 with SMTP id ll6so85454475wic.0
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 04:07:25 -0700 (PDT)
Date: Wed, 21 Oct 2015 14:07:23 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: kernel oops on mmotm-2015-10-15-15-20
Message-ID: <20151021110723.GC10597@node.shutemov.name>
References: <20151021052836.GB6024@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20151021052836.GB6024@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

On Wed, Oct 21, 2015 at 02:28:36PM +0900, Minchan Kim wrote:
> I detach this report from my patchset thread because I see below
> problem with removing MADV_FREE related code and I can reproduce
> same oops with MADV_FREE + recent patches(both my SetPageDirty
> and Kirill's pte_mkdirty) within 7 hours.

Could you share code for your workload?

> I can not be sure it's THP refcount redesign's problem but it was
> one of big change in MM between mmotm-2015-10-15-15-20 and
> mmotm-2015-10-06-16-30 so it could be a culprit.
>=20
> In page_lock_anon_vma_read, anon_vma_root was NULL.
> I added VM_BUG_ON_PAGE(!root_anon_vma, page) in there and got the result.

Hm. That's tricky.. :-/

Could you please dump anon_vma->refcount too?

I have vage suspicion that I'm screwing up anon_vma refcounting during
split_huge_page.

It would be great to see if the page was part of THP before.

>=20
> ..
> ..
> Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k=
 FS
> page:ffffea0001b81140 count:3 mapcount:1 mapping:ffff88007e806461 index:0=
x600001445
> page:ffffea0001b87bc0 count:3 mapcount:1 mapping:ffff88007e806461 index:0=
x6000015ef
> flags: 0x4000000000048019(locked|uptodate|dirty|swapcache|swapbacked)
> page dumped because: VM_BUG_ON_PAGE(1)
> page->mem_cgroup:ffff88007f2de000
> ------------[ cut here ]------------
> kernel BUG at mm/rmap.c:517!
> invalid opcode: 0000 [#1] SMP=20
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 0 PID: 24935 Comm: madvise_test Not tainted 4.3.0-rc5-mm1-THP-ref-ma=
dv_free+ #1555
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2=
011
> task: ffff880000ce8000 ti: ffff8800ada28000 task.ti: ffff8800ada28000
> RIP: 0010:[<ffffffff81128f6e>]  [<ffffffff81128f6e>] page_lock_anon_vma_r=
ead+0x18e/0x190
> RSP: 0000:ffff8800ada2b868  EFLAGS: 00010296
> RAX: 0000000000000021 RBX: ffffea0001b87bc0 RCX: 0000000000000000
> RDX: 0000000000000001 RSI: 0000000000000282 RDI: ffffffff81830db0
> RBP: ffff8800ada2b888 R08: 0000000000000021 R09: ffff8800ba40eb75
> R10: 0000000001ff14bc R11: 0000000000000000 R12: ffff88007e806461
> R13: ffff88007e806460 R14: 0000000000000000 R15: ffffffff818464c0
> FS:  00007f6d93212740(0000) GS:ffff8800bfa00000(0000) knlGS:0000000000000=
000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000600003c14000 CR3: 00000000a674b000 CR4: 00000000000006b0
> Stack:
>  ffffea0001b87bc0 ffff8800ada2b8f8 ffff88007f2de000 0000000000000000
>  ffff8800ada2b8d0 ffffffff81129593 ffff880000000000 ffffffff8105f8c0
>  ffffea0001b87bc0 ffff8800ada2b9f8 ffff88007f2de000 0000000000000000
> Call Trace:
>  [<ffffffff81129593>] rmap_walk+0x1b3/0x3f0
>  [<ffffffff8105f8c0>] ? finish_task_switch+0x70/0x260
>  [<ffffffff81129973>] page_referenced+0x1a3/0x220
>  [<ffffffff81127c10>] ? __page_check_address+0x1d0/0x1d0
>  [<ffffffff81128de0>] ? page_get_anon_vma+0xd0/0xd0
>  [<ffffffff81127580>] ? anon_vma_ctor+0x40/0x40
>  [<ffffffff81103e9e>] shrink_page_list+0x5ce/0xdc0
>  [<ffffffff81104d4c>] shrink_inactive_list+0x18c/0x4b0
>  [<ffffffff811059af>] shrink_lruvec+0x58f/0x730
>  [<ffffffff81105c24>] shrink_zone+0xd4/0x280
>  [<ffffffff81105efd>] do_try_to_free_pages+0x12d/0x3b0
>  [<ffffffff8110635d>] try_to_free_mem_cgroup_pages+0x9d/0x120
>  [<ffffffff8114e235>] try_charge+0x175/0x720
>  [<ffffffff810fdf80>] ? __activate_page+0x230/0x230
>  [<ffffffff81152005>] mem_cgroup_try_charge+0x85/0x1d0
>  [<ffffffff8111e69a>] handle_mm_fault+0xc9a/0x1000
>  [<ffffffff8106215b>] ? __set_cpus_allowed_ptr+0x9b/0x1a0
>  [<ffffffff81033629>] __do_page_fault+0x189/0x400
>  [<ffffffff810338ac>] do_page_fault+0xc/0x10
>  [<ffffffff81428782>] page_fault+0x22/0x30
> Code: c9 0f 84 b9 fe ff ff 8d 51 01 89 c8 f0 0f b1 16 39 c1 0f 84 11 ff f=
f ff 89 c1 eb e3 48 c7 c6 88 02 78 81 48 89 df e8 02 f3 fe ff <0f> 0b 0f 1f=
 44 00 00 55 48 89 e5 41 57 41 56 45 31 f6=20
> 41 55 4c=20
> RIP  [<ffffffff81128f6e>] page_lock_anon_vma_read+0x18e/0x190
>  RSP <ffff8800ada2b868>
> ---[ end trace cfbb87f54f12290e ]---
> Kernel panic - not syncing: Fatal exception
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Kernel Offset: disabled
>=20
> On Tue, Oct 20, 2015 at 10:38:54AM +0900, Minchan Kim wrote:
> > On Mon, Oct 19, 2015 at 07:01:50PM +0900, Minchan Kim wrote:
> > > On Mon, Oct 19, 2015 at 03:31:42PM +0900, Minchan Kim wrote:
> > > > Hello, it's too late since I sent previos patch.
> > > > https://lkml.org/lkml/2015/6/3/37
> > > >=20
> > > > This patch is alomost new compared to previos approach.
> > > > I think this is more simple, clear and easy to review.
> > > >=20
> > > > One thing I should notice is that I have tested this patch
> > > > and couldn't find any critical problem so I rebased patchset
> > > > onto recent mmotm(ie, mmotm-2015-10-15-15-20) to send formal
> > > > patchset. Unfortunately, I start to see sudden discarding of
> > > > the page we shouldn't do. IOW, application's valid anonymous page
> > > > was disappeared suddenly.
> > > >=20
> > > > When I look through THP changes, I think we could lose
> > > > dirty bit of pte between freeze_page and unfreeze_page
> > > > when we mark it as migration entry and restore it.
> > > > So, I added below simple code without enough considering
> > > > and cannot see the problem any more.
> > > > I hope it's good hint to find right fix this problem.
> > > >=20
> > > > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > > > index d5ea516ffb54..e881c04f5950 100644
> > > > --- a/mm/huge_memory.c
> > > > +++ b/mm/huge_memory.c
> > > > @@ -3138,6 +3138,9 @@ static void unfreeze_page_vma(struct vm_area_=
struct *vma, struct page *page,
> > > >  		if (is_write_migration_entry(swp_entry))
> > > >  			entry =3D maybe_mkwrite(entry, vma);
> > > > =20
> > > > +		if (PageDirty(page))
> > > > +			SetPageDirty(page);
> > >=20
> > > The condition of PageDirty was typo. I didn't add the condition.
> > > Just added.
> > >=20
> > >                 SetPageDirty(page);
> >=20
> > For the first step to find this bug, I removed all MADV_FREE related
> > code in mmotm-2015-10-15-15-20. IOW, git checkout 54bad5da4834
> > (arm64: add pmd_[dirty|mkclean] for THP) so the tree doesn't have
> > any core code of MADV_FREE.
> >=20
> > I tested following workloads in my KVM machine.
> >=20
> > 0. make memcg
> > 1. limit memcg
> > 2. fork several processes
> > 3. each process allocates THP page and fill
> > 4. increase limit of the memcg to swapoff successfully
> > 5. swapoff
> > 6. kill all of processes
> > 7. goto 1
> >=20
> > Within a few hours, I encounter following bug.
> > Attached detailed boot log and dmesg result.
> >=20
> >=20
> > Initializing cgroup subsys cpu
> > Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200 debug apic=
=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D100 panic=3D=
-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic console=3DttyS0,1=
15200 console=3Dtty0 earlyprintk=3DttyS0 ignore_loglevel ftrace_dump_on_oop=
s vga=3Dnormal root=3D/dev/vda1 rw
> > KERNEL supported cpus:
> >   Intel GenuineIntel
> > x86/fpu: Legacy x87 FPU detected.
> > x86/fpu: Using 'lazy' FPU context switches.
> > e820: BIOS-provided physical RAM map:
> > BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
> > BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
> > BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
> > BIOS-e820: [mem 0x0000000000100000-0x00000000bfffbfff] usable
> > BIOS-e820: [mem 0x00000000bfffc000-0x00000000bfffffff] reserved
> > BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
> > BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
> >=20
> > <snip>
> >=20
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > BUG: unable to handle kernel NULL pointer dereference at 00000000000000=
08
> > IP: [<ffffffff810782a9>] down_read_trylock+0x9/0x30
> > PGD 0=20
> > Oops: 0000 [#1] SMP=20
> > Dumping ftrace buffer:
> >    (ftrace buffer empty)
> > Modules linked in:
> > CPU: 1 PID: 26445 Comm: sh Not tainted 4.3.0-rc5-mm1-diet-meta+ #1545
> > Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01=
/2011
> > task: ffff8800b9af3480 ti: ffff88007fea0000 task.ti: ffff88007fea0000
> > RIP: 0010:[<ffffffff810782a9>]  [<ffffffff810782a9>] down_read_trylock+=
0x9/0x30
> > RSP: 0018:ffff88007fea3648  EFLAGS: 00010202
> > RAX: 0000000000000001 RBX: ffffea0002324900 RCX: ffff88007fea37e8
> > RDX: 0000000000000000 RSI: ffff88007fea36e8 RDI: 0000000000000008
> > RBP: ffff88007fea3648 R08: ffffffff818446a0 R09: ffff8800b9af4c80
> > R10: 0000000000000216 R11: 0000000000000001 R12: ffff88007f58d6e1
> > R13: ffff88007f58d6e0 R14: 0000000000000008 R15: 0000000000000001
> > FS:  00007f0993e78740(0000) GS:ffff8800bfa20000(0000) knlGS:00000000000=
00000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > CR2: 0000000000000008 CR3: 000000007edee000 CR4: 00000000000006a0
> > Stack:
> >  ffff88007fea3678 ffffffff81124ff0 ffffea0002324900 ffff88007fea36e8
> >  ffff88009ffe8400 0000000000000000 ffff88007fea36c0 ffffffff81125733
> >  ffff8800bfa34540 ffffffff8105dc9d ffffea0002324900 ffff88007fea37e8
> > Call Trace:
> >  [<ffffffff81124ff0>] page_lock_anon_vma_read+0x60/0x180
> >  [<ffffffff81125733>] rmap_walk+0x1b3/0x3f0
> >  [<ffffffff8105dc9d>] ? finish_task_switch+0x5d/0x1f0
> >  [<ffffffff81125b13>] page_referenced+0x1a3/0x220
> >  [<ffffffff81123e30>] ? __page_check_address+0x1a0/0x1a0
> >  [<ffffffff81124f90>] ? page_get_anon_vma+0xd0/0xd0
> >  [<ffffffff81123820>] ? anon_vma_ctor+0x40/0x40
> >  [<ffffffff8110087b>] shrink_page_list+0x5ab/0xde0
> >  [<ffffffff8110174c>] shrink_inactive_list+0x18c/0x4b0
> >  [<ffffffff811023bd>] shrink_lruvec+0x59d/0x740
> >  [<ffffffff811025f0>] shrink_zone+0x90/0x250
> >  [<ffffffff811028dd>] do_try_to_free_pages+0x12d/0x3b0
> >  [<ffffffff81102d3d>] try_to_free_mem_cgroup_pages+0x9d/0x120
> >  [<ffffffff811496c3>] try_charge+0x163/0x700
> >  [<ffffffff81149cb4>] mem_cgroup_do_precharge+0x54/0x70
> >  [<ffffffff81149e45>] mem_cgroup_can_attach+0x175/0x1b0
> >  [<ffffffff811b2c57>] ? kernfs_iattrs.isra.6+0x37/0xd0
> >  [<ffffffff81148e70>] ? get_mctgt_type+0x320/0x320
> >  [<ffffffff810a9d29>] cgroup_migrate+0x149/0x440
> >  [<ffffffff810aa60c>] cgroup_attach_task+0x7c/0xe0
> >  [<ffffffff810aa904>] __cgroup_procs_write.isra.33+0x1d4/0x2b0
> >  [<ffffffff810aaa10>] cgroup_tasks_write+0x10/0x20
> >  [<ffffffff810a6238>] cgroup_file_write+0x38/0xf0
> >  [<ffffffff811b54ad>] kernfs_fop_write+0x11d/0x170
> >  [<ffffffff81153918>] __vfs_write+0x28/0xe0
> >  [<ffffffff8116e614>] ? __fd_install+0x24/0xc0
> >  [<ffffffff810784a1>] ? percpu_down_read+0x21/0x50
> >  [<ffffffff81153e91>] vfs_write+0xa1/0x170
> >  [<ffffffff81154716>] SyS_write+0x46/0xa0
> >  [<ffffffff81420a17>] entry_SYSCALL_64_fastpath+0x12/0x6a
> > Code: 5e 82 3a 00 48 83 c4 08 5b 5d c3 48 89 45 f0 e8 9b 6a 3a 00 48 8b=
 45 f0 eb df 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 55 48 89 e5 <48> 8b 07 =
48 89 c2 48 83 c2 01 7e 07 f0 48 0f b1 17 75 f0 48 f7=20
> > RIP  [<ffffffff810782a9>] down_read_trylock+0x9/0x30
> >  RSP <ffff88007fea3648>
> > CR2: 0000000000000008
> > BUG: unable to handle kernel ---[ end trace e81a82c8122b447d ]---
> > Kernel panic - not syncing: Fatal exception
> >=20
> > NULL pointer dereference at 0000000000000008
> > IP: [<ffffffff810782a9>] down_read_trylock+0x9/0x30
> > PGD 0=20
> > Oops: 0000 [#2] SMP=20
> > Dumping ftrace buffer:
> >    (ftrace buffer empty)
> > Modules linked in:
> > CPU: 10 PID: 59 Comm: khugepaged Tainted: G      D         4.3.0-rc5-mm=
1-diet-meta+ #1545
> > Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01=
/2011
> > task: ffff8800b9851a40 ti: ffff8800b985c000 task.ti: ffff8800b985c000
> > RIP: 0010:[<ffffffff810782a9>]  [<ffffffff810782a9>] down_read_trylock+=
0x9/0x30
> > RSP: 0018:ffff8800b985f778  EFLAGS: 00010202
> > RAX: 0000000000000001 RBX: ffffea0002321800 RCX: ffff8800b985f918
> > RDX: 0000000000000000 RSI: ffff8800b985f818 RDI: 0000000000000008
> > RBP: ffff8800b985f778 R08: ffffffff818446a0 R09: ffff8800b9853240
> > R10: 000000000000ba03 R11: 0000000000000001 R12: ffff88007f58d6e1
> > R13: ffff88007f58d6e0 R14: 0000000000000008 R15: 0000000000000001
> > FS:  0000000000000000(0000) GS:ffff8800bfb40000(0000) knlGS:00000000000=
00000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > CR2: 0000000000000008 CR3: 0000000001808000 CR4: 00000000000006a0
> > Stack:
> >  ffff8800b985f7a8 ffffffff81124ff0 ffffea0002321800 ffff8800b985f818
> >  ffff88009ffe8400 0000000000000000 ffff8800b985f7f0 ffffffff81125733
> >  ffff8800bfb54540 ffffffff8105dc9d ffffea0002321800 ffff8800b985f918
> > Call Trace:
> >  [<ffffffff81124ff0>] page_lock_anon_vma_read+0x60/0x180
> >  [<ffffffff81125733>] rmap_walk+0x1b3/0x3f0
> >  [<ffffffff8105dc9d>] ? finish_task_switch+0x5d/0x1f0
> >  [<ffffffff81125b13>] page_referenced+0x1a3/0x220
> >  [<ffffffff81123e30>] ? __page_check_address+0x1a0/0x1a0
> >  [<ffffffff81124f90>] ? page_get_anon_vma+0xd0/0xd0
> >  [<ffffffff81123820>] ? anon_vma_ctor+0x40/0x40
> >  [<ffffffff8110087b>] shrink_page_list+0x5ab/0xde0
> >  [<ffffffff8110174c>] shrink_inactive_list+0x18c/0x4b0
> >  [<ffffffff811023bd>] shrink_lruvec+0x59d/0x740
> >  [<ffffffff811025f0>] shrink_zone+0x90/0x250
> >  [<ffffffff811028dd>] do_try_to_free_pages+0x12d/0x3b0
> >  [<ffffffff81102d3d>] try_to_free_mem_cgroup_pages+0x9d/0x120
> >  [<ffffffff811496c3>] try_charge+0x163/0x700
> >  [<ffffffff8141d1f3>] ? schedule+0x33/0x80
> >  [<ffffffff8114d45f>] mem_cgroup_try_charge+0x9f/0x1d0
> >  [<ffffffff811434bc>] khugepaged+0x7cc/0x1ac0
> >  [<ffffffff81066e01>] ? hrtick_update+0x1/0x70
> >  [<ffffffff81072430>] ? prepare_to_wait_event+0xf0/0xf0
> >  [<ffffffff81142cf0>] ? total_mapcount+0x70/0x70
> >  [<ffffffff81056cd9>] kthread+0xc9/0xe0
> >  [<ffffffff81056c10>] ? kthread_park+0x60/0x60
> >  [<ffffffff81420d6f>] ret_from_fork+0x3f/0x70
> >  [<ffffffff81056c10>] ? kthread_park+0x60/0x60
> > Code: 5e 82 3a 00 48 83 c4 08 5b 5d c3 48 89 45 f0 e8 9b 6a 3a 00 48 8b=
 45 f0 eb df 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 55 48 89 e5 <48> 8b 07 =
48 89 c2 48 83 c2 01 7e 07 f0 48 0f b1 17 75 f0 48 f7=20
> > RIP  [<ffffffff810782a9>] down_read_trylock+0x9/0x30
> >  RSP <ffff8800b985f778>
> > CR2: 0000000000000008
> > ---[ end trace e81a82c8122b447e ]---
> > Shutting down cpus with NMI
> > Dumping ftrace buffer:
> >    (ftrace buffer empty)
> > Kernel Offset: disabled
> >=20
>=20
> > QEMU 2.0.0 monitor - type 'help' for more information
> > (qemu) s=1B[Kearly console in setup code
> > Initializing cgroup subsys cpu
> > Linux version 4.3.0-rc5-mm1-diet-meta+ (barrios@bbox) (gcc version 4.8.=
4 (Ubuntu 4.8.4-2ubuntu1~14.04) ) #1545 SMP Tue Oct 20 08:55:45 KST 2015
> > Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200 debug apic=
=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D100 panic=3D=
-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic console=3DttyS0,1=
15200 console=3Dtty0 earlyprintk=3DttyS0 ignore_loglevel ftrace_dump_on_oop=
s vga=3Dnormal root=3D/dev/vda1 rw
> > KERNEL supported cpus:
> >   Intel GenuineIntel
> > x86/fpu: Legacy x87 FPU detected.
> > x86/fpu: Using 'lazy' FPU context switches.
> > e820: BIOS-provided physical RAM map:
> > BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
> > BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
> > BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
> > BIOS-e820: [mem 0x0000000000100000-0x00000000bfffbfff] usable
> > BIOS-e820: [mem 0x00000000bfffc000-0x00000000bfffffff] reserved
> > BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
> > BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
> > bootconsole [earlyser0] enabled
> > debug: ignoring loglevel setting.
> > NX (Execute Disable) protection: active
> > SMBIOS 2.4 present.
> > DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> > e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> reserved
> > e820: remove [mem 0x000a0000-0x000fffff] usable
> > e820: last_pfn =3D 0xbfffc max_arch_pfn =3D 0x400000000
> > MTRR default type: write-back
> > MTRR fixed ranges enabled:
> >   00000-9FFFF write-back
> >   A0000-BFFFF uncachable
> >   C0000-FFFFF write-protect
> > MTRR variable ranges enabled:
> >   0 base 00C0000000 mask FFC0000000 uncachable
> >   1 disabled
> >   2 disabled
> >   3 disabled
> >   4 disabled
> >   5 disabled
> >   6 disabled
> >   7 disabled
> > x86/PAT: PAT not supported by CPU.
> > Scan for SMP in [mem 0x00000000-0x000003ff]
> > Scan for SMP in [mem 0x0009fc00-0x0009ffff]
> > Scan for SMP in [mem 0x000f0000-0x000fffff]
> > found SMP MP-table at [mem 0x000f0a70-0x000f0a7f] mapped at [ffff880000=
0f0a70]
> >   mpc: f0a80-f0c44
> > Scanning 1 areas for low memory corruption
> > Base memory trampoline at [ffff880000099000] 99000 size 24576
> > init_memory_mapping: [mem 0x00000000-0x000fffff]
> >  [mem 0x00000000-0x000fffff] page 4k
> > BRK [0x0220e000, 0x0220efff] PGTABLE
> > BRK [0x0220f000, 0x0220ffff] PGTABLE
> > BRK [0x02210000, 0x02210fff] PGTABLE
> > init_memory_mapping: [mem 0xbfc00000-0xbfdfffff]
> >  [mem 0xbfc00000-0xbfdfffff] page 2M
> > BRK [0x02211000, 0x02211fff] PGTABLE
> > init_memory_mapping: [mem 0xa0000000-0xbfbfffff]
> >  [mem 0xa0000000-0xbfbfffff] page 2M
> > init_memory_mapping: [mem 0x80000000-0x9fffffff]
> >  [mem 0x80000000-0x9fffffff] page 2M
> > init_memory_mapping: [mem 0x00100000-0x7fffffff]
> >  [mem 0x00100000-0x001fffff] page 4k
> >  [mem 0x00200000-0x7fffffff] page 2M
> > init_memory_mapping: [mem 0xbfe00000-0xbfffbfff]
> >  [mem 0xbfe00000-0xbfffbfff] page 4k
> > BRK [0x02212000, 0x02212fff] PGTABLE
> > RAMDISK: [mem 0x7851a000-0x7fffffff]
> >  [ffffea0000000000-ffffea0002ffffff] PMD -> [ffff8800bc400000-ffff8800b=
f3fffff] on node 0
> > Zone ranges:
> >   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
> >   DMA32    [mem 0x0000000001000000-0x00000000bfffbfff]
> >   Normal   empty
> > Movable zone start for each node
> > Early memory node ranges
> >   node   0: [mem 0x0000000000001000-0x000000000009efff]
> >   node   0: [mem 0x0000000000100000-0x00000000bfffbfff]
> > Initmem setup node 0 [mem 0x0000000000001000-0x00000000bfffbfff]
> > On node 0 totalpages: 786330
> >   DMA zone: 64 pages used for memmap
> >   DMA zone: 21 pages reserved
> >   DMA zone: 3998 pages, LIFO batch:0
> >   DMA32 zone: 12224 pages used for memmap
> >   DMA32 zone: 782332 pages, LIFO batch:31
> > Intel MultiProcessor Specification v1.4
> >   mpc: f0a80-f0c44
> > MPTABLE: OEM ID: BOCHSCPU
> > MPTABLE: Product ID: 0.1        =20
> > MPTABLE: APIC at: 0xFEE00000
> > mapped APIC to ffffffffff5fd000 (        fee00000)
> > Processor #0 (Bootup-CPU)
> > Processor #1
> > Processor #2
> > Processor #3
> > Processor #4
> > Processor #5
> > Processor #6
> > Processor #7
> > Processor #8
> > Processor #9
> > Processor #10
> > Processor #11
> > Bus #0 is PCI  =20
> > Bus #1 is ISA  =20
> > IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-23
> > Int: type 0, pol 1, trig 0, bus 00, IRQ 04, APIC ID 0, APIC INT 09
> > Int: type 0, pol 1, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC INT 0b
> > Int: type 0, pol 1, trig 0, bus 00, IRQ 10, APIC ID 0, APIC INT 0b
> > Int: type 0, pol 1, trig 0, bus 00, IRQ 14, APIC ID 0, APIC INT 0a
> > Int: type 0, pol 1, trig 0, bus 00, IRQ 18, APIC ID 0, APIC INT 0a
> > Int: type 0, pol 0, trig 0, bus 01, IRQ 00, APIC ID 0, APIC INT 02
> > Int: type 0, pol 0, trig 0, bus 01, IRQ 01, APIC ID 0, APIC INT 01
> > Int: type 0, pol 0, trig 0, bus 01, IRQ 03, APIC ID 0, APIC INT 03
> > Int: type 0, pol 0, trig 0, bus 01, IRQ 04, APIC ID 0, APIC INT 04
> > Int: type 0, pol 0, trig 0, bus 01, IRQ 06, APIC ID 0, APIC INT 06
> > Int: type 0, pol 0, trig 0, bus 01, IRQ 07, APIC ID 0, APIC INT 07
> > Int: type 0, pol 0, trig 0, bus 01, IRQ 08, APIC ID 0, APIC INT 08
> > Int: type 0, pol 0, trig 0, bus 01, IRQ 0c, APIC ID 0, APIC INT 0c
> > Int: type 0, pol 0, trig 0, bus 01, IRQ 0d, APIC ID 0, APIC INT 0d
> > Int: type 0, pol 0, trig 0, bus 01, IRQ 0e, APIC ID 0, APIC INT 0e
> > Int: type 0, pol 0, trig 0, bus 01, IRQ 0f, APIC ID 0, APIC INT 0f
> > Lint: type 3, pol 0, trig 0, bus 01, IRQ 00, APIC ID 0, APIC LINT 00
> > Lint: type 1, pol 0, trig 0, bus 01, IRQ 00, APIC ID ff, APIC LINT 01
> > Processors: 12
> > smpboot: Allowing 12 CPUs, 0 hotplug CPUs
> > mapped IOAPIC to ffffffffff5fc000 (fec00000)
> > e820: [mem 0xc0000000-0xfeffbfff] available for PCI devices
> > clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, =
max_idle_ns: 7645519600211568 ns
> > setup_percpu: NR_CPUS:16 nr_cpumask_bits:16 nr_cpu_ids:12 nr_node_ids:1
> > PERCPU: Embedded 31 pages/cpu @ffff8800bfa00000 s87640 r8192 d31144 u13=
1072
> > pcpu-alloc: s87640 r8192 d31144 u131072 alloc=3D1*2097152
> > pcpu-alloc: [0] 00 01 02 03 04 05 06 07 08 09 10 11 -- -- -- --=20
> > Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 77=
4021
> > Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200 deb=
ug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D100 p=
anic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic console=3D=
ttyS0,115200 console=3Dtty0 earlyprintk=3DttyS0 ignore_loglevel ftrace_dump=
_on_oops vga=3Dnormal root=3D/dev/vda1 rw
> > sysrq: sysrq always enabled.
> > log_buf_len individual max cpu contribution: 2097152 bytes
> > log_buf_len total cpu_extra contributions: 23068672 bytes
> > log_buf_len min size: 8388608 bytes
> > log_buf_len: 33554432 bytes
> > early log buf free: 8380096(99%)
> > PID hash table entries: 4096 (order: 3, 32768 bytes)
> > Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
> > Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
> > Memory: 2911172K/3145320K available (4237K kernel code, 721K rwdata, 19=
88K rodata, 936K init, 8608K bss, 234148K reserved, 0K cma-reserved)
> > SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D12, Nodes=3D1
> > Hierarchical RCU implementation.
> > 	Build-time adjustment of leaf fanout to 64.
> > 	RCU restricting CPUs from NR_CPUS=3D16 to nr_cpu_ids=3D12.
> > RCU: Adjusting geometry for rcu_fanout_leaf=3D64, nr_cpu_ids=3D12
> > NR_IRQS:4352 nr_irqs:136 16
> > Console: colour VGA+ 80x25
> > console [tty0] enabled
> > bootconsole [earlyser0] disabled
> > Initializing cgroup subsys cpu
> > Linux version 4.3.0-rc5-mm1-diet-meta+ (barrios@bbox) (gcc version 4.8.=
4 (Ubuntu 4.8.4-2ubuntu1~14.04) ) #1545 SMP Tue Oct 20 08:55:45 KST 2015
> > Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200 debug apic=
=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D100 panic=3D=
-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic console=3DttyS0,1=
15200 console=3Dtty0 earlyprintk=3DttyS0 ignore_loglevel ftrace_dump_on_oop=
s vga=3Dnormal root=3D/dev/vda1 rw
> > KERNEL supported cpus:
> >   Intel GenuineIntel
> > x86/fpu: Legacy x87 FPU detected.
> > x86/fpu: Using 'lazy' FPU context switches.
> > e820: BIOS-provided physical RAM map:
> > BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
> > BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
> > BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
> > BIOS-e820: [mem 0x0000000000100000-0x00000000bfffbfff] usable
> > BIOS-e820: [mem 0x00000000bfffc000-0x00000000bfffffff] reserved
> > BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
> > BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
> > bootconsole [earlyser0] enabled
> > debug: ignoring loglevel setting.
> > NX (Execute Disable) protection: active
> > SMBIOS 2.4 present.
> > DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> > e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> reserved
> > e820: remove [mem 0x000a0000-0x000fffff] usable
> > e820: last_pfn =3D 0xbfffc max_arch_pfn =3D 0x400000000
> > MTRR default type: write-back
> > MTRR fixed ranges enabled:
> >   00000-9FFFF write-back
> >   A0000-BFFFF uncachable
> >   C0000-FFFFF write-protect
> > MTRR variable ranges enabled:
> >   0 base 00C0000000 mask FFC0000000 uncachable
> >   1 disabled
> >   2 disabled
> >   3 disabled
> >   4 disabled
> >   5 disabled
> >   6 disabled
> >   7 disabled
> > x86/PAT: PAT not supported by CPU.
> > Scan for SMP in [mem 0x00000000-0x000003ff]
> > Scan for SMP in [mem 0x0009fc00-0x0009ffff]
> > Scan for SMP in [mem 0x000f0000-0x000fffff]
> > found SMP MP-table at [mem 0x000f0a70-0x000f0a7f] mapped at [ffff880000=
0f0a70]
> >   mpc: f0a80-f0c44
> > Scanning 1 areas for low memory corruption
> > Base memory trampoline at [ffff880000099000] 99000 size 24576
> > init_memory_mapping: [mem 0x00000000-0x000fffff]
> >  [mem 0x00000000-0x000fffff] page 4k
> > BRK [0x0220e000, 0x0220efff] PGTABLE
> > BRK [0x0220f000, 0x0220ffff] PGTABLE
> > BRK [0x02210000, 0x02210fff] PGTABLE
> > init_memory_mapping: [mem 0xbfc00000-0xbfdfffff]
> >  [mem 0xbfc00000-0xbfdfffff] page 2M
> > BRK [0x02211000, 0x02211fff] PGTABLE
> > init_memory_mapping: [mem 0xa0000000-0xbfbfffff]
> >  [mem 0xa0000000-0xbfbfffff] page 2M
> > init_memory_mapping: [mem 0x80000000-0x9fffffff]
> >  [mem 0x80000000-0x9fffffff] page 2M
> > init_memory_mapping: [mem 0x00100000-0x7fffffff]
> >  [mem 0x00100000-0x001fffff] page 4k
> >  [mem 0x00200000-0x7fffffff] page 2M
> > init_memory_mapping: [mem 0xbfe00000-0xbfffbfff]
> >  [mem 0xbfe00000-0xbfffbfff] page 4k
> > BRK [0x02212000, 0x02212fff] PGTABLE
> > RAMDISK: [mem 0x7851a000-0x7fffffff]
> >  [ffffea0000000000-ffffea0002ffffff] PMD -> [ffff8800bc400000-ffff8800b=
f3fffff] on node 0
> > Zone ranges:
> >   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
> >   DMA32    [mem 0x0000000001000000-0x00000000bfffbfff]
> >   Normal   empty
> > Movable zone start for each node
> > Early memory node ranges
> >   node   0: [mem 0x0000000000001000-0x000000000009efff]
> >   node   0: [mem 0x0000000000100000-0x00000000bfffbfff]
> > Initmem setup node 0 [mem 0x0000000000001000-0x00000000bfffbfff]
> > On node 0 totalpages: 786330
> >   DMA zone: 64 pages used for memmap
> >   DMA zone: 21 pages reserved
> >   DMA zone: 3998 pages, LIFO batch:0
> >   DMA32 zone: 12224 pages used for memmap
> >   DMA32 zone: 782332 pages, LIFO batch:31
> > Intel MultiProcessor Specification v1.4
> >   mpc: f0a80-f0c44
> > MPTABLE: OEM ID: BOCHSCPU
> > MPTABLE: Product ID: 0.1        =20
> > MPTABLE: APIC at: 0xFEE00000
> > mapped APIC to ffffffffff5fd000 (        fee00000)
> > Processor #0 (Bootup-CPU)
> > Processor #1
> > Processor #2
> > Processor #3
> > Processor #4
> > Processor #5
> > Processor #6
> > Processor #7
> > Processor #8
> > Processor #9
> > Processor #10
> > Processor #11
> > Bus #0 is PCI  =20
> > Bus #1 is ISA  =20
> > IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-23
> > Int: type 0, pol 1, trig 0, bus 00, IRQ 04, APIC ID 0, APIC INT 09
> > Int: type 0, pol 1, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC INT 0b
> > Int: type 0, pol 1, trig 0, bus 00, IRQ 10, APIC ID 0, APIC INT 0b
> > Int: type 0, pol 1, trig 0, bus 00, IRQ 14, APIC ID 0, APIC INT 0a
> > Int: type 0, pol 1, trig 0, bus 00, IRQ 18, APIC ID 0, APIC INT 0a
> > Int: type 0, pol 0, trig 0, bus 01, IRQ 00, APIC ID 0, APIC INT 02
> > Int: type 0, pol 0, trig 0, bus 01, IRQ 01, APIC ID 0, APIC INT 01
> > Int: type 0, pol 0, trig 0, bus 01, IRQ 03, APIC ID 0, APIC INT 03
> > Int: type 0, pol 0, trig 0, bus 01, IRQ 04, APIC ID 0, APIC INT 04
> > Int: type 0, pol 0, trig 0, bus 01, IRQ 06, APIC ID 0, APIC INT 06
> > Int: type 0, pol 0, trig 0, bus 01, IRQ 07, APIC ID 0, APIC INT 07
> > Int: type 0, pol 0, trig 0, bus 01, IRQ 08, APIC ID 0, APIC INT 08
> > Int: type 0, pol 0, trig 0, bus 01, IRQ 0c, APIC ID 0, APIC INT 0c
> > Int: type 0, pol 0, trig 0, bus 01, IRQ 0d, APIC ID 0, APIC INT 0d
> > Int: type 0, pol 0, trig 0, bus 01, IRQ 0e, APIC ID 0, APIC INT 0e
> > Int: type 0, pol 0, trig 0, bus 01, IRQ 0f, APIC ID 0, APIC INT 0f
> > Lint: type 3, pol 0, trig 0, bus 01, IRQ 00, APIC ID 0, APIC LINT 00
> > Lint: type 1, pol 0, trig 0, bus 01, IRQ 00, APIC ID ff, APIC LINT 01
> > Processors: 12
> > smpboot: Allowing 12 CPUs, 0 hotplug CPUs
> > mapped IOAPIC to ffffffffff5fc000 (fec00000)
> > e820: [mem 0xc0000000-0xfeffbfff] available for PCI devices
> > clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, =
max_idle_ns: 7645519600211568 ns
> > setup_percpu: NR_CPUS:16 nr_cpumask_bits:16 nr_cpu_ids:12 nr_node_ids:1
> > PERCPU: Embedded 31 pages/cpu @ffff8800bfa00000 s87640 r8192 d31144 u13=
1072
> > pcpu-alloc: s87640 r8192 d31144 u131072 alloc=3D1*2097152
> > pcpu-alloc: [0] 00 01 02 03 04 05 06 07 08 09 10 11 -- -- -- --=20
> > Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 77=
4021
> > Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200 deb=
ug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D100 p=
anic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic console=3D=
ttyS0,115200 console=3Dtty0 earlyprintk=3DttyS0 ignore_loglevel ftrace_dump=
_on_oops vga=3Dnormal root=3D/dev/vda1 rw
> > sysrq: sysrq always enabled.
> > log_buf_len individual max cpu contribution: 2097152 bytes
> > log_buf_len total cpu_extra contributions: 23068672 bytes
> > log_buf_len min size: 8388608 bytes
> > log_buf_len: 33554432 bytes
> > early log buf free: 8380096(99%)
> > PID hash table entries: 4096 (order: 3, 32768 bytes)
> > Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
> > Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
> > Memory: 2911172K/3145320K available (4237K kernel code, 721K rwdata, 19=
88K rodata, 936K init, 8608K bss, 234148K reserved, 0K cma-reserved)
> > SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D12, Nodes=3D1
> > Hierarchical RCU implementation.
> > 	Build-time adjustment of leaf fanout to 64.
> > 	RCU restricting CPUs from NR_CPUS=3D16 to nr_cpu_ids=3D12.
> > RCU: Adjusting geometry for rcu_fanout_leaf=3D64, nr_cpu_ids=3D12
> > NR_IRQS:4352 nr_irqs:136 16
> > Console: colour VGA+ 80x25
> > console [tty0] enabled
> > bootconsole [earlyser0] disabled
> > console [ttyS0] enabled
> > tsc: Fast TSC calibration using PIT
> > tsc: Detected 3199.926 MHz processor
> > Calibrating delay loop (skipped), value calculated using timer frequenc=
y.. 6399.85 BogoMIPS (lpj=3D12799704)
> > pid_max: default: 32768 minimum: 301
> > Mount-cache hash table entries: 8192 (order: 4, 65536 bytes)
> > Mountpoint-cache hash table entries: 8192 (order: 4, 65536 bytes)
> > Initializing cgroup subsys memory
> > Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
> > Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
> > Freeing SMP alternatives memory: 20K (ffffffff819a0000 - ffffffff819a50=
00)
> > ftrace: allocating 16664 entries in 66 pages
> > Switched APIC routing to physical flat.
> > enabled ExtINT on CPU#0
> > ENABLING IO-APIC IRQs
> > init IO_APIC IRQs
> >  apic 0 pin 0 not connected
> > IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest=
:0)
> > IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Active:0 Dest=
:0)
> > IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest=
:0)
> > IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest=
:0)
> >  apic 0 pin 5 not connected
> > IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest=
:0)
> > IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest=
:0)
> > IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest=
:0)
> > IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Active:0 Dest=
:0)
> > IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 Active:0 De=
st:0)
> > IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 Active:0 De=
st:0)
> > IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 De=
st:0)
> > IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 De=
st:0)
> > IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 Active:0 De=
st:0)
> > IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 Active:0 De=
st:0)
> >  apic 0 pin 16 not connected
> >  apic 0 pin 17 not connected
> >  apic 0 pin 18 not connected
> >  apic 0 pin 19 not connected
> >  apic 0 pin 20 not connected
> >  apic 0 pin 21 not connected
> >  apic 0 pin 22 not connected
> >  apic 0 pin 23 not connected
> > ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D-1
> > Using local APIC timer interrupts.
> > calibrating APIC timer ...
> > ... lapic delta =3D 6251755
> > ..... delta 6251755
> > ..... mult: 268510832
> > ..... calibration result: 4001123
> > ..... CPU clock speed is 3200.3592 MHz.
> > ..... host bus clock speed is 1000.1123 MHz.
> > ... verify APIC timer
> > ... jiffies delta =3D 25
> > ... jiffies result ok
> > smpboot: CPU0: Intel QEMU Virtual CPU version 2.0.0 (family: 0x6, model=
: 0x6, stepping: 0x3)
> > Performance Events: Broken PMU hardware detected, using software events=
 only.
> > Failed to access perfctr msr (MSR c2 is 0)
> > x86: Booting SMP configuration:
> > .... node  #0, CPUs:        #1
> > masked ExtINT on CPU#1
> >   #2
> > masked ExtINT on CPU#2
> >   #3
> > masked ExtINT on CPU#3
> >   #4
> > masked ExtINT on CPU#4
> >   #5
> > masked ExtINT on CPU#5
> >   #6
> > masked ExtINT on CPU#6
> >   #7
> > masked ExtINT on CPU#7
> >   #8
> > masked ExtINT on CPU#8
> >   #9
> > masked ExtINT on CPU#9
> >  #10
> > masked ExtINT on CPU#10
> >  #11
> > masked ExtINT on CPU#11
> > x86: Booted up 1 node, 12 CPUs
> > smpboot: Total of 12 processors activated (76818.13 BogoMIPS)
> > devtmpfs: initialized
> > clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle=
_ns: 7645041785100000 ns
> > NET: Registered protocol family 16
> > PCI: Using configuration type 1 for base access
> > vgaarb: loaded
> > SCSI subsystem initialized
> > libata version 3.00 loaded.
> > PCI: Probing PCI hardware
> > PCI: root bus 00: using default resources
> > PCI: Probing PCI hardware (bus 00)
> > PCI host bridge to bus 0000:00
> > pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
> > pci_bus 0000:00: root bus resource [mem 0x00000000-0xffffffffff]
> > pci_bus 0000:00: No busn resource found for root bus, will use [bus 00-=
ff]
> > pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
> > pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
> > pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
> > pci 0000:00:01.1: reg 0x20: [io  0xc0c0-0xc0cf]
> > pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
> > pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
> > pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
> > pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
> > pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
> > pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
> > pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
> > pci 0000:00:02.0: reg 0x14: [mem 0xfebd0000-0xfebd0fff]
> > pci 0000:00:02.0: reg 0x30: [mem 0xfebc0000-0xfebcffff pref]
> > vgaarb: setting as boot device: PCI:0000:00:02.0
> > vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=3Dio+mem,l=
ocks=3Dnone
> > pci 0000:00:03.0: [1af4:1000] type 00 class 0x020000
> > pci 0000:00:03.0: reg 0x10: [io  0xc080-0xc09f]
> > pci 0000:00:03.0: reg 0x14: [mem 0xfebd1000-0xfebd1fff]
> > pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff pref]
> > pci 0000:00:04.0: [1af4:1002] type 00 class 0x00ff00
> > pci 0000:00:04.0: reg 0x10: [io  0xc0a0-0xc0bf]
> > pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
> > pci 0000:00:05.0: reg 0x10: [io  0xc000-0xc03f]
> > pci 0000:00:05.0: reg 0x14: [mem 0xfebd2000-0xfebd2fff]
> > pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
> > pci 0000:00:06.0: reg 0x10: [io  0xc040-0xc07f]
> > pci 0000:00:06.0: reg 0x14: [mem 0xfebd3000-0xfebd3fff]
> > pci 0000:00:07.0: [8086:25ab] type 00 class 0x088000
> > pci 0000:00:07.0: reg 0x10: [mem 0xfebd4000-0xfebd400f]
> > pci_bus 0000:00: busn_res: [bus 00-ff] end is updated to 00
> > pci 0000:00:01.0: PIIX/ICH IRQ router [8086:7000]
> > PCI: pci_cache_line_size set to 64 bytes
> > e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
> > e820: reserve RAM buffer [mem 0xbfffc000-0xbfffffff]
> > clocksource: Switched to clocksource refined-jiffies
> > pci_bus 0000:00: resource 4 [io  0x0000-0xffff]
> > pci_bus 0000:00: resource 5 [mem 0x00000000-0xffffffffff]
> > NET: Registered protocol family 2
> > TCP established hash table entries: 32768 (order: 6, 262144 bytes)
> > TCP bind hash table entries: 32768 (order: 7, 524288 bytes)
> > TCP: Hash tables configured (established 32768 bind 32768)
> > UDP hash table entries: 2048 (order: 4, 65536 bytes)
> > UDP-Lite hash table entries: 2048 (order: 4, 65536 bytes)
> > NET: Registered protocol family 1
> > Trying to unpack rootfs image as initramfs...
> > Freeing initrd memory: 125848K (ffff88007851a000 - ffff880080000000)
> > platform rtc_cmos: registered platform RTC device (no PNP device found)
> > Scanning for low memory corruption every 60 seconds
> > futex hash table entries: 4096 (order: 6, 262144 bytes)
> > HugeTLB registered 2 MB page size, pre-allocated 0 pages
> > fuse init (API version 7.23)
> > 9p: Installing v9fs 9p2000 file system support
> > cryptomgr_test (74) used greatest stack depth: 15352 bytes left
> > cryptomgr_test (82) used greatest stack depth: 15136 bytes left
> > Block layer SCSI generic (bsg) driver version 0.4 loaded (major 251)
> > io scheduler noop registered
> > io scheduler deadline registered
> > io scheduler cfq registered (default)
> > querying PCI -> IRQ mapping bus:0, slot:3, pin:0.
> > virtio-pci 0000:00:03.0: PCI->APIC IRQ transform: INT A -> IRQ 11
> > virtio-pci 0000:00:03.0: virtio_pci: leaving for legacy driver
> > querying PCI -> IRQ mapping bus:0, slot:4, pin:0.
> > virtio-pci 0000:00:04.0: PCI->APIC IRQ transform: INT A -> IRQ 11
> > virtio-pci 0000:00:04.0: virtio_pci: leaving for legacy driver
> > querying PCI -> IRQ mapping bus:0, slot:5, pin:0.
> > virtio-pci 0000:00:05.0: PCI->APIC IRQ transform: INT A -> IRQ 10
> > virtio-pci 0000:00:05.0: virtio_pci: leaving for legacy driver
> > querying PCI -> IRQ mapping bus:0, slot:6, pin:0.
> > virtio-pci 0000:00:06.0: PCI->APIC IRQ transform: INT A -> IRQ 10
> > virtio-pci 0000:00:06.0: virtio_pci: leaving for legacy driver
> > Serial: 8250/16550 driver, 32 ports, IRQ sharing enabled
> > serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) is a 1=
6550A
> > Linux agpgart interface v0.103
> > brd: module loaded
> > loop: module loaded
> >  vda: vda1 vda2 < vda5 >
> > zram: Added device: zram0
> > libphy: Fixed MDIO Bus: probed
> > tun: Universal TUN/TAP device driver, 1.6
> > tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
> > serio: i8042 KBD port at 0x60,0x64 irq 1
> > serio: i8042 AUX port at 0x60,0x64 irq 12
> > mousedev: PS/2 mouse device common for all mice
> > rtc_cmos rtc_cmos: rtc core: registered rtc_cmos as rtc0
> > rtc_cmos rtc_cmos: alarms up to one day, 114 bytes nvram
> > device-mapper: ioctl: 4.33.0-ioctl (2015-8-18) initialised: dm-devel@re=
dhat.com
> > device-mapper: cache cleaner: version 1.0.0 loaded
> > NET: Registered protocol family 17
> > 9pnet: Installing 9P2000 support
> > ... APIC ID:      00000000 (0)
> > ... APIC VERSION: 01050014
> > 0000000000000000000000000000000000000000000000000000000000000000
> > 000000000e000000000000000000000000000000000000000000000000000000
> > 0000000000020000000000000000000000000000000000000000000000008000
> >=20
> > number of MP IRQ sources: 16.
> > number of IO-APIC #0 registers: 24.
> > testing the IO APIC.......................
> > IO APIC #0......
> > .... register #00: 00000000
> > .......    : physical APIC id: 00
> > .......    : Delivery Type: 0
> > .......    : LTS          : 0
> > .... register #01: 00170011
> > .......     : max redirection entries: 17
> > .......     : PRQ implemented: 0
> > .......     : IO APIC version: 11
> > .... register #02: 00000000
> > .......     : arbitration: 00
> > .... IRQ redirection table:
> > IOAPIC 0:
> >  pin00, disabled, edge , high, V(00), IRR(0), S(0), physical, D(00), M(=
0)
> >  pin01, enabled , edge , high, V(31), IRR(0), S(0), physical, D(00), M(=
0)
> >  pin02, enabled , edge , high, V(30), IRR(0), S(0), physical, D(00), M(=
0)
> >  pin03, enabled , edge , high, V(33), IRR(0), S(0), physical, D(00), M(=
0)
> >  pin04, disabled, edge , high, V(34), IRR(0), S(0), physical, D(00), M(=
0)
> >  pin05, disabled, edge , high, V(00), IRR(0), S(0), physical, D(00), M(=
0)
> >  pin06, enabled , edge , high, V(36), IRR(0), S(0), physical, D(00), M(=
0)
> >  pin07, enabled , edge , high, V(37), IRR(0), S(0), physical, D(00), M(=
0)
> >  pin08, enabled , edge , high, V(38), IRR(0), S(0), physical, D(00), M(=
0)
> >  pin09, disabled, level, high, V(39), IRR(0), S(0), physical, D(00), M(=
0)
> >  pin0a, enabled , level, high, V(3A), IRR(0), S(0), physical, D(00), M(=
0)
> >  pin0b, enabled , level, high, V(3B), IRR(0), S(0), physical, D(00), M(=
0)
> >  pin0c, enabled , edge , high, V(3C), IRR(0), S(0), physical, D(00), M(=
0)
> >  pin0d, enabled , edge , high, V(3D), IRR(0), S(0), physical, D(00), M(=
0)
> >  pin0e, enabled , edge , high, V(3E), IRR(0), S(0), physical, D(00), M(=
0)
> >  pin0f, enabled , edge , high, V(3F), IRR(0), S(0), physical, D(00), M(=
0)
> >  pin10, disabled, edge , high, V(00), IRR(0), S(0), physical, D(00), M(=
0)
> >  pin11, disabled, edge , high, V(00), IRR(0), S(0), physical, D(00), M(=
0)
> >  pin12, disabled, edge , high, V(00), IRR(0), S(0), physical, D(00), M(=
0)
> >  pin13, disabled, edge , high, V(00), IRR(0), S(0), physical, D(00), M(=
0)
> >  pin14, disabled, edge , high, V(00), IRR(0), S(0), physical, D(00), M(=
0)
> >  pin15, disabled, edge , high, V(00), IRR(0), S(0), physical, D(00), M(=
0)
> >  pin16, disabled, edge , high, V(00), IRR(0), S(0), physical, D(00), M(=
0)
> >  pin17, disabled, edge , high, V(00), IRR(0), S(0), physical, D(00), M(=
0)
> > IRQ to pin mappings:
> > IRQ0 -> 0:2
> > IRQ1 -> 0:1
> > IRQ3 -> 0:3
> > IRQ4 -> 0:4
> > IRQ6 -> 0:6
> > IRQ7 -> 0:7
> > IRQ8 -> 0:8
> > IRQ9 -> 0:9
> > IRQ10 -> 0:10
> > IRQ11 -> 0:11
> > IRQ12 -> 0:12
> > IRQ13 -> 0:13
> > IRQ14 -> 0:14
> > IRQ15 -> 0:15
> > .................................... done.
> > rtc_cmos rtc_cmos: setting system clock to 2015-10-20 08:57:55 UTC (144=
5331475)
> > input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/i=
nput/input0
> > Freeing unused kernel memory: 936K (ffffffff818b6000 - ffffffff819a0000)
> > Write protecting the kernel read-only data: 8192k
> > Freeing unused kernel memory: 1900K (ffff880001425000 - ffff88000160000=
0)
> > Freeing unused kernel memory: 60K (ffff8800017f1000 - ffff880001800000)
> > busybox (117) used greatest stack depth: 14480 bytes left
> > exe (124) used greatest stack depth: 14024 bytes left
> > udevd[140]: starting version 175
> > blkid (151) used greatest stack depth: 13920 bytes left
> > modprobe (242) used greatest stack depth: 13784 bytes left
> > clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x2e200418439, m=
ax_idle_ns: 440795220848 ns
> > clocksource: Switched to clocksource tsc
> > EXT4-fs (vda1): recovery complete
> > EXT4-fs (vda1): mounted filesystem with ordered data mode. Opts: (null)
> > exe (262) used greatest stack depth: 13032 bytes left
> > random: init urandom read with 9 bits of entropy available
> > init: plymouth-upstart-bridge main process (279) terminated with status=
 1
> > init: plymouth-upstart-bridge main process ended, respawning
> > init: plymouth-upstart-bridge main process (289) terminated with status=
 1
> > init: plymouth-upstart-bridge main process ended, respawning
> > init: plymouth-upstart-bridge main process (293) terminated with status=
 1
> > init: plymouth-upstart-bridge main process ended, respawning
> > init: ureadahead main process (282) terminated with status 5
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > systemd-udevd[423]: starting version 204
> > EXT4-fs (vdb): mounted filesystem with ordered data mode. Opts: errors=
=3Dremount-ro
> >  * Stopping Send an event to indicate plymouth is up=1B[74G[ OK ]
> >  * Starting Mount filesystems on boot=1B[74G[ OK ]
> >  * Starting Signal sysvinit that the rootfs is mounted=1B[74G[ OK ]
> >  * Starting Populate /dev filesystem=1B[74G[ OK ]
> >  * Starting Populate and link to /run filesystem=1B[74G[ OK ]
> >  * Stopping Populate /dev filesystem=1B[74G[ OK ]
> >  * Stopping Populate and link to /run filesystem=1B[74G[ OK ]
> >  * Starting Clean /tmp directory=1B[74G[ OK ]
> >  * Stopping Track if upstart is running in a container=1B[74G[ OK ]
> >  * Stopping Clean /tmp directory=1B[74G[ OK ]
> >  * Starting Initialize or finalize resolvconf=1B[74G[ OK ]
> >  * Starting set console keymap=1B[74G[ OK ]
> >  * Starting Signal sysvinit that virtual filesystems are mounted=1B[74G=
[ OK ]
> >  * Starting Signal sysvinit that virtual filesystems are mounted=1B[74G=
[ OK ]
> >  * Starting Bridge udev events into upstart=1B[74G[ OK ]
> >  * Starting Signal sysvinit that remote filesystems are mounted=1B[74G[=
 OK ]
> >  * Stopping set console keymap=1B[74G[ OK ]
> >  * Starting device node and kernel event manager=1B[74G[ OK ]
> >  * Starting load modules from /etc/modules=1B[74G[ OK ]
> >  * Starting cold plug devices=1B[74G[ OK ]
> >  * Starting log initial device creation=1B[74G[ OK ]
> >  * Stopping Read required files in advance (for other mountpoints)=1B[7=
4G[ OK ]
> >  * Stopping load modules from /etc/modules=1B[74G[ OK ]
> >  * Starting Signal sysvinit that local filesystems are mounted=1B[74G[ =
OK ]
> >  * Starting flush early job output to logs=1B[74G[ OK ]
> >  * Stopping Mount filesystems on boot=1B[74G[ OK ]
> >  * Stopping flush early job output to logs=1B[74G[ OK ]
> >  * Starting D-Bus system message bus=1B[74G[ OK ]
> >  * Starting SystemD login management service=1B[74G[ OK ]
> >  * Starting system logging daemon=1B[74G[ OK ]
> >  * Stopping cold plug devices=1B[74G[ OK ]
> >  * Starting Uncomplicated firewall=1B[74G[ OK ]
> >  * Starting configure network device security=1B[74G[ OK ]
> >  * Stopping log initial device creation=1B[74G[ OK ]
> >  * Starting configure network device security=1B[74G[ OK ]
> >  * Starting save udev log and update rules=1B[74G[ OK ]
> >  * Starting set console font=1B[74G[ OK ]
> >  * Stopping save udev log and update rules=1B[74G[ OK ]
> >  * Starting Mount network filesystems=1B[74G[ OK ]
> >  * Starting Failsafe Boot Delay=1B[74G[ OK ]
> >  * Starting configure network device security=1B[74G[ OK ]
> >  * Stopping Mount network filesystems=1B[74G[ OK ]
> >  * Starting configure network device=1B[74G[ OK ]
> >  * Starting configure network device=1B[74G[ OK ]
> >  * Starting Bridge file events into upstart=1B[74G[ OK ]
> >  * Starting Bridge socket events into upstart=1B[74G[ OK ]
> >  * Stopping set console font=1B[74G[ OK ]
> >  * Starting userspace bootsplash=1B[74G[ OK ]
> >  * Starting Send an event to indicate plymouth is up=1B[74G[ OK ]
> >  * Stopping userspace bootsplash=1B[74G[ OK ]
> >  * Stopping Send an event to indicate plymouth is up=1B[74G[ OK ]
> >  * Starting Mount network filesystems=1B[74G[ OK ]
> > init: failsafe main process (591) killed by TERM signal
> >  * Stopping Failsafe Boot Delay=1B[74G[ OK ]
> >  * Starting System V initialisation compatibility=1B[74G[ OK ]
> >  * Stopping Mount network filesystems=1B[74G[ OK ]
> >  * Starting configure virtual network devices=1B[74G[ OK ]
> >  * Stopping System V initialisation compatibility=1B[74G[ OK ]
> >  * Starting System V runlevel compatibility=1B[74G[ OK ]
> >  * Starting deferred execution scheduler=1B[74G[ OK ]
> >  * Starting regular background program processing daemon=1B[74G[ OK ]
> >  * Starting ACPI daemon=1B[74G[ OK ]
> >  * Starting save kernel messages=1B[74G[ OK ]
> >  * Starting CPU interrupts balancing daemon=1B[74G[ OK ]
> >  * Stopping save kernel messages=1B[74G[ OK ]
> >  * Starting OpenSSH server=1B[74G[ OK ]
> >  * Starting automatic crash report generation=1B[74G[ OK ]
> >  * Restoring resolver state...       =1B[80G =0D=1B[74G[ OK ]
> > eth0 Link encap:Ethernet HWaddr 52:54:79:12:34:57 inet addr:192.168.0.2=
1 Bcast:192.168.0.255 Mask:255.255.255.0 UP BROADCAST RUNNING MULTICAST MTU=
:1500 Metric:1 RX packets:34 errors:0 dropped:24 overruns:0 frame:0 TX pack=
ets:4 errors:0 dropped:0 overruns:0 carrier:0 collisions:0 txqueuelen:1000 =
RX bytes:5780 (5.7 KB) TX bytes:800 (800.0 B) lo Link encap:Local Loopback =
inet addr:127.0.0.1 Mask:255.0.0.0 UP LOOPBACK RUNNING MTU:65536 Metric:1 R=
X packets:0 errors:0 dropped:0 overruns:0 frame:0 TX packets:0 errors:0 dro=
pped:0 overruns:0 carrier:0 collisions:0 txqueuelen:0 RX bytes:0 (0.0 B) TX=
 bytes:0 (0.0 B)
> >  * Stopping System V runlevel compatibility=1B[74G[ OK ]
> > init: plymouth-upstart-bridge main process ended, respawning
> > sh (1429) used greatest stack depth: 11752 bytes left
> > sh (1454) used greatest stack depth: 11528 bytes left
> > random: nonblocking pool is initialized
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > sh (2785) used greatest stack depth: 11480 bytes left
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:419122=
8k FS
> > BUG: unable to handle kernel NULL pointer dereference at 00000000000000=
08
> > IP: [<ffffffff810782a9>] down_read_trylock+0x9/0x30
> > PGD 0=20
> > Oops: 0000 [#1] SMP=20
> > Dumping ftrace buffer:
> >    (ftrace buffer empty)
> > Modules linked in:
> > CPU: 1 PID: 26445 Comm: sh Not tainted 4.3.0-rc5-mm1-diet-meta+ #1545
> > Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01=
/2011
> > task: ffff8800b9af3480 ti: ffff88007fea0000 task.ti: ffff88007fea0000
> > RIP: 0010:[<ffffffff810782a9>]  [<ffffffff810782a9>] down_read_trylock+=
0x9/0x30
> > RSP: 0018:ffff88007fea3648  EFLAGS: 00010202
> > RAX: 0000000000000001 RBX: ffffea0002324900 RCX: ffff88007fea37e8
> > RDX: 0000000000000000 RSI: ffff88007fea36e8 RDI: 0000000000000008
> > RBP: ffff88007fea3648 R08: ffffffff818446a0 R09: ffff8800b9af4c80
> > R10: 0000000000000216 R11: 0000000000000001 R12: ffff88007f58d6e1
> > R13: ffff88007f58d6e0 R14: 0000000000000008 R15: 0000000000000001
> > FS:  00007f0993e78740(0000) GS:ffff8800bfa20000(0000) knlGS:00000000000=
00000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > CR2: 0000000000000008 CR3: 000000007edee000 CR4: 00000000000006a0
> > Stack:
> >  ffff88007fea3678 ffffffff81124ff0 ffffea0002324900 ffff88007fea36e8
> >  ffff88009ffe8400 0000000000000000 ffff88007fea36c0 ffffffff81125733
> >  ffff8800bfa34540 ffffffff8105dc9d ffffea0002324900 ffff88007fea37e8
> > Call Trace:
> >  [<ffffffff81124ff0>] page_lock_anon_vma_read+0x60/0x180
> >  [<ffffffff81125733>] rmap_walk+0x1b3/0x3f0
> >  [<ffffffff8105dc9d>] ? finish_task_switch+0x5d/0x1f0
> >  [<ffffffff81125b13>] page_referenced+0x1a3/0x220
> >  [<ffffffff81123e30>] ? __page_check_address+0x1a0/0x1a0
> >  [<ffffffff81124f90>] ? page_get_anon_vma+0xd0/0xd0
> >  [<ffffffff81123820>] ? anon_vma_ctor+0x40/0x40
> >  [<ffffffff8110087b>] shrink_page_list+0x5ab/0xde0
> >  [<ffffffff8110174c>] shrink_inactive_list+0x18c/0x4b0
> >  [<ffffffff811023bd>] shrink_lruvec+0x59d/0x740
> >  [<ffffffff811025f0>] shrink_zone+0x90/0x250
> >  [<ffffffff811028dd>] do_try_to_free_pages+0x12d/0x3b0
> >  [<ffffffff81102d3d>] try_to_free_mem_cgroup_pages+0x9d/0x120
> >  [<ffffffff811496c3>] try_charge+0x163/0x700
> >  [<ffffffff81149cb4>] mem_cgroup_do_precharge+0x54/0x70
> >  [<ffffffff81149e45>] mem_cgroup_can_attach+0x175/0x1b0
> >  [<ffffffff811b2c57>] ? kernfs_iattrs.isra.6+0x37/0xd0
> >  [<ffffffff81148e70>] ? get_mctgt_type+0x320/0x320
> >  [<ffffffff810a9d29>] cgroup_migrate+0x149/0x440
> >  [<ffffffff810aa60c>] cgroup_attach_task+0x7c/0xe0
> >  [<ffffffff810aa904>] __cgroup_procs_write.isra.33+0x1d4/0x2b0
> >  [<ffffffff810aaa10>] cgroup_tasks_write+0x10/0x20
> >  [<ffffffff810a6238>] cgroup_file_write+0x38/0xf0
> >  [<ffffffff811b54ad>] kernfs_fop_write+0x11d/0x170
> >  [<ffffffff81153918>] __vfs_write+0x28/0xe0
> >  [<ffffffff8116e614>] ? __fd_install+0x24/0xc0
> >  [<ffffffff810784a1>] ? percpu_down_read+0x21/0x50
> >  [<ffffffff81153e91>] vfs_write+0xa1/0x170
> >  [<ffffffff81154716>] SyS_write+0x46/0xa0
> >  [<ffffffff81420a17>] entry_SYSCALL_64_fastpath+0x12/0x6a
> > Code: 5e 82 3a 00 48 83 c4 08 5b 5d c3 48 89 45 f0 e8 9b 6a 3a 00 48 8b=
 45 f0 eb df 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 55 48 89 e5 <48> 8b 07 =
48 89 c2 48 83 c2 01 7e 07 f0 48 0f b1 17 75 f0 48 f7=20
> > RIP  [<ffffffff810782a9>] down_read_trylock+0x9/0x30
> >  RSP <ffff88007fea3648>
> > CR2: 0000000000000008
> > BUG: unable to handle kernel ---[ end trace e81a82c8122b447d ]---
> > Kernel panic - not syncing: Fatal exception
> >=20
> > NULL pointer dereference at 0000000000000008
> > IP: [<ffffffff810782a9>] down_read_trylock+0x9/0x30
> > PGD 0=20
> > Oops: 0000 [#2] SMP=20
> > Dumping ftrace buffer:
> >    (ftrace buffer empty)
> > Modules linked in:
> > CPU: 10 PID: 59 Comm: khugepaged Tainted: G      D         4.3.0-rc5-mm=
1-diet-meta+ #1545
> > Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01=
/2011
> > task: ffff8800b9851a40 ti: ffff8800b985c000 task.ti: ffff8800b985c000
> > RIP: 0010:[<ffffffff810782a9>]  [<ffffffff810782a9>] down_read_trylock+=
0x9/0x30
> > RSP: 0018:ffff8800b985f778  EFLAGS: 00010202
> > RAX: 0000000000000001 RBX: ffffea0002321800 RCX: ffff8800b985f918
> > RDX: 0000000000000000 RSI: ffff8800b985f818 RDI: 0000000000000008
> > RBP: ffff8800b985f778 R08: ffffffff818446a0 R09: ffff8800b9853240
> > R10: 000000000000ba03 R11: 0000000000000001 R12: ffff88007f58d6e1
> > R13: ffff88007f58d6e0 R14: 0000000000000008 R15: 0000000000000001
> > FS:  0000000000000000(0000) GS:ffff8800bfb40000(0000) knlGS:00000000000=
00000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > CR2: 0000000000000008 CR3: 0000000001808000 CR4: 00000000000006a0
> > Stack:
> >  ffff8800b985f7a8 ffffffff81124ff0 ffffea0002321800 ffff8800b985f818
> >  ffff88009ffe8400 0000000000000000 ffff8800b985f7f0 ffffffff81125733
> >  ffff8800bfb54540 ffffffff8105dc9d ffffea0002321800 ffff8800b985f918
> > Call Trace:
> >  [<ffffffff81124ff0>] page_lock_anon_vma_read+0x60/0x180
> >  [<ffffffff81125733>] rmap_walk+0x1b3/0x3f0
> >  [<ffffffff8105dc9d>] ? finish_task_switch+0x5d/0x1f0
> >  [<ffffffff81125b13>] page_referenced+0x1a3/0x220
> >  [<ffffffff81123e30>] ? __page_check_address+0x1a0/0x1a0
> >  [<ffffffff81124f90>] ? page_get_anon_vma+0xd0/0xd0
> >  [<ffffffff81123820>] ? anon_vma_ctor+0x40/0x40
> >  [<ffffffff8110087b>] shrink_page_list+0x5ab/0xde0
> >  [<ffffffff8110174c>] shrink_inactive_list+0x18c/0x4b0
> >  [<ffffffff811023bd>] shrink_lruvec+0x59d/0x740
> >  [<ffffffff811025f0>] shrink_zone+0x90/0x250
> >  [<ffffffff811028dd>] do_try_to_free_pages+0x12d/0x3b0
> >  [<ffffffff81102d3d>] try_to_free_mem_cgroup_pages+0x9d/0x120
> >  [<ffffffff811496c3>] try_charge+0x163/0x700
> >  [<ffffffff8141d1f3>] ? schedule+0x33/0x80
> >  [<ffffffff8114d45f>] mem_cgroup_try_charge+0x9f/0x1d0
> >  [<ffffffff811434bc>] khugepaged+0x7cc/0x1ac0
> >  [<ffffffff81066e01>] ? hrtick_update+0x1/0x70
> >  [<ffffffff81072430>] ? prepare_to_wait_event+0xf0/0xf0
> >  [<ffffffff81142cf0>] ? total_mapcount+0x70/0x70
> >  [<ffffffff81056cd9>] kthread+0xc9/0xe0
> >  [<ffffffff81056c10>] ? kthread_park+0x60/0x60
> >  [<ffffffff81420d6f>] ret_from_fork+0x3f/0x70
> >  [<ffffffff81056c10>] ? kthread_park+0x60/0x60
> > Code: 5e 82 3a 00 48 83 c4 08 5b 5d c3 48 89 45 f0 e8 9b 6a 3a 00 48 8b=
 45 f0 eb df 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 55 48 89 e5 <48> 8b 07 =
48 89 c2 48 83 c2 01 7e 07 f0 48 0f b1 17 75 f0 48 f7=20
> > RIP  [<ffffffff810782a9>] down_read_trylock+0x9/0x30
> >  RSP <ffff8800b985f778>
> > CR2: 0000000000000008
> > ---[ end trace e81a82c8122b447e ]---
> > Shutting down cpus with NMI
> > Dumping ftrace buffer:
> >    (ftrace buffer empty)
> > Kernel Offset: disabled
>=20

--=20
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
