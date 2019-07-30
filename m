Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29A52C32750
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 22:28:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8AC3206E0
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 22:28:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8AC3206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 79E368E0003; Tue, 30 Jul 2019 18:28:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77D798E0001; Tue, 30 Jul 2019 18:28:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 664668E0003; Tue, 30 Jul 2019 18:28:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 321AB8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 18:28:16 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id q11so36116555pll.22
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 15:28:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:reply-to
         :subject:to:cc:references:from:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=jbK8JULC9SJ6pDOMm9cfN8qfqr2zIleYy2L1Zt/un+A=;
        b=baxvPNv46rfelsMCf3R2KilsPppjUWknNuQVt5UuCDY+xiTShqALpMqskxZ2ulzorG
         sXUFhrwBAb3xDhKZMGHpeVtEIclz0WzXf1W66OEoKbAwWQbw8r+djxU5NB3IJD4SjzKO
         wbbBX9FJTF3SG7+27zQlAr11ciM1CofunGS3V/lftIS4MbOjT++75ijAX8F3b7FBhIzC
         OnZ8WCXja1rdDCu1pNkzNh8SKNBV9EXt/35lPvPHqCrH89bDdvkcGx0/BhzC/2Tlsure
         Ec2WECo1F4psE/ERjO+cHfJKotiU0dh6mtZm+mQfiM/vJBXEns2b4DzSLIHymkZtOSxT
         pCVQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of sathyanarayanan.kuppuswamy@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=sathyanarayanan.kuppuswamy@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUzxCWOlqzTO5RVGFaWtezmgM8CLJpuG7iWFKpmnju+fay+Xabu
	K3Afm4SLoiwDNz7KLASoxzHDWhl+N2Ko7j7B4WxlGHqtSWXec1OHO6AZ7jSVFwo9jCoLVcN3mvu
	klIUOqVVf56mM3ZoKcxPcnP+9I5Dm8uAZfTGL6Gcam6bH08Ud7fXvLaQY7P/LpJ2ZFw==
X-Received: by 2002:aa7:96ad:: with SMTP id g13mr45976883pfk.182.1564525695821;
        Tue, 30 Jul 2019 15:28:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyLSyFYl0FlA/vYW9PtDsIy+oheTDH2nB4Q9/n/i/ZrABBl2wEFDYufX4S62I/qAB6yVfr
X-Received: by 2002:aa7:96ad:: with SMTP id g13mr45976839pfk.182.1564525695011;
        Tue, 30 Jul 2019 15:28:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564525695; cv=none;
        d=google.com; s=arc-20160816;
        b=n3r6rdSV1RC+xywpThbMrtEgg9+SP3y8FitZMi7XpoCn+Lo2yHygwBzH3pQFSpZBjO
         U7FQRA3qgI8NT4LVVUo0OUMC7qgPmYj6p0OWJCAqvQjFAxqbPxJEDTne8HxHqn5rQa4h
         adXlB1ym8rkZTRX8HkU6H0WpHGcmR6I8pQZZOZnTN+jEFPsq4+wgDD3101htFSKTYb0A
         VoHbjHKYlZ4Q9WgSB+600n1pgw+rBjBxWTV6n3Q1fyRfZJG1yKlGDpq49JlehysEWL1z
         uqMN5jvct5dM7kE+Fb+OcHfHPYEPpVwuzQPklFoTi0Ly4aYjnfwz1lmHTzCsWBwKEN8W
         g4JQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:reply-to;
        bh=jbK8JULC9SJ6pDOMm9cfN8qfqr2zIleYy2L1Zt/un+A=;
        b=pQJOr7xJ8mDjSd7jz5LRrQUwP22N6RdmK8QefBFaF28kF/nA1QYr79peVNWtCFc463
         rCYd2StYHJk+UdrmjYk496b8X3EbNdWIOM28N8JwM+iAa8xpKyX2bs4fGGExxdAm+KVM
         nLw+AlDlDK1Lco6R/pvwsEULM6HcgldbKFXicQZQJPlFqHoIaXRzTwKI/ioiKRooJAuQ
         A9xDAtgYraifO+hIIBkioiyjcb/hTMwHvL9Lg3Jy2kTI+Q1uHJyr3NjYQZb1iXFPdhpX
         KCDAi9tlol+w5y19zKnHT0fA20o010ECKOuGJQer5US/0yE5ngyDkAm85XUXOFGymxpE
         RUhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of sathyanarayanan.kuppuswamy@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=sathyanarayanan.kuppuswamy@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id x9si29886367plo.98.2019.07.30.15.28.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 15:28:14 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of sathyanarayanan.kuppuswamy@linux.intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of sathyanarayanan.kuppuswamy@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=sathyanarayanan.kuppuswamy@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 30 Jul 2019 15:28:14 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,327,1559545200"; 
   d="scan'208";a="183424035"
