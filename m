Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2A2ED6B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:49:13 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p6so25410349lfp.5
        for <linux-mm@kvack.org>; Wed, 24 May 2017 04:49:13 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id a68si11589656lfe.177.2017.05.24.04.49.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 May 2017 04:49:11 -0700 (PDT)
Message-ID: <5925709F.1030105@huawei.com>
Date: Wed, 24 May 2017 19:38:07 +0800
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

Hi Vlastimil,

I find the root cause, if the page was not cached on the current cpu,
lru_add_drain() will not push it to LRU. So we should handle fail
case in mlock_vma_page().

follow_page_pte()
		...
		if (page->mapping && trylock_page(page)) {
			lru_add_drain();  /* push cached pages to LRU */
			/*
			 * Because we lock page here, and migration is
			 * blocked by the pte's page reference, and we
			 * know the page is still mapped, we don't even
			 * need to check for file-cache page truncation.
			 */
			mlock_vma_page(page);
			unlock_page(page);
		}
		...

I think we should add yisheng's patch, also we should add the following change.
I think it is better than use lru_add_drain_all().

diff --git a/mm/mlock.c b/mm/mlock.c
index 3d3ee6c..ca2aeb9 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -88,6 +88,11 @@ void mlock_vma_page(struct page *page)
 		count_vm_event(UNEVICTABLE_PGMLOCKED);
 		if (!isolate_lru_page(page))
 			putback_lru_page(page);
+		else {
+			ClearPageMlocked(page);
+			mod_zone_page_state(page_zone(page), NR_MLOCK,
+					-hpage_nr_pages(page));
+		}
 	}
 }

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
