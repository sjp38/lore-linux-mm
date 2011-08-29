Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7611C900138
	for <linux-mm@kvack.org>; Sun, 28 Aug 2011 23:57:06 -0400 (EDT)
Message-Id: <20110829032951.677220552@intel.com>
Date: Mon, 29 Aug 2011 11:29:51 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [RFC][PATCH 0/7] trace memory objects
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>
Cc: Mel Gorman <mgorman@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>

Andrew, Ingo,

I'd like to introduce three memory object interfaces

/debug/tracing/objects/mm/pages/dump-pfn
/debug/tracing/objects/mm/pages/dump-file
/debug/tracing/objects/mm/pages/dump-fs

for dumping

- a range of PFNs
- the cached inodes (icache)
- the cached inode pages (page cache)

The "dump-pfn" interface is a superset of the existing /proc/kpageflags and
/proc/kpagecount interfaces. Example output:

# echo 10000 +10 > /debug/tracing/objects/mm/pages/dump-pfn
# cat /debug/tracing/trace
# tracer: nop
#
#           TASK-PID    CPU#    TIMESTAMP  FUNCTION
#              | |       |          |         |
             zsh-3128  [000]  1393.460292: dump_page_frame: pfn=10001 page=ffffea000009c400 count=1 mapcount=0 memcg=0 private=0 mapping=0 index=0 flags=reserved
             zsh-3128  [000]  1393.460296: dump_page_frame: pfn=10002 page=ffffea000009c440 count=1 mapcount=0 memcg=0 private=0 mapping=0 index=0 flags=reserved
             zsh-3128  [000]  1393.460298: dump_page_frame: pfn=10003 page=ffffea000009c480 count=1 mapcount=0 memcg=0 private=0 mapping=0 index=0 flags=reserved
             zsh-3128  [000]  1393.460299: dump_page_frame: pfn=10004 page=ffffea000009c4c0 count=1 mapcount=0 memcg=0 private=0 mapping=0 index=0 flags=reserved
             zsh-3128  [000]  1393.460300: dump_page_frame: pfn=10005 page=ffffea000009c500 count=1 mapcount=0 memcg=0 private=0 mapping=0 index=0 flags=reserved
             zsh-3128  [000]  1393.460301: dump_page_frame: pfn=10006 page=ffffea000009c540 count=1 mapcount=0 memcg=0 private=0 mapping=0 index=0 flags=reserved
             zsh-3128  [000]  1393.460301: dump_page_frame: pfn=10007 page=ffffea000009c580 count=1 mapcount=0 memcg=0 private=0 mapping=0 index=0 flags=reserved
             zsh-3128  [000]  1393.460302: dump_page_frame: pfn=10008 page=ffffea000009c5c0 count=1 mapcount=0 memcg=0 private=0 mapping=0 index=0 flags=reserved
             zsh-3128  [000]  1393.460303: dump_page_frame: pfn=10009 page=ffffea000009c600 count=1 mapcount=0 memcg=0 private=0 mapping=0 index=0 flags=reserved
             zsh-3128  [000]  1393.460304: dump_page_frame: pfn=10010 page=ffffea000009c640 count=1 mapcount=0 memcg=0 private=0 mapping=0 index=0 flags=reserved

The "dump-file", "dump-fs" interfaces could be pretty useful for examining
the page cache status. Example output:

