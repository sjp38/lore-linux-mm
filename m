Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 72D656B0005
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 08:24:19 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 12-v6so5232752qtq.8
        for <linux-mm@kvack.org>; Fri, 01 Jun 2018 05:24:19 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id b5-v6si3584304qvo.203.2018.06.01.05.24.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jun 2018 05:24:18 -0700 (PDT)
Date: Fri, 1 Jun 2018 14:24:10 +0200
From: Igor Mammedov <imammedo@redhat.com>
Subject: Re: [Qemu-devel] [RFC v2 0/2] kvm "fake DAX" device flushing
Message-ID: <20180601142410.5c986f13@redhat.com>
In-Reply-To: <20180425112415.12327-1-pagupta@redhat.com>
References: <20180425112415.12327-1-pagupta@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pankaj Gupta <pagupta@redhat.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-nvdimm@ml01.01.org, linux-mm@kvack.org, kwolf@redhat.com, haozhong.zhang@intel.com, jack@suse.cz, xiaoguangrong.eric@gmail.com, riel@surriel.com, niteshnarayanlal@hotmail.com, david@redhat.com, ross.zwisler@intel.com, lcapitulino@redhat.com, hch@infradead.org, mst@redhat.com, stefanha@redhat.com, marcel@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com, nilal@redhat.com

On Wed, 25 Apr 2018 16:54:12 +0530
Pankaj Gupta <pagupta@redhat.com> wrote:

[...]
> - Qemu virtio-pmem device
>   It exposes a persistent memory range to KVM guest which 
>   at host side is file backed memory and works as persistent 
>   memory device. In addition to this it provides virtio 
>   device handling of flushing interface. KVM guest performs
>   Qemu side asynchronous sync using this interface.
a random high level question,
Have you considered using a separate (from memory itself)
virtio device as controller for exposing some memory, async flushing.
And then just slaving pc-dimm devices to it with notification/ACPI
code suppressed so that guest won't touch them?

That way it might be more scale-able, you consume only 1 PCI slot
for controller vs multiple for virtio-pmem devices.


> Changes from previous RFC[1]:
> 
> - Reuse existing 'pmem' code for registering persistent 
>   memory and other operations instead of creating an entirely 
>   new block driver.
> - Use VIRTIO driver to register memory information with 
>   nvdimm_bus and create region_type accordingly. 
> - Call VIRTIO flush from existing pmem driver.
> 
> Details of project idea for 'fake DAX' flushing interface is 
> shared [2] & [3].
> 
> Pankaj Gupta (2):
>    Add virtio-pmem guest driver
>    pmem: device flush over VIRTIO
> 
> [1] https://marc.info/?l=linux-mm&m=150782346802290&w=2
> [2] https://www.spinics.net/lists/kvm/msg149761.html
> [3] https://www.spinics.net/lists/kvm/msg153095.html  
> 
>  drivers/nvdimm/region_devs.c     |    7 ++
>  drivers/virtio/Kconfig           |   12 +++
>  drivers/virtio/Makefile          |    1 
>  drivers/virtio/virtio_pmem.c     |  118 +++++++++++++++++++++++++++++++++++++++
>  include/linux/libnvdimm.h        |    4 +
>  include/uapi/linux/virtio_ids.h  |    1 
>  include/uapi/linux/virtio_pmem.h |   58 +++++++++++++++++++
>  7 files changed, 201 insertions(+)
> 
