Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id A34B56B0038
	for <linux-mm@kvack.org>; Sat, 30 Aug 2014 12:41:18 -0400 (EDT)
Received: by mail-la0-f44.google.com with SMTP id hz20so4253164lab.3
        for <linux-mm@kvack.org>; Sat, 30 Aug 2014 09:41:18 -0700 (PDT)
Received: from mail-la0-x22d.google.com (mail-la0-x22d.google.com [2a00:1450:4010:c03::22d])
        by mx.google.com with ESMTPS id uf7si4675016lbc.101.2014.08.30.09.41.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 30 Aug 2014 09:41:17 -0700 (PDT)
Received: by mail-la0-f45.google.com with SMTP id pn19so4173680lab.32
        for <linux-mm@kvack.org>; Sat, 30 Aug 2014 09:41:16 -0700 (PDT)
Subject: [PATCH v2 0/6] mm/balloon_compaction: fixes and cleanups
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sat, 30 Aug 2014 20:41:06 +0400
Message-ID: <20140830163834.29066.98205.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Rafael Aquini <aquini@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Sasha Levin <sasha.levin@oracle.com>

I've checked compilation of linux-next/x86 for allnoconfig, defconfig and
defconfig + kvmconfig + virtio-balloon with and without balloon-compaction.
For stable kernels first three patches should be enough.

changes since v1:

mm/balloon_compaction: ignore anonymous pages
* no changes

mm/balloon_compaction: keep ballooned pages away from normal migration path
* fix compilation without CONFIG_BALLOON_COMPACTION

mm/balloon_compaction: isolate balloon pages without lru_lock
* no changes

mm: introduce common page state for ballooned memory
* move __Set/ClearPageBalloon into linux/mm.h
* remove inc/dec_zone_page_state from __Set/ClearPageBalloon

mm/balloon_compaction: use common page ballooning
* call inc/dec_zone_page_state from balloon_page_insert/delete

mm/balloon_compaction: general cleanup
* fix compilation without CONFIG_MIGRATION
* fix compilation without CONFIG_BALLOON_COMPACTION

---

Konstantin Khlebnikov (6):
      mm/balloon_compaction: ignore anonymous pages
      mm/balloon_compaction: keep ballooned pages away from normal migration path
      mm/balloon_compaction: isolate balloon pages without lru_lock
      mm: introduce common page state for ballooned memory
      mm/balloon_compaction: use common page ballooning
      mm/balloon_compaction: general cleanup


 Documentation/filesystems/proc.txt     |    2 
 drivers/base/node.c                    |   16 +-
 drivers/virtio/Kconfig                 |    1 
 drivers/virtio/virtio_balloon.c        |   77 +++--------
 fs/proc/meminfo.c                      |    6 +
 fs/proc/page.c                         |    3 
 include/linux/balloon_compaction.h     |  223 ++++++--------------------------
 include/linux/migrate.h                |   11 --
 include/linux/mm.h                     |   20 +++
 include/linux/mmzone.h                 |    3 
 include/linux/pagemap.h                |   18 ---
 include/uapi/linux/kernel-page-flags.h |    1 
 mm/Kconfig                             |    7 +
 mm/Makefile                            |    3 
 mm/balloon_compaction.c                |  219 ++++++++++---------------------
 mm/compaction.c                        |    9 +
 mm/migrate.c                           |   29 +---
 mm/vmscan.c                            |    2 
 mm/vmstat.c                            |    8 +
 tools/vm/page-types.c                  |    1 
 20 files changed, 210 insertions(+), 449 deletions(-)

--
Signature

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
