Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id C60636B0069
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 07:50:47 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id v10so4802484pde.22
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 04:50:47 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id cg2si7693405pad.34.2014.10.20.04.50.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Oct 2014 04:50:46 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RESEND 0/4] Simplify cpuset API and fix cpuset check in SL[AU]B
Date: Mon, 20 Oct 2014 15:50:28 +0400
Message-ID: <cover.1413804554.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Zefan Li <lizefan@huawei.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

[Rebased on top of 3.18-rc1 and added acks from Christoph and Zefan]

Hi,

SLAB and SLUB use hardwall cpuset check on fallback alloc, while the
page allocator uses softwall check for all kernel allocations. This may
result in falling into the page allocator even if there are free objects
on other nodes. SLAB algorithm is especially affected: the number of
objects allocated in vain is unlimited, so that they theoretically can
eat up a whole NUMA node. For more details see comments to patches 3, 4.

When I last sent a fix (https://lkml.org/lkml/2014/8/10/100), David
found the whole cpuset API being cumbersome and proposed to simplify it
before getting to fixing its users. So this patch set addresses both
David's complain (patches 1, 2) and the SL[AU]B issues (patches 3, 4).

Reviews are appreciated.

Thanks,

Vladimir Davydov (4):
  cpuset: convert callback_mutex to a spinlock
  cpuset: simplify cpuset_node_allowed API
  slab: fix cpuset check in fallback_alloc
  slub: fix cpuset check in get_any_partial

 include/linux/cpuset.h |   37 +++--------
 kernel/cpuset.c        |  162 +++++++++++++++++-------------------------------
 mm/hugetlb.c           |    2 +-
 mm/oom_kill.c          |    2 +-
 mm/page_alloc.c        |    6 +-
 mm/slab.c              |    2 +-
 mm/slub.c              |    2 +-
 mm/vmscan.c            |    5 +-
 8 files changed, 74 insertions(+), 144 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
