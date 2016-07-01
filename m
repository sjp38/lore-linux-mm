Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A7C3D828E2
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 10:21:14 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c82so19982194wme.2
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 07:21:14 -0700 (PDT)
Received: from mail-lf0-x233.google.com (mail-lf0-x233.google.com. [2a00:1450:4010:c07::233])
        by mx.google.com with ESMTPS id t10si4523026lfd.348.2016.07.01.07.21.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 07:21:13 -0700 (PDT)
Received: by mail-lf0-x233.google.com with SMTP id l188so78291395lfe.2
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 07:21:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <57767BCA.8010305@virtuozzo.com>
References: <1467381733-18314-1-git-send-email-iamjoonsoo.kim@lge.com>
 <CACT4Y+ZgmmizB209CUMOnq_p=2=__Y8AH4qsq1SG0RYk2kvxbQ@mail.gmail.com>
 <CAAmzW4MfofvK7hM_hVbpZ0orWaLcWYGUQ7HRafeaqD49ACER6Q@mail.gmail.com>
 <CACT4Y+bVWR88KivuMnX9a9v1tkk8VhhxSVx6TjznPqxc26evjg@mail.gmail.com> <57767BCA.8010305@virtuozzo.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 1 Jul 2016 16:20:53 +0200
Message-ID: <CACT4Y+Z6gHyjevYmFFAZWUQhdyBSZphWrB_ShGPwPo=CPfsUhw@mail.gmail.com>
Subject: Re: [PATCH v3] kasan/quarantine: fix bugs on qlist_move_cache()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, Jul 1, 2016 at 4:18 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>
>
> On 07/01/2016 05:15 PM, Dmitry Vyukov wrote:
>> On Fri, Jul 1, 2016 at 4:09 PM, Joonsoo Kim <js1304@gmail.com> wrote:
>>> 2016-07-01 23:03 GMT+09:00 Dmitry Vyukov <dvyukov@google.com>:
>
>>>>> +
>>>>> +               if (obj_cache == cache)
>>>>> +                       qlist_put(to, qlink, cache->size);
>>>>> +               else
>>>>> +                       qlist_put(from, qlink, cache->size);
>>>>
>>>> This line is wrong. If obj_cache != cache, object size != cache->size.
>>>> Quarantine contains objects of different sizes.
>>>
>>> You're right. 11 pm is not good time to work. :/
>>> If it is fixed, the patch looks correct to you?
>>> I will fix it and send v4 on next week.
>>
>>
>> I don't see anything else wrong. But I need to see how you fix the size issue.
>> Performance of this operation is not particularly critical, so the
>> simpler the better.
>
> Is there any other way besides obvious: s/cache->size/obj_cache->size ?

We can remember the original bytes, then subtract
num_objects_moved*cache->size from it and assign to from->bytes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
