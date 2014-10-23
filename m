Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 0A2F06B0069
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 17:09:33 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id g10so170018pdj.24
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 14:09:33 -0700 (PDT)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com. [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id 1si2581338pdr.58.2014.10.23.14.09.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Oct 2014 14:09:33 -0700 (PDT)
Received: by mail-pd0-f179.google.com with SMTP id g10so183921pdj.10
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 14:09:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20141023132233.b156cd79badc1254eff08494@linux-foundation.org>
References: <1413893696-25484-1-git-send-email-thierry.reding@gmail.com> <20141023132233.b156cd79badc1254eff08494@linux-foundation.org>
From: Catalin Marinas <catalin.marinas@arm.com>
Date: Thu, 23 Oct 2014 22:09:12 +0100
Message-ID: <CAHkRjk5KLR1390eiRdXcNmppVKWBgugutsuvhpesMwXYa6CRzA@mail.gmail.com>
Subject: Re: [PATCH] mm/cma: Make kmemleak ignore CMA regions
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Thierry Reding <thierry.reding@gmail.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 23 October 2014 21:22, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Tue, 21 Oct 2014 14:14:56 +0200 Thierry Reding <thierry.reding@gmail.com> wrote:
>
>> From: Thierry Reding <treding@nvidia.com>
>>
>> kmemleak will add allocations as objects to a pool. The memory allocated
>> for each object in this pool is periodically searched for pointers to
>> other allocated objects. This only works for memory that is mapped into
>> the kernel's virtual address space, which happens not to be the case for
>> most CMA regions.
>>
>> Furthermore, CMA regions are typically used to store data transferred to
>> or from a device and therefore don't contain pointers to other objects.
>>
>> Signed-off-by: Thierry Reding <treding@nvidia.com>
>> ---
>> Note: I'm not sure this is really the right fix. But without this, the
>> kernel crashes on the first execution of the scan_gray_list() because
>> it tries to access highmem. Perhaps a more appropriate fix would be to
>> reject any object that can't map to a kernel virtual address?
>
> Let's cc Catalin.
>
>> --- a/mm/cma.c
>> +++ b/mm/cma.c
>> @@ -280,6 +280,7 @@ int __init cma_declare_contiguous(phys_addr_t base,
>>                       ret = -ENOMEM;
>>                       goto err;
>>               } else {
>> +                     kmemleak_ignore(phys_to_virt(addr));
>>                       base = addr;
>>               }
>>       }

I wonder whether using __va() for the argument of kmemleak_alloc() in
memblock_alloc_range_nid() is always correct. Is
memblock.current_limit guaranteed to be in lowmem? If not, I think we
need some logic not to call kmemleak_alloc() for all memblock
allocations (and avoid the need to ignore them later).

> And let's tell our poor readers why we did stuff.  Something like this.
>
> --- a/mm/cma.c~mm-cma-make-kmemleak-ignore-cma-regions-fix
> +++ a/mm/cma.c
> @@ -280,6 +280,10 @@ int __init cma_declare_contiguous(phys_a
>                         ret = -ENOMEM;
>                         goto err;
>                 } else {
> +                       /*
> +                        * kmemleak writes metadata to the tracked objects, but
> +                        * this address isn't mapped and accessible.
> +                        */
>                         kmemleak_ignore(phys_to_virt(addr));
>                         base = addr;
>                 }

The reason is different, as per Therry's patch description. Kmemleak
does not write metadata to the tracked objects but reads them during
memory scanning. So maybe something like "kmemleak scans/reads tracked
objects for pointers to other objects but this address isn't mapped
and accessible."

A better API to use here would have been kmemleak_no_scan(), however,
I don't think we care about such CMA pointers anyway since they seem
to be tracked by physical address which kmemleak doesn't store.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
