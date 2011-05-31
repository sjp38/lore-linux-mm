Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DBCB46B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 20:33:40 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p4V0XdIh013244
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:33:39 -0700
Received: from pzk28 (pzk28.prod.google.com [10.243.19.156])
	by wpaz24.hot.corp.google.com with ESMTP id p4V0XaFv002934
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:33:38 -0700
Received: by pzk28 with SMTP id 28so2132618pzk.8
        for <linux-mm@kvack.org>; Mon, 30 May 2011 17:33:36 -0700 (PDT)
Date: Mon, 30 May 2011 17:33:26 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 0/14] mm: tmpfs and trunc changes, affecting drm
Message-ID: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, Keith Packard <keithp@keithp.com>, Thomas Hellstrom <thellstrom@vmware.com>, Dave Airlie <airlied@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Here's a patchset for mmotm, based on 30-rc1.  Nothing exciting,
mostly cleanup, preparation for what will probably be two more
patchsets coming over the next few weeks, first simplifying tmpfs
by getting rid of its ->readpage (give it a splice instead), then
getting rid of its peculiar swap index (use radix_tree instead).

The ordering here is somewhat illogical, arranged in the hope that
at least the first four can get into 30-rc, which would simplify
the dependencies between linux-next and mmotm.

The first is just an independent fix (I think) noticed on the way.
2,3,4 affect the interface between tmpfs and drm very slightly.
Once they're in 30-rc, drm maintainers could take 5,6,7,8 out of
mmotm and into linux-next (or even 30-rc).

 1/14 mm: invalidate_mapping_pages flush cleancache
 2/14 mm: move vmtruncate_range to truncate.c
 3/14 tmpfs: take control of its truncate_range
 4/14 tmpfs: add shmem_read_mapping_page_gfp
 5/14 drm/ttm: use shmem_read_mapping_page
 6/14 drm/i915: use shmem_read_mapping_page
 7/14 drm/i915: adjust to new truncate_range
 8/14 drm/i915: more struct_mutex locking
 9/14 mm: cleanup descriptions of filler arg
10/14 mm: truncate functions are in truncate.c
11/14 mm: tidy vmtruncate_range and related functions
12/14 mm: consistent truncate and invalidate loops
13/14 mm: pincer in truncate_inode_pages_range
14/14 tmpfs: no need to use i_lock

 drivers/gpu/drm/i915/i915_dma.c      |    3 
 drivers/gpu/drm/i915/i915_gem.c      |   36 ++---
 drivers/gpu/drm/i915/intel_overlay.c |    5 
 drivers/gpu/drm/ttm/ttm_tt.c         |    4 
 include/linux/mm.h                   |    3 
 include/linux/pagemap.h              |   22 ++-
 mm/filemap.c                         |   14 +-
 mm/memory.c                          |   24 ---
 mm/shmem.c                           |   79 +++++++-----
 mm/truncate.c                        |  161 +++++++++++++------------
 10 files changed, 185 insertions(+), 166 deletions(-)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
