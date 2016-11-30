Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id F25F56B0038
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 03:58:08 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 144so294226349pfv.5
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 00:58:08 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 2si63315599pgd.31.2016.11.30.00.58.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 00:58:08 -0800 (PST)
From: Liang Li <liang.z.li@intel.com>
Subject: [PATCH kernel v5 0/5] Extend virtio-balloon for fast (de)inflating & fast live migration
Date: Wed, 30 Nov 2016 16:43:12 +0800
Message-Id: <1480495397-23225-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org
Cc: virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, qemu-devel@nongnu.org, quintela@redhat.com, dgilbert@redhat.com, dave.hansen@intel.com, mst@redhat.com, jasowang@redhat.com, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, pbonzini@redhat.com, Liang Li <liang.z.li@intel.com>

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
 
Changes from v4 to v5:
    * Drop the code to get the max_pfn, use another way instead.
    * Simplify the API to get the unused page information from mm. 

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

Liang Li (5):
  virtio-balloon: rework deflate to add page to a list
  virtio-balloon: define new feature bit and head struct
  virtio-balloon: speed up inflate/deflate process
  virtio-balloon: define flags and head for host request vq
  virtio-balloon: tell host vm's unused page info

 drivers/virtio/virtio_balloon.c     | 539 ++++++++++++++++++++++++++++++++----
 include/linux/mm.h                  |   3 +-
 include/uapi/linux/virtio_balloon.h |  41 +++
 mm/page_alloc.c                     |  72 +++++
 4 files changed, 607 insertions(+), 48 deletions(-)

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