# echo > /debug/tracing/trace
# echo / > /debug/tracing/objects/mm/pages/dump-fs
# head -50 /debug/tracing/trace
# tracer: nop
#
#           TASK-PID    CPU#    TIMESTAMP  FUNCTION
#              | |       |          |         |
             zsh-3128  [000]  1482.623149: dump_inode_cache: ino=1507329 size=4096 cached=4096 dirtied_when=4294676467 age=1482 state=____ type=DIR name=/
             zsh-3128  [000]  1482.623157: dump_page_cache: index=0 len=1 flags=___ARU_____ count=1 mapcount=0 memcg=1
             zsh-3128  [000]  1482.623340: dump_inode_cache: ino=1786836 size=12288 cached=12288 dirtied_when=4294676472 age=1482 state=____ type=DIR name=/sbin
             zsh-3128  [000]  1482.623355: dump_page_cache: index=0 len=3 flags=___ARU_____ count=1 mapcount=0 memcg=1
             zsh-3128  [000]  1482.623393: dump_inode_cache: ino=1786946 size=37312 cached=40960 dirtied_when=4294676473 age=1482 state=____ type=REG name=/sbin/init
             zsh-3128  [000]  1482.623404: dump_page_cache: index=0 len=6 flags=M__ARU_____ count=2 mapcount=1 memcg=1
             zsh-3128  [000]  1482.623405: dump_page_cache: index=6 len=1 flags=M__A_U_____ count=2 mapcount=1 memcg=1
             zsh-3128  [000]  1482.623406: dump_page_cache: index=7 len=1 flags=M__ARU_____ count=2 mapcount=1 memcg=1
             zsh-3128  [000]  1482.623408: dump_page_cache: index=8 len=2 flags=_____U_____ count=1 mapcount=0 memcg=1
             zsh-3128  [000]  1482.623422: dump_inode_cache: ino=1507464 size=4 cached=4096 dirtied_when=4294676477 age=1482 state=____ type=LNK name=/lib64
             zsh-3128  [000]  1482.623427: dump_page_cache: index=0 len=1 flags=___ARU_____ count=1 mapcount=0 memcg=1
             zsh-3128  [000]  1482.623441: dump_inode_cache: ino=1590173 size=12288 cached=0 dirtied_when=4294676477 age=1482 state=____ type=DIR name=/lib
             zsh-3128  [000]  1482.623458: dump_inode_cache: ino=1590265 size=27 cached=4096 dirtied_when=4294676478 age=1482 state=____ type=LNK name=/lib/ld-linux-x86-64.so.2
             zsh-3128  [000]  1482.623462: dump_page_cache: index=0 len=1 flags=___ARU_____ count=1 mapcount=0 memcg=1
             zsh-3128  [000]  1482.623478: dump_inode_cache: ino=1663440 size=4096 cached=0 dirtied_when=4294676479 age=1482 state=____ type=DIR name=/lib/x86_64-linux-gnu
             zsh-3128  [000]  1482.623495: dump_inode_cache: ino=3293287 size=136936 cached=139264 dirtied_when=4294676480 age=1482 state=____ type=REG name=/lib/x86_64-linux-gnu/ld-2.13.so
             zsh-3128  [000]  1482.623499: dump_page_cache: index=0 len=1 flags=M__ARU_____ count=28 mapcount=27 memcg=1
             zsh-3128  [000]  1482.623501: dump_page_cache: index=1 len=3 flags=M__ARU_____ count=23 mapcount=22 memcg=1
             zsh-3128  [000]  1482.623503: dump_page_cache: index=4 len=4 flags=M__ARU_____ count=26 mapcount=25 memcg=1
             zsh-3128  [000]  1482.623504: dump_page_cache: index=8 len=2 flags=M__ARU_____ count=34 mapcount=33 memcg=1
             zsh-3128  [000]  1482.623506: dump_page_cache: index=10 len=3 flags=M__ARU_____ count=26 mapcount=25 memcg=1
             zsh-3128  [000]  1482.623508: dump_page_cache: index=13 len=1 flags=M__ARU_____ count=34 mapcount=33 memcg=1
             zsh-3128  [000]  1482.623509: dump_page_cache: index=14 len=1 flags=M__ARU_____ count=33 mapcount=32 memcg=1
             zsh-3128  [000]  1482.623510: dump_page_cache: index=15 len=1 flags=M__ARU_____ count=26 mapcount=25 memcg=1
             zsh-3128  [000]  1482.623511: dump_page_cache: index=16 len=1 flags=M__ARU_____ count=25 mapcount=24 memcg=1
             zsh-3128  [000]  1482.623512: dump_page_cache: index=17 len=1 flags=M__ARU_____ count=26 mapcount=25 memcg=1
             zsh-3128  [000]  1482.623513: dump_page_cache: index=18 len=1 flags=M__ARU_____ count=10 mapcount=9 memcg=1
             zsh-3128  [000]  1482.623514: dump_page_cache: index=19 len=1 flags=M__ARU_____ count=34 mapcount=33 memcg=1
             zsh-3128  [000]  1482.623515: dump_page_cache: index=20 len=1 flags=M__ARU_____ count=23 mapcount=22 memcg=1
             zsh-3128  [000]  1482.623516: dump_page_cache: index=21 len=1 flags=M__ARU_____ count=26 mapcount=25 memcg=1
             zsh-3128  [000]  1482.623517: dump_page_cache: index=22 len=1 flags=M__ARU_____ count=34 mapcount=33 memcg=1
             zsh-3128  [000]  1482.623518: dump_page_cache: index=23 len=2 flags=M__ARU_____ count=26 mapcount=25 memcg=1
             zsh-3128  [000]  1482.623519: dump_page_cache: index=25 len=1 flags=M__ARU_____ count=33 mapcount=32 memcg=1
             zsh-3128  [000]  1482.623520: dump_page_cache: index=26 len=1 flags=M__ARU_____ count=10 mapcount=9 memcg=1
             zsh-3128  [000]  1482.623522: dump_page_cache: index=27 len=1 flags=M__ARU_____ count=4 mapcount=3 memcg=1
             zsh-3128  [000]  1482.623523: dump_page_cache: index=28 len=1 flags=M__ARU_____ count=26 mapcount=25 memcg=1
             zsh-3128  [000]  1482.623525: dump_page_cache: index=29 len=5 flags=_____U_____ count=1 mapcount=0 memcg=1
             zsh-3128  [000]  1482.623540: dump_inode_cache: ino=1525477 size=12288 cached=0 dirtied_when=4294676489 age=1482 state=____ type=DIR name=/etc
             zsh-3128  [000]  1482.623556: dump_inode_cache: ino=1526474 size=69589 cached=69632 dirtied_when=4294676491 age=1482 state=____ type=REG name=/etc/ld.so.cache
             zsh-3128  [000]  1482.623561: dump_page_cache: index=0 len=1 flags=___ARU_____ count=1 mapcount=0 memcg=1
             zsh-3128  [000]  1482.623562: dump_page_cache: index=1 len=1 flags=_____U_____ count=1 mapcount=0 memcg=1
             zsh-3128  [000]  1482.623569: dump_page_cache: index=2 len=15 flags=___ARU_____ count=1 mapcount=0 memcg=1
             zsh-3128  [000]  1482.623585: dump_inode_cache: ino=1590258 size=241632 cached=241664 dirtied_when=4294676493 age=1482 state=____ type=REG name=/lib/libsepol.so.1
             zsh-3128  [000]  1482.623591: dump_page_cache: index=0 len=5 flags=M__ARU_____ count=2 mapcount=1 memcg=1
             zsh-3128  [000]  1482.623609: dump_page_cache: index=5 len=42 flags=_____U_____ count=1 mapcount=0 memcg=1
             zsh-3128  [000]  1482.623610: dump_page_cache: index=47 len=1 flags=M__ARU_____ count=2 mapcount=1 memcg=1

