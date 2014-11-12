Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1B3596B00E3
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 03:25:07 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id r10so11811313pdi.30
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 00:25:06 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id xd1si22118520pab.234.2014.11.12.00.25.04
        for <linux-mm@kvack.org>;
        Wed, 12 Nov 2014 00:25:05 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 0/5] Resurrect and use struct page extension for some debugging features
Date: Wed, 12 Nov 2014 17:27:10 +0900
Message-Id: <1415780835-24642-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Alexander Nyberg <alexn@dsv.su.se>, Dave Hansen <dave@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Jungsoo Son <jungsoo.son@lge.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

When we debug something, we'd like to insert some information to
every page. For this purpose, we sometimes modify struct page itself.
But, this has drawbacks. First, it requires re-compile. This makes us
hesitate to use the powerful debug feature so development process is
slowed down. And, second, sometimes it is impossible to rebuild the kernel
due to third party module dependency. At third, system behaviour would be
largely different after re-compile, because it changes size of struct
page greatly and this structure is accessed by every part of kernel.
Keeping this as it is would be better to reproduce errornous situation.

To overcome these drawbacks, we can extend struct page on another place
rather than struct page itself. Until now, memcg uses this technique. But,
now, memcg decides to embed their variable to struct page itself and it's
code to extend struct page has been removed. I'd like to use this code
to develop debug feature, so this series resurrect it.

With resurrecting it, this patchset makes two debugging features boottime
configurable. As mentioned above, rebuild has serious problems. Making
it boottime configurable mitigate these problems with marginal
computational overhead. One of the features, page_owner isn't in mainline
now. But, it is really useful so it is in mm tree for a long time. I think
that it's time to upstream this feature.

Any comments are more than welcome.

This patchset is based on next-20141106 + my two patches related to
debug-pagealloc [1].

[1]: https://lkml.org/lkml/2014/11/7/78

Joonsoo Kim (5):
  mm/page_ext: resurrect struct page extending code for debugging
  mm/debug-pagealloc: prepare boottime configurable on/off
  mm/debug-pagealloc: make debug-pagealloc boottime configurable
  stacktrace: support snprint
  mm/page_owner: keep track of page owners

 arch/powerpc/mm/hash_utils_64.c  |    2 +-
 arch/powerpc/mm/pgtable_32.c     |    2 +-
 arch/s390/mm/pageattr.c          |    2 +-
 arch/sparc/mm/init_64.c          |    2 +-
 arch/x86/mm/pageattr.c           |    2 +-
 include/linux/mm.h               |   35 +++-
 include/linux/mm_types.h         |    4 -
 include/linux/mmzone.h           |   12 ++
 include/linux/page-debug-flags.h |   32 ----
 include/linux/page_ext.h         |   84 +++++++++
 include/linux/page_owner.h       |   19 +++
 include/linux/stacktrace.h       |    3 +
 init/main.c                      |    7 +
 kernel/stacktrace.c              |   24 +++
 lib/Kconfig.debug                |   13 ++
 mm/Kconfig.debug                 |   10 ++
 mm/Makefile                      |    2 +
 mm/debug-pagealloc.c             |   31 +++-
 mm/page_alloc.c                  |   61 ++++++-
 mm/page_ext.c                    |  346 ++++++++++++++++++++++++++++++++++++++
 mm/page_owner.c                  |  206 +++++++++++++++++++++++
 mm/vmstat.c                      |   93 ++++++++++
 tools/vm/Makefile                |    4 +-
 tools/vm/page_owner_sort.c       |  144 ++++++++++++++++
 24 files changed, 1087 insertions(+), 53 deletions(-)
 delete mode 100644 include/linux/page-debug-flags.h
 create mode 100644 include/linux/page_ext.h
 create mode 100644 include/linux/page_owner.h
 create mode 100644 mm/page_ext.c
 create mode 100644 mm/page_owner.c
 create mode 100644 tools/vm/page_owner_sort.c

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
