Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87AF7C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:20:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 554EF21019
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:20:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 554EF21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 045166B026D; Wed, 12 Jun 2019 13:20:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F38906B026E; Wed, 12 Jun 2019 13:20:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DFF5F6B026F; Wed, 12 Jun 2019 13:20:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id B4DC86B026D
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 13:20:48 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id a198so5727766oii.15
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:20:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=iZ8K6R0putn6ncHt26atrOoAgAL+7/vF31xtELMSfnM=;
        b=HkndZTo8FcWoUwMW1+ScZj0/ZVMguYS+ZIxHW83i/KunmnCzLmsJA8FBgoV4ubyxDK
         WLbRzlCrS2ciiFHb0V/05HZ0lnNWvSwuxWVe/QbUOOd9eMepZfbsYUqtSn9cbmavq0ou
         f5ZeLlR+9TAhzyOMasnzLi8q5t0Iac5emAkuwBx6723HgeN7zuq0emBJhMt3BEM764/A
         JaFKLk/lVPFlflFMdIqB+0NRsgemL9QGuOG3v5Ls/bAiMZ4Dy2D/zJJJqRGH1XrHvms4
         BeHXNj0LxyKVgYztqVqRdpibPhT+Eb/+bjDMKHxuWgkd75X6kjJ2r8Ky9VKkZku/hLpn
         pZSw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXmUNdUu1w4qidAniinWIXnWbsGNugOuoIugqMRT49pKwoBelNq
	s27SUT5kCqdYNeWhe+nBqwVq5MYOEcMuroNrqqo/3U646/wgnvbzoCNqNTXzAQjm39z7UuPN5BI
	Vs8CpON4RlcHYg42fX2aKNLRnN9KARRJR6kScb/2D4XDQ89divXrcjvagdsQhKJ0EZA==
X-Received: by 2002:aca:b8d7:: with SMTP id i206mr190428oif.25.1560360048040;
        Wed, 12 Jun 2019 10:20:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw8VTX/d0hbgfDw+ac/nib96JMO5yPocp+lxRMe6c52JdbzMifwTtfhp7wbLd/gM3UWRvSW
X-Received: by 2002:aca:b8d7:: with SMTP id i206mr190401oif.25.1560360047463;
        Wed, 12 Jun 2019 10:20:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560360047; cv=none;
        d=google.com; s=arc-20160816;
        b=YuyeBTCG7+LffAmy61Jvq4eWMG1VielU0OyiQ1ZVfpRzZY5u5TvxD3BRv/v7WLRFfW
         xRk8UgeZaz7BoM6xVOFbwshBapijCckmOrN7NcHEmylsVTH1uT6lwuipLgyxk12VFGKE
         T2aRKM0TLcDOEDEMw7vnz7iEBUab4hNATcXDmqs6KFz1MtzsgBeJ+HtKzV2N3k4uJZN8
         wVvMZYGr/+wN0Fp59mtwoGDDwn2Nxc2jIVEhgWYHnb+3qlUzOzs6BsMZnbRSO7pHFn7d
         lEW8MeHSEa/HuvjvbOIUi4QaNUHpS0gq9JEWJHSOjWzQogXPOp0BYQ4WOh2D6660ew3h
         H6gg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=iZ8K6R0putn6ncHt26atrOoAgAL+7/vF31xtELMSfnM=;
        b=iWljxY5+3+/ASJ54QSRxr/qz1m+Q9jFK1j9/z5LaeiNGQyb+867smPUH3NO4bFwujY
         1dQm2MXI05us2g7UH+SNO5fgvRNGQLv4TNum2biTeLmDOOd4DdYJclLSj0MNln7MVsWq
         EOsA0sKuOcyrDp9tmAfeHuOStCr50SNo3bg6JYw8pONMvLjIda5gqVXk3OlTm2n10EaF
         wgMqCGRuoSze2ZWtRoq/3B5vnC1n76MGS3lW/SxJ4zitcw79/ZGbzpNL/9UYlCFlM6Fd
         PL++Jhhbk9V67sl7lTNZG/duKH4rrAxeZJJzqUCclJCqHO1gKuCK20jXvEPKpEfTB/1x
         NJEw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com. [115.124.30.54])
        by mx.google.com with ESMTPS id v16si210775otq.13.2019.06.12.10.20.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 10:20:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) client-ip=115.124.30.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R361e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0TU.Zjat_1560360018;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TU.Zjat_1560360018)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 13 Jun 2019 01:20:22 +0800
Subject: Re: [PATCH 4/4] mm: shrinker: make shrinker not depend on memcg kmem
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: ktkhai@virtuozzo.com, kirill.shutemov@linux.intel.com,
 hannes@cmpxchg.org, mhocko@suse.com, hughd@google.com, shakeelb@google.com,
 rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1559887659-23121-1-git-send-email-yang.shi@linux.alibaba.com>
 <1559887659-23121-5-git-send-email-yang.shi@linux.alibaba.com>
 <20190612025257.7fv55qmx6p45hz7o@box>
 <a8f6f119-fd72-9a93-de99-fc7bea6404c0@linux.alibaba.com>
 <20190612101104.7rmjzmfy5owhqcif@box>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <aa4fd2f3-daf4-3c25-8f51-1527db8f743b@linux.alibaba.com>
Date: Wed, 12 Jun 2019 10:20:15 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190612101104.7rmjzmfy5owhqcif@box>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/12/19 3:11 AM, Kirill A. Shutemov wrote:
> On Tue, Jun 11, 2019 at 10:07:54PM -0700, Yang Shi wrote:
>>
>> On 6/11/19 7:52 PM, Kirill A. Shutemov wrote:
>>> On Fri, Jun 07, 2019 at 02:07:39PM +0800, Yang Shi wrote:
>>>> Currently shrinker is just allocated and can work when memcg kmem is
>>>> enabled.  But, THP deferred split shrinker is not slab shrinker, it
>>>> doesn't make too much sense to have such shrinker depend on memcg kmem.
>>>> It should be able to reclaim THP even though memcg kmem is disabled.
>>>>
>>>> Introduce a new shrinker flag, SHRINKER_NONSLAB, for non-slab shrinker,
>>>> i.e. THP deferred split shrinker.  When memcg kmem is disabled, just
>>>> such shrinkers can be called in shrinking memcg slab.
>>> Looks like it breaks bisectability. It has to be done before makeing
>>> shrinker memcg-aware, hasn't it?
>> No, it doesn't break bisectability. But, THP shrinker just can be called
>> with kmem charge enabled without this patch.
> So, if kmem is disabled, it will not be called, right? Then it is
> regression in my opinion. This patch has to go in before 2/4.

I don't think this is a regression. "regression" should mean something 
used to work, but it is broken now. Actually, deferred split shrinker 
never works with memcg.

Anyway, either before 2/4 or after 2/4 looks ok.

>

