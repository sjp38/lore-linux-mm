Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F80D6B0003
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 07:24:29 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id q185so12941063qke.7
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 04:24:29 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id q70si366410qke.80.2018.04.25.04.24.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Apr 2018 04:24:27 -0700 (PDT)
From: Pankaj Gupta <pagupta@redhat.com>
Subject: [RFC v2 0/2] kvm "fake DAX" device flushing
Date: Wed, 25 Apr 2018 16:54:12 +0530
Message-Id: <20180425112415.12327-1-pagupta@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-nvdimm@ml01.01.org, linux-mm@kvack.org
Cc: jack@suse.cz, stefanha@redhat.com, dan.j.williams@intel.com, riel@surriel.com, haozhong.zhang@intel.com, nilal@redhat.com, kwolf@redhat.com, pbonzini@redhat.com, ross.zwisler@intel.com, david@redhat.com, xiaoguangrong.eric@gmail.com, hch@infradead.org, marcel@redhat.com, mst@redhat.com, niteshnarayanlal@hotmail.com, imammedo@redhat.com, pagupta@redhat.com, lcapitulino@redhat.com

This is RFC V2 for 'fake DAX' flushing interface sharing
for review. This patchset has two main parts:

- Guest virtio-pmem driver
  Guest driver reads persistent memory range from paravirt 
  device and registers with 'nvdimm_bus'. 'nvdimm/pmem' 
  driver uses this information to allocate persistent 
  memory range. Also, we have implemented guest side of 
  VIRTIO flushing interface.

- Qemu virtio-pmem device
  It exposes a persistent memory range to KVM guest which 
  at host side is file backed memory and works as persistent 
  memory device. In addition to this it provides virtio 
  device handling of flushing interface. KVM guest performs
  Qemu side asynchronous sync using this interface.

Changes from previous RFC[1]:

- Reuse existing 'pmem' code for registering persistent 
  memory and other operations instead of creating an entirely 
  new block driver.
- Use VIRTIO driver to register memory information with 
  nvdimm_bus and create region_type accordingly. 
- Call VIRTIO flush from existing pmem driver.

Details of project idea for 'fake DAX' flushing interface is 
shared [2] & [3].

Pankaj Gupta (2):
   Add virtio-pmem guest driver
   pmem: device flush over VIRTIO

[1] https://marc.info/?l=linux-mm&m=150782346802290&w=2
[2] https://www.spinics.net/lists/kvm/msg149761.html
[3] https://www.spinics.net/lists/kvm/msg153095.html  

 drivers/nvdimm/region_devs.c     |    7 ++
 drivers/virtio/Kconfig           |   12 +++
 drivers/virtio/Makefile          |    1 
 drivers/virtio/virtio_pmem.c     |  118 +++++++++++++++++++++++++++++++++++++++
 include/linux/libnvdimm.h        |    4 +
 include/uapi/linux/virtio_ids.h  |    1 
 include/uapi/linux/virtio_pmem.h |   58 +++++++++++++++++++
 7 files changed, 201 insertions(+)
