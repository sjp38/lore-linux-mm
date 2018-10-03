Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1733C6B000D
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 07:53:17 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g28-v6so2998130edc.18
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 04:53:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h22-v6si1063810eda.202.2018.10.03.04.53.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 04:53:15 -0700 (PDT)
Date: Wed, 3 Oct 2018 13:53:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Avoid swapping in interrupt context
Message-ID: <20181003115314.GE4714@dhcp22.suse.cz>
References: <1538387115-2363-1-git-send-email-amhetre@nvidia.com>
 <20181001122400.GF18290@dhcp22.suse.cz>
 <988dfe01-6553-1e0a-1d98-1b3d3aa67517@nvidia.com>
 <20181003110146.GB4714@dhcp22.suse.cz>
 <f54a61b2-b398-19e3-2b9b-1711ba3c75b7@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f54a61b2-b398-19e3-2b9b-1711ba3c75b7@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ashish Mhetre <amhetre@nvidia.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, vdumpa@nvidia.com, Snikam@nvidia.com

On Wed 03-10-18 17:20:15, Ashish Mhetre wrote:
> > This doesn't show the backtrace part which contains the allocation
> AFAICS.
> 
> My bad. Here is a complete dump:
> [ 264.082531] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM
> [ 264.088350] Modules linked in:
> [ 264.091406] CPU: 0 PID: 3805 Comm: kworker/0:4 Tainted: G W
> 3.10.33-g990282b #1
> [ 264.099572] Workqueue: events netstat_work_func
> [ 264.104097] task: e7b12040 ti: dc7d4000 task.ti: dc7d4000
> [ 264.109485] PC is at zs_map_object+0x180/0x18c
> [ 264.113918] LR is at zram_bvec_rw.isra.15+0x304/0x88c
> [ 264.118956] pc : [<c01581e8>] lr : [<c0456618>] psr: 200f0013
> [ 264.118956] sp : dc7d5460 ip : fff00814 fp : 00000002
> [ 264.130407] r10: ea8ec000 r9 : ebc93340 r8 : 00000000
> [ 264.135618] r7 : c191502c r6 : dc7d4020 r5 : d25f5684 r4 : ec3158c0
> [ 264.142128] r3 : 00000200 r2 : 00000002 r1 : c191502c r0 : ea8ec000
> 
> --------
> [ 265.772426] [<c01581e8>] (zs_map_object+0x180/0x18c) from [<c0456618>]
> (zram_bvec_rw.isra.15+0x304/0x88c)
> [ 265.781973] [<c0456618>] (zram_bvec_rw.isra.15+0x304/0x88c) from
> [<c0456d78>] (zram_make_request+0x1d8/0x378)
> [ 265.791868] [<c0456d78>] (zram_make_request+0x1d8/0x378) from [<c02c7afc>]
> (generic_make_request+0xb0/0xdc)
> [ 265.801588] [<c02c7afc>] (generic_make_request+0xb0/0xdc) from
> [<c02c7bb0>] (submit_bio+0x88/0x140)
> [ 265.810617] [<c02c7bb0>] (submit_bio+0x88/0x140) from [<c01459d4>]
> (__swap_writepage+0x198/0x230)
> [ 265.819471] [<c01459d4>] (__swap_writepage+0x198/0x230) from [<c011fc50>]
> (shrink_page_list+0x4e0/0x974)
> [ 265.828930] [<c011fc50>] (shrink_page_list+0x4e0/0x974) from [<c0120644>]
> (shrink_inactive_list+0x150/0x3c8)
> [ 265.838736] [<c0120644>] (shrink_inactive_list+0x150/0x3c8) from
> [<c0120de8>] (shrink_lruvec+0x20c/0x448)
> [ 265.848282] [<c0120de8>] (shrink_lruvec+0x20c/0x448) from [<c012109c>]
> (shrink_zone+0x78/0x188)
> [ 265.856960] [<c012109c>] (shrink_zone+0x78/0x188) from [<c01212ac>]
> (do_try_to_free_pages+0x100/0x544)
> [ 265.866246] [<c01212ac>] (do_try_to_free_pages+0x100/0x544) from
> [<c0121928>] (try_to_free_pages+0x238/0x428)
> [ 265.876140] [<c0121928>] (try_to_free_pages+0x238/0x428) from [<c01179cc>]
> (__alloc_pages_nodemask+0x5b0/0x90c)
> [ 265.886207] [<c01179cc>] (__alloc_pages_nodemask+0x5b0/0x90c) from
> [<c0117d44>] (__get_free_pages+0x1c/0x34)
> [ 265.896014] [<c0117d44>] (__get_free_pages+0x1c/0x34) from [<c0844a4c>]
> (tcp4_seq_show+0x248/0x4b4)
> [ 265.905042] [<c0844a4c>] (tcp4_seq_show+0x248/0x4b4) from [<c017a844>]
> (seq_read+0x1e4/0x484)
> [ 265.913550] [<c017a844>] (seq_read+0x1e4/0x484) from [<c01a84f0>]
> (proc_reg_read+0x60/0x88)
> [ 265.921884] [<c01a84f0>] (proc_reg_read+0x60/0x88) from [<c015aa44>]
> (vfs_read+0xa0/0x14c)
> [ 265.930129] [<c015aa44>] (vfs_read+0xa0/0x14c) from [<c015b0c4>]
> (SyS_read+0x44/0x80)
> [ 265.937942] [<c015b0c4>] (SyS_read+0x44/0x80) from [<c052e98c>]
> (netstat_work_func+0x54/0xec)
> [ 265.946450] [<c052e98c>] (netstat_work_func+0x54/0xec) from [<c0086700>]
> (process_one_work+0x13c/0x454)
> [ 265.955823] [<c0086700>] (process_one_work+0x13c/0x454) from [<c008745c>]
> (worker_thread+0x140/0x3dc)
> 265.965022] [<c008745c>] (worker_thread+0x140/0x3dc) from [<c008cf4c>]
> (kthread+0xe0/0xe4)
> [ 265.973269] [<c008cf4c>] (kthread+0xe0/0xe4) from [<c000ef98>]
> (ret_from_fork+0x14/0x20)
> [ 264.148640] Flags: nzCv IRQs on FIQs on Mode SVC_32 ISA ARM Segment kernel
> [ 264.155930] Control: 30c5387d Table: aaf7c000 DAC: fffffffd

This looks like a regular syscall path. How have you concluded this is
due to an IRQ context?
-- 
Michal Hocko
SUSE Labs
