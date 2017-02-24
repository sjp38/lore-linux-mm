Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5D73A6B0387
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 08:43:30 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id p185so8938686pfb.4
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 05:43:30 -0800 (PST)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id g2si7420295plj.200.2017.02.24.05.43.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Feb 2017 05:43:26 -0800 (PST)
Received: by mail-pg0-x243.google.com with SMTP id 1so3154049pgz.2
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 05:43:25 -0800 (PST)
Subject: Re: [PATCH v2 1/2] mm/cgroup: avoid panic when init with low memory
References: <1487856999-16581-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1487856999-16581-2-git-send-email-ldufour@linux.vnet.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <ef0066da-417f-f926-4af8-43f0ce28750f@gmail.com>
Date: Sat, 25 Feb 2017 00:42:57 +1100
MIME-Version: 1.0
In-Reply-To: <1487856999-16581-2-git-send-email-ldufour@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 24/02/17 00:36, Laurent Dufour wrote:
> The system may panic when initialisation is done when almost all the
> memory is assigned to the huge pages using the kernel command line
> parameter hugepage=xxxx. Panic may occur like this:
> 
> [    0.082289] Unable to handle kernel paging request for data at address 0x00000000
> [    0.082338] Faulting instruction address: 0xc000000000302b88
> [    0.082377] Oops: Kernel access of bad area, sig: 11 [#1]
> [    0.082408] SMP NR_CPUS=2048 [    0.082424] NUMA
> [    0.082440] pSeries
> [    0.082457] Modules linked in:
> [    0.082490] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.9.0-15-generic #16-Ubuntu
> [    0.082536] task: c00000021ed01600 task.stack: c00000010d108000
> [    0.082575] NIP: c000000000302b88 LR: c000000000270e04 CTR: c00000000016cfd0
> [    0.082621] REGS: c00000010d10b2c0 TRAP: 0300   Not tainted (4.9.0-15-generic)
> [    0.082666] MSR: 8000000002009033 <SF,VEC,EE,ME,IR,DR,RI,LE>[ 0.082770]   CR: 28424422  XER: 00000000
> [    0.082793] CFAR: c0000000003d28b8 DAR: 0000000000000000 DSISR: 40000000 SOFTE: 1
> GPR00: c000000000270e04 c00000010d10b540 c00000000141a300 c00000010fff6300
> GPR04: 0000000000000000 00000000026012c0 c00000010d10b630 0000000487ab0000
> GPR08: 000000010ee90000 c000000001454fd8 0000000000000000 0000000000000000
> GPR12: 0000000000004400 c00000000fb80000 00000000026012c0 00000000026012c0
> GPR16: 00000000026012c0 0000000000000000 0000000000000000 0000000000000002
> GPR20: 000000000000000c 0000000000000000 0000000000000000 00000000024200c0
> GPR24: c0000000016eef48 0000000000000000 c00000010fff7d00 00000000026012c0
> GPR28: 0000000000000000 c00000010fff7d00 c00000010fff6300 c00000010d10b6d0
> NIP [c000000000302b88] mem_cgroup_soft_limit_reclaim+0xf8/0x4f0
> [    0.083456] LR [c000000000270e04] do_try_to_free_pages+0x1b4/0x450
> [    0.083494] Call Trace:
> [    0.083511] [c00000010d10b540] [c00000010d10b640] 0xc00000010d10b640 (unreliable)
> [    0.083567] [c00000010d10b610] [c000000000270e04] do_try_to_free_pages+0x1b4/0x450
> [    0.083622] [c00000010d10b6b0] [c000000000271198] try_to_free_pages+0xf8/0x270
> [    0.083676] [c00000010d10b740] [c000000000259dd8] __alloc_pages_nodemask+0x7a8/0xff0
> [    0.083729] [c00000010d10b960] [c0000000002dd274] new_slab+0x104/0x8e0
> [    0.083776] [c00000010d10ba40] [c0000000002e03d0] ___slab_alloc+0x620/0x700
> [    0.083822] [c00000010d10bb70] [c0000000002e04e4] __slab_alloc+0x34/0x60
> [    0.083868] [c00000010d10bba0] [c0000000002e101c] kmem_cache_alloc_node_trace+0xdc/0x310
> [    0.083947] [c00000010d10bc00] [c000000000eb8120] mem_cgroup_init+0x158/0x1c8
> [    0.083994] [c00000010d10bc40] [c00000000000dde8] do_one_initcall+0x68/0x1d0
> [    0.084041] [c00000010d10bd00] [c000000000e84184] kernel_init_freeable+0x278/0x360
> [    0.084094] [c00000010d10bdc0] [c00000000000e714] kernel_init+0x24/0x170
> [    0.084143] [c00000010d10be30] [c00000000000c0e8] ret_from_kernel_thread+0x5c/0x74
> [    0.084195] Instruction dump:
> [    0.084220] eb81ffe0 eba1ffe8 ebc1fff0 ebe1fff8 4e800020 3d230001 e9499a42 3d220004
> [    0.084300] 3929acd8 794a1f24 7d295214 eac90100 <e9360000> 2fa90000 419eff74 3b200000
> [    0.084382] ---[ end trace 342f5208b00d01b6 ]---
> 
> This is a chicken and egg issue where the kernel try to get free
> memory when allocating per node data in mem_cgroup_init(), but in that
> path mem_cgroup_soft_limit_reclaim() is called which assumes that
> these data are allocated.
> 
> As mem_cgroup_soft_limit_reclaim() is best effort, it should return
> when these data are not yet allocated.
> 
> This patch also fixes potential null pointer access in
> mem_cgroup_remove_from_trees() and mem_cgroup_update_tree().
> 
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> ---
Acked-by: Balbir Singh <bsingharora@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
