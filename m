Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	UNWANTED_LANGUAGE_BODY,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCFA5C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 09:21:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82FA42184A
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 09:21:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82FA42184A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 178958E0003; Thu, 28 Feb 2019 04:21:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 102CB8E0001; Thu, 28 Feb 2019 04:21:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F0CC38E0003; Thu, 28 Feb 2019 04:21:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 942B08E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 04:21:04 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e46so8321161ede.9
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 01:21:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=yiX6uAf/WUFtOPz9qYacHQSf4FhObRYVqDYHqLC7T2k=;
        b=LathUsnx9/skBkjkualdoHBpRPC/wO+TFihqXFZjUVlZsT7xipPpvRzp8RpgKl3hjl
         E/ELUmW2dG+xPgnQDIDA9qn63vsuc2nhpMHsLMRn3RzPlfgZEKQMYD6dJhpMg3GytaMX
         EbwgyGOhUXVIZ8ndf7V8pYNdSKoa/JLUxnoxo+c2Dap6qdQDhZXeI5+M1mRaQV++Gcv1
         c2TRdMIn32pTB3JyNqGG+P1x3crujRguGvOT9f1cepNh0OFb61hM8CmUKXFNUGbh73FM
         MT6pmTTMwKfwB/BG9LYW0bIXzwQK0EwNASd6yqfCfi+Aq+r7cyW4WmAvqLkhe7gutXjc
         eVMg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AHQUAualSkQnoSFTOOevRSQgILUwhRdNYMF8sM+UOsynpVEP/YULtH0Q
	o3ZtoM8HLYHA2RnSChsBtX166Yvv/EdZ35ltmmeIsflFOgAtPuXDoNbJsJzF6Ow3HNiId+eozRb
	qyChqNO/bS4TESvYqfQnXhz783br8aQkH2e3qdrmy8UAUQv10N954/fFTuWRmQxDu+A==
X-Received: by 2002:a50:be42:: with SMTP id b2mr5924728edi.78.1551345664150;
        Thu, 28 Feb 2019 01:21:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYmdhejFPoGQmTFAJGlfQNS4ApHVuc2f1ksB7yUfM8oGP+Q1Tads1C5nXrPWdKSKDhW43oZ
X-Received: by 2002:a50:be42:: with SMTP id b2mr5924675edi.78.1551345663250;
        Thu, 28 Feb 2019 01:21:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551345663; cv=none;
        d=google.com; s=arc-20160816;
        b=divGkJnsR/UZh1Jp007BCxMgvq+WiIM1R6ylJm8P7TJJY3QeeO8B48X3DAXB3aVjgY
         KGRQvzNQQAmz3jWIkk5ypWm54vRx4H/P0WtMu3GWLthjMZQb1M7nKrLygtWXATT/AY46
         MN7GqY6/jtMJDxDvvqCAAL+WCawsJvEBAJG24QW0nxT9NU/vGAFGLP3Hm1ZBFXXwrZ7h
         /SeaNg6nBr+yR+a/hj98HLNcTtzA5JVHxVaDi/NxxUR8jxmXIv8fYVXyKjzM8j3vErUP
         fPDrcNywPd8yWCbr5Jv+wuJCTHdSjoFWc+ssyqMPtb5KpGYKq+4pCNfmD9gr3el9eGVf
         Lj2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=yiX6uAf/WUFtOPz9qYacHQSf4FhObRYVqDYHqLC7T2k=;
        b=WrEWEIcl6zzgkJgYmB+9SaBdJTB/+ZnJpmjD25PHuEXIoawfjA7nTaM8FxsiE+iggp
         ikUGM9dpMA3V3l64onnwn09yJrh+FV4VBZasNlwN2zNaJj8ru7u5EdIe137SnzRneu1D
         CdLl3NzWksf/lk/eGuKgN5hlilRt4VnKna6Zi0WWApuuGzXGqHvAAdx22MgOZc9oLLJN
         GdbUvxqyw0Z9VAVIwLc1TCNGS1QMlW2CAwS38thwYbGwLJjCHHcPSynxxFXCgDrAsSQM
         je72WlbPR8eg7jMthpc60Q/XrmooySgvmcZCGIPzfD/XGWD8GOVd2rbIDUAqfeHhRraK
         9b6A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p18si3901839ejj.234.2019.02.28.01.21.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 01:21:03 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4904DAC5A;
	Thu, 28 Feb 2019 09:21:02 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id E00081E4263; Thu, 28 Feb 2019 10:21:01 +0100 (CET)
