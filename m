Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D72CC74A36
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 18:24:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 068002087F
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 18:24:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 068002087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 984E38E0086; Wed, 10 Jul 2019 14:24:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90EB78E0032; Wed, 10 Jul 2019 14:24:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FDE68E0086; Wed, 10 Jul 2019 14:24:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1B5328E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 14:24:42 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id t23so265049lfb.8
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 11:24:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=wZtz7lm7J/SagsRkoCghKnDoEzNg/tnMRP90/zbxSlc=;
        b=k9gUHTKsjGGNbDlVbmibss/UwmiFlfUtxD3aStoPIS5B1eRBpR4s7cyw8UU2R1VKu2
         ee8aAwM2TlHjv6x91qSomwL4SLV8kzZJHjnP1H+rJI/xEu+E1B31TMkwAi0nvzxcggeF
         oKlwspA6N/k+OCO8Cyx6mIa2D7J5a8jw6cuZXlYsVaOy17UNh70IAJGRTFGoitCGk2kY
         1Mr6pex/s4pfdww2lFEA4MVYUR+6mKc3wtXBo8ybPaw7Rlili4zjNBFGU2QsVYO0M8lx
         NabbhkNz/eNB+vt4fJpgd9iu1f+thV0IZ3HIJieL4oY13k73TfILTza+k2pcO76NKgrz
         RzhA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAVNvvakLYz/Hhth8erQHweJ0fycJvcQ3iwNGbe1Dm+3rjYQNlug
	dg0BRGHwbpf1h0wGllcBC0JIwLP8bgolFbWwl3k+4a6Ir73zV9bVrm2weBjvrF1Lsysfmw9zvP6
	FGo+Td+Nxqcvjn0X+4DXOr9l8LaxyffKuc1NKjRgQiv5qoyXOJCnRRg0/kvsJ0Rx3Jg==
X-Received: by 2002:a2e:8007:: with SMTP id j7mr18349966ljg.191.1562783081370;
        Wed, 10 Jul 2019 11:24:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQ2RC1wJeSmGDBQUEtUa2mEuzIe0210A7UFUaPfxxBZBz8Dwzzo2pi2MbIQxAL/5X8/4eQ
X-Received: by 2002:a2e:8007:: with SMTP id j7mr18349935ljg.191.1562783080455;
        Wed, 10 Jul 2019 11:24:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562783080; cv=none;
        d=google.com; s=arc-20160816;
        b=ZGR5gBG4JpuY8X+z64NlowlQ0LEnUL7OA0FeliPhtuZ9NpO4bXXYedKkPjICq8AuLC
         Ag33L9LxcqTlJb8yuUHV3cHal+BzoYccBur3PKWZrQogD7MgbdTBqncdjq5w+KuBBfR+
         ZMMLPUYumvXS3guJqGB/frJy93DCdUxT6TJpaz3ShScpKmGrlNj9dbtLTswSea4CWpnY
         zV2pUmJcSvADZZKUr+FTJIJVKQSycvVYnYvK/UlCFKpKpJgGyg8vSWZB2pPd7VmNILco
         24XYTM8Uy99Dv8SXpEYt33G4NE4OC3xMAnstNv2aPGtu2vK6I/fIQR3MQWofv3/rL2f6
         30QQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=wZtz7lm7J/SagsRkoCghKnDoEzNg/tnMRP90/zbxSlc=;
        b=ydsA/5EzxUvh2hRWYHseWlmZYp4KwfH4Ns1stn7aFrA2CyrfaUAj6IEiGlvVW8nQta
         exxA2Mis7hAi8CYWRybCndQTRrJSknIaVpkXVwRdvIEAcUE4oXdwsJvJkBuFBw2tuepf
         FjQoIr7Kkh+mvSWYritV3NR6YS4g8LDEBiuiQAaiOpvRyZbP9ckUrhYBXmwHgfCU4OmJ
         kg+L5F1GrNtMraFoF8d8uNF3SFtUEwMamJmQVh6kaK3ws8LshiJ2rJMa1usvovG9PSLk
         PXxsEujuEo/rm7eeplfVL4rTkF4p9F1MF7tCWy7v8xm7LYPiKp0eXlnDpHoEWXjiZ3x1
         GB6g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id x22si2694041ljg.217.2019.07.10.11.24.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jul 2019 11:24:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.92)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1hlHGV-0006Kk-L9; Wed, 10 Jul 2019 21:24:27 +0300
Subject: Re: [PATCH v3] kasan: add memory corruption identification for
 software tag-based mode
To: Walter Wu <walter-zh.wu@mediatek.com>, Dmitry Vyukov <dvyukov@google.com>
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
 <ebc99ee1-716b-0b18-66ab-4e93de02ce50@virtuozzo.com>
 <1562640832.9077.32.camel@mtksdccf07>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <d9fd1d5b-9516-b9b9-0670-a1885e79f278@virtuozzo.com>
Date: Wed, 10 Jul 2019 21:24:22 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <1562640832.9077.32.camel@mtksdccf07>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/9/19 5:53 AM, Walter Wu wrote:
> On Mon, 2019-07-08 at 19:33 +0300, Andrey Ryabinin wrote:
>>
>> On 7/5/19 4:34 PM, Dmitry Vyukov wrote:
>>> On Mon, Jul 1, 2019 at 11:56 AM Walter Wu <walter-zh.wu@mediatek.com> wrote:

>>>
>>> Sorry for delays. I am overwhelm by some urgent work. I afraid to
>>> promise any dates because the next week I am on a conference, then
>>> again a backlog and an intern starting...
>>>
>>> Andrey, do you still have concerns re this patch? This change allows
>>> to print the free stack.
>>
>> I 'm not sure that quarantine is a best way to do that. Quarantine is made to delay freeing, but we don't that here.
>> If we want to remember more free stacks wouldn't be easier simply to remember more stacks in object itself?
>> Same for previously used tags for better use-after-free identification.
>>
> 
> Hi Andrey,
> 
> We ever tried to use object itself to determine use-after-free
> identification, but tag-based KASAN immediately released the pointer
> after call kfree(), the original object will be used by another
> pointer, if we use object itself to determine use-after-free issue, then
> it has many false negative cases. so we create a lite quarantine(ring
> buffers) to record recent free stacks in order to avoid those false
> negative situations.

I'm telling that *more* than one free stack and also tags per object can be stored.
If object reused we would still have information about n-last usages of the object.
It seems like much easier and more efficient solution than patch you proposing.

As for other concern about this particular patch
 - It wasn't tested. There is deadlock (sleep in atomic) on the report path which would have been noticed it tested.
   Also GFP_NOWAIT allocation which fails very noisy and very often, especially in memory constraint enviromnent where tag-based KASAN supposed to be used.

 - Inefficient usage of memory:
	48 bytes (sizeof (qlist_object) + sizeof(kasan_alloc_meta)) per kfree() call seems like a lot. It could be less.

	The same 'struct kasan_track' stored twice in two different places (in object and in quarantine).
	Basically, at least some part of the quarantine always duplicates information that we already know about
	recently freed object. 

	Since now we call kmalloc() from kfree() path, every unique kfree() stacktrace now generates additional unique stacktrace that
	takes space in stackdepot.

