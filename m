Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9A5346B000A
	for <linux-mm@kvack.org>; Mon, 13 Aug 2018 05:48:23 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id z3-v6so10652600plb.16
        for <linux-mm@kvack.org>; Mon, 13 Aug 2018 02:48:23 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a5-v6si15055100pgd.400.2018.08.13.02.48.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Aug 2018 02:48:22 -0700 (PDT)
Subject: Re: [PATCH V3 4/4] kvm: add a check if pfn is from NVDIMM pmem.
References: <cover.1533811181.git.yi.z.zhang@linux.intel.com>
 <0cc6cba7020f80168695fba731b8fd72fd649dc8.1533811181.git.yi.z.zhang@linux.intel.com>
 <2130082365.883434.1533803526182.JavaMail.zimbra@redhat.com>
From: "Zhang,Yi" <yi.z.zhang@linux.intel.com>
Message-ID: <083b8170-a9ba-beee-7578-6d33e70a8b6e@linux.intel.com>
Date: Tue, 14 Aug 2018 01:32:05 +0800
MIME-Version: 1.0
In-Reply-To: <2130082365.883434.1533803526182.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pankaj Gupta <pagupta@redhat.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan j williams <dan.j.williams@intel.com>, jack@suse.cz, hch@lst.de, yu c zhang <yu.c.zhang@intel.com>, linux-mm@kvack.org, rkrcmar@redhat.com, yi z zhang <yi.z.zhang@intel.com>



On 2018a1'08ae??09ae?JPY 16:32, Pankaj Gupta wrote:
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
> s/indentify/identify & remove '.'
Thanks Pankaj, :-)
>
>> as normal pages.
>>
>> Without this patch, Many operations will be missed due to this
>> mistreatment to pmem pages. For example, a page may not have chance to
>> be unpinned for KVM guest(in kvm_release_pfn_clean); not able to be
>> marked as dirty/accessed(in kvm_set_pfn_dirty/accessed) etc
>>
>> Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
>> ---
>>  virt/kvm/kvm_main.c | 8 ++++++--
>>  1 file changed, 6 insertions(+), 2 deletions(-)
>>
>> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
>> index c44c406..969b6ca 100644
>> --- a/virt/kvm/kvm_main.c
>> +++ b/virt/kvm/kvm_main.c
>> @@ -147,8 +147,12 @@ __weak void
>> kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
>>  
>>  bool kvm_is_reserved_pfn(kvm_pfn_t pfn)
>>  {
>> -        if (pfn_valid(pfn))
>> -                return PageReserved(pfn_to_page(pfn));
>> +        struct page *page;
>> +
>> +        if (pfn_valid(pfn)) {
>> +                page = pfn_to_page(pfn);
>> +                return PageReserved(page) && !is_dax_page(page);
>> +        }
>>  
>>          return true;
>>  }
>> --
>> 2.7.4
>>
>>
