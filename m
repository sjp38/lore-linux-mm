Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9AF5C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 18:08:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7748821773
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 18:08:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7748821773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2516C6B0286; Fri, 24 May 2019 14:08:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 229666B0288; Fri, 24 May 2019 14:08:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 118BA6B0289; Fri, 24 May 2019 14:08:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B4AD86B0286
	for <linux-mm@kvack.org>; Fri, 24 May 2019 14:08:13 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h2so15263925edi.13
        for <linux-mm@kvack.org>; Fri, 24 May 2019 11:08:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Rdc7eJpHsf18NFlocy+3oh446K/Obu3h//QJB9GRX4Q=;
        b=DxT1j7bI4OdsUtLNNxl9FOfs4hGHxMHzyA4XVjmi9WxESFz8t8b4BFXsOdFUHmmem0
         mJID2s1ulwBtWO1k8441ZMEcN6Iyf6Bn3y9h0NTAF0ZFX+v7YCueUgRGA5lhZgHbfPCD
         kKTAV24uGNiyX1ZpOkSQQ6/+2IoD+K4FfVfBk6Mdtt15k7icqcom5gI/IJlgr5SPsg8X
         Hqg6BbVqMgI5SwgQVXIliHmwECXoDWCHO2MzEG8CDeeJDTrBD4RQCpuJevFAZqJXBOBe
         9/vm9t2eTGSJRiV9Igbt8tUq0Np0IK3Ia9y0WjI4Rf+l0wlFPPOjVrDAvczF0Nb8yvpO
         3Rpg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: APjAAAXx03cYti8ocRXiupO4QSajRm/XV6xGgrZFmOjIOafHjZinL75l
	A60bSA7gryQuPQcNjVMjbN5t9Ou0mDaEwIufwOhP0pC+UG3KArocxuqdnA1b656UOkkwiGi7k0E
	vbfvVEUW6FTCrO0T+aWwmZM7Z3SJdOOGx4QDbHD07d7TtZpHs0rXa+iT7BYJAOXGlyQ==
X-Received: by 2002:a17:906:5d12:: with SMTP id g18mr70760391ejt.286.1558721293278;
        Fri, 24 May 2019 11:08:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyI5okpVUhwwg+h4lIYOijj6TLmlc+f6xWeSnxOd/3SNgurB6sJpFzxRklR/ZcjvDq7hmCc
X-Received: by 2002:a17:906:5d12:: with SMTP id g18mr70760298ejt.286.1558721292306;
        Fri, 24 May 2019 11:08:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558721292; cv=none;
        d=google.com; s=arc-20160816;
        b=xBgwkgrfTvyB7x6mBkl610H6a5yItKCOuE3YkLzTNPLWVucsi8ehnFI11VJR14u+vY
         Li+96izhFsCfXTnOgxdGGsekhu5Lg7O0HryhfI/ir+sMxbnvusqYRw6FOLd8TYL6aR8e
         phaCH+91MkAFO8zu6LrULOooymViLTcoj6CD1WJ+eiUniQsmmQccnV3gdEEKUuL1msSr
         SMhNbud3GipLGJfxVDk+U9IrQ4hMhJmOXEnwxPO0dSMJuZp2gz3ZT6WOMB+05pcYKmgB
         G8BxaDNg8EsY1FsQvejbmKgJ/vU8k63/MyB3RuABBBqAyIU/E9hzzcmSjmrh2UD92SbA
         hr5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Rdc7eJpHsf18NFlocy+3oh446K/Obu3h//QJB9GRX4Q=;
        b=fZLSsYm6fHPmlhVeIBwCDXO5d0P9Zoe9Q9LphUu8LRJ1mbdzcHHy+I2DhNVsHGiZH4
         BuZ55G9P2/Mv2Tqe2T2f2wsciGcEO+mvbo5AEnMD0I+8xp6+VyZ6Gx8DG0wWOVsUXu2H
         5VcSeX6P/bv0zwn7nZZ7n8YAoDIVfeJsjWFCoARmztT5nDsZkEpQFr1h8rIrxh3NZ+/F
         7x3HW8FSc88P3JlH1JdvH66sW8nrDu8yKK9kDtX0N+aV1ibUbfzQl/fBmseLM48LGGD4
         QSPbYVyvcly1S7QU/tWBsJJd/hHrBwHOQp9DUZyJozACsP9CGS51iOqxSigOp6EWu+mv
         1saw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b15si2641391edb.89.2019.05.24.11.08.12
        for <linux-mm@kvack.org>;
        Fri, 24 May 2019 11:08:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 49589A78;
	Fri, 24 May 2019 11:08:11 -0700 (PDT)
