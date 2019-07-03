Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5629C06511
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 14:10:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96A3921881
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 14:10:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96A3921881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 306AA6B0006; Wed,  3 Jul 2019 10:10:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28E338E0005; Wed,  3 Jul 2019 10:10:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 157CC8E0003; Wed,  3 Jul 2019 10:10:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BC1DC6B0006
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 10:10:45 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i44so1803774eda.3
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 07:10:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=cwszHtW+mIPivSs6sbnbs4LhP5LT3yq9wBgQjqfg+UQ=;
        b=ZVT3jsbDoZLabRQdK5W0TUQ/nYyeF1cMeF4G0GGLFPK7Lr8oa/zZMCeblidrtUH24g
         c8rGTorxac/uIJRsLtD0p29zSHkqGzDjlvC1ScmxcJpzHEdxu7EwaJpZj14bnRQbaqhm
         k8yfgvzXAVWEodPrAsNGDFEOR6UyV6TzM2LSWMR8EU5H7SXRw6YKQgJXU4QjRl/CGcMu
         O7t/fcZYLneDXb3gxlmitYL9V/vUH3/cIlIfMbASEAHNnt15PQKIZ/2v40q9GSQWl7q8
         TZPjMMGhnsTcuQ192ynizTYpg4QECLrWGmvXq2silyjopPiSjnCmDvdxnECmnr0dZbgm
         Weig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWEhqLx9frXUNQsDqeb6AGCQYaTzA3ASRFj6FhylV4DRSzgzzdr
	fgQpFSf5Fe7rc7z6ubNMcJlTMusiKJDUCFKQyOydNAtMMSQ8aN33yXbcY/jaPjcQRp3rMfJsXNJ
	HYg0Br7tm1XGxAQyeOCXAXtQxs8HVCwUSlMIOMlsdvZnwsH2umUh9akm8nV3yVnMksw==
X-Received: by 2002:a17:906:1e04:: with SMTP id g4mr34670677ejj.48.1562163045346;
        Wed, 03 Jul 2019 07:10:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyszLQdkHEJHC4Rn/B2p5Pm3olQOnWx1kEUN0gqrzYnSwlhsdu5AfLHC9YJV60B5PWkWaMO
X-Received: by 2002:a17:906:1e04:: with SMTP id g4mr34670602ejj.48.1562163044506;
        Wed, 03 Jul 2019 07:10:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562163044; cv=none;
        d=google.com; s=arc-20160816;
        b=qmmoG3JNAnlHIZD4Q0fDQAlfEega+WlQOhNw/RRHdjhy5MEUeKr4xW0dNwcqfiIxkW
         SKCfFz6ZDQCkO3lJor6/2LpQ1PmRad3jz1QbORuimQz8uvB2iDvt4a53CfAh74T4FrMy
         owMW53NQw68H8xSluxuijrE4iE85AAtRO2RR69uqn0SoaIZk/F5So3SGhrC8yoXKBfxS
         WsF4KM5OQQ7U2VyyzlUDVjJ1+8son586pmSd6asBBeY//hJ9yUq7QJTWMCcKfKOoywYD
         VjP+Hg3rdA+7C9C8Riv4efGo1927e90w1Ckc17CTTtCvzhKVjhGShxzkLE4FYeHjW78q
         KCAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=cwszHtW+mIPivSs6sbnbs4LhP5LT3yq9wBgQjqfg+UQ=;
        b=0hOG94roCaC0QZ5bgUavi6yaMS8m1bR6XHqVeMGEoFJzszY3iEwpXfq9WMivTnYUYz
         kpn0quwEvHKB1qWHRWWfa1tuApZ4anwrKooIFJxA2ttbhnwKnWUDTZEgsPdm4kP70TbV
         hyu3/tOAoBDLwa9LNosAEbsqrBbda+q3P+YBP+R1u1y0iRBkPjMC508sGG2cfq1UEyU3
         G+Z0XU9QJ8JMzO+5oDCybFtTtks2mR4+Sf+W8Z8Asq5ZlbILcMUlzn4sjn9lWnBbInDj
         2flWG8vPud5X5Ew/ko9PSGkmJX546I737kcB7L8KTOvxuLJhps0cGkgIAE3X6zf5eYew
         o9qg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id z44si2224377edb.16.2019.07.03.07.10.44
        for <linux-mm@kvack.org>;
        Wed, 03 Jul 2019 07:10:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9B3752B;
	Wed,  3 Jul 2019 07:10:43 -0700 (PDT)
Received: from [10.162.42.95] (p8cg001049571a15.blr.arm.com [10.162.42.95])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 15DD03F718;
	Wed,  3 Jul 2019 07:10:41 -0700 (PDT)
Subject: Re: [DRAFT] mm/kprobes: Add generic kprobe_fault_handler() fallback
 definition
To: Guenter Roeck <linux@roeck-us.net>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org
References: <78863cd0-8cb5-c4fd-ed06-b1136bdbb6ef@arm.com>
 <1561973757-5445-1-git-send-email-anshuman.khandual@arm.com>
 <8c6b9525-5dc5-7d17-cee1-b75d5a5121d6@roeck-us.net>
 <fc68afaa-32e1-a265-aae2-e4a9440f4c95@arm.com>
 <8a5eb5d5-32f0-01cd-b2fe-890ebb98395b@roeck-us.net>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <a0a0e277-ec1a-6c49-4852-c945ad64a1fd@arm.com>
Date: Wed, 3 Jul 2019 19:41:08 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <8a5eb5d5-32f0-01cd-b2fe-890ebb98395b@roeck-us.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 07/03/2019 06:29 PM, Guenter Roeck wrote:
> On 7/2/19 10:35 PM, Anshuman Khandual wrote:
>>
>>
>> On 07/01/2019 06:58 PM, Guenter Roeck wrote:
>>> On 7/1/19 2:35 AM, Anshuman Khandual wrote:
>>>> Architectures like parisc enable CONFIG_KROBES without having a definition
>>>> for kprobe_fault_handler() which results in a build failure. Arch needs to
>>>> provide kprobe_fault_handler() as it is platform specific and cannot have
>>>> a generic working alternative. But in the event when platform lacks such a
>>>> definition there needs to be a fallback.
>>>>
>>>> This adds a stub kprobe_fault_handler() definition which not only prevents
>>>> a build failure but also makes sure that kprobe_page_fault() if called will
>>>> always return negative in absence of a sane platform specific alternative.
>>>>
>>>> While here wrap kprobe_page_fault() in CONFIG_KPROBES. This enables stud
>>>> definitions for generic kporbe_fault_handler() and kprobes_built_in() can
>>>> just be dropped. Only on x86 it needs to be added back locally as it gets
>>>> used in a !CONFIG_KPROBES function do_general_protection().
>>>>
>>>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>>>> ---
>>>> I am planning to go with approach unless we just want to implement a stub
>>>> definition for parisc to get around the build problem for now.
>>>>
>>>> Hello Guenter,
>>>>
>>>> Could you please test this in your parisc setup. Thank you.
>>>>
>>>
>>> With this patch applied on top of next-20190628, parisc:allmodconfig builds
>>> correctly. I scheduled a full build for tonight for all architectures.
>>
>> How did that come along ? Did this pass all build tests ?
>>
> 
> Let's say it didn't find any failures related to this patch. I built on top of
> next-20190701 which was quite badly broken for other reasons. Unfortunately,
> next-20190702 is much worse, so retesting would not add any value at this time.
> I'd say go for it.
> 
> Guenter
> 

Sure thanks, will post it out soon.

