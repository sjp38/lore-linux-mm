Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A662C10F00
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 15:24:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25F3820830
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 15:24:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25F3820830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC1DE6B000D; Tue,  2 Apr 2019 11:24:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B709F6B000E; Tue,  2 Apr 2019 11:24:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A39F86B0010; Tue,  2 Apr 2019 11:24:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4C64C6B000D
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 11:24:08 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id e16so3533214edj.1
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 08:24:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=uJOYD+SbG9xO21G2yGVVuimf0CFBb7muchMzhEdgSUc=;
        b=awF3MemvM73vGNE7ROO4JaQuV0B+FDClXfyOx3hX67b7s6TyuDt//X04L9+0Mfc9zO
         pXIBiHnPaW1yFj2DMQA2q3YdbPsfVqlYuD3Jm3urG7/jn7gkLyffQl7HvynoC7ccx9Zf
         M6xzdpCAOEVr1J5e1YbVn6WcqsQSGzdTvugGcr7630adJzACCZIURHQifqdrRuBiOMGR
         4mwvonk2ujA9d2anvt2Jlk1xvp31eBBisL3j1ibCvs0xqK41M1V2HiUzVKpDge+33EZf
         4srpRdZ2GsFg9k503Qfv0gHB7xoqe0dTy5Ws5CMK+V6FMMaoYngPCFLUIkkTyQ41BCHy
         Zmng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAXM/DuXlPijY+dA/7OODBJn/Lej+qXAq6UM0pJBXjNSG8o4c483
	FMis3EijdOmfREs3nF/ptE4+7YKFmkE0/gzrbBBmj/rcxlASaGLymipROXHCY4hKsHPQloV/zk4
	+Vg+mD+2AhT3XgPFHyWtXS588Uzde/0dqfXP0yUAnPRXToyT+0kGIMsmm7E0n5w+4RQ==
X-Received: by 2002:a50:b1fa:: with SMTP id n55mr47714233edd.34.1554218647862;
        Tue, 02 Apr 2019 08:24:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxX3U97cPY6QerF6aJLHVskkSyHfvRk+EyYaxIVaIr8KW/TpJGq3pL5ye+uJHinEc0weMh7
X-Received: by 2002:a50:b1fa:: with SMTP id n55mr47714182edd.34.1554218647041;
        Tue, 02 Apr 2019 08:24:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554218647; cv=none;
        d=google.com; s=arc-20160816;
        b=Zf2rlQJaRWxOivK4VLa0faWKclTEELY9MlTCmnhFyiFhukYDvr0yeiJ/hO7xATRCGj
         10OQAlE6B/o3d5neP9MqGN9xLDuxPjRzTaCEzjB3Lvm9LMUp7IiMncA5EBkFoqaj+Ns0
         FblWomKRhSFczpamNDhbAPX7vzBcZJvC6MBZ/xyqbwyAkJSUnIVkhwMz6qyhcfq59dRI
         zRZ+wrwv7twm1+0x96W/kfLX7GEqUF8/LECFdIxpuWNuNPG5g7GHC7JM7kxsf93QTBtO
         MQV8YrFvocr502+3Gk5/DRjyAFZv465Q77EyWh4RCZZPjra2zmVcsyYBH9nn7YUysl/2
         wRsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=uJOYD+SbG9xO21G2yGVVuimf0CFBb7muchMzhEdgSUc=;
        b=n9aRDnRDc6qizHjco+2kzaUCpW7dul4SxzzJhXH7D1LN4MKkdjPwCP+UPj4ESA9em7
         59+Lqpz+5sesBXguULIILj5qslGGlqeby7n6zdVW6xOB75MCEJtrQrlh9aehOgBqz6vb
         nIumbXb0oraaFL2FUel3b0p8qUIGEUrR74svYHLQra982+iHSSQJUxEoP9a2HNAbS1/5
         lJPhkxyKi9wYlV8Yco6Dp8smgLbDbjiBlBXVCPCpBxS5lMO8ELYXCU+WPUlwA6LTJyr2
         1fXg/AIMS70v8a2NfwP96bk4OygWJirjwsCupm2640k8ksamZFIz5OxMMaj2/iEIXIDw
         /Uyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z27si491092edl.146.2019.04.02.08.24.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 08:24:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EF995AFD3;
	Tue,  2 Apr 2019 15:24:05 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 7E39E1E3FD4; Tue,  2 Apr 2019 17:24:05 +0200 (CEST)
