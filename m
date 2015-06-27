Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f50.google.com (mail-vn0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id A2E516B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 22:28:50 -0400 (EDT)
Received: by vnbg129 with SMTP id g129so17961464vnb.2
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 19:28:50 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id g20si5198279vdu.74.2015.06.26.19.28.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 26 Jun 2015 19:28:49 -0700 (PDT)
Message-ID: <558E084A.60900@huawei.com>
Date: Sat, 27 Jun 2015 10:19:54 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC v2 PATCH 0/8] mm: mirrored memory support for page buddy allocations
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, "Luck, Tony" <tony.luck@intel.com>, Hanjun Guo <guohanjun@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>, leon@leon.nu, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Intel Xeon processor E7 v3 product family-based platforms introduces support
for partial memory mirroring called as 'Address Range Mirroring'. This feature
allows BIOS to specify a subset of total available memory to be mirrored (and
optionally also specify whether to mirror the range 0-4 GB). This capability
allows user to make an appropriate tradeoff between non-mirrored memory range
and mirrored memory range thus optimizing total available memory and still
achieving highly reliable memory range for mission critical workloads and/or
kernel space.

Tony has already send a patchset to supprot this feature at boot time.
https://lkml.org/lkml/2015/5/8/521
This patchset is based on Tony's, it can support the feature after boot time.
Use mirrored memory for all kernel allocations.

TBD: 
  - Add compatibility with memory online/offline, memory compaction, CMA...
  - Need to discuss the implementation ideas, add a new zone or a new
    migratetype or others.

V2:
  - Use memblock which marked MEMBLOCK_MIRROR to find mirrored memory instead
    of mirror_info.
  - Remove __GFP_MIRROR and /proc/sys/vm/mirrorable.
  - Use mirrored memory for all kernel allocations.


Xishi Qiu (8):
  mm: add a new config to manage the code
  mm: introduce MIGRATE_MIRROR to manage the mirrored pages
  mm: find mirrored memory in memblock
  mm: add mirrored memory to buddy system
  mm: introduce a new zone_stat_item NR_FREE_MIRROR_PAGES
  mm: add free mirrored pages info
  mm: add the buddy system interface
  mm: add the PCP interface

 drivers/base/node.c      |  17 ++++---
 fs/proc/meminfo.c        |   6 +++
 include/linux/memblock.h |  29 ++++++++++--
 include/linux/mmzone.h   |  10 ++++
 include/linux/vmstat.h   |   2 +
 mm/Kconfig               |   8 ++++
 mm/memblock.c            |  33 +++++++++++--
 mm/nobootmem.c           |   3 ++
 mm/page_alloc.c          | 117 ++++++++++++++++++++++++++++++++++++-----------
 mm/vmstat.c              |   4 ++
 10 files changed, 190 insertions(+), 39 deletions(-)

-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
