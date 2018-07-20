Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 992096B0010
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 04:38:56 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id o16-v6so5506180pgv.21
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 01:38:56 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id f59-v6si1228127plf.500.2018.07.20.01.38.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 01:38:55 -0700 (PDT)
Subject: Re: [PATCH V2 0/4] Fix kvm misconceives NVDIMM pages as reserved mmio
References: <cover.1531241281.git.yi.z.zhang@linux.intel.com>
 <c4e1c527-a372-bd6a-a101-5a8e9026e7c1@linux.intel.com>
 <25569674-2d8f-8b54-4ba7-478b57067325@redhat.com>
From: "Zhang,Yi" <yi.z.zhang@linux.intel.com>
Message-ID: <3e822509-dc66-0fe8-bad6-d4e4ef9eb528@linux.intel.com>
Date: Sat, 21 Jul 2018 00:24:41 +0800
MIME-Version: 1.0
In-Reply-To: <25569674-2d8f-8b54-4ba7-478b57067325@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, dan.j.williams@intel.com, jack@suse.cz, hch@lst.de, yu.c.zhang@intel.com, dave.jiang@intel.com
Cc: linux-mm@kvack.org, rkrcmar@redhat.com, yi.z.zhang@intel.com

Thanks Paolo, let's wait Jan&Dan 's comments.

Thank you, Paolo.

Regards
Yi

On 2018a1'07ae??20ae?JPY 16:32, Paolo Bonzini wrote:
> On 20/07/2018 16:11, Zhang,Yi wrote:
>> Added Jiang,Dave,
>>
>> Ping for further review, comments.
> I need an Acked-by from the MM people to merge this.  Jan, Dan?
>
> Paolo
>
>> Thanks All
>>
>> Regards
>> Yi.
>>
>>
>> On 2018a1'07ae??11ae?JPY 01:01, Zhang Yi wrote:
>>> For device specific memory space, when we move these area of pfn to
>>> memory zone, we will set the page reserved flag at that time, some of
>>> these reserved for device mmio, and some of these are not, such as
>>> NVDIMM pmem.
>>>
>>> Now, we map these dev_dax or fs_dax pages to kvm for DIMM/NVDIMM
>>> backend, since these pages are reserved. the check of
>>> kvm_is_reserved_pfn() misconceives those pages as MMIO. Therefor, we
>>> introduce 2 page map types, MEMORY_DEVICE_FS_DAX/MEMORY_DEVICE_DEV_DAX,
>>> to indentify these pages are from NVDIMM pmem. and let kvm treat these
>>> as normal pages.
>>>
>>> Without this patch, Many operations will be missed due to this
>>> mistreatment to pmem pages. For example, a page may not have chance to
>>> be unpinned for KVM guest(in kvm_release_pfn_clean); not able to be
>>> marked as dirty/accessed(in kvm_set_pfn_dirty/accessed) etc.
>>>
>>> V1:
>>> https://lkml.org/lkml/2018/7/4/91
>>>
>>> V2:
>>> *Add documentation for MEMORY_DEVICE_DEV_DAX memory type in comment block
>>> *Add is_dax_page() in mm.h to differentiate the pages is from DAX device.
>>> *Remove the function kvm_is_nd_pfn().
>>>
>>> Zhang Yi (4):
>>>   kvm: remove redundant reserved page check
>>>   mm: introduce memory type MEMORY_DEVICE_DEV_DAX
>>>   mm: add a function to differentiate the pages is from DAX device
>>>     memory
>>>   kvm: add a check if pfn is from NVDIMM pmem.
>>>
>>>  drivers/dax/pmem.c       |  1 +
>>>  include/linux/memremap.h |  9 +++++++++
>>>  include/linux/mm.h       | 12 ++++++++++++
>>>  virt/kvm/kvm_main.c      | 16 ++++++++--------
>>>  4 files changed, 30 insertions(+), 8 deletions(-)
>>>
>>
