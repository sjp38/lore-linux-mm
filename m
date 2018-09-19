Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 27D118E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 03:20:32 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id 123-v6so3277731qkl.3
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 00:20:32 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b37-v6si1106575qkb.397.2018.09.19.00.20.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Sep 2018 00:20:30 -0700 (PDT)
Subject: Re: [PATCH V5 4/4] kvm: add a check if pfn is from NVDIMM pmem.
References: <cover.1536342881.git.yi.z.zhang@linux.intel.com>
 <4e8c2e0facd46cfaf4ab79e19c9115958ab6f218.1536342881.git.yi.z.zhang@linux.intel.com>
 <CAPcyv4ifg2BZMTNfu6mg0xxtPWs3BVgkfEj51v1CQ6jp2S70fw@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <fefbd66e-623d-b6a5-7202-5309dd4f5b32@redhat.com>
Date: Wed, 19 Sep 2018 09:20:25 +0200
MIME-Version: 1.0
In-Reply-To: <CAPcyv4ifg2BZMTNfu6mg0xxtPWs3BVgkfEj51v1CQ6jp2S70fw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>
Cc: KVM list <kvm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Paolo Bonzini <pbonzini@redhat.com>, Dave Jiang <dave.jiang@intel.com>, "Zhang, Yu C" <yu.c.zhang@intel.com>, Pankaj Gupta <pagupta@redhat.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, rkrcmar@redhat.com, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "Zhang, Yi Z" <yi.z.zhang@intel.com>

Am 19.09.18 um 04:53 schrieb Dan Williams:
> On Fri, Sep 7, 2018 at 2:25 AM Zhang Yi <yi.z.zhang@linux.intel.com> wrote:
>>
>> For device specific memory space, when we move these area of pfn to
>> memory zone, we will set the page reserved flag at that time, some of
>> these reserved for device mmio, and some of these are not, such as
>> NVDIMM pmem.
>>
>> Now, we map these dev_dax or fs_dax pages to kvm for DIMM/NVDIMM
>> backend, since these pages are reserved, the check of
>> kvm_is_reserved_pfn() misconceives those pages as MMIO. Therefor, we
>> introduce 2 page map types, MEMORY_DEVICE_FS_DAX/MEMORY_DEVICE_DEV_DAX,
>> to identify these pages are from NVDIMM pmem and let kvm treat these
>> as normal pages.
>>
>> Without this patch, many operations will be missed due to this
>> mistreatment to pmem pages, for example, a page may not have chance to
>> be unpinned for KVM guest(in kvm_release_pfn_clean), not able to be
>> marked as dirty/accessed(in kvm_set_pfn_dirty/accessed) etc.
>>
>> Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
>> Acked-by: Pankaj Gupta <pagupta@redhat.com>
>> ---
>>  virt/kvm/kvm_main.c | 16 ++++++++++++++--
>>  1 file changed, 14 insertions(+), 2 deletions(-)
>>
>> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
>> index c44c406..9c49634 100644
>> --- a/virt/kvm/kvm_main.c
>> +++ b/virt/kvm/kvm_main.c
>> @@ -147,8 +147,20 @@ __weak void kvm_arch_mmu_notifier_invalidate_range(struct kvm *kvm,
>>
>>  bool kvm_is_reserved_pfn(kvm_pfn_t pfn)
>>  {
>> -       if (pfn_valid(pfn))
>> -               return PageReserved(pfn_to_page(pfn));
>> +       struct page *page;
>> +
>> +       if (pfn_valid(pfn)) {
>> +               page = pfn_to_page(pfn);
>> +
>> +               /*
>> +                * For device specific memory space, there is a case
>> +                * which we need pass MEMORY_DEVICE_FS[DEV]_DAX pages
>> +                * to kvm, these pages marked reserved flag as it is a
>> +                * zone device memory, we need to identify these pages
>> +                * and let kvm treat these as normal pages
>> +                */
>> +               return PageReserved(page) && !is_dax_page(page);
> 
> Should we consider just not setting PageReserved for
> devm_memremap_pages()? Perhaps kvm is not be the only component making
> these assumptions about this flag?

I was asking the exact same question in v3 or so.

I was recently going through all PageReserved users, trying to clean up
and document how it is used.

PG_reserved used to be a marker "not available for the page allocator".
This is only partially true and not really helpful I think. My current
understanding:

"
PG_reserved is set for special pages, struct pages of such pages should
in general not be touched except by their owner. Pages marked as
reserved include:
- Kernel image (including vDSO) and similar (e.g. BIOS, initrd)
- Pages allocated early during boot (bootmem, memblock)
- Zero pages
- Pages that have been associated with a zone but were not onlined
  (e.g. NVDIMM/pmem, online_page_callback used by XEN)
- Pages to exclude from the hibernation image (e.g. loaded kexec images)
- MCA (memory error) pages on ia64
- Offline pages
Some architectures don't allow to ioremap RAM pages that are not marked
as reserved. Allocated pages might have to be set reserved to allow for
that - if there is a good reason to enforce this. Consequently,
PG_reserved part of a user space table might be the indicator for the
zero page, pmem or MMIO pages.
"

Swapping code does not care about PageReserved at all as far as I
remember. This seems to be fine as it only looks at the way pages have
been mapped into user space.

I don't really see a good reason to set pmem pages as reserved. One
question would be, how/if to exclude them from the hibernation image.
But that could also be solved differently (we would have to double check
how they are handled in hibernation code).


A similar user of PageReserved to look at is:

drivers/vfio/vfio_iommu_type1.c:is_invalid_reserved_pfn()

It will not mark pages dirty if they are reserved. Similar to KVM code.

> 
> Why is MEMORY_DEVICE_PUBLIC memory specifically excluded?
> 
> This has less to do with "dax" pages and more to do with
> devm_memremap_pages() established ranges. P2PDMA is another producer
> of these pages. If either MEMORY_DEVICE_PUBLIC or P2PDMA pages can be
> used in these kvm paths then I think this points to consider clearing
> the Reserved flag.
> 
> That said I haven't audited all the locations that test PageReserved().
> 
> Sorry for not responding sooner I was on extended leave.
> 


-- 

Thanks,

David / dhildenb
