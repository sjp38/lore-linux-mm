Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4701AC32751
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 21:16:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0287B217D4
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 21:15:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0287B217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7AF4C8E0003; Tue, 30 Jul 2019 17:15:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 760B68E0001; Tue, 30 Jul 2019 17:15:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 650318E0003; Tue, 30 Jul 2019 17:15:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 304A88E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 17:15:59 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id m19so26914810pgv.7
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 14:15:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:reply-to
         :subject:to:cc:references:from:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=GhyoLKyG0uJOFlq1UGbCgWs1Ot1gFTXDuOPjy2wlxWk=;
        b=A6EfdbzcEdef54PHbczKlt6uyBMENYOEQrELZh00IxvWSRPmTQ/EJgGqu7kYWze4Pl
         Fy0JpWJAExyHkToRw4l5/wWiP2yzjXuxW7PF8Oiy8gidrj1POwLqS/z65MdiGU0B/4ZZ
         7T8cj4PH8YmKMaZL73jb85Pvg9X5188FIDRgyHR7QigREUMuw22GWLgJU9EHuCFx/zEV
         o+F/n5jay9jxv2qITEkSisQ3qUzzzUWjP/Emn8Z16b3IGV2AqwLg3TbcGYmFu/PqPCqF
         uo21s+18MCFb6A9h8Cg1qyXPkAkKU/qJIIDssIrrghJXJdYhDcklVmXXoNcWDT7/lVl4
         ftuw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of sathyanarayanan.kuppuswamy@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=sathyanarayanan.kuppuswamy@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW+Tw24BPBM7+iRyq2fySBjHLpwbPcN4RXxoozCRMazTir2moWQ
	BrgegJq7YTGe/ES0sDv+azBelKJKemNByj5UICvFhLHuKOO6PvZuKuyi8vnkxvXykAKat3FbL12
	ozy3dy7cGx44iHbc2/Oi2I+kB65QYCMdHjzjWSoaYqab+09Fnoy+VSb827cqgJx0JXg==
X-Received: by 2002:a17:902:9349:: with SMTP id g9mr115084026plp.262.1564521358885;
        Tue, 30 Jul 2019 14:15:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz/BiMlQZiZgdNIRHEFlZe8lfWHBwlqIoC7dy22hzkj8zGEVP4IaWffZ6YkDUZrO8/gQkRU
X-Received: by 2002:a17:902:9349:: with SMTP id g9mr115083983plp.262.1564521358146;
        Tue, 30 Jul 2019 14:15:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564521358; cv=none;
        d=google.com; s=arc-20160816;
        b=CN92uQZ09vOVYGlJr/vmzNzby2NEPqIaCJ0d7/kkbuupLfIEgB+IJZp1Vm/bCjuWdJ
         s7SeW9SWIQ0KFGzYjLB9DvKw1mwRvtRDHWlHCVOeahXQfm1ql08gpQIYlwVT/+QKYwRE
         0cUw9+TQ7SVvcVawM8hmec9+KqjMnuH1tlV9LvsqIONBFNmOdW8Bx5aW1fXVgy7J5kIe
         jW9HTz4OkaMVGIoHvLAIa526oZRDTQFzj4YuS9CdWjDi4WVpSYcrE5nQPflX3OwgNGCR
         HEP8LjXPrcCKM+9NkfMk1nxd4fIGBk8Ka/rWCzyTjkt7d+/zTPy+pLphvYShLS4PtGK4
         xcow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:reply-to;
        bh=GhyoLKyG0uJOFlq1UGbCgWs1Ot1gFTXDuOPjy2wlxWk=;
        b=feJwAGTIYmLcd5Td4UU1Shp10v95CnGR/T6sFpkN0L8YdzxcCpKWEWy5aGsmBr4QWZ
         ZsDQvvXpFISj7dAu4M0a8nmkRrNsmDQLj0vJgjxcNL9UcqxjJxSeGKUpdo6VuEmyNKPk
         tPsoLxoqY+QESDNm3FVMr4z9uz99N/Hy3h2I9pXEZWLJRvdncyDLGE1fD9uYitGc7HRu
         jBTuN/dUcHjJOhuHdwMDbDP8E6QncaagsOCqhZY3f8vOfKu1H6yi36zTrD7yT/AZItlD
         lTgmkIAMjFJ0ZFXEAdY0Zld05ftj6hWLs7g7G6GIZeuYeogq9llEEgTK2SnjbvHKSCFx
         Uqgw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of sathyanarayanan.kuppuswamy@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=sathyanarayanan.kuppuswamy@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id q15si29938072pfh.284.2019.07.30.14.15.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 14:15:58 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of sathyanarayanan.kuppuswamy@linux.intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of sathyanarayanan.kuppuswamy@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=sathyanarayanan.kuppuswamy@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 30 Jul 2019 14:15:57 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,327,1559545200"; 
   d="scan'208";a="196059110"
