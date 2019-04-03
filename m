Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7264AC10F0B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:57:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 376632133D
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:57:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 376632133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C47D26B027C; Wed,  3 Apr 2019 13:57:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF7D96B027D; Wed,  3 Apr 2019 13:57:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE6B36B027E; Wed,  3 Apr 2019 13:57:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5FCD06B027C
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 13:57:10 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n12so8002271edo.5
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 10:57:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=IQ9nnstDbPMxKjJQJzTG/jeVQIZQtwOINabybIT8hYI=;
        b=tx38izqEJkWmvKSWbQcvRL+ielKtLUxZexgHwtVEwoXbCVggpsqmM2d5GV9in5FgsM
         x+84ZgDUTgs6KzlS5GgbMP1evfXiScEm9biv6FU/NDyU/+Siy9fMxe6isRh651kr53l9
         C1t0t5d43fUbS7ls2Ww1D4Lps/B+MZZ+PwX6puLP63BjcB8f6T0fS6CWB9sgsTXDHomB
         M8ek0HzbQVXNWA5hyUvxZSiQdMjGxPT7Lp4/nWM9BZOv7EDxDTMnyJ7aebYOHEwZVEYI
         RJ5NvDEe1emQ0T8JnjByGkov+6u9vtLm1h6UJwgDNiWM2OYO4SMzstAztZLb+PJX8z2i
         THew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAUyK+QhS7Vve1K6BdPAaZUgDOHH6z8syQ6AHZVSqfN9LF0LtxgS
	xNA5TTz2i+XK9R35DKhE4d2WYikpnphKT2auEsd/VTWjDqJooOwI8TQi+dzYN8I1ISl6CaQctYY
	d+kqGeB//bIcJ4yPrF4EBIRIgCDkqevnsrxFR1UQwMKywfi14Mvo1WaZiqPUJ7a8gYw==
X-Received: by 2002:a50:ba8e:: with SMTP id x14mr611963ede.211.1554314229914;
        Wed, 03 Apr 2019 10:57:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTALQg1nllOd5m47YWLIU5ZQTrtotDjJagcjCWySqLSp2MI6CzZWBV0L8xe+jcIoAK7G8I
X-Received: by 2002:a50:ba8e:: with SMTP id x14mr611926ede.211.1554314228969;
        Wed, 03 Apr 2019 10:57:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554314228; cv=none;
        d=google.com; s=arc-20160816;
        b=uk49visRN495PCsSJwrgXhH6FKCGLdqdh/vHtpZGY0XSAjrVhHuvnEw5frKIJt8sHp
         W5kzDY2NBrtYncouf5aEQRh4rc/C1VetL+0oHXvvJ5NjJMdZYSa9QLMJ1EaP4Q94Cc9O
         WNssqqVt6YZ4I2q/J0XLiFgoqTxDj3JcmxPIPNrnsfe5HADcKkqNNaTAr3zT3kajyA83
         u0PlBCSvB6Fib5YHfnZ+3lFN2h16mFKYdOf5Ps95e4GaFmdoG6aT/ysz0CFFSYptbzvt
         74E8CX4eaqyP9XO43xC5Q+8fYE81qoPHhgps5OdQZ2SLMUaxiVIuff0v5iqfgIOaVTsH
         L3sg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=IQ9nnstDbPMxKjJQJzTG/jeVQIZQtwOINabybIT8hYI=;
        b=pO4cF4rzMZttry1roLahZs6t4S7aQQKUqZbuJB0HR+weqG9CKmk66tuPKf4Mur+RCc
         70igCSMPJOAIx5qx6kNoRvpM/KoclvJSQwUL44B4G3dTfjdPm/R4QtZ39BWOVcZkcFDg
         xfll+611EWtDIWqUHutTy+Jc4ACo5MQvb12aIQPV65WdTaBo4gdxXwQ3YuSTQW27bpvq
         aBwkN53dQ6hwpSjqAYSr01eVZ3J9AInMirl2N0RpZxDQBjz06a7pEIKdZw6mxgaWtuLL
         RuwzuTDKo8sZudBhBWcw2xahyDS2rgq9bj0tcL3aGsbY4VnAaHMYBJ6zVl7i5OGZCEXg
         B0HA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c48si3779939edc.283.2019.04.03.10.57.08
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 10:57:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id AF8DA80D;
	Wed,  3 Apr 2019 10:57:07 -0700 (PDT)
