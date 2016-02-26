Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id EDBC86B0009
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 23:45:09 -0500 (EST)
Received: by mail-qg0-f42.google.com with SMTP id d32so1756881qgd.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 20:45:09 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j107si11510636qgj.89.2016.02.25.20.45.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 20:45:09 -0800 (PST)
Subject: Re: [RFC][PATCH v3 1/2] mm/page_poison.c: Enable PAGE_POISONING as a
 separate option
References: <1456356923-5164-1-git-send-email-keescook@chromium.org>
 <1456356923-5164-2-git-send-email-keescook@chromium.org>
 <CAHz2CGWrUQMicbLUxkD95VxEGe65NM9Mo76wHj3BoNgnEnnHzg@mail.gmail.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <56CFD851.9040802@redhat.com>
Date: Thu, 25 Feb 2016 20:45:05 -0800
MIME-Version: 1.0
In-Reply-To: <CAHz2CGWrUQMicbLUxkD95VxEGe65NM9Mo76wHj3BoNgnEnnHzg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>, Kees Cook <keescook@chromium.org>
Cc: Laura Abbott <labbott@fedoraproject.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Mathias Krause <minipli@googlemail.com>, Dave Hansen <dave.hansen@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 02/25/2016 06:53 PM, Jianyu Zhan wrote:
> On Thu, Feb 25, 2016 at 7:35 AM, Kees Cook <keescook@chromium.org> wrote:
>>   config PAGE_POISONING
>> -       bool
>> +       bool "Poison pages after freeing"
>> +       select PAGE_EXTENSION
>> +       select PAGE_POISONING_NO_SANITY if HIBERNATION
>> +       ---help---
>> +         Fill the pages with poison patterns after free_pages() and verify
>> +         the patterns before alloc_pages. The filling of the memory helps
>> +         reduce the risk of information leaks from freed data. This does
>> +         have a potential performance impact.
>> +
>> +         If unsure, say N
>> +
>
> I would suggest that you add some wording in the help text to clarify
> that what "poisoning"
> means here is not the same as that in "HWPoison".
>
> The previous one is pattern padding, while the latter one is just
> nomenclature borrowed from
> Intel for memory failure.
>

Do you have some suggestion on wording here? I'm not sure what else to
say besides poison patterns to differentiate from hardware poison.
  
