Return-Path: <SRS0=GxOJ=TZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FF2CC282E1
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 02:42:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE01A20879
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 02:42:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE01A20879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6008A6B0010; Fri, 24 May 2019 22:42:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B0286B0266; Fri, 24 May 2019 22:42:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 49F876B0269; Fri, 24 May 2019 22:42:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 10D6F6B0010
	for <linux-mm@kvack.org>; Fri, 24 May 2019 22:42:14 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i123so8402375pfb.19
        for <linux-mm@kvack.org>; Fri, 24 May 2019 19:42:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=nuj1sQoMTpXT469l1wKEM2JVGI8voUZ3kIMiD0m2uXQ=;
        b=oylLdBK2mgmDfNcrCEZijipvpIZAthgnDFzPmckBWtYVdJ9mgfy8QWW1fkq4mqfszl
         Is0qT9AVhCliAObXWrQnF+Fkusg+8U73rscTeYOrKfCLGPvgDAQEiK0SVLfNm8x321oO
         ZtbPfAF+G58rwupAr0FyzRVgIUoL+efHAnvPmUmLMs9Prk/wn+EQEDLOSBzCQeigirD1
         gcjmCMti6PJpYGlLT/SYVIx436bLHaV5ciRrB0KoWQpB7c8PdVW0A7lnhO2bWBMqbNAJ
         m1jMici+UpaP83sEEOHWTZ7sOn3G1MYLVZWP5ZOS5CtRWH1iwYSnmfdYHiKNYaT3U09b
         FVMA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAU30RD1BsmxM/Q9HOT2QZ/fyw+7UDMbe+UApphmQLuiML56YiFA
	tPIJu+XpqolFbBiMtsVkWQhKCg1QXJdAF1ZgmMfmSLxUcxqCZxoNG945wupd2gO6I3vhS21PcDy
	kS+y2yk6W3o1eKkQvPrBhMY0woxxjaFb78xw1t0fJ9aJGVJGjzElVZvqGLQ+CjXrwng==
X-Received: by 2002:a17:902:b949:: with SMTP id h9mr65842610pls.50.1558752133713;
        Fri, 24 May 2019 19:42:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxr0FBDa7yN+AHX4Zu/nU5d5yYr7oPOtJ5nNzY8jd7pefDoKDqP3MeuW6XQLbS2JKj8efdB
X-Received: by 2002:a17:902:b949:: with SMTP id h9mr65842533pls.50.1558752132639;
        Fri, 24 May 2019 19:42:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558752132; cv=none;
        d=google.com; s=arc-20160816;
        b=LWeASrAPZFALdCHO3DhZyQaqmE2rHFUDn6XcmlU9Dp9M+sU3a+p4wwNGcxs9+iUU4l
         DQOzI4ykU2Wlvpc4uVcduz7V0crcUIgzUCgBOVKG43aVqdywn9ZYQmbIfVcPwykCdsxc
         nyCqUBCK1P5hYG3iNcOKT/LFfWc5tx8GbrEWY8588mnNapOuPKgo/bQCifnnDdNaU5Fk
         CA6A4irbCzkQNgDMpOtLDRfpF1B61Q9wdgissEHI3y1qOYLfuQ5NBMr8YA1CRuUW9mcR
         7IlqOFHRN0Wd4CMT2p/i7NXSKV7LwZpAEGazQJ2hh7qI5F5xIi62K418zP/z3oBVLvnt
         aKTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=nuj1sQoMTpXT469l1wKEM2JVGI8voUZ3kIMiD0m2uXQ=;
        b=SU6iA+0IvuQei0uFsA9qsxBX+Sr2njYBzEU/CafvdA/oEugnltDDPSw1yOzLosHNXJ
         DbSpIM7AmzC1ZTQdUxRGx1B2BY29jxmjw4prqdygoj91qCg78f+NqPoR4ehWC2WJ/xC2
         yb31FnL9WhrjWb0x99WDfFiCzP8/mE6x9LQAM9SdvTUiB38YsRyaKgWEjCitP7zNW+J4
         i+lPQeq1C1au/bS/FpRCwIF+mrnfiWh5Krni10ZtdXKlxiFQ6CSi4vJ1oRbVEcJvSdU0
         rqfZ1dQsgvsc58wbu+eA6YxXZw3DmKswORbWZX6ow+68FNSPfWtv+jZ7YirGxhDRhw1T
         z5Ng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id v30si6468975pgk.295.2019.05.24.19.42.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 19:42:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R171e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07486;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TScWKt2_1558752127;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TScWKt2_1558752127)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 25 May 2019 10:42:07 +0800
Subject: Re: [v4 PATCH 2/2] mm: vmscan: correct some vmscan counters for
From: Yang Shi <yang.shi@linux.alibaba.com>
To: Hillf Danton <hdanton@sina.com>
Cc: ying.huang@intel.com, hannes@cmpxchg.org, mhocko@suse.com,
 mgorman@techsingularity.net, kirill.shutemov@linux.intel.com,
 josef@toxicpanda.com, hughd@google.com, shakeelb@google.com,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190524055125.3036-1-hdanton@sina.com>
 <fbc9a823-7e6a-f923-92e1-c7e93a256aff@linux.alibaba.com>
