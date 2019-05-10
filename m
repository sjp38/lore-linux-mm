Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 839ECC04AB1
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 03:03:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FEB32183F
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 03:03:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FEB32183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 659886B0003; Thu,  9 May 2019 23:03:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60B096B0006; Thu,  9 May 2019 23:03:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F9126B0007; Thu,  9 May 2019 23:03:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 164BB6B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 23:03:21 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 93so2798612plf.14
        for <linux-mm@kvack.org>; Thu, 09 May 2019 20:03:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=4X/GbgMsSIhCwQ6jqGE96QTIgxr7vrCRrYAFUpt6EBE=;
        b=LJJ+CbOdI48wV13v0PAZArLy89RXVmnYSqp9rt2a2jljm15iOnPSkE8+iBt9UntuSn
         IOWqox6yV0b874c17jkZgi/oapwBi0xDbwEAKhm+u/mdLHpwDFtbMlrbV0FuO5czxb5P
         Nxjrpxeng+uw3JDSvnj7KCaQzOZfVPHtm+xGEU5AB9IvhNRYkZ0wn6pA6bKXEp4fvMjx
         Q7Kt8Dr6mXvbTKZFRDmUEMFLlXtZnJsmy9SCXPaUfnhVwRXld+QmQhBkOFFZtO/ObdED
         X2NseBlsizb9pIdhYRpO2JliPKngfuNpE8dFz0lENQYvv4l1vGzHBB5x6Wi1MQRSG+Ol
         iK/g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWY0lt8bMQZ+4BDTETNYeJAIYFdSTFQ2Q9+bLztAjzMyNx98XBF
	kMYUFu1Ql0thq/NEtyQRRRsfAkwmK1VszqlBe9MH/AFmTH3GkwWt2PCbkw56/pSttq2L6fE744w
	w1nz8HNxAd14Pysz4Es3nme8grhJ78CkSg+dOaYmTS5bunbSf6zjleJsCUMzE1yNRkA==
X-Received: by 2002:a63:1866:: with SMTP id 38mr10521418pgy.123.1557457400732;
        Thu, 09 May 2019 20:03:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBo85ffc5npcXb6XBQW1lJ9qi2Z+w9Rz8V/ep9ar5u+K2+59bZT1JflOTQMVeaVrcPTzs1
X-Received: by 2002:a63:1866:: with SMTP id 38mr10521296pgy.123.1557457399783;
        Thu, 09 May 2019 20:03:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557457399; cv=none;
        d=google.com; s=arc-20160816;
        b=q9S1oqHh2gUaHsnBS+eDHr8lwIpNzYwePjc9ljQYv0pRHSU6XUo+zY5GsgczThykBF
         bv8tyfBW/7tQIqMLjQvmxNY/VEyhXGM00OQuHo0bBGXNOt+sm+HlHMkSyq1oKflKfeJo
         31O2cdfTv9RZvRHr77ppjyDinwHHmWx7uwykIdLirInLd6aTRKCw2Am8805o4evzGBuj
         3OZwI66INidpSHvCyVl5e2Sti5WcErqjt3Ov9UXP7v7aeqt59awbMoBOnQmBbmlPq/IW
         EBBp4vOPZ9C525891+BRzc/vrhE8r9yp8HZxtc7Idb73EDEVrdOT8pEHsuXusNTWONdm
         9WGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=4X/GbgMsSIhCwQ6jqGE96QTIgxr7vrCRrYAFUpt6EBE=;
        b=k41jXqG5PaUPG2s+iXqmw+8IHXYMTIf7IoJI/hCMWTdLPJHe0Qh+Gz3NeZm96iv8e6
         VYi3piy2GtNB+hOW6Vdzi4Svh3KexrungYT7mxx2qRdiKn5idyXVLX/aBrVM2CpSuaQ/
         D2M2JILPvD1nSlgUPEaCse71ns9VwC2fg2TGHglZ7yTIbpeWA2/rCcrC96dOZgaexmSJ
         qdwg+AZKrvNQvf445R64wYcqEUy0cUKUmLXT+x2hRbEoiQEyJxkk59hnKRmPUnsvR/aa
         fVPFVI6l6qo9ZuAMLYZ4JOzqeSyycivKcp4DBRzwEEZaRYZtAFF3KWM+ONWIby6AaE3P
         67Rg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id p11si5993556pgd.65.2019.05.09.20.03.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 20:03:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 May 2019 20:03:18 -0700
