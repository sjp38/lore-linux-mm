Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14058C43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 18:34:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F60C206C0
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 18:34:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="eDYAXQ27"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F60C206C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0ED6C6B0006; Mon,  1 Apr 2019 14:34:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 074656B0008; Mon,  1 Apr 2019 14:34:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA6CB6B000A; Mon,  1 Apr 2019 14:34:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id C44686B0006
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 14:34:31 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id k5so8946213ioh.13
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 11:34:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=+53egRqiXPQZ9EJ7mGipuGA/l/Y4XVrW1UL2Rjyi1aY=;
        b=BkYWpu0mf4j7v5y/5FKwEwtSRfzMax5BdRjn9igsnEEdzfaq31P9upcVQKYif24yt5
         dAf71npHEDd0Mf44Sty6VN6aN2QMTy6GQyYS4EBQKF+kDyIoQohqlbGVqaAbgyYrxlV1
         084T4G707yiywFdQCyE4PBpnZi0Wi8OZmYZR5aSbtOyHY5mmha9/JBYuQeKNkw5k8XpW
         gwPRsaR5YMTTYKk/0r1gHVJnf1eBxB81YzRis19aw2lXlSyWTKHed53tGSODuvnXI+BC
         ub11HC0QmIonlAF79M4GSUsrysMa85d/IPrmqtCRwyLEGmDdlp42sSOXRsDG3a65Q3ph
         vkiw==
X-Gm-Message-State: APjAAAXpxtWOAcVnIkijfHzcW0NE2NGv3IZIxt7pEVtK6SrJ8Y2ZKtFA
	iKs5WJ5ZXrgU6Xsj4DdziFp8Yk9K48ZpAO2EviYRHZx8CEj0bOtU7ODwp4Y4kqa4kTlH8hP1tXA
	A7QThDelyQ5DKZ9Uvv7jEli9Rlb/JoRz89OWkNICaN7ufljtH4qWSR/EUPCi5665qSQ==
X-Received: by 2002:a24:68c8:: with SMTP id v191mr866222itb.75.1554143671445;
        Mon, 01 Apr 2019 11:34:31 -0700 (PDT)
X-Received: by 2002:a24:68c8:: with SMTP id v191mr866172itb.75.1554143670628;
        Mon, 01 Apr 2019 11:34:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554143670; cv=none;
        d=google.com; s=arc-20160816;
        b=kLwPcZl4RLaCp6gnaA76QHJfxUBtsxgQcSFWl38NVrVkc3r0rTKcDmozHguRQ5XQuI
         BynmTcAwUB1WBxQ9dS7jDFzgZX+eu8Nr3qlhuPoMrCJe+LOx7A00mbp0pBCYTcrw5QUx
         1hBZrBvAmxyuW/j1+A8k0isXyHT3mAYO0HkP+j3q65mroNY8KH573KWABjNM/beowFuD
         uJjqmo21Er7ZwM1QiUpNcZk7xjn5r8Dk7AcnHnlWjmtLbc+7mjbfs6JP9DQIUJf5eBiX
         ltkOLL6mrZVENjPOcFGQC+ai4JN4qioGrfq3by9B4VJfZeQG8lJuj/mS0jqEyEEiTVO+
         YG1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=+53egRqiXPQZ9EJ7mGipuGA/l/Y4XVrW1UL2Rjyi1aY=;
        b=B+GbVwFa/XedmsF2+v13jm4dxo/D0YBBoYY2dIQH+908MeXsosYVBPJbl2zOFmXoRy
         cci8zz/ItrDPxKAnUyTbnH5Vt3ToYDh/KG5ZZ548VVhEL3uV+N6zkclqXP6/nb60BSZ7
         /ek/HAxY8b0yBRYIlQpQEpmwnW55qfBEU/j36e5NAGNnZDDnVTyBN69OrUpqIFjFXZhW
         aN4HGjDbEGnUl/I2kyGiRq55XnB4hY2/2eUKISnrYoTzpQ4cA5kgL+2CtP76C/5YVDRG
         QhFmdvbWGjZkEeqcF9aM04lID7coRVDlw90F2psF35Fr/0FjTE+6yGgV8dedHZ6DtJMr
         lmxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eDYAXQ27;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y2sor29218317jaf.2.2019.04.01.11.34.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Apr 2019 11:34:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eDYAXQ27;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=+53egRqiXPQZ9EJ7mGipuGA/l/Y4XVrW1UL2Rjyi1aY=;
        b=eDYAXQ27VoAC7+Qv2snc75BOR1No525mPjeUWUBN5ZQDYffbsqG/JAEpAH9plTZBA0
         5QmkBdG4vPydgQz3g+pjFgQ4jijgIhtJyqRsUK5t/K4TAfbQZYzCrT65jMljFU3smoXr
         UKSrVqXcCFe1wRXufXWRK2iP3IMDew4disNuXDBwoAQQJy8U6LuDHjnfwAqC/z9XlC/8
         HWrJWMHSvyu2n2yiznM6WDQnPb8F6iPT16jnODrqnMGVN5XL11J1qYeRVdQ4N/DPqWU0
         R248eZh5XqtP72GF5x2vj0EQ4xoI8XZXcbt4Jw6T/DYJPyGnrOHJpr3tHK6mDdQKQCZE
         2NcA==
