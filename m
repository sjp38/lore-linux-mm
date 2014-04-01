Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 026796B0035
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 03:38:54 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id q8so6620061lbi.14
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 00:38:54 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id le2si10216912lbc.61.2014.04.01.00.38.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Apr 2014 00:38:53 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 0/2] cleanup kmemcg charging (was: "kmemcg: get rid of __GFP_KMEMCG")
Date: Tue, 1 Apr 2014 11:38:43 +0400
Message-ID: <cover.1396335798.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, gthelen@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

Hi,

Currently we charge kmem to memcg in alloc_pages if __GFP_KMEMCG is
passed. However, since there are only a few places where we actually
want to charge kmem, we could call kmemcg charge function explicitly
instead. That would remove all kmemcg-related stuff from the general
allocation path and make all kmem charges easier to follow.

So let's charge kmem explicitly where we want it to be charged (slab,
threadinfo) and remove __GFP_KMEMCG.

Changes in v2:
 - use static key optimization in memcg_(un)charge_slab to avoid any
   overhead if kmemcg is not used;
 - introduce helper functions, alloc/free_kmem_pages, which charge newly
   allocated pages to kmemcg, to avoid code duplication;
 - do not remove accounting of kmalloc_large allocations (as discussed in the
   comments to v1).

v1 can be found at lkml.org/lkml/2014/3/26/228

Thanks,

Vladimir Davydov (2):
  sl[au]b: charge slabs to kmemcg explicitly
  mm: get rid of __GFP_KMEMCG

 include/linux/gfp.h             |   10 ++++---
 include/linux/memcontrol.h      |   17 ++++--------
 include/linux/slab.h            |   11 --------
 include/linux/thread_info.h     |    2 --
 include/trace/events/gfpflags.h |    1 -
 kernel/fork.c                   |    6 ++---
 mm/memcontrol.c                 |    4 +--
 mm/page_alloc.c                 |   56 ++++++++++++++++++++++++---------------
 mm/slab.c                       |    7 ++++-
 mm/slab.h                       |   29 ++++++++++++++++++++
 mm/slab_common.c                |   18 +++++++++----
 mm/slub.c                       |   30 ++++++++++++++-------
 12 files changed, 119 insertions(+), 72 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
