Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73630C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 17:05:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 042A921851
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 17:05:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 042A921851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 90D3B8E0005; Wed, 31 Jul 2019 13:05:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BDB48E0001; Wed, 31 Jul 2019 13:05:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7AD7C8E0005; Wed, 31 Jul 2019 13:05:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 15E098E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 13:05:06 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id c18so14998864lji.19
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 10:05:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=gLsZksY+gBpgTVjGj1ZFUu3CK/yOt5FqgBnNEXrwvKg=;
        b=c8S6u26BruvWYiNqqGpVYiNS2zv+v/U2z3lLapdQ2ZPY3Htu5c/idH/nxkNI64Nr9y
         /K4CcPuLQpkRyoaNOH1b0sYA/9HvETz+kz02VvtMh9GA0pBagwZ+ykDDoytfGpJadCug
         6blVrdEFey5buclfUiwDpmfU9ctTpIcU72l7KrM3aI7wl8Uwmy55AwZyQqd2ClHIR5H3
         Yzklk92p00f4Sqc8XX3Q8vS1Rhdl7wNMiSUdBjDmX13nPM1rS+e/jBd0OpxdUSPVWuta
         8dYNEx06QqtRmX2NIJUlq3luttKIb00KY43aMXkBy7YvDf/JY9oaCV20EgJEuiCDW5Z6
         m5wA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAXVTXznIhLTk+fv86X0TzHZSURZC2JYsbzXE9NNO9QKkcTXmtI+
	w/18jutrkq9tGszExbDbjDcACjELm4EEpcAo4afmFvgjztjKffZDlBH14R/1bji2Ux2N4a4WSjx
	viOTAoXIIAokF0ahE/ojrBevcTZB/Txzkvb6jjEwqlAu9uns3wisyphAY+x4a0p3TSQ==
X-Received: by 2002:a2e:86c3:: with SMTP id n3mr22930412ljj.129.1564592705329;
        Wed, 31 Jul 2019 10:05:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyPmlyC92GXBN/aWjQzJ/w8KvvxQJ+9IpO/bXhrHFTO3GiHmI/zOqaUSKVkAIuTJb03F30S
X-Received: by 2002:a2e:86c3:: with SMTP id n3mr22930361ljj.129.1564592704264;
        Wed, 31 Jul 2019 10:05:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564592704; cv=none;
        d=google.com; s=arc-20160816;
        b=0ql7/9H8vMWyTlFao/Ad8KnCVwpUEYT3r5t7zWq1TPt3CPBtDGrDpSIkj8N25Ar17K
         vP/wmkI1pmGPR84yzJL/PXKsZK7izaCj/cHjrUVJTdu5jEki8ne70CP9XiKt2FknH2fE
         Rug7PH9YmC7o0RaMY/hH/hlrkvLeLM57HrmGAs9VnROIcCmMa+7HHSobyXH42BdVg61m
         jihnN3JrCYIWq1B1UGB0yt6Ptg9Lnzbvd4dn8i0bGyi20uwwDRUEYpTjx/kbEGGm8u8Y
         VWkfB2Mhnf/QJ7uoj2ZNqwiDsG+0xvVH/hYv1kAu82UWfcKNH/Roxb4RzJvzeezLNcn5
         M41w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=gLsZksY+gBpgTVjGj1ZFUu3CK/yOt5FqgBnNEXrwvKg=;
        b=MtZMLttdgg4LiyZg3qYMGZgzaBdDq6IGmrRBsGMptvTgTPLJkKZjanX5zMIYCUSOD0
         CQW9cn7nhG07V3PQTJicBeVwmjg6PBOGWMtRbzIhza8oWmxR3txGwlDBneNcWgA4/Oo4
         9a+zQnfKjGP7aEwaxXTweANs4ykf/15TO/efs4ZlWU+xvZNna10cU2P0UNgnYccKeQMB
         1ZRtiEMbbnOyHMihY8yQYdjHiU/jGPKa630MIjlVCtJV9OSpRaDjr7dtwnyDA1iRC6U8
         ON+10r7Kr9RRjTnf1hPLT4P43sIYfOPtRbbOADTgx8TKBkapKwXdTl9S0hwgxMHH46i1
         y73A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id 25si63141704ljs.122.2019.07.31.10.05.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 10:05:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.92)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1hss1z-0001ux-M2; Wed, 31 Jul 2019 20:04:51 +0300
Subject: Re: [PATCH v3] kasan: add memory corruption identification for
 software tag-based mode
To: Walter Wu <walter-zh.wu@mediatek.com>
Cc: Dmitry Vyukov <dvyukov@google.com>,
 Alexander Potapenko <glider@google.com>, Christoph Lameter <cl@linux.com>,
 Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>,
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
 <d9fd1d5b-9516-b9b9-0670-a1885e79f278@virtuozzo.com>
 <1562839579.5846.12.camel@mtksdccf07>
 <37897fb7-88c1-859a-dfcc-0a5e89a642e0@virtuozzo.com>
 <1563160001.4793.4.camel@mtksdccf07>
 <9ab1871a-2605-ab34-3fd3-4b44a0e17ab7@virtuozzo.com>
 <1563789162.31223.3.camel@mtksdccf07>
 <e62da62a-2a63-3a1c-faeb-9c5561a5170c@virtuozzo.com>
 <1564144097.515.3.camel@mtksdccf07>
 <71df2bd5-7bc8-2c82-ee31-3f68c3b6296d@virtuozzo.com>
 <1564147164.515.10.camel@mtksdccf07>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <f29ee964-cf12-1b5d-e570-1d5baa49a580@virtuozzo.com>
Date: Wed, 31 Jul 2019 20:04:59 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <1564147164.515.10.camel@mtksdccf07>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/26/19 4:19 PM, Walter Wu wrote:
> On Fri, 2019-07-26 at 15:52 +0300, Andrey Ryabinin wrote:
>>
>> On 7/26/19 3:28 PM, Walter Wu wrote:
>>> On Fri, 2019-07-26 at 15:00 +0300, Andrey Ryabinin wrote:
>>>>
>>>
>>>>>
>>>>>
>>>>> I remember that there are already the lists which you concern. Maybe we
>>>>> can try to solve those problems one by one.
>>>>>
>>>>> 1. deadlock issue? cause by kmalloc() after kfree()?
>>>>
>>>> smp_call_on_cpu()
>>>
>>>>> 2. decrease allocation fail, to modify GFP_NOWAIT flag to GFP_KERNEL?
>>>>
>>>> No, this is not gonna work. Ideally we shouldn't have any allocations there.
>>>> It's not reliable and it hurts performance.
>>>>
>>> I dont know this meaning, we need create a qobject and put into
>>> quarantine, so may need to call kmem_cache_alloc(), would you agree this
>>> action?
>>>
>>
>> How is this any different from what you have now?
> 
> I originally thought you already agreed the free-list(tag-based
> quarantine) after fix those issue. If no allocation there,

If no allocation there, than it must be somewhere else.
We known exactly the amount of memory we need, so it's possible to preallocate it in advance.


> i think maybe
> only move generic quarantine into tag-based kasan, but its memory
> consumption is more bigger our patch. what do you think?
> 

