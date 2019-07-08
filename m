Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F4AAC606BD
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 16:33:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C856F21479
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 16:33:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C856F21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A6648E001C; Mon,  8 Jul 2019 12:33:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 131338E0002; Mon,  8 Jul 2019 12:33:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 046F58E001C; Mon,  8 Jul 2019 12:33:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 921688E0002
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 12:33:52 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id e14so3817789ljj.3
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 09:33:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=8xnud/qEILYwa7BJOMRtOBOSIve8spYjI6fhHhkcm+Q=;
        b=n/m+su7Sa1JbfQp+VgSDFW/9wYjaRqfdxZlNrCRCLjiZExebfoYyUEQVShvmUcvZqz
         M3JEuyVEiL7IbY7i578dn1BMahmZdLai5BCjU2kRVf3zojTBdZFw9zN6Zxt4e6aDewP3
         /wslpFK2CaZvdEUMi2yCDAko6FO19DMvgP2JitHNjDMksO6o6C/vYxfps9Y3+036WagZ
         zYgf3edtc7FersxFQix85oyYdJRa6JrvWigBTSQlwqPa1PMrKSDQJ77BdVeJk1WFor1L
         igJ0LkGR5JNJtZQj8E5Rql5fjnGcsoMZNkfgtLNZBS7ChwxPuA/k4qMUZmibuwBuJr9x
         M73w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAW56H8dJn+ChTxm4wX6khavNlGHBFuiteIAaW3VenkVZBQ0HAj6
	f1BypI3gEtt+pH91nrjT/2Uw94xyEHNcPeH1xe8JjAdzaGBipHwwYZL/uKAFyVHYKbcQNsNulFO
	0IJlnF7tc8jxFyKcQTJq/gIIW7gre8DRQ4d1xA+yiURGlmZNTSpSjho4COslxz8Wjiw==
X-Received: by 2002:a2e:9003:: with SMTP id h3mr10360286ljg.194.1562603631926;
        Mon, 08 Jul 2019 09:33:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygUeNBrncemKeb2+ume7tUkm1VUNsJm3x778LIeFvacha1SEGEoWQ1yaMvYhaq1iWSZRnN
X-Received: by 2002:a2e:9003:: with SMTP id h3mr10360231ljg.194.1562603630558;
        Mon, 08 Jul 2019 09:33:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562603630; cv=none;
        d=google.com; s=arc-20160816;
        b=Oki76f5rVP9GXOLq08ALxln5IvGvtl+s4HovGQZLDjMIYjg2Wg5E8wsEYOxM+9Q6nD
         QpuBoBnaYWM7Ao1ikviRrit6SuuMtXZcA8cZBdiCkIAmbqCXAIFldUGH9DVQwOb7gig2
         AARqRtz9in6H6svIFAzAgk1ZzFeyUTVFVMdOFymvn1jYfO5SpVeU2wb2M7MtQ//fuzgE
         KFcL+1aiompvQUW4coMX6sHbWjjcxMstQca6+7E9mJHIDQcKEsBZZoY2+bF9NtaR0UPL
         PCpe6UhJBpCcH5L5aPjmfSHEYJMzAv9DNyqiik6Xn8ERus61h8QtFGwtPeeWJTnTvkvK
         2fSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=8xnud/qEILYwa7BJOMRtOBOSIve8spYjI6fhHhkcm+Q=;
        b=x6LL+345289uOWcXQq15orKiZtd8uMOrsC7bWwMEq719+V6yyN229eVuEYyxjKdhrb
         jAiXYEzGdepvF0JrSP/lfudxcQEAZ5QnkoYYrJGnM/WiSc2U3q6U8yW7Jfjt6yLiHSUT
         sebzV/Vb2dOikawktMBIJ+0eGicX2Qm5hluz4TY7rDWXi2ATadWXByfjCNmZMZyOhvSY
         KVuq12wHklrVI2yWCZZmZf/ceC5uOcUGvQeA5La88m9UnDV36ufxWUjAu1bF6cigMtVr
         DXe4Su01df7a2q6CWv9EVjFMC/4YF8lTbKWxEynUgZMeiTiquKmUakckE1/fuy/UBqgc
         Gugw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id m22si13734384lfb.140.2019.07.08.09.33.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jul 2019 09:33:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.92)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1hkWa8-00028e-L6; Mon, 08 Jul 2019 19:33:36 +0300
Subject: Re: [PATCH v3] kasan: add memory corruption identification for
 software tag-based mode
To: Dmitry Vyukov <dvyukov@google.com>, Walter Wu <walter-zh.wu@mediatek.com>
Cc: Alexander Potapenko <glider@google.com>, Christoph Lameter
 <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Matthias Brugger <matthias.bgg@gmail.com>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>,
 Vasily Gorbik <gor@linux.ibm.com>, Andrey Konovalov <andreyknvl@google.com>,
 "Jason A . Donenfeld" <Jason@zx2c4.com>, Miles Chen
 <miles.chen@mediatek.com>, kasan-dev <kasan-dev@googlegroups.com>,
 LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
 Linux ARM <linux-arm-kernel@lists.infradead.org>,
 linux-mediatek@lists.infradead.org, wsd_upstream <wsd_upstream@mediatek.com>
References: <20190613081357.1360-1-walter-zh.wu@mediatek.com>
 <da7591c9-660d-d380-d59e-6d70b39eaa6b@virtuozzo.com>
 <1560447999.15814.15.camel@mtksdccf07> <1560479520.15814.34.camel@mtksdccf07>
 <1560744017.15814.49.camel@mtksdccf07>
 <CACT4Y+Y3uS59rXf92ByQuFK_G4v0H8NNnCY1tCbr4V+PaZF3ag@mail.gmail.com>
 <1560774735.15814.54.camel@mtksdccf07> <1561974995.18866.1.camel@mtksdccf07>
 <CACT4Y+aMXTBE0uVkeZz+MuPx3X1nESSBncgkScWvAkciAxP1RA@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <ebc99ee1-716b-0b18-66ab-4e93de02ce50@virtuozzo.com>
