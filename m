Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 296BD6B0003
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 12:56:44 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id b27-v6so5189181pfm.15
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 09:56:44 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id n12-v6si20209183pgl.136.2018.10.10.09.56.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 09:56:42 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Wed, 10 Oct 2018 22:26:41 +0530
From: Arun KS <arunks@codeaurora.org>
Subject: Re: [PATCH v5 1/2] memory_hotplug: Free pages as higher order
In-Reply-To: <72215e75-6c7e-0aef-c06e-e3aba47cf806@suse.cz>
References: <1538727006-5727-1-git-send-email-arunks@codeaurora.org>
 <72215e75-6c7e-0aef-c06e-e3aba47cf806@suse.cz>
Message-ID: <efb65160af41d0e18cb2dcb30c2fb86a@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com, boris.ostrovsky@oracle.com, jgross@suse.com, akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com, iamjoonsoo.kim@lge.com, gregkh@linuxfoundation.org, osalvador@suse.de, malat@debian.org, kirill.shutemov@linux.intel.com, jrdr.linux@gmail.com, yasu.isimatu@gmail.com, mgorman@techsingularity.net, aaron.lu@intel.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, vatsa@codeaurora.org, vinmenon@codeaurora.org, getarunks@gmail.com

On 2018-10-10 21:00, Vlastimil Babka wrote:
> On 10/5/18 10:10 AM, Arun KS wrote:
>> When free pages are done with higher order, time spend on
>> coalescing pages by buddy allocator can be reduced. With
>> section size of 256MB, hot add latency of a single section
>> shows improvement from 50-60 ms to less than 1 ms, hence
>> improving the hot add latency by 60%. Modify external
>> providers of online callback to align with the change.
>> 
>> Signed-off-by: Arun KS <arunks@codeaurora.org>
> 
> [...]
> 
>> @@ -655,26 +655,44 @@ void __online_page_free(struct page *page)
>>  }
>>  EXPORT_SYMBOL_GPL(__online_page_free);
>> 
>> -static void generic_online_page(struct page *page)
>> +static int generic_online_page(struct page *page, unsigned int order)
>>  {
>> -	__online_page_set_limits(page);
> 
> This is now not called anymore, although the xen/hv variants still do
> it. The function seems empty these days, maybe remove it as a followup
> cleanup?
> 
>> -	__online_page_increment_counters(page);
>> -	__online_page_free(page);
>> +	__free_pages_core(page, order);
>> +	totalram_pages += (1UL << order);
>> +#ifdef CONFIG_HIGHMEM
>> +	if (PageHighMem(page))
>> +		totalhigh_pages += (1UL << order);
>> +#endif
> 
> __online_page_increment_counters() would have used
> adjust_managed_page_count() which would do the changes under
> managed_page_count_lock. Are we safe without the lock? If yes, there
> should perhaps be a comment explaining why.

Looks unsafe without managed_page_count_lock. I think better have a 
similar implementation of free_boot_core() in memory_hotplug.c like we 
had in version 1 of patch. And use adjust_managed_page_count() instead 
of page_zone(page)->managed_pages += nr_pages;

https://lore.kernel.org/patchwork/patch/989445/

-static void generic_online_page(struct page *page)
+static int generic_online_page(struct page *page, unsigned int order)
  {
-	__online_page_set_limits(page);
-	__online_page_increment_counters(page);
-	__online_page_free(page);
+	unsigned long nr_pages = 1 << order;
+	struct page *p = page;
+
+	for (loop = 0 ; loop < nr_pages ; loop++, p++) {
+		__ClearPageReserved(p);
+		set_page_count(p, 0);
+	}
+
+	adjust_managed_page_count(page, nr_pages);
+	set_page_refcounted(page);
+	__free_pages(page, order);
+
+	return 0;
+}


Regards,
Arun
