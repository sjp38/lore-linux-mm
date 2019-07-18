Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D178C7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 16:11:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B21421019
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 16:11:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B21421019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 96DFB8E0009; Thu, 18 Jul 2019 12:11:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F79A8E0007; Thu, 18 Jul 2019 12:11:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7991F8E0009; Thu, 18 Jul 2019 12:11:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0198E0007
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 12:11:34 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id e14so6264611ljj.3
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 09:11:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Ka7PIt6i9Q88JwccYuiYHqGAECqE20Y+n7xYlOq9DlY=;
        b=saxvuBri8tTvW6Aar0yJnSMY7VVumHuyRSdoQn/jF3vOnwGDkqzgpv88d+MLyyv+bv
         ehmZNPPXpOAa+XT2xQc+AX1Zk2FLkzqpyAHut4ZV+4/GUVBZejKg/X01vtlhd4eOQQ5T
         vBbf5aiJC0wh3vQCY1Xaz8s6ol0tlZpofaqwg9knqjhYwi5cvdi6a9GID7/CN2xg9Qa3
         ikHiZZ1YsYkgcfgT2U1MDCVfweHjz2XPOYJ7zpusv/x6PvnoZU+1rwtd6JF0flN1wWhT
         7skOx646hiwgYUw/3d+F5ELIuQ2XHjGae92UStdm4KwjSA7zL8DOwKolCTomVHumkJrf
         C2Iw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAX6+WfOtpZqF5zHHnH2ExYxfhe9GicvYVZbhVCN6RYJwM6uxWV1
	TqnFhPnXDJYzf5fjSdYcKFZBzHJ0Xo2GwxQF/oVb3+IDLmxVhuvnbHm/mBuKxIGoV3hv4wKVGtM
	5QNaPvbgwXGa6abmbZz4Ex3VwNAmXgQZpq/V34BCT/Ph1frNZKTQqVCWwRT+n3k38bQ==
X-Received: by 2002:a2e:7013:: with SMTP id l19mr25169609ljc.141.1563466293314;
        Thu, 18 Jul 2019 09:11:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzUUjTkGTT6FUVR5mppasJSMO8bcPn2Ou11FW/vWVn7iNIBIYdqyh7adGti/V1CFLfyfb3r
