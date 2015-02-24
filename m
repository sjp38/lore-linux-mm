Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 79D166B006E
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 13:44:57 -0500 (EST)
Received: by pablf10 with SMTP id lf10so37959823pab.12
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 10:44:57 -0800 (PST)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id gj9si7981912pbc.35.2015.02.24.10.44.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 24 Feb 2015 10:44:55 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NKA0089HHLEF650@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 24 Feb 2015 18:48:50 +0000 (GMT)
From: Stefan Strogin <s.strogin@partner.samsung.com>
Subject: [PATCH v3 0/4] mm: cma: add some debug information for CMA
Date: Tue, 24 Feb 2015 21:44:31 +0300
Message-id: <cover.1424802755.git.s.strogin@partner.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Stefan Strogin <s.strogin@partner.samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

Hi all.

Here is the third version of a patch set that adds some debugging facility for
CMA.

This patch set is based on v4.0-rc1 and Sasha Levin's patch set
"mm: cma: debugfs access to CMA" v5 [1].
It is also available on git:
git://github.com/stefanstrogin/linux -b cmainfo-v3

We want an interface to see a list of currently allocated CMA buffers and some
useful information about them (like /proc/vmallocinfo but for physically
contiguous buffers allocated with CMA).

For example. We want a big (megabytes) CMA buffer to be allocated in runtime
in default CMA region. If someone already uses CMA then the big allocation
could fail. If it happened then with such an interface we could find who used
CMA at the moment of failure, who caused fragmentation and so on. Ftrace also
would be helpful here, but with ftrace we can see the whole history of
allocations and releases, whereas with this patch set we can see a snapshot of
CMA region with actual information about its allocations.

These patches add some files to debugfs when CONFIG_CMA_DEBUGFS is enbled.

/sys/kernel/debug/cma/cma-<N>/used and cma/cma-<N>/maxchunk are added to show
used size in pages and the biggest free chunk in each CMA region.

When CONFIG_CMA_BUFFER_LIST is enabled (depended on CONFIG_CMA_DEBUGFS)
/sys/kernel/debug/cma/cma-<N>/buffers is added. It contains a list of
currently allocated contiguous buffers for each CMA region (N stands for
region number). Format is:
<base_phys_addr> - <end_phys_addr> (<size> kB), allocated by <PID> (<comm>)

Another added option is CONFIG_CMA_ALLOC_STACKTRACE. When it's enabled then
stack traces are also saved when the allocations are made. The stack traces
are added to each entry in cma/cma-<N>/buffers (see an example [3]). This
can be used to see who and whence allocated each buffer.

Also added trace events for cma_alloc() and cma_release().

Changes from v2 (https://lkml.org/lkml/2015/2/12/647):
- Rebased on v4.0-rc1 and Sasha Levin's patch set v5 [1].
- Changed kmalloc() to vmalloc() in cma_buffer_list_read().
- Added CONFIG_CMA_BUFFER_LIST and CONFIG_CMA_ALLOC_STACKTRACE.
- Considered order_per_bit for returning page number in cma_get_used() and
  cma_get_maxchunk().
- Reordered the patches to make the one with trace events indepentent of
  others.
- Moved the prototypes of cma_buffer_list_add() and cma_buffer_list_del()
  from include/linux/cma.h to mm/cma.h.
- Various small changes.

Changes from v1 (aka "mm: cma: add /proc/cmainfo")
(https://lkml.org/lkml/2014/12/26/95):
- Rebased on v3.19 and Sasha Levin's patch set v4 [2].
- Moved debug code from cma.c to cma_debug.c.
- Moved cmainfo to debugfs and splited it by CMA region.
- Splited 'cmainfo' into 'buffers', 'used' and 'maxchunk'.
- Used CONFIG_CMA_DEBUGFS instead of CONFIG_CMA_DEBUG.
- Added trace events for cma_alloc() and cma_release().
- Don't use seq_files.
- A small change of debug output in cma_release().
- cma_buffer_list_del() now supports releasing chunks which ranges don't match
  allocations. E.g. we have buffer1: [0x0, 0x1], buffer2: [0x2, 0x3], then
  cma_buffer_list_del(cma, 0x1 /*or 0x0*/, 1 /*(or 2 or 3)*/) should work.
- Various small changes.

[1] https://lkml.org/lkml/2015/2/12/657

[2] https://lkml.org/lkml/2015/1/28/755

[3] root@debian:/sys/kernel/debug/cma# cat cma-0/buffers
0x2f400000 - 0x2f417000 (92 kB), allocated by pid 1 (swapper/0)
 [<c1142c4b>] cma_alloc+0x1bb/0x200
 [<c143d28a>] dma_alloc_from_contiguous+0x3a/0x40
 [<c10079d9>] dma_generic_alloc_coherent+0x89/0x160
 [<c14456ce>] dmam_alloc_coherent+0xbe/0x100
 [<c1487312>] ahci_port_start+0xe2/0x210
 [<c146e0e0>] ata_host_start.part.28+0xc0/0x1a0
 [<c1473650>] ata_host_activate+0xd0/0x110
 [<c14881bf>] ahci_host_activate+0x3f/0x170
 [<c14854e4>] ahci_init_one+0x764/0xab0
 [<c12e415f>] pci_device_probe+0x6f/0xd0
 [<c14378a8>] driver_probe_device+0x68/0x210
 [<c1437b09>] __driver_attach+0x79/0x80
 [<c1435eef>] bus_for_each_dev+0x4f/0x80
 [<c143749e>] driver_attach+0x1e/0x20
 [<c1437197>] bus_add_driver+0x157/0x200
 [<c14381bd>] driver_register+0x5d/0xf0
<...> 
0x2f41b000 - 0x2f41c000 (4 kB), allocated by pid 1264 (NetworkManager)
 [<c1142c4b>] cma_alloc+0x1bb/0x200
 [<c143d28a>] dma_alloc_from_contiguous+0x3a/0x40
 [<c10079d9>] dma_generic_alloc_coherent+0x89/0x160
 [<c14c5d13>] e1000_setup_all_tx_resources+0x93/0x540
 [<c14c8021>] e1000_open+0x31/0x120
 [<c16264cf>] __dev_open+0x9f/0x130
 [<c16267ce>] __dev_change_flags+0x8e/0x150
 [<c16268b8>] dev_change_flags+0x28/0x60
 [<c1633ee0>] do_setlink+0x2a0/0x760
 [<c1634acb>] rtnl_newlink+0x60b/0x7b0
 [<c16314f4>] rtnetlink_rcv_msg+0x84/0x1f0
 [<c164b58e>] netlink_rcv_skb+0x8e/0xb0
 [<c1631461>] rtnetlink_rcv+0x21/0x30
 [<c164af7a>] netlink_unicast+0x13a/0x1d0
 [<c164b250>] netlink_sendmsg+0x240/0x3e0
 [<c160cbfd>] do_sock_sendmsg+0xbd/0xe0
<...>


Dmitry Safonov (1):
  mm: cma: add functions to get region pages counters

Stefan Strogin (3):
  mm: cma: add trace events to debug physically-contiguous memory
    allocations
  mm: cma: add number of pages to debug message in cma_release()
  mm: cma: add list of currently allocated CMA buffers to debugfs

 include/linux/cma.h        |   2 +
 include/trace/events/cma.h |  57 ++++++++++++++
 mm/Kconfig                 |  17 +++++
 mm/cma.c                   |  45 +++++++++++-
 mm/cma.h                   |  26 +++++++
 mm/cma_debug.c             | 180 +++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 326 insertions(+), 1 deletion(-)
 create mode 100644 include/trace/events/cma.h

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
