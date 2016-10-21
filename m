Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0CB526B0069
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 02:37:00 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u84so45222712pfj.6
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 23:37:00 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id y20si1235903pfd.167.2016.10.20.23.36.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Oct 2016 23:36:59 -0700 (PDT)
From: Liang Li <liang.z.li@intel.com>
Subject: [RESEND PATCH v3 kernel 0/7] Extend virtio-balloon for fast (de)inflating & fast live migration
Date: Fri, 21 Oct 2016 14:24:33 +0800
Message-Id: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, quintela@redhat.com, dgilbert@redhat.com, dave.hansen@intel.com, pbonzini@redhat.com, cornelia.huck@de.ibm.com, amit.shah@redhat.com, Liang Li <liang.z.li@intel.com>

This patch set contains two parts of changes to the virtio-balloon.
 
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
 
Dave Hansen suggested a new scheme to encode the data structure,
because of additional complexity, it's not implemented in v3.
 
Changes from v2 to v3:
    * Change the name of 'free page' to 'unused page'.
    * Use the scatter & gather bitmap instead of a 1MB page bitmap.
    * Fix overwriting the page bitmap after kicking.
    * Some of MST's comments for v2.
 
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
  mm: add the related functions to get unused page
  virtio-balloon: define feature bit and head for misc virt queue
  virtio-balloon: tell host vm's unused page info

 drivers/virtio/virtio_balloon.c     | 390 ++++++++++++++++++++++++++++++++----
 include/linux/mm.h                  |   3 +
 include/uapi/linux/virtio_balloon.h |  41 ++++
 mm/page_alloc.c                     |  94 +++++++++
 4 files changed, 485 insertions(+), 43 deletions(-)

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
