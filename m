Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3E22C43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 16:16:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FBCD20896
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 16:16:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FBCD20896
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1527A6B000D; Mon,  1 Apr 2019 12:16:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 102616B000E; Mon,  1 Apr 2019 12:16:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F33DE6B0010; Mon,  1 Apr 2019 12:16:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A2E8A6B000D
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 12:16:45 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id e55so4605458edd.6
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 09:16:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=M31kcYQG9WLigXD5qo644ptFSmXfIIQGCTfSzBxHqnU=;
        b=ejODw2nJv8Fw+6EjiMLiSxpKnH7LNfWMNLCLOzVZ9Oqdavjlz9XcKnDYQa1yTUrWcl
         2sqHtNNjF5JYcsu2S4ah0IkIew17qf3382in6Lrbm5QAFjO1AeTjbOsyoS90kZvVJ/Af
         v/vhMRyghDXpntlSi+rrDWhezRH78Bi95slR/fSRuxzNzlCDFqrhVJhX+mi1uatxzVkJ
         48cYqlJwVlZP/fnbZ17v6wuw1av9Oxx6IzdTgRO49xNM13ukMZmVLDp7TLeVjjNqJ+9u
         BxElfqdq92Up20INT7F3KBo1I+xoL3G51wnIamFRrtbt/WsNeyYY7c2tVgHvsDVBWiT1
         BJrQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: APjAAAVcQpNcvlGwm1KegnEnoQ9BWvPMVFPi77kDzrVpqcJnXKBTY3CL
	DH/JzPub4cELzAv8d5bsoLoYATAILwiClpGvJUq8qzICiJQwUfVaPSMioC6PTOby3r+OuP94w4j
	DPwwE6FOmUxIaKzMCSlIuqaWYtU4I6uzLcVLWnylZz9oW8VTy+018FYVfolx76LcPlg==
X-Received: by 2002:a50:aa0f:: with SMTP id o15mr43078537edc.129.1554135405200;
        Mon, 01 Apr 2019 09:16:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw2qqx5NUTAN3rq/a/N2sTv5K/UCLiIYm2ykUnYnqPmUf8O+aimcktwGRaWCMa/6uVtBM0E
X-Received: by 2002:a50:aa0f:: with SMTP id o15mr43078473edc.129.1554135404040;
        Mon, 01 Apr 2019 09:16:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554135404; cv=none;
        d=google.com; s=arc-20160816;
        b=SPmvBj9vhnIYWT+F05cN6twKG5+rPHqbHLYuXj12xND2BnAlUKIR7TSbaQMYfuV4FO
         HIBC3LyfYG19HI2Yp/9Sqy/jL1Ujb4eGuv1cKFIyHDuKcL6UEVgqEklfCCioidjzhkYf
         VGT8NlLyyJZB6teXlM7V1r6kifn0WPEmNRQ4fDAN4PGyXi752tYdZQKnSnlbS77f+fvZ
         0N9CIIiVIzxR+6LcduYDP7ivDhl3qrpPvXeQDa9EeiBbTRckWEgXCgjqS+6d0slqE4de
         BKAQLRkcb8vU7LsL1S3NKtJ22ld2ce3ARanZX3kVzTpgZv7AqbBtZs13p1GIC+9JVCdn
         r/Eg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=M31kcYQG9WLigXD5qo644ptFSmXfIIQGCTfSzBxHqnU=;
        b=1EHgYT504dD2+RJ4fxevwllVmlcrSQ/ULfFp5+4MPTXAi23rPRFJcRTwPuN0os8zua
         1KtMb/bC62YGVrRmSiHlADvnXRFRB+0MpxPhHJXnMKJ9/pTDsw8dIfa0b847f5cl7PVn
         9vSyXBkniD0zU2XquMhYy5rARFrJC1VAr+NnEMhmsGMPYGAE+J9cUAxCT+Kl4AFx4M3Q
         +0tHvoSo9LxG2fLw3lLBvvZPQyRJAe9bqxKY2CGOrmoOrvtm7/7LmlTwJts44nc+/EPY
         TtKupUTjARiIaWyviGZSxzOXaC3mCXl6/QSCGvnw7yL/NGm7b3TgCA+N3GkX5uVuVdIs
         zTOw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f55si2013550edb.217.2019.04.01.09.16.43
        for <linux-mm@kvack.org>;
        Mon, 01 Apr 2019 09:16:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A2553A78;
	Mon,  1 Apr 2019 09:16:42 -0700 (PDT)
Received: from fuggles.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 8DD5A3F690;
	Mon,  1 Apr 2019 09:16:40 -0700 (PDT)
Date: Mon, 1 Apr 2019 17:16:38 +0100
From: Will Deacon <will.deacon@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org,
	catalin.marinas@arm.com, mark.rutland@arm.com, yuzhao@google.com,
	suzuki.poulose@arm.com, marc.zyngier@arm.com,
	christoffer.dall@arm.com, james.morse@arm.com,
	julien.thierry@arm.com, kvmarm@lists.cs.columbia.edu
Subject: Re: [PATCH V2] KVM: ARM: Remove pgtable page standard functions from
 stage-2 page tables
