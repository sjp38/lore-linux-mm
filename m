Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A481C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 06:00:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A614A20851
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 06:00:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A614A20851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DC056B0005; Fri, 24 May 2019 02:00:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18C2A6B0006; Fri, 24 May 2019 02:00:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07B2B6B0007; Fri, 24 May 2019 02:00:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id C25FB6B0005
	for <linux-mm@kvack.org>; Fri, 24 May 2019 02:00:05 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 93so5132772plf.14
        for <linux-mm@kvack.org>; Thu, 23 May 2019 23:00:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=bmdTSJYIf0UASnQRz1FyYRCr2E+59ic8jJRr7WCLF+A=;
        b=ebj4NXTtdUNOAR/zKk2xvnTsZplu9ZFQlLFA24Z0VVBcrB9Ah1rgc4ugs9aYGI4GkB
         C17mJS0N5wDsemu2c9Nya5rnoprrBqG+Z3wejyYKziqUSpwfkPJyFXbFLBDlKPpUn9R6
         5+HH8liTRLwFztNfrgS7eZXOLYwj9bz45lS2MDkwAEa6SsbvUdLjWupMg3RcYc9+1+zd
         uRBw7aZIhr50Rf6zHDkV1ShhNxOgqqVmdCtiIsXA1g7TfkpMxQAdU9GEMhwMn7nPPXXP
         XCWn34Yg7w6rFlGwt86Ywvu7KVCRzKF6gP7osJcxQNiBHaTaMk/LczZItITf+X1MqhEg
         pjbg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWNQuVPhMBZzNyRcl/SXJgqhYF0/wmx7ekC4reAEyEdwsHS7bK5
	5pCC/ugyHpfgqkBAKFJWGHWXepc0+yEF88uTzZNC/4n7kHkxLGcc07SiZ5R/sRMsDevj6j26NTN
	FXa9ZmMBn9ee0qeSjLtb1ps3K/ctbZVgx5L1RjGyTWq7ezH8s+X7yvSwYV1NOeroNfw==
X-Received: by 2002:a17:902:e104:: with SMTP id cc4mr103221763plb.254.1558677605442;
        Thu, 23 May 2019 23:00:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNFKlA3ZcnIWsV7iEQq9TOGeYrYxoKJYdSssT0KlnPMEwXC60gfRfdjmO+KBkudHu1zo+v
X-Received: by 2002:a17:902:e104:: with SMTP id cc4mr103221658plb.254.1558677604092;
        Thu, 23 May 2019 23:00:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558677604; cv=none;
        d=google.com; s=arc-20160816;
        b=f5cNyTf3Ge06s32O2dk+nDrMXDVaqiyOa1P6gg33LDxP+IQZtvT74HhY36rWldVg6f
         LSRlIqqRnGF8FOS7S8CigRPImQsdicR1JBz24e9eVdElbm5eardKhWyuzX4cYskPqTpn
         5a3tcMLapOoLL+eH7zdjAoKPBwOLkNp+ElmaIorNSBOIZKF+0vFRYtTcctUj7Ozg6whP
         toJhum9xbV3orP9V67gLWJ1FhUO2Y81KiU5C0dXUVmJ13+rAYZuE7lx7cUYpFIniLETc
         xIsW3OGQzsbIELgPSoRCJY6ZLsCJdLufmvM1JcG3Jb1+sM/fuKaNSBvKVgjCoABeE4p0
         m7uQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=bmdTSJYIf0UASnQRz1FyYRCr2E+59ic8jJRr7WCLF+A=;
        b=OJOc5r2fLeHDsAcTSzNZlH4M3y2k3Jj9XL8/9dq/Jkr1DIAm3700dDFOpb/SRE+AfJ
         qUPGwYcK8mKYjrjRLNXo0RANtk51IltMhOTSQBkax+/6ZQ8xPY7QMIpesz0zSfmlwb8e
         Ma5FssyibSces6aX/UbwLrNkcp0PY9vNo3C06nfqMw90zHmWsmPsIxZjHc5sy3Scthgr
         o1Sk0hJbblx0IvD9Je6JFEa0VyJniViCyYg79ye4y/YfX2pFl0RSv52XwJsAGoAVPzEg
         8Np/v7/yN/+3ANYKREK3dbvNApFwpPbaUCTOTz8cIhRy17dRkVMYPEr7wJOQKYBb3nwj
         jBgw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id e67si2722246pgc.11.2019.05.23.23.00.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 23:00:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) client-ip=115.124.30.130;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R201e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04400;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TSXfk8M_1558677600;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TSXfk8M_1558677600)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 24 May 2019 14:00:01 +0800
