Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D61CB9000C7
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 03:18:02 -0400 (EDT)
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch 0/5] per-zone dirty limits v3
Date: Fri, 30 Sep 2011 09:17:19 +0200
Message-Id: <1317367044-475-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Chris Mason <chris.mason@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Shaohua Li <shaohua.li@intel.com>, xfs@oss.sgi.com, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

this is the third revision of the per-zone dirty limits.  Changes from
the second version have been mostly documentation, changelog, and
naming fixes based on review feedback:

o add new dirty_balance_reserve instead of abusing totalreserve_pages
  for undirtyable (per-zone) reserves and document the variable and
  its calculation (Mel)
o use !ALLOC_WMARK_LOW instead of adding new ALLOC_SLOWPATH (Mel)
o rename determine_dirtyable_memory -> global_dirtyable_memory (Andrew)
o better explain behaviour on NUMA in changelog (Andrew)
o extend changelogs and code comments on how per-zone dirty limits are
  calculated, and why, and their proportions to the global limit (Mel, Andrew)
o kernel-doc zone_dirty_ok() (Andrew)
o extend changelogs and code comments on how per-zone dirty limits are
  used to protect zones from dirty pages (Mel, Andrew)
o revert back to a separate set of zone_dirtyable_memory() and zone_dirty_limit()
  for easier reading (Andrew)

Based on v3.1-rc3-mmotm-2011-08-24-14-08.

 fs/btrfs/file.c           |    2 +-
 include/linux/gfp.h       |    4 +-
 include/linux/mmzone.h    |    6 ++
 include/linux/swap.h      |    1 +
 include/linux/writeback.h |    1 +
 mm/filemap.c              |    5 +-
 mm/page-writeback.c       |  181 +++++++++++++++++++++++++++++++++------------
 mm/page_alloc.c           |   48 ++++++++++++
 8 files changed, 197 insertions(+), 51 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
