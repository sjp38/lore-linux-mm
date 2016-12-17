Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id B8C786B0267
	for <linux-mm@kvack.org>; Sat, 17 Dec 2016 07:00:58 -0500 (EST)
Received: by mail-yb0-f200.google.com with SMTP id v132so30030753yba.3
        for <linux-mm@kvack.org>; Sat, 17 Dec 2016 04:00:58 -0800 (PST)
Received: from mail-yw0-x241.google.com (mail-yw0-x241.google.com. [2607:f8b0:4002:c05::241])
        by mx.google.com with ESMTPS id 203si3220839ywu.17.2016.12.17.04.00.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Dec 2016 04:00:57 -0800 (PST)
Received: by mail-yw0-x241.google.com with SMTP id s68so5696039ywg.0
        for <linux-mm@kvack.org>; Sat, 17 Dec 2016 04:00:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <db51d8ca-e95f-ad93-ff6d-c55762d484c0@redhat.com>
References: <1481259930-4620-1-git-send-email-jaewon31.kim@samsung.com>
 <1481259930-4620-2-git-send-email-jaewon31.kim@samsung.com> <db51d8ca-e95f-ad93-ff6d-c55762d484c0@redhat.com>
From: Jaewon Kim <jaewon31.kim@gmail.com>
Date: Sat, 17 Dec 2016 21:00:57 +0900
Message-ID: <CAJrd-UsOxs7VbWoh49jEgYS5gM39k1d3mOy-cfr-bNWsBZfN1w@mail.gmail.com>
Subject: Re: [PATCH] staging: android: ion: return -ENOMEM in ion_cma_heap
 allocation failure
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Jaewon Kim <jaewon31.kim@samsung.com>, gregkh@linuxfoundation.org, sumit.semwal@linaro.org, tixy@linaro.org, prime.zeng@huawei.com, tranmanphong@gmail.com, fabio.estevam@freescale.com, ccross@android.com, rebecca@android.com, benjamin.gaignard@linaro.org, arve@android.com, riandrews@android.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

2016-12-14 1:04 GMT+09:00 Laura Abbott <labbott@redhat.com>:
> On 12/08/2016 09:05 PM, Jaewon Kim wrote:
>> Initial Commit 349c9e138551 ("gpu: ion: add CMA heap") returns -1 in allocation
>> failure. The returned value is passed up to userspace through ioctl. So user can
>> misunderstand error reason as -EPERM(1) rather than -ENOMEM(12).
>>
>> This patch simply changed this to return -ENOMEM.
>>
>> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
>> ---
>>  drivers/staging/android/ion/ion_cma_heap.c | 6 ++----
>>  1 file changed, 2 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/staging/android/ion/ion_cma_heap.c b/drivers/staging/android/ion/ion_cma_heap.c
>> index 6c7de74..22b9582 100644
>> --- a/drivers/staging/android/ion/ion_cma_heap.c
>> +++ b/drivers/staging/android/ion/ion_cma_heap.c
>> @@ -24,8 +24,6 @@
>>  #include "ion.h"
>>  #include "ion_priv.h"
>>
>> -#define ION_CMA_ALLOCATE_FAILED -1
>> -
>>  struct ion_cma_heap {
>>       struct ion_heap heap;
>>       struct device *dev;
>> @@ -59,7 +57,7 @@ static int ion_cma_allocate(struct ion_heap *heap, struct ion_buffer *buffer,
>>
>>       info = kzalloc(sizeof(struct ion_cma_buffer_info), GFP_KERNEL);
>>       if (!info)
>> -             return ION_CMA_ALLOCATE_FAILED;
>> +             return -ENOMEM;
>>
>>       info->cpu_addr = dma_alloc_coherent(dev, len, &(info->handle),
>>                                               GFP_HIGHUSER | __GFP_ZERO);
>> @@ -88,7 +86,7 @@ static int ion_cma_allocate(struct ion_heap *heap, struct ion_buffer *buffer,
>>       dma_free_coherent(dev, len, info->cpu_addr, info->handle);
>>  err:
>>       kfree(info);
>> -     return ION_CMA_ALLOCATE_FAILED;
>> +     return -ENOMEM;
>>  }
>>
>>  static void ion_cma_free(struct ion_buffer *buffer)
>>
>
> Happy to see cleanup
>
> Acked-by: Laura Abbott <labbott@redhat.com>

Thank you Laura Abbott. I'm honored to get Ack from you. I looked many
patches of you.
I hope this patch to be mainlined.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
