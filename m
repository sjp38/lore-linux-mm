Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 707D76B0253
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 14:52:03 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id z50so6475719qtj.9
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 11:52:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b4si1773132qkd.396.2017.10.11.11.52.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 11:52:02 -0700 (PDT)
From: Pankaj Gupta <pagupta@redhat.com>
Subject: [RFC] KVM "fake DAX" device flushing
Date: Thu, 12 Oct 2017 00:21:46 +0530
Message-Id: <20171011185146.20295-1-pagupta@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-nvdimm@ml01.01.org, linux-mm@kvack.org
Cc: jack@suse.cz, stefanha@redhat.com, dan.j.williams@intel.com, riel@redhat.com, haozhong.zhang@intel.com, nilal@redhat.com, kwolf@redhat.com, pbonzini@redhat.com, ross.zwisler@intel.com, david@redhat.com, xiaoguangrong.eric@gmail.com, pagupta@redhat.com

We are sharing the prototype version of 'fake DAX' flushing
interface for the initial feedback. This is still work in progress
and not yet ready for merging.

Protoype right now just implements basic functionality without advanced
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
- Qemu device flush functionality.
- Qemu live migration work when host page cache is used.
- Multiple virtio-pmem disks support.

Prototype implementation for feedback:

Kernel: https://github.com/pagupta/linux/commit/d15cf90074eae91aeed7a228da3faf319566dd40
Qemu  : https://github.com/pagupta/qemu/commit/9c428db1e1076970e097e2b0ef8afe52509af823

Please provide feedback. Also, I would be attending KVM Forum in Prague from (25-27 Oct). 
If you are attending KVM forum/Linux conference, I would love to have a discussion on ideas 
and future work.

Thank you,
Pankaj Gupta

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
