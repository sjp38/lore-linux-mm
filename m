Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A539C6B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 10:43:41 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e190so32628584pfe.3
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 07:43:41 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id a190si12021683pfa.80.2016.04.19.07.43.40
        for <linux-mm@kvack.org>;
        Tue, 19 Apr 2016 07:43:40 -0700 (PDT)
From: Liang Li <liang.z.li@intel.com>
Subject: [PATCH kernel 0/2] speed up live migration by skipping free pages
Date: Tue, 19 Apr 2016 22:34:32 +0800
Message-Id: <1461076474-3864-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com, viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org, quintela@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, dgilbert@redhat.com
Cc: linux-mm@kvack.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, agraf@suse.de, borntraeger@de.ibm.com, Liang Li <liang.z.li@intel.com>

Current QEMU live migration implementation mark all guest's RAM pages
as dirtied in the ram bulk stage, all these pages will be processed
and it consumes quite a lot of CPU cycles and network bandwidth.

>From guest's point of view, it doesn't care about the content in free
page. We can make use of this fact and skip processing the free
pages, this can save a lot CPU cycles and reduce the network traffic
significantly while speed up the live migration process obviously.

This patch set is the kernel side implementation.

The virtio-balloon driver is extended to send the free page bitmap
from guest to QEMU.

After getting the free page bitmap, QEMU can use it to filter out
guest's free pages. This make the live migration process much more
efficient.

In order to skip more free pages, we add an interface to let the user
decide whether dropping the cache in guest during live migration.

Liang Li (2):
  mm: add the related functions to build the free page bitmap
  virtio-balloon: extend balloon driver to support the new feature

 drivers/virtio/virtio_balloon.c     | 100 ++++++++++++++++++++++++++++++++++--
 fs/drop_caches.c                    |  22 +++++---
 include/linux/fs.h                  |   1 +
 include/uapi/linux/virtio_balloon.h |   1 +
 mm/page_alloc.c                     |  46 +++++++++++++++++
 5 files changed, 157 insertions(+), 13 deletions(-)

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