Subject: Re: [v4 PATCH 2/2] mm: vmscan: correct some vmscan counters for
To: Hillf Danton <hdanton@sina.com>
Cc: ying.huang@intel.com, hannes@cmpxchg.org, mhocko@suse.com,
 mgorman@techsingularity.net, kirill.shutemov@linux.intel.com,
 josef@toxicpanda.com, hughd@google.com, shakeelb@google.com,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190524055125.3036-1-hdanton@sina.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <fbc9a823-7e6a-f923-92e1-c7e93a256aff@linux.alibaba.com>
Date: Fri, 24 May 2019 14:00:00 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190524055125.3036-1-hdanton@sina.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/24/19 1:51 PM, Hillf Danton wrote:
> On Fri, 24 May 2019 09:27:02 +0800 Yang Shi wrote:
>> On 5/23/19 11:51 PM, Hillf Danton wrote:
>>> On Thu, 23 May 2019 10:27:38 +0800 Yang Shi wrote:
>>>> @ -1642,14 +1650,14 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>>>>    	unsigned long nr_zone_taken[MAX_NR_ZONES] = { 0 };
>>>>    	unsigned long nr_skipped[MAX_NR_ZONES] = { 0, };
>>>>    	unsigned long skipped = 0;
>>>> -	unsigned long scan, total_scan, nr_pages;
>>>> +	unsigned long scan, total_scan;
>>>> +	unsigned long nr_pages;
>>> Change for no earn:)
>> Aha, yes.
>>
>>>>    	LIST_HEAD(pages_skipped);
>>>>    	isolate_mode_t mode = (sc->may_unmap ? 0 : ISOLATE_UNMAPPED);
>>>> +	total_scan = 0;
>>>>    	scan = 0;
>>>> -	for (total_scan = 0;
>>>> -	     scan < nr_to_scan && nr_taken < nr_to_scan && !list_empty(src);
>>>> -	     total_scan++) {
>>>> +	while (scan < nr_to_scan && !list_empty(src)) {
>>>>    		struct page *page;
>>> AFAICS scan currently prevents us from looping for ever, while nr_taken bails
>>> us out once we get what's expected, so I doubt it makes much sense to cut
>>> nr_taken off.
>> It is because "scan < nr_to_scan && nr_taken >= nr_to_scan" is
>> impossible now with the units fixed.
>>
> With the units fixed, nr_taken is no longer checked.

It is because scan would be always >= nr_taken.

>
>>>>    		page = lru_to_page(src);
>>>> @@ -1657,9 +1665,12 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>>>>    		VM_BUG_ON_PAGE(!PageLRU(page), page);
>>>> +		nr_pages = 1 << compound_order(page);
>>>> +		total_scan += nr_pages;
>>>> +
>>>>    		if (page_zonenum(page) > sc->reclaim_idx) {
>>>>    			list_move(&page->lru, &pages_skipped);
>>>> -			nr_skipped[page_zonenum(page)]++;
>>>> +			nr_skipped[page_zonenum(page)] += nr_pages;
>>>>    			continue;
>>>>    		}
>>>> @@ -1669,10 +1680,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>>>>    		 * ineligible pages.  This causes the VM to not reclaim any
>>>>    		 * pages, triggering a premature OOM.
>>>>    		 */
>>>> -		scan++;
>>>> +		scan += nr_pages;
>>> The comment looks to defy the change if we fail to add a huge page to
>>> the dst list; otherwise nr_taken knows how to do the right thing. What
>>> I prefer is to let scan to do one thing a time.
>> I don't get your point. Do you mean the comment "Do not count skipped
>> pages because that makes the function return with no isolated pages if
>> the LRU mostly contains ineligible pages."? I'm supposed the comment is
>> used to explain why not count skipped page.
>>
> Well consider the case where there is a huge page in the second place
> reversely on the src list along with other 20 regular pages, and we are
> not able to add the huge page to the dst list. Currently we can go on and
> try to scan other pages, provided nr_to_scan is 32; with the units fixed,
> however, scan goes over nr_to_scan, leaving us no chance to scan any page
> that may be not busy. I wonder that triggers a premature OOM, because I
> think scan means the number of list nodes we try to isolate, and
> nr_taken the number of regular pages successfully isolated.

Yes, good point. I think I just need roll back to what v3 did here to 
get scan accounted for each case separately to avoid the possible 
over-account.

>>>>    		switch (__isolate_lru_page(page, mode)) {
>>>>    		case 0:
>>>> -			nr_pages = hpage_nr_pages(page);
>>>>    			nr_taken += nr_pages;
>>>>    			nr_zone_taken[page_zonenum(page)] += nr_pages;
>>>>    			list_move(&page->lru, dst);
>>>> --
>>>> 1.8.3.1
> Best Regards
> Hillf