Date: Tue, 2 Apr 2019 17:24:05 +0200
From: Jan Kara <jack@suse.cz>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: dan.j.williams@intel.com, akpm@linux-foundation.org,
	Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org,
	linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org,
	stable@vger.kernel.org, Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [PATCH v2] mm: Fix modifying of page protection by
 insert_pfn_pmd()
Message-ID: <20190402152405.GC25668@quack2.suse.cz>
References: <20190402115125.18803-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190402115125.18803-1-aneesh.kumar@linux.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 02-04-19 17:21:25, Aneesh Kumar K.V wrote:
> With some architectures like ppc64, set_pmd_at() cannot cope with
> a situation where there is already some (different) valid entry present.
> 
> Use pmdp_set_access_flags() instead to modify the pfn which is built to
> deal with modifying existing PMD entries.
> 
> This is similar to
> commit cae85cb8add3 ("mm/memory.c: fix modifying of page protection by insert_pfn()")
> 
> We also do similar update w.r.t insert_pfn_pud eventhough ppc64 don't support
> pud pfn entries now.
> 
> Without this patch we also see the below message in kernel log
> "BUG: non-zero pgtables_bytes on freeing mm:"
> 
> CC: stable@vger.kernel.org
> Reported-by: Chandan Rajendra <chandan@linux.ibm.com>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>

Looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
> Changes from v1:
> * Fix the pgtable leak 
> 
>  mm/huge_memory.c | 36 ++++++++++++++++++++++++++++++++++++
>  1 file changed, 36 insertions(+)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 404acdcd0455..165ea46bf149 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -755,6 +755,21 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
>  	spinlock_t *ptl;
>  
>  	ptl = pmd_lock(mm, pmd);
> +	if (!pmd_none(*pmd)) {
> +		if (write) {
> +			if (pmd_pfn(*pmd) != pfn_t_to_pfn(pfn)) {
> +				WARN_ON_ONCE(!is_huge_zero_pmd(*pmd));
> +				goto out_unlock;
> +			}
> +			entry = pmd_mkyoung(*pmd);
> +			entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
> +			if (pmdp_set_access_flags(vma, addr, pmd, entry, 1))
> +				update_mmu_cache_pmd(vma, addr, pmd);
> +		}
> +
> +		goto out_unlock;
> +	}
> +
>  	entry = pmd_mkhuge(pfn_t_pmd(pfn, prot));
>  	if (pfn_t_devmap(pfn))
>  		entry = pmd_mkdevmap(entry);
> @@ -766,11 +781,16 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
>  	if (pgtable) {
>  		pgtable_trans_huge_deposit(mm, pmd, pgtable);
>  		mm_inc_nr_ptes(mm);
> +		pgtable = NULL;
>  	}
>  
>  	set_pmd_at(mm, addr, pmd, entry);
>  	update_mmu_cache_pmd(vma, addr, pmd);
> +
> +out_unlock:
>  	spin_unlock(ptl);
> +	if (pgtable)
> +		pte_free(mm, pgtable);
>  }
>  
>  vm_fault_t vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
> @@ -821,6 +841,20 @@ static void insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
>  	spinlock_t *ptl;
>  
>  	ptl = pud_lock(mm, pud);
> +	if (!pud_none(*pud)) {
> +		if (write) {
> +			if (pud_pfn(*pud) != pfn_t_to_pfn(pfn)) {
> +				WARN_ON_ONCE(!is_huge_zero_pud(*pud));
> +				goto out_unlock;
> +			}
> +			entry = pud_mkyoung(*pud);
> +			entry = maybe_pud_mkwrite(pud_mkdirty(entry), vma);
> +			if (pudp_set_access_flags(vma, addr, pud, entry, 1))
> +				update_mmu_cache_pud(vma, addr, pud);
> +		}
> +		goto out_unlock;
> +	}
> +
>  	entry = pud_mkhuge(pfn_t_pud(pfn, prot));
>  	if (pfn_t_devmap(pfn))
>  		entry = pud_mkdevmap(entry);
> @@ -830,6 +864,8 @@ static void insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
>  	}
>  	set_pud_at(mm, addr, pud, entry);
>  	update_mmu_cache_pud(vma, addr, pud);
> +
> +out_unlock:
>  	spin_unlock(ptl);
>  }
>  
> -- 
> 2.20.1
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

