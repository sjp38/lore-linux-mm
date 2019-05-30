Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 753A3C28CC2
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 13:29:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47CDA259AE
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 13:29:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47CDA259AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD94E6B026E; Thu, 30 May 2019 09:29:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B88B16B026F; Thu, 30 May 2019 09:29:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A50C86B0270; Thu, 30 May 2019 09:29:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6FB646B026E
	for <linux-mm@kvack.org>; Thu, 30 May 2019 09:29:58 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id g38so2323663pgl.22
        for <linux-mm@kvack.org>; Thu, 30 May 2019 06:29:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=AJEAJ7wb5ekzTfTE3ciuY9go/IMqJFuPiNQXaSv9wEY=;
        b=VxzzIqMCjQicj7yBmeQFx+3HEDc4qcCz1zGW5Rq5Rogc4PXNSIBqobvApgZqW2PeoD
         oRv1OUDwm1/DYaqxqCRck+IGT3/t9hH5+7NlwQpgFYTeCcwv1TLvVQAFP2Bf/tE85qMO
         2SwSG3mRQZQH7BIYbHsH958pH59Wrzn96/15xOhfSrckpYVcQT9cstNvDYamawHLLcE3
         z+WHSqaIyii2kwa5eA7ySnOv5Hx5VRVpDyjZf1HzoKmTHbG8cokFgqW2xcbyOE8WiMwt
         7tSJp+/+jk3GBJncy4yFcpRhMzyrXVps4AAdxsGfzf2A8XrZ1KZzxsfCK6WrLhCvs0Vj
         vVPQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUJvG3z4GyfGmDIlo/LYTJiWvk8TL44xTJL0zlCuh2FVsA19otd
	iewg2diPhGMVug+D63T2wbRTdJ2fwe68jJ9BinaQw5u/re5wgyj4XuWDY4S7hGGTjAbMfCyJLNx
	yLh6rdMseJVa3VNO5KcgiKeJ10SRothHusrWmx3IzC+FYEV/EzccHT6sIeDt9mGYknw==
X-Received: by 2002:a17:90a:9dca:: with SMTP id x10mr3413745pjv.105.1559222998132;
        Thu, 30 May 2019 06:29:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzCpga19/ocerZwK7fD9EFsb41KuA5lya7yK7siCDHz8THqL3OxMYw3JqJlWqKpMBswICcm
X-Received: by 2002:a17:90a:9dca:: with SMTP id x10mr3413685pjv.105.1559222997096;
        Thu, 30 May 2019 06:29:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559222997; cv=none;
        d=google.com; s=arc-20160816;
        b=jEwK/qKZoZVTQjNavLPAMRQwOTbGQ8SvIQ79w7++6YoWQlYD/1t0CkQ3HTgtPnIRDg
         otbXdWE3gka1dJN/9a4B4k0++qqHOSKqytMd59s5Y7LKs+1PMgwXp4KJ0fw72b4bsQOs
         oeJmOZ4ORVbnsLIqwdo1qeSK4ZFN1n8k0u8pzeYiD2iuEb0XGA07IZIVikzgOXKe601H
         6bNwp5Zvlmlbg08g7OnBtQbEDUMtoACnfxi3sWmFYPtTNo5SFSlhgHghmK8x/AUZJX9s
         IvpOxGZ6Fjf4s58bjdGHXVuDex6NpmU54OvUikYjaLEUpzFZIl0WuTOO/hLpGZaGmbaL
         4ggQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=AJEAJ7wb5ekzTfTE3ciuY9go/IMqJFuPiNQXaSv9wEY=;
        b=tMaD1Rd+NLL4QRLI0Rq4SHIt/fwjOBl7hOTR40TGlWVVgKqSuYm13toP2u8/HlyyQZ
         KVrIJG0ZX40sqCnCZtLDbdwVp+TOquWRiRp9ygJDBifNa/8rsNSRfXevOcbZ4fmGgqBK
         BNJz0jGDHURfif2+ORL48c/RROLLDRU9KXX3p7MN4L6Z+5vrCB3YHMzIaTfvbO4KY5SX
         Q5VbmhPPszMbqnjG2bsNE+witx/c4nwAPuO11DfPCrwcIMwm8VecR2NxOhxx0i2myv1+
         dMoY+8Nks7Il/3v8Cs8tIz2KvnLLN/iZjA33TFIRYeWFvVTKWyu7fBRd3AkemLeLqksJ
         16Qg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id n88si2961546pjc.7.2019.05.30.06.29.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 06:29:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R791e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04426;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=10;SR=0;TI=SMTPD_---0TT0VdIh_1559222982;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TT0VdIh_1559222982)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 30 May 2019 21:29:42 +0800
Subject: Re: [PATCH 1/3] mm: thp: make deferred split shrinker memcg aware
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: ktkhai@virtuozzo.com, hannes@cmpxchg.org, mhocko@suse.com,
 kirill.shutemov@linux.intel.com, hughd@google.com, shakeelb@google.com,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1559047464-59838-1-git-send-email-yang.shi@linux.alibaba.com>
 <1559047464-59838-2-git-send-email-yang.shi@linux.alibaba.com>
 <20190530120718.52xuxgezkzsmaxqi@box>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <8c14a749-d94e-754d-656e-24e123ab28c6@linux.alibaba.com>
Date: Thu, 30 May 2019 21:29:40 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190530120718.52xuxgezkzsmaxqi@box>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/30/19 8:07 PM, Kirill A. Shutemov wrote:
> On Tue, May 28, 2019 at 08:44:22PM +0800, Yang Shi wrote:
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index bc74d6a..9ff5fab 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -316,6 +316,12 @@ struct mem_cgroup {
>>   	struct list_head event_list;
>>   	spinlock_t event_list_lock;
>>   
>> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> +	struct list_head split_queue;
>> +	unsigned long split_queue_len;
>> +	spinlock_t split_queue_lock;
> Maybe we should wrap there into a struct and have helper that would return
> pointer to the struct which is right for the page: from pgdat or from
> memcg, depending on the situation?
>
> This way we will be able to kill most of code duplication, right?

Yes, it sounds simpler than using list_lru.

>

