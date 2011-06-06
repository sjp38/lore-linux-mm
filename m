Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 06F476B0114
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 00:21:48 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p564Ldw0015909
	for <linux-mm@kvack.org>; Sun, 5 Jun 2011 21:21:40 -0700
Received: from pxi20 (pxi20.prod.google.com [10.243.27.20])
	by kpbe17.cbf.corp.google.com with ESMTP id p564LcsN010886
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 5 Jun 2011 21:21:38 -0700
Received: by pxi20 with SMTP id 20so2740363pxi.27
        for <linux-mm@kvack.org>; Sun, 05 Jun 2011 21:21:38 -0700 (PDT)
Date: Sun, 5 Jun 2011 21:21:28 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 0/14] mm: tmpfs and trunc changes, affecting drm
Message-ID: <alpine.LSU.2.00.1106052116350.17116@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Chris Wilson <chris@chris-wilson.co.uk>, Keith Packard <keithp@keithp.com>, Thomas Hellstrom <thellstrom@vmware.com>, Dave Airlie <airlied@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Here's v2 patchset for mmotm, based on 30-rc1.  Nothing exciting,
mostly cleanup, preparation for what will probably be two more
patchsets coming over the next few weeks, first simplifying tmpfs
by getting rid of its ->readpage (give it a splice instead), then
getting rid of its peculiar swap index (use radix_tree instead).

The ordering here is somewhat illogical, arranged in the hope that
at least the first four can get into 30-rc, which would simplify
the dependencies between linux-next and mmotm.

Changes since last week's v1:
- removed the original 1/14, which was adding cleancache_flush_inode()
  into invalidate_mapping_pages(): I stand by that patch, but feedback
  from Dan Magenheimer and Chris Mason implies that cleancache has a
  bigger problem in this area (flushing too much or too little, unable
  to distinguish truncate from evict, potential issue with O_DIRECT)
  which we shall discuss and deal with separately.
- incorporated feedback from Christoph Hellwig, mainly electing for
  an explicit call to shmem_truncate_range() from drm/i915, which
  will also help if we replace ->truncate_range by ->fallocate later;
  so a new 2/14 which moves shmem function prototypes into shmem_fs.h.

1,2,3,4 affect the interface between tmpfs and drm very slightly.
Once they're in 30-rc, drm maintainers could take 5,6,7,8 out of
mmotm and into linux-next (or even 30-rc).

 1/14 mm: move vmtruncate_range to truncate.c
 2/14 mm: move shmem prototypes to shmem_fs.h
 3/14 tmpfs: take control of its truncate_range
 4/14 tmpfs: add shmem_read_mapping_page_gfp
 5/14 drm/ttm: use shmem_read_mapping_page
 6/14 drm/i915: use shmem_read_mapping_page
 7/14 drm/i915: use shmem_truncate_range
 8/14 drm/i915: more struct_mutex locking
 9/14 mm: cleanup descriptions of filler arg
10/14 mm: truncate functions are in truncate.c
11/14 mm: tidy vmtruncate_range and related functions
12/14 mm: consistent truncate and invalidate loops
13/14 mm: pincer in truncate_inode_pages_range
14/14 tmpfs: no need to use i_lock

 drivers/gpu/drm/drm_gem.c            |    1 
 drivers/gpu/drm/i915/i915_dma.c      |    3 
 drivers/gpu/drm/i915/i915_gem.c      |   38 ++---
 drivers/gpu/drm/i915/intel_overlay.c |    5 
 drivers/gpu/drm/ttm/ttm_tt.c         |    5 
 include/linux/mm.h                   |    3 
 include/linux/pagemap.h              |   12 -
 include/linux/shmem_fs.h             |   21 +++
 include/linux/swap.h                 |   10 -
 mm/filemap.c                         |   14 +-
 mm/memcontrol.c                      |    1 
 mm/memory.c                          |   24 ---
 mm/shmem.c                           |   88 +++++++++----
 mm/swapfile.c                        |    2 
 mm/truncate.c                        |  159 +++++++++++++------------
 15 files changed, 206 insertions(+), 180 deletions(-)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
