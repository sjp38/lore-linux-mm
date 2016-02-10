Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3C8676B0009
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 08:43:01 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id c200so29143569wme.0
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 05:43:01 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bg9si4656129wjb.182.2016.02.10.05.42.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Feb 2016 05:43:00 -0800 (PST)
Subject: Re: [PATCH v2 3/3] mm/compaction: speed up pageblock_pfn_to_page()
 when zone is contiguous
References: <1454566775-30973-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1454566775-30973-3-git-send-email-iamjoonsoo.kim@lge.com>
 <20160204164929.a2f12b8a7edcdfa596abd850@linux-foundation.org>
 <CAAmzW4Pps1gSXb5qCvbkC=wNjcySgVYZu1jLeBWy31q7RNWVYg@mail.gmail.com>
 <56BA28C8.3060903@suse.cz>
 <20160209125301.c7e6067558c321cfb87602b5@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56BB3E61.50707@suse.cz>
Date: Wed, 10 Feb 2016 14:42:57 +0100
MIME-Version: 1.0
In-Reply-To: <20160209125301.c7e6067558c321cfb87602b5@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Aaron Lu <aaron.lu@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 02/09/2016 09:53 PM, Andrew Morton wrote:
> On Tue, 9 Feb 2016 18:58:32 +0100 Vlastimil Babka <vbabka@suse.cz> wrote:
> 
>> On 02/05/2016 05:11 PM, Joonsoo Kim wrote:
>>> Yeah, it seems wrong to me. :)
>>> Here goes fix.
>>
>> Doesn't apply for me, even after fixing the most obvious line wraps.
>> Seems like the version in mmotm is still your original patch and
>> Andrew's hotfix?
> 
> Yes, that patch was hopelessly mailer-mangled.  I painstakingly fixed
> it up and generated the incremental:

Thanks a lot. My review of the final patch also involved pain (due to
the cold, not the patch!).

You can take my Acked-by, but I also find the definitions of
set_zone_contiguous/clear_zone_contiguous() "in the header of the
consumer" (hotplug) somewhat unusual. It works, but e.g. mm/internal.h
would be more expected.

Then there's this:

> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -509,6 +509,8 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
>  	int start_sec, end_sec;
>  	struct vmem_altmap *altmap;
>  
> +	clear_zone_contiguous(zone);
> +
>  	/* during initialize mem_map, align hot-added range to section */
>  	start_sec = pfn_to_section_nr(phys_start_pfn);
>  	end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
> @@ -540,6 +542,8 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
>  	}
>  	vmemmap_populate_print_last();
>  
> +	set_zone_contiguous(zone);
> +
>  	return err;
>  }
>  EXPORT_SYMBOL_GPL(__add_pages);

Between the clear and set, __add_pages() might return with -EINVAL,
leaving the flag cleared potentially forever. Not critical, probably
rare, but it should be possible to avoid this by moving the clear below
the altmap check?

Thanks,
Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
