Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0D39E6B0031
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 05:45:39 -0400 (EDT)
Received: by mail-la0-f48.google.com with SMTP id gf5so4449218lab.7
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 02:45:39 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id h4si11754856lae.214.2014.04.07.02.45.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Apr 2014 02:45:38 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 0/2] slab: cleanup mem hotplug synchronization
Date: Mon, 7 Apr 2014 13:45:33 +0400
Message-ID: <cover.1396857765.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

Hi,

kmem_cache_{create,destroy,shrink} need to get a stable value of
cpu/node online mask, because they init/destroy/access per-cpu/node
kmem_cache parts, which can be allocated or destroyed on cpu/mem
hotplug. To protect against cpu hotplug, these functions use
{get,put}_online_cpus. However, they do nothing to synchronize with
memory hotplug - taking the slab_mutex does not eliminate the
possibility of race as described in patch 2.

What we need there is something like get_online_cpus, but for memory. We
already have lock_memory_hotplug, which serves for the purpose, but it's
a bit of a hammer right now, because it's backed by a mutex. As a
result, it imposes some limitations to locking order, which are not
desirable, and can't be used just like get_online_cpus. That's why in
patch 1 I substitute it with get/put_online_mems, which work exactly
like get/put_online_cpus except they block not cpu, but memory hotplug.

[ v1 can be found at https://lkml.org/lkml/2014/4/6/68. I NAK'ed it by
myself, because it used an rw semaphore for get/put_online_mems, making
them dead lock prune. ]

Thanks,

Vladimir Davydov (2):
  mem-hotplug: implement get/put_online_mems
  slab: lock_memory_hotplug for kmem_cache_{create,destroy,shrink}

 include/linux/memory_hotplug.h |   14 ++--
 include/linux/mmzone.h         |    8 +--
 mm/kmemleak.c                  |    4 +-
 mm/memory-failure.c            |    8 +--
 mm/memory_hotplug.c            |  142 ++++++++++++++++++++++++++++------------
 mm/slab.c                      |   26 +-------
 mm/slab.h                      |    1 +
 mm/slab_common.c               |   35 +++++++++-
 mm/slob.c                      |    3 +-
 mm/slub.c                      |    9 ++-
 mm/vmscan.c                    |    2 +-
 11 files changed, 155 insertions(+), 97 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
