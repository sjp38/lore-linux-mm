Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B8A9C76195
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 18:39:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 225D32184E
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 18:39:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 225D32184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 520796B0007; Wed, 17 Jul 2019 14:39:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A9C38E0003; Wed, 17 Jul 2019 14:39:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 322D28E0001; Wed, 17 Jul 2019 14:39:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id EB6E26B0007
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 14:39:09 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id a5so12489632pla.3
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 11:39:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=RqRT4jUsZgUrnXcG7lhhFqG7NvnyClUrEitYVws76XQ=;
        b=GodoYXHQpp3ZQntwAKlLhyRJEJ/pAKurmvLVSNjL5TK9CCNtc0X878qDLgIGMqWKSO
         o+pH8DyB0/Qkw5sPAggda2nesNaNjxUOPbL60pKge0nSIDlDuT7G0vXwhcsiDx46Zgum
         3hvIua3vYC7EfNcnCfGDGajOGEaAku/aEeLhljvx3Q2hBEIHJ2S81wfqsCLHO9FYUiWs
         P+OKjMw5WSE9xByS8AivkrIgKPWRV5nEZKkXljqgWpO46/X/xehdEGak1ckTJRTtwahf
         +37gYLpDQJlbxEJnh76AUaYkqVgBn+aB/ox5LR0okEfrjAfmZdBtFDJkhqpdkhHOwZlw
         u12A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUlwk1nQn59zsABGFzip1hv0XKeOWOZLt2VQyHNztBD8yruGCM8
	Qo6Km8oOISDjjJsfO+mafOtm5eoiRNDiivVnlv5xe114qX6xSVsHNw7OSFFKFE6HoAjHxcmJfgn
	LuSWVVEc28KEFuGMMiYqEeBpgwaVnuRQcY7+X8CyN1Buz6GUeSSIKaQ1fnMXy9p+m5A==
X-Received: by 2002:a17:902:76c6:: with SMTP id j6mr44826566plt.102.1563388749629;
        Wed, 17 Jul 2019 11:39:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwvG9YtCAPthVUEBkU4yd342HGCfUfl9wsinpHOXd76w557U8A3h1nYfxSbB4F0MCWmkTdb
X-Received: by 2002:a17:902:76c6:: with SMTP id j6mr44826495plt.102.1563388748956;
        Wed, 17 Jul 2019 11:39:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563388748; cv=none;
        d=google.com; s=arc-20160816;
        b=r5R40jKP5BeiZPTEfkbvXsnDX4fZ/8zFkXqKAj3CJEKhXtZR+VBrxQVkJwrNq+xsGq
         C3EvP+CYiR3NMxikkg4lwvl5mua/ukTYAfg97HFecsGfcTocgucKp/Jqvn6jKERoRoXP
         W/75obnTmatk8vHXOUcKgGaqrIEtkl3vKigsA5NOnAwXGLVQHsyHfYfwj1Eun+wli9dZ
         M73101xLYETHaYlbk+y2qLz4NTMDHn376qTb6lUteVnKGh8O7j2A0R/toQZdy09PRjUE
         1xnZVXGgJJyC78CdrnNcn6UIqPJcg1EkACiaJK4Q+i4r0pIGxJeuxiXoxsPSsCm4S1Vc
         fLIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=RqRT4jUsZgUrnXcG7lhhFqG7NvnyClUrEitYVws76XQ=;
        b=QF4Mu454lH/48jL2lGz1PcDfrhBk0Sek1lhjQzEcFLx5+9AtEBua8ZKbCioC7Qm88P
         vkWsTc21MXKHmOtSKp2Zj5wHlIQz25DB6XXEe7oJ7y8ZE/uX1bFiSUHQsjMSvHmGz27R
         FIhXvxuIZF8kDh1nBhIGiebqhnMFGEUF12HaQZdZQLHPTBcbcQlX4cl5bGvk5URjTgR2
         wPMR+ACbWjL9mxgNK46N4d3bvueCYCXuvE34ac2h4Hv7PLKS79WkIgJaXWXErILFuNc9
         ogFj0w6NCNAnOGayRf9pCycV2OhzcaTLI+3RFNndSMa5JR8an2MB74ADL+u/ny2p6mKl
         GESQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-43.freemail.mail.aliyun.com (out30-43.freemail.mail.aliyun.com. [115.124.30.43])
        by mx.google.com with ESMTPS id m63si22604007pld.385.2019.07.17.11.39.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 11:39:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) client-ip=115.124.30.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R161e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04407;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TX8zwcd_1563388743;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TX8zwcd_1563388743)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 18 Jul 2019 02:39:06 +0800
