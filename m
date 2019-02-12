Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B9F5C282CA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 12:14:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E640220842
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 12:14:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E640220842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BE898E0015; Tue, 12 Feb 2019 07:14:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 545758E0014; Tue, 12 Feb 2019 07:14:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40ED98E0015; Tue, 12 Feb 2019 07:14:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id CBA428E0014
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 07:14:25 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id n4so287572lfl.20
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 04:14:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=l/u2+gdRm2cvDk2NbZLG0vHLqMXF0HF+jEi5Dv4VYIY=;
        b=hC/xLYDUbvCqJJBEC7wrtdN44cCpj06jdhEr/82juW0N+kSTfeLUdQOl3xidk1ceDp
         DGSRg5V8EREm3et+xbuQR5FiU7Pa7wj0MT6RmxQYYAjlZRhwnR4yy6T23tIP6eZRjcq8
         2kozYWQ96PxHoeh1FpVG7UNBSc59KFxb4TTzoE0DWIr2LUHHkqQyDRjHuaPS5rPFpFdn
         YtxKnEi0IrDlN5loSxx7oJQpBb5LxlAD18tvLegM5fnil05N9gYp0Obpy7i+p6SC2jP7
         NXAYum8+Mya8sTGUCt2sSTg2oLg96mHVQn4YdGfjlFh5cssVFmHp21GvpbHJGNol8kX/
         94wQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAuYw4Q7N9YD03Yu2E5SiXcC6tJHlo8eMpP15m8feYHIxrnd18Hq1
	Lo3YI1yXIzWc4dvvHilIU82aq+Z25aP0gqsJPWcs3UNDhjQMc/p8SbxuAjIXX7en1qbWYC+KEIJ
	rCZpGndEqNjvjvUDwRtx7ePIkJoeUm31zGZEaqjvM7f7mIucP0GK7goIZhSRIGFA8Ww==
X-Received: by 2002:a2e:5854:: with SMTP id x20-v6mr2149738ljd.31.1549973665024;
        Tue, 12 Feb 2019 04:14:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZfeCofHnApJ9DGqtzXKlucFAnVQDBQrJjxv1cWORURZp3RwDfbe6yrf/T65cd1oax33Xq2
X-Received: by 2002:a2e:5854:: with SMTP id x20-v6mr2149701ljd.31.1549973664111;
        Tue, 12 Feb 2019 04:14:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549973664; cv=none;
        d=google.com; s=arc-20160816;
        b=QYjaSCk7u6IX3RAWOD2ej3l4Iww1PNDngAMyHr5c2S9hp+fHjMvcDyT/MtsHbWlQS4
         KjtmXv0nCEEsBEm4VAhwRyfBUnh2QXwRdS6DVzEw0r4WFRoGVIdJ445a3wrcBXJRrbjF
         fWTT4F8ijhZa6DD3qUKl5CsnQaGvYZVTp6w7JHW9ABgcrqyF/7nYnujA0iO2uMqJ82EB
         5nHOBY6IIkaJUX3f45YlFL3X2bi6I/D2ZeJFslFTjRLEVYsvJOQnA9iPFaRkUz9CV+gf
         0Bf54SKaEyBoK4xcZbd2KCteRc0bKUNZv/ASNFwhJftugZyb3xWCUqt6R3vlvM9b5bNg
         TMnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=l/u2+gdRm2cvDk2NbZLG0vHLqMXF0HF+jEi5Dv4VYIY=;
        b=a0STAc/IDfv+p3vNVue359IpGAbGudZR2xR3CazXQxeBiwQsrfsVNTVA3q22g5oxFa
         JSTQI0RnELyWsaOQcusqVd3VRMAa8/pLRKE1eMIA12VfquBUoHurI3nlFLAhBlFb2/OD
         V1LEq6Gn73EUhixqEf5pkKmii7uVc53C/EgPv85SvOrjRyCgBh6TPUtExoOum5x1f13x
         ImyUOU7isvM92IhJqXHXjoCkPpyZSS6I1fiFYvxlKyQBKrS0W92BUOfF1YihywdLzyIR
         oR0Pyd1m8tH48bpj6Z5YsOf60FMx7JwPOoX335Ar4mFWxg8Np9ntV3OGpmlRQDfQ+C5J
         ZS2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id x17-v6si12102473ljx.97.2019.02.12.04.14.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 04:14:24 -0800 (PST)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1gtWx9-000831-M1; Tue, 12 Feb 2019 15:14:19 +0300
