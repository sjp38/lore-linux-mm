Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB845C10F0E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 13:11:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 74B682075E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 13:11:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74B682075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 254846B000C; Thu,  4 Apr 2019 09:11:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 203A86B000D; Thu,  4 Apr 2019 09:11:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D7B66B000E; Thu,  4 Apr 2019 09:11:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id AEB986B000C
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 09:11:31 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id j3so1389577edb.14
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 06:11:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=77oy2l8hjVP8piQUpW0+JPvcwf7YhI2VkCu5Ok1v/mw=;
        b=Cmq/wbnUIqfK+4VogImBvHTrVsTn4PTVBgQqOlkzJ+m3uOQT5j56buPvskVx4ChXWd
         FPfHRTA+OVBhOqJxxbt3adllNxgRRO9dfprb9HYmijL14UUcby6Bmc0VHw5oxbUbP1l4
         c9eM0ZDUy0laqc1mwnliFOfaNWki5nlrXc3mLoxYfrMjxfA4jluR5NiMM2ctXZkk7nk6
         78YEYU+2qHXx4f+dfHeQY9m/+1rxqXM5cOjFII57WYcdYds2GYh+4KO45D4pb+Zl/pwW
         87ptJQJElsxzLqUZxwzmt/Ypt2H7lRnQ3tMv30C38MeDknbxxF8npQmc0+YFXxXxsVo7
         HhXA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXjMiuEMPwFa1WXh0deeeJq4c3gEmpQmNgQDxyDKTgashcE/WK1
	71z7lMWBbD/hIqhYel/Cbe8lywHxqQc5OPcm5SThqpEzYB5JGdpQ1XlSaQ2SZ1dFFl0yCbIhb4M
	0d6Cp6Jk6VLNpjw0T/gCjM7j3hXhQNGt9dPFKT2+NHsMWBnz3t0TtcKNz+ADfAuBjtw==
X-Received: by 2002:a17:906:1596:: with SMTP id k22mr3507401ejd.162.1554383491235;
        Thu, 04 Apr 2019 06:11:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxkuCpKKt/GNAhX4L0yvURWcVPpj1DyyahP/bs9F4Cn7Ufkd/IO8J+mE2QeJBf+b57+NfNn
X-Received: by 2002:a17:906:1596:: with SMTP id k22mr3507361ejd.162.1554383490298;
        Thu, 04 Apr 2019 06:11:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554383490; cv=none;
        d=google.com; s=arc-20160816;
        b=lrgmL1lX2D9Gh9c+kHXAiUko+OhEq4hnwjzfUU/VZWjUBZ6zaOOG9lNDoTzomw17Qf
         /d83BRLuxyhwFwRGEbmuSljEiBJy5xLH15VbJSgv0zKztr2RKP+UEapdphKhRnA2JUtT
         mfzIXkzvLlo+L7YobWQKCRIKkDI09plkvJlyOFjNeMm3VdfjQk/vELBs1J+JHHGiLxm8
         tirDl4sejouBgpJlAGu+cRcSgj90dzVO8IUBgrR8EIWgOLZrOD+Jqcp83CrhavVaEuW1
         hIUl+q3IZkB565ADO7PjLE9GDodnIXPvNFclWQ5UCSji9igUAKnu5ClfuddqrXiDHnC4
         y9Dg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=77oy2l8hjVP8piQUpW0+JPvcwf7YhI2VkCu5Ok1v/mw=;
        b=ox/8DnIhIjsMouuvtRb2ZBra37UqJCue1/gzUoVRDAPgrCJiHqpjbFZV9RGg/c7p34
         xjgK3+9dP74DXPJulCcEESKaTYVVYaNd+qOOoenUSmrwbPe4bZUsgH/jRPY05RCbneTP
         ibI+a2G0IWRGaBcprIBlk44HmSaUb08B04tjbbgemeVUdLzjAN91HZSDlz+3gkrpL83j
         qv3RgprlbPiyyurhC960qwe3urY7gbPBVjFgb3wVow8t1wMhpWqw1NXL5Qnhtip2rLCR
         eGAbzuVT/Y7NWGhRy9A/Qu041dXFuq1HVpCRko4X+5j5uooB5UCd0yU3Jiuck+6HWMa2
         /GiA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h10si1719490edv.8.2019.04.04.06.11.30
        for <linux-mm@kvack.org>;
        Thu, 04 Apr 2019 06:11:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 38A17A78;
	Thu,  4 Apr 2019 06:11:29 -0700 (PDT)
