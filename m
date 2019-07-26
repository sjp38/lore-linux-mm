Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34E24C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 12:52:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0C1F2238C
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 12:52:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0C1F2238C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9ADDA6B0005; Fri, 26 Jul 2019 08:52:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95EC66B0006; Fri, 26 Jul 2019 08:52:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8756D8E0002; Fri, 26 Jul 2019 08:52:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1C1366B0005
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 08:52:15 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id e20so11616674ljk.2
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 05:52:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=+E2gPxrIouv9oSF6tb6T+yMioGcNKU3BukFFMkra0WE=;
        b=eNxJuXzfOKcThMAxrswh/vB75qbVqbuv26tD5JmJsJBo/bp0XLnqr6jQnepTMuWeg0
         sIRsvUjsYp7QriIej92PCcHOFGgWywEfXxF68Cp5lC62jA8zbvs2GWZmlos8uwbIHV/K
         8VPkG/wfQDzeuwbzg6/OYBlsRdgnIObtShebgGuZVbA1wBOMzF+a4eX/EEXwUzNgX2h2
         xfJdn73XrGxapXmG7NRemkwsTCPGr9s3m5df3UenSMhKwiqq8z7bngGvf62ptHpYRHJs
         FRzoHyeU6oe7X8EjAiOGB6Sg4xM6Owo9Cq5kyB4tOADMDawGx3BJCUGVmoQLjYJsJMVE
         SLqQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAWLgTdgjql2+UMt8fu8KT9h9TYPBUBOCFP2OZSH0ls3UNB2pNBt
	bM/LGtuyNHzq3Y5KndvY1CNASUZnyc4PeBdlc5Ng07p6sLIfISa5COSwgIP6Am5nSZkYunlzLP6
	M6u+/IvNdA7vLPO68/6YMFBv4Quijk9wHUf4k2+GRZ7cHf8c/25e277jaDTuyyrTOQQ==
X-Received: by 2002:ac2:5225:: with SMTP id i5mr44023904lfl.157.1564145534404;
        Fri, 26 Jul 2019 05:52:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyh8ybIsfoq2b9Hh+XFJLgbFWWtzRGZwstvsfM1dz4+swBWz/WbZZlhza1mczZheYHLit92
X-Received: by 2002:ac2:5225:: with SMTP id i5mr44023884lfl.157.1564145533693;
        Fri, 26 Jul 2019 05:52:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564145533; cv=none;
        d=google.com; s=arc-20160816;
        b=c6viarpdhy6YcryfK8UMwxvYTgqjMMgkwfjYFuGtP672SofmKuAStqIeIn3X/ifPL5
         gbmXJcpojy7sE42ZiIW94VJlOwbx3WzYdF1qhRMBPSTHYjIj2JNyjSdY2YgUuG5al5m1
         aUU/zowM8+rTZ+M3EPV9LXF63QAudQDzxP393fyiC2hFIQwrnK3H+14Gl/KFkn59kvRG
         vVpKJyP0V8AJ5dlPVAUwm+OiCIYhRkhhra7LKSuyMs5dqVYzoKMHxz3QfXlH6VZlIUm4
         BK1LEA85wR9/rrOqL+4+3fPjed5/w5DmL1feFoClrKK5jH4y/OEPgYRM7zW0/QDWX2sS
         Eh8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=+E2gPxrIouv9oSF6tb6T+yMioGcNKU3BukFFMkra0WE=;
        b=TsUCrctDOPBFw6oLSLfOeW6qOaIzSPc/B1do+QrAegUmmb4B7TaSSxa9lncErLwyMG
         5ksa9WCBqJxz5ndT7kfyvnidzv/ZbCHIfUwq0VIlv2M58vEeQ/6bdTAK2v+cUmJiERkt
         PHXC3HkvjOHeaJhoSZge1KeMDH+PrySwfihHqoTOA5DmghUdP2M2MX6wjWp7Ez+qIKMS
         F9HOTtBSrwGg7EA/vbh4T0lu4waRMRPaXrHN6RUBomb465J7owySmW7YJZFYWGuyR92h
         hZOnf1NT6NUZxM8gQt28pa8zjc3lzJUj9L4b6eW42+TRhddNHnsk6e3ePGCNZ5JYhigs
         LEyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id e16si45307995ljh.141.2019.07.26.05.52.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 05:52:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.92)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1hqzhc-0007Xf-H3; Fri, 26 Jul 2019 15:52:04 +0300
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
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <71df2bd5-7bc8-2c82-ee31-3f68c3b6296d@virtuozzo.com>
Date: Fri, 26 Jul 2019 15:52:10 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <1564144097.515.3.camel@mtksdccf07>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/26/19 3:28 PM, Walter Wu wrote:
> On Fri, 2019-07-26 at 15:00 +0300, Andrey Ryabinin wrote:
>>
>
>>>
>>>
>>> I remember that there are already the lists which you concern. Maybe we
>>> can try to solve those problems one by one.
>>>
>>> 1. deadlock issue? cause by kmalloc() after kfree()?
>>
>> smp_call_on_cpu()
> 
>>> 2. decrease allocation fail, to modify GFP_NOWAIT flag to GFP_KERNEL?
>>
>> No, this is not gonna work. Ideally we shouldn't have any allocations there.
>> It's not reliable and it hurts performance.
>>
> I dont know this meaning, we need create a qobject and put into
> quarantine, so may need to call kmem_cache_alloc(), would you agree this
> action?
> 

How is this any different from what you have now?

