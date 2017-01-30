Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 65F336B0260
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 10:04:23 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id l126so54186562qkc.1
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 07:04:23 -0800 (PST)
Received: from smtpbgbr2.qq.com (smtpbgbr2.qq.com. [54.207.22.56])
        by mx.google.com with ESMTPS id g8si9703970qtc.212.2017.01.30.07.04.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Jan 2017 07:04:22 -0800 (PST)
Subject: Re: [PATCH v4 2/2] HWPOISON: soft offlining for non-lru movable page
References: <1485356738-4831-1-git-send-email-ysxie@foxmail.com>
 <1485356738-4831-3-git-send-email-ysxie@foxmail.com>
 <20170126092725.GD6590@dhcp22.suse.cz>
From: Yisheng Xie <ysxie@foxmail.com>
Message-ID: <588F55ED.3010509@foxmail.com>
Date: Mon, 30 Jan 2017 23:04:13 +0800
MIME-Version: 1.0
In-Reply-To: <20170126092725.GD6590@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, guohanjun@huawei.com, qiuxishi@huawei.com

Hi, Michal,
Sorry for late reply.

On 01/26/2017 05:27 PM, Michal Hocko wrote:
> On Wed 25-01-17 23:05:38, ysxie@foxmail.com wrote:
>> From: Yisheng Xie <xieyisheng1@huawei.com>
>>
>> This patch is to extends soft offlining framework to support
>> non-lru page, which already support migration after
>> commit bda807d44454 ("mm: migrate: support non-lru movable page
>> migration")
>>
>> When memory corrected errors occur on a non-lru movable page,
>> we can choose to stop using it by migrating data onto another
>> page and disable the original (maybe half-broken) one.
>>
>> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
>> Suggested-by: Michal Hocko <mhocko@kernel.org>
>> Suggested-by: Minchan Kim <minchan@kernel.org>
>> Reviewed-by: Minchan Kim <minchan@kernel.org>
>> Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> CC: Vlastimil Babka <vbabka@suse.cz>
>> ---
>>  mm/memory-failure.c | 26 ++++++++++++++++----------
>>  1 file changed, 16 insertions(+), 10 deletions(-)
>>
>> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>> index f283c7e..56e39f8 100644
>> --- a/mm/memory-failure.c
>> +++ b/mm/memory-failure.c
>> @@ -1527,7 +1527,8 @@ static int get_any_page(struct page *page, unsigned long pfn, int flags)
>>  {
>>  	int ret = __get_any_page(page, pfn, flags);
>>  
>> -	if (ret == 1 && !PageHuge(page) && !PageLRU(page)) {
>> +	if (ret == 1 && !PageHuge(page) &&
>> +	    !PageLRU(page) && !__PageMovable(page)) {
>>  		/*
>>  		 * Try to free it.
>>  		 */
> Is this sufficient? Not that I am familiar with get_any_page() but
> __get_any_page doesn't seem to be aware of movable pages and neither
> shake_page is.
Sorry,maybe I do not quite get what you mean.
 If the page can be migrated, it can skip "shake_page and __get_any_page once more" here,
though it is not a free page. right ?
Please let me know if I miss anything.

>> @@ -1649,7 +1650,10 @@ static int __soft_offline_page(struct page *page, int flags)
>>  	 * Try to migrate to a new page instead. migrate.c
>>  	 * handles a large number of cases for us.
>>  	 */
>> -	ret = isolate_lru_page(page);
>> +	if (PageLRU(page))
>> +		ret = isolate_lru_page(page);
>> +	else if (!isolate_movable_page(page, ISOLATE_UNEVICTABLE))
>> +		ret = -EBUSY;
> As pointed out in the previous response isolate_movable_page should
> really have the same return value contract as [__]isolate_lru_page
Yes, I agree with your suggestion. I will rewrite it in later patch if it is suitable.
as I mention before.

Thanks again for your reviewing.

Yisheng Xie
>>  	/*
>>  	 * Drop page reference which is came from get_any_page()
>>  	 * successful isolate_lru_page() already took another one.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
