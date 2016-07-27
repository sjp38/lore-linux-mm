Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 65A0A6B0261
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 21:31:06 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ca5so13212018pac.0
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 18:31:06 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id k84si3422959pfa.56.2016.07.26.18.31.05
        for <linux-mm@kvack.org>;
        Tue, 26 Jul 2016 18:31:05 -0700 (PDT)
From: Liang Li <liang.z.li@intel.com>
Subject: [PATCH v2 repost 0/7] Extend virtio-balloon for fast (de)inflating & fast live migration
Date: Wed, 27 Jul 2016 09:23:29 +0800
Message-Id: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, dgilbert@redhat.com, quintela@redhat.com, Liang Li <liang.z.li@intel.com>

This patchset is for kernel and contains two parts of change to the
virtio-balloon. 

One is the change for speeding up the inflating & deflating process,
the main idea of this optimization is to use bitmap to send the page
information to host instead of the PFNs, to reduce the overhead of
virtio data transmission, address translation and madvise(). This can
help to improve the performance by about 85%.

Another change is for speeding up live migration. By skipping process
guest's free pages in the first round of data copy, to reduce needless
data processing, this can help to save quite a lot of CPU cycles and
network bandwidth. We put guest's free page information in bitmap and
send it to host with the virt queue of virtio-balloon. For an idle 8GB
guest, this can help to shorten the total live migration time from 2Sec
to about 500ms in the 10Gbps network environment.  


Changes from v1 to v2:
    * Abandon the patch for dropping page cache.
    * Put some structures to uapi head file.
    * Use a new way to determine the page bitmap size.
    * Use a unified way to send the free page information with the bitmap 
    * Address the issues referred in MST's comments

Liang Li (7):
  virtio-balloon: rework deflate to add page to a list
  virtio-balloon: define new feature bit and page bitmap head
  mm: add a function to get the max pfn
  virtio-balloon: speed up inflate/deflate process
  virtio-balloon: define feature bit and head for misc virt queue
  mm: add the related functions to get free page info
  virtio-balloon: tell host vm's free page info

 drivers/virtio/virtio_balloon.c     | 306 +++++++++++++++++++++++++++++++-----
 include/uapi/linux/virtio_balloon.h |  41 +++++
 mm/page_alloc.c                     |  52 ++++++
 3 files changed, 359 insertions(+), 40 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
