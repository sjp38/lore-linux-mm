Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id E9E316B0070
	for <linux-mm@kvack.org>; Fri, 24 May 2013 05:37:34 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 0/4] Support hot-remove local pagetable pages.
Date: Fri, 24 May 2013 17:30:03 +0800
Message-Id: <1369387807-17956-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, mingo@redhat.com, hpa@zytor.com, minchan@kernel.org, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, yinghai@kernel.org, jiang.liu@huawei.com, tj@kernel.org, liwanp@linux.vnet.ibm.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

The following patch-set from Yinghai allocates pagetables to local nodes.
v1: https://lkml.org/lkml/2013/3/7/642
v2: https://lkml.org/lkml/2013/3/10/47
v3: https://lkml.org/lkml/2013/4/4/639
v4: https://lkml.org/lkml/2013/4/11/829

Since pagetable pages are used by the kernel, they cannot be offlined.
As a result, they cannot be hot-remove.

This patch fix this problem with the following solution:

     1.   Introduce a new bootmem type LOCA_NODE_DATAL, and register local 
          pagetable pages as LOCA_NODE_DATAL by setting page->lru.next to
          LOCA_NODE_DATAL, just like we register SECTION_INFO pages.

     2.   Skip LOCA_NODE_DATAL pages in offline/online procedures. When the 
          whole memory block they reside in is offlined, the kernel can 
          still access the pagetables.
          (This changes the semantics of offline/online a little bit.)

     3.   Do not free LOCA_NODE_DATAL pages to buddy system because they 
          were skipped when in offline/online procedures. The memory block 
          they reside in could have been offlined.

Anyway, this problem should be fixed. Any better idea is welcome.

Tang Chen (4):
  bootmem, mem-hotplug: Register local pagetable pages with
    LOCAL_NODE_DATA when freeing bootmem.
  mem-hotplug: Skip LOCAL_NODE_DATA pages in memory offline procedure.
  mem-hotplug: Skip LOCAL_NODE_DATA pages in memory online procedure.
  mem-hotplug: Do not free LOCAL_NODE_DATA pages to buddy system in
    hot-remove procedure.

 arch/x86/mm/init_64.c          |    2 +
 include/linux/memblock.h       |   22 +++++++++++++++++
 include/linux/memory_hotplug.h |   13 ++++++++-
 mm/memblock.c                  |   52 ++++++++++++++++++++++++++++++++++++++++
 mm/memory_hotplug.c            |   42 +++++++++++++++++++++++++++++++-
 mm/page_alloc.c                |   18 ++++++++++++-
 mm/page_isolation.c            |    6 ++++
 7 files changed, 150 insertions(+), 5 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
