Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id DDB3F6B05C7
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 05:03:09 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id j9-v6so17828666pfn.20
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 02:03:09 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id p3si3123266pgi.0.2018.11.08.02.03.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 02:03:08 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Thu, 08 Nov 2018 15:33:06 +0530
From: Arun KS <arunks@codeaurora.org>
Subject: Re: [PATCH v3 4/4] mm: Remove managed_page_count spinlock
In-Reply-To: <20181108083400.GQ27423@dhcp22.suse.cz>
References: <1541665398-29925-1-git-send-email-arunks@codeaurora.org>
 <1541665398-29925-5-git-send-email-arunks@codeaurora.org>
 <20181108083400.GQ27423@dhcp22.suse.cz>
Message-ID: <4e5e2923a424ab2e2c50e56b2e538a3c@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, keescook@chromium.org, khlebnikov@yandex-team.ru, minchan@kernel.org, vbabka@suse.cz, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, getarunks@gmail.com

On 2018-11-08 14:04, Michal Hocko wrote:
> On Thu 08-11-18 13:53:18, Arun KS wrote:
>> Now totalram_pages and managed_pages are atomic varibles. No need
>> of managed_page_count spinlock.
> 
> As explained earlier. Please add a motivation here. Feel free to reuse
> wording from 
> http://lkml.kernel.org/r/20181107103630.GF2453@dhcp22.suse.cz

Sure. Will add in next spin.

Regards,
Arun
> 
>> 
>> Signed-off-by: Arun KS <arunks@codeaurora.org>
>> Reviewed-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>> Acked-by: Michal Hocko <mhocko@suse.com>
>> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>> ---
>>  include/linux/mmzone.h | 6 ------
>>  mm/page_alloc.c        | 5 -----
>>  2 files changed, 11 deletions(-)
>> 
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index e73dc31..c71b4d9 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -428,12 +428,6 @@ struct zone {
>>  	 * Write access to present_pages at runtime should be protected by
>>  	 * mem_hotplug_begin/end(). Any reader who can't tolerant drift of
>>  	 * present_pages should get_online_mems() to get a stable value.
>> -	 *
>> -	 * Read access to managed_pages should be safe because it's unsigned
>> -	 * long. Write access to zone->managed_pages and totalram_pages are
>> -	 * protected by managed_page_count_lock at runtime. Idealy only
>> -	 * adjust_managed_page_count() should be used instead of directly
>> -	 * touching zone->managed_pages and totalram_pages.
>>  	 */
>>  	atomic_long_t		managed_pages;
>>  	unsigned long		spanned_pages;
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index f8b64cc..26c5e14 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -122,9 +122,6 @@
>>  };
>>  EXPORT_SYMBOL(node_states);
>> 
>> -/* Protect totalram_pages and zone->managed_pages */
>> -static DEFINE_SPINLOCK(managed_page_count_lock);
>> -
>>  atomic_long_t _totalram_pages __read_mostly;
>>  EXPORT_SYMBOL(_totalram_pages);
>>  unsigned long totalreserve_pages __read_mostly;
>> @@ -7065,14 +7062,12 @@ static int __init 
>> cmdline_parse_movablecore(char *p)
>> 
>>  void adjust_managed_page_count(struct page *page, long count)
>>  {
>> -	spin_lock(&managed_page_count_lock);
>>  	atomic_long_add(count, &page_zone(page)->managed_pages);
>>  	totalram_pages_add(count);
>>  #ifdef CONFIG_HIGHMEM
>>  	if (PageHighMem(page))
>>  		totalhigh_pages_add(count);
>>  #endif
>> -	spin_unlock(&managed_page_count_lock);
>>  }
>>  EXPORT_SYMBOL(adjust_managed_page_count);
>> 
>> --
>> 1.9.1
