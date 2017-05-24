Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 764806B02FD
	for <linux-mm@kvack.org>; Wed, 24 May 2017 06:52:43 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y65so192507368pff.13
        for <linux-mm@kvack.org>; Wed, 24 May 2017 03:52:43 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id s16si24487921plk.213.2017.05.24.03.52.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 May 2017 03:52:42 -0700 (PDT)
Message-ID: <59256545.9010608@huawei.com>
Date: Wed, 24 May 2017 18:49:41 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [Question] Mlocked count will not be decreased
References: <a61701d8-3dce-51a2-5eaf-14de84425640@huawei.com> <85591559-2a99-f46b-7a5a-bc7affb53285@huawei.com> <93f1b063-6288-d109-117d-d3c1cf152a8e@suse.cz>
In-Reply-To: <93f1b063-6288-d109-117d-d3c1cf152a8e@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, Kefeng Wang <wangkefeng.wang@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zhongjiang <zhongjiang@huawei.com>

On 2017/5/24 18:32, Vlastimil Babka wrote:

> On 05/24/2017 10:32 AM, Yisheng Xie wrote:
>> Hi Kefengi 1/4 ?
>> Could you please try this patch.
>>
>> Thanks
>> Yisheng Xie
>> -------------
>> From a70ae975756e8e97a28d49117ab25684da631689 Mon Sep 17 00:00:00 2001
>> From: Yisheng Xie <xieyisheng1@huawei.com>
>> Date: Wed, 24 May 2017 16:01:24 +0800
>> Subject: [PATCH] mlock: fix mlock count can not decrease in race condition
>>
>> Kefeng reported that when run the follow test the mlock count in meminfo
>> cannot be decreased:
>>  [1] testcase
>>  linux:~ # cat test_mlockal
>>  grep Mlocked /proc/meminfo
>>   for j in `seq 0 10`
>>   do
>>  	for i in `seq 4 15`
>>  	do
>>  		./p_mlockall >> log &
>>  	done
>>  	sleep 0.2
>>  done
>>  sleep 5 # wait some time to let mlock decrease
>>  grep Mlocked /proc/meminfo
>>
>>  linux:~ # cat p_mlockall.c
>>  #include <sys/mman.h>
>>  #include <stdlib.h>
>>  #include <stdio.h>
>>
>>  #define SPACE_LEN	4096
>>
>>  int main(int argc, char ** argv)
>>  {
>>  	int ret;
>>  	void *adr = malloc(SPACE_LEN);
>>  	if (!adr)
>>  		return -1;
>>
>>  	ret = mlockall(MCL_CURRENT | MCL_FUTURE);
>>  	printf("mlcokall ret = %d\n", ret);
>>
>>  	ret = munlockall();
>>  	printf("munlcokall ret = %d\n", ret);
>>
>>  	free(adr);
>>  	return 0;
>>  }
>>
>> When __munlock_pagevec, we ClearPageMlock but isolation_failed in race
>> condition, and we do not count these page into delta_munlocked, which cause mlock
> 
> Race condition with what? Who else would isolate our pages?
> 
>> counter incorrect for we had Clear the PageMlock and cannot count down
>> the number in the feture.
>>
>> Fix it by count the number of page whoes PageMlock flag is cleared.
>>
>> Reported-by: Kefeng Wang <wangkefeng.wang@huawei.com>
>> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> 
> Weird, I can reproduce the issue on my desktop's 4.11 distro kernel, but
> not in qemu and small kernel build, for some reason. So I couldn't test
> the patch yet. But it's true that before 7225522bb429 ("mm: munlock:
> batch non-THP page isolation and munlock+putback using pagevec") we
> decreased NR_MLOCK for each pages that passed TestClearPageMlocked(),
> and that unintentionally changed with my patch. There should be a Fixes:
> tag for that.
> 

Hi Vlastimil,

Why the page has marked Mlocked, but not in lru list?

		if (TestClearPageMlocked(page)) {
			/*
			 * We already have pin from follow_page_mask()
			 * so we can spare the get_page() here.
			 */
			if (__munlock_isolate_lru_page(page, false))
				continue;
			else
				__munlock_isolation_failed(page);  // How this happened?
		}

Thanks,
Xishi Qiu

>> ---
>>  mm/mlock.c | 7 ++++---
>>  1 file changed, 4 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/mlock.c b/mm/mlock.c
>> index c483c5c..71ba5cf 100644
>> --- a/mm/mlock.c
>> +++ b/mm/mlock.c
>> @@ -284,7 +284,7 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
>>  {
>>  	int i;
>>  	int nr = pagevec_count(pvec);
>> -	int delta_munlocked;
>> +	int munlocked = 0;
>>  	struct pagevec pvec_putback;
>>  	int pgrescued = 0;
>>
>> @@ -296,6 +296,7 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
>>  		struct page *page = pvec->pages[i];
>>
>>  		if (TestClearPageMlocked(page)) {
>> +			munlocked --;
>>  			/*
>>  			 * We already have pin from follow_page_mask()
>>  			 * so we can spare the get_page() here.
>> @@ -315,8 +316,8 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
>>  		pagevec_add(&pvec_putback, pvec->pages[i]);
>>  		pvec->pages[i] = NULL;
>>  	}
>> -	delta_munlocked = -nr + pagevec_count(&pvec_putback);
>> -	__mod_zone_page_state(zone, NR_MLOCK, delta_munlocked);
>> +	if (munlocked)
> 
> You don't have to if () this, it should be very rare that munlocked will
> be 0, and the code works fine even if it is.
> 
>> +		__mod_zone_page_state(zone, NR_MLOCK, munlocked);
>>  	spin_unlock_irq(zone_lru_lock(zone));
>>
>>  	/* Now we can release pins of pages that we are not munlocking */
>>
> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
