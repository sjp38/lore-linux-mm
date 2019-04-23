Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9704FC10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 09:41:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55C372077C
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 09:41:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55C372077C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D21D46B0007; Tue, 23 Apr 2019 05:41:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD1416B000A; Tue, 23 Apr 2019 05:41:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE8E16B000C; Tue, 23 Apr 2019 05:41:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 864276B0007
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 05:41:13 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id p8so9404942pfd.4
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 02:41:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=2uob2F3Kx6TW0ByX6Nfo89dOAaZeH4eT8fFX6/yrdPw=;
        b=JOeQA1Pr9x1ovgCVDazULX1zVvtVl3PDbrb4WpYqTvxuh8iS9ZJvBzhxbxORB6FJz+
         FqEnMeVnoEBTSu+NnyawAoPaKRqtd6QAkV6iulCpsbhL53Dr6ExSq/viTrEhOeazK2dv
         dZ/LR/QFLcMvBh5uMYXIhrNuxvxGR6uI4pe94GY/KK1DCw/afJLDZuCkZgIragGQZhw9
         78v8/m5OfPcrrkLLfWyDbCLGozOnaRhYfgS1dC9CxOT54v2fcAB8Ye8jTYyM/Wf838J6
         mpNRyAqgN+pK3KDmlEclLbAgILcaV/MHZ5RGBIVzqQDgnsLzE2qg1hS/LAFOh9Jb9ukE
         gMNA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXfSJERTLIzOSuhQJewhO8VQ+Hn4TqDW9MTnRqNiKvs/HkqDMR3
	bDKATiCkClBDj1qFebgT56Smt2dPVe+PH6UmPtwXf3u6Qr3SF4FK8ffCqr2fklC4eUhmLlywQim
	r+GJt5mZth6DDldPh4pw15aaRFKoY6WW+8L2Zo1IF5V7wZe0y2rJ/CzF/Rr8v7xqfhA==
X-Received: by 2002:a62:292:: with SMTP id 140mr26395399pfc.206.1556012473203;
        Tue, 23 Apr 2019 02:41:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxohdDfAfMvZ2GCbAIV3bW6HuEvnPMILoj5Thw+aV1+eKxvfvO6C+L3MiTgYNlHzilkHbLB
X-Received: by 2002:a62:292:: with SMTP id 140mr26395349pfc.206.1556012472492;
        Tue, 23 Apr 2019 02:41:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556012472; cv=none;
        d=google.com; s=arc-20160816;
        b=oMqqQout9v2/03CV++/wSwqZdpaw8BMurGMXe2QisUbP73q4wAVIyFxnJkqUJy9M4Q
         kiH+wgYFJylNX1PpoVMIM647WLsLttmI8MI1QYiO6ZZ5YQovjRuVQ0qToVRBDDo2SZyu
         DBLr1EcuGuMsYLOwj2wJFZsqrlytOp/z91Qr40OQwvPDDOIZaK1OlSKdCUPUzb7dVMPg
         HPBRYjVSkbPDjCYctzUDJx/cVbKc93I9TuboyUm0ygmbllPwl3KwIB08gUYHK96J/3dZ
         jh3HKWA/4Jm7ckDvBN93zyL8D6jV4rPXzVP0aO96zE84dzlTUbu4dM6jeOkxRlmirFrJ
         7Bjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=2uob2F3Kx6TW0ByX6Nfo89dOAaZeH4eT8fFX6/yrdPw=;
        b=f2KP8I3eu8gLMIY2SSBsiukXvzsoumbVK6w/wPuOXkWg5GLczOiDvpxuvPxeZOlYSJ
         VSBy0AAS1jT0DsmVi3nIrjRTcK5eqGCUoIDNFLQxevWBQrVIdUl9f0tHebkXPZVoRscr
         vhRVBnBlu9GofuzwimyJ7DlXBCfmfLCBQuUtW/AHTsOFAaCCkD71vHeINej64eFkX0cO
         6xEB6m/bYIpQkLz5R/6bMOtlaiZlIYIF3ad598sZQSX9fdzbsLHpdvaZeFMnESS1LGL5
         C+vsARg+bti1XadG3AADDT2nuxGLDEJEhArOlVbUyqNvcS3CRPXm93kdQPcc5cH8D2YB
         DYWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id y193si14374415pgd.483.2019.04.23.02.41.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 02:41:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e01422;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TQ1rapc_1556012469;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TQ1rapc_1556012469)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 23 Apr 2019 17:41:10 +0800
Subject: Re: [RFC PATCH 3/5] numa: introduce per-cgroup preferred numa node
To: Peter Zijlstra <peterz@infradead.org>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
 Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <77452c03-bc4c-7aed-e605-d5351f868586@linux.alibaba.com>
 <20190423085533.GF11158@hirez.programming.kicks-ass.net>
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Message-ID: <e5e39d99-2b7a-db27-5aa0-ecc8d064257b@linux.alibaba.com>
Date: Tue, 23 Apr 2019 17:41:09 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190423085533.GF11158@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019/4/23 下午4:55, Peter Zijlstra wrote:
> On Mon, Apr 22, 2019 at 10:13:36AM +0800, 王贇 wrote:
>> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>> index af171ccb56a2..6513504373b4 100644
>> --- a/mm/mempolicy.c
>> +++ b/mm/mempolicy.c
>> @@ -2031,6 +2031,10 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
>>
>>  	pol = get_vma_policy(vma, addr);
>>
>> +	page = alloc_page_numa_preferred(gfp, order);
>> +	if (page)
>> +		goto out;
>> +
>>  	if (pol->mode == MPOL_INTERLEAVE) {
>>  		unsigned nid;
>>
> 
> This I think is wrong, it overrides app specific mbind() requests.

The original concern is that we scared the user apps insider cgroup deal
wrong with memory policy and do bad behavior, but now I agree that we
should not override the policy, the admin will take the responsibility.

Regards,
Michael Wang

> 

