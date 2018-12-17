Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8843B8E0033
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 10:34:51 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x15so9121132edd.2
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 07:34:51 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Mon, 17 Dec 2018 16:34:48 +0100
From: osalvador@suse.de
Subject: Re: [PATCH] mm, page_alloc: Fix has_unmovable_pages for HugePages
In-Reply-To: <20181217152936.GR30879@dhcp22.suse.cz>
References: <20181217150651.16176-1-osalvador@suse.de>
 <20181217152936.GR30879@dhcp22.suse.cz>
Message-ID: <a4cf58c096f2f521e2b53745621c4562@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, rppt@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, owner-linux-mm@kvack.org

On 2018-12-17 16:29, Michal Hocko wrote:
> On Mon 17-12-18 16:06:51, Oscar Salvador wrote:
> [...]
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index a6e7bfd18cde..18d41e85f672 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -8038,11 +8038,12 @@ bool has_unmovable_pages(struct zone *zone, 
>> struct page *page, int count,
>>  		 * handle each tail page individually in migration.
>>  		 */
>>  		if (PageHuge(page)) {
>> +			struct page *head = compound_head(page);
>> 
>> -			if (!hugepage_migration_supported(page_hstate(page)))
>> +			if (!hugepage_migration_supported(page_hstate(head)))
>>  				goto unmovable;
> 
> OK, this makes sense.
> 
>> 
>> -			iter = round_up(iter + 1, 1<<compound_order(page)) - 1;
>> +			iter = round_up(iter + 1, 1<<compound_order(head)) - 1;
> 
> but this less so. You surely do not want to move by the full hugetlb
> page when you got a tail page, right? You could skip too much. You have
> to consider page - head into the equation.

Argh, you're quite right.
I will amend it in the next version.
