Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1D4676B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 07:45:38 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id v96so150691400ioi.5
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 04:45:38 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id w13si13696347iow.157.2017.01.23.04.45.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Jan 2017 04:45:37 -0800 (PST)
Subject: Re: [RFC v2] HWPOISON: soft offlining for non-lru movable page
References: <1484837943-21745-1-git-send-email-ysxie@foxmail.com>
 <20170123051459.GB11763@bbox>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <f658e1ed-081b-c5e5-8997-8b750c1c14ea@huawei.com>
Date: Mon, 23 Jan 2017 20:39:59 +0800
MIME-Version: 1.0
In-Reply-To: <20170123051459.GB11763@bbox>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, ysxie@foxmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, n-horiguchi@ah.jp.nec.com, mhocko@suse.com, akpm@linux-foundation.org, vbabka@suse.cz, guohanjun@huawei.com, qiuxishi@huawei.com

Hi Minchan,
Thanks for reviewing.
On 2017/1/23 13:14, Minchan Kim wrote:
> Hello,
> 
> On Thu, Jan 19, 2017 at 10:59:03PM +0800, ysxie@foxmail.com wrote:
>> From: Yisheng Xie <xieyisheng1@huawei.com>
>>
>> @@ -1527,7 +1527,8 @@ static int get_any_page(struct page *page, unsigned long pfn, int flags)
>>  {
>>  	int ret = __get_any_page(page, pfn, flags);
>>  
>> -	if (ret == 1 && !PageHuge(page) && !PageLRU(page)) {
>> +	if (ret == 1 && !PageHuge(page) &&
>> +	    !PageLRU(page) && !__PageMovable(page)) {
> 
> __PageMovable without holding page_lock could be raced so need to check
> if it's okay to miss some of pages offlining by the race.
> When I read description of soft_offline_page, it seems to be okay.
> Just wanted double check. :)
Yes, I have thought about whether should add page_lock to avoid race. For it is ok to
miss some of pages caused by race, I do not add page_lock.

> 
>>  		/*
>>  		 * Try to free it.
>>  		 */
>> @@ -1609,7 +1610,7 @@ static int soft_offline_huge_page(struct page *page, int flags)
>>  
>>  static int __soft_offline_page(struct page *page, int flags)
>>  {
>> -	int ret;
>> +	int ret = -1;
>>  	unsigned long pfn = page_to_pfn(page);
>>  
>>  	/*
>> @@ -1619,7 +1620,8 @@ static int __soft_offline_page(struct page *page, int flags)
>>  	 * so there's no race between soft_offline_page() and memory_failure().
>>  	 */
>>  	lock_page(page);
>> -	wait_on_page_writeback(page);
>> +	if (PageLRU(page))
>> +		wait_on_page_writeback(page);
> 
> I doubt we need to add such limitation(i.e., Only LRU pages could be write-backed).
> Do you have some reason to add that code?

I add this check for not quite sure about whether non-lru page will as marked as
PageWriteBack(page). I will delete no need limitation in next version.

> 
>>  	if (PageHWPoison(page)) {
>>  		unlock_page(page);
>>  		put_hwpoison_page(page);
>> @@ -1630,7 +1632,8 @@ static int __soft_offline_page(struct page *page, int flags)
>>  	 * Try to invalidate first. This should work for
>>  	 * non dirty unmapped page cache pages.
>>  	 */
>> -	ret = invalidate_inode_page(page);
>> +	if (PageLRU(page))
>> +		ret = invalidate_inode_page(page);
> 
> Ditto.
> 
>>  	unlock_page(page);
>>  	/*
>>  	 * RED-PEN would be better to keep it isolated here, but we
>> @@ -1649,7 +1652,10 @@ static int __soft_offline_page(struct page *page, int flags)
>>  	 * Try to migrate to a new page instead. migrate.c
>>  	 * handles a large number of cases for us.
>>  	 */
>> -	ret = isolate_lru_page(page);
>> +	if (PageLRU(page))
>> +		ret = isolate_lru_page(page);
>> +	else
>> +		ret = !isolate_movable_page(page, ISOLATE_UNEVICTABLE);
>>  	/*
>>  	 * Drop page reference which is came from get_any_page()
>>  	 * successful isolate_lru_page() already took another one.
>> @@ -1657,18 +1663,15 @@ static int __soft_offline_page(struct page *page, int flags)
>>  	put_hwpoison_page(page);
>>  	if (!ret) {
>>  		LIST_HEAD(pagelist);
>> -		inc_node_page_state(page, NR_ISOLATED_ANON +
>> +		if (PageLRU(page))
> 
> isolate_lru_page removes PG_lru so this check will be false. Namely, happens
> isolated count mismatch happens.
> 
Really sorry about that. That's my mistake.
I will use !__PageMovable(page) instead in v3.

Thanks
Yisheng Xie.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
