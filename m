Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D2BC2831F4
	for <linux-mm@kvack.org>; Thu,  4 May 2017 04:55:49 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id i63so5890360pgd.15
        for <linux-mm@kvack.org>; Thu, 04 May 2017 01:55:49 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id t188si1518031pgt.331.2017.05.04.01.55.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 May 2017 01:55:48 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v10 0/6] Extend virtio-balloon for fast (de)inflating & fast live migration
Date: Thu,  4 May 2017 16:50:09 +0800
Message-Id: <1493887815-6070-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com

This patch series implements the follow two things:
1) Optimization of balloon page transfer: instead of transferring balloon pages
to host one by one, the new mechanism transfers them in chunks.
2) A mechanism to report info of guest unused pages: the pages have been unused
at some time between when host sent command and when guest reported them.  Host
uses that by tracking memory changes and then discarding changes made to the
pages that it gets from guest before it sent the command.

Changes:
v9->v10:
1) mm: put report_unused_page_block() under CONFIG_VIRTIO_BALLOON;
2) virtio-balloon: add virtballoon_validate();
3) virtio-balloon: msg format change;
4) virtio-balloon: move miscq handling to a task on system_freezable_wq;
5) virtio-balloon: code cleanup.

v8->v9:
1) Split the two new features, VIRTIO_BALLOON_F_BALLOON_CHUNKS and
VIRTIO_BALLOON_F_MISC_VQ, which were mixed together in the previous
implementation;
2) Simpler function to get the free page block.

v7->v8:
1) Use only one chunk format, instead of two.
2) re-write the virtio-balloon implementation patch.
3) commit changes
4) patch re-org

Liang Li (1):
  virtio-balloon: deflate via a page list

Wei Wang (5):
  virtio-balloon: coding format cleanup
  virtio-balloon: VIRTIO_BALLOON_F_PAGE_CHUNKS
  mm: function to offer a page block on the free list
  mm: export symbol of next_zone and first_online_pgdat
  virtio-balloon: VIRTIO_BALLOON_F_MISC_VQ

 drivers/virtio/virtio_balloon.c     | 696 +++++++++++++++++++++++++++++++++---
 include/linux/mm.h                  |   5 +
 include/uapi/linux/virtio_balloon.h |  26 ++
 mm/mmzone.c                         |   2 +
 mm/page_alloc.c                     |  91 +++++
 5 files changed, 761 insertions(+), 59 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