Received: from [10.162.40.100] (p8cg001049571a15.blr.arm.com [10.162.40.100])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id CA5593F68F;
	Thu,  4 Apr 2019 06:11:23 -0700 (PDT)
Subject: Re: [PATCH 0/6] arm64/mm: Enable memory hot remove and ZONE_DEVICE
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 linux-arm-kernel@lists.infradead.org, Linux MM <linux-mm@kvack.org>,
 Andrew Morton <akpm@linux-foundation.org>, Will Deacon
 <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>,
 Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>,
 james.morse@arm.com, Mark Rutland <mark.rutland@arm.com>,
 Robin Murphy <robin.murphy@arm.com>, cpandya@codeaurora.org,
 arunks@codeaurora.org, osalvador@suse.de,
 Logan Gunthorpe <logang@deltatee.com>,
 Pavel Tatashin <pasha.tatashin@oracle.com>,
 David Hildenbrand <david@redhat.com>, cai@lca.pw
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <CAPcyv4gdz7L20nSMEBNLDWgUzr-GjaBhecF3i8Q4D_O=ug0qNw@mail.gmail.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <6d46fc37-91e2-c44c-6e01-bfbd5c022f39@arm.com>
Date: Thu, 4 Apr 2019 18:41:25 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <CAPcyv4gdz7L20nSMEBNLDWgUzr-GjaBhecF3i8Q4D_O=ug0qNw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 04/03/2019 11:38 PM, Dan Williams wrote:
> On Tue, Apr 2, 2019 at 9:30 PM Anshuman Khandual
> <anshuman.khandual@arm.com> wrote:
>>
>> This series enables memory hot remove on arm64, fixes a memblock removal
>> ordering problem in generic __remove_memory(), enables sysfs memory probe
>> interface on arm64. It also enables ZONE_DEVICE with struct vmem_altmap
>> support.
>>
>> Testing:
>>
>> Tested hot remove on arm64 for all 4K, 16K, 64K page config options with
>> all possible VA_BITS and PGTABLE_LEVELS combinations. Tested ZONE_DEVICE
>> with ARM64_4K_PAGES through a dummy driver.
>>
>> Build tested on non arm64 platforms. I will appreciate if folks can test
>> arch_remove_memory() re-ordering in __remove_memory() on other platforms.
>>
>> Dependency:
>>
>> V5 series in the thread (https://lkml.org/lkml/2019/2/14/1096) will make
>> kernel linear mapping loose pgtable_page_ctor() init. When this happens
>> the proposed functions free_pte|pmd|pud_table() in [PATCH 2/6] will have
>> to stop calling pgtable_page_dtor().
> 
> Hi Anshuman,

Hello Dan,

> 
> I'd be interested to integrate this with the sub-section hotplug
> support [1]. Otherwise the padding implementation in libnvdimm can't
> be removed unless all ZONE_DEVICE capable archs also agree on the
> minimum arch_add_memory() granularity. I'd prefer not to special case
> which archs support which granularity, but it unfortunately
> complicates what you're trying to achieve.

Sorry I have not been following your series on sub-section hotplug support.
Hence might not have the full context here. Could you please give some more
details on what exactly might be a problem.

> 
> I think at a minimum we, mm hotplug co-travellers, need to come to a
> consensus on whether sub-section support is viable for v5.2 and / or a
> pre-requisite for new arch-ZONE_DEVICE implementations

I would need to go through sub-section hotplug series first to understand
the pre-requisite. Do we need to support sub-section hotplug first before
being able to enable ZONE_DEVICE ?

- Anshuman

