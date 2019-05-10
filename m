Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D33B4C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 16:50:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E8DC21479
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 16:50:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E8DC21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 268186B0005; Fri, 10 May 2019 12:50:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F0D36B0006; Fri, 10 May 2019 12:50:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DFC36B0007; Fri, 10 May 2019 12:50:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id CC8EF6B0005
	for <linux-mm@kvack.org>; Fri, 10 May 2019 12:50:14 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id z7so4437746pgc.1
        for <linux-mm@kvack.org>; Fri, 10 May 2019 09:50:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=oWOXzW0KqXpElJGEH/CiDPpkA/nkCHGWaJ/eRWgGGP0=;
        b=YP3oQnck+QB+hhinA70doId2svGBcXflWDe27CEd9E99CTrk8a5V9tVYX6qhfHhkI1
         kc7cfHwhk5w9zkxcRVk1aWf+h+wGcrYbD66M8CwwW+PBI/aoV+YjV+3mwg5fg0NHKvPi
         EYJomClAe7BYNJC/P/Sp/0TgIVabSAQhr7lBdb7v72VkTZvxez8sm+1UbFGOYvQ5GK95
         o05mOQXKdlVUuKI3ut/ub3JDKcMX2PZ5qP8VKHLpLXBuW8vqM+SHjAyqMwKKXc0OkZiU
         aWhqPI2E87lAKmV/pvHUrPyfZ8KBRPu4TJwYItgtJQZ0dARRL976VtscsB2hc3wLlzEX
         hVBw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXIIsqJl/zu9gKywJfrV/hGf/Mki1bPH6JzyJnLXKV3+0ak6IU5
	LJgpHBc4I6ah5slz8fmc+hUSYa9Cy8SQcklaSf0QBNbrjTvOD6/StA5lvKv3Z6WRSLq863h6VIa
	skS+7UIAmbN3DtKxeoynmNPLAQ406tG5asR6LclyzEJ02xXGi+eqZtqWnXy30PG0x+Q==
X-Received: by 2002:a65:4802:: with SMTP id h2mr14081968pgs.98.1557507014529;
        Fri, 10 May 2019 09:50:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwk78yaty2PNLHcnUgNmS1EHcARoRfAqLbafqnxW6xJmKG/OyMGJGkp6bGj37RNrsojaWww
X-Received: by 2002:a65:4802:: with SMTP id h2mr14081896pgs.98.1557507013934;
        Fri, 10 May 2019 09:50:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557507013; cv=none;
        d=google.com; s=arc-20160816;
        b=tRqWwLyxZsV88+oC0mV37z3hz3Z+XJyrakVtOibfVkek3S1IvIU4KbrPl0sqzFAIWw
         EasJgwkOCEE2PDKycL1nlncr1wR9f/+kShkXbIiK0ryPOVQxzALuq1tflSgfNqANqcSM
         9gRXog9nlRoWP3lTgA2sYb6f1RrHWVgOaj3xdYHhvWqx1Mqf1if3H/nNO/BIbpjUMUDi
         JMX4maUbrdzd03PBxBDUpEJXAO0M3vGXqYCTtQaU580SPLd7GiojIuYfaUNsS1tadSvs
         A/uHVOB3t0t8NON/NUJYUnMUlaYzN+nbG8MnLNaWcFHrJJah8hjdjGcrf4g30M9SU/vc
         1QYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=oWOXzW0KqXpElJGEH/CiDPpkA/nkCHGWaJ/eRWgGGP0=;
        b=StDUyUx32mnamjjL1JKUY0zT4peocFUqJKeC+Uea8+Y3xc9oACTfMshfLFe2HLtv3V
         Jedx0hvSOgsAovPtkqqEYSyEE1qcS26QvW31ZSKM6MPJbVgv5v7QXq2Xh5xdxo0vxP5s
         5gUUwAnnSLjqdFy3DgORVOArW98BiiGLpXu0fkwoZNdIvJg7f43CI421/7AJtwJr8kDW
         kG5E6IWnS56xkmmkCj2wA9GJJtRgCbp/7qc8qzn7ORcOcEyUMj0PPhFnnsEBj1EGm3py
         4LNne4+LoILO/OkjqWbW56wkoXDaSavWfzDKPxl8FzHP8kNONTqv2N+3kzo1krV38+o5
         LMPA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id 31si8215267plh.231.2019.05.10.09.50.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 09:50:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) client-ip=115.124.30.131;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R151e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=10;SR=0;TI=SMTPD_---0TRMJzjz_1557507007;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TRMJzjz_1557507007)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 11 May 2019 00:50:10 +0800
Subject: Re: [PATCH] mm: vmscan: correct nr_reclaimed for THP
To: Matthew Wilcox <willy@infradead.org>, "Huang, Ying" <ying.huang@intel.com>
Cc: hannes@cmpxchg.org, mhocko@suse.com, mgorman@techsingularity.net,
 kirill.shutemov@linux.intel.com, hughd@google.com,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1557447392-61607-1-git-send-email-yang.shi@linux.alibaba.com>
 <87y33fjbvr.fsf@yhuang-dev.intel.com>
 <20190510163612.GA23417@bombadil.infradead.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <3a919cba-fefe-d78e-313a-8f0d81a4a75d@linux.alibaba.com>
Date: Fri, 10 May 2019 09:50:04 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190510163612.GA23417@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/10/19 9:36 AM, Matthew Wilcox wrote:
> On Fri, May 10, 2019 at 10:12:40AM +0800, Huang, Ying wrote:
>>> +		nr_reclaimed += (1 << compound_order(page));
>> How about to change this to
>>
>>
>>          nr_reclaimed += hpage_nr_pages(page);
> Please don't.  That embeds the knowledge that we can only swap out either
> normal pages or THP sized pages.  I'm trying to make the VM capable of
> supporting arbitrary-order pages, and this would be just one more place
> to fix.
>
> I'm sympathetic to the "self documenting" argument.  My current tree has
> a patch in it:
>
>      mm: Introduce compound_nr
>      
>      Replace 1 << compound_order(page) with compound_nr(page).  Minor
>      improvements in readability.
>
> It goes along with this patch:
>
>      mm: Introduce page_size()
>
>      It's unnecessarily hard to find out the size of a potentially huge page.
>      Replace 'PAGE_SIZE << compound_order(page)' with page_size(page).

So you prefer keeping using  "1 << compound_order" as v1 did? Then you 
will convert all "1 << compound_order" to compound_nr?

>
> Better suggestions on naming gratefully received.  I'm more happy with
> page_size() than I am with compound_nr().  page_nr() gives the wrong
> impression; page_count() isn't great either.

