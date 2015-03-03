Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id F38466B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 04:16:54 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so15775178pdb.5
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 01:16:54 -0800 (PST)
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com. [122.248.162.6])
        by mx.google.com with ESMTPS id l2si289330pdk.79.2015.03.03.01.16.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Mar 2015 01:16:54 -0800 (PST)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 3 Mar 2015 14:46:50 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id C4CC0E0059
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 14:48:40 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t239Gk1l46596334
	for <linux-mm@kvack.org>; Tue, 3 Mar 2015 14:46:47 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t239Gjgc012361
	for <linux-mm@kvack.org>; Tue, 3 Mar 2015 14:46:46 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 3/4] mm: cma: add list of currently allocated CMA buffers to debugfs
In-Reply-To: <1fe64ae6f12eeda1c2aa59daea7f89e57e0e35a9.1424802755.git.s.strogin@partner.samsung.com>
References: <cover.1424802755.git.s.strogin@partner.samsung.com> <1fe64ae6f12eeda1c2aa59daea7f89e57e0e35a9.1424802755.git.s.strogin@partner.samsung.com>
Date: Tue, 03 Mar 2015 14:46:44 +0530
Message-ID: <87pp8qa1ab.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Strogin <s.strogin@partner.samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

Stefan Strogin <s.strogin@partner.samsung.com> writes:

> When CONFIG_CMA_BUFFER_LIST is configured a file is added to debugfs:
> /sys/kernel/debug/cma/cma-<N>/buffers contains a list of currently allocated
> CMA buffers for each CMA region (N stands for number of CMA region).
>
> Format is:
> <base_phys_addr> - <end_phys_addr> (<size> kB), allocated by <PID> (<comm>)
>
> When CONFIG_CMA_ALLOC_STACKTRACE is configured then stack traces are saved when
> the allocations are made. The stack traces are added to cma/cma-<N>/buffers
> for each buffer list entry.
>
> Example:
>
> root@debian:/sys/kernel/debug/cma# cat cma-0/buffers
> 0x2f400000 - 0x2f417000 (92 kB), allocated by pid 1 (swapper/0)
>  [<c1142c4b>] cma_alloc+0x1bb/0x200
>  [<c143d28a>] dma_alloc_from_contiguous+0x3a/0x40
>  [<c10079d9>] dma_generic_alloc_coherent+0x89/0x160
>  [<c14456ce>] dmam_alloc_coherent+0xbe/0x100
>  [<c1487312>] ahci_port_start+0xe2/0x210
>  [<c146e0e0>] ata_host_start.part.28+0xc0/0x1a0
>  [<c1473650>] ata_host_activate+0xd0/0x110
>  [<c14881bf>] ahci_host_activate+0x3f/0x170
>  [<c14854e4>] ahci_init_one+0x764/0xab0
>  [<c12e415f>] pci_device_probe+0x6f/0xd0
>  [<c14378a8>] driver_probe_device+0x68/0x210
>  [<c1437b09>] __driver_attach+0x79/0x80
>  [<c1435eef>] bus_for_each_dev+0x4f/0x80
>  [<c143749e>] driver_attach+0x1e/0x20
>  [<c1437197>] bus_add_driver+0x157/0x200
>  [<c14381bd>] driver_register+0x5d/0xf0
> <...>

A perf record -g will also give this information right ? To use this
feature, one need to recompile the kernel anyway. So why not assume that
user can always rerun the test with perf record -g and find the cma
allocation point stack trace ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
