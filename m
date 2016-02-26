Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id A62716B0009
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 01:01:32 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id fl4so45430738pad.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:01:32 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id h78si17597693pfj.67.2016.02.25.22.01.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 22:01:31 -0800 (PST)
Received: by mail-pa0-x22a.google.com with SMTP id yy13so45388356pab.3
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:01:31 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH v2 00/17] mm/slab: introduce new freed objects management way, OBJFREELIST_SLAB
Date: Fri, 26 Feb 2016 15:01:07 +0900
Message-Id: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

This submission is just intended to get more review if possible.
This patchset is already on mmotm for a month and there is
no problem at all. No changes from mmotm one.

Changes from v1:
o Fold fixes into corresponding ones (no difference from mmotm)
o Add a clean-up patch at last per Christoph's comment

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

Thanks.

Joonsoo Kim (17):
  mm/slab: fix stale code comment
  mm/slab: remove useless structure define
  mm/slab: remove the checks for slab implementation bug
  mm/slab: activate debug_pagealloc in SLAB when it is actually enabled
  mm/slab: use more appropriate condition check for debug_pagealloc
  mm/slab: clean up DEBUG_PAGEALLOC processing code
  mm/slab: alternative implementation for DEBUG_SLAB_LEAK
  mm/slab: remove object status buffer for DEBUG_SLAB_LEAK
  mm/slab: put the freelist at the end of slab page
  mm/slab: align cache size first before determination of OFF_SLAB
    candidate
  mm/slab: clean up cache type determination
  mm/slab: do not change cache size if debug pagealloc isn't possible
  mm/slab: make criteria for off slab determination robust and simple
  mm/slab: factor out slab list fixup code
  mm/slab: factor out debugging initialization in cache_init_objs()
  mm/slab: introduce new slab management type, OBJFREELIST_SLAB
  mm/slab: avoid returning values by reference

 include/linux/mm.h       |  12 +-
 include/linux/slab_def.h |   3 +
 mm/slab.c                | 626 ++++++++++++++++++++++++++---------------------
 3 files changed, 362 insertions(+), 279 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
