Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id E2C8F6B13F0
	for <linux-mm@kvack.org>; Sat, 11 Feb 2012 04:51:06 -0500 (EST)
Message-Id: <20120211043140.108656864@intel.com>
Date: Sat, 11 Feb 2012 12:31:40 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 0/9] readahead stats/tracing, backwards prefetching and more (v5)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>

Andrew,

This introduces the per-cpu readahead stats, tracing, backwards prefetching,
fixes context readahead for SSD random reads and does some other minor changes.

Changes since v4:
- fix changelog for readahead stats

Changes since v3:
- default to CONFIG_READAHEAD_STATS=n
- drop "block: limit default readahead size for small devices"
  (and expect some distro udev rules to do the job)
- use percpu_counter for the readahead stats

Changes since v2:
- use per-cpu counters for readahead stats
- make context readahead more conservative
- simplify readahead tracing format and use __print_symbolic()
- backwards prefetching and snap to EOF fixes and cleanups

Changes since v1:
- use bit fields: pattern, for_mmap, for_metadata, lseek
- comment the various readahead patterns
- drop boot options "readahead=" and "readahead_stats="
- add for_metadata
- add snapping to EOF

 [PATCH 1/9] readahead: make context readahead more conservative
 [PATCH 2/9] readahead: record readahead patterns
 [PATCH 3/9] readahead: tag mmap page fault call sites
 [PATCH 4/9] readahead: tag metadata call sites
 [PATCH 5/9] readahead: add vfs/readahead tracing event
 [PATCH 6/9] readahead: add /debug/readahead/stats
 [PATCH 7/9] readahead: dont do start-of-file readahead after lseek()
 [PATCH 8/9] readahead: snap readahead request to EOF
 [PATCH 9/9] readahead: basic support for backwards prefetching

 fs/Makefile                |    1 
 fs/ext3/dir.c              |    1 
 fs/ext4/dir.c              |    1 
 fs/read_write.c            |    3 
 fs/trace.c                 |    2 
 include/linux/fs.h         |   41 ++++
 include/linux/mm.h         |    4 
 include/trace/events/vfs.h |   78 ++++++++
 mm/Kconfig                 |   15 +
 mm/filemap.c               |    9 -
 mm/readahead.c             |  310 +++++++++++++++++++++++++++++++++--
 11 files changed, 450 insertions(+), 15 deletions(-)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
