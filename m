Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35541C10F00
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 08:13:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1FD9218D3
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 08:13:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1FD9218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E2956B0003; Thu, 21 Mar 2019 04:13:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 894486B0006; Thu, 21 Mar 2019 04:13:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7832E6B0007; Thu, 21 Mar 2019 04:13:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 218C26B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 04:13:47 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z98so1928487ede.3
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 01:13:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=PHU5eqGCOBoQmIQBBLjbNbMCKhob/+FBO3i8mLGlMLw=;
        b=WlaL+h702GN+LkvoxkHQmUM1vPjzh7stcixfNEmbt7HAoCuwxMnJbTvNqHM7JGQg31
         P/VMzaioxs9HYiTK9EuUcTJ7P2Yx9DqIq7UTMqik9TdljdOcotqENTMzV5nnLmmWxjkN
         Orx8PIC/Wa77Vhane7BxSll4pdeKDJFGBqsh1nFfXjVvoFHt4qZPI/Co2pbeAlNmBzFG
         rqTCknUhZSV/8I72aL2OB7mEgOODcuA2yLRVEqmL/tN4fROhVDi2i1faMCOoQHNkQaf9
         l4XFHcV51VXr46IwaOI4PRRswNVQFv+PMGpq8Oj5ByPEc5NFBcMwvWMJ7e//n0orjjY9
         tnKg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAX0u7sB4SFFGZ/jekzA2lKWBS/E5v/tMUKBkNG4tyA8Gk0+x+tt
	opkAcL4AH24pXv2kxmUUakT+eZDHKBkFsBTDTHFONdkMFdH8NkEQv85rRVdeAvFOAo/MX60AyU7
	j9gxtAMieQAxgdya/KLchE8ygegMUFyGtuk2iL8jL1L5fyDqo1YQ7wl7T3FxowTfmRg==
X-Received: by 2002:a50:b1d4:: with SMTP id n20mr1569134edd.108.1553156026700;
        Thu, 21 Mar 2019 01:13:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzeV46extbDbuxwDS5KKR7DWSEb/aJAL6kvCWHrKLazrbSh6SCISdnzjOWnYSLH9xQTmvuD
X-Received: by 2002:a50:b1d4:: with SMTP id n20mr1569098edd.108.1553156025931;
        Thu, 21 Mar 2019 01:13:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553156025; cv=none;
        d=google.com; s=arc-20160816;
        b=mPYvmeI1AWU1HM0bb+Jhk1c2yq8kvcY9Xt32wHSqyp+rUz4Ztvx+E4TzI6DWTP9IkO
         1d+75Z4Zdgbokkc4c6PT7dkGZ6aiNubKx4vzAmZVTEZpRHd32EorNLBBZvyNtOLOVBAu
         1fnfKCb1e4KfjOdIJ9Ku+hptScp/66NCoQIM5Uwg7eLcB6ea4asTLc2iZ2oefmMSrXlk
         j/9VICBPpQ/xfPShb57bwynF6ad0Ody/Yrvs4XE1FZiKFMau3npvwu/lEDuhr/oH8hc9
         9PHgQo+B/Mvfw2cC8nVi+KJ0PDPc/6Nqg+ArFDaCQRlkL+Fbp4My7RxxGicl0EGSeoU7
         9bHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=PHU5eqGCOBoQmIQBBLjbNbMCKhob/+FBO3i8mLGlMLw=;
        b=Lxi4QVWIcCvB6n3c78OyrNdXpK/w5URfXlmqByI+q0PJegupyNDXceeiAT8WpllNx6
         jhubOKQKj2ODp9ho4l3dgX9wuMoV7tXzIouTa6Caz7Vo5BVX5L8e/ZffZzEZalTRg42y
         IX7IwnGUZauIssa1ZkxUNyuTJUpl5R2Nyt2xZQ4lj8PS2/bRKLB1ASG9f6coVaY8UIgb
         LnGWKkV/CgkFSbj3p02FeAPNgE1gG09dQc0twQKxbT5IjwosarXqGOMcOa2fO8u0lsfe
         c13LOg1T9Yd04uHE8Z9QD17Ot07r5879zmTbc4JJnbhWSu1UXvRpq7jtENA5HGwwQxRy
         StBg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t32si1744111edd.442.2019.03.21.01.13.45
        for <linux-mm@kvack.org>;
        Thu, 21 Mar 2019 01:13:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id DFB4080D;
	Thu, 21 Mar 2019 01:13:44 -0700 (PDT)
Received: from [10.162.42.102] (p8cg001049571a15.blr.arm.com [10.162.42.102])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D22803F71A;
	Thu, 21 Mar 2019 01:13:42 -0700 (PDT)
Subject: Re: [PATCH] mm/isolation: Remove redundant pfn_valid_within() in
 __first_valid_page()
To: Michal Hocko <mhocko@kernel.org>
Cc: Zi Yan <ziy@nvidia.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, mike.kravetz@oracle.com, osalvador@suse.de,
 akpm@linux-foundation.org
References: <1553141595-26907-1-git-send-email-anshuman.khandual@arm.com>
 <8AB57711-48C0-4D95-BC5F-26B266DC3AE8@nvidia.com>
 <cda4f247-4eea-decf-3f4a-3dc09364de27@arm.com>
 <20190321080702.GG8696@dhcp22.suse.cz>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <8a6b3968-a315-07ce-0491-2a5acdd49ab4@arm.com>
Date: Thu, 21 Mar 2019 13:43:40 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190321080702.GG8696@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 03/21/2019 01:37 PM, Michal Hocko wrote:
> On Thu 21-03-19 11:03:18, Anshuman Khandual wrote:
>>
>>
>> On 03/21/2019 10:31 AM, Zi Yan wrote:
>>> On 20 Mar 2019, at 21:13, Anshuman Khandual wrote:
>>>
>>>> pfn_valid_within() calls pfn_valid() when CONFIG_HOLES_IN_ZONE making it
>>>> redundant for both definitions (w/wo CONFIG_MEMORY_HOTPLUG) of the helper
>>>> pfn_to_online_page() which either calls pfn_valid() or pfn_valid_within().
>>>> pfn_valid_within() being 1 when !CONFIG_HOLES_IN_ZONE is irrelevant either
>>>> way. This does not change functionality.
>>>>
>>>> Fixes: 2ce13640b3f4 ("mm: __first_valid_page skip over offline pages")
>>>
>>> I would not say this patch fixes the commit 2ce13640b3f4 from 2017,
>>> because the pfn_valid_within() in pfn_to_online_page() was introduced by
>>> a recent commit b13bc35193d9e last month. :)
>>
>> Right, will update the tag with this commit.
> 
> The patch is correct but I wouldn't bother to add Fixes tag at all. The
> current code is obviously not incorrect. Do you see any actual

Sure.

> performance issue?
> 

No. Just from code inspection. pfn_valid() is anyways expensive on arm64
because of the memblock search so why to make it redundant as well.

