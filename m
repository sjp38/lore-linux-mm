Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5B4076B0279
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 08:00:07 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g46so7430103wrd.3
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 05:00:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p91si2035920wrc.257.2017.07.07.05.00.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 07 Jul 2017 05:00:05 -0700 (PDT)
Subject: Re: "mm: use early_pfn_to_nid in page_ext_init" broken on some
 configurations?
References: <20170630141847.GN22917@dhcp22.suse.cz>
 <54336b9a-6dc7-890f-1900-c4188fb6cf1a@suse.cz>
 <20170704051713.GB28589@js1304-desktop>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <31ca76ee-fd1a-236b-2b9d-fa205202c1ac@suse.cz>
Date: Fri, 7 Jul 2017 14:00:03 +0200
MIME-Version: 1.0
In-Reply-To: <20170704051713.GB28589@js1304-desktop>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, Yang Shi <yang.shi@linaro.org>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 07/04/2017 07:17 AM, Joonsoo Kim wrote:
>> 
>> Still, backporting b8f1a75d61d8 fixes this:
>> 
>> [    1.538379] allocated 738197504 bytes of page_ext
>> [    1.539340] Node 0, zone      DMA: page owner found early allocated 0 pages
>> [    1.540179] Node 0, zone    DMA32: page owner found early allocated 33 pages
>> [    1.611173] Node 0, zone   Normal: page owner found early allocated 96755 pages
>> [    1.683167] Node 1, zone   Normal: page owner found early allocated 96575 pages
>> 
>> No panic, notice how it allocated more for page_ext, and found smaller number of
>> early allocated pages.
>> 
>> Now backporting fe53ca54270a on top:
>> 
>> [    0.000000] allocated 738197504 bytes of page_ext
>> [    0.000000] Node 0, zone      DMA: page owner found early allocated 0 pages
>> [    0.000000] Node 0, zone    DMA32: page owner found early allocated 33 pages
>> [    0.000000] Node 0, zone   Normal: page owner found early allocated 2842622 pages
>> [    0.000000] Node 1, zone   Normal: page owner found early allocated 3694362 pages
>> 
>> Again no panic, and same amount of page_ext usage. But the "early allocated" numbers
>> seem bogus to me. I think it's because init_pages_in_zone() is running and inspecting
>> struct pages that have not been yet initialized. It doesn't end up crashing, but
>> still doesn't seem correct?
> 
> Numbers looks sane to me. fe53ca54270a makes init_pages_in_zone()
> called before page_alloc_init_late(). So, there would be many
> uninitialized pages with PageReserved(). Page owner regarded these
> PageReserved() page as allocated page.

That seems incorrect for two reasons:
- init_pages_in_zone() actually skips PageReserved() pages
- the pages don't have PageReserved() flag, until the deferred struct page init
thread processes them via deferred_init_memmap() -> __init_single_page() AFAICS

Now I've found out why upstream reports much less early allocated pages than our
kernel. We're missing 9d43f5aec950 ("mm/page_owner: add zone range overlapping
check") which adds a "page_zone(page) != zone" check. I think this only works
because the pages are not initialized and thus have no nid/zone links. Probably
page_zone() only doesn't break because it's all zeroed. I don't think it's safe
to rely on this?

> We can change the message to "page owner found early reserved N pages"
> 
> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
