Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 589F96B0038
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 12:35:21 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id g10so6425506wrg.6
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 09:35:21 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id d93si6511026edc.450.2017.11.06.09.35.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 06 Nov 2017 09:35:19 -0800 (PST)
Date: Mon, 6 Nov 2017 12:35:11 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm, sparse: do not swamp log with huge vmemmap
 allocation failures
Message-ID: <20171106173511.GA32336@cmpxchg.org>
References: <20171106092228.31098-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171106092228.31098-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, Nov 06, 2017 at 10:22:28AM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> While doing a memory hotplug tests under a heavy memory pressure we have
> noticed too many page allocation failures when allocating vmemmap memmap
> backed by huge page
> [146792.281354] kworker/u3072:1: page allocation failure: order:9, mode:0x24084c0(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO)
> [...]
> [146792.281394] Call Trace:
> [146792.281430]  [<ffffffff81019a99>] dump_trace+0x59/0x310
> [146792.281436]  [<ffffffff81019e3a>] show_stack_log_lvl+0xea/0x170
> [146792.281440]  [<ffffffff8101abc1>] show_stack+0x21/0x40
> [146792.281448]  [<ffffffff8130f040>] dump_stack+0x5c/0x7c
> [146792.281464]  [<ffffffff8118c982>] warn_alloc_failed+0xe2/0x150
> [146792.281471]  [<ffffffff8118cddd>] __alloc_pages_nodemask+0x3ed/0xb20
> [146792.281489]  [<ffffffff811d3aaf>] alloc_pages_current+0x7f/0x100
> [146792.281503]  [<ffffffff815dfa2c>] vmemmap_alloc_block+0x79/0xb6
> [146792.281510]  [<ffffffff815dfbd3>] __vmemmap_alloc_block_buf+0x136/0x145
> [146792.281524]  [<ffffffff815dd0c5>] vmemmap_populate+0xd2/0x2b9
> [146792.281529]  [<ffffffff815dffd9>] sparse_mem_map_populate+0x23/0x30
> [146792.281532]  [<ffffffff815df88d>] sparse_add_one_section+0x68/0x18e
> [146792.281537]  [<ffffffff815d9f5a>] __add_pages+0x10a/0x1d0
> [146792.281553]  [<ffffffff8106249a>] arch_add_memory+0x4a/0xc0
> [146792.281559]  [<ffffffff815da1f9>] add_memory_resource+0x89/0x160
> [146792.281564]  [<ffffffff815da33d>] add_memory+0x6d/0xd0
> [146792.281585]  [<ffffffff813d36c4>] acpi_memory_device_add+0x181/0x251
> [146792.281597]  [<ffffffff813946e5>] acpi_bus_attach+0xfd/0x19b
> [146792.281602]  [<ffffffff81394866>] acpi_bus_scan+0x59/0x69
> [146792.281604]  [<ffffffff813949de>] acpi_device_hotplug+0xd2/0x41f
> [146792.281608]  [<ffffffff8138db67>] acpi_hotplug_work_fn+0x1a/0x23
> [146792.281623]  [<ffffffff81093cee>] process_one_work+0x14e/0x410
> [146792.281630]  [<ffffffff81094546>] worker_thread+0x116/0x490
> [146792.281637]  [<ffffffff810999ed>] kthread+0xbd/0xe0
> [146792.281651]  [<ffffffff815e4e7f>] ret_from_fork+0x3f/0x70
> 
> and we do see many of those because essentially every the allocation
> failes for each memory section. This is overly excessive way to tell
> user that there is nothing to really worry about because we do have
> a fallback mechanism to use base pages. The only downside might be a
> performance degradation due to TLB pressure.
> 
> This patch changes vmemmap_alloc_block to use __GFP_NOWARN and warn
> explicitly once on the first allocation failure. This will reduce the
> noise in the kernel log considerably, while we still have an indication
> that a performance might be impacted.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
> Hi,
> this has somehow fell of my radar completely. The patch is essentially
> what Johannes suggested [1] so I have added his s-o-b and added the
> changelog into it.

Looks good to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
