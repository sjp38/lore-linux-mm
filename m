Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 78EA06B02D7
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 07:29:56 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id 98so44053039qkp.22
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 04:29:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 127si3626417qkl.122.2018.11.15.04.29.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 04:29:55 -0800 (PST)
Subject: Re: [PATCH RFC 6/6] PM / Hibernate: exclude all PageOffline() pages
References: <20181114211704.6381-1-david@redhat.com>
 <20181114211704.6381-7-david@redhat.com>
 <20181115122302.GR23831@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <2e94148a-514f-0e18-5103-0e3ae342b3c9@redhat.com>
Date: Thu, 15 Nov 2018 13:29:44 +0100
MIME-Version: 1.0
In-Reply-To: <20181115122302.GR23831@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, "Michael S. Tsirkin" <mst@redhat.com>

On 15.11.18 13:23, Michal Hocko wrote:
> On Wed 14-11-18 22:17:04, David Hildenbrand wrote:
> [...]
>> diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
>> index b0308a2c6000..01db1d13481a 100644
>> --- a/kernel/power/snapshot.c
>> +++ b/kernel/power/snapshot.c
>> @@ -1222,7 +1222,7 @@ static struct page *saveable_highmem_page(struct zone *zone, unsigned long pfn)
>>  	BUG_ON(!PageHighMem(page));
>>  
>>  	if (swsusp_page_is_forbidden(page) ||  swsusp_page_is_free(page) ||
>> -	    PageReserved(page))
>> +	    PageReserved(page) || PageOffline(page))
>>  		return NULL;
>>  
>>  	if (page_is_guard(page))
>> @@ -1286,6 +1286,9 @@ static struct page *saveable_page(struct zone *zone, unsigned long pfn)
>>  	if (swsusp_page_is_forbidden(page) || swsusp_page_is_free(page))
>>  		return NULL;
>>  
>> +	if (PageOffline(page))
>> +		return NULL;
>> +
>>  	if (PageReserved(page)
>>  	    && (!kernel_page_present(page) || pfn_is_nosave(pfn)))
>>  		return NULL;
> 
> Btw. now that you are touching this file could you also make
> s@pfn_to_page@pfn_to_online_page@ please? We really do not want to touch
> offline pfn ranges in general. A separate patch for that of course.
> 
> Thanks!
> 

Sure thing, will look into that!

Thanks!

-- 

Thanks,

David / dhildenb