patches:

dump-pfn interface
(it looks more clean and easier for review to fold patches 1-5 into one, but
let's keep the changelog for the initial post)

	[RFC][PATCH 1/7] tracing/mm: add page frame snapshot trace
	[RFC][PATCH 2/7] tracing/mm: rename trigger file to dump-pfn
	[RFC][PATCH 3/7] tracing/mm: create trace_objects.c
	[RFC][PATCH 4/7] tracing/mm: dump more page frame information
	[RFC][PATCH 5/7] tracing/mm: accept echo-able input format for pfn range

dump-file and dump-fs interfaces

	[RFC][PATCH 6/7] tracing/mm: add dump-file and dump-fs interfaces

add memcg support

	[RFC][PATCH 7/7] tracing/mm: add memcg field

diffstat:

 fs/inode.c                   |    8 
 fs/internal.h                |    5 
 include/linux/fs.h           |    1 
 include/linux/memcontrol.h   |    6 
 include/linux/page-flags.h   |    1 
 include/trace/events/mm.h    |  170 ++++++++++++++
 kernel/trace/Makefile        |    2 
 kernel/trace/trace.h         |    1 
 kernel/trace/trace_mm.c      |  378 +++++++++++++++++++++++++++++++++
 kernel/trace/trace_objects.c |   26 ++
 mm/memcontrol.c              |   18 +
 mm/page_alloc.c              |    4 
 12 files changed, 612 insertions(+), 8 deletions(-)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
