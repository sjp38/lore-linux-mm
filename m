Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5EFCC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 07:08:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91AE820882
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 07:08:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91AE820882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 193466B0005; Thu,  4 Apr 2019 03:08:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 143DC6B0007; Thu,  4 Apr 2019 03:08:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0312F6B0008; Thu,  4 Apr 2019 03:08:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A8BEA6B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 03:08:05 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id w3so883554edt.2
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 00:08:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=rvT5Dy5+bbSFU97w80+ONJ2clo+gB5JRzeiUar7lJ3M=;
        b=iqF+d+Ij9Dcgw9LdyPOtQPxLm58mMge/4FLSMsdyFBaULtHPq8Nst68TEbPWTYGA8N
         2hbLJgOzyglAtN4pYOza4gx0tB+L8JqHyFpHxnzFAW9UC/3Q2bFQl3hs4cNsEpPATlK/
         ObhdqAy8hwbX8idOsPJeC5z4Qv10YhrBhVLGVzayJD2+/4sJfdlG3s6IQU3NKQ3OPsE0
         2lOtRxaFKTNmLJtP0FjW2v0xf+JH3hOcLkFhoTUSOVlFMSDCAkxKkSBkU/NsftwV8naR
         BSEqsUiwTkWeSrByv39xFx7zfWX2USSSXbvkfeonbuqE5ciWB/2uyxh3Ovw3qNI1V3Vd
         yeMw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAU1sJDuj7C0tS5fJXFBj6XzDFNV1LX1x4BuPIilvK30WCX44r6R
	l0waEfGCX1tgTO/GXIslYIvVbWMRC2Dd863duBXmQv/7Hs1OBU31VJx9wbxwEyfJNa9DPo8ySf0
	J+mDJDz23Cku84sXcJpL8XAxJ8pe47MJHZHksTz5OLJRKLB69yn9w3iQIKJ4pfvc+7g==
X-Received: by 2002:aa7:d945:: with SMTP id l5mr2676573eds.263.1554361685235;
        Thu, 04 Apr 2019 00:08:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxn67ASRcIfO4og4mi4iuyjDXMtGHDlpzCALOeLOgwaZRWRZG0PmO5KUs6JFYSoomSatoEU
X-Received: by 2002:aa7:d945:: with SMTP id l5mr2676515eds.263.1554361684079;
        Thu, 04 Apr 2019 00:08:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554361684; cv=none;
        d=google.com; s=arc-20160816;
        b=fWy320VvYjO8B9/+vneSJCFPgIyO2lSCqmEhu4FJ1R+SfPGwlOc4zNwWG8VgL12yGT
         L3W2HJqwO5wMCXe1l8CT+gpxWMgqH/f//o7FqttYd1OnafJiqZOZqNuqy5vXRlMD6pwg
         b3BJE1NwHsD4Qe733vHYz7fP6lDSwEHEGtw4lztGO94By4AI5/TIwU7Y7BbCqqJ2kaIU
         EB+UHmiu4UsZff7ZqTNx/DPyuqsUqvrcHbV4U+f7L7EIRhOHoIaAFkxEcjnkw/yHg7X8
         gqkZ71WHfIXpp/+sjdhU2/X27/gH542EwdLPyGrZo0GQxqEimcCJMBUI7JUcwMrSge+v
         6hBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=rvT5Dy5+bbSFU97w80+ONJ2clo+gB5JRzeiUar7lJ3M=;
        b=Tavzw7w2xUbeLlADE0i9l+BVIpGo+qhfvYk1aj69yifJ5lLZp2/fT/TB6DXlW24w8I
         fNlLk74qznTlS0zek1FVMDQqP4acaiRuAHGDo+K4NvJETfyfBSi6E5lwMFm+rTyAqrwP
         Jzt355C8zlf48Uv1a6roFRKBXMuCf54ysVZguKcj6Ln3u5E9e9SvnBZy/y0CU2N1jgCu
         MHOpMMOMdfVIxKNpiWrTNakOYFiyHOIEHu28SQr59me+LXqF2fniaSSYx25HdACmYnRN
         gpdQKUoc7pt0E7YmieWPf/2BH8e0Iq5hQ5grY0uNTKoZQ3Mz5dcshpaWfTX1I3zhUYN/
         GGeA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t25si3440768ejr.164.2019.04.04.00.08.03
        for <linux-mm@kvack.org>;
        Thu, 04 Apr 2019 00:08:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 01B3180D;
	Thu,  4 Apr 2019 00:08:03 -0700 (PDT)
Received: from [10.162.40.100] (p8cg001049571a15.blr.arm.com [10.162.40.100])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2AFF33F68F;
	Thu,  4 Apr 2019 00:07:56 -0700 (PDT)
Subject: Re: [PATCH 2/6] arm64/mm: Enable memory hot remove
To: Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 akpm@linux-foundation.org, will.deacon@arm.com, catalin.marinas@arm.com
Cc: mhocko@suse.com, mgorman@techsingularity.net, james.morse@arm.com,
 mark.rutland@arm.com, robin.murphy@arm.com, cpandya@codeaurora.org,
 arunks@codeaurora.org, dan.j.williams@intel.com, osalvador@suse.de,
 pasha.tatashin@oracle.com, david@redhat.com, cai@lca.pw,
 Stephen Bates <sbates@raithlin.com>
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-3-git-send-email-anshuman.khandual@arm.com>
 <f2ea761c-49b2-88f6-14fa-5aaec57952cb@deltatee.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <45afb99f-5785-4048-a748-4e0f06b06b31@arm.com>
Date: Thu, 4 Apr 2019 12:37:58 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <f2ea761c-49b2-88f6-14fa-5aaec57952cb@deltatee.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 04/03/2019 11:02 PM, Logan Gunthorpe wrote:
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

Sure that will be great. The only impediment is pgtable_page_ctor() for kernel
linear mapping. This series is based on current arm64 where linear mapping
pgtable pages go through pgtable_page_ctor() init sequence but that might be
changing soon. If RISC-V does not have pgtable_page_ctor() init for linear
mapping and no other arch specific stuff later on we can try to consolidate
remove_pagetable() atleast for both the architectures.

Then I wondering whether I can transition pud|pmd_large() to pud|pmd_sect().