Received: from linux.intel.com ([10.54.29.200])
  by orsmga002.jf.intel.com with ESMTP; 30 Jul 2019 15:28:14 -0700
Received: from [10.54.74.33] (skuppusw-desk.jf.intel.com [10.54.74.33])
	by linux.intel.com (Postfix) with ESMTP id 1919558060A;
	Tue, 30 Jul 2019 15:28:14 -0700 (PDT)
Reply-To: sathyanarayanan.kuppuswamy@linux.intel.com
Subject: Re: [PATCH v1 1/1] mm/vmalloc.c: Fix percpu free VM area search
 criteria
To: Dennis Zhou <dennis@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Uladzislau Rezki <urezki@gmail.com>,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190729232139.91131-1-sathyanarayanan.kuppuswamy@linux.intel.com>
 <20190730204643.tsxgc3n4adb63rlc@pc636>
 <d121eb22-01fd-c549-a6e8-9459c54d7ead@intel.com>
 <9fdd44c2-a10e-23f0-a71c-bf8f3e6fc384@linux.intel.com>
 <20190730215535.GA67664@dennisz-mbp.dhcp.thefacebook.com>
From: sathyanarayanan kuppuswamy <sathyanarayanan.kuppuswamy@linux.intel.com>
Organization: Intel
Message-ID: <e4dd0282-9d36-2398-5e8c-2ac5527744a0@linux.intel.com>
Date: Tue, 30 Jul 2019 15:25:42 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190730215535.GA67664@dennisz-mbp.dhcp.thefacebook.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/30/19 2:55 PM, Dennis Zhou wrote:
> On Tue, Jul 30, 2019 at 02:13:25PM -0700, sathyanarayanan kuppuswamy wrote:
>> On 7/30/19 1:54 PM, Dave Hansen wrote:
>>> On 7/30/19 1:46 PM, Uladzislau Rezki wrote:
>>>>> +		/*
>>>>> +		 * If required width exeeds current VA block, move
>>>>> +		 * base downwards and then recheck.
>>>>> +		 */
>>>>> +		if (base + end > va->va_end) {
>>>>> +			base = pvm_determine_end_from_reverse(&va, align) - end;
>>>>> +			term_area = area;
>>>>> +			continue;
>>>>> +		}
>>>>> +
>>>>>    		/*
>>>>>    		 * If this VA does not fit, move base downwards and recheck.
>>>>>    		 */
>>>>> -		if (base + start < va->va_start || base + end > va->va_end) {
>>>>> +		if (base + start < va->va_start) {
>>>>>    			va = node_to_va(rb_prev(&va->rb_node));
>>>>>    			base = pvm_determine_end_from_reverse(&va, align) - end;
>>>>>    			term_area = area;
>>>>> -- 
>>>>> 2.21.0
>>>>>
>>>> I guess it is NUMA related issue, i mean when we have several
>>>> areas/sizes/offsets. Is that correct?
>>> I don't think NUMA has anything to do with it.  The vmalloc() area
>>> itself doesn't have any NUMA properties I can think of.  We don't, for
>>> instance, partition it into per-node areas that I know of.
>>>
>>> I did encounter this issue on a system with ~100 logical CPUs, which is
>>> a moderate amount these days.
>> I agree with Dave. I don't think this issue is related to NUMA. The problem
>> here is about the logic we use to find appropriate vm_area that satisfies
>> the offset and size requirements of pcpu memory allocator.
>>
>> In my test case, I can reproduce this issue if we make request with offset
>> (ffff000000) and size (600000).
>>
>> -- 
>> Sathyanarayanan Kuppuswamy
>> Linux kernel developer
>>
> I misspoke earlier. I don't think it's numa related either, but I think
> you could trigger this much more easily this way as it could skip more
> viable vma space because it'd have to find more holes.
>
> But it seems that pvm_determine_end_from_reverse() will return the free
> vma below the address if it is aligned so:
>
>      base + end > va->va_end
>
> will always be true and then push down the searching va instead of using
> that va first.

It won't be always true. Initially base address is calculated as below:

base = pvm_determine_end_from_reverse(&va, align) - end;

So for first iteration it will not fail.
>
> Thanks,
> Dennis
>
-- 
Sathyanarayanan Kuppuswamy
Linux kernel developer