Message-ID: <80fbb4f6-b6ec-7a48-2e58-be2ce2a9d5e7@linux.alibaba.com>
Date: Sat, 25 May 2019 10:42:03 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <fbc9a823-7e6a-f923-92e1-c7e93a256aff@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/24/19 2:00 PM, Yang Shi wrote:
>
>
> On 5/24/19 1:51 PM, Hillf Danton wrote:
>> On Fri, 24 May 2019 09:27:02 +0800 Yang Shi wrote:
>>> On 5/23/19 11:51 PM, Hillf Danton wrote:
>>>> On Thu, 23 May 2019 10:27:38 +0800 Yang Shi wrote:
>>>>> @ -1642,14 +1650,14 @@ static unsigned long 
>>>>> isolate_lru_pages(unsigned long nr_to_scan,
>>>>>        unsigned long nr_zone_taken[MAX_NR_ZONES] = { 0 };
>>>>>        unsigned long nr_skipped[MAX_NR_ZONES] = { 0, };
>>>>>        unsigned long skipped = 0;
>>>>> -    unsigned long scan, total_scan, nr_pages;
>>>>> +    unsigned long scan, total_scan;
>>>>> +    unsigned long nr_pages;
>>>> Change for no earn:)
>>> Aha, yes.
>>>
>>>>>        LIST_HEAD(pages_skipped);
>>>>>        isolate_mode_t mode = (sc->may_unmap ? 0 : ISOLATE_UNMAPPED);
>>>>> +    total_scan = 0;
>>>>>        scan = 0;
>>>>> -    for (total_scan = 0;
>>>>> -         scan < nr_to_scan && nr_taken < nr_to_scan && 
>>>>> !list_empty(src);
>>>>> -         total_scan++) {
>>>>> +    while (scan < nr_to_scan && !list_empty(src)) {
>>>>>            struct page *page;
>>>> AFAICS scan currently prevents us from looping for ever, while 
>>>> nr_taken bails
>>>> us out once we get what's expected, so I doubt it makes much sense 
>>>> to cut
>>>> nr_taken off.
>>> It is because "scan < nr_to_scan && nr_taken >= nr_to_scan" is
>>> impossible now with the units fixed.
>>>
>> With the units fixed, nr_taken is no longer checked.
>
> It is because scan would be always >= nr_taken.
>
>>
>>>>>            page = lru_to_page(src);
>>>>> @@ -1657,9 +1665,12 @@ static unsigned long 
>>>>> isolate_lru_pages(unsigned long nr_to_scan,
>>>>>            VM_BUG_ON_PAGE(!PageLRU(page), page);
>>>>> +        nr_pages = 1 << compound_order(page);
>>>>> +        total_scan += nr_pages;
>>>>> +
>>>>>            if (page_zonenum(page) > sc->reclaim_idx) {
>>>>>                list_move(&page->lru, &pages_skipped);
>>>>> -            nr_skipped[page_zonenum(page)]++;
>>>>> +            nr_skipped[page_zonenum(page)] += nr_pages;
>>>>>                continue;
>>>>>            }
>>>>> @@ -1669,10 +1680,9 @@ static unsigned long 
>>>>> isolate_lru_pages(unsigned long nr_to_scan,
>>>>>             * ineligible pages.  This causes the VM to not reclaim 
>>>>> any
>>>>>             * pages, triggering a premature OOM.
>>>>>             */
>>>>> -        scan++;
>>>>> +        scan += nr_pages;
>>>> The comment looks to defy the change if we fail to add a huge page to
>>>> the dst list; otherwise nr_taken knows how to do the right thing. What
>>>> I prefer is to let scan to do one thing a time.
>>> I don't get your point. Do you mean the comment "Do not count skipped
>>> pages because that makes the function return with no isolated pages if
>>> the LRU mostly contains ineligible pages."? I'm supposed the comment is
>>> used to explain why not count skipped page.
>>>
>> Well consider the case where there is a huge page in the second place
>> reversely on the src list along with other 20 regular pages, and we are
>> not able to add the huge page to the dst list. Currently we can go on 
>> and
>> try to scan other pages, provided nr_to_scan is 32; with the units 
>> fixed,
>> however, scan goes over nr_to_scan, leaving us no chance to scan any 
>> page
>> that may be not busy. I wonder that triggers a premature OOM, because I
>> think scan means the number of list nodes we try to isolate, and
>> nr_taken the number of regular pages successfully isolated.
>
> Yes, good point. I think I just need roll back to what v3 did here to 
> get scan accounted for each case separately to avoid the possible 
> over-account.

By rethinking the code, I think "scan" here still should mean the number 
of base pages. If the case you mentioned happens, the right behavior 
should be to raise priority to give another round of scan.

And, vmscan uses sync isolation (mode = (sc->may_unmap ? 0 : 
ISOLATE_UNMAPPED)), it returns -EBUSY only when the page is freed 
somewhere else, so this should not cause premature OOM.

>
>>>>>            switch (__isolate_lru_page(page, mode)) {
>>>>>            case 0:
>>>>> -            nr_pages = hpage_nr_pages(page);
>>>>>                nr_taken += nr_pages;
>>>>>                nr_zone_taken[page_zonenum(page)] += nr_pages;
>>>>>                list_move(&page->lru, dst);
>>>>> -- 
>>>>> 1.8.3.1
>> Best Regards
>> Hillf
>