Received: from [10.1.196.75] (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 4AC263F721;
	Wed,  3 Apr 2019 10:57:04 -0700 (PDT)
Subject: Re: [PATCH 2/6] arm64/mm: Enable memory hot remove
To: Logan Gunthorpe <logang@deltatee.com>,
 Anshuman Khandual <anshuman.khandual@arm.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 akpm@linux-foundation.org, will.deacon@arm.com, catalin.marinas@arm.com
Cc: mark.rutland@arm.com, mhocko@suse.com, david@redhat.com, cai@lca.pw,
 pasha.tatashin@oracle.com, Stephen Bates <sbates@raithlin.com>,
 james.morse@arm.com, cpandya@codeaurora.org, arunks@codeaurora.org,
 dan.j.williams@intel.com, mgorman@techsingularity.net, osalvador@suse.de
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-3-git-send-email-anshuman.khandual@arm.com>
 <f2ea761c-49b2-88f6-14fa-5aaec57952cb@deltatee.com>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <85fbfe49-d49e-fd6e-21dd-ff4d9808610b@arm.com>
Date: Wed, 3 Apr 2019 18:57:02 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <f2ea761c-49b2-88f6-14fa-5aaec57952cb@deltatee.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/04/2019 18:32, Logan Gunthorpe wrote:
> 
> 
> On 2019-04-02 10:30 p.m., Anshuman Khandual wrote:
>> Memory removal from an arch perspective involves tearing down two different
>> kernel based mappings i.e vmemmap and linear while releasing related page
>> table pages allocated for the physical memory range to be removed.
>>
>> Define a common kernel page table tear down helper remove_pagetable() which
>> can be used to unmap given kernel virtual address range. In effect it can
>> tear down both vmemap or kernel linear mappings. This new helper is called
>> from both vmemamp_free() and ___remove_pgd_mapping() during memory removal.
>> The argument 'direct' here identifies kernel linear mappings.
>>
>> Vmemmap mappings page table pages are allocated through sparse mem helper
>> functions like vmemmap_alloc_block() which does not cycle the pages through
>> pgtable_page_ctor() constructs. Hence while removing it skips corresponding
>> destructor construct pgtable_page_dtor().
>>
>> While here update arch_add_mempory() to handle __add_pages() failures by
>> just unmapping recently added kernel linear mapping. Now enable memory hot
>> remove on arm64 platforms by default with ARCH_ENABLE_MEMORY_HOTREMOVE.
>>
>> This implementation is overall inspired from kernel page table tear down
>> procedure on X86 architecture.
> 
> I've been working on very similar things for RISC-V. In fact, I'm
> currently in progress on a very similar stripped down version of
> remove_pagetable(). (Though I'm fairly certain I've done a bunch of
> stuff wrong.)
> 
> Would it be possible to move this work into common code that can be used
> by all arches? Seems like, to start, we should be able to support both
> arm64 and RISC-V... and maybe even x86 too.
> 
> I'd be happy to help integrate and test such functions in RISC-V.

Indeed, I had hoped we might be able to piggyback off generic code for 
this anyway, given that we have generic pagetable code which knows how 
to free process pagetables, and kernel pagetables are also pagetables.

I did actually hack up such a patch[1], and other than 
p?d_none_or_clear_bad() being loud it does actually appear to function 
OK in terms of withstanding repeated add/remove cycles and not crashing, 
but all the pagetable accounting and other stuff I don't really know 
about mean it's probably not viable without a lot more core work.

Robin.

[1] 
http://linux-arm.org/git?p=linux-rm.git;a=commitdiff;h=75934a2c4f737ad9f26903861108d5b0658e86bb