Received: from linux.intel.com ([10.54.29.200])
  by fmsmga004.fm.intel.com with ESMTP; 30 Jul 2019 14:15:57 -0700
Received: from [10.54.74.33] (skuppusw-desk.jf.intel.com [10.54.74.33])
	by linux.intel.com (Postfix) with ESMTP id DA4F65803A5;
	Tue, 30 Jul 2019 14:15:56 -0700 (PDT)
Reply-To: sathyanarayanan.kuppuswamy@linux.intel.com
Subject: Re: [PATCH v1 1/1] mm/vmalloc.c: Fix percpu free VM area search
 criteria
To: Dave Hansen <dave.hansen@intel.com>, Uladzislau Rezki <urezki@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190729232139.91131-1-sathyanarayanan.kuppuswamy@linux.intel.com>
 <20190730204643.tsxgc3n4adb63rlc@pc636>
 <d121eb22-01fd-c549-a6e8-9459c54d7ead@intel.com>
From: sathyanarayanan kuppuswamy <sathyanarayanan.kuppuswamy@linux.intel.com>
Organization: Intel
Message-ID: <9fdd44c2-a10e-23f0-a71c-bf8f3e6fc384@linux.intel.com>
Date: Tue, 30 Jul 2019 14:13:25 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <d121eb22-01fd-c549-a6e8-9459c54d7ead@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/30/19 1:54 PM, Dave Hansen wrote:
> On 7/30/19 1:46 PM, Uladzislau Rezki wrote:
>>> +		/*
>>> +		 * If required width exeeds current VA block, move
>>> +		 * base downwards and then recheck.
>>> +		 */
>>> +		if (base + end > va->va_end) {
>>> +			base = pvm_determine_end_from_reverse(&va, align) - end;
>>> +			term_area = area;
>>> +			continue;
>>> +		}
>>> +
>>>   		/*
>>>   		 * If this VA does not fit, move base downwards and recheck.
>>>   		 */
>>> -		if (base + start < va->va_start || base + end > va->va_end) {
>>> +		if (base + start < va->va_start) {
>>>   			va = node_to_va(rb_prev(&va->rb_node));
>>>   			base = pvm_determine_end_from_reverse(&va, align) - end;
>>>   			term_area = area;
>>> -- 
>>> 2.21.0
>>>
>> I guess it is NUMA related issue, i mean when we have several
>> areas/sizes/offsets. Is that correct?
> I don't think NUMA has anything to do with it.  The vmalloc() area
> itself doesn't have any NUMA properties I can think of.  We don't, for
> instance, partition it into per-node areas that I know of.
>
> I did encounter this issue on a system with ~100 logical CPUs, which is
> a moderate amount these days.

I agree with Dave. I don't think this issue is related to NUMA. The 
problem here is about the logic we use to find appropriate vm_area that 
satisfies the offset and size requirements of pcpu memory allocator.

In my test case, I can reproduce this issue if we make request with 
offset (ffff000000) and size (600000).

>
-- 
Sathyanarayanan Kuppuswamy
Linux kernel developer