X-Received: by 2002:a2e:7013:: with SMTP id l19mr25169554ljc.141.1563466292267;
        Thu, 18 Jul 2019 09:11:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563466292; cv=none;
        d=google.com; s=arc-20160816;
        b=b9LJDdTYcnlp00NPhMF/gpYQtmNFCAwbT+un50Ne6rQOCL7NHDiPtOPlmOQWO9ifab
         I5dKk3c53y287WkCZ/4EoMyAXn94+zNAUNW+3WppqMTGZDIQWOak8bNhsNFb/N6vatfd
         Dj57ecibaXb4uH5NGqU9Rq0twHz69TQQXTsTEGui5eJVjBQxl7IGz9vt5sQMAP0WIGZQ
         pEojAxOnqn2r43sZL9YTUnXSKfwKIXLUU/H2YR8ujIv/FMp42lgKQYvfwpdS9+2lMp3h
         JApwqzVUA8ToFqby8qCkdHH9+99lqjThtStotXiwK9q7kPssDhMM6gNIkevxs5s8Wr8N
         RVtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Ka7PIt6i9Q88JwccYuiYHqGAECqE20Y+n7xYlOq9DlY=;
        b=HB/qPFRPXS1m4lE9T8yY521JKd1vWrNbpDc51QEvOOKw1lSmIW7OeAXWwcSTc5tbS0
         qjeGjFaueJG2Thmc3s3c7xnK4+9P2jQkcEEChcV6AX+RFwc7cGNLQEPDvrPuuEQ2ZFbh
         oEStk59KjasVAX0Wa22i27eIiL3YxKaw3gwktBPpZVPjA9F6+o8Ak5fDy14dElTDalla
         pDKPbwWMFYCPwdnyJezKoQXRLRIEvGxGIO0fDbkbKmXnOmFxfRYEihMJILoro6BTTTtg
         jv8kLoc+Klpr6FDX3AwwsksL8WSPMa5R7ImVNh0NnBqydLsWFAHp0l0uBQbsTOCvANWg
         Uvtg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id 132si20850659lfi.55.2019.07.18.09.11.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 09:11:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.92)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1ho902-00080M-Ln; Thu, 18 Jul 2019 19:11:18 +0300
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
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <9ab1871a-2605-ab34-3fd3-4b44a0e17ab7@virtuozzo.com>
Date: Thu, 18 Jul 2019 19:11:21 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <1563160001.4793.4.camel@mtksdccf07>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/15/19 6:06 AM, Walter Wu wrote:
> On Fri, 2019-07-12 at 13:52 +0300, Andrey Ryabinin wrote:
>>
>> On 7/11/19 1:06 PM, Walter Wu wrote:
>>> On Wed, 2019-07-10 at 21:24 +0300, Andrey Ryabinin wrote:
>>>>
>>>> On 7/9/19 5:53 AM, Walter Wu wrote:
>>>>> On Mon, 2019-07-08 at 19:33 +0300, Andrey Ryabinin wrote:
>>>>>>
>>>>>> On 7/5/19 4:34 PM, Dmitry Vyukov wrote:
>>>>>>> On Mon, Jul 1, 2019 at 11:56 AM Walter Wu <walter-zh.wu@mediatek.com> wrote:
>>>>
>>>>>>>
>>>>>>> Sorry for delays. I am overwhelm by some urgent work. I afraid to
>>>>>>> promise any dates because the next week I am on a conference, then
>>>>>>> again a backlog and an intern starting...
>>>>>>>
>>>>>>> Andrey, do you still have concerns re this patch? This change allows
>>>>>>> to print the free stack.
>>>>>>
>>>>>> I 'm not sure that quarantine is a best way to do that. Quarantine is made to delay freeing, but we don't that here.
>>>>>> If we want to remember more free stacks wouldn't be easier simply to remember more stacks in object itself?
>>>>>> Same for previously used tags for better use-after-free identification.
>>>>>>
>>>>>
>>>>> Hi Andrey,
>>>>>
>>>>> We ever tried to use object itself to determine use-after-free
>>>>> identification, but tag-based KASAN immediately released the pointer
>>>>> after call kfree(), the original object will be used by another
>>>>> pointer, if we use object itself to determine use-after-free issue, then
>>>>> it has many false negative cases. so we create a lite quarantine(ring
>>>>> buffers) to record recent free stacks in order to avoid those false
>>>>> negative situations.
>>>>
>>>> I'm telling that *more* than one free stack and also tags per object can be stored.
>>>> If object reused we would still have information about n-last usages of the object.
>>>> It seems like much easier and more efficient solution than patch you proposing.
>>>>
>>> To make the object reused, we must ensure that no other pointers uses it
>>> after kfree() release the pointer.
>>> Scenario:
>>> 1). The object reused information is valid when no another pointer uses
>>> it.
>>> 2). The object reused information is invalid when another pointer uses
>>> it.
>>> Do you mean that the object reused is scenario 1) ?
>>> If yes, maybe we can change the calling quarantine_put() location. It
>>> will be fully use that quarantine, but at scenario 2) it looks like to
>>> need this patch.
>>> If no, maybe i miss your meaning, would you tell me how to use invalid
>>> object information? or?
>>>
>>
>>
>> KASAN keeps information about object with the object, right after payload in the kasan_alloc_meta struct.
>> This information is always valid as long as slab page allocated. Currently it keeps only one last free stacktrace.
>> It could be extended to record more free stacktraces and also record previously used tags which will allow you
>> to identify use-after-free and extract right free stacktrace.
> 
> Thanks for your explanation.
> 
> For extend slub object, if one record is 9B (sizeof(u8)+ sizeof(struct
> kasan_track)) and add five records into slub object, every slub object
> may add 45B usage after the system runs longer. 
> Slub object number is easy more than 1,000,000(maybe it may be more
> bigger), then the extending object memory usage should be 45MB, and
> unfortunately it is no limit. The memory usage is more bigger than our
> patch.

No, it's not necessarily more.
And there are other aspects to consider such as performance, how simple reliable the code is.

> 
> We hope tag-based KASAN advantage is smaller memory usage. If it’s
> possible, we should spend less memory in order to identify
> use-after-free. Would you accept our patch after fine tune it?

Sure, if you manage to fix issues and demonstrate that performance penalty of your
patch is close to zero.

