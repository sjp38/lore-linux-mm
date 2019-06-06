Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0294C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 04:44:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51A53207E0
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 04:44:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51A53207E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B037B6B0270; Thu,  6 Jun 2019 00:44:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB4A46B0271; Thu,  6 Jun 2019 00:44:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97C066B0272; Thu,  6 Jun 2019 00:44:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4A8676B0270
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 00:44:05 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f15so1851852ede.8
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 21:44:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=H4EWZiVx+F+aV6iACwGgAeVn9gB/fMTJdwjJ6otddBc=;
        b=VFGci5AAhn6mcDIhS7izj+Q2XWUJNbQWSW/SsXIGVoUrAmEKAQRg4hKWl3Jj7oL2a7
         UQez8nHnjKF29c6x8/ZLk1H3hnk5ZbSE/rTX/ofjMV3I1ecIc8l6hZ1rVsRhUIvPL+Dj
         X0I5aiUCz5QZ7yNpmz8VbIzPN6YYFMeEy5vK6S5tgnnvhoyDfYu5xZsRGngTWGKrEn7y
         SzC2Xbl9L2scmFbxoYVibKEpnNmva4qJjtvgSrHIehQ2Fl+ndx90N8N9K97+xa9uXLNp
         eCeRhb4d+h9v/TkCF8zIonM02jV2cwD+AXJuEJUJo24WPaFM4E7QSKblo4IpNc31eSPR
         z5Cg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVf7o4N5ffSDuTcPYO1hY2IS40tdWPKLegyVMx2hKWL+GaoiiZn
	xgp2rFVFyTFZKuqnAbxCaQzXE55s6cJPRYilhvoGuMeT8LJ0ahiGtll45q1vIntIyQKuY4Xa0cS
	gf4SBYXwhFPncUuaQa6KOL2ST7PA6YDj8hADLhaiyneXxvAv6BZxryrNNswMRq5uXWA==
X-Received: by 2002:a50:bb24:: with SMTP id y33mr47316317ede.116.1559796244875;
        Wed, 05 Jun 2019 21:44:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy9qaWMKSy7x+BFhkp4Ptiqla3VbTXmBEAIqssbhJ+DHjWWeFMR2rggP2W8vNZbcLbpLRVy
X-Received: by 2002:a50:bb24:: with SMTP id y33mr47316236ede.116.1559796243891;
        Wed, 05 Jun 2019 21:44:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559796243; cv=none;
        d=google.com; s=arc-20160816;
        b=u0yN8acaktm8Of0UTEFoaFDmOrI3bq+mZ99u2kOXShUNFgZaVCAmJnmQMw+GJdPtHv
         TC3AlKpXHeZ7fVCIR8bWzs1/T0C3NXfBU4Vqc4N3aG9KzCp9RL0X46LB5mgqS1B0DPRK
         StJJPQ+HZIEdHCQeks5T6OLKag6gI1t11xnhlgnmaeKCjkb0EexnOD1fbX0mTWTIMGm2
         MrQhy6r+Pu9/8qcvApM7sOD8EOYKjygsWIRXCsCMqPGrVzVGLLpawlRRouSb9nb9oLRZ
         V5hx36g1V8G0/tguubqN9G8IVw0xyESIBzN9uvZpShlG8gBJWPwr/xiv7atNRDMxXZAb
         03lA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=H4EWZiVx+F+aV6iACwGgAeVn9gB/fMTJdwjJ6otddBc=;
        b=gT4Ki5rTlJX7WDEdWv1JGUk3VJ3rI/gD7LajR9VMDRggWS/89+v+anK3yZTdX83loa
         SYc1xf7UvhEEXXLPQ9oN0ZFBYPAg/3RnE6N1B8+8S/Qs1NidXW0tCiqJ++9VRGB8XZFE
         2uXYAdLRBLmAawe0HvoKojvFIAULLuvCqtkg6f1hw1LWfoLBorSUW8YJkYstZObMVvo2
         w06P8zqUZ5zP9o7IsAYnpEqgGtU2G6H+4RlzkrKC/sYUz8xVCNYYqodepcalsfWDDPN2
         +TmyZx1jcOc5EoyN9FB8Ck0qBtbbs/LFravrRHdrtzIPtve5Tesm00+GuCXq6vvALwQF
         xUGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c3si671818ejr.5.2019.06.05.21.44.02
        for <linux-mm@kvack.org>;
        Wed, 05 Jun 2019 21:44:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7015E80D;
	Wed,  5 Jun 2019 21:44:01 -0700 (PDT)
Received: from [10.162.43.122] (p8cg001049571a15.blr.arm.com [10.162.43.122])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 3F3273F690;
	Wed,  5 Jun 2019 21:43:58 -0700 (PDT)
Subject: Re: [PATCH V3 2/2] arm64/mm: Change offset base address in
 [pud|pmd]_free_[pmd|pte]_page()
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org,
 Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
 James Morse <james.morse@arm.com>, Robin Murphy <robin.murphy@arm.com>
References: <1557377177-20695-1-git-send-email-anshuman.khandual@arm.com>
 <1557377177-20695-3-git-send-email-anshuman.khandual@arm.com>
 <20190604142405.GI6610@arrakis.emea.arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <922c80b9-ec5b-4e12-2253-230d58df570c@arm.com>
Date: Thu, 6 Jun 2019 10:14:15 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190604142405.GI6610@arrakis.emea.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 06/04/2019 07:54 PM, Catalin Marinas wrote:
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
>> ---
>>  arch/arm64/mm/mmu.c | 6 +++---
>>  1 file changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
>> index e97f018ff740..71bcb783aace 100644
>> --- a/arch/arm64/mm/mmu.c
>> +++ b/arch/arm64/mm/mmu.c
>> @@ -1005,7 +1005,7 @@ int pmd_free_pte_page(pmd_t *pmdp, unsigned long addr)
>>  		return 1;
>>  	}
>>  
>> -	table = pte_offset_kernel(pmdp, addr);
>> +	table = pte_offset_kernel(pmdp, 0UL);
>>  	pmd_clear(pmdp);
>>  	__flush_tlb_kernel_pgtable(addr);
>>  	pte_free_kernel(NULL, table);
>> @@ -1026,8 +1026,8 @@ int pud_free_pmd_page(pud_t *pudp, unsigned long addr)
>>  		return 1;
>>  	}
>>  
>> -	table = pmd_offset(pudp, addr);
>> -	pmdp = table;
>> +	table = pmd_offset(pudp, 0UL);
>> +	pmdp = pmd_offset(pudp, addr);
>>  	next = addr;
>>  	end = addr + PUD_SIZE;
>>  	do {
> 
> I have the same comment as last time:
> 
> https://lore.kernel.org/linux-arm-kernel/20190430161759.GI29799@arrakis.emea.arm.com/
> 
> I don't see why pmdp needs to be different from table. We get the
> pointer to a pmd page and we want to iterate over it to free the pte
> entries it contains. You can add a VM_WARN on addr alignment as in the
> previous version of the patch but pmdp is just an iterator over table.

Fair enough. I believe VM_WARN() is needed to check address alignment because
they are now guaranteed to be aligned because of the previous patch. I guess
we should probably drop this patch and consider only the previous one ?

