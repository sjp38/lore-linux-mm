Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E9E146B0279
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 00:58:47 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id e1so1107731pga.5
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 21:58:47 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id u25si670623pfa.375.2017.06.06.21.58.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Jun 2017 21:58:47 -0700 (PDT)
Message-ID: <59378799.1050000@huawei.com>
Date: Wed, 7 Jun 2017 12:56:57 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Revert "mm: vmpressure: fix sending wrong events on underflow"
References: <1496804917-7628-1-git-send-email-zhongjiang@huawei.com> <20170607035540.GA5687@bbox>
In-Reply-To: <20170607035540.GA5687@bbox>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: akpm@linux-foundation.org, vinayakm.list@gmail.com, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2017/6/7 11:55, Minchan Kim wrote:
> On Wed, Jun 07, 2017 at 11:08:37AM +0800, zhongjiang wrote:
>> This reverts commit e1587a4945408faa58d0485002c110eb2454740c.
>>
>> THP lru page is reclaimed , THP is split to normal page and loop again.
>> reclaimed pages should not be bigger than nr_scan.  because of each
>> loop will increase nr_scan counter.
> Unfortunately, there is still underflow issue caused by slab pages as
> Vinayak reported in description of e1587a4945408 so we cannot revert.
> Please correct comment instead of removing the logic.
>
> Thanks.
  we calculate the vmpressue based on the Lru page, exclude the slab pages by previous
  discussion.    is it not this?

  Thanks
 zhongjiang
>> Signed-off-by: zhongjiang <zhongjiang@huawei.com>
>> ---
>>  mm/vmpressure.c | 10 +---------
>>  1 file changed, 1 insertion(+), 9 deletions(-)
>>
>> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
>> index 6063581..149fdf6 100644
>> --- a/mm/vmpressure.c
>> +++ b/mm/vmpressure.c
>> @@ -112,16 +112,9 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
>>  						    unsigned long reclaimed)
>>  {
>>  	unsigned long scale = scanned + reclaimed;
>> -	unsigned long pressure = 0;
>> +	unsigned long pressure;
>>  
>>  	/*
>> -	 * reclaimed can be greater than scanned in cases
>> -	 * like THP, where the scanned is 1 and reclaimed
>> -	 * could be 512
>> -	 */
>> -	if (reclaimed >= scanned)
>> -		goto out;
>> -	/*
>>  	 * We calculate the ratio (in percents) of how many pages were
>>  	 * scanned vs. reclaimed in a given time frame (window). Note that
>>  	 * time is in VM reclaimer's "ticks", i.e. number of pages
>> @@ -131,7 +124,6 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
>>  	pressure = scale - (reclaimed * scale / scanned);
>>  	pressure = pressure * 100 / scale;
>>  
>> -out:
>>  	pr_debug("%s: %3lu  (s: %lu  r: %lu)\n", __func__, pressure,
>>  		 scanned, reclaimed);
>>  
>> -- 
>> 1.7.12.4
>>
> .
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
