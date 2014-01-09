Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id B73366B0031
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 02:04:33 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id kx10so2916759pab.36
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 23:04:33 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id eb3si2955614pbd.257.2014.01.08.23.04.30
        for <linux-mm@kvack.org>;
        Wed, 08 Jan 2014 23:04:32 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 0/7] improve robustness on handling migratetype
Date: Thu,  9 Jan 2014 16:04:40 +0900
Message-Id: <1389251087-10224-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jiang Liu <jiang.liu@huawei.com>, Mel Gorman <mgorman@suse.de>, Cody P Schafer <cody@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Andi Kleen <ak@linux.intel.com>, Wei Yongjun <yongjun_wei@trendmicro.com.cn>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hello,

I found some weaknesses on handling migratetype during code review and
testing CMA.

First, we don't have any synchronization method on get/set pageblock
migratetype. When we change migratetype, we hold the zone lock. So
writer-writer race doesn't exist. But while someone changes migratetype,
others can get migratetype. This may introduce totally unintended value
as migratetype. Although I haven't heard of any problem report about
that, it is better to protect properly.

Second, (get/set)_freepage_migrate isn't used properly. I guess that it
would be introduced for per cpu page(pcp) performance, but, it is also
used by memory isolation, now. For that case, the information isn't
enough to use, so we need to fix it.

Third, there is the problem on buddy allocator. It doesn't consider
migratetype when merging buddy, so pages from cma or isolate region can
be moved to other migratetype freelist. It makes CMA failed over and over.
To prevent it, the buddy allocator should consider migratetype if
CMA/ISOLATE is enabled.

This patchset is aimed at fixing these problems and based on v3.13-rc7.

Thanks.

Joonsoo Kim (7):
  mm/page_alloc: synchronize get/set pageblock
  mm/cma: fix cma free page accounting
  mm/page_alloc: move set_freepage_migratetype() to better place
  mm/isolation: remove invalid check condition
  mm/page_alloc: separate interface to set/get migratetype of freepage
  mm/page_alloc: store freelist migratetype to the page on buddy
    properly
  mm/page_alloc: don't merge MIGRATE_(CMA|ISOLATE) pages on buddy

 include/linux/mm.h             |   35 +++++++++++++++++++++---
 include/linux/mmzone.h         |    2 ++
 include/linux/page-isolation.h |    1 -
 mm/page_alloc.c                |   59 ++++++++++++++++++++++++++--------------
 mm/page_isolation.c            |    5 +---
 5 files changed, 73 insertions(+), 29 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