X-Google-Smtp-Source: APXvYqzZTl9HjDi6RnxdmwsZz5YNWY2r4EgOJRkxEpWp2zd2bQ6DyUFaMDMtV9M2qFewuWS4RaLmhw==
X-Received: by 2002:a02:938f:: with SMTP id z15mr9224027jah.108.1554143670032;
        Mon, 01 Apr 2019 11:34:30 -0700 (PDT)
Received: from google.com ([2620:15c:183:0:a0c3:519e:9276:fc96])
        by smtp.gmail.com with ESMTPSA id f9sm4571750ioo.24.2019.04.01.11.34.29
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 01 Apr 2019 11:34:29 -0700 (PDT)
Date: Mon, 1 Apr 2019 12:34:25 -0600
From: Yu Zhao <yuzhao@google.com>
To: Will Deacon <will.deacon@arm.com>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com,
	mark.rutland@arm.com, suzuki.poulose@arm.com, marc.zyngier@arm.com,
	christoffer.dall@arm.com, james.morse@arm.com,
	julien.thierry@arm.com, kvmarm@lists.cs.columbia.edu
Subject: Re: [PATCH V2] KVM: ARM: Remove pgtable page standard functions from
 stage-2 page tables
Message-ID: <20190401183425.GA106130@google.com>
References: <3be0b7e0-2ef8-babb-88c9-d229e0fdd220@arm.com>
 <1552397145-10665-1-git-send-email-anshuman.khandual@arm.com>
 <20190401161638.GB22092@fuggles.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190401161638.GB22092@fuggles.cambridge.arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 01, 2019 at 05:16:38PM +0100, Will Deacon wrote:
