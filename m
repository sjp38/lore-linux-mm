Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 388CD900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 09:11:34 -0400 (EDT)
Received: by padj3 with SMTP id j3so29492369pad.0
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 06:11:34 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id kf7si5784847pab.234.2015.06.04.06.11.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 04 Jun 2015 06:11:33 -0700 (PDT)
Message-ID: <55704A7E.5030507@huawei.com>
Date: Thu, 4 Jun 2015 20:54:22 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC PATCH 00/12] mm: mirrored memory support for page buddy allocations
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas
 Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>
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

This patchset can support the feature after boot time. It introduces mirror_info
to save the mirrored memory range. Then use __GFP_MIRROR to allocate mirrored 
pages. 

I think add a new migratetype is btter and easier than a new zone, so I use
MIGRATE_MIRROR to manage the mirrored pages. However it changed some code in the
core file, please review and comment, thanks.

TBD: 
1) call add_mirror_info() to fill mirrored memory info.
2) add compatibility with memory online/offline.
3) add more interface? others?

Xishi Qiu (12):
  mm: add a new config to manage the code
  mm: introduce mirror_info
  mm: introduce MIGRATE_MIRROR to manage the mirrored pages
  mm: add mirrored pages to buddy system
  mm: introduce a new zone_stat_item NR_FREE_MIRROR_PAGES
  mm: add free mirrored pages info
  mm: introduce __GFP_MIRROR to allocate mirrored pages
  mm: use mirrorable to switch allocate mirrored memory
  mm: enable allocate mirrored memory at boot time
  mm: add the buddy system interface
  mm: add the PCP interface
  mm: let slab/slub/slob use mirrored memory

 arch/x86/mm/numa.c     |   3 ++
 drivers/base/node.c    |  17 ++++---
 fs/proc/meminfo.c      |   6 +++
 include/linux/gfp.h    |   5 +-
 include/linux/mmzone.h |  23 +++++++++
 include/linux/vmstat.h |   2 +
 kernel/sysctl.c        |   9 ++++
 mm/Kconfig             |   8 +++
 mm/page_alloc.c        | 134 ++++++++++++++++++++++++++++++++++++++++++++++---
 mm/slab.c              |   3 +-
 mm/slob.c              |   2 +-
 mm/slub.c              |   2 +-
 mm/vmstat.c            |   4 ++
 13 files changed, 202 insertions(+), 16 deletions(-)

-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
