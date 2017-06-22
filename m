Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3E36B6B02B4
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 10:23:34 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p64so5015613wrc.8
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 07:23:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b184si1339683wmb.158.2017.06.22.07.23.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Jun 2017 07:23:32 -0700 (PDT)
From: Nikolay Borisov <nborisov@suse.com>
Subject: [RFC PATCH 0/4] Support for metadata specific accounting 
Date: Thu, 22 Jun 2017 17:23:20 +0300
Message-Id: <1498141404-18807-1-git-send-email-nborisov@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org
Cc: jbacik@fb.com, jack@suse.cz, jeffm@suse.com, chandan@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, axboe@kernel.dk, Nikolay Borisov <nborisov@suse.com>

Hello, 

This series is a report of Josef's original posting [1]. I've included 
fine-grained changelog in each patch with my changes. Basically, I've forward
ported it to 4.12-rc6 and tried incorporating the feedback which was given to 
every individual patch (I've included link with that information in each 
individual patch). 

The main rationale of pushing this is to enable btrfs' subpage-blocksizes
patches to eventually be merged.

This patchset depends on patches (in listed order) which have already
been submitted [2] [3] [4]. But overall they don't hamper review. 


[1] https://www.spinics.net/lists/linux-btrfs/msg59976.html
[2] https://patchwork.kernel.org/patch/9800129/
[3] https://patchwork.kernel.org/patch/9800985/
[4] https://patchwork.kernel.org/patch/9799735/

Josef Bacik (4):
  remove mapping from balance_dirty_pages*()
  writeback: convert WB_WRITTEN/WB_DIRITED counters to bytes
  writeback: add counters for metadata usage
  writeback: introduce super_operations->write_metadata

 drivers/base/node.c              |   8 ++
 drivers/mtd/devices/block2mtd.c  |  12 ++-
 fs/btrfs/disk-io.c               |   6 +-
 fs/btrfs/file.c                  |   3 +-
 fs/btrfs/ioctl.c                 |   3 +-
 fs/btrfs/relocation.c            |   3 +-
 fs/buffer.c                      |   3 +-
 fs/fs-writeback.c                |  74 +++++++++++++--
 fs/fuse/file.c                   |   4 +-
 fs/iomap.c                       |   6 +-
 fs/ntfs/attrib.c                 |  10 +-
 fs/ntfs/file.c                   |   4 +-
 fs/proc/meminfo.c                |   6 ++
 fs/super.c                       |   7 ++
 include/linux/backing-dev-defs.h |   8 +-
 include/linux/backing-dev.h      |  51 +++++++++--
 include/linux/fs.h               |   4 +
 include/linux/mm.h               |   9 ++
 include/linux/mmzone.h           |   3 +
 include/linux/writeback.h        |   3 +-
 include/trace/events/writeback.h |  13 ++-
 mm/backing-dev.c                 |  15 ++-
 mm/filemap.c                     |   4 +-
 mm/memory.c                      |   5 +-
 mm/page-writeback.c              | 192 ++++++++++++++++++++++++++++++++-------
 mm/page_alloc.c                  |  21 ++++-
 mm/util.c                        |   2 +
 mm/vmscan.c                      |  19 +++-
 mm/vmstat.c                      |   3 +
 29 files changed, 418 insertions(+), 83 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
