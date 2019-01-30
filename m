Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E434C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 10:52:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 188B120857
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 10:52:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 188B120857
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A762C8E0002; Wed, 30 Jan 2019 05:52:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A260E8E0001; Wed, 30 Jan 2019 05:52:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 93C788E0002; Wed, 30 Jan 2019 05:52:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 520CB8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 05:52:44 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id a9so16620533pla.2
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 02:52:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=MRNwiROVM7y711Xlw0zX40ICsHqIIxWR66JS1NF+F8Y=;
        b=NvGrbK3pkpMuvCFTLd1R0tUlOcHmMYepcKapVbOW+miRIlyS0myETgfhCy0OzdOsd2
         VVaYeTAmgNCTTohIcFXmtH+siobWATwEs4mcoN1BCb52Akuo742ytCoECq9IqhY3nT+Y
         al/aHP9b9H1mVDAzsdyVpiI5KlMtgxZQJdldaiVUQfYc5B0KF/PQ0Ao13aRzgi780O1a
         Xhebjw1ClxplYa3yHVTwvLjh5bsjLyJtblMDRDbSBC/S9JWrOhh+NWVk1Aye6cpNK3xX
         CW5W6at7ue6WD96QmxD7D8NcYOcLj99PcRSmhCQwMNNirqcyuwjIXZfx5HLdKkuVTMJK
         M5NA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AJcUukfVmed0Aqbewo25XTIU1uJo2O+EFfdQYOOUcHFu7zucTuDnHc3c
	5IXxrM5lGZuujjbFAcIaTJnC/V3rVfOQowSKvMxrpU02rqDhmGvUmKeCi09gpybTg2cXMta4TqG
	d4QAaaM1qRAcURcgGkBwi3ip/NExKvScrHbs73VCrk4WBp/a2aIHIpOKA0j3n3o4=
X-Received: by 2002:a63:e21:: with SMTP id d33mr27015283pgl.272.1548845563980;
        Wed, 30 Jan 2019 02:52:43 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5bk8xNyqyAW82LljbD9Ao6r4VDZfPorAvyf31zyjbUb2/890gXPlPQh+Y1A2eXQPHI0p26
X-Received: by 2002:a63:e21:: with SMTP id d33mr27015250pgl.272.1548845563152;
        Wed, 30 Jan 2019 02:52:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548845563; cv=none;
        d=google.com; s=arc-20160816;
        b=WwHigMz7gNrhhpacbldqj3u2+UND/frpmb/ZsisTkNrCgAEBXxhPdkBqhCXdQrxeyu
         ebwJL2UN79yW9ygs7m5UrhexSSyXyC/kS47Yeip+ACT1AbZZV7DIViMEdVTS+MLEBy83
         uMTTZ5zVCDR+5uL76HqwyDGhTV6i+uqB6lCTGMI/ybzB7OJXI+yOLg8RJZVbHNe/KrWS
         uNLKKmRm3M2awEsRfYUH+8x1X8RjfelprR0HHl7X8rCpClRYiwq5USKuc9U6S3VO/F6e
         O6veK2c1UFuv1kR9IwsTxOgi02j6cxp6sJGwGoVd5RO0PDuRez8p9vCKDeysNxeiDLRB
         +jYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=MRNwiROVM7y711Xlw0zX40ICsHqIIxWR66JS1NF+F8Y=;
        b=lF70+atxJj/Ib2fnDsWN8rOvRMRDXPdmn76cFpb20YfPbaoPV+/Nypl3lyOH8aNtfh
         7ziWsmZQZMsXztemk/iign1zNBI1WTOMtIeH3kePx0KuYOIHa3TvqYHxu5D12kZFGGLr
         ZSD3umJsMCdKzRY4/pZhiACOLmpjivjHSn/tgx6LJNA9kFs40VxiEGvIboxXpJwkO12g
         kaa+5sDIr5QDfG+XTgXhxj2hjcBQAcccu+Za9m93F6RXsx2aWR+17ik9duJT73jwMvRn
         vV9TQlCwFRfOz2IIRzuOVyiZRFAJ6chl1nTeTm7lMVFDsoLAuZ7J+Udt4LE3A/lyxfkZ
         ReqA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id u11si1183467plq.287.2019.01.30.02.52.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Jan 2019 02:52:43 -0800 (PST)
Received-SPF: neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 43qKvW28qXz9s3q;
	Wed, 30 Jan 2019 21:52:39 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, x86@kernel.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: Re: [PATCH V5 3/5] arch/powerpc/mm: Nest MMU workaround for mprotect RW upgrade.
In-Reply-To: <20190116085035.29729-4-aneesh.kumar@linux.ibm.com>
References: <20190116085035.29729-1-aneesh.kumar@linux.ibm.com> <20190116085035.29729-4-aneesh.kumar@linux.ibm.com>
Date: Wed, 30 Jan 2019 21:52:38 +1100
Message-ID: <87fttaqux5.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:
> NestMMU requires us to mark the pte invalid and flush the tlb when we do a
> RW upgrade of pte. We fixed a variant of this in the fault path in commit
> Fixes: bd5050e38aec ("powerpc/mm/radix: Change pte relax sequence to handle nest MMU hang")

