Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E92096B06E8
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 06:07:21 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id 6-v6so994266edz.10
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 03:07:21 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k10-v6si3183531ejq.34.2018.11.09.03.07.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 03:07:20 -0800 (PST)
Date: Fri, 9 Nov 2018 12:07:13 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, memory_hotplug: do not clear numa_node
 association after hot_remove
Message-ID: <20181109110713.GG5321@dhcp22.suse.cz>
References: <20181108100413.966-1-mhocko@kernel.org>
 <20181108102917.GV27423@dhcp22.suse.cz>
 <048c04ae-7394-d03f-813e-42acdc965dd2@arm.com>
 <20181109075914.GD18390@dhcp22.suse.cz>
 <f9dd3dd0-3b20-446f-a131-70180fb733bf@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f9dd3dd0-3b20-446f-a131-70180fb733bf@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, LKML <linux-kernel@vger.kernel.org>, Miroslav Benes <mbenes@suse.cz>, Vlastimil Babka <vbabka@suse.cz>

On Fri 09-11-18 16:34:29, Anshuman Khandual wrote:
> 
> 
> On 11/09/2018 01:29 PM, Michal Hocko wrote:
> > On Fri 09-11-18 09:12:09, Anshuman Khandual wrote:
> >>
> >>
> >> On 11/08/2018 03:59 PM, Michal Hocko wrote:
> >>> [Removing Wen Congyang and Tang Chen from the CC list because their
> >>>  emails bounce. It seems that we will never learn about their motivation]
> >>>
> >>> On Thu 08-11-18 11:04:13, Michal Hocko wrote:
> >>>> From: Michal Hocko <mhocko@suse.com>
> >>>>
> >>>> Per-cpu numa_node provides a default node for each possible cpu. The
> >>>> association gets initialized during the boot when the architecture
> >>>> specific code explores cpu->NUMA affinity. When the whole NUMA node is
> >>>> removed though we are clearing this association
> >>>>
> >>>> try_offline_node
> >>>>   check_and_unmap_cpu_on_node
> >>>>     unmap_cpu_on_node
> >>>>       numa_clear_node
> >>>>         numa_set_node(cpu, NUMA_NO_NODE)
> >>>>
> >>>> This means that whoever calls cpu_to_node for a cpu associated with such
> >>>> a node will get NUMA_NO_NODE. This is problematic for two reasons. First
> >>>> it is fragile because __alloc_pages_node would simply blow up on an
> >>>> out-of-bound access. We have encountered this when loading kvm module
> >>>> BUG: unable to handle kernel paging request at 00000000000021c0
> >>>> IP: [<ffffffff8119ccb3>] __alloc_pages_nodemask+0x93/0xb70
> >>>> PGD 800000ffe853e067 PUD 7336bbc067 PMD 0
> >>>> Oops: 0000 [#1] SMP
> >>>> [...]
> >>>> CPU: 88 PID: 1223749 Comm: modprobe Tainted: G        W          4.4.156-94.64-default #1
> >>>> task: ffff88727eff1880 ti: ffff887354490000 task.ti: ffff887354490000
> >>>> RIP: 0010:[<ffffffff8119ccb3>]  [<ffffffff8119ccb3>] __alloc_pages_nodemask+0x93/0xb70
> >>>> RSP: 0018:ffff887354493b40  EFLAGS: 00010202
> >>>> RAX: 00000000000021c0 RBX: 0000000000000000 RCX: 0000000000000000
> >>>> RDX: 0000000000000000 RSI: 0000000000000002 RDI: 00000000014000c0
> >>>> RBP: 00000000014000c0 R08: ffffffffffffffff R09: 0000000000000000
> >>>> R10: ffff88fffc89e790 R11: 0000000000014000 R12: 0000000000000101
> >>>> R13: ffffffffa0772cd4 R14: ffffffffa0769ac0 R15: 0000000000000000
> >>>> FS:  00007fdf2f2f1700(0000) GS:ffff88fffc880000(0000) knlGS:0000000000000000
> >>>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> >>>> CR2: 00000000000021c0 CR3: 00000077205ee000 CR4: 0000000000360670
> >>>> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> >>>> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> >>>> Stack:
> >>>>  0000000000000086 014000c014d20400 ffff887354493bb8 ffff882614d20f4c
> >>>>  0000000000000000 0000000000000046 0000000000000046 ffffffff810ac0c9
> >>>>  ffff88ffe78c0000 ffffffff0000009f ffffe8ffe82d3500 ffff88ff8ac55000
> >>>> Call Trace:
> >>>>  [<ffffffffa07476cd>] alloc_vmcs_cpu+0x3d/0x90 [kvm_intel]
> >>>>  [<ffffffffa0772c0c>] hardware_setup+0x781/0x849 [kvm_intel]
> >>>>  [<ffffffffa04a1c58>] kvm_arch_hardware_setup+0x28/0x190 [kvm]
> >>>>  [<ffffffffa04856fc>] kvm_init+0x7c/0x2d0 [kvm]
> >>>>  [<ffffffffa0772cf2>] vmx_init+0x1e/0x32c [kvm_intel]
> >>>>  [<ffffffff8100213a>] do_one_initcall+0xca/0x1f0
> >>>>  [<ffffffff81193886>] do_init_module+0x5a/0x1d7
> >>>>  [<ffffffff81112083>] load_module+0x1393/0x1c90
> >>>>  [<ffffffff81112b30>] SYSC_finit_module+0x70/0xa0
> >>>>  [<ffffffff8161cbc3>] entry_SYSCALL_64_fastpath+0x1e/0xb7
> >>>> DWARF2 unwinder stuck at entry_SYSCALL_64_fastpath+0x1e/0xb7
> >>>>
> >>>> on an older kernel but the code is basically the same in the current
> >>>> Linus tree as well. alloc_vmcs_cpu could use alloc_pages_nodemask which
> >>>> would recognize NUMA_NO_NODE and use alloc_pages_node which would translate
> >>>> it to numa_mem_id but that is wrong as well because it would use a cpu
> >>>> affinity of the local CPU which might be quite far from the original node.
> >>
> >> But then the original node is getting/already off-lined. The allocation is
> >> going to come from a different node. alloc_pages_node() at least steer the
> >> allocation alway from VM_BUG_ON() because of NUMA_NO_NODE by replacing it
> >> with numa_mem_id().
> >>
> >> If node fallback order is important for this allocation then could not it
> >> use __alloc_pages_nodemask() directly giving preference for its zonelist
> >> node and nodemask. Just curious.
> > 
> > How does the caller get the right node to allocate from? We do have the
> > proper zone list for the offline node so why not use it?
> I get your point. NODE_DATA() for the off lined node is still around and
> so does the proper zone list for allocation, so why the caller should work
> around the problem by building it's preferred nodemask_t etc. No problem,
> I was just curious.

I thought I've made it cler in the changelog. If not, I am open to
suggestions on how to make it more clear.
-- 
Michal Hocko
SUSE Labs
