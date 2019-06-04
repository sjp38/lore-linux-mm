Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 682B3C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 14:24:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2AB82243F6
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 14:24:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2AB82243F6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6AE26B026E; Tue,  4 Jun 2019 10:24:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF4726B0272; Tue,  4 Jun 2019 10:24:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B32B06B0273; Tue,  4 Jun 2019 10:24:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 684776B026E
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 10:24:12 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id a21so617383edt.23
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 07:24:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=iDk9z3L/CsleVCxclXZO9/f/ibDqaeIztcQvZUQ5c9o=;
        b=DXABFPaXE1qTauRUpkhO45Oe1qdMr52lS2o2Eb7RcIXlOo1S/Z6vKoKiX+maG+sMYP
         aokV1sF/hOmGtP52BtdG/bAo9yRkr/tXULz3DtGYtvFcNJG70kg6PaLlo23U9rNI7bqO
         SYCuG7aZeBV+KgIb1RXsqOhtkvvPl4C7/pk7fHnLxy50ClvXogb8V+Ojn9ttgX4RagwD
         ByOVbaxrQ3AkTK4eGLt2djuCeIBLvDbBZuHhyQB9S9uoNP6/kwmbPhrRlL4Tr5ICq42J
         R1TAvvFSha4qcv4H3E3e5ZREKXh211weT8iX4FaU2WMMO+7R39yjkta2RuNamJQSBo+7
         pW1A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAU6N4MZDvRnYCHbfSA+k3TSOh3ls61yUjeCn/WooJ37YsyY4dm4
	MjhmIU0nwaF8dDRa9tZKeedl2IdQFAXgtouqRZ5DQM5qVjxjBYvatzTKHSEGVFYmU++yGZ7K5uM
	fRxJdX6HX0dobB3T0EiZTidNucqHNgN0v/4Tkubw1FAFTPgn1fjDpdoj7oZio8q0k5A==
X-Received: by 2002:a17:906:c06:: with SMTP id s6mr16601402ejf.242.1559658251985;
        Tue, 04 Jun 2019 07:24:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvKSIdu9TV7q6CCmdIi7UwOSw9wlfhInZEH5Q+7qHS05TT3KztAkJwEGW81kh4k/fewGab
X-Received: by 2002:a17:906:c06:: with SMTP id s6mr16601325ejf.242.1559658251088;
        Tue, 04 Jun 2019 07:24:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559658251; cv=none;
        d=google.com; s=arc-20160816;
        b=CDJii/4DwnJxuuxgctQpATEv19fMdCWw1MQoSi0AC5iQyrTkaZBM28jtjLvDJ7/cDR
         zwUVnkbjRuR89Yh1yOp3H7l9USVWfM56kisQGsFo/t1dbbVBvaynmnZKduJB1Fj4GPfe
         qd9X1C9O/fKcCTRrSUGgyu8GCVvocNUZ3HvS5lnAlBKP7fKE3ZJGrWldXzehbvQI6V3d
         DJxAEOoRciZ2B4tbcUjzWbecLpvZu+jEDIm4vhdLEY1NGwbu49fx33DWBf41Aeb/v7hc
         IEYbisccdG5I0ippCvohjTuwBoQydjh7g9dL7CLumhAY8Ju13cLOygW3gbTeLGZjhPh0
         h/2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=iDk9z3L/CsleVCxclXZO9/f/ibDqaeIztcQvZUQ5c9o=;
        b=F/+LmwfoGmldiHwUzsc5z2NaZw+jvKdgILOpeACfF8154bSgKO4G83/mdp0fpxD0Zs
         3s65ciMX8UCwmBoQqJEMwv2DSKDsK4syYsUArBT9NTRwMlZkQO1kZAb0109twHCMxFvY
         dSKrj3/oV7HSWtdrh/EPISFEBN3GMF33m8XE0x/lN6xk2lHOqFdnNySFVYq82qViqSAY
         /i3rJxz2CYFGKOZy+X33ASM9RXXqCEIhdi3WEpUTGpGm6ETwYMBRDhwv9XG0XWZLQIzJ
         yUV3wc432uhveBRbMoPIrfHFzmcuAaDKap2IPAdUMwrwtumatw8S7FhZ9qgC4xjnFfwS
         x5dA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u25si4210247ejt.173.2019.06.04.07.24.10
        for <linux-mm@kvack.org>;
        Tue, 04 Jun 2019 07:24:11 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1A289341;
	Tue,  4 Jun 2019 07:24:10 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B86483F690;
	Tue,  4 Jun 2019 07:24:08 -0700 (PDT)
Date: Tue, 4 Jun 2019 15:24:06 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	James Morse <james.morse@arm.com>,
	Robin Murphy <robin.murphy@arm.com>
Subject: Re: [PATCH V3 2/2] arm64/mm: Change offset base address in
 [pud|pmd]_free_[pmd|pte]_page()
Message-ID: <20190604142405.GI6610@arrakis.emea.arm.com>
References: <1557377177-20695-1-git-send-email-anshuman.khandual@arm.com>
 <1557377177-20695-3-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1557377177-20695-3-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 09, 2019 at 10:16:17AM +0530, Anshuman Khandual wrote:
> Pgtable page address can be fetched with [pmd|pte]_offset_[kernel] if input
> address is PMD_SIZE or PTE_SIZE aligned. Input address is now guaranteed to
> be aligned, hence fetched pgtable page address is always correct. But using
> 0UL as offset base address has been a standard practice across platforms.
> It also makes more sense as it isolates pgtable page address computation
> from input virtual address alignment. This does not change functionality.
> 
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: James Morse <james.morse@arm.com>
> Cc: Robin Murphy <robin.murphy@arm.com>
> ---
>  arch/arm64/mm/mmu.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> index e97f018ff740..71bcb783aace 100644
> --- a/arch/arm64/mm/mmu.c
> +++ b/arch/arm64/mm/mmu.c
> @@ -1005,7 +1005,7 @@ int pmd_free_pte_page(pmd_t *pmdp, unsigned long addr)
>  		return 1;
>  	}
>  
> -	table = pte_offset_kernel(pmdp, addr);
> +	table = pte_offset_kernel(pmdp, 0UL);
>  	pmd_clear(pmdp);
>  	__flush_tlb_kernel_pgtable(addr);
>  	pte_free_kernel(NULL, table);
> @@ -1026,8 +1026,8 @@ int pud_free_pmd_page(pud_t *pudp, unsigned long addr)
>  		return 1;
>  	}
>  
> -	table = pmd_offset(pudp, addr);
> -	pmdp = table;
> +	table = pmd_offset(pudp, 0UL);
> +	pmdp = pmd_offset(pudp, addr);
>  	next = addr;
>  	end = addr + PUD_SIZE;
>  	do {

I have the same comment as last time:

https://lore.kernel.org/linux-arm-kernel/20190430161759.GI29799@arrakis.emea.arm.com/

I don't see why pmdp needs to be different from table. We get the
pointer to a pmd page and we want to iterate over it to free the pte
entries it contains. You can add a VM_WARN on addr alignment as in the
previous version of the patch but pmdp is just an iterator over table.

-- 
Catalin

