Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4E3976B0005
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 08:23:32 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g62so190531370pfb.3
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 05:23:32 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id y144si3140112pfb.83.2016.06.13.05.22.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Jun 2016 05:23:30 -0700 (PDT)
Subject: Re: [PATCH v1 0/3] per-process reclaim
References: <1465804259-29345-1-git-send-email-minchan@kernel.org>
 <575E9DE8.4050200@hisilicon.com>
From: "ZhaoJunmin Zhao(Junmin)" <zhaojunmin@huawei.com>
Message-ID: <575EA573.2010204@huawei.com>
Date: Mon, 13 Jun 2016 20:22:11 +0800
MIME-Version: 1.0
In-Reply-To: <575E9DE8.4050200@hisilicon.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Feng <puck.chen@hisilicon.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Redmond <u93410091@gmail.com>, Vinayak Menon <vinmenon@codeaurora.org>, Juneho Choi <juno.choi@lge.com>, Sangwoo Park <sangwoo2.park@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>



a?? 2016/6/13 19:50, Chen Feng a??e??:
> Hi Minchan,
>
> On 2016/6/13 15:50, Minchan Kim wrote:
>> Hi all,
>>
>> http://thread.gmane.org/gmane.linux.kernel/1480728
>>
>> I sent per-process reclaim patchset three years ago. Then, last
>> feedback from akpm was that he want to know real usecase scenario.
>>
>> Since then, I got question from several embedded people of various
>> company "why it's not merged into mainline" and heard they have used
>> the feature as in-house patch and recenlty, I noticed android from
>> Qualcomm started to use it.
>>
>> Of course, our product have used it and released it in real procuct.
>>
>> Quote from Sangwoo Park <angwoo2.park@lge.com>
>> Thanks for the data, Sangwoo!
>> "
>> - Test scenaro
>>    - platform: android
>>    - target: MSM8952, 2G DDR, 16G eMMC
>>    - scenario
>>      retry app launch and Back Home with 16 apps and 16 turns
>>      (total app launch count is 256)
>>    - result:
>> 			  resume count   |  cold launching count
>> -----------------------------------------------------------------
>>   vanilla           |           85        |          171
>>   perproc reclaim   |           184       |           72
>> "
>>
>> Higher resume count is better because cold launching needs loading
>> lots of resource data which takes above 15 ~ 20 seconds for some
>> games while successful resume just takes 1~5 second.
>>
>> As perproc reclaim way with new management policy, we could reduce
>> cold launching a lot(i.e., 171-72) so that it reduces app startup
>> a lot.
>>
>> Another useful function from this feature is to make swapout easily
>> which is useful for testing swapout stress and workloads.
>>
> Thanks Minchan.
>
> Yes, this is useful interface when there are memory pressure and let the userspace(Android)
> to pick process for reclaim. We also take there series into our platform.
>
> But I have a question on the reduce app startup time. Can you also share your
> theory(management policy) on how can the app reduce it's startup time?
>
>
>> Thanks.

Yes, In Huawei device, we use the interface now! Now according to 
procsss LRU state in ActivityManagerService, we can reclaim some process
in proactive way.

>>
>> Cc: Redmond <u93410091@gmail.com>
>> Cc: ZhaoJunmin Zhao(Junmin) <zhaojunmin@huawei.com>
>> Cc: Vinayak Menon <vinmenon@codeaurora.org>
>> Cc: Juneho Choi <juno.choi@lge.com>
>> Cc: Sangwoo Park <sangwoo2.park@lge.com>
>> Cc: Chan Gyun Jeong <chan.jeong@lge.com>
>>
>> Minchan Kim (3):
>>    mm: vmscan: refactoring force_reclaim
>>    mm: vmscan: shrink_page_list with multiple zones
>>    mm: per-process reclaim
>>
>>   Documentation/filesystems/proc.txt |  15 ++++
>>   fs/proc/base.c                     |   1 +
>>   fs/proc/internal.h                 |   1 +
>>   fs/proc/task_mmu.c                 | 149 +++++++++++++++++++++++++++++++++++++
>>   include/linux/rmap.h               |   4 +
>>   mm/vmscan.c                        |  85 ++++++++++++++++-----
>>   6 files changed, 235 insertions(+), 20 deletions(-)
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
