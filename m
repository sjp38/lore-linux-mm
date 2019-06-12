Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 939F6C31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 05:06:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02E1420896
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 05:06:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02E1420896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 614D86B0003; Wed, 12 Jun 2019 01:06:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C5FC6B0005; Wed, 12 Jun 2019 01:06:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B5976B0006; Wed, 12 Jun 2019 01:06:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 12B356B0003
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 01:06:46 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x9so11197751pfm.16
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 22:06:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=4uedWlOrHcx8sPBuVPwGjNWVQX4sp7zvNXORW31pKVs=;
        b=ZeaCKqGKfAR8n/pvRdC7GujxCtkTQlGGqM4XfHO4Ww15IbfbIFLqWKhrZH2UFkJF4B
         zJ7nWYJ/dKsgALaRWkqSTLAR/RjB3RPbLImopQbqOD/in90YJTy1iKkgxeGbc1vHC+iB
         3PCCyPb3mrqWaDkAWN9JFvf6D0f7aUH5PZDYIBLOdhgmLk20AJqH9yv5fXVpKxOvm6eV
         Wfzm2A7pu6E8nDI5tFF9+5zaWHklJqk7FF5qjj59ttiAB55wXSPiLnW9BpKywE+0xqVi
         CgeXfM8DGjri/LMq4BVgmikhrh05OJaViNHT0f4hIuMJHpqWoWCoipu1vO52PQZdhvM5
         PQew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWhPKgwbYE/MhIBsdq7XknciMyj3lrUA1c7DO1PLkBQQsj8FdOb
	nAQC2MtYyuEbBQc5QPe7u+9UwuXJYB263IA2s95y9kM33/0gjGBMC07YUIfWm40FzaZr8utSgMD
	8iHY1msNzDnkcx23horFuD4u/9suVRPwpzpd3IApktllRc/XS2oxr8nRnuYQL0GkJAQ==
X-Received: by 2002:a62:2b81:: with SMTP id r123mr43183589pfr.108.1560316005695;
        Tue, 11 Jun 2019 22:06:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy9VjvzV9ZgdNF57O4a3zuuQezEJIMlpfm8jCTf/CYj9OZiQzfGaESPfJlCC/4l4Y3yS3Ri
X-Received: by 2002:a62:2b81:: with SMTP id r123mr43183537pfr.108.1560316004860;
        Tue, 11 Jun 2019 22:06:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560316004; cv=none;
        d=google.com; s=arc-20160816;
        b=smyLkj7jMmM9fueXm1EBNJCqO+X0x+VRrRoV54cK2bUW+4bHi6M7EJPJLdQbthZlpQ
         F2Hg6OJqJ670ZYo70FTYKOsXHJTvEqmAMWpVBVOgDhW7bT0FA4h+3hdKpdZ6wwmdMgUK
         0HJfl9pKk+Mz4mCrk1VmDOIELJTnH2RR+XZG7nkX4C4gy5OWEEMbGX7WL7lOZ3AuaqOs
         8HnnrWlnKMym7PzRkw2VSCk0Q9dU7PTbWbRBUUApgH3c7vhaTDcT9HTCZ2tEoNEntist
         2Q9lrBMHG5VSgn6O1BcEYiBAd3BaUMlFzcJZ4mzuQ/vVs08nrVFKTs+5c6zfAcIKPkmq
         HOVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=4uedWlOrHcx8sPBuVPwGjNWVQX4sp7zvNXORW31pKVs=;
        b=a5/kKQYXyfpFCGnIDpCoSibAAb78kfB2ZLyYOM+SS3NG3/0jNA7GXR+E8M/0inHlCY
         UQo+TvQ+xAvvh+oTEN1CFPByvj02/taSO/m7NHKcxlovLuAS46C59jdrPX53Bb3poC7A
         3kDQkiCcTrJigdyukB6prbFLzrZWnMDymH9CTp/FkMJw4e1urc6TTArXvuHk4eCqxJvs
         jRY3+FUNlx6P51LaXEff03ceEnipp4yvMvhZOEAODGxm7T08hg9ZdXdsHQDxfHIDInhi
         5eFSbQnAj2OgjkaRpMGowfR9e5RNwlXTmModNC2EWikDn0/0x8u6n7x0KoxoIzcRtUC2
         W9/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com. [115.124.30.54])
        by mx.google.com with ESMTPS id z25si13970061pgv.418.2019.06.11.22.06.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 22:06:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) client-ip=115.124.30.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04423;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0TTyFFvH_1560315997;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TTyFFvH_1560315997)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 12 Jun 2019 13:06:41 +0800
Subject: Re: [PATCH 2/4] mm: thp: make deferred split shrinker memcg aware
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: ktkhai@virtuozzo.com, kirill.shutemov@linux.intel.com,
 hannes@cmpxchg.org, mhocko@suse.com, hughd@google.com, shakeelb@google.com,
 rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1559887659-23121-1-git-send-email-yang.shi@linux.alibaba.com>
 <1559887659-23121-3-git-send-email-yang.shi@linux.alibaba.com>
 <20190612024747.f5nsol7ntvubjckq@box>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <ace52062-e6be-a3f2-7ef1-d8612f3a76f9@linux.alibaba.com>
Date: Tue, 11 Jun 2019 22:06:36 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190612024747.f5nsol7ntvubjckq@box>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/11/19 7:47 PM, Kirill A. Shutemov wrote:
> On Fri, Jun 07, 2019 at 02:07:37PM +0800, Yang Shi wrote:
>> +	/*
>> +	 * The THP may be not on LRU at this point, e.g. the old page of
>> +	 * NUMA migration.  And PageTransHuge is not enough to distinguish
>> +	 * with other compound page, e.g. skb, THP destructor is not used
>> +	 * anymore and will be removed, so the compound order sounds like
>> +	 * the only choice here.
>> +	 */
>> +	if (PageTransHuge(page) && compound_order(page) == HPAGE_PMD_ORDER) {
> What happens if the page is the same order as THP is not THP? Why removing

It may corrupt the deferred split queue since it is never added into the 
list, but deleted here.

> of destructor is required?

Due to the change to free_transhuge_page() (extracted deferred split 
queue manipulation and moved before memcg uncharge since 
page->mem_cgroup is needed), it just calls free_compound_page(). So, it 
sounds pointless to still keep THP specific destructor.

It looks there is not a good way to tell if the compound page is THP in 
free_page path or not, we may keep the destructor just for this?

>