Subject: Re: [v2 PATCH 2/2] mm: mempolicy: handle vma with unmovable pages
 mapped correctly in mbind
From: Yang Shi <yang.shi@linux.alibaba.com>
To: Vlastimil Babka <vbabka@suse.cz>, mhocko@kernel.org,
 mgorman@techsingularity.net, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1561162809-59140-1-git-send-email-yang.shi@linux.alibaba.com>
 <1561162809-59140-3-git-send-email-yang.shi@linux.alibaba.com>
 <0cbc99f6-76a9-7357-efa7-a2d551b3cd12@suse.cz>
 <9defdc16-c825-05b7-b394-abdf39000220@linux.alibaba.com>
 <3197a7df-c7bc-2bac-3d40-dbfc97d4a909@linux.alibaba.com>
Message-ID: <c1d91462-6aff-1784-1934-117112ac9d01@linux.alibaba.com>
Date: Wed, 17 Jul 2019 11:39:02 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <3197a7df-c7bc-2bac-3d40-dbfc97d4a909@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/17/19 11:23 AM, Yang Shi wrote:
>
>
> On 7/16/19 10:28 AM, Yang Shi wrote:
>>
>>
>> On 7/16/19 5:07 AM, Vlastimil Babka wrote:
>>> On 6/22/19 2:20 AM, Yang Shi wrote:
>>>> @@ -969,10 +975,21 @@ static long do_get_mempolicy(int *policy, 
>>>> nodemask_t *nmask,
>>>>   /*
>>>>    * page migration, thp tail pages can be passed.
>>>>    */
>>>> -static void migrate_page_add(struct page *page, struct list_head 
>>>> *pagelist,
>>>> +static int migrate_page_add(struct page *page, struct list_head 
>>>> *pagelist,
>>>>                   unsigned long flags)
>>>>   {
>>>>       struct page *head = compound_head(page);
>>>> +
>>>> +    /*
>>>> +     * Non-movable page may reach here.  And, there may be
>>>> +     * temporaty off LRU pages or non-LRU movable pages.
>>>> +     * Treat them as unmovable pages since they can't be
>>>> +     * isolated, so they can't be moved at the moment.  It
>>>> +     * should return -EIO for this case too.
>>>> +     */
>>>> +    if (!PageLRU(head) && (flags & MPOL_MF_STRICT))
>>>> +        return -EIO;
>>>> +
>>> Hm but !PageLRU() is not the only way why queueing for migration can
>>> fail, as can be seen from the rest of the function. Shouldn't all cases
>>> be reported?
>>
>> Do you mean the shared pages and isolation failed pages? I'm not sure 
>> whether we should consider these cases break the semantics or not, so 
>> I leave them as they are. But, strictly speaking they should be 
>> reported too, at least for the isolation failed page.
>
> By reading mbind man page, it says:
>
> If MPOL_MF_MOVE is specified in flags, then the kernel will attempt to 
> move all the existing pages in the memory range so that they follow 
> the policy.  Pages that are shared with other processes will not be 
> moved.  If MPOL_MF_STRICT is also specified, then the call fails with 
> the error EIO if some pages could not be moved.
>
> It looks the code already handles shared page correctly, we just need 
> return -EIO for isolation failed page if MPOL_MF_STRICT is specified.

Second look shows isolate_lru_page() returns error when and only when 
the page is *not* on LRU. So, we don't need change anything to this patch.

>
>>
>> Thanks,
>> Yang
>>
>>>
>>>>       /*
>>>>        * Avoid migrating a page that is shared with others.
>>>>        */
>>>> @@ -984,6 +1001,8 @@ static void migrate_page_add(struct page 
>>>> *page, struct list_head *pagelist,
>>>>                   hpage_nr_pages(head));
>>>>           }
>>>>       }
>>>> +
>>>> +    return 0;
>>>>   }
>>>>     /* page allocation callback for NUMA node migration */
>>>> @@ -1186,9 +1205,10 @@ static struct page *new_page(struct page 
>>>> *page, unsigned long start)
>>>>   }
>>>>   #else
>>>>   -static void migrate_page_add(struct page *page, struct list_head 
>>>> *pagelist,
>>>> +static int migrate_page_add(struct page *page, struct list_head 
>>>> *pagelist,
>>>>                   unsigned long flags)
>>>>   {
>>>> +    return -EIO;
>>>>   }
>>>>     int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
>>>>
>>
>

