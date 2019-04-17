Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1779C10F12
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 09:54:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90D982173C
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 09:54:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90D982173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F38076B0003; Wed, 17 Apr 2019 05:54:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBE106B0006; Wed, 17 Apr 2019 05:54:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D5FF46B000D; Wed, 17 Apr 2019 05:54:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 860246B0003
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 05:54:45 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d2so12139686edo.23
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 02:54:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=qvuMHqjt5eIikGlxaz5PCzs1JMVGU+bv+a2QIRZepzk=;
        b=gRYIv7NH7Nn2tzZ9rv1xUeV0iOS1ckqWwdIvw2qJzPlphHoWfdRkNRaMnV7WBsaFGZ
         0tGr0iOlw9FTfjt6fgJSCeHeOWjXGQ94fuTnwPHqapnw//b5EfUhCffqUGre+4FPNCmq
         JBhfd5Mwqc2JAnOUGPWYugtmKi2lvX1ly+1hBO1iEnwsVDdfv+iRIT3EoXdPcHaM+Pze
         ys1L1wanAU+/HQHqwgxWrRRwSpwbSu2ZSRhbsaLmQdfCMDWEQnJ0GHsOjXLe+35Q/F4A
         xIU6IlHxKXgH8BqHJk4yLPWG5W9BvogPa3b/nI3A3SuPcTrC8mMeAyqO4wy24YHJ8HO7
         MwrA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAXi7G08vdvDq68wIjy4u/8jXs1ePdFlr2NNJhTk1GAKp0HO+Gtk
	EBX6H4Z0g2Zogjg71XYk9K+qKTiFJP6aagFFqxx/F4xgMJtc0ocX57jLyNsf2KN+aPFe/b6JYeU
	XYBCzG1m2dFnF7p//qmGPAO3F9sEVYvR+eZITuNP/cH8ZRk951WSPRJ6N4lDSHwTPCw==
X-Received: by 2002:a50:cb06:: with SMTP id g6mr37357105edi.89.1555494884997;
        Wed, 17 Apr 2019 02:54:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxckmnzjYsGo329JQ39kaJJyE4Au5YyblWo7YuAqL6nAd4n+16fszECv5iQ/nLPIwV09Ray
X-Received: by 2002:a50:cb06:: with SMTP id g6mr37357069edi.89.1555494884243;
        Wed, 17 Apr 2019 02:54:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555494884; cv=none;
        d=google.com; s=arc-20160816;
        b=cSUVRmXntmva4FjjU4IcUgU7KGd1kd6Ek3/jHJi22nBbJebt1UKzeUjErxImkMJHD6
         cW/Ftb00ldR26WPEjWnKTKxUygyX/O2jtrapu1uohVohIBHJwk+YKzMHwIvULyCQdemx
         WxDxv/VsVR1XyYP+3PXaNSHXfSYNmyOzBy2fdpYU8jV+hyCGMje60xOMmlKzIX5XtYST
         TuK6li+NGm8u2jvT/Fycdhlgt1sfUjbv+dTRbfWXm8VnfV1i+RgGvJErB8mzw9prJam0
         OFWNJFEZA8P5yungTevjEFp89KaS+32MuM0K6WzM1HDR9fRsFOX6GmrI8c7xEACxxAEN
         NLWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=qvuMHqjt5eIikGlxaz5PCzs1JMVGU+bv+a2QIRZepzk=;
        b=IEJQYS6j/1ZnXbK3KtElVJlwSMqGBq2Sp/0TQ1y9xcqsKG0VRiYnOXXsrteggQJTqh
         /6K9ONb8Veuus3FfipgVbcPgD/LXzeA16vpmG/9CWROPm+YTn0xukcBipj4vVg5oKqjY
         63dZGg1fqzyviZDQfBY+mnkcRLvHxpczJg7h0N+/MIEYw8uMAnzYMxmqam/RFNxRYKun
         7FRweTMpRkm5wzsPBDxuMo37STnyv1oZJh7/IpS/G0TvIV4uqF4f6BrYN6i5oSCnZp8S
         92m+Abrzc0U44ZAtTbR87EnAbt4gIZY216Hac/WKSTxzO1USTp1GA9NQ/jCFkBg6q/St
         5CoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l15si7175231eje.246.2019.04.17.02.54.43
        for <linux-mm@kvack.org>;
        Wed, 17 Apr 2019 02:54:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E5637374;
	Wed, 17 Apr 2019 02:54:42 -0700 (PDT)