You don't want the "Fixes:" there.

>
> Do the same for mprotect upgrades.
>
> Hugetlb is handled in the next patch.
>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
>  arch/powerpc/include/asm/book3s/64/pgtable.h | 18 ++++++++++++++
>  arch/powerpc/include/asm/book3s/64/radix.h   |  4 ++++
>  arch/powerpc/mm/pgtable-book3s64.c           | 25 ++++++++++++++++++++
>  arch/powerpc/mm/pgtable-radix.c              | 18 ++++++++++++++
>  4 files changed, 65 insertions(+)
>
> diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
> index 2e6ada28da64..92eaea164700 100644
> --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
> +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
> @@ -1314,6 +1314,24 @@ static inline int pud_pfn(pud_t pud)
>  	BUILD_BUG();
>  	return 0;
>  }

Can we get a blank line here?

> +#define __HAVE_ARCH_PTEP_MODIFY_PROT_TRANSACTION
> +pte_t ptep_modify_prot_start(struct vm_area_struct *, unsigned long, pte_t *);
> +void ptep_modify_prot_commit(struct vm_area_struct *, unsigned long,
> +			     pte_t *, pte_t, pte_t);

So these are not inline ...

> +/*
> + * Returns true for a R -> RW upgrade of pte
> + */
> +static inline bool is_pte_rw_upgrade(unsigned long old_val, unsigned long new_val)
> +{
> +	if (!(old_val & _PAGE_READ))
> +		return false;
> +
> +	if ((!(old_val & _PAGE_WRITE)) && (new_val & _PAGE_WRITE))
> +		return true;
> +
> +	return false;
> +}
>  
>  #endif /* __ASSEMBLY__ */
>  #endif /* _ASM_POWERPC_BOOK3S_64_PGTABLE_H_ */
> diff --git a/arch/powerpc/mm/pgtable-book3s64.c b/arch/powerpc/mm/pgtable-book3s64.c
> index f3c31f5e1026..47c742f002ea 100644
> --- a/arch/powerpc/mm/pgtable-book3s64.c
> +++ b/arch/powerpc/mm/pgtable-book3s64.c
> @@ -400,3 +400,28 @@ void arch_report_meminfo(struct seq_file *m)
>  		   atomic_long_read(&direct_pages_count[MMU_PAGE_1G]) << 20);
>  }
>  #endif /* CONFIG_PROC_FS */
> +
> +pte_t ptep_modify_prot_start(struct vm_area_struct *vma, unsigned long addr,
> +			     pte_t *ptep)
> +{
> +	unsigned long pte_val;
> +
> +	/*
> +	 * Clear the _PAGE_PRESENT so that no hardware parallel update is
> +	 * possible. Also keep the pte_present true so that we don't take
> +	 * wrong fault.
> +	 */
> +	pte_val = pte_update(vma->vm_mm, addr, ptep, _PAGE_PRESENT, _PAGE_INVALID, 0);
> +
> +	return __pte(pte_val);
> +
> +}
> +
> +void ptep_modify_prot_commit(struct vm_area_struct *vma, unsigned long addr,
> +			     pte_t *ptep, pte_t old_pte, pte_t pte)
> +{

Which means we're going to be doing a function call to get to here ...

> +	if (radix_enabled())
> +		return radix__ptep_modify_prot_commit(vma, addr,
> +						      ptep, old_pte, pte);

And then another function call to get to the radix version ...

> +	set_pte_at(vma->vm_mm, addr, ptep, pte);
> +}
> diff --git a/arch/powerpc/mm/pgtable-radix.c b/arch/powerpc/mm/pgtable-radix.c
> index 931156069a81..dced3cd241c2 100644
> --- a/arch/powerpc/mm/pgtable-radix.c
> +++ b/arch/powerpc/mm/pgtable-radix.c
> @@ -1063,3 +1063,21 @@ void radix__ptep_set_access_flags(struct vm_area_struct *vma, pte_t *ptep,
>  	}
>  	/* See ptesync comment in radix__set_pte_at */
>  }
> +
> +void radix__ptep_modify_prot_commit(struct vm_area_struct *vma,
> +				    unsigned long addr, pte_t *ptep,
> +				    pte_t old_pte, pte_t pte)
> +{
> +	struct mm_struct *mm = vma->vm_mm;
> +
> +	/*
> +	 * To avoid NMMU hang while relaxing access we need to flush the tlb before
> +	 * we set the new value. We need to do this only for radix, because hash
> +	 * translation does flush when updating the linux pte.
> +	 */
> +	if (is_pte_rw_upgrade(pte_val(old_pte), pte_val(pte)) &&
> +	    (atomic_read(&mm->context.copros) > 0))
> +		radix__flush_tlb_page(vma, addr);

To finally get here, where we'll realise that 99.99% of processes don't
use copros and so we have nothing to do except set the PTE.

> +
> +	set_pte_at(mm, addr, ptep, pte);
> +}

So can we just make it all inline in the header? Or do we think it's not
a hot enough path to worry about it?

cheers

