Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6450A6B0038
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 20:06:24 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id l8so67726026iti.6
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 17:06:24 -0800 (PST)
Received: from mail-it0-x231.google.com (mail-it0-x231.google.com. [2607:f8b0:4001:c0b::231])
        by mx.google.com with ESMTPS id y15si14243457ioe.241.2016.11.14.17.06.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Nov 2016 17:06:23 -0800 (PST)
Received: by mail-it0-x231.google.com with SMTP id q124so138363260itd.1
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 17:06:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161114162529.1a5b08ff90f6f199c1be8cc9@linux-foundation.org>
References: <147892450132.22062.16875659431109209179.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20161114162529.1a5b08ff90f6f199c1be8cc9@linux-foundation.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 14 Nov 2016 17:06:23 -0800
Message-ID: <CAPcyv4g0kHH_HQH4Op8HSUKn1MFak_BS1V0VSBx99kRhgQMmAw@mail.gmail.com>
Subject: Re: [PATCH] mm: disable numa migration faults for dax vmas
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On Mon, Nov 14, 2016 at 4:25 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, 11 Nov 2016 20:21:41 -0800 Dan Williams <dan.j.williams@intel.com> wrote:
>
>> Mark dax vmas as not migratable to exclude them from task_numa_work().
>> This is especially relevant for device-dax which wants to ensure
>> predictable access latency and not incur periodic faults.
>>
>> ...
>>
>> @@ -177,6 +178,9 @@ static inline bool vma_migratable(struct vm_area_struct *vma)
>>       if (vma->vm_flags & (VM_IO | VM_PFNMAP))
>>               return false;
>>
>> +     if (vma_is_dax(vma))
>> +             return false;
>> +
>>  #ifndef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
>>       if (vma->vm_flags & VM_HUGETLB)
>>               return false;
>
> I don't think the reader could figure out why this code is here, so...  this?
>
> --- a/include/linux/mempolicy.h~mm-disable-numa-migration-faults-for-dax-vmas-fix
> +++ a/include/linux/mempolicy.h
> @@ -180,6 +180,10 @@ static inline bool vma_migratable(struct
>         if (vma->vm_flags & (VM_IO | VM_PFNMAP))
>                 return false;
>
> +       /*
> +        * DAX device mappings require predictable access latency, so avoid
> +        * incurring periodic faults.
> +        */
>         if (vma_is_dax(vma))
>                 return false;
>

Yes, thanks for fixing it up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
