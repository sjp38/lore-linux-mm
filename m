Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 121A66B006E
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 03:27:20 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so126920394pdb.1
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 00:27:19 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id l8si24802961pbq.79.2015.06.02.00.27.17
        for <linux-mm@kvack.org>;
        Tue, 02 Jun 2015 00:27:18 -0700 (PDT)
From: Gioh Kim <gioh.kim@lge.com>
Subject: [RFC 0/4] enable migration of non-LRU pages
Date: Tue,  2 Jun 2015 16:27:40 +0900
Message-Id: <1433230065-3573-1-git-send-email-gioh.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jlayton@poochiereds.net, bfields@fieldses.org, akpm@linux-foundation.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, mst@redhat.com, kirill@shutemov.name, minchan@kernel.org, mgorman@suse.de
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, gunho.lee@lge.com, Gioh Kim <gioh.kim@lge.com>

Hello,

This series try to enable migration of non-LRU pages, such as driver's page.

My ARM-based platform occured severe fragmentation problem after long-term
(several days) test. Sometimes even order-3 page allocation failed. It has
memory size 512MB ~ 1024MB. 30% ~ 40% memory is consumed for graphic processing
and 20~30 memory is reserved for zram.

I found that many pages of GPU driver and zram are non-movable pages. So I
reported Minchan Kim, the maintainer of zram, and he made the internal 
compaction logic of zram. And I made the internal compaction of GPU driver.

They reduced some fragmentation but they are not enough effective.
They are activated by its own interface, /sys, so they are not cooperative
with kernel compaction. If there is too much fragmentation and kernel starts
to compaction, zram and GPU driver cannot work with the kernel compaction.

The first this patch adds a generic isolate/migrate/putback callbacks for page
address-space. The zram and GPU, and any other modules can register
its own migration method. The kernel compaction can call the registered
migration when it works. Therefore all page in the system can be migrated
at once.

The 2nd the generic migration callbacks are applied into balloon driver.
My gpu driver code is not open so I apply generic migration into balloon
to show how it works. I've tested it with qemu enabled by kvm like followings:
- turn on Ubuntu 14.04 with 1G memory on qemu.
- do kernel building
- after several seconds check more than 512MB is used with free command
- command "balloon 512" in qemu monitor
- check hundreds MB of pages are migrated

Next kernel compaction code can call generic migration callbacks instead of
balloon driver interface.
Finally calling migration of balloon driver is removed.


Gioh Kim (4):
  mm/compaction: enable driver page migration
  mm/balloon: apply migratable-page into balloon driver
  mm/compaction: apply migratable-page into compaction
  mm: remove direct migration of migratable-page

 drivers/virtio/virtio_balloon.c        |  2 +
 fs/proc/page.c                         |  4 +-
 include/linux/balloon_compaction.h     | 42 +++++++++++++++------
 include/linux/compaction.h             | 13 +++++++
 include/linux/fs.h                     |  2 +
 include/linux/mm.h                     | 14 +++----
 include/linux/pagemap.h                | 27 ++++++++++++++
 include/uapi/linux/kernel-page-flags.h |  2 +-
 mm/balloon_compaction.c                | 67 +++++++++++++++++++++++++++++-----
 mm/compaction.c                        |  9 +++--
 mm/migrate.c                           | 25 ++++---------
 11 files changed, 154 insertions(+), 53 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
