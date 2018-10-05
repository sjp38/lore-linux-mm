Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 581486B026B
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 03:24:48 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id f59-v6so7231630plb.5
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 00:24:48 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id s13-v6si7267664pgo.505.2018.10.05.00.24.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Oct 2018 00:24:47 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Fri, 05 Oct 2018 12:54:45 +0530
From: Arun KS <arunks@codeaurora.org>
Subject: Re: [PATCH v4] memory_hotplug: Free pages as higher order
In-Reply-To: <20181004145108.GH22173@dhcp22.suse.cz>
References: <1538573979-28365-1-git-send-email-arunks@codeaurora.org>
 <20181004145108.GH22173@dhcp22.suse.cz>
Message-ID: <9ed0de45f2d7257c56e39efe43606d27@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com, boris.ostrovsky@oracle.com, jgross@suse.com, akpm@linux-foundation.org, dan.j.williams@intel.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, gregkh@linuxfoundation.org, osalvador@suse.de, malat@debian.org, kirill.shutemov@linux.intel.com, jrdr.linux@gmail.com, yasu.isimatu@gmail.com, mgorman@techsingularity.net, aaron.lu@intel.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, vatsa@codeaurora.org, vinmenon@codeaurora.org, getarunks@gmail.com

On 2018-10-04 20:21, Michal Hocko wrote:
> On Wed 03-10-18 19:09:39, Arun KS wrote:
> [...]
>> +static int online_pages_blocks(unsigned long start, unsigned long 
>> nr_pages)
>> +{
>> +	unsigned long end = start + nr_pages;
>> +	int order, ret, onlined_pages = 0;
>> +
>> +	while (start < end) {
>> +		order = min(MAX_ORDER - 1UL, __ffs(start));
>> +
>> +		while (start + (1UL << order) > end)
>> +			order--;
> 
> this really made me scratch my head. Wouldn't it be much simpler to do
> the following?
> 		order = min(MAX_ORDER - 1, get_order(end - start))?

Yes. Much better. Will change to,

                 order = min(MAX_ORDER - 1,
                         get_order(PFN_PHYS(end) - PFN_PHYS(start)));

> 
>> +
>> +		ret = (*online_page_callback)(pfn_to_page(start), order);
>> +		if (!ret)
>> +			onlined_pages += (1UL << order);
>> +		else if (ret > 0)
>> +			onlined_pages += ret;
>> +
>> +		start += (1UL << order);
>> +	}
>> +	return onlined_pages;
>>  }
> [...]
>> -static void __init __free_pages_boot_core(struct page *page, unsigned 
>> int order)
>> +void __free_pages_core(struct page *page, unsigned int order)
>>  {
>>  	unsigned int nr_pages = 1 << order;
>>  	struct page *p = page;
>>  	unsigned int loop;
>> 
>> -	prefetchw(p);
>> -	for (loop = 0; loop < (nr_pages - 1); loop++, p++) {
>> -		prefetchw(p + 1);
>> +	for (loop = 0; loop < nr_pages; loop++, p++) {
>>  		__ClearPageReserved(p);
>>  		set_page_count(p, 0);
>>  	}
>> -	__ClearPageReserved(p);
>> -	set_page_count(p, 0);
>> 
>>  	page_zone(page)->managed_pages += nr_pages;
>>  	set_page_refcounted(page);
> 
> I think this is wort a separate patch as it is unrelated to the patch.
Sure. Will split the patch.

Regards,
Arun
