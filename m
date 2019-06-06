Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23365C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 08:08:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E7E6420673
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 08:08:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7E6420673
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8498D6B0269; Thu,  6 Jun 2019 04:08:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D37D6B026C; Thu,  6 Jun 2019 04:08:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E94C6B026D; Thu,  6 Jun 2019 04:08:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 25C2D6B0269
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 04:08:45 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d27so2545151eda.9
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 01:08:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=6uuOUw0MtzH6y5gvw/BW9BdxcQLNg5mXoHWYg+Blo1I=;
        b=NS+hxXAPwvM/NfyfVypAewbdGafDs/L+2ITq+BsXDhgJTupiBBVuhmRrqYR7PwpmNo
         xtdKCUiEhzxRfZWElFk518dXLM4OrpNFJlAMXwsPvlNOL8gjLYUyleyrDwZTlHxTAS66
         c0OPxl3ftVU6PLIhyx/3nOy8abpXZ/oqf5NMg7W4XvdoN/CjohgasU916u6dVyGn7c++
         pArUdeUw4/8JNGJAh4K3lKN3+SwH+oarwoPPjbSFnbjCy5bl2o/vyTcduks0MhGHlrCd
         KWz/GyVSqCFsWmhZmAxJCk3M6xU4AY7HxhFT/YMJaipRM/99ZzgHI9tkDO9b1k08qTod
         Xwog==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUSonFeooV0AJw8BIEvGR3oZMlCRoyjN87I13Qqy1LRIaKPI+x6
	5yH5R+fL8jZLC7Po+Wq2ASP6ByEq1hW5dSiO3OwCkMq9Qa7PSwruCA8NDpgjJSE+GY0dWrbK7Mn
	8Uqjk/KZEuW84Ybw2s3N06OJHB+cClNGtKQUoK5dDbiefpGu3y5KjpvSnjjIReO+ffg==
X-Received: by 2002:a17:906:d049:: with SMTP id bo9mr35327540ejb.93.1559808524678;
        Thu, 06 Jun 2019 01:08:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwcM8lB2WAzZEx/dqtpsjAMfF2dE9v/I7czr/IbliFpJ5BnNqowng7rR6GaDnKQQT4RRXZm
X-Received: by 2002:a17:906:d049:: with SMTP id bo9mr35327469ejb.93.1559808523610;
        Thu, 06 Jun 2019 01:08:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559808523; cv=none;
        d=google.com; s=arc-20160816;
        b=ofQWVAl+RZ5raqv/8nm2WqfMNF6j3UJlgFSnwAtpLTs2wFIFuVg60CBNXFn4zADwo+
         Q0+WSDWH6Q21ADEw6OlxDb25X51ALigBaDmQvg3OobOBC3OuDmEMM62/Ca98OxWqcPqr
         FVJEzkaao6CPD9snjkDl0BEWME/2kX8S3XpO5EM+IQMneReZmVAXjZwe6UyyW37BBMBP
         taGdTO3vU4wso7WorYFXIAAczUjyPo5q+hWlxNPUCz60cbivEWlbre7fE4NGgVpjN+VH
         wE3SGELcEdo40lmXnda5v/IWHzjvdWF8vJNaqYBgP74hMaE1O/fzwatbXKKkh+8u1X6T
         SaoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=6uuOUw0MtzH6y5gvw/BW9BdxcQLNg5mXoHWYg+Blo1I=;
        b=my60MhLs/XoX7dbN81I+eKVrIsWVIjpG1sqTlVu0giT7Vr7fMZWfYN32rZWVivJXjO
         4DujB1irbJf8xZNh77xUqH3bSMUHLUjisUjf8HxQMvJL9P3Ez/3izQ7G1+GQESkSfZMD
         8yLQPfWepy0ez3Rqr5eygIdQDpuJaLbSkUUA0CeNQ2gUAhW0nfreT9cSG8e0SXtLnIdV
         dcPrB3C02M3pYkFaGFC1GmgRjFeNAtq7AbU2zSyy2Kxh4AmWT3hrVOdKsR7J8+WbUlwj
         0zPLpFp8X2LYB0VM6eE/AY3xURXb4sQXpqX3UI0VwTqchh7Ru8qazFHKlVnpSLEbWtLI
         5Taw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v25si949892ejq.334.2019.06.06.01.08.43
        for <linux-mm@kvack.org>;
        Thu, 06 Jun 2019 01:08:43 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7C077341;
	Thu,  6 Jun 2019 01:08:42 -0700 (PDT)
Received: from [10.162.43.122] (p8cg001049571a15.blr.arm.com [10.162.43.122])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5D8B13F246;
	Thu,  6 Jun 2019 01:08:40 -0700 (PDT)
Subject: Re: [PATCH V3 2/2] arm64/mm: Change offset base address in
 [pud|pmd]_free_[pmd|pte]_page()
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org,
 Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
 James Morse <james.morse@arm.com>, Robin Murphy <robin.murphy@arm.com>
References: <1557377177-20695-1-git-send-email-anshuman.khandual@arm.com>
 <1557377177-20695-3-git-send-email-anshuman.khandual@arm.com>
 <20190603153638.GA63283@arrakis.emea.arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <53f14fca-262c-f035-fdd1-e957fec4863f@arm.com>
Date: Thu, 6 Jun 2019 13:38:56 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190603153638.GA63283@arrakis.emea.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 06/03/2019 09:06 PM, Catalin Marinas wrote:
> Hi Anshuman,
> 
> 
> On Thu, May 09, 2019 at 10:16:17AM +0530, Anshuman Khandual wrote:
>> Pgtable page address can be fetched with [pmd|pte]_offset_[kernel] if input
>> address is PMD_SIZE or PTE_SIZE aligned. Input address is now guaranteed to
>> be aligned, hence fetched pgtable page address is always correct. But using
>> 0UL as offset base address has been a standard practice across platforms.
>> It also makes more sense as it isolates pgtable page address computation
>> from input virtual address alignment. This does not change functionality.
>>
>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>> Cc: Catalin Marinas <catalin.marinas@arm.com>
>> Cc: Will Deacon <will.deacon@arm.com>
>> Cc: Mark Rutland <mark.rutland@arm.com>
>> Cc: James Morse <james.morse@arm.com>
>> Cc: Robin Murphy <robin.murphy@arm.com>
> 
> What's the plan with this small series? I didn't find a v5 (unless I
> deleted it by mistake). I can queue this patch through the arm64 tree or
> they can both go in via the mm tree.

As mentioned earlier [1] I believe the second patch is not needed anymore. Hence
only V4 of the first patch (https://patchwork.kernel.org/patch/10944191/) which
has a Reviewed-by tag should be considered.

[1] https://patchwork.kernel.org/patch/10936625/

