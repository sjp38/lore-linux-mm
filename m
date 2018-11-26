Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 616206B40E9
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 02:41:52 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i55so8793846ede.14
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 23:41:52 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j9si388171edt.202.2018.11.25.23.41.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Nov 2018 23:41:51 -0800 (PST)
Subject: Re: [PATCH] mm: do not consider SWAP to calculate available when not
 necessary
References: <1543190303-8121-1-git-send-email-yang.yang29@zte.com.cn>
 <20181126020115.GF3065@bombadil.infradead.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <fe5e1615-00ac-2962-3db9-4c385e239d9d@suse.cz>
Date: Mon, 26 Nov 2018 08:41:49 +0100
MIME-Version: 1.0
In-Reply-To: <20181126020115.GF3065@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Yang Yang <yang.yang29@zte.com.cn>
Cc: akpm@linux-foundation.org, mhocko@suse.com, pavel.tatashin@microsoft.com, osalvador@suse.de, rppt@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, alexander.h.duyck@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zhong.weidong@zte.com.cn, wang.yi59@zte.com.cn

On 11/26/18 3:01 AM, Matthew Wilcox wrote:
> On Mon, Nov 26, 2018 at 07:58:23AM +0800, Yang Yang wrote:
>> When si_mem_available() calculates 'available', it takes SWAP
>> into account. But if CONFIG_SWAP is N or SWAP is off(some embedded system
>> would like to do that), there is no need to consider it.
> 
> I don't understand this patch.  The pagecache can be written back to
> storage if it is dirty, regardless of whether there is swap space.
> 
>> @@ -4724,9 +4726,13 @@ long si_mem_available(void)
>>  	 * Not all the page cache can be freed, otherwise the system will
>>  	 * start swapping. Assume at least half of the page cache, or the

I guess the first sentence in the comment above might be misleading by
using the word 'swapping', where 'thrashing' would be more accurate and
unambiguous.

So this is not related to the swap, but to the assumption that somebody
is accessing the pages in pagecache, and if too much would be freed,
most accesses would mean reading data from disk, i.e. thrashing.

>>  	 * low watermark worth of cache, needs to stay.
>> +	 * But if CONFIG_SWAP is N or SWAP is off, do not consider it.
>>  	 */
>>  	pagecache = pages[LRU_ACTIVE_FILE] + pages[LRU_INACTIVE_FILE];
>> -	pagecache -= min(pagecache / 2, wmark_low);
>> +#ifdef CONFIG_SWAP
>> +	if (i.totalswap > 0)
>> +		pagecache -= min(pagecache / 2, wmark_low);
>> +#endif
>>  	available += pagecache;
>>  
>>  	/*
>> -- 
>> 2.15.2
>>
