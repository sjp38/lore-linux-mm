Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37684C282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 16:28:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A79A6222A7
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 16:28:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A79A6222A7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 37D296B0006; Fri, 19 Apr 2019 12:28:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 32A7E6B0007; Fri, 19 Apr 2019 12:28:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 200C26B0008; Fri, 19 Apr 2019 12:28:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id EFA426B0006
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 12:28:44 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id t13so7250395itk.0
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 09:28:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=UPb0IWwjIBeEX5imLIyRgeszted8bfQ9YSKdWtZJE5Y=;
        b=KEBVeNB+hNuChLn4oitWfND4SrtQI3Fw0Cq7SP/YbqwL/weywTVkg7tc2i3P1CBeSb
         XNN4H4cUG8MqGQOJqnQB8ttNBNtcUX1S++Dz7DD+jPPgkTSoJmtkHQcXic5paiK1vsr2
         oQTAiqy+dU8rhVqS00283ShBkfxh3dPZ5ETP7Y9+GmUxOCJsqkVL0DdI9H4GqdxQWCKA
         oYpZsSNc7Rsib5ZWERoSjQhZnXyz16NCDDi7WpT8jV/6PSIJH8FHVR4zBamy1Zo+3CLB
         ScoFgEoqOpqe6yiYwwmDQTN7+kv+QISvR85sDtzegCwaD3K0gXtmIEbwowIdKwiICASK
         03yQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVjxQ9We8zqDjkxL/iub+ojSvpBiK1XYo24ae1pAjkloensCAnS
	rgmZe08R6j6i71HUmNqgfvDWvgxJdqzE8eqHsRultV9W5OAdYyjlYK8zx8R0XI4z2C4aJe80mzR
	rAzc0W2/Y6hW0DH1h9bUG+q6pKSXUhdJypJyamWNO1uIS6gOYEXFBxeKSufqTnePerA==
X-Received: by 2002:a24:e303:: with SMTP id d3mr3722967ith.170.1555691324746;
        Fri, 19 Apr 2019 09:28:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzDwyBg4NR9CrAA92SZ6KPUDSah0sKBf54bb9tCunqMuVrNWDr5ofpTWNJpuQ0jKzcju87d
X-Received: by 2002:a24:e303:: with SMTP id d3mr3722926ith.170.1555691323992;
        Fri, 19 Apr 2019 09:28:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555691323; cv=none;
        d=google.com; s=arc-20160816;
        b=pUS53t/JgyA/j+RFyP3MTQRNFFcdBsovBJH/RsUeh/HOjaaeAIrIQIMc9TPBABCbDE
         3Zzuub1ndGGBW7pSOKDgoxZY+ROj+wMl4L5cBACdWzEWTzMAXx7KY47mW4xhOPLjpYOn
         qHBO+Uzr3rSy1QruSPrZPs87pn9ed7wKGZuAtSJJiTJrUq0j7L3bdAtYPp2dB5uWcK7n
         eWIEn8dn5Ji2OAxCJzIbanrwrRvpEXnGT5ISasSVSjVKSgmNnHUttNS22YDDEREw6zAz
         audauMOPELnuWL3jRW4j2pFPxYKfhu//H4KdTCDrUnh6bIapnnwuGhHriRQwPAICHjSh
         6wFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=UPb0IWwjIBeEX5imLIyRgeszted8bfQ9YSKdWtZJE5Y=;
        b=nTZ2KABzHOCV6vc5wcDSopMkR4XSmrMXuEXmYzX3i78fIDNsJ+8824JJwnNm1LQNbj
         UNoy7p0wS7pMINH8TccXy3cWobEoD6ngAbS65mk0EHpUND/aJwkijvY85SqaFSrmuw+R
         F6VZeZjwdeUJChZy6hQxJaS4DbZpKV5sAFo6gRTHVpDX1rMHd22vTgmdFEYO+R1D4Yv1
         HPfhZAD9H6fIzNkSTCksxrcAtqnN1xdvTFevvFK1KcdW/lzQJPXKn0xUgxEn/ctUhHUe
         rApwmNtDtUnMGsxBJsKz/8F7wYJ3NodkYXYmAmBJJS+eAYqKiiY+Ui/R4giSLcLd5/J9
         oXPg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id k188si3623568itb.61.2019.04.19.09.28.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 09:28:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R191e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TPjGOrH_1555691304;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TPjGOrH_1555691304)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 20 Apr 2019 00:28:26 +0800
