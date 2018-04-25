Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 66B616B0007
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 10:43:54 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id m24-v6so12198356otd.21
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 07:43:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i1-v6sor1794762oiy.225.2018.04.25.07.43.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Apr 2018 07:43:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAPcyv4hvrB08XPTbVK0xT2_1Xmaid=-v3OMxJVDTNwQucsOHLA@mail.gmail.com>
References: <20180425112415.12327-1-pagupta@redhat.com> <20180425112415.12327-2-pagupta@redhat.com>
 <CAPcyv4hvrB08XPTbVK0xT2_1Xmaid=-v3OMxJVDTNwQucsOHLA@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 25 Apr 2018 07:43:52 -0700
Message-ID: <CAPcyv4hiowWozV527sQA_e4fdgCYbD6xfG==vepAqu0hxQEQcw@mail.gmail.com>
Subject: Re: [RFC v2 1/2] virtio: add pmem driver
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pankaj Gupta <pagupta@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, KVM list <kvm@vger.kernel.org>, Qemu Developers <qemu-devel@nongnu.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, Stefan Hajnoczi <stefanha@redhat.com>, Rik van Riel <riel@surriel.com>, Haozhong Zhang <haozhong.zhang@intel.com>, Nitesh Narayan Lal <nilal@redhat.com>, Kevin Wolf <kwolf@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, "Zwisler, Ross" <ross.zwisler@intel.com>, David Hildenbrand <david@redhat.com>, Xiao Guangrong <xiaoguangrong.eric@gmail.com>, Christoph Hellwig <hch@infradead.org>, Marcel Apfelbaum <marcel@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, niteshnarayanlal@hotmail.com, Igor Mammedov <imammedo@redhat.com>, lcapitulino@redhat.com, jmoyer <jmoyer@redhat.com>

[ adding Jeff directly since he has also been looking at
infrastructure to track when MAP_SYNC should be disabled ]

On Wed, Apr 25, 2018 at 7:21 AM, Dan Williams <dan.j.williams@intel.com> wrote:
> On Wed, Apr 25, 2018 at 4:24 AM, Pankaj Gupta <pagupta@redhat.com> wrote:
>> This patch adds virtio-pmem driver for KVM
>> guest.
>
> Minor nit, please expand your changelog line wrapping to 72 columns.
>
>>
>> Guest reads the persistent memory range
>> information from Qemu over VIRTIO and registers
>> it on nvdimm_bus. It also creates a nd_region
>> object with the persistent memory range
>> information so that existing 'nvdimm/pmem'
>> driver can reserve this into system memory map.
>> This way 'virtio-pmem' driver uses existing
>> functionality of pmem driver to register persistent
>> memory compatible for DAX capable filesystems.
>
> We need some additional enabling to disable MAP_SYNC for this
> configuration. In other words, if fsync() is required then we must
> disable the MAP_SYNC optimization. I think this should be a struct
> dax_device property looked up at mmap time in each MAP_SYNC capable
> ->mmap() file operation implementation.
