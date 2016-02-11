Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id C4B666B0005
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 20:58:27 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id xk3so55428409obc.2
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 17:58:27 -0800 (PST)
Received: from mail-ob0-x243.google.com (mail-ob0-x243.google.com. [2607:f8b0:4003:c01::243])
        by mx.google.com with ESMTPS id d3si5782303obo.16.2016.02.10.17.58.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Feb 2016 17:58:26 -0800 (PST)
Received: by mail-ob0-x243.google.com with SMTP id x5so4007392obg.1
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 17:58:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160210105845.973cecc56906ed950fbdd8ba@linux-foundation.org>
References: <1454566775-30973-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1454566775-30973-3-git-send-email-iamjoonsoo.kim@lge.com>
	<20160204164929.a2f12b8a7edcdfa596abd850@linux-foundation.org>
	<CAAmzW4Pps1gSXb5qCvbkC=wNjcySgVYZu1jLeBWy31q7RNWVYg@mail.gmail.com>
	<56BA28C8.3060903@suse.cz>
	<20160209125301.c7e6067558c321cfb87602b5@linux-foundation.org>
	<56BB3E61.50707@suse.cz>
	<20160210105845.973cecc56906ed950fbdd8ba@linux-foundation.org>
Date: Thu, 11 Feb 2016 10:58:26 +0900
Message-ID: <CAAmzW4OW-gDsGgmSHzgE5R7GeLXYG78Gz6mhJJz9QPwPCchmiA@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] mm/compaction: speed up pageblock_pfn_to_page()
 when zone is contiguous
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Aaron Lu <aaron.lu@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

2016-02-11 3:58 GMT+09:00 Andrew Morton <akpm@linux-foundation.org>:
> On Wed, 10 Feb 2016 14:42:57 +0100 Vlastimil Babka <vbabka@suse.cz> wrote:
>
>> > --- a/mm/memory_hotplug.c
>> > +++ b/mm/memory_hotplug.c
>> > @@ -509,6 +509,8 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
>> >     int start_sec, end_sec;
>> >     struct vmem_altmap *altmap;
>> >
>> > +   clear_zone_contiguous(zone);
>> > +
>> >     /* during initialize mem_map, align hot-added range to section */
>> >     start_sec = pfn_to_section_nr(phys_start_pfn);
>> >     end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
>> > @@ -540,6 +542,8 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
>> >     }
>> >     vmemmap_populate_print_last();
>> >
>> > +   set_zone_contiguous(zone);
>> > +
>> >     return err;
>> >  }
>> >  EXPORT_SYMBOL_GPL(__add_pages);
>>
>> Between the clear and set, __add_pages() might return with -EINVAL,
>> leaving the flag cleared potentially forever. Not critical, probably
>> rare, but it should be possible to avoid this by moving the clear below
>> the altmap check?
>
> um, yes.  return-in-the-middle-of-a-function strikes again.
>
> --- a/mm/memory_hotplug.c~mm-compaction-speed-up-pageblock_pfn_to_page-when-zone-is-contiguous-fix
> +++ a/mm/memory_hotplug.c
> @@ -526,7 +526,8 @@ int __ref __add_pages(int nid, struct zo
>                 if (altmap->base_pfn != phys_start_pfn
>                                 || vmem_altmap_offset(altmap) > nr_pages) {
>                         pr_warn_once("memory add fail, invalid altmap\n");
> -                       return -EINVAL;
> +                       err = -EINVAL;
> +                       goto out;
>                 }
>                 altmap->alloc = 0;
>         }
> @@ -544,9 +545,8 @@ int __ref __add_pages(int nid, struct zo
>                 err = 0;
>         }
>         vmemmap_populate_print_last();
> -
> +out:
>         set_zone_contiguous(zone);
> -
>         return err;
>  }
>  EXPORT_SYMBOL_GPL(__add_pages);

Sorry for late response. I was on biggest holiday in Korea until now.
It seems that there is no issue left.
Andrew, Vlastimil, thanks for fixes and review.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