Subject: Re: [QUESTIONS] THP allocation in NUMA fault migration path
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 linux-kernel <linux-kernel@vger.kernel.org>
References: <aa34f38e-5e55-bdb2-133c-016b91245533@linux.alibaba.com>
 <20190418063218.GA6567@dhcp22.suse.cz>
 <bb2464c9-dc45-eff1-b9ac-f29105ccd27b@linux.alibaba.com>
 <20190419111356.GK18914@techsingularity.net>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <e48a5899-7139-ba76-46e9-76bda4a7ab78@linux.alibaba.com>
Date: Fri, 19 Apr 2019 09:28:21 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190419111356.GK18914@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 4/19/19 4:13 AM, Mel Gorman wrote:
> On Thu, Apr 18, 2019 at 09:18:15AM -0700, Yang Shi wrote:
>>
>> On 4/17/19 11:32 PM, Michal Hocko wrote:
>>> On Wed 17-04-19 21:15:41, Yang Shi wrote:
>>>> Hi folks,
>>>>
>>>>
>>>> I noticed that there might be new THP allocation in NUMA fault migration
>>>> path (migrate_misplaced_transhuge_page()) even when THP is disabled (set to
>>>> "never"). When THP is set to "never", there should be not any new THP
>>>> allocation, but the migration path is kind of special. So I'm not quite sure
>>>> if this is the expected behavior or not?
>>>>
>>>>
>>>> And, it looks this allocation disregards defrag setting too, is this
>>>> expected behavior too?H
>>> Could you point to the specific code? But in general the miTgration path
>> Yes. The code is in migrate_misplaced_transhuge_page() called by
>> do_huge_pmd_numa_page().
>>
>> It would just do:
>> alloc_pages_node(node, (GFP_TRANSHUGE_LIGHT | __GFP_THISNODE),
>> HPAGE_PMD_ORDER);
>> without checking if transparent_hugepage is enabled or not.
>>
>> THP may be disabled before calling into do_huge_pmd_numa_page(). The
>> do_huge_pmd_wp_page() does check if THP is disabled or not. If THP is
>> disabled, it just tries to allocate 512 base pages.
>>
>>> should allocate the memory matching the migration origin. If the origin
>>> was a THP then I find it quite natural if the target was a huge page as
>> Yes, this is what I would like to confirm. Migration allocates a new THP to
>> replace the old one.
>>
>>> well. How hard the allocation should try is another question and I
>>> suspect we do want to obedy the defrag setting.
>> Yes, I thought so too. However, THP NUMA migration was added in 3.8 by
>> commit b32967f ("mm: numa: Add THP migration for the NUMA working set
>> scanning fault case."). It disregarded defrag setting at the very beginning.
>> So, I'm not quite sure if it was done on purpose or just forgot it.
>>
> It was on purpose as migration due to NUMA misplacement was not intended
> to change the type of page used. It would be impossible to tell in advance
> if locality was more important than the page size from a performance point
> of view. This is particularly relevant if the workload is virtualised and
> there is an expectation that huge pages are preserved.  I'm not aware of
> any bugs whereby there was a complaint that the THP migration caused an
> excessive stall. It could be altered of course, but it would be preferred
> to have an example workload demonstrating the problem before making a
> decision.

Thanks a lot for elaborating the idea. I didn't run into any problem at 
the moment, just didn't get the thinking behind the choice since other 
page fault paths (i.e. wp) do allocate hugepages more aggressively.

>

