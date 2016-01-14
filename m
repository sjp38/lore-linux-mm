Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id DE1E5828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 00:24:26 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id uo6so354974671pac.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:24:26 -0800 (PST)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id 29si6901299pfk.107.2016.01.13.21.24.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 21:24:26 -0800 (PST)
Received: by mail-pa0-x243.google.com with SMTP id gi1so35229176pac.2
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:24:26 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 00/16] mm/slab: introduce new freed objects management way, OBJFREELIST_SLAB
Date: Thu, 14 Jan 2016 14:24:13 +0900
Message-Id: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

This patchset implements new freed object management way, that is,
OBJFREELIST_SLAB. Purpose of it is to reduce memory overhead in SLAB.

SLAB needs a array to manage freed objects in a slab. If there is
leftover after objects are packed into a slab, we can use it as
a management array, and, in this case, there is no memory waste.
But, in the other cases, we need to allocate extra memory for
a management array or utilize dedicated internal memory in a slab for it.
Both cases causes memory waste so it's not good.

With this patchset, freed object itself can be used for a management
array. So, memory waste could be reduced. Detailed idea and numbers
are described in last patch's commit description. Please refer it.

In fact, I tested another idea implementing OBJFREELIST_SLAB with
extendable linked array through another freed object. It can remove
memory waste completely but it causes more computational overhead
in critical lock path and it seems that overhead outweigh benefit.
So, this patchset doesn't include it. I will attach prototype just for
a reference.

This patchset is based on next-20151231.

Thanks.

Joonsoo Kim (16):
  mm/slab: fix stale code comment
  mm/slab: remove useless structure define
  mm/slab: remove the checks for slab implementation bug
  mm/slab: activate debug_pagealloc in SLAB when it is actually enabled
  mm/slab: use more appropriate condition check for debug_pagealloc
  mm/slab: clean-up DEBUG_PAGEALLOC processing code
  mm/slab: alternative implementation for DEBUG_SLAB_LEAK
  mm/slab: remove object status buffer for DEBUG_SLAB_LEAK
  mm/slab: put the freelist at the end of slab page
  mm/slab: align cache size first before determination of OFF_SLAB
    candidate
  mm/slab: clean-up cache type determination
  mm/slab: do not change cache size if debug pagealloc isn't possible
  mm/slab: make criteria for off slab determination robust and simple
  mm/slab: factor out slab list fixup code
  mm/slab: factor out debugging initialization in cache_init_objs()
  mm/slab: introduce new slab management type, OBJFREELIST_SLAB

 include/linux/slab_def.h |   3 +
 mm/slab.c                | 620 ++++++++++++++++++++++++++---------------------
 2 files changed, 350 insertions(+), 273 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
