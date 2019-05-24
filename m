Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E40E9C282DD
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 01:27:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A05162168B
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 01:27:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A05162168B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42E4F6B0007; Thu, 23 May 2019 21:27:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DEAC6B0008; Thu, 23 May 2019 21:27:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CDAB6B000A; Thu, 23 May 2019 21:27:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E847B6B0007
	for <linux-mm@kvack.org>; Thu, 23 May 2019 21:27:16 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 21so5140637pgl.5
        for <linux-mm@kvack.org>; Thu, 23 May 2019 18:27:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=+khW/DQO1VcPKNDkRmBjKgBsqSADE78QnWtHeSz7egE=;
        b=cG0XC4cDdP8U9g17FVcgbW1kTDHnFrJq++DffUo4bQUGt7LerHoCg9b9dfbWjWE2f9
         0nwEO3j5xh8hdHTX0BrpvG6XK7mLoZP2JwHmIiSOWMXb/YESqQbKPkcebmiw5qzJr+p5
         t5V1a0xuI3etQehiBdag3BH2WbmaFwwwS64+rpW2yDOIEVtE3/B7QPFjqEo7cnCRlh9F
         S6ExUJepVwyQaAmb/tS4xL1YiJ6v0EE3IcIpWpe60FKl0nDpapVqBla5rYnklhbX49hZ
         j+yfu04HSivUzEwiG4ztRuGztQZoCnRnfsDwIz/9Ac3MmKKaEuBjCe7XrgxKbMcetuyj
         zreg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWZz3FVweqLAqNTNV+WKitsP02Q6uk01IBwb5yBTCcBom3pRm+k
	WtQh6gQcG3WWwJZTILB7OXRAnFHQ0ufA6j9n1r+VJJ7mXr4VSyBDHtUEW8TKbjj8icA91oOo0FH
	ke6d+iBOdXiqt/5I+ONQtTl6toleQ9OC4o3OBvwOB28yNmyc4mLPz0qk9hHB6zriZnQ==
X-Received: by 2002:a63:ed16:: with SMTP id d22mr101431929pgi.35.1558661236569;
        Thu, 23 May 2019 18:27:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx6ldKGOxen1g3s1d2qnPhYl1xlHj0sOV+QoYiVTpMc8NEtRU3KE138LAF6y3urfiRd1bMN
X-Received: by 2002:a63:ed16:: with SMTP id d22mr101431838pgi.35.1558661235785;
        Thu, 23 May 2019 18:27:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558661235; cv=none;
        d=google.com; s=arc-20160816;
        b=n8V6F4LHpwjohZ1DENsGymRpwGNyl4E8tH7GbtSCktD2TDEMVs8n8s/HEyzZ1yMQBc
         +DyxAVbsdNLLLMO2pw39JrbyssaohPvqkIVIjSN+abiORpd3mg2N9JMPkQ9OcIt11NoO
         0QHcEyJMFxdojkl1sJCWFKSFGYeVJxf+3KKfYn4ogNIX/+fVjM7WEZpjHb1p8jCqT8To
         zE3ydMBk7cdo9uYp/RC/5u8wu42GAG1U+1iiY1lse0MJ7Rcuk092cSSaJIwOu2cjeHrF
         wLhKOn1j53vnIBs29QB7ZtAY1OMqJPUd2P9iThQ39L0ChQjCZtQsPHgJ/SQWNz9H4SfR
         kpGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=+khW/DQO1VcPKNDkRmBjKgBsqSADE78QnWtHeSz7egE=;
        b=d+1mP/36G3w/jbmXXOsfLNV3UTmJruDpQzgg1R5RsHTLGU5dQM8F/CXM0VvzB26Vvt
         2qbvprNdWTmjsQQsWhBl8+gT0+h5vHyBEGCoFJXJ3xk0JvDAC/lC2cf+MMTzD3ODzF1u
         eiQi2jk/c+o0SsZcV7Jtc5bjgpEa2byu4TabTmrShqqPucsdcJxxVzP9QpLXVFhGuH10
         9auZuwU0C3t6vyDtPgqY5qBPl62t8phPdMJF22dBxA4J1zfujV+JbBr2DUGZXF0uEPJ/
         Pi/pLOohwfwhLT9SkuBSu+2+nXpJjdrN++b3CLi+gH9mnG71IuETfGGPgXkDzbf7dQmF
         yTHg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id c16si1971125pfr.94.2019.05.23.18.27.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 18:27:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R141e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04423;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TSWQwwc_1558661219;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TSWQwwc_1558661219)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 24 May 2019 09:27:00 +0800
