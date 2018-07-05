Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 05A2C6B0005
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 01:33:29 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 70-v6so1260149plc.1
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 22:33:28 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e17-v6si4531536pgv.160.2018.07.04.22.33.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 22:33:27 -0700 (PDT)
Subject: Re: [PATCH 3/3] kvm: add a function to check if page is from NVDIMM
 pmem.
References: <cover.1530716899.git.yi.z.zhang@linux.intel.com>
 <359fdf0103b61014bf811d88d4ce36bc793d18f2.1530716899.git.yi.z.zhang@linux.intel.com>
 <1efab832-8782-38f3-9fd5-7a8b45bde153@redhat.com>
From: "Zhang,Yi" <yi.z.zhang@linux.intel.com>
Message-ID: <a6049ab7-19f4-3cdb-a954-c8ad7a05ed37@linux.intel.com>
Date: Thu, 5 Jul 2018 21:19:30 +0800
MIME-Version: 1.0
In-Reply-To: <1efab832-8782-38f3-9fd5-7a8b45bde153@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, dan.j.williams@intel.com, jack@suse.cz, hch@lst.de, yu.c.zhang@intel.com
Cc: linux-mm@kvack.org, rkrcmar@redhat.com, yi.z.zhang@intel.com



On 2018a1'07ae??04ae?JPY 23:25, Paolo Bonzini wrote:
> On 04/07/2018 17:30, Zhang Yi wrote:
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
>> Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
>> Signed-off-by: Zhang Yu <yu.c.zhang@linux.intel.com>
>> ---
>>  virt/kvm/kvm_main.c | 17 +++++++++++++++--
>>  1 file changed, 15 insertions(+), 2 deletions(-)
>>
>> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
>> index afb2e6e..1365d18 100644
>> --- a/virt/kvm/kvm_main.c
>> +++ b/virt/kvm/kvm_main.c
>> @@ -140,10 +140,23 @@ __weak void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
>>  {
>>  }
>>  
>> +static bool kvm_is_nd_pfn(kvm_pfn_t pfn)
>> +{
>> +	struct page *page = pfn_to_page(pfn);
>> +
>> +	return is_zone_device_page(page) &&
>> +		((page->pgmap->type == MEMORY_DEVICE_FS_DAX) ||
>> +		 (page->pgmap->type == MEMORY_DEVICE_DEV_DAX));
>> +}
> If the mm people agree, I'd prefer something that takes a struct page *
> and is exported by include/linux/mm.h.  Then KVM can just do something like
>
> 	struct page *page;
> 	if (!pfn_valid(pfn))
> 		return true;
>
> 	page = pfn_to_page(pfn);
> 	return PageReserved(page) && !is_dax_page(page);
>
> Thanks,
>
> Paolo
Yeah, that could be much better. Thanks for your comments Paolo.

Hi Kara, Do u have Any opinions/ideas to add such definition in mm?

Regards,
Yi