Date: Thu, 28 Feb 2019 10:21:01 +0100
From: Jan Kara <jack@suse.cz>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: akpm@linux-foundation.org,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Jan Kara <jack@suse.cz>, mpe@ellerman.id.au,
	Ross Zwisler <zwisler@kernel.org>,
	Oliver O'Halloran <oohall@gmail.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH 1/2] fs/dax: deposit pagetable even when installing zero
 page
Message-ID: <20190228092101.GA22210@quack2.suse.cz>
References: <20190228083522.8189-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190228083522.8189-1-aneesh.kumar@linux.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 28-02-19 14:05:21, Aneesh Kumar K.V wrote:
> Architectures like ppc64 use the deposited page table to store hardware
> page table slot information. Make sure we deposit a page table when
> using zero page at the pmd level for hash.
> 
> Without this we hit
> 
> Unable to handle kernel paging request for data at address 0x00000000
> Faulting instruction address: 0xc000000000082a74
> Oops: Kernel access of bad area, sig: 11 [#1]
> ....
> 
> NIP [c000000000082a74] __hash_page_thp+0x224/0x5b0
> LR [c0000000000829a4] __hash_page_thp+0x154/0x5b0
> Call Trace:
>  hash_page_mm+0x43c/0x740
>  do_hash_page+0x2c/0x3c
>  copy_from_iter_flushcache+0xa4/0x4a0
>  pmem_copy_from_iter+0x2c/0x50 [nd_pmem]
>  dax_copy_from_iter+0x40/0x70
>  dax_iomap_actor+0x134/0x360
>  iomap_apply+0xfc/0x1b0
>  dax_iomap_rw+0xac/0x130
>  ext4_file_write_iter+0x254/0x460 [ext4]
>  __vfs_write+0x120/0x1e0
>  vfs_write+0xd8/0x220
>  SyS_write+0x6c/0x110
>  system_call+0x3c/0x130
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>

Thanks for the patch. It looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

> ---
> TODO:
> * Add fixes tag 

Probably this is a problem since initial PPC PMEM support, isn't it?

								Honza

> 
>  fs/dax.c | 15 +++++++++++++++
>  1 file changed, 15 insertions(+)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index 6959837cc465..01bfb2ac34f9 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -33,6 +33,7 @@
>  #include <linux/sizes.h>
>  #include <linux/mmu_notifier.h>
>  #include <linux/iomap.h>
> +#include <asm/pgalloc.h>
>  #include "internal.h"
>  
>  #define CREATE_TRACE_POINTS
> @@ -1410,7 +1411,9 @@ static vm_fault_t dax_pmd_load_hole(struct xa_state *xas, struct vm_fault *vmf,
>  {
>  	struct address_space *mapping = vmf->vma->vm_file->f_mapping;
>  	unsigned long pmd_addr = vmf->address & PMD_MASK;
> +	struct vm_area_struct *vma = vmf->vma;
>  	struct inode *inode = mapping->host;
> +	pgtable_t pgtable = NULL;
>  	struct page *zero_page;
>  	spinlock_t *ptl;
>  	pmd_t pmd_entry;
> @@ -1425,12 +1428,22 @@ static vm_fault_t dax_pmd_load_hole(struct xa_state *xas, struct vm_fault *vmf,
>  	*entry = dax_insert_entry(xas, mapping, vmf, *entry, pfn,
>  			DAX_PMD | DAX_ZERO_PAGE, false);
>  
> +	if (arch_needs_pgtable_deposit()) {
> +		pgtable = pte_alloc_one(vma->vm_mm);
> +		if (!pgtable)
> +			return VM_FAULT_OOM;
> +	}
> +
>  	ptl = pmd_lock(vmf->vma->vm_mm, vmf->pmd);
>  	if (!pmd_none(*(vmf->pmd))) {
>  		spin_unlock(ptl);
>  		goto fallback;
>  	}
>  
> +	if (pgtable) {
> +		pgtable_trans_huge_deposit(vma->vm_mm, vmf->pmd, pgtable);
> +		mm_inc_nr_ptes(vma->vm_mm);
> +	}
>  	pmd_entry = mk_pmd(zero_page, vmf->vma->vm_page_prot);
>  	pmd_entry = pmd_mkhuge(pmd_entry);
>  	set_pmd_at(vmf->vma->vm_mm, pmd_addr, vmf->pmd, pmd_entry);
> @@ -1439,6 +1452,8 @@ static vm_fault_t dax_pmd_load_hole(struct xa_state *xas, struct vm_fault *vmf,
>  	return VM_FAULT_NOPAGE;
>  
>  fallback:
> +	if (pgtable)
> +		pte_free(vma->vm_mm, pgtable);
>  	trace_dax_pmd_load_hole_fallback(inode, vmf, zero_page, *entry);
>  	return VM_FAULT_FALLBACK;
>  }
> -- 
> 2.20.1
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

