Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7C1FC742B2
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 09:57:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 709B220863
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 09:57:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 709B220863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E2D608E0133; Fri, 12 Jul 2019 05:57:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE6D78E00DB; Fri, 12 Jul 2019 05:57:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA4248E0133; Fri, 12 Jul 2019 05:57:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 790ED8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 05:57:57 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l26so7371559eda.2
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 02:57:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=m1SqSbn3cTGIHBraMHp9P5Kki1zGCfjoqi6Mnla8XIc=;
        b=lYQMABC1l7R6ZszJmvWc2yn2Yfsw6EOVx3SotO5XaQszuv5VCefn2q5GCtfLyKpFl1
         lHpC6vBeG+79uoVZhAZVu53uWR76PZZhqQKdjC0sTCPMF3c2AXPJzIfBs70oeXefcZxD
         KyQb/a37YztQtQbcNRc7xFyCSKYj7hegGW6WfOz10ckqqrOJuaSfzL/H/SHjfTtB7lrr
         9PRfV5zq/7FBOtSXF1Xn6dkEDfpmTw7c6s7oGLPGtX73hyk1TZhGtTSodyLdV/Tr7O0D
         bUqk2l4ERc4/xv4ly7mP5iZUmkvMuq6OpfuYloQQ2k2Ot8ax0qZRsS6RhzPZr8BCBiYU
         00OQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAU5wljFpzlNGiNHXfaZVKwiUR2Yljgaqs14/mfMMyU8wUW0SCQA
	4599GMZ/Y7C38B1pJWeDfTIYfeAooKqmvOIWgrmD8nQJOT7nAPEuAVT6h0lA5EVZiZwJChT94jE
	1SPBoHz9Pml3v1id3AXSAJe4WutAyK2i7TU1Kq+MSsRpEcN537PFsAsGom2sSYeHW9A==
X-Received: by 2002:a50:9871:: with SMTP id h46mr8228956edb.69.1562925477070;
        Fri, 12 Jul 2019 02:57:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyG0lPOG98gGAZJXQYZCOvd4DEjsIJNPFNSBmng6pKayCT/Syn/JvLIlOstGd6uKaumBvhT
X-Received: by 2002:a50:9871:: with SMTP id h46mr8228891edb.69.1562925475863;
        Fri, 12 Jul 2019 02:57:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562925475; cv=none;
        d=google.com; s=arc-20160816;
        b=qWXIm35Z6CKPJMkJs9YpOmXPqVexHulLBplGjDV33svFhBhM7fSlHukjMDbGHVL7hA
         TecH3JkkFzNZWwTKAx00+m0eq1hLcX0M1wxfHa2pkErKFsoDP4+fIWa7w5dPWVhXCUrc
         ylPY39/RE6D3HYkPKF8OtmVR0x627t4WlOYDSBLqJIpvut298k/nhnV7pg+EWIkVDgEt
         afMDttiWGIjVtxtAvf3cUqEFrZ2gM7lEmBGLXF3YEUnB++TEsdF8Kktqh8A3VKTa/gol
         jME5r04s+9vHUiCCdv6PvUqutLHLN4Tjz14LL7m+fpZOzqCJvjUeU7sogB43Q2fyELn0
         0+CA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=m1SqSbn3cTGIHBraMHp9P5Kki1zGCfjoqi6Mnla8XIc=;
        b=tiAOcj+AiN3JNQTZ50jOVU4g1QhLIc2U48KAWHPKQ3XXdHG4TAakmW5jjCJoVt6+Ho
         CujVLsKGzQCvsuQ1IkitgiAX+UAcYZ3N8QSvcoQqSoR3SpzTlKwFzVnwBYj9pSmGf63z
         DlNBmY/gBn25rPTEjUduEpEpI2eNs0C5zMLJgAOVeAxWe8ZoVVzzO/KpkIh+pHRvniht
         EejF+oTWZz7R5vk4XPKgzKrL2x9bKsT2bvltmZdUnzUA/LbhtOsA8Cn9XGnTmjmJsRt2
         N577ihW/PDvdYHRFRJhgBZVclIFSUFDz1ozpTXl9z1ug3WW3TRS8qZ3aka/oPjm5X16K
         ZPGg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id b2si2742624ejq.303.2019.07.12.02.57.55
        for <linux-mm@kvack.org>;
        Fri, 12 Jul 2019 02:57:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 054A42B;
	Fri, 12 Jul 2019 02:57:55 -0700 (PDT)
Received: from [10.162.41.115] (p8cg001049571a15.blr.arm.com [10.162.41.115])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C4A683F71F;
	Fri, 12 Jul 2019 02:57:50 -0700 (PDT)
Subject: Re: [PATCH V2] mm/ioremap: Probe platform for p4d huge map support
To: Michael Ellerman <mpe@ellerman.id.au>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will.deacon@arm.com>, Dave Hansen
 <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>,
 Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>,
 Ingo Molnar <mingo@redhat.com>,
 "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
 Michal Hocko <mhocko@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>,
 linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org,
 x86@kernel.org
References: <1561699231-20991-1-git-send-email-anshuman.khandual@arm.com>
 <20190702160630.25de5558e9fe2d7d845f3472@linux-foundation.org>
 <fbc147c7-bec2-daed-b828-c4ae170010a9@arm.com>
 <87tvbrennf.fsf@concordia.ellerman.id.au>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <b0525e42-6ba0-593f-5662-dc6271db2f4f@arm.com>
Date: Fri, 12 Jul 2019 15:28:22 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <87tvbrennf.fsf@concordia.ellerman.id.au>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 07/12/2019 12:37 PM, Michael Ellerman wrote:
> Anshuman Khandual <anshuman.khandual@arm.com> writes:
>> On 07/03/2019 04:36 AM, Andrew Morton wrote:
>>> On Fri, 28 Jun 2019 10:50:31 +0530 Anshuman Khandual <anshuman.khandual@arm.com> wrote:
>>>
>>>> Finishing up what the commit c2febafc67734a ("mm: convert generic code to
>>>> 5-level paging") started out while levelling up P4D huge mapping support
>>>> at par with PUD and PMD. A new arch call back arch_ioremap_p4d_supported()
>>>> is being added which just maintains status quo (P4D huge map not supported)
>>>> on x86, arm64 and powerpc.
>>>
>>> Does this have any runtime effects?  If so, what are they and why?  If
>>> not, what's the actual point?
>>
>> It just finishes up what the previous commit c2febafc67734a ("mm: convert
>> generic code to 5-level paging") left off with respect p4d based huge page
>> enablement for ioremap. When HAVE_ARCH_HUGE_VMAP is enabled its just a simple
>> check from the arch about the support, hence runtime effects are minimal.
> 
> The return value of arch_ioremap_p4d_supported() is stored in the
> variable ioremap_p4d_capable which is then returned by
> ioremap_p4d_enabled().
> 
> That is used by ioremap_try_huge_p4d() called from ioremap_p4d_range()
> from ioremap_page_range().

That is right.

> 
> The runtime effect is that it prevents ioremap_page_range() from trying
> to create huge mappings at the p4d level on arches that don't support
> it.

But now after first checking with an arch callback. Previously p4d huge
mappings were disabled on all platforms as ioremap_p4d_capable remained
clear through out being a static.