Subject: Re: [PATCH v4 3/3] powerpc/32: Add KASAN support
To: Christophe Leroy <christophe.leroy@c-s.fr>, Daniel Axtens
 <dja@axtens.net>, Andrey Konovalov <andreyknvl@google.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Nicholas Piggin <npiggin@gmail.com>,
 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 Linux Memory Management List <linux-mm@kvack.org>,
 PowerPC <linuxppc-dev@lists.ozlabs.org>, LKML
 <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>
References: <cover.1548166824.git.christophe.leroy@c-s.fr>
 <1f5629e03181d0e30efc603f00dad78912991a45.1548166824.git.christophe.leroy@c-s.fr>
 <87ef8i45km.fsf@dja-thinkpad.axtens.net>
 <69720148-fd19-0810-5a1d-96c45e2ec00c@c-s.fr>
 <CAAeHK+wcUwLiSQffUkcyiH2fuox=VihJadEqQqRG1YfU3Y2gDA@mail.gmail.com>
 <f8b9e9ec-991b-6824-46c2-f7fc0aaa7fb8@c-s.fr>
 <CAAeHK+zop5ajOJQ4KEYbuxMRegk2GM1LvuGcSbCU1O5EZxB0MA@mail.gmail.com>
 <805fbf9d-a10f-03e0-aa52-6f6bd16059b9@virtuozzo.com>
 <87imxpak4r.fsf@linkitivity.dja.id.au>
 <a11adaf3-beda-ed0c-e6aa-9ef30f2e80cf@c-s.fr>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <c5599614-128b-69a8-2526-72b135070e8d@virtuozzo.com>
Date: Tue, 12 Feb 2019 15:14:40 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <a11adaf3-beda-ed0c-e6aa-9ef30f2e80cf@c-s.fr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/12/19 2:38 PM, Christophe Leroy wrote:
> 
> 
> Le 12/02/2019 à 02:08, Daniel Axtens a écrit :
>> Andrey Ryabinin <aryabinin@virtuozzo.com> writes:
>>
>>>
>>> Christophe, you can specify KASAN_SHADOW_OFFSET either in Kconfig (e.g. x86_64) or
>>> in Makefile (e.g. arm64). And make early mapping writable, because compiler generated code will write
>>> to shadow memory in function prologue/epilogue.
>>
>> Hmm. Is this limitation just that compilers have not implemented
>> out-of-line support for stack instrumentation, or is there a deeper
>> reason that stack/global instrumentation relies upon inline
>> instrumentation?
> 
> No, it looks like as soon as we define KASAN_SHADOW_OFFSET in Makefile in addition to asm/kasan.h, stack instrumentation works with out-of-line.
> 


I think you confusing two different things.
CONFIG_KASAN_INLINE/CONFIG_KASAN_OUTLINE affects only generation of code that checks memory accesses,
whether we call __asan_loadx()/__asan_storex() or directly insert code, checking shadow memory. 

But with stack instrumentation we also need to poison redzones around stack variables and unpoison them
when we leave the function. That poisoning/unpoisoning thing is always inlined. Currently there is no option to make it out-of-line.

So you can have stack instrumentation with KASAN_OUTLINE, but it just means that checking shadow memory on memory access will be outlined,
poisoning/unpoisoing stack redzones will remain inlined.