Subject: Re: [v4 PATCH 2/2] mm: vmscan: correct some vmscan counters for THP
 swapout
To: Hillf Danton <hdanton@sina.com>
Cc: ying.huang@intel.com, hannes@cmpxchg.org, mhocko@suse.com,
 mgorman@techsingularity.net, kirill.shutemov@linux.intel.com,
 josef@toxicpanda.com, hughd@google.com, shakeelb@google.com,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190523155126.2312-1-hdanton@sina.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <b9c24d05-776a-4c4d-162a-e756e2c20d0f@linux.alibaba.com>
Date: Fri, 24 May 2019 09:26:57 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190523155126.2312-1-hdanton@sina.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/23/19 11:51 PM, Hillf Danton wrote:
> On Thu, 23 May 2019 10:27:38 +0800 Yang Shi wrote:
>> @ -1642,14 +1650,14 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>>   	unsigned long nr_zone_taken[MAX_NR_ZONES] = { 0 };
>>   	unsigned long nr_skipped[MAX_NR_ZONES] = { 0, };
>>   	unsigned long skipped = 0;
>> -	unsigned long scan, total_scan, nr_pages;
>> +	unsigned long scan, total_scan;
>> +	unsigned long nr_pages;
> Change for no earn:)

Aha, yes.

>
>>   	LIST_HEAD(pages_skipped);
>>   	isolate_mode_t mode = (sc->may_unmap ? 0 : ISOLATE_UNMAPPED);
>>   
>> +	total_scan = 0;
>>   	scan = 0;
>> -	for (total_scan = 0;
>> -	     scan < nr_to_scan && nr_taken < nr_to_scan && !list_empty(src);
>> -	     total_scan++) {
>> +	while (scan < nr_to_scan && !list_empty(src)) {
>>   		struct page *page;
> AFAICS scan currently prevents us from looping for ever, while nr_taken bails
> us out once we get what's expected, so I doubt it makes much sense to cut
> nr_taken off.

It is because "scan < nr_to_scan && nr_taken >= nr_to_scan" is 
impossible now with the units fixed.

>>   
>>   		page = lru_to_page(src);
>> @@ -1657,9 +1665,12 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>>   
>>   		VM_BUG_ON_PAGE(!PageLRU(page), page);
>>   
>> +		nr_pages = 1 << compound_order(page);
>> +		total_scan += nr_pages;
>> +
>>   		if (page_zonenum(page) > sc->reclaim_idx) {
>>   			list_move(&page->lru, &pages_skipped);
>> -			nr_skipped[page_zonenum(page)]++;
>> +			nr_skipped[page_zonenum(page)] += nr_pages;
>>   			continue;
>>   		}
>>   
>> @@ -1669,10 +1680,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>>   		 * ineligible pages.  This causes the VM to not reclaim any
>>   		 * pages, triggering a premature OOM.
>>   		 */
>> -		scan++;
>> +		scan += nr_pages;
> The comment looks to defy the change if we fail to add a huge page to
> the dst list; otherwise nr_taken knows how to do the right thing. What
> I prefer is to let scan to do one thing a time.

I don't get your point. Do you mean the comment "Do not count skipped 
pages because that makes the function return with no isolated pages if 
the LRU mostly contains ineligible pages."? I'm supposed the comment is 
used to explain why not count skipped page.

>
>>   		switch (__isolate_lru_page(page, mode)) {
>>   		case 0:
>> -			nr_pages = hpage_nr_pages(page);
>>   			nr_taken += nr_pages;
>>   			nr_zone_taken[page_zonenum(page)] += nr_pages;
>>   			list_move(&page->lru, dst);
>> -- 
>> 1.8.3.1
>>
> Best Regards
> Hillf

