Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 52B826B0006
	for <linux-mm@kvack.org>; Mon, 13 Aug 2018 05:41:38 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id d12-v6so6964122pgv.12
        for <linux-mm@kvack.org>; Mon, 13 Aug 2018 02:41:38 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id z125-v6si19470675pfz.10.2018.08.13.02.41.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Aug 2018 02:41:37 -0700 (PDT)
Subject: Re: [PATCH V3 0/4] Fix kvm misconceives NVDIMM pages as reserved mmio
References: <cover.1533811181.git.yi.z.zhang@linux.intel.com>
 <76cbaf38-1c72-0b45-4075-add904226725@redhat.com>
From: "Zhang,Yi" <yi.z.zhang@linux.intel.com>
Message-ID: <0f4f0d15-7949-c576-1981-145e7758ae4a@linux.intel.com>
Date: Tue, 14 Aug 2018 01:25:38 +0800
MIME-Version: 1.0
In-Reply-To: <76cbaf38-1c72-0b45-4075-add904226725@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan.j.williams@intel.com, jack@suse.cz, hch@lst.de, yu.c.zhang@intel.com
Cc: linux-mm@kvack.org, rkrcmar@redhat.com, yi.z.zhang@intel.com



On 2018a1'08ae??10ae?JPY 21:27, David Hildenbrand wrote:
> On 09.08.2018 12:52, Zhang Yi wrote:
>> For device specific memory space, when we move these area of pfn to
>> memory zone, we will set the page reserved flag at that time, some of
>> these reserved for device mmio, and some of these are not, such as
>> NVDIMM pmem.
>>
>> Now, we map these dev_dax or fs_dax pages to kvm for DIMM/NVDIMM
>> backend, since these pages are reserved. the check of
>> kvm_is_reserved_pfn() misconceives those pages as MMIO. Therefor, we
>> introduce 2 page map types, MEMORY_DEVICE_FS_DAX/MEMORY_DEVICE_DEV_DAX,
>> to indentify these pages are from NVDIMM pmem. and let kvm treat these
>> as normal pages.
>>
>> Without this patch, Many operations will be missed due to this
>> mistreatment to pmem pages. For example, a page may not have chance to
>> be unpinned for KVM guest(in kvm_release_pfn_clean); not able to be
>> marked as dirty/accessed(in kvm_set_pfn_dirty/accessed) etc.
>>
> I am right now looking into (and trying to better document) PG_reserved
> - and having a hard time :) .
>
> One of the main points about reserved pages is that the struct pages are
> not to be touched. See [1] (I know that statement is fairly old, but it
> resembles what PG_reserved is actually used for nowadays - with some
> exceptions unfortunately.).
>
> Struct pages part of user space tables that are PG_reserved can indicate
> (as of now according to my research)
> - MMIO pages
> - Selected MMAPed pages - e.g. vDSO
> - Zero page
> - PMEM pages as you correctly state
>
> So I wonder, if it is really the right approach to silently go ahead and
> treat reserved pages just like they would not be reserved. Maybe the
> right approach would rather be to do something about pmem pages being
> reserved. Yes, they are never to be given to the page allocator, but I
> wonder if PG_reserved is strictly needed for that.
>
> [1] https://lists.linuxcoding.com/kernel/2005-q3/msg10350.html

Thanks David list the long history of Page reserved, By now, I think we treat nvdimm as a device not a DRAM, also has it's device driver which manager its own device memory. From this perspective, it is reasonable to set these pages as zone device memory and mark reserved flag.
@Dan @Dave, how do you think about this?

>
>> V1:
>> https://lkml.org/lkml/2018/7/4/91
>>
>> V2:
>> https://lkml.org/lkml/2018/7/10/135
>>
>> V3:
>> [PATCH V3 1/4] Needs Comments.
>> [PATCH V3 2/4] Update the description of MEMORY_DEVICE_DEV_DAX: Jan
>> [PATCH V3 3/4] Acked-by: Jan in V2
>> [PATCH V3 4/4] Needs Comments.
>>
>> Zhang Yi (4):
>>   kvm: remove redundant reserved page check
>>   mm: introduce memory type MEMORY_DEVICE_DEV_DAX
>>   mm: add a function to differentiate the pages is from DAX device
>>     memory
>>   kvm: add a check if pfn is from NVDIMM pmem.
>>
>>  drivers/dax/pmem.c       |  1 +
>>  include/linux/memremap.h |  8 ++++++++
>>  include/linux/mm.h       | 12 ++++++++++++
>>  virt/kvm/kvm_main.c      | 16 ++++++++--------
>>  4 files changed, 29 insertions(+), 8 deletions(-)
>>
>
