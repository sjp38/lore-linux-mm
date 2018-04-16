Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id AC55E6B0007
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:38:04 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id a1-v6so2727860lfa.16
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 09:38:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q9-v6sor2841131lfe.44.2018.04.16.09.38.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Apr 2018 09:38:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <e20daa13-b756-8e8e-c98c-22030fb0a5f8@infradead.org>
References: <20180414155059.GA18015@jordon-HP-15-Notebook-PC>
 <CAPcyv4g+Gdc2tJ1qrM5Xn9vtARw-ZqFXaMbiaBKJJsYDtSNBig@mail.gmail.com> <e20daa13-b756-8e8e-c98c-22030fb0a5f8@infradead.org>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Mon, 16 Apr 2018 22:08:01 +0530
Message-ID: <CAFqt6zZpPTY0mX5d9NVJ=imBkFw+1yVEDvo0OVKhBpZaYn0vAw@mail.gmail.com>
Subject: Re: [PATCH] dax: Change return type to vm_fault_t
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Dan Williams <dan.j.williams@intel.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Matthew Wilcox <willy@infradead.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

On Mon, Apr 16, 2018 at 9:59 PM, Randy Dunlap <rdunlap@infradead.org> wrote:
> On 04/16/2018 09:14 AM, Dan Williams wrote:
>> On Sat, Apr 14, 2018 at 8:50 AM, Souptick Joarder <jrdr.linux@gmail.com> wrote:
>>> Use new return type vm_fault_t for fault and
>>> huge_fault handler.
>>>
>>> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
>>> Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
>>> ---
>>>  drivers/dax/device.c | 26 +++++++++++---------------
>>>  1 file changed, 11 insertions(+), 15 deletions(-)
>>>
>>> diff --git a/drivers/dax/device.c b/drivers/dax/device.c
>>> index 2137dbc..a122701 100644
>>> --- a/drivers/dax/device.c
>>> +++ b/drivers/dax/device.c
>>> @@ -243,11 +243,11 @@ __weak phys_addr_t dax_pgoff_to_phys(struct dev_dax *dev_dax, pgoff_t pgoff,
>>>         return -1;
>>>  }
>>>
>>> -static int __dev_dax_pte_fault(struct dev_dax *dev_dax, struct vm_fault *vmf)
>>> +static vm_fault_t __dev_dax_pte_fault(struct dev_dax *dev_dax,
>>> +                               struct vm_fault *vmf)
>>>  {
>>>         struct device *dev = &dev_dax->dev;
>>>         struct dax_region *dax_region;
>>> -       int rc = VM_FAULT_SIGBUS;
>>>         phys_addr_t phys;
>>>         pfn_t pfn;
>>>         unsigned int fault_size = PAGE_SIZE;
>>> @@ -274,17 +274,11 @@ static int __dev_dax_pte_fault(struct dev_dax *dev_dax, struct vm_fault *vmf)
>>>
>>>         pfn = phys_to_pfn_t(phys, dax_region->pfn_flags);
>>>
>>> -       rc = vm_insert_mixed(vmf->vma, vmf->address, pfn);
>>> -
>>> -       if (rc == -ENOMEM)
>>> -               return VM_FAULT_OOM;
>>> -       if (rc < 0 && rc != -EBUSY)
>>> -               return VM_FAULT_SIGBUS;
>>> -
>>> -       return VM_FAULT_NOPAGE;
>>> +       return vmf_insert_mixed(vmf->vma, vmf->address, pfn);
>>
>> Ugh, so this change to vmf_insert_mixed() went upstream without fixing
>> the users? This changelog is now misleading as it does not mention
>> that is now an urgent standalone fix. On first read I assumed this was
>> part of a wider effort for 4.18.
>>
>> Grumble, we'll get this applied with a 'Fixes: 1c8f422059ae ("mm:
>> change return type to vm_fault_t")' tag.
>>
>
> Thanks for that explanation. The patch description is missing any kind
> of "why" (justification).

ok, I will send v2 with description.

>
>
> --
> ~Randy
