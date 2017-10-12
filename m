Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 082A16B0253
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 11:50:53 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id m189so2078389qke.21
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 08:50:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a13si7743339qkg.520.2017.10.12.08.50.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 08:50:51 -0700 (PDT)
From: Pankaj Gupta <pagupta@redhat.com>
Subject: [RFC 0/2] KVM "fake DAX" device flushing
Date: Thu, 12 Oct 2017 21:20:24 +0530
Message-Id: <20171012155027.3277-1-pagupta@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-nvdimm@ml01.01.org, linux-mm@kvack.org
Cc: jack@suse.cz, stefanha@redhat.com, dan.j.williams@intel.com, riel@redhat.com, haozhong.zhang@intel.com, nilal@redhat.com, kwolf@redhat.com, pbonzini@redhat.com, ross.zwisler@intel.com, david@redhat.com, xiaoguangrong.eric@gmail.com, pagupta@redhat.com

We are sharing the prototype version of 'fake DAX' flushing
interface for the initial feedback. This is still work in progress
and not yet ready for merging.

Prototype right now just implements basic functionality without advanced
features with two major parts:

- Qemu virtio-pmem device
  It exposes a persistent memory range to KVM guest which at host side is file
  backed memory and works as persistent memory device. In addition to this it
  provides a virtio flushing interface for KVM guest to do a Qemu side sync for
  guest DAX persistent memory range.  

- Guest virtio-pmem driver
  Reads persistent memory range from paravirt device and reserves system memory map.
  It also allocates a block device corresponding to the pmem range which is accessed
  by DAX capable file systems. (file system support is still pending).  
  
We shared the project idea for 'fake DAX' flushing interface here [1].
Based on suggestions here [2], we implemented guest 'virtio-pmem'
driver and Qemu paravirt device.

[1] https://www.spinics.net/lists/kvm/msg149761.html
[2] https://www.spinics.net/lists/kvm/msg153095.html

Work yet to be done:

- Separate out the common code used by ACPI pmem interface and
  reuse it.

- In pmem device memmap allocation and working. There is some parallel work
  going on upstream related to 'memory_hotplug restructuring' [3] and also hitting
  a memory section alignment issue [4].
  
  [3] https://lwn.net/Articles/712099/
  [4] https://www.mail-archive.com/linux-nvdimm@lists.01.org/msg02978.html
  
- Provide DAX capable file-system(ext4 & XFS) support.
- Qemu device flush functionality trigger with guest fsync on file.
- Qemu live migration work when host page cache is used.
- Multiple virtio-pmem disks support.
- Prepare virtio spec after we get feedback on current approach.

 drivers/nvdimm/pfn.h             |   14 -
 drivers/nvdimm/pfn_devs.c        |   20 --
 drivers/nvdimm/pmem.c            |   40 ----
 drivers/nvdimm/pmem.h            |    5 
 drivers/virtio/Kconfig           |   10 +
 drivers/virtio/Makefile          |    1 
 drivers/virtio/virtio_pmem.c     |  322 +++++++++++++++++++++++++++++++++++++++
 include/linux/memremap.h         |   23 ++
 include/linux/pfn.h              |   15 +
 include/linux/pmem_common.h      |   52 ++++++
 include/uapi/linux/virtio_pmem.h |   55 ++++++
 11 files changed, 479 insertions(+), 78 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