Date: Mon, 8 Jul 2019 19:33:41 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <CACT4Y+aMXTBE0uVkeZz+MuPx3X1nESSBncgkScWvAkciAxP1RA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/5/19 4:34 PM, Dmitry Vyukov wrote:
> On Mon, Jul 1, 2019 at 11:56 AM Walter Wu <walter-zh.wu@mediatek.com> wrote:
>>>>>>>>> This patch adds memory corruption identification at bug report for
>>>>>>>>> software tag-based mode, the report show whether it is "use-after-free"
>>>>>>>>> or "out-of-bound" error instead of "invalid-access" error.This will make
>>>>>>>>> it easier for programmers to see the memory corruption problem.
>>>>>>>>>
>>>>>>>>> Now we extend the quarantine to support both generic and tag-based kasan.
>>>>>>>>> For tag-based kasan, the quarantine stores only freed object information
>>>>>>>>> to check if an object is freed recently. When tag-based kasan reports an
>>>>>>>>> error, we can check if the tagged addr is in the quarantine and make a
>>>>>>>>> good guess if the object is more like "use-after-free" or "out-of-bound".
>>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>> We already have all the information and don't need the quarantine to make such guess.
>>>>>>>> Basically if shadow of the first byte of object has the same tag as tag in pointer than it's out-of-bounds,
>>>>>>>> otherwise it's use-after-free.
>>>>>>>>
>>>>>>>> In pseudo-code it's something like this:
>>>>>>>>
>>>>>>>> u8 object_tag = *(u8 *)kasan_mem_to_shadow(nearest_object(cacche, page, access_addr));
>>>>>>>>
>>>>>>>> if (access_addr_tag == object_tag && object_tag != KASAN_TAG_INVALID)
>>>>>>>>   // out-of-bounds
>>>>>>>> else
>>>>>>>>   // use-after-free
>>>>>>>
>>>>>>> Thanks your explanation.
>>>>>>> I see, we can use it to decide corruption type.
>>>>>>> But some use-after-free issues, it may not have accurate free-backtrace.
>>>>>>> Unfortunately in that situation, free-backtrace is the most important.
>>>>>>> please see below example
>>>>>>>
>>>>>>> In generic KASAN, it gets accurate free-backrace(ptr1).
>>>>>>> In tag-based KASAN, it gets wrong free-backtrace(ptr2). It will make
>>>>>>> programmer misjudge, so they may not believe tag-based KASAN.
>>>>>>> So We provide this patch, we hope tag-based KASAN bug report is the same
>>>>>>> accurate with generic KASAN.
>>>>>>>
>>>>>>> ---
>>>>>>>     ptr1 = kmalloc(size, GFP_KERNEL);
>>>>>>>     ptr1_free(ptr1);
>>>>>>>
>>>>>>>     ptr2 = kmalloc(size, GFP_KERNEL);
>>>>>>>     ptr2_free(ptr2);
>>>>>>>
>>>>>>>     ptr1[size] = 'x';  //corruption here
>>>>>>>
>>>>>>>
>>>>>>> static noinline void ptr1_free(char* ptr)
>>>>>>> {
>>>>>>>     kfree(ptr);
>>>>>>> }
>>>>>>> static noinline void ptr2_free(char* ptr)
>>>>>>> {
>>>>>>>     kfree(ptr);
>>>>>>> }
>>>>>>> ---
>>>>>>>
>>>>>> We think of another question about deciding by that shadow of the first
>>>>>> byte.
>>>>>> In tag-based KASAN, it is immediately released after calling kfree(), so
>>>>>> the slub is easy to be used by another pointer, then it will change
>>>>>> shadow memory to the tag of new pointer, it will not be the
>>>>>> KASAN_TAG_INVALID, so there are many false negative cases, especially in
>>>>>> small size allocation.
>>>>>>
>>>>>> Our patch is to solve those problems. so please consider it, thanks.
>>>>>>
>>>>> Hi, Andrey and Dmitry,
>>>>>
>>>>> I am sorry to bother you.
>>>>> Would you tell me what you think about this patch?
>>>>> We want to use tag-based KASAN, so we hope its bug report is clear and
>>>>> correct as generic KASAN.
>>>>>
>>>>> Thanks your review.
>>>>> Walter
>>>>
>>>> Hi Walter,
>>>>
>>>> I will probably be busy till the next week. Sorry for delays.
>>>
>>> It's ok. Thanks your kindly help.
>>> I hope I can contribute to tag-based KASAN. It is a very important tool
>>> for us.
>>
>> Hi, Dmitry,
>>
>> Would you have free time to discuss this patch together?
>> Thanks.
> 
> Sorry for delays. I am overwhelm by some urgent work. I afraid to
> promise any dates because the next week I am on a conference, then
> again a backlog and an intern starting...
> 
> Andrey, do you still have concerns re this patch? This change allows
> to print the free stack.

I 'm not sure that quarantine is a best way to do that. Quarantine is made to delay freeing, but we don't that here.
If we want to remember more free stacks wouldn't be easier simply to remember more stacks in object itself?
Same for previously used tags for better use-after-free identification.

> We also have a quarantine for hwasan in user-space. Though it works a
> bit differently then the normal asan quarantine. We keep a per-thread
> fixed-size ring-buffer of recent allocations:
> https://github.com/llvm-mirror/compiler-rt/blob/master/lib/hwasan/hwasan_report.cpp#L274-L284
> and scan these ring buffers during reports.
> 

