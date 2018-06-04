Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 86BE06B0003
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 05:55:41 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id a16-v6so12123548qkb.7
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 02:55:41 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id p6-v6si1106554qvk.246.2018.06.04.02.55.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jun 2018 02:55:40 -0700 (PDT)
Subject: Re: [Qemu-devel] [RFC v2 0/2] kvm "fake DAX" device flushing
References: <20180425112415.12327-1-pagupta@redhat.com>
 <20180601142410.5c986f13@redhat.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <a36137df-d2f6-39d5-318e-9006415b8ca2@redhat.com>
Date: Mon, 4 Jun 2018 11:55:33 +0200
MIME-Version: 1.0
In-Reply-To: <20180601142410.5c986f13@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Mammedov <imammedo@redhat.com>, Pankaj Gupta <pagupta@redhat.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-nvdimm@ml01.01.org, linux-mm@kvack.org, kwolf@redhat.com, haozhong.zhang@intel.com, jack@suse.cz, xiaoguangrong.eric@gmail.com, riel@surriel.com, niteshnarayanlal@hotmail.com, ross.zwisler@intel.com, lcapitulino@redhat.com, hch@infradead.org, mst@redhat.com, stefanha@redhat.com, marcel@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com, nilal@redhat.com

On 01.06.2018 14:24, Igor Mammedov wrote:
> On Wed, 25 Apr 2018 16:54:12 +0530
> Pankaj Gupta <pagupta@redhat.com> wrote:
> 
> [...]
>> - Qemu virtio-pmem device
>>   It exposes a persistent memory range to KVM guest which 
>>   at host side is file backed memory and works as persistent 
>>   memory device. In addition to this it provides virtio 
>>   device handling of flushing interface. KVM guest performs
>>   Qemu side asynchronous sync using this interface.
> a random high level question,
> Have you considered using a separate (from memory itself)
> virtio device as controller for exposing some memory, async flushing.
> And then just slaving pc-dimm devices to it with notification/ACPI
> code suppressed so that guest won't touch them?

I don't think slaving pc-dimm would be the right thing to do (e.g.
slots, pcdimm vs nvdimm, bus(less), etc..). However the general idea is
interesting for virtio-pmem (as we might have a bigger number of disks).

We could have something like a virtio-pmem-bus to which you attach
virtio-pmem devices. By specifying the mapping, e.g. the thread that
will be used for async flushes will be implicit.

> 
> That way it might be more scale-able, you consume only 1 PCI slot
> for controller vs multiple for virtio-pmem devices.>
> 
>> Changes from previous RFC[1]:
>>
>> - Reuse existing 'pmem' code for registering persistent 
>>   memory and other operations instead of creating an entirely 
>>   new block driver.
>> - Use VIRTIO driver to register memory information with 
>>   nvdimm_bus and create region_type accordingly. 
>> - Call VIRTIO flush from existing pmem driver.
>>
>> Details of project idea for 'fake DAX' flushing interface is 
>> shared [2] & [3].
>>
>> Pankaj Gupta (2):
>>    Add virtio-pmem guest driver
>>    pmem: device flush over VIRTIO
>>
>> [1] https://marc.info/?l=linux-mm&m=150782346802290&w=2
>> [2] https://www.spinics.net/lists/kvm/msg149761.html
>> [3] https://www.spinics.net/lists/kvm/msg153095.html  
>>
>>  drivers/nvdimm/region_devs.c     |    7 ++
>>  drivers/virtio/Kconfig           |   12 +++
>>  drivers/virtio/Makefile          |    1 
>>  drivers/virtio/virtio_pmem.c     |  118 +++++++++++++++++++++++++++++++++++++++
>>  include/linux/libnvdimm.h        |    4 +
>>  include/uapi/linux/virtio_ids.h  |    1 
>>  include/uapi/linux/virtio_pmem.h |   58 +++++++++++++++++++
>>  7 files changed, 201 insertions(+)
>>
> 


-- 

Thanks,

David / dhildenb
