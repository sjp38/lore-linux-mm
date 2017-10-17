Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D50EE6B0069
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 09:03:32 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id n4so785514wrb.8
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 06:03:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m22si1994313wrb.94.2017.10.17.06.03.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Oct 2017 06:03:31 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm, page_alloc: fail has_unmovable_pages when seeing
 reserved pages
References: <20171013115835.zaehapuucuzl2vlv@dhcp22.suse.cz>
 <20171013120013.698-1-mhocko@kernel.org>
 <20171013120013.698-2-mhocko@kernel.org>
 <d98bfc90-e857-4bbe-bfbc-ee69dc310cc0@suse.cz>
 <20171013120756.jeopthigbmm3c7bl@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7d389744-13c9-4f01-106a-902af61643e1@suse.cz>
Date: Tue, 17 Oct 2017 15:03:30 +0200
MIME-Version: 1.0
In-Reply-To: <20171013120756.jeopthigbmm3c7bl@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On 10/13/2017 02:07 PM, Michal Hocko wrote:
> On Fri 13-10-17 14:04:08, Vlastimil Babka wrote:
>> On 10/13/2017 02:00 PM, Michal Hocko wrote:
>>> From: Michal Hocko <mhocko@suse.com>
>>>
>>> Reserved pages should be completely ignored by the core mm because they
>>> have a special meaning for their owners. has_unmovable_pages doesn't
>>> check those so we rely on other tests (reference count, or PageLRU) to
>>> fail on such pages. Althought this happens to work it is safer to simply
>>> check for those explicitly and do not rely on the owner of the page
>>> to abuse those fields for special purposes.
>>>
>>> Please note that this is more of a further fortification of the code
>>> rahter than a fix of an existing issue.
>>>
>>> Signed-off-by: Michal Hocko <mhocko@suse.com>
>>> ---
>>>  mm/page_alloc.c | 3 +++
>>>  1 file changed, 3 insertions(+)
>>>
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index ad0294ab3e4f..a8800b0a5619 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -7365,6 +7365,9 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>>>  
>>>  		page = pfn_to_page(check);
>>>  
>>> +		if (PageReferenced(page))
>>
>> "Referenced" != "Reserved"
> 
> Dohh, you are right of course. I blame auto-completion ;) but I am lame
> in fact...
> ---
> From 44b20bdb03846bc5fd79c883d16b8f3aa436878f Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Fri, 13 Oct 2017 13:55:21 +0200
> Subject: [PATCH] mm, page_alloc: fail has_unmovable_pages when seeing reserved
>  pages
> 
> Reserved pages should be completely ignored by the core mm because they
> have a special meaning for their owners. has_unmovable_pages doesn't
> check those so we rely on other tests (reference count, or PageLRU) to
> fail on such pages. Althought this happens to work it is safer to simply
> check for those explicitly and do not rely on the owner of the page
> to abuse those fields for special purposes.
> 
> Please note that this is more of a further fortification of the code
> rahter than a fix of an existing issue.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/page_alloc.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ad0294ab3e4f..5b4d85ae445c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7365,6 +7365,9 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  
>  		page = pfn_to_page(check);
>  
> +		if (PageReserved(page))
> +			return true;
> +
>  		/*
>  		 * Hugepages are not in LRU lists, but they're movable.
>  		 * We need not scan over tail pages bacause we don't
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
