Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id CAF816B0005
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 17:01:16 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id 64-v6so15730356oii.1
        for <linux-mm@kvack.org>; Mon, 08 Oct 2018 14:01:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p2sor11515905oth.183.2018.10.08.14.01.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Oct 2018 14:01:15 -0700 (PDT)
MIME-Version: 1.0
References: <20180925200551.3576.18755.stgit@localhost.localdomain> <20180925202053.3576.66039.stgit@localhost.localdomain>
In-Reply-To: <20180925202053.3576.66039.stgit@localhost.localdomain>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 8 Oct 2018 14:01:02 -0700
Message-ID: <CAPcyv4jX5WYmMYzGCBrnaqT7tqHGSVPwm7Dpi-XpuM9ns84+0w@mail.gmail.com>
Subject: Re: [PATCH v5 4/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: alexander.h.duyck@linux.intel.com
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Pasha Tatashin <pavel.tatashin@microsoft.com>, Michal Hocko <mhocko@suse.com>, Dave Jiang <dave.jiang@intel.com>, Dave Hansen <dave.hansen@intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, rppt@linux.vnet.ibm.com, Logan Gunthorpe <logang@deltatee.com>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Sep 25, 2018 at 1:29 PM Alexander Duyck
<alexander.h.duyck@linux.intel.com> wrote:
>
> The ZONE_DEVICE pages were being initialized in two locations. One was with
> the memory_hotplug lock held and another was outside of that lock. The
> problem with this is that it was nearly doubling the memory initialization
> time. Instead of doing this twice, once while holding a global lock and
> once without, I am opting to defer the initialization to the one outside of
> the lock. This allows us to avoid serializing the overhead for memory init
> and we can instead focus on per-node init times.
>
> One issue I encountered is that devm_memremap_pages and
> hmm_devmmem_pages_create were initializing only the pgmap field the same
> way. One wasn't initializing hmm_data, and the other was initializing it to
> a poison value. Since this is something that is exposed to the driver in
> the case of hmm I am opting for a third option and just initializing
> hmm_data to 0 since this is going to be exposed to unknown third party
> drivers.
>
> Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> ---
>
> v4: Moved moved memmap_init_zone_device to below memmmap_init_zone to avoid
>     merge conflicts with other changes in the kernel.
> v5: No change

This patch appears to cause a regression in the "create.sh" unit test
in the ndctl test suite.

I tried to reproduce on -next with:

2302f5ee215e mm: defer ZONE_DEVICE page initialization to the point
where we init pgmap

...but -next does not even boot for me at that commit.

Here is a warning signature that proceeds a hang with this patch
applied against v4.19-rc6:

percpu ref (blk_queue_usage_counter_release) <= 0 (-1530626) after
switching to atomic
WARNING: CPU: 24 PID: 7346 at lib/percpu-refcount.c:155
percpu_ref_switch_to_atomic_rcu+0x1f7/0x200
CPU: 24 PID: 7346 Comm: modprobe Tainted: G           OE     4.19.0-rc6+ #2458
[..]
RIP: 0010:percpu_ref_switch_to_atomic_rcu+0x1f7/0x200
[..]
Call Trace:
 <IRQ>
 ? percpu_ref_reinit+0x140/0x140
 rcu_process_callbacks+0x273/0x880
 __do_softirq+0xd2/0x428
 irq_exit+0xf6/0x100
 smp_apic_timer_interrupt+0xa2/0x220
 apic_timer_interrupt+0xf/0x20
 </IRQ>
RIP: 0010:lock_acquire+0xb8/0x1a0
[..]
 ? __put_page+0x55/0x150
 ? __put_page+0x55/0x150
 __put_page+0x83/0x150
 ? __put_page+0x55/0x150
 devm_memremap_pages_release+0x194/0x250
 release_nodes+0x17c/0x2c0
 device_release_driver_internal+0x1a2/0x250
 driver_detach+0x3a/0x70
 bus_remove_driver+0x58/0xd0
 __x64_sys_delete_module+0x13f/0x200
 ? trace_hardirqs_off_thunk+0x1a/0x1c
 do_syscall_64+0x60/0x210
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
