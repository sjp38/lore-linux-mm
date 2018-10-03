Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4EC486B0007
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 07:01:49 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b13-v6so3033489edb.1
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 04:01:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t12-v6si1138929edi.268.2018.10.03.04.01.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 04:01:48 -0700 (PDT)
Date: Wed, 3 Oct 2018 13:01:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Avoid swapping in interrupt context
Message-ID: <20181003110146.GB4714@dhcp22.suse.cz>
References: <1538387115-2363-1-git-send-email-amhetre@nvidia.com>
 <20181001122400.GF18290@dhcp22.suse.cz>
 <988dfe01-6553-1e0a-1d98-1b3d3aa67517@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <988dfe01-6553-1e0a-1d98-1b3d3aa67517@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ashish Mhetre <amhetre@nvidia.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, vdumpa@nvidia.com, Snikam@nvidia.com

On Wed 03-10-18 16:18:37, Ashish Mhetre wrote:
> > How? No allocation request from the interrupt context can use a
> > sleepable allocation context and that means that no reclaim is allowed
> > from the IRQ context.
> Kernel Oops happened when ZRAM was used as swap with zsmalloc as alloctor
> under memory pressure condition.
> This is probably because of kmalloc() from IRQ as pointed out by Sergey.

Yes most likely and that should be fixed.
 
> > Could you provide the Oops message?
> BUG_ON() got triggered at https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/tree/mm/zsmalloc.c?h=next-20181002#n1324 with Oops message:
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

This doesn't show the backtrace part which contains the allocation
AFAICS.
-- 
Michal Hocko
SUSE Labs
