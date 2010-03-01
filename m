From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 00/16] [PATCH 00/15] 512K readahead size with thrashing safe readahead v3
Date: Mon, 01 Mar 2010 13:26:51 +0800
Message-ID: <20100301052651.857984880@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1NlyKP-0004zL-M1
	for glkm-linux-mm-2@m.gmane.org; Mon, 01 Mar 2010 06:38:01 +0100
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id DE3556B0047
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 00:37:56 -0500 (EST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Matt Mackall <mpm@selenic.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Andrew,

This enlarges the default readahead size from 128K to 512K.
To avoid possible regressions, also do
- scale down readahead size on small device and small memory
- thrashing safe context readahead
- add readahead tracing/stats support to help expose possible problems

Besides, the patchset also includes several algorithm updates:
- no start-of-file readahead after lseek
- faster radix_tree_next_hole()/radix_tree_prev_hole()
- pagecache context based mmap read-around


Changes since v2:
- add notes on readahead size
- limit read-around size for small memory system, but don't limit readahead size
- bug fix: allow context readahead async size grow to its full size
- bug fix: let radix_tree_lookup_leaf_node() handle the height=1 case

Changes since v1:
- update mmap read-around heuristics (Thanks to Nick Piggin)
- radix_tree_lookup_leaf_node() for the pagecache based mmap read-around
- use __print_symbolic() to show readahead pattern names
  (Thanks to Steven Rostedt)
- scale down readahead size proportional to system memory
  (Thanks to Matt Mackall)
- add readahead size kernel parameter (by Nikanth Karthikesan)
- add comments from Christian Ehrhardt

Changes since RFC:
- move the lenthy intro text to individual patch changelogs
- treat get_capacity()==0 as uninitilized value (Thanks to Vivek Goyal)
- increase readahead size limit for small devices (Thanks to Jens Axboe)
- add fio test results by Vivek Goyal


[PATCH 01/16] readahead: limit readahead size for small devices
[PATCH 02/16] readahead: retain inactive lru pages to be accessed soon
[PATCH 03/16] readahead: bump up the default readahead size
[PATCH 04/16] readahead: make default readahead size a kernel parameter
[PATCH 05/16] readahead: limit read-ahead size for small memory systems
[PATCH 06/16] readahead: add notes on readahead size
[PATCH 07/16] readahead: replace ra->mmap_miss with ra->ra_flags
[PATCH 08/16] readahead: thrashing safe context readahead
[PATCH 09/16] readahead: record readahead patterns
[PATCH 10/16] readahead: add tracing event
[PATCH 11/16] readahead: add /debug/readahead/stats
[PATCH 12/16] readahead: dont do start-of-file readahead after lseek()
[PATCH 13/16] radixtree: introduce radix_tree_lookup_leaf_node()
[PATCH 14/16] radixtree: speed up the search for hole
[PATCH 15/16] readahead: reduce MMAP_LOTSAMISS for mmap read-around
[PATCH 16/16] readahead: pagecache context based mmap read-around

 Documentation/kernel-parameters.txt |    4 
 block/blk-core.c                    |    3 
 block/genhd.c                       |   24 +
 fs/fuse/inode.c                     |    2 
 fs/read_write.c                     |    3 
 include/linux/fs.h                  |   64 +++
 include/linux/mm.h                  |    8 
 include/linux/radix-tree.h          |    2 
 include/trace/events/readahead.h    |   78 ++++
 lib/radix-tree.c                    |  104 ++++-
 mm/Kconfig                          |   13 
 mm/filemap.c                        |   34 +
 mm/readahead.c                      |  458 ++++++++++++++++++++++----
 13 files changed, 688 insertions(+), 109 deletions(-)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
