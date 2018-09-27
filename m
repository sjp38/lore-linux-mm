Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D61DE8E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 04:11:47 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id a4-v6so1896209pfi.16
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 01:11:47 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id g20-v6si1368847pgb.239.2018.09.27.01.11.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Sep 2018 01:11:46 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Thu, 27 Sep 2018 13:41:45 +0530
From: Arun KS <arunks@codeaurora.org>
Subject: Re: [PATCH v3] memory_hotplug: Free pages as higher order
In-Reply-To: <36488c0e-6bae-e277-2cdb-32d0dcc40065@suse.com>
References: <1538031530-25489-1-git-send-email-arunks@codeaurora.org>
 <36488c0e-6bae-e277-2cdb-32d0dcc40065@suse.com>
Message-ID: <21949851c3b2c82853588101f39f1207@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com, boris.ostrovsky@oracle.com, akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, gregkh@linuxfoundation.org, osalvador@suse.de, malat@debian.org, kirill.shutemov@linux.intel.com, jrdr.linux@gmail.com, yasu.isimatu@gmail.com, mgorman@techsingularity.net, aaron.lu@intel.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org, vatsa@codeaurora.org, vinmenon@codeaurora.org, getarunks@gmail.com

On 2018-09-27 12:41, Juergen Gross wrote:
> On 27/09/18 08:58, Arun KS wrote:
>> When free pages are done with higher order, time spend on
>> coalescing pages by buddy allocator can be reduced. With
>> section size of 256MB, hot add latency of a single section
>> shows improvement from 50-60 ms to less than 1 ms, hence
>> improving the hot add latency by 60%.
>> 
>> Modify external providers of online callback to align with
>> the change.
>> 
>> Signed-off-by: Arun KS <arunks@codeaurora.org>
>> ---
>> Changes since v2:
>> reuse code from __free_pages_boot_core()
>> 
>> Changes since v1:
>> - Removed prefetch()
>> 
>> Changes since RFC:
>> - Rebase.
>> - As suggested by Michal Hocko remove pages_per_block.
>> - Modifed external providers of online_page_callback.
>> 
>> v2: https://lore.kernel.org/patchwork/patch/991363/
>> v1: https://lore.kernel.org/patchwork/patch/989445/
>> RFC: https://lore.kernel.org/patchwork/patch/984754/
>> 
>> ---
>>  drivers/hv/hv_balloon.c        |  6 ++++--
>>  drivers/xen/balloon.c          | 18 ++++++++++++++---
>>  include/linux/memory_hotplug.h |  2 +-
>>  mm/internal.h                  |  1 +
>>  mm/memory_hotplug.c            | 44 
>> ++++++++++++++++++++++++++++++------------
>>  mm/page_alloc.c                |  2 +-
>>  6 files changed, 54 insertions(+), 19 deletions(-)
>> 
> 
> ...
> 
>> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
>> index e12bb25..010cf4d 100644
>> --- a/drivers/xen/balloon.c
>> +++ b/drivers/xen/balloon.c
>> @@ -390,8 +390,8 @@ static enum bp_state 
>> reserve_additional_memory(void)
>> 
>>  	/*
>>  	 * add_memory_resource() will call online_pages() which in its turn
>> -	 * will call xen_online_page() callback causing deadlock if we don't
>> -	 * release balloon_mutex here. Unlocking here is safe because the
>> +	 * will call xen_bring_pgs_online() callback causing deadlock if we
>> +	 * don't release balloon_mutex here. Unlocking here is safe because 
>> the
>>  	 * callers drop the mutex before trying again.
>>  	 */
>>  	mutex_unlock(&balloon_mutex);
>> @@ -422,6 +422,18 @@ static void xen_online_page(struct page *page)
>>  	mutex_unlock(&balloon_mutex);
>>  }
>> 
>> +static int xen_bring_pgs_online(struct page *pg, unsigned int order)
>> +{
>> +	unsigned long i, size = (1 << order);
>> +	unsigned long start_pfn = page_to_pfn(pg);
>> +
>> +	pr_debug("Online %lu pages starting at pfn 0x%lx\n", size, 
>> start_pfn);
>> +	for (i = 0; i < size; i++)
>> +		xen_online_page(pfn_to_page(start_pfn + i));
> 

Hi,

> xen_online_page() isn't very complex and this is the only user.
> 
> Why don't you move its body in here and drop the extra function?
> And now you can execute the loop with balloon_mutex held instead of
> taking and releasing it in each iteration of the loop.
Point taken. Will incorporate them.

Regards,
Arun
> 
> 
> Juergen
