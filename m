Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id CA6986B0031
	for <linux-mm@kvack.org>; Wed, 26 Mar 2014 11:28:11 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id p9so1593107lbv.24
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 08:28:10 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id w4si14677936lad.164.2014.03.26.08.28.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Mar 2014 08:28:09 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 0/4] kmemcg: get rid of __GFP_KMEMCG
Date: Wed, 26 Mar 2014 19:28:03 +0400
Message-ID: <cover.1395846845.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

Hi,

Currently we charge kmem to memcg in alloc_pages if __GFP_KMEMCG is
passed. However, since there are only a few places where we actually
want to charge kmem, we could call kmemcg charge function explicitly
instead. That would remove all kmemcg-related stuff from the general
allocation path and make all kmem charges easier to follow.

So let's charge kmem explicitly where we want it to be charged (slab,
threadinfo) and remove __GFP_KMEMCG.

Thanks,

Vladimir Davydov (4):
  sl[au]b: do not charge large allocations to memcg
  sl[au]b: charge slabs to memcg explicitly
  fork: charge threadinfo to memcg explicitly
  mm: kill __GFP_KMEMCG

 include/linux/gfp.h             |    5 -----
 include/linux/memcontrol.h      |   26 +++++++++++++-----------
 include/linux/slab.h            |    2 +-
 include/linux/thread_info.h     |    2 --
 include/trace/events/gfpflags.h |    1 -
 kernel/fork.c                   |   13 +++++++++---
 mm/memcontrol.c                 |   42 +++++++++++++++------------------------
 mm/page_alloc.c                 |   35 --------------------------------
 mm/slab.c                       |    7 ++++++-
 mm/slab_common.c                |    6 +-----
 mm/slub.c                       |   28 +++++++++++++++++---------
 11 files changed, 67 insertions(+), 100 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