> [+KVM/ARM folks, since I can't take this without an Ack in place from them]
> 
> My understanding is that this patch is intended to replace patch 3/4 in
> this series:
> 
> http://lists.infradead.org/pipermail/linux-arm-kernel/2019-March/638083.html

Yes, and sorry for the confusion. I could send an updated series once
this patch is merged. Thanks.

> On Tue, Mar 12, 2019 at 06:55:45PM +0530, Anshuman Khandual wrote:
> > ARM64 standard pgtable functions are going to use pgtable_page_[ctor|dtor]
> > or pgtable_pmd_page_[ctor|dtor] constructs. At present KVM guest stage-2
> > PUD|PMD|PTE level page tabe pages are allocated with __get_free_page()
> > via mmu_memory_cache_alloc() but released with standard pud|pmd_free() or
> > pte_free_kernel(). These will fail once they start calling into pgtable_
> > [pmd]_page_dtor() for pages which never originally went through respective
> > constructor functions. Hence convert all stage-2 page table page release
> > functions to call buddy directly while freeing pages.
> > 
> > Reviewed-by: Suzuki K Poulose <suzuki.poulose@arm.com>
> > Acked-by: Yu Zhao <yuzhao@google.com>
> > Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> > ---
> > Changes in V2:
> > 
> > - Updated stage2_pud_free() with NOP as per Suzuki
> > - s/__free_page/free_page/ in clear_stage2_pmd_entry() for uniformity
> > 
> >  arch/arm/include/asm/stage2_pgtable.h   | 4 ++--
> >  arch/arm64/include/asm/stage2_pgtable.h | 4 ++--
> >  virt/kvm/arm/mmu.c                      | 2 +-
> >  3 files changed, 5 insertions(+), 5 deletions(-)
> > 
> > diff --git a/arch/arm/include/asm/stage2_pgtable.h b/arch/arm/include/asm/stage2_pgtable.h
> > index de2089501b8b..fed02c3b4600 100644
> > --- a/arch/arm/include/asm/stage2_pgtable.h
> > +++ b/arch/arm/include/asm/stage2_pgtable.h
> > @@ -32,14 +32,14 @@
> >  #define stage2_pgd_present(kvm, pgd)		pgd_present(pgd)
> >  #define stage2_pgd_populate(kvm, pgd, pud)	pgd_populate(NULL, pgd, pud)
> >  #define stage2_pud_offset(kvm, pgd, address)	pud_offset(pgd, address)
> > -#define stage2_pud_free(kvm, pud)		pud_free(NULL, pud)
> > +#define stage2_pud_free(kvm, pud)		do { } while (0)
> >  
> >  #define stage2_pud_none(kvm, pud)		pud_none(pud)
> >  #define stage2_pud_clear(kvm, pud)		pud_clear(pud)
> >  #define stage2_pud_present(kvm, pud)		pud_present(pud)
> >  #define stage2_pud_populate(kvm, pud, pmd)	pud_populate(NULL, pud, pmd)
> >  #define stage2_pmd_offset(kvm, pud, address)	pmd_offset(pud, address)
> > -#define stage2_pmd_free(kvm, pmd)		pmd_free(NULL, pmd)
> > +#define stage2_pmd_free(kvm, pmd)		free_page((unsigned long)pmd)
> >  
> >  #define stage2_pud_huge(kvm, pud)		pud_huge(pud)
> >  
> > diff --git a/arch/arm64/include/asm/stage2_pgtable.h b/arch/arm64/include/asm/stage2_pgtable.h
> > index 5412fa40825e..915809e4ac32 100644
> > --- a/arch/arm64/include/asm/stage2_pgtable.h
> > +++ b/arch/arm64/include/asm/stage2_pgtable.h
> > @@ -119,7 +119,7 @@ static inline pud_t *stage2_pud_offset(struct kvm *kvm,
> >  static inline void stage2_pud_free(struct kvm *kvm, pud_t *pud)
> >  {
> >  	if (kvm_stage2_has_pud(kvm))
> > -		pud_free(NULL, pud);
> > +		free_page((unsigned long)pud);
> >  }
> >  
> >  static inline bool stage2_pud_table_empty(struct kvm *kvm, pud_t *pudp)
> > @@ -192,7 +192,7 @@ static inline pmd_t *stage2_pmd_offset(struct kvm *kvm,
> >  static inline void stage2_pmd_free(struct kvm *kvm, pmd_t *pmd)
> >  {
> >  	if (kvm_stage2_has_pmd(kvm))
> > -		pmd_free(NULL, pmd);
> > +		free_page((unsigned long)pmd);
> >  }
> >  
> >  static inline bool stage2_pud_huge(struct kvm *kvm, pud_t pud)
> > diff --git a/virt/kvm/arm/mmu.c b/virt/kvm/arm/mmu.c
> > index e9d28a7ca673..cbfbdadca8a5 100644
> > --- a/virt/kvm/arm/mmu.c
> > +++ b/virt/kvm/arm/mmu.c
> > @@ -191,7 +191,7 @@ static void clear_stage2_pmd_entry(struct kvm *kvm, pmd_t *pmd, phys_addr_t addr
> >  	VM_BUG_ON(pmd_thp_or_huge(*pmd));
> >  	pmd_clear(pmd);
> >  	kvm_tlb_flush_vmid_ipa(kvm, addr);
> > -	pte_free_kernel(NULL, pte_table);
> > +	free_page((unsigned long)pte_table);
> >  	put_page(virt_to_page(pmd));
> >  }
> >  
> > -- 
> > 2.20.1
> > 

