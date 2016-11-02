Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B01F46B02A1
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 02:30:31 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 17so1874948pfy.2
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 23:30:31 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id j2si1089211pfj.194.2016.11.01.23.30.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Nov 2016 23:30:30 -0700 (PDT)
From: Liang Li <liang.z.li@intel.com>
Subject: [PATCH kernel v4 0/7] Extend virtio-balloon for fast (de)inflating & fast live migration
Date: Wed,  2 Nov 2016 14:17:20 +0800
Message-Id: <1478067447-24654-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com, dave.hansen@intel.com
Cc: pbonzini@redhat.com, amit.shah@redhat.com, quintela@redhat.com, dgilbert@redhat.com, qemu-devel@nongnu.org, kvm@vger.kernel.org, virtio-dev@lists.oasis-open.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, mgorman@techsingularity.net, cornelia.huck@de.ibm.com, Liang Li <liang.z.li@intel.com>

This patch set contains two parts of changes to the virtio-balloon.
 
One is the change for speeding up the inflating & deflating process,
the main idea of this optimization is to use bitmap to send the page
information to host instead of the PFNs, to reduce the overhead of
virtio data transmission, address translation and madvise(). This can
help to improve the performance by about 85%.
 
Another change is for speeding up live migration. By skipping process
guest's unused pages in the first round of data copy, to reduce needless
data processing, this can help to save quite a lot of CPU cycles and
network bandwidth. We put guest's unused page information in a bitmap
and send it to host with the virt queue of virtio-balloon. For an idle
guest with 8GB RAM, this can help to shorten the total live migration
time from 2Sec to about 500ms in 10Gbps network environment.
 
Changes from v3 to v4:
    * Use the new scheme suggested by Dave Hansen to encode the bitmap.
    * Add code which is missed in v3 to handle migrate page. 
    * Free the memory for bitmap intime once the operation is done.
    * Address some of the comments in v3.

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
  virtio-balloon: define new feature bit and head struct
  mm: add a function to get the max pfn
  virtio-balloon: speed up inflate/deflate process
  mm: add the related functions to get unused page
  virtio-balloon: define flags and head for host request vq
  virtio-balloon: tell host vm's unused page info

 drivers/virtio/virtio_balloon.c     | 546 ++++++++++++++++++++++++++++++++----
 include/linux/mm.h                  |   3 +
 include/uapi/linux/virtio_balloon.h |  41 +++
 mm/page_alloc.c                     |  95 +++++++
 4 files changed, 636 insertions(+), 49 deletions(-)

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