Received: from fuggles.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E5C8A3F703;
	Fri, 24 May 2019 11:08:09 -0700 (PDT)
Date: Fri, 24 May 2019 19:08:05 +0100
From: Will Deacon <will.deacon@arm.com>
To: Robin Murphy <robin.murphy@arm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, catalin.marinas@arm.com,
	anshuman.khandual@arm.com, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3 4/4] arm64: mm: Implement pte_devmap support
Message-ID: <20190524180805.GA9697@fuggles.cambridge.arm.com>
References: <cover.1558547956.git.robin.murphy@arm.com>
 <817d92886fc3b33bcbf6e105ee83a74babb3a5aa.1558547956.git.robin.murphy@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <817d92886fc3b33bcbf6e105ee83a74babb3a5aa.1558547956.git.robin.murphy@arm.com>
User-Agent: Mutt/1.11.1+86 (6f28e57d73f2) ()
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 04:03:16PM +0100, Robin Murphy wrote:
> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
> index 2c41b04708fe..a6378625d47c 100644
> --- a/arch/arm64/include/asm/pgtable.h
> +++ b/arch/arm64/include/asm/pgtable.h
> @@ -90,6 +90,7 @@ extern unsigned long empty_zero_page[PAGE_SIZE / sizeof(unsigned long)];
>  #define pte_write(pte)		(!!(pte_val(pte) & PTE_WRITE))
>  #define pte_user_exec(pte)	(!(pte_val(pte) & PTE_UXN))
>  #define pte_cont(pte)		(!!(pte_val(pte) & PTE_CONT))
> +#define pte_devmap(pte)		(!!(pte_val(pte) & PTE_DEVMAP))
>  
>  #define pte_cont_addr_end(addr, end)						\
>  ({	unsigned long __boundary = ((addr) + CONT_PTE_SIZE) & CONT_PTE_MASK;	\
> @@ -217,6 +218,11 @@ static inline pmd_t pmd_mkcont(pmd_t pmd)
>  	return __pmd(pmd_val(pmd) | PMD_SECT_CONT);
>  }
>  
> +static inline pte_t pte_mkdevmap(pte_t pte)
> +{
> +	return set_pte_bit(pte, __pgprot(PTE_DEVMAP));
> +}
> +
>  static inline void set_pte(pte_t *ptep, pte_t pte)
>  {
>  	WRITE_ONCE(*ptep, pte);
> @@ -381,6 +387,9 @@ static inline int pmd_protnone(pmd_t pmd)
>  
>  #define pmd_mkhuge(pmd)		(__pmd(pmd_val(pmd) & ~PMD_TABLE_BIT))
>  
> +#define pmd_devmap(pmd)		pte_devmap(pmd_pte(pmd))
> +#define pmd_mkdevmap(pmd)	pte_pmd(pte_mkdevmap(pmd_pte(pmd)))
> +
>  #define __pmd_to_phys(pmd)	__pte_to_phys(pmd_pte(pmd))
>  #define __phys_to_pmd_val(phys)	__phys_to_pte_val(phys)
>  #define pmd_pfn(pmd)		((__pmd_to_phys(pmd) & PMD_MASK) >> PAGE_SHIFT)
> @@ -537,6 +546,11 @@ static inline phys_addr_t pud_page_paddr(pud_t pud)
>  	return __pud_to_phys(pud);
>  }
>  
> +static inline int pud_devmap(pud_t pud)
> +{
> +	return 0;
> +}
> +
>  /* Find an entry in the second-level page table. */
>  #define pmd_index(addr)		(((addr) >> PMD_SHIFT) & (PTRS_PER_PMD - 1))
>  
> @@ -624,6 +638,11 @@ static inline phys_addr_t pgd_page_paddr(pgd_t pgd)
>  
>  #define pgd_ERROR(pgd)		__pgd_error(__FILE__, __LINE__, pgd_val(pgd))
>  
> +static inline int pgd_devmap(pgd_t pgd)
> +{
> +	return 0;
> +}

I think you need to guard this and pXd_devmap() with
CONFIG_TRANSPARENT_HUGEPAGE, otherwise you'll conflict with the dummy
definitions in mm.h and the build will fail.

Will

