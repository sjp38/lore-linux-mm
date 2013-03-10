Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 8BB6D6B004D
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 04:08:30 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id uo15so2659101pbc.5
        for <linux-mm@kvack.org>; Sun, 10 Mar 2013 00:08:29 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part2 00/10] simplify initialization of highmem pages
Date: Sun, 10 Mar 2013 16:01:00 +0800
Message-Id: <1362902470-25787-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The original goal of this patchset is to fix the bug reported by
https://bugzilla.kernel.org/show_bug.cgi?id=53501
Now it has also been expanded to reduce common code used by memory
initializion.

This is the second part, which applies to the previous part at:
http://marc.info/?l=linux-mm&m=136289696323825&w=2

It introduces a helper function free_highmem_page() to free highmem
pages into the buddy system when initializing mm subsystem.
Introduction of free_highmem_page() is one step forward to clean up
accesses and modificaitons of totalhigh_pages, totalram_pages and
zone->managed_pages etc. I hope we could remove all references to
totalhigh_pages from the arch/ subdirectory.

We have only tested these patchset on x86 platforms, and have done basic
compliation tests using cross-compilers from ftp.kernel.org. That means
some code may not pass compilation on some architectures. So any help
to test this patchset are welcomed!

There are several other parts still under development:
Part3: refine code to manage totalram_pages, totalhigh_pages and
	zone->managed_pages
Part4: introduce helper functions to simplify mem_init() and remove the
	global variable num_physpages.

Jiang Liu (10):
  mm: introduce free_highmem_page() helper to free highmem pages into
    buddy system
  mm/ARM: use free_highmem_page() to free highmem pages into buddy
    system
  mm/FRV: use free_highmem_page() to free highmem pages into buddy
    system
  mm/metag: use free_highmem_page() to free highmem pages into buddy
    system
  mm/microblaze: use free_highmem_page() to free highmem pages into
    buddy system
  mm/MIPS: use free_highmem_page() to free highmem pages into buddy
    system
  mm/PPC: use free_highmem_page() to free highmem pages into buddy
    system
  mm/SPARC: use free_highmem_page() to free highmem pages into buddy
    system
  mm/um: use free_highmem_page() to free highmem pages into buddy
    system
  mm/x86: use free_highmem_page() to free highmem pages into buddy
    system

 arch/arm/mm/init.c        |    7 ++-----
 arch/frv/mm/init.c        |    6 ++----
 arch/metag/mm/init.c      |   10 ++--------
 arch/microblaze/mm/init.c |    6 +-----
 arch/mips/mm/init.c       |    6 +-----
 arch/powerpc/mm/mem.c     |    6 +-----
 arch/sparc/mm/init_32.c   |   12 ++----------
 arch/um/kernel/mem.c      |   16 +++-------------
 arch/x86/mm/highmem_32.c  |    1 -
 arch/x86/mm/init_32.c     |   10 +---------
 include/linux/mm.h        |    7 +++++++
 mm/page_alloc.c           |    9 +++++++++
 12 files changed, 31 insertions(+), 65 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
