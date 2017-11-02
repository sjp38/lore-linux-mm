Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D4B9F6B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 09:40:07 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id z77so2960934wmc.16
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 06:40:07 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id d47si3302780ede.45.2017.11.02.06.40.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 06:40:06 -0700 (PDT)
Subject: Re: [PATCH v1 1/1] mm: buddy page accessed before initialized
References: <20171031155002.21691-1-pasha.tatashin@oracle.com>
 <20171031155002.21691-2-pasha.tatashin@oracle.com>
 <20171102133235.2vfmmut6w4of2y3j@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Message-ID: <a9b637b0-2ff0-80e8-76a7-801c5c0820a8@oracle.com>
Date: Thu, 2 Nov 2017 09:39:58 -0400
MIME-Version: 1.0
In-Reply-To: <20171102133235.2vfmmut6w4of2y3j@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/02/2017 09:32 AM, Michal Hocko wrote:
> On Tue 31-10-17 11:50:02, Pavel Tatashin wrote:
> [...]
>> The problem happens in this path:
>>
>> page_alloc_init_late
>>    deferred_init_memmap
>>      deferred_init_range
>>        __def_free
>>          deferred_free_range
>>            __free_pages_boot_core(page, order)
>>              __free_pages()
>>                __free_pages_ok()
>>                  free_one_page()
>>                    __free_one_page(page, pfn, zone, order, migratetype);
>>
>> deferred_init_range() initializes one page at a time by calling
>> __init_single_page(), once it initializes pageblock_nr_pages pages, it
>> calls deferred_free_range() to free the initialized pages to the buddy
>> allocator. Eventually, we reach __free_one_page(), where we compute buddy
>> page:
>> 	buddy_pfn = __find_buddy_pfn(pfn, order);
>> 	buddy = page + (buddy_pfn - pfn);
>>
>> buddy_pfn is computed as pfn ^ (1 << order), or pfn + pageblock_nr_pages.
>> Thefore, buddy page becomes a page one after the range that currently was
>> initialized, and we access this page in this function. Also, later when we
>> return back to deferred_init_range(), the buddy page is initialized again.
>>
>> So, in order to avoid this issue, we must initialize the buddy page prior
>> to calling deferred_free_range().
> 
> How come we didn't have this problem previously? I am really confused.
> 

Hi Michal,

Previously as before my project? That is because memory for all struct 
pages was always zeroed in memblock, and in __free_one_page() 
page_is_buddy() was always returning false, thus we never tried to 
incorrectly remove it from the list:

837			list_del(&buddy->lru);

Now, that memory is not zeroed, page_is_buddy() can return true after 
kexec when memory is dirty (unfortunately memset(1) with CONFIG_VM_DEBUG 
does not catch this case). And proceed further to incorrectly remove 
buddy from the list.

This is why we must initialize the computed buddy page beforehand.

Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