X-ExtLoop1: 1
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.29])
  by fmsmga001.fm.intel.com with ESMTP; 09 May 2019 20:03:17 -0700
From: "Huang\, Ying" <ying.huang@intel.com>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: <hannes@cmpxchg.org>,  <mhocko@suse.com>,  <mgorman@techsingularity.net>,  <kirill.shutemov@linux.intel.com>,  <hughd@google.com>,  <akpm@linux-foundation.org>,  <linux-mm@kvack.org>,  <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm: vmscan: correct nr_reclaimed for THP
References: <1557447392-61607-1-git-send-email-yang.shi@linux.alibaba.com>
	<87y33fjbvr.fsf@yhuang-dev.intel.com>
	<1fb73973-f409-1411-423b-c48895d3dde8@linux.alibaba.com>
Date: Fri, 10 May 2019 11:03:16 +0800
In-Reply-To: <1fb73973-f409-1411-423b-c48895d3dde8@linux.alibaba.com> (Yang
	Shi's message of "Thu, 9 May 2019 19:25:20 -0700")
Message-ID: <87tve3j9jf.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Yang Shi <yang.shi@linux.alibaba.com> writes:

> On 5/9/19 7:12 PM, Huang, Ying wrote:
>> Yang Shi <yang.shi@linux.alibaba.com> writes:
>>
>>> Since commit bd4c82c22c36 ("mm, THP, swap: delay splitting THP after
>>> swapped out"), THP can be swapped out in a whole.  But, nr_reclaimed
>>> still gets inc'ed by one even though a whole THP (512 pages) gets
>>> swapped out.
>>>
>>> This doesn't make too much sense to memory reclaim.  For example, direct
>>> reclaim may just need reclaim SWAP_CLUSTER_MAX pages, reclaiming one THP
>>> could fulfill it.  But, if nr_reclaimed is not increased correctly,
>>> direct reclaim may just waste time to reclaim more pages,
>>> SWAP_CLUSTER_MAX * 512 pages in worst case.
>>>
>>> This change may result in more reclaimed pages than scanned pages showed
>>> by /proc/vmstat since scanning one head page would reclaim 512 base pages.
>>>
>>> Cc: "Huang, Ying" <ying.huang@intel.com>
>>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>>> Cc: Michal Hocko <mhocko@suse.com>
>>> Cc: Mel Gorman <mgorman@techsingularity.net>
>>> Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
>>> Cc: Hugh Dickins <hughd@google.com>
>>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>>> ---
>>> I'm not quite sure if it was the intended behavior or just omission. I tried
>>> to dig into the review history, but didn't find any clue. I may miss some
>>> discussion.
>>>
>>>   mm/vmscan.c | 6 +++++-
>>>   1 file changed, 5 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>> index fd9de50..7e026ec 100644
>>> --- a/mm/vmscan.c
>>> +++ b/mm/vmscan.c
>>> @@ -1446,7 +1446,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>>     		unlock_page(page);
>>>   free_it:
>>> -		nr_reclaimed++;
>>> +		/*
>>> +		 * THP may get swapped out in a whole, need account
>>> +		 * all base pages.
>>> +		 */
>>> +		nr_reclaimed += (1 << compound_order(page));
>>>     		/*
>>>   		 * Is there need to periodically free_page_list? It would
>> Good catch!  Thanks!
>>
>> How about to change this to
>>
>>
>>          nr_reclaimed += hpage_nr_pages(page);
>
> Either is fine to me. Is this faster than "1 << compound_order(page)"?

I think the readability is a little better.  And this will become

        nr_reclaimed += 1

if CONFIG_TRANSPARENT_HUAGEPAGE is disabled.

Best Regards,
Huang, Ying

>>
>> Best Regards,
>> Huang, Ying

