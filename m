Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EEC3C742B3
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 10:52:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F1842084B
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 10:52:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F1842084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C8648E0138; Fri, 12 Jul 2019 06:52:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 749CA8E00DB; Fri, 12 Jul 2019 06:52:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6122B8E0138; Fri, 12 Jul 2019 06:52:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id F22E38E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 06:52:52 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id s10so693671lfp.14
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 03:52:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=O67v3k5bom5Y2GHrnJOdlacQsTwxZnyxwR9ee+CLLBI=;
        b=KbM07hlSg9/ayP0NfKQR9FOP+Skm88hFH4pEwbEF8/+BaSKU+OcBeu8C7Oo+uabEJe
         NbV8QRwLp2sAdH2LMKLX3dtUFuenSqyhRw4ktw9pWMIwfzLb95B9gv998imOLZ5R68oV
         lF3Vz9BbCCWk2I9u7m4PTKcoHBppocJVp0AxiEid42ipYWoSqK+0gR7c8u0WIN8oki29
         WcIz2L0DXcFhhy1BLhjvcy7LIahn9Jp3snQLlbUFKpD7scrACYpPNrBw1lpJrari3+3R
         aPX6D+B2cKeLlZtyhTuShPPe7B7BdUbdW3id9rmvQr/UeffGv4jGetofdh4MbeO0N3oO
         /sHA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAWdncT6ziNrGW/nbYv6ETE2qs82WwHF2aDdlzIPCBI+FVzvp0Gz
	E/DAHX4fY96bPkj7CXYl7SwXOHmHeYq13HoSWcH0wGYYmGlK0vt7N5BaABYeTBE/b88ISXzwcx4
	hVchWFYMqV6jtsZeZuFOMBsDpyJWtsz9UC5qJXlWNf55htkTQyemG3NYfp9cITVfXdQ==
X-Received: by 2002:ac2:563c:: with SMTP id b28mr4334784lff.93.1562928772229;
        Fri, 12 Jul 2019 03:52:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtrHk5HosTJQKMUyO+LfmTKnprKseTTkURiJ0QKlVLFtsUE+NoSGMQ2ltxN5m/9mmGCs1K
X-Received: by 2002:ac2:563c:: with SMTP id b28mr4334748lff.93.1562928771289;
        Fri, 12 Jul 2019 03:52:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562928771; cv=none;
        d=google.com; s=arc-20160816;
        b=VSoB+gCQCDif3fTpGKjLYxE41ig5Mve2Fi3hkTYwxUmQogwwwA6N3zDmUZ/5sc9Tsg
         Ui43mB6J6Zeykcl7u5GHV7P1lBdIWAN48hbuLG+Gr6g/iVpCOD92HyPiAv8KhUha7ZFq
         +xbOZhF1zOSPUH1FWLra8bhN/zQ5WZoUDr4VVywZY126cC5FqDQjmzJyW0DnYQIRuS5z
         Hzr36R7LsG5oePPbqpxUxRIsOISYV6SUXsqZgyPGDdbBBmpK7xBzmk8WBgeR46sqGZgW
         v4zmeLFp+d4D6pEbzwCNhWCGb0YcFT62ynyVG9I1sOqn+CBEeKx6BCdNkceZirKfDPHu
         haLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=O67v3k5bom5Y2GHrnJOdlacQsTwxZnyxwR9ee+CLLBI=;
        b=AACCyqW+hpkpVNaGrnV8hOWKPwzSknEDZKJTmrl7dg1WKUSSDFI80KrBRprlGxXrmw
         wVUiLvAQ4OPNn0uA/3ehghArlkxPvx5IICR4PgypBzY8CJ7fHxaKhyl3CwtCAnQCrT74
         rSh1p6jJlybehzrsLSxA06LodlV7CQlZatdoMETc5nypr081i+CQKZN4+3pZJiyfKfdV
         7YZJ+V1n6/1buKxyD1y6tGQNVwofp6D9HrE1wyzP5OCW1GyTWoN7R4wXZP+fOLW8ElVn
         cSLfpjR/nSZAFSky7JNCM0kPHFTxugbBFWcCPSkBSi/W3CLJ/cy2VJsCkQDe8/01EW2I
         NFJA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id l13si6789832lfk.73.2019.07.12.03.52.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 03:52:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.92)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1hltAL-0005Ih-PS; Fri, 12 Jul 2019 13:52:38 +0300
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
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <37897fb7-88c1-859a-dfcc-0a5e89a642e0@virtuozzo.com>
Date: Fri, 12 Jul 2019 13:52:40 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <1562839579.5846.12.camel@mtksdccf07>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/11/19 1:06 PM, Walter Wu wrote:
> On Wed, 2019-07-10 at 21:24 +0300, Andrey Ryabinin wrote:
>>
>> On 7/9/19 5:53 AM, Walter Wu wrote:
>>> On Mon, 2019-07-08 at 19:33 +0300, Andrey Ryabinin wrote:
>>>>
>>>> On 7/5/19 4:34 PM, Dmitry Vyukov wrote:
>>>>> On Mon, Jul 1, 2019 at 11:56 AM Walter Wu <walter-zh.wu@mediatek.com> wrote:
>>
>>>>>
>>>>> Sorry for delays. I am overwhelm by some urgent work. I afraid to
>>>>> promise any dates because the next week I am on a conference, then
>>>>> again a backlog and an intern starting...
>>>>>
>>>>> Andrey, do you still have concerns re this patch? This change allows
>>>>> to print the free stack.
>>>>
>>>> I 'm not sure that quarantine is a best way to do that. Quarantine is made to delay freeing, but we don't that here.
>>>> If we want to remember more free stacks wouldn't be easier simply to remember more stacks in object itself?
>>>> Same for previously used tags for better use-after-free identification.
>>>>
>>>
>>> Hi Andrey,
>>>
>>> We ever tried to use object itself to determine use-after-free
>>> identification, but tag-based KASAN immediately released the pointer
>>> after call kfree(), the original object will be used by another
>>> pointer, if we use object itself to determine use-after-free issue, then
>>> it has many false negative cases. so we create a lite quarantine(ring
>>> buffers) to record recent free stacks in order to avoid those false
>>> negative situations.
>>
>> I'm telling that *more* than one free stack and also tags per object can be stored.
>> If object reused we would still have information about n-last usages of the object.
>> It seems like much easier and more efficient solution than patch you proposing.
>>
> To make the object reused, we must ensure that no other pointers uses it
> after kfree() release the pointer.
> Scenario:
> 1). The object reused information is valid when no another pointer uses
> it.
> 2). The object reused information is invalid when another pointer uses
> it.
> Do you mean that the object reused is scenario 1) ?
> If yes, maybe we can change the calling quarantine_put() location. It
> will be fully use that quarantine, but at scenario 2) it looks like to
> need this patch.
> If no, maybe i miss your meaning, would you tell me how to use invalid
> object information? or?
> 


KASAN keeps information about object with the object, right after payload in the kasan_alloc_meta struct.
This information is always valid as long as slab page allocated. Currently it keeps only one last free stacktrace.
It could be extended to record more free stacktraces and also record previously used tags which will allow you
to identify use-after-free and extract right free stacktrace.

