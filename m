Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id ED8BC6B0028
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:29:12 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id o9so2933253pgv.8
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 09:29:12 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k7si6902933pgo.149.2018.04.16.09.29.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 16 Apr 2018 09:29:11 -0700 (PDT)
Subject: Re: [PATCH] dax: Change return type to vm_fault_t
References: <20180414155059.GA18015@jordon-HP-15-Notebook-PC>
 <CAPcyv4g+Gdc2tJ1qrM5Xn9vtARw-ZqFXaMbiaBKJJsYDtSNBig@mail.gmail.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <e20daa13-b756-8e8e-c98c-22030fb0a5f8@infradead.org>
Date: Mon, 16 Apr 2018 09:29:09 -0700
MIME-Version: 1.0
In-Reply-To: <CAPcyv4g+Gdc2tJ1qrM5Xn9vtARw-ZqFXaMbiaBKJJsYDtSNBig@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Souptick Joarder <jrdr.linux@gmail.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Matthew Wilcox <willy@infradead.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

On 04/16/2018 09:14 AM, Dan Williams wrote:
> On Sat, Apr 14, 2018 at 8:50 AM, Souptick Joarder <jrdr.linux@gmail.com> wrote:
>> Use new return type vm_fault_t for fault and
>> huge_fault handler.
>>
>> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
>> Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
>> ---
>>  drivers/dax/device.c | 26 +++++++++++---------------
>>  1 file changed, 11 insertions(+), 15 deletions(-)
>>
>> diff --git a/drivers/dax/device.c b/drivers/dax/device.c
>> index 2137dbc..a122701 100644
>> --- a/drivers/dax/device.c
>> +++ b/drivers/dax/device.c
>> @@ -243,11 +243,11 @@ __weak phys_addr_t dax_pgoff_to_phys(struct dev_dax *dev_dax, pgoff_t pgoff,
>>         return -1;
>>  }
>>
>> -static int __dev_dax_pte_fault(struct dev_dax *dev_dax, struct vm_fault *vmf)
>> +static vm_fault_t __dev_dax_pte_fault(struct dev_dax *dev_dax,
>> +                               struct vm_fault *vmf)
>>  {
>>         struct device *dev = &dev_dax->dev;
>>         struct dax_region *dax_region;
>> -       int rc = VM_FAULT_SIGBUS;
>>         phys_addr_t phys;
>>         pfn_t pfn;
>>         unsigned int fault_size = PAGE_SIZE;
>> @@ -274,17 +274,11 @@ static int __dev_dax_pte_fault(struct dev_dax *dev_dax, struct vm_fault *vmf)
>>
>>         pfn = phys_to_pfn_t(phys, dax_region->pfn_flags);
>>
>> -       rc = vm_insert_mixed(vmf->vma, vmf->address, pfn);
>> -
>> -       if (rc == -ENOMEM)
>> -               return VM_FAULT_OOM;
>> -       if (rc < 0 && rc != -EBUSY)
>> -               return VM_FAULT_SIGBUS;
>> -
>> -       return VM_FAULT_NOPAGE;
>> +       return vmf_insert_mixed(vmf->vma, vmf->address, pfn);
> 
> Ugh, so this change to vmf_insert_mixed() went upstream without fixing
> the users? This changelog is now misleading as it does not mention
> that is now an urgent standalone fix. On first read I assumed this was
> part of a wider effort for 4.18.
> 
> Grumble, we'll get this applied with a 'Fixes: 1c8f422059ae ("mm:
> change return type to vm_fault_t")' tag.
> 

Thanks for that explanation. The patch description is missing any kind
of "why" (justification).


-- 
~Randy
