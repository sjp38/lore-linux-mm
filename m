Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7EE0C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 17:21:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81AB022BF5
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 17:21:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81AB022BF5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 183236B0006; Thu, 25 Jul 2019 13:21:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 135886B0007; Thu, 25 Jul 2019 13:21:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04AB58E0002; Thu, 25 Jul 2019 13:21:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id C47866B0006
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 13:21:19 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d2so26689839pla.18
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 10:21:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=e4m6puvB10EHfZzDVgE/4cPEhExXNSF5xqCUc7jJOlE=;
        b=bri7z7MvRmOT/SK6KlCodhWDBaYhXDP8MK0MlMiNZ1Rhf+wyKhL2sfYL1dAV12qo9V
         39WqpJqRJSTdY5IGPuhq1Quh5nmUyOBl9sA7GAnoxSkbZsHsvc74WPUGo9G8qCsaF3E4
         ZKnaCa9kefPpZNPXTlKo796vSGn90xgsOuy7ZDn7SuyUhn4f2xguWWgcPF141zsccB0p
         /hxHekja7Npj6QJb1RO56CyYXNQnmIkGUJXaWSiHYBzyuv5ZZmk8s5sf+4f1ObSnHNJ9
         Had6F5ZH6OO0Wrax8tQ7K8UO3Xltg4iB2etVRuLqWd9nnb+wbs47Io0M8dOyNJiwM8wY
         0KvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVAbMKFrLHGyCL6/GQeDXq0jkpYavlxRbY0H7xGO9VVFw3MPtrQ
	pSXfrR9/EAalB2ejUbgAZpTlO12bqovVjJgqtBErNeJ9PcnWdBH1MNZ+vX8Wu4ksQOuTwhYndnb
	l3AB1igmLeedP7e8h+r5TDRVd0O3YHqnhF3aWKYaj187t1BDfwyY7M/UEB107vNcChA==
X-Received: by 2002:a17:902:2aab:: with SMTP id j40mr40726234plb.76.1564075279317;
        Thu, 25 Jul 2019 10:21:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyaDi+jg5hZZ2CBYrhGftDZty9IaZEZxV1KzWvJGoHfLb/Uw4x8qOc3TcYUKiFD+skKKeId
X-Received: by 2002:a17:902:2aab:: with SMTP id j40mr40726201plb.76.1564075278511;
        Thu, 25 Jul 2019 10:21:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564075278; cv=none;
        d=google.com; s=arc-20160816;
        b=OYVB9xzh2uc+oKgLTyn0zkvyLfsnoP/FPt2fhKo9teqgybGXDtPuLahQL86cyrH0Iq
         IRzjLLduSnTvHPDWNHnmxXZC36GJloG/Y83jeKLeVa9QN+KJsU0No1IwAMNqJXLXv3/w
         uURhel8gCBiRzWW/ohViz31olxMagCTqMudRHoZILMXuMsGojMLHARV3aJYxr5D/LLEA
         8xo11D/TzkuB6RHTE3ipjGy6+HSYivgDX5L3VBW90fcheHFrUZAQidxT0j3Rev70xvd2
         lojIL78MKG4mmIXN/h06TO31Tt0zVKyTMPwq1aRobjb29Sc2nTSMJBo7wZyPHyoUX8RV
         KUKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=e4m6puvB10EHfZzDVgE/4cPEhExXNSF5xqCUc7jJOlE=;
        b=sSxNvisGozD46ErwVoZa/f0Ru0OiAs400uN14srIQt9fCTwskwegfpiJmzoXtghEQO
         5t7MBUikud5SerRbHThhFsl1Zm5z/tmEkpqxbnRPHvxZ+vPYlaxBjHGFi1VMvjEYcae3
         IvTYFKWezyH6EO6VUIx08+Tz9AlW0i6DICnjaxMBkyWSkrOaeedv2uoNjkYS3nypobNN
         I+XxwM+4Q+gdwDxoGSB0zL+0RgU0HL0qTCVIhl5KflNBxPgmwUH9Z+tG1kFw0E4pTirc
         v82y/IJPRNFQHjaIsDe56ns8d/A6AQDjiadnouC5zgo560qM3uCIRxdbCYnAeiINnKsw
         XgWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-44.freemail.mail.aliyun.com (out30-44.freemail.mail.aliyun.com. [115.124.30.44])
        by mx.google.com with ESMTPS id l6si17011344pjt.70.2019.07.25.10.21.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 10:21:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) client-ip=115.124.30.44;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R121e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04391;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TXn99.H_1564075272;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TXn99.H_1564075272)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 26 Jul 2019 01:21:15 +0800
Subject: Re: [PATCH] mm: page_alloc: document kmemleak's non-blockable
 __GFP_NOFAIL case
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mhocko@suse.com, dvyukov@google.com, catalin.marinas@arm.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1562964544-59519-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190724194835.59947a6b4df3c2ae7816470d@linux-foundation.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <c086eadf-dd92-9a06-7214-876c66015b49@linux.alibaba.com>
Date: Thu, 25 Jul 2019 10:21:08 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190724194835.59947a6b4df3c2ae7816470d@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/24/19 7:48 PM, Andrew Morton wrote:
> On Sat, 13 Jul 2019 04:49:04 +0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
>> When running ltp's oom test with kmemleak enabled, the below warning was
>> triggerred since kernel detects __GFP_NOFAIL & ~__GFP_DIRECT_RECLAIM is
>> passed in:
>>
>> ...
>>
>> The mempool_alloc_slab() clears __GFP_DIRECT_RECLAIM, kmemleak has
>> __GFP_NOFAIL set all the time due to commit
>> d9570ee3bd1d4f20ce63485f5ef05663866fe6c0 ("kmemleak: allow to coexist
>> with fault injection").
>>
>> The fault-injection would not try to fail slab or page allocation if
>> __GFP_NOFAIL is used and that commit tries to turn off fault injection
>> for kmemleak allocation.  Although __GFP_NOFAIL doesn't guarantee no
>> failure for all the cases (i.e. non-blockable allocation may fail), it
>> still makes sense to the most cases.  Kmemleak is also a debugging tool,
>> so it sounds not worth changing the behavior.
>>
>> It also meaks sense to keep the warning, so just document the special
>> case in the comment.
>>
>> ...
>>
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -4531,8 +4531,14 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>>   	 */
>>   	if (gfp_mask & __GFP_NOFAIL) {
>>   		/*
>> -		 * All existing users of the __GFP_NOFAIL are blockable, so warn
>> -		 * of any new users that actually require GFP_NOWAIT
>> +		 * The users of the __GFP_NOFAIL are expected be blockable,
>> +		 * and this is true for the most cases except for kmemleak.
>> +		 * The kmemleak pass in __GFP_NOFAIL to skip fault injection,
>> +		 * however kmemleak may allocate object at some non-blockable
>> +		 * context to trigger this warning.
>> +		 *
>> +		 * Keep this warning since it is still useful for the most
>> +		 * normal cases.
>>   		 */
> Comment has rather a lot of typos.  I'd normally fix them but I think
> I'll duck this patch until the kmemleak situation is addressed, so we
> can add a kmemleakless long-term comment, if desired.

Actually, this has been replaced by reverting the problematic commit. 
And, the patch has been in -mm tree. Please see: 
revert-kmemleak-allow-to-coexist-with-fault-injection.patch

I think we would like to have this merged in 5.3-rc1 or rc2?