>> +config PAGE_POISONING_NO_SANITY
>> +       depends on PAGE_POISONING
>> +       bool "Only poison, don't sanity check"
>> +       ---help---
>> +          Skip the sanity checking on alloc, only fill the pages with
>> +          poison on free. This reduces some of the overhead of the
>> +          poisoning feature.
>> +
>> +          If you are only interested in sanitization, say Y. Otherwise
>> +          say N.
>> diff --git a/mm/Makefile b/mm/Makefile
>> index fb1a7948c107..ec59c071b4f9 100644
>> --- a/mm/Makefile
>> +++ b/mm/Makefile
>> @@ -13,7 +13,6 @@ KCOV_INSTRUMENT_slob.o := n
>>   KCOV_INSTRUMENT_slab.o := n
>>   KCOV_INSTRUMENT_slub.o := n
>>   KCOV_INSTRUMENT_page_alloc.o := n
>> -KCOV_INSTRUMENT_debug-pagealloc.o := n
>>   KCOV_INSTRUMENT_kmemleak.o := n
>>   KCOV_INSTRUMENT_kmemcheck.o := n
>>   KCOV_INSTRUMENT_memcontrol.o := n
>> @@ -63,9 +62,6 @@ obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
>>   obj-$(CONFIG_SLOB) += slob.o
>>   obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
>>   obj-$(CONFIG_KSM) += ksm.o
>> -ifndef CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC
>> -       obj-$(CONFIG_DEBUG_PAGEALLOC) += debug-pagealloc.o
>> -endif
>>   obj-$(CONFIG_PAGE_POISONING) += page_poison.o
>>   obj-$(CONFIG_SLAB) += slab.o
>>   obj-$(CONFIG_SLUB) += slub.o
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index a34c359d8e81..0bdb3cfd83b5 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -1026,6 +1026,7 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
>>                                             PAGE_SIZE << order);
>>          }
>>          arch_free_page(page, order);
>> +       kernel_poison_pages(page, 1 << order, 0);
>>          kernel_map_pages(page, 1 << order, 0);
>>
>>          return true;
>> @@ -1497,6 +1498,7 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
>>
>>          arch_alloc_page(page, order);
>>          kernel_map_pages(page, 1 << order, 1);
>> +       kernel_poison_pages(page, 1 << order, 1);
>>          kasan_alloc_pages(page, order);
>>
>>          if (gfp_flags & __GFP_ZERO)
>> diff --git a/mm/page_poison.c b/mm/page_poison.c
>> index 92ead727b8f0..884a6f854432 100644
>> --- a/mm/page_poison.c
>> +++ b/mm/page_poison.c
>> @@ -80,7 +80,7 @@ static void poison_page(struct page *page)
>>          kunmap_atomic(addr);
>>   }
>>
>> -void poison_pages(struct page *page, int n)
>> +static void poison_pages(struct page *page, int n)
>>   {
>>          int i;
>>
>> @@ -101,6 +101,9 @@ static void check_poison_mem(unsigned char *mem, size_t bytes)
>>          unsigned char *start;
>>          unsigned char *end;
>>
>> +       if (IS_ENABLED(CONFIG_PAGE_POISONING_NO_SANITY))
>> +               return;
>> +
>>          start = memchr_inv(mem, PAGE_POISON, bytes);
>>          if (!start)
>>                  return;
>> @@ -113,9 +116,9 @@ static void check_poison_mem(unsigned char *mem, size_t bytes)
>>          if (!__ratelimit(&ratelimit))
>>                  return;
>>          else if (start == end && single_bit_flip(*start, PAGE_POISON))
>> -               printk(KERN_ERR "pagealloc: single bit error\n");
>> +               pr_err("pagealloc: single bit error\n");
>>          else
>> -               printk(KERN_ERR "pagealloc: memory corruption\n");
>> +               pr_err("pagealloc: memory corruption\n");
>>
>>          print_hex_dump(KERN_ERR, "", DUMP_PREFIX_ADDRESS, 16, 1, start,
>>                          end - start + 1, 1);
>> @@ -135,10 +138,28 @@ static void unpoison_page(struct page *page)
>>          kunmap_atomic(addr);
>>   }
>>
>> -void unpoison_pages(struct page *page, int n)
>> +static void unpoison_pages(struct page *page, int n)
>>   {
>>          int i;
>>
>>          for (i = 0; i < n; i++)
>>                  unpoison_page(page + i);
>>   }
>> +
>> +void kernel_poison_pages(struct page *page, int numpages, int enable)
>> +{
>> +       if (!page_poisoning_enabled())
>> +               return;
>> +
>> +       if (enable)
>> +               unpoison_pages(page, numpages);
>> +       else
>> +               poison_pages(page, numpages);
>> +}
>> +
>> +#ifndef CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC
>> +void __kernel_map_pages(struct page *page, int numpages, int enable)
>> +{
>> +       /* This function does nothing, all work is done via poison pages */
>> +}
>> +#endif
>
> IMHO,  kernel_map_pages is originally incorporated for debugging page
> allocation.
> And latter for archs that do not support arch-specific page poisoning,
> a software poisoning
> method was used.
>
> So I think it is not appropriate to use two interfaces in the alloc/free hooks.
>
> The kernel_poison_pages actually should be an implementation detail
> and should be hided
> in the kernel_map_pages interface.
>

We want to have the poisoning independent of anything that kernel_map_pages
does. It was originally added for software poisoning for arches that
didn't have the full ARCH_SUPPORTS_DEBUG_PAGEALLOC support but there's
nothing that specifically ties it to mapping. It's beneficial even when
we aren't mapping/unmapping the pages so putting it in kernel_map_pages
would defeat what we're trying to accomplish here.
  
>
> Thanks,
> Jianyu Zhan
>

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
