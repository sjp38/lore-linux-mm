Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 71D0C6B004D
	for <linux-mm@kvack.org>; Sun, 18 Nov 2012 11:09:15 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so3069609pad.14
        for <linux-mm@kvack.org>; Sun, 18 Nov 2012 08:09:14 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFT PATCH v1 0/5] fix up inaccurate zone->present_pages
Date: Mon, 19 Nov 2012 00:07:25 +0800
Message-Id: <1353254850-27336-1-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <20121115112454.e582a033.akpm@linux-foundation.org>
References: <20121115112454.e582a033.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Wen Congyang <wency@cn.fujitsu.com>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The commit 7f1290f2f2a4 ("mm: fix-up zone present pages") tries to
resolve an issue caused by inaccurate zone->present_pages, but that
fix is incomplete and causes regresions with HIGHMEM. And it has been
reverted by commit 
5576646 revert "mm: fix-up zone present pages"

This is a following-up patchset for the issue above. It introduces a
new field named "managed_pages" to struct zone, which counts pages
managed by the buddy system from the zone. And zone->present_pages
is used to count pages existing in the zone, which is
	spanned_pages - absent_pages.

But that way, zone->present_pages will be kept in consistence with
pgdat->node_present_pages, which is sum of zone->present_pages.

This patchset has only been tested on x86_64 with nobootmem.c. So need
help to test this patchset on machines:
1) use bootmem.c
2) have highmem

This patchset applies to "f4a75d2e Linux 3.7-rc6" from
git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git

Any comments and helps are welcomed!

Jiang Liu (5):
  mm: introduce new field "managed_pages" to struct zone
  mm: replace zone->present_pages with zone->managed_pages if
    appreciated
  mm: set zone->present_pages to number of existing pages in the zone
  mm: provide more accurate estimation of pages occupied by memmap
  mm: increase totalram_pages when free pages allocated by bootmem
    allocator

 include/linux/mmzone.h |    1 +
 mm/bootmem.c           |   14 ++++++++
 mm/memory_hotplug.c    |    6 ++++
 mm/mempolicy.c         |    2 +-
 mm/nobootmem.c         |   15 ++++++++
 mm/page_alloc.c        |   89 +++++++++++++++++++++++++++++++-----------------
 mm/vmscan.c            |   16 ++++-----
 mm/vmstat.c            |    8 +++--
 8 files changed, 108 insertions(+), 43 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
