Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38ECDC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 10:34:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E7C20218A3
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 10:34:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7C20218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 889AF8E0003; Wed, 30 Jan 2019 05:34:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 838E38E0001; Wed, 30 Jan 2019 05:34:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 74EAA8E0003; Wed, 30 Jan 2019 05:34:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 335FE8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 05:34:07 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id 12so16500314plb.18
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 02:34:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=hAsTxnO/hqW6Htm5TTGboCiwni7rWDGAfubBbLlUiXM=;
        b=V20Zh5I/r/hj4MV007rAzeg2OT+bCgfZnG9TtkWGPbjQ3P+Y5QHeIF+75q2Cvx/VD+
         f5iJ6GkRPcgSikmRBBgnKV5d3a0kzrBsKH/i5xiHrEJ0CyJEqQEVRu8Ii/oRqK5KjJ8/
         CUzomlk+xLYXB/zBQIrZztweJauQxtcQeQmYSr7/UiY09grTpZw54ot7dyzH34jqFrf6
         WyrDiPshOBX3vheMkKkr3CT+O9nK8U5ypAd51AjwJSgjVmF2NjqWniuyxkALVzen2Aau
         QqalPtWj5iDWwmFbiB+xIRt6K4hoBLvoRzD4F3B56jxE2ogXCFFPOgMSlQ0MuHEnFKj5
         sTbQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AJcUukeDd15oaPVbG2dgpLu0KqHO7P8Q+qEncFQmGMf2l4I5OHASR3mo
	Kh4VfO7kMNhslnQuQD28MbxZJ6r2hDFoGWkiYURNwe1ENpO062K3NRI2vAg+0zghlv+OUcuRCEW
	GLinYs1wNDJwmCRjmMRs3yP9RH372kTmfwGxQV269idlJzQ8iMnVCGw6HCkkZ+fc=
X-Received: by 2002:a63:101:: with SMTP id 1mr27083042pgb.152.1548844446787;
        Wed, 30 Jan 2019 02:34:06 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5l27ZGliSLvxv3dSLQGQkHvspZPHoTa7elQEPQ0REt6QMtHnlFBExSZwzdaUP87F1TGokY
X-Received: by 2002:a63:101:: with SMTP id 1mr27083009pgb.152.1548844446029;
        Wed, 30 Jan 2019 02:34:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548844446; cv=none;
        d=google.com; s=arc-20160816;
        b=iu8g/SvRmOTmKGa5M7jK3urcboDdTC3tEEpZDlHb8wsBVZZat+jAOG25WFgR/a+r+5
         rrlKtbwlWcsTbYKOGQGFuuw3AxLuyBDu2DhLK2KeyLW2zfTBXT/gZM4+Qb69jkW6bTQO
         KzQMjOq5Nw8Pvz7T1hOI/S1qTwICjXs4b9nLTx9rvmVh1QSdYq4I6UlIhBvQrnZTJVCQ
         Yezptbh56g+n675EIpRtCR1HJ3TuuI/H/m+Cu2D+LhyqfXdCI1uEmphJds8WkJZtbdss
         0HYmVz6nHrSgMZiNJisdxNV4b4n1DO45W4zlGq5n3hThc1NO+0zdPj29/4phr08FS20d
         yK+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=hAsTxnO/hqW6Htm5TTGboCiwni7rWDGAfubBbLlUiXM=;
        b=iCvnAfYu0eeEg116g/skhok6EtNId50MEM1smiMKxfMShMTvS04hNd7baBL3kziYUd
         U5ue4lUBAK6GCK5QN3clS4OUcPuKfFPyC3HO7JJslZzaBbnvuSU43iToNGeh8Dtz2muO
         KfCX7bym7Y0dO2iUSAiSdIUb9MUbrE6saqOZmOjtAlPPx11IXO7IWJSbBIoBe2vzRShQ
         p7uJ0rn0/Ab6Nt4l7Hb7yWmtPQgTzTgL+aci6UwX6WXJ7rMJThDGXfM2lvLLuL5FduiF
         sdVV/evtlJdPNlvazQAhi+URZ/mP8kA+4qrb9AsN/Q/KhwLnhWbh1CabG+hoMJDW0h/N
         d8sQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id x6si1082787pgh.363.2019.01.30.02.34.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Jan 2019 02:34:05 -0800 (PST)
Received-SPF: neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 43qKV265Vdz9s9G;
	Wed, 30 Jan 2019 21:34:02 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, x86@kernel.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: Re: [PATCH V5 1/5] mm: Update ptep_modify_prot_start/commit to take vm_area_struct as arg
In-Reply-To: <20190116085035.29729-2-aneesh.kumar@linux.ibm.com>
References: <20190116085035.29729-1-aneesh.kumar@linux.ibm.com> <20190116085035.29729-2-aneesh.kumar@linux.ibm.com>
Date: Wed, 30 Jan 2019 21:33:57 +1100
Message-ID: <87lg32qvsa.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:

> Some architecture may want to call flush_tlb_range from these helpers.

That's what we want to do, but wouldn't a better description be that
some architectures may need access to the vma for some reason, one of
which might be flushing the TLB.

> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
>  arch/s390/include/asm/pgtable.h       |  4 ++--
>  arch/s390/mm/pgtable.c                |  6 ++++--
>  arch/x86/include/asm/paravirt.h       | 11 ++++++-----
>  arch/x86/include/asm/paravirt_types.h |  5 +++--
>  arch/x86/xen/mmu.h                    |  4 ++--
>  arch/x86/xen/mmu_pv.c                 |  8 ++++----
>  fs/proc/task_mmu.c                    |  4 ++--
>  include/asm-generic/pgtable.h         | 16 ++++++++--------
>  mm/memory.c                           |  4 ++--
>  mm/mprotect.c                         |  4 ++--
>  10 files changed, 35 insertions(+), 31 deletions(-)
>
> diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
> index 063732414dfb..5d730199e37b 100644
> --- a/arch/s390/include/asm/pgtable.h
> +++ b/arch/s390/include/asm/pgtable.h
> @@ -1069,8 +1069,8 @@ static inline pte_t ptep_get_and_clear(struct mm_struct *mm,
>  }
>  
>  #define __HAVE_ARCH_PTEP_MODIFY_PROT_TRANSACTION
> -pte_t ptep_modify_prot_start(struct mm_struct *, unsigned long, pte_t *);
> -void ptep_modify_prot_commit(struct mm_struct *, unsigned long, pte_t *, pte_t);
> +pte_t ptep_modify_prot_start(struct vm_area_struct *, unsigned long, pte_t *);
> +void ptep_modify_prot_commit(struct vm_area_struct *, unsigned long, pte_t *, pte_t);
>  
>  #define __HAVE_ARCH_PTEP_CLEAR_FLUSH
>  static inline pte_t ptep_clear_flush(struct vm_area_struct *vma,
> diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
> index f2cc7da473e4..29c0a21cd34a 100644
> --- a/arch/s390/mm/pgtable.c
> +++ b/arch/s390/mm/pgtable.c
> @@ -301,12 +301,13 @@ pte_t ptep_xchg_lazy(struct mm_struct *mm, unsigned long addr,
>  }
>  EXPORT_SYMBOL(ptep_xchg_lazy);
>  
> -pte_t ptep_modify_prot_start(struct mm_struct *mm, unsigned long addr,
> +pte_t ptep_modify_prot_start(struct vm_area_struct *vma, unsigned long addr,
>  			     pte_t *ptep)
>  {
>  	pgste_t pgste;
>  	pte_t old;
>  	int nodat;
> +	struct mm_struct *mm = vma->vm_mm;

If this was my code I'd want the mm as the first variable, to preserve
the Reverse Christmas tree format.

>  	preempt_disable();
>  	pgste = ptep_xchg_start(mm, addr, ptep);
> @@ -320,10 +321,11 @@ pte_t ptep_modify_prot_start(struct mm_struct *mm, unsigned long addr,
>  }
>  EXPORT_SYMBOL(ptep_modify_prot_start);
>  
> -void ptep_modify_prot_commit(struct mm_struct *mm, unsigned long addr,
> +void ptep_modify_prot_commit(struct vm_area_struct *vma, unsigned long addr,
>  			     pte_t *ptep, pte_t pte)
>  {
>  	pgste_t pgste;
> +	struct mm_struct *mm = vma->vm_mm;
  
Ditto.

>  	if (!MACHINE_HAS_NX)
>  		pte_val(pte) &= ~_PAGE_NOEXEC;
> diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
> index a97f28d914d5..c5a7f18cce7e 100644
> --- a/arch/x86/include/asm/paravirt.h
> +++ b/arch/x86/include/asm/paravirt.h
> @@ -422,25 +422,26 @@ static inline pgdval_t pgd_val(pgd_t pgd)
>  }
>  
>  #define  __HAVE_ARCH_PTEP_MODIFY_PROT_TRANSACTION
> -static inline pte_t ptep_modify_prot_start(struct mm_struct *mm, unsigned long addr,
> +static inline pte_t ptep_modify_prot_start(struct vm_area_struct *vma, unsigned long addr,
>  					   pte_t *ptep)
>  {
>  	pteval_t ret;
>  
> -	ret = PVOP_CALL3(pteval_t, mmu.ptep_modify_prot_start, mm, addr, ptep);
> +	ret = PVOP_CALL3(pteval_t, mmu.ptep_modify_prot_start, vma, addr, ptep);
>  
>  	return (pte_t) { .pte = ret };
>  }
>  
> -static inline void ptep_modify_prot_commit(struct mm_struct *mm, unsigned long addr,
> +static inline void ptep_modify_prot_commit(struct vm_area_struct *vma, unsigned long addr,
>  					   pte_t *ptep, pte_t pte)
>  {
> +

Unnecessary blank line here.

>  	if (sizeof(pteval_t) > sizeof(long))
>  		/* 5 arg words */
> -		pv_ops.mmu.ptep_modify_prot_commit(mm, addr, ptep, pte);
> +		pv_ops.mmu.ptep_modify_prot_commit(vma, addr, ptep, pte);
>  	else
>  		PVOP_VCALL4(mmu.ptep_modify_prot_commit,
> -			    mm, addr, ptep, pte.pte);
> +			    vma, addr, ptep, pte.pte);
>  }
>  
>  static inline void set_pte(pte_t *ptep, pte_t pte)

The rest looks good.

cheers

