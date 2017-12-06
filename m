Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id D9BBD6B0327
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 21:45:11 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id v15so1664726uae.23
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 18:45:11 -0800 (PST)
Received: from huawei.com ([45.249.212.35])
        by mx.google.com with ESMTPS id s39si199722uai.138.2017.12.05.18.45.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 18:45:11 -0800 (PST)
Message-ID: <5A275987.3070001@huawei.com>
Date: Wed, 6 Dec 2017 10:44:23 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [mmotm] mm/page_owner: align with pageblock_nr_pages
References: <1512395284-13588-1-git-send-email-zhongjiang@huawei.com> <20171205165826.aed52f6b6e5ca4cd7994ce31@linux-foundation.org>
In-Reply-To: <20171205165826.aed52f6b6e5ca4cd7994ce31@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mhocko@kernel.org, vbabka@suse.cz, linux-mm@kvack.org

On 2017/12/6 8:58, Andrew Morton wrote:
> On Mon, 4 Dec 2017 21:48:04 +0800 zhong jiang <zhongjiang@huawei.com> wrote:
>
>> Currently, init_pages_in_zone walk the zone in pageblock_nr_pages
>> steps.  MAX_ORDER_NR_PAGES is possible to have holes when
>> CONFIG_HOLES_IN_ZONE is set. it is likely to be different between
>> MAX_ORDER_NR_PAGES and pageblock_nr_pages. if we skip the size of
>> MAX_ORDER_NR_PAGES, it will result in the second 2M memroy leak.
>>
>> meanwhile, the change will make the code consistent. because the
>> entire function is based on the pageblock_nr_pages steps.
>>
>> ...
>>
>> --- a/mm/page_owner.c
>> +++ b/mm/page_owner.c
>> @@ -527,7 +527,7 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
>>  	 */
>>  	for (; pfn < end_pfn; ) {
>>  		if (!pfn_valid(pfn)) {
>> -			pfn = ALIGN(pfn + 1, MAX_ORDER_NR_PAGES);
>> +			pfn = ALIGN(pfn + 1, pageblock_nr_pages);
>>  			continue;
>>  		}
> I *think* Michal and Vlastimil will be OK with this as-newly-presented.
> Guys, can you please have another think?
According to Vlastimil's comment,  it is not simple as it looks to cover all corners.
Maybe  architecture need explicit define the hole granularity to use correctly.
so far,  I have no a good idea to solve it perfectly. 
Anyway. I will go further to find out.

Thanks
zhong jiang


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
