Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id F37026B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 03:46:07 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u101so4036330wrc.2
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 00:46:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h76sor629212wme.6.2017.06.08.00.46.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Jun 2017 00:46:06 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/4] more sensible hugetlb migration for hotplug/CMA
Date: Thu,  8 Jun 2017 09:45:49 +0200
Message-Id: <20170608074553.22152-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, zhong jiang <zhongjiang@huawei.com>, Joonsoo Kim <js1304@gmail.com>, LKML <linux-kernel@vger.kernel.org>

Hi,
I have received a bug report for memory hotplug triggered hugetlb
migration on a distribution kernel but the very same issue is still
present in the current upstream code. The bug is described in patch
2 but in short the issue is that new_node_page doesn't really try to
consume preallocated hugetlb pages in the pool on other than the next
node which is really suboptimal. This results in very likely failures of
memory hotremove even though there are many hugetlb pages in the pool.
I think it is fair to call this a bug.

Patches 1 and 3 are cleanups and the last patch is still a RFC because
I am not sure we really need/want to go that way. The thing is that the
page allocator relies on zonelists to do the proper allocation fallback
wrt. numa distances.  We do not have anything like that for hugetlb
allocations because they are not zone aware in general. Making them
fully zonlist (or alternately nodelist) aware is quite a large project
I guess. Instead I admittedly went the path of least resistance and
instead provided a much simpler approach. More on that in patch 4.  If
this doesn't seem good enough I will drop it from the series but to me
it looks like a reasonable compromise code wise.

Thoughts, ideas, objections?

Diffstat
 include/linux/hugetlb.h  |  3 +++
 include/linux/migrate.h  | 17 +++++++++++++++++
 include/linux/nodemask.h | 20 ++++++++++++++++++++
 mm/hugetlb.c             | 30 ++++++++++++++++++++++++++++++
 mm/memory_hotplug.c      | 25 ++++++-------------------
 mm/page_isolation.c      | 18 ++----------------
 6 files changed, 78 insertions(+), 35 deletions(-)

Shortlog
Michal Hocko (4):
      mm, memory_hotplug: simplify empty node mask handling in new_node_page
      hugetlb, memory_hotplug: prefer to use reserved pages for migration
      mm: unify new_node_page and alloc_migrate_target
      hugetlb: add support for preferred node to alloc_huge_page_nodemask


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