Received: from [10.1.196.75] (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A992B3F68F;
	Wed, 17 Apr 2019 02:54:40 -0700 (PDT)
Subject: Re: [PATCH] crypto: testmgr - allocate buffers with __GFP_COMP
To: Russell King - ARM Linux admin <linux@armlinux.org.uk>,
 Matthew Wilcox <willy@infradead.org>
Cc: Kees Cook <keescook@chromium.org>, Rik van Riel <riel@surriel.com>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 Eric Biggers <ebiggers@kernel.org>, Linux-MM <linux-mm@kvack.org>,
 linux-security-module <linux-security-module@vger.kernel.org>,
 Geert Uytterhoeven <geert@linux-m68k.org>,
 linux-crypto <linux-crypto@vger.kernel.org>,
 Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@redhat.com>,
 Linux ARM <linux-arm-kernel@lists.infradead.org>,
 Herbert Xu <herbert@gondor.apana.org.au>
References: <20190411192607.GD225654@gmail.com>
 <20190411192827.72551-1-ebiggers@kernel.org>
 <CAGXu5jJ8k7fP5Vb=ygmQ0B45GfrK2PeaV04bPWmcZ6Vb+swgyA@mail.gmail.com>
 <20190415022412.GA29714@bombadil.infradead.org>
 <20190415024615.f765e7oagw26ezam@gondor.apana.org.au>
 <20190416021852.GA18616@bombadil.infradead.org>
 <CAGXu5jKaVB=bTJCBWhsxAny7-OkzXQ+8KCd5O+_-7hKcJFiqKw@mail.gmail.com>
 <20190417040822.GB7751@bombadil.infradead.org>
 <20190417080919.54wywpzrt3psn4vj@shell.armlinux.org.uk>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <0ea51c23-d285-25c3-80d6-f3c0045ee325@arm.com>
Date: Wed, 17 Apr 2019 10:54:39 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190417080919.54wywpzrt3psn4vj@shell.armlinux.org.uk>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 17/04/2019 09:09, Russell King - ARM Linux admin wrote:
> On Tue, Apr 16, 2019 at 09:08:22PM -0700, Matthew Wilcox wrote:
>> On Mon, Apr 15, 2019 at 10:14:51PM -0500, Kees Cook wrote:
>>> On Mon, Apr 15, 2019 at 9:18 PM Matthew Wilcox <willy@infradead.org> wrote:
>>>> I agree; if the crypto code is never going to try to go from the address of
>>>> a byte in the allocation back to the head page, then there's no need to
>>>> specify GFP_COMP.
>>>>
>>>> But that leaves us in the awkward situation where
>>>> HARDENED_USERCOPY_PAGESPAN does need to be able to figure out whether
>>>> 'ptr + n - 1' lies within the same allocation as ptr.  Without using
>>>> a compound page, there's no indication in the VM structures that these
>>>> two pages were allocated as part of the same allocation.
>>>>
>>>> We could force all multi-page allocations to be compound pages if
>>>> HARDENED_USERCOPY_PAGESPAN is enabled, but I worry that could break
>>>> something.  We could make it catch fewer problems by succeeding if the
>>>> page is not compound.  I don't know, these all seem like bad choices
>>>> to me.
>>>
>>> If GFP_COMP is _not_ the correct signal about adjacent pages being
>>> part of the same allocation, then I agree: we need to drop this check
>>> entirely from PAGESPAN. Is there anything else that indicates this
>>> property? (Or where might we be able to store that info?)
>>
>> As far as I know, the page allocator does not store size information
>> anywhere, unless you use GFP_COMP.  That's why you have to pass
>> the 'order' to free_pages() and __free_pages().  It's also why
>> alloc_pages_exact() works (follow all the way into split_page()).
>>
>>> There are other pagespan checks, though, so those could stay. But I'd
>>> really love to gain page allocator allocation size checking ...
>>
>> I think that's a great idea, but I'm not sure how you'll be able to
>> do that.
> 
> However, we have had code (maybe historically now) that has allocated
> a higher order page and then handed back pages that it doesn't need -
> for example, when the code requires multiple contiguous pages but does
> not require a power-of-2 size of contiguous pages.

'git grep alloc_pages_exact' suggests it's not historical yet...

Robin.