Message-ID: <20190401161638.GB22092@fuggles.cambridge.arm.com>
References: <3be0b7e0-2ef8-babb-88c9-d229e0fdd220@arm.com>
 <1552397145-10665-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1552397145-10665-1-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.11.1+86 (6f28e57d73f2) ()
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[+KVM/ARM folks, since I can't take this without an Ack in place from them]

My understanding is that this patch is intended to replace patch 3/4 in
this series:

http://lists.infradead.org/pipermail/linux-arm-kernel/2019-March/638083.html

On Tue, Mar 12, 2019 at 06:55:45PM +0530, Anshuman Khandual wrote:
> ARM64 standard pgtable functions are going to use pgtable_page_[ctor|dtor]
> or pgtable_pmd_page_[ctor|dtor] constructs. At present KVM guest stage-2
> PUD|PMD|PTE level page tabe pages are allocated with __get_free_page()
> via mmu_memory_cache_alloc() but released with standard pud|pmd_free() or
> pte_free_kernel(). These will fail once they start calling into pgtable_
> [pmd]_page_dtor() for pages which never originally went through respective
> constructor functions. Hence convert all stage-2 page table page release
> functions to call buddy directly while freeing pages.
> 
> Reviewed-by: Suzuki K Poulose <suzuki.poulose@arm.com>
> Acked-by: Yu Zhao <yuzhao@google.com>
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
> Changes in V2:
> 
> - Updated stage2_pud_free() with NOP as per Suzuki
> - s/__free_page/free_page/ in clear_stage2_pmd_entry() for uniformity
> 
>  arch/arm/include/asm/stage2_pgtable.h   | 4 ++--
>  arch/arm64/include/asm/stage2_pgtable.h | 4 ++--
>  virt/kvm/arm/mmu.c                      | 2 +-
>  3 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/arch/arm/include/asm/stage2_pgtable.h b/arch/arm/include/asm/stage2_pgtable.h
> index de2089501b8b..fed02c3b4600 100644
> --- a/arch/arm/include/asm/stage2_pgtable.h
> +++ b/arch/arm/include/asm/stage2_pgtable.h
> @@ -32,14 +32,14 @@
>  #define stage2_pgd_present(kvm, pgd)		pgd_present(pgd)
>  #define stage2_pgd_populate(kvm, pgd, pud)	pgd_populate(NULL, pgd, pud)
>  #define stage2_pud_offset(kvm, pgd, address)	pud_offset(pgd, address)
> -#define stage2_pud_free(kvm, pud)		pud_free(NULL, pud)
> +#define stage2_pud_free(kvm, pud)		do { } while (0)
>  
>  #define stage2_pud_none(kvm, pud)		pud_none(pud)
>  #define stage2_pud_clear(kvm, pud)		pud_clear(pud)
>  #define stage2_pud_present(kvm, pud)		pud_present(pud)
>  #define stage2_pud_populate(kvm, pud, pmd)	pud_populate(NULL, pud, pmd)
>  #define stage2_pmd_offset(kvm, pud, address)	pmd_offset(pud, address)
> -#define stage2_pmd_free(kvm, pmd)		pmd_free(NULL, pmd)
> +#define stage2_pmd_free(kvm, pmd)		free_page((unsigned long)pmd)
>  
>  #define stage2_pud_huge(kvm, pud)		pud_huge(pud)
>  
> diff --git a/arch/arm64/include/asm/stage2_pgtable.h b/arch/arm64/include/asm/stage2_pgtable.h
> index 5412fa40825e..915809e4ac32 100644
> --- a/arch/arm64/include/asm/stage2_pgtable.h
> +++ b/arch/arm64/include/asm/stage2_pgtable.h
> @@ -119,7 +119,7 @@ static inline pud_t *stage2_pud_offset(struct kvm *kvm,
>  static inline void stage2_pud_free(struct kvm *kvm, pud_t *pud)
>  {
>  	if (kvm_stage2_has_pud(kvm))
> -		pud_free(NULL, pud);
> +		free_page((unsigned long)pud);
>  }
>  
>  static inline bool stage2_pud_table_empty(struct kvm *kvm, pud_t *pudp)
> @@ -192,7 +192,7 @@ static inline pmd_t *stage2_pmd_offset(struct kvm *kvm,
>  static inline void stage2_pmd_free(struct kvm *kvm, pmd_t *pmd)
>  {
>  	if (kvm_stage2_has_pmd(kvm))
> -		pmd_free(NULL, pmd);
> +		free_page((unsigned long)pmd);
>  }
>  
>  static inline bool stage2_pud_huge(struct kvm *kvm, pud_t pud)
> diff --git a/virt/kvm/arm/mmu.c b/virt/kvm/arm/mmu.c
> index e9d28a7ca673..cbfbdadca8a5 100644
> --- a/virt/kvm/arm/mmu.c
> +++ b/virt/kvm/arm/mmu.c
> @@ -191,7 +191,7 @@ static void clear_stage2_pmd_entry(struct kvm *kvm, pmd_t *pmd, phys_addr_t addr
>  	VM_BUG_ON(pmd_thp_or_huge(*pmd));
>  	pmd_clear(pmd);
>  	kvm_tlb_flush_vmid_ipa(kvm, addr);
> -	pte_free_kernel(NULL, pte_table);
> +	free_page((unsigned long)pte_table);
>  	put_page(virt_to_page(pmd));
>  }
>  
> -- 
> 2.20.1
> 

