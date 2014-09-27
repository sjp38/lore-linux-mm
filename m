Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 580746B0038
	for <linux-mm@kvack.org>; Sat, 27 Sep 2014 15:15:34 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id gb8so6650386lab.30
        for <linux-mm@kvack.org>; Sat, 27 Sep 2014 12:15:33 -0700 (PDT)
Received: from mail-la0-x235.google.com (mail-la0-x235.google.com [2a00:1450:4010:c03::235])
        by mx.google.com with ESMTPS id f8si12002509lbc.136.2014.09.27.12.15.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 27 Sep 2014 12:15:32 -0700 (PDT)
Received: by mail-la0-f53.google.com with SMTP id ty20so3502844lab.40
        for <linux-mm@kvack.org>; Sat, 27 Sep 2014 12:15:31 -0700 (PDT)
Subject: [PATCH v3 0/4] mm/balloon_compaction: fixes and cleanups
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sat, 27 Sep 2014 23:15:12 +0400
Message-ID: <20140927183403.13738.22121.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

Here is reworked and resplitted patchset. patches agains current mmotm.
I've merged fixes into first patch. It appyies clearly to v3.16,
older kernels has a trivial conflict in mm/migrate.c.

Reference counting during isolation and migration of ballooned pages
reorganized and now looks similar to scheme used for normal pages
(grab extra reference, isolate, migrate, putback/drop extra reference).

Changes since v2:

* PagePrivate used for fixing race between isolation and deflation
* all fixes merged into first patch

second patch contains only cleanup
third patch adds new interfaces (vmstat, kpageflags)
transhuge-stress: no changes except commit message

bloat-o-meter (x86_64, defconfig + balloon-compaction):

add/remove: 0/7 grow/shrink: 7/9 up/down: 134/-1045 (-911)
function                                     old     new   delta
virtballoon_migratepage                      322     357     +35
vmstat_text                                  824     848     +24
vm_event_states                              496     520     +24
stable_page_flags                            378     401     +23
balloon_page_enqueue                         138     154     +16
balloon_page_migrate                         162     168      +6
balloon_page_dequeue                         287     293      +6
leak_balloon                                 254     246      -8
balloon_page_putback                         205     193     -12
__ksymtab_balloon_mapping_alloc               16       -     -16
__ksymtab_balloon_devinfo_alloc               16       -     -16
virtballoon_remove                            70      48     -22
__kstrtab_balloon_mapping_alloc               22       -     -22
__kstrtab_balloon_devinfo_alloc               22       -     -22
balloon_page_isolate                         291     243     -48
virtballoon_probe                            382     318     -64
balloon_devinfo_alloc                         96       -     -96
isolate_migratepages_block                  1682    1578    -104
reclaim_clean_pages_from_list                435     330    -105
putback_movable_pages                        312     207    -105
migrate_pages                               1992    1875    -117
balloon_mapping_alloc                        128       -    -128
virtio_balloon_aops                          160       -    -160

even allnoconfig is smaller now:

add/remove: 0/3 grow/shrink: 0/0 up/down: 0/-291 (-291)
function                                     old     new   delta
balloon_devinfo_alloc                         63       -     -63
balloon_page_enqueue                          82       -     -82
balloon_page_dequeue                         146       -    -146

---

Konstantin Khlebnikov (4):
      mm/balloon_compaction: redesign ballooned pages management
      mm/balloon_compaction: remove balloon mapping and flag AS_BALLOON_MAP
      mm/balloon_compaction: add vmstat counters and kpageflags bit
      selftests/vm/transhuge-stress: stress test for memory compaction


 drivers/virtio/Kconfig                        |    1 
 drivers/virtio/virtio_balloon.c               |   76 +++--------
 fs/proc/page.c                                |    3 
 include/linux/balloon_compaction.h            |  169 +++++++------------------
 include/linux/migrate.h                       |   11 --
 include/linux/mm.h                            |   19 +++
 include/linux/pagemap.h                       |   18 ---
 include/linux/vm_event_item.h                 |    7 +
 include/uapi/linux/kernel-page-flags.h        |    1 
 mm/Kconfig                                    |    7 +
 mm/Makefile                                   |    3 
 mm/balloon_compaction.c                       |  123 +++---------------
 mm/compaction.c                               |    2 
 mm/migrate.c                                  |   16 +-
 mm/vmstat.c                                   |   12 ++
 tools/testing/selftests/vm/Makefile           |    1 
 tools/testing/selftests/vm/transhuge-stress.c |  144 +++++++++++++++++++++
 tools/vm/page-types.c                         |    1 
 18 files changed, 288 insertions(+), 326 deletions(-)
 create mode 100644 tools/testing/selftests/vm/transhuge-stress.c

--
Signature

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
