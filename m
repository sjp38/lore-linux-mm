Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f171.google.com (mail-ea0-f171.google.com [209.85.215.171])
	by kanga.kvack.org (Postfix) with ESMTP id DB7DA6B0036
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 17:40:25 -0400 (EDT)
Received: by mail-ea0-f171.google.com with SMTP id n15so749351ead.30
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 14:40:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id x41si127273eee.102.2014.03.13.14.40.22
        for <linux-mm@kvack.org>;
        Thu, 13 Mar 2014 14:40:23 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 0/6] memory error report/recovery for dirty pagecache v3
Date: Thu, 13 Mar 2014 17:39:40 -0400
Message-Id: <1394746786-6397-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org

This patchset tries to solve the following issues related to handling memory
errors on dirty pagecache:
 1. stickiness of error info: in current implementation, the events of
    dirty pagecache memory error are recorded as AS_EIO on page_mapping(page),
    which is not sticky (cleared once checked). As a result, we have a race
    window of ignoring the data lost due to concurrent accesses even if
    your application can handle the error report by itself.
 2. finer granularity: when memory error hits a page of a file, we get the
    error report in accessing to other healthy pages, which is confusing for
    userspace.
 3. overwrite recovery: with fixes on problem 1 and 2, we have a possibility
    to recover from the memory error if applications recreate the date on the
    error page or applications are sure of that data on the error page is not
    important.
These problems are solved by introducing a new pagecache tag to remember
memory errors.

Patch 1 is extending some radix_tree operation to support end parameter,
which is used later.

Patch 2 introduces PAGECACHE_TAG_HWPOISON and solve problem 1 and 2 with it.

Patch 3 implements overwrite recovery to solve problem 3.

Patch 4-6 add a new interface /proc/kpagecache which is helpful when
testing/debugging pagecache related issues like this patchset.
Some sample usespace code and documentation is also added.

I think that we can straightforwardly raplace error reporting for normal
IO error with pagecache tag, and we have a clear benefit of doing so in
finer granurality. And overwrite recovery is also fine for example when
dirty data was lost in write failure. But at first I want review and 
feedback on the base idea.

Previous discussions are available from the URLs:
- v1: http://thread.gmane.org/gmane.linux.kernel/1341433
- v2: http://thread.gmane.org/gmane.linux.kernel.mm/84760

Test code:
  https://github.com/Naoya-Horiguchi/test_memory_error_reporting
---
Summary:

Naoya Horiguchi (6):
      radix-tree: add end_index to support ranged iteration
      mm/memory-failure.c: report and recovery for memory error on dirty pagecache
      mm/memory-failure.c: add code to resolve quasi-hwpoisoned page
      fs/proc/page.c: introduce /proc/kpagecache interface
      tools/vm/page-types.c: add file scanning mode
      Documentation: update Documentation/vm/pagemap.txt

 Documentation/vm/pagemap.txt  |  29 ++++++
 drivers/gpu/drm/qxl/qxl_ttm.c |   2 +-
 fs/proc/page.c                | 106 +++++++++++++++++++
 include/linux/fs.h            |  12 ++-
 include/linux/pagemap.h       |  27 +++++
 include/linux/radix-tree.h    |  31 ++++--
 kernel/irq/irqdomain.c        |   2 +-
 lib/radix-tree.c              |   8 +-
 mm/filemap.c                  |  28 ++++-
 mm/memory-failure.c           | 230 +++++++++++++++++++++++++++++++++++-------
 mm/shmem.c                    |   2 +-
 mm/truncate.c                 |   7 ++
 tools/vm/page-types.c         | 117 ++++++++++++++++++---
 13 files changed, 530 insertions(+), 71 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
